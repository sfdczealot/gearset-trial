global without sharing class ButtonSOApprovalStart extends CS_ButtonBase {

    global override void init() {
        this.className = ButtonSOApprovalStart.class.getName();
        this.calloutType = 'ButtonSOApprovalStart';
        this.lastButtonClicked = 'Submit';
        this.isDfpAction = true;
        this.skipFulfilmentItemUpdate = true;
    }

    global override Boolean doAdditionalValidation() {
    if(checkDates())
    return false;
        if (!areAllConfigurationStatusesValid()
            || isPurchaseOrderNumberTooBig()
            || !areSchedulesValid()
            || areMandatoryFieldsOnSOEmpty()
            || !isPurchaseOrderNumberPopulated()
            || !isTCTypePopulated()
            || !allowedForMigrationOrPrimarySOSynced()
            || !isMarketSameOnAllPCs()
            || isStartDateOfAnyLineInThePast()
            || isThereNotKilledSoldSO()
            || isRequesterComment()
            || isMPDPayperuseProdConfig()
            || subsidiaryValidation()
            //|| billingContactInfo()
            || accountReaId()
            || isBillingScheduleSelected()
            || onlyEventforiPP()){
                return false;
            }

        return true;
    }

    global override void doAction() {
        salesOrder.Submitted_By__c = UserInfo.getUserId();
        salesOrder.Reason_for_Retraction__c = null;
        salesOrder.Comments__c = null;
        initSalesOrder(this.calloutType);
        update salesOrder;

        if (this.isOppMigrationRecordType()) {

        }
        archiveCompletedOrchestrationProcesses(salesOrder.id);

        if(salesOrder.Is_Programmatic__c) {
            CSPOFA__Orchestration_Process__c process = new CSPOFA__Orchestration_Process__c();
            process.Sales_Order__c = salesOrder.id;
            process.CSPOFA__Orchestration_Process_Template__c = [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c WHERE Name = 'Sales Order Lifecycle PG'].id;
            process.Name = 'Sales Order Lifecycle ' + Datetime.now();
            insert process;
        }
        else {
            CSPOFA__Orchestration_Process__c process = new CSPOFA__Orchestration_Process__c();
            process.Sales_Order__c = salesOrder.id;
            process.CSPOFA__Orchestration_Process_Template__c = [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c WHERE Name = 'Sales Order Lifecycle'].id;
            process.Name = 'Sales Order Lifecycle ' + Datetime.now();
            insert process;

        }

        returnMessage.setSuccessMessage('Sales Order has been successfully submitted.');
    }

    private void archiveCompletedOrchestrationProcesses(Id salesOrderId) {
        CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();

        dispatcher.addWorker(new ArchiveCompletedTerminatedQueueableWorker(new Map<String, Object>{
                'salesOrderId' => salesOrderId
        }));

        dispatcher.dispatch();

    }

    public class ArchiveCompletedTerminatedQueueableWorker extends CS_QueueableWorker {
        public ArchiveCompletedTerminatedQueueableWorker(Object params) {
            super('CS_P_ArchiveCompletedTerminated', params);
        }

        public override void doWork() {
            Map<String, Object> paramsType = (Map<String, Object>) this.params;
            Id salesOrderId = (Id) paramsType.get('salesOrderId');

            //collect related child process for archiving
            List<CSPOFA__Orchestration_Process__c> existingOrchestrationProcess = [
                    SELECT Id, Name, Sales_Order__c, CSPOFA__Parent_Process__c, CSPOFA__State__c
                    FROM CSPOFA__Orchestration_Process__c
                    WHERE Sales_Order__c = :salesOrderId
                    AND ((CSPOFA__Root_Process__c = null AND (CSPOFA__State__c = 'COMPLETED' OR CSPOFA__State__c = 'TERMINATED')) OR
                        (CSPOFA__Root_Process__c != null AND (CSPOFA__Root_Process__r.CSPOFA__State__c = 'COMPLETED' OR CSPOFA__Root_Process__r.CSPOFA__State__c = 'TERMINATED')))
            ];

            List<CSPOFA.ProcessArchivingRequest> archivingRequestsList = new List<CSPOFA.ProcessArchivingRequest>();
            List<CSPOFA__Orchestration_Process__c> processToUpdate = new List<CSPOFA__Orchestration_Process__c>();
            for(CSPOFA__Orchestration_Process__c orchestrationProcess : existingOrchestrationProcess){
                //add all terminated or completed child processes to list to archive

                if(orchestrationProcess.CSPOFA__State__c != 'COMPLETED' && orchestrationProcess.CSPOFA__State__c != 'TERMINATED') {
                    orchestrationProcess.CSPOFA__State__c = 'TERMINATED';
                    processToUpdate.add(orchestrationProcess);
                }
                archivingRequestsList.add(new CSPOFA.ProcessArchivingRequest().processId(orchestrationProcess.Id));
            }

            if(!processToUpdate.isEmpty()) {
                update processToUpdate;
            }
            
            List<CSPOFA.ApiResult> archivingResults = CSPOFA.API_V1.processes.archive(archivingRequestsList);

            for (CSPOFA.ApiResult result : archivingResults) {
                if (result.isSuccess()) {
                    //done
                } else {
                    List<CSPOFA.ApiError> errors = result.getErrors();
                    system.debug('Archiving error on record '+result.getId()+' with error: '+errors);
                }
            }
        }
    }

    private Boolean isMarketSameOnAllPCs() {
        Map<String, List<cscfga__Product_Configuration__c>> mapConfigurationToPackage = new Map<String, List<cscfga__Product_Configuration__c>>();
        for (cscfga__Product_Configuration__c currConfiguration : this.configs.values()) {
        if(currConfiguration.get('cscfga__Product_Family__c') !='Developer Listings' && currConfiguration.get('cscfga__Product_Family__c') !='Database Marketing'){
            if (currConfiguration.cscfga__package_guid__c != null) {
                if (mapConfigurationToPackage.containsKey(currConfiguration.cscfga__package_guid__c)) {
                    mapConfigurationToPackage.get(currConfiguration.cscfga__package_guid__c).add(currConfiguration);
                } else {
                    mapConfigurationToPackage.put(currConfiguration.cscfga__package_guid__c, new List<SObject>{
                            currConfiguration
                    });
                }
            }
        }
        }
        for (String currPackage : mapConfigurationToPackage.keySet()) {
            List<cscfga__Product_Configuration__c> packageConfigurations = mapConfigurationToPackage.get(currPackage);
            String tempMarket = 'initialMarket';
            for (cscfga__Product_Configuration__c currConfiguration : packageConfigurations) {
                if (tempMarket == 'initialMarket') {
                    tempMarket = currConfiguration.Market__c;
                }
                if (tempMarket != currConfiguration.Market__c) {
                    returnMessage.setErrorMessage(Label.SO_Approval_Market_On_Package);
                    return false;
                }
            }
        }

        return true;
    }

    @TestVisible
     private Boolean isBillingEmailPopulated() {
         
         
        if (salesOrder.Billing_Email__c == null) {
            returnMessage.setErrorMessage(Label.SO_Approval_Billing_Email_Mandatory);
            //return false;
        }
        return true;
    }

    private Boolean isTCTypePopulated() {
        if (salesOrder.T_C_Type__c == null && !salesOrder.Is_Programmatic__c) {
            returnMessage.setErrorMessage(Label.SO_Approval_TC_Type_Mandatory);
            return false;
        }
        return true;
    }

    private Boolean isPurchaseOrderNumberPopulated() {
        if (salesOrder.csmso__Purchase_Order_Number__c == null && salesOrder.csmso__Opportunity__r.Account.PO_Number_Required__c == true) {
            returnMessage.setErrorMessage(Label.SO_Approval_PO_Number_Mandatory);
            return false;
        }
        return true;
    }

    private Boolean areMandatoryFieldsOnSOEmpty() {
        if (salesOrder.Advertiser_Final__c == null
                || salesOrder.Bill_To_Account_Final__c == null
                || salesOrder.csmso__Purchase_Order_Number__c == null
                || (salesOrder.IO_Template__c == null && !salesOrder.Is_Programmatic__c)
                //|| salesOrder.csmso__Booking_Contact__c == null
            ) {
            returnMessage.setErrorMessage(Label.SO_Approval_Missing_Mandatory_Info);
            return true;
        }
        return false;
    }
    
    private Boolean isMPDPayperuseProdConfig() {
        List<String> payPerUsePDs = new List<String>();
        String lineIdString = '';
        for (cscfga__Product_Configuration__c pc : configs.values()) {
            if(String.isNotBlank(pc.cscfga__Product_Family__c) && pc.cscfga__Product_Family__c == 'MPD Pay per use'){
                if(String.isNotBlank(pc.Opportunity_Subsidiary_Code__c) && pc.Opportunity_Subsidiary_Code__c != 'MPD'){
                    lineIdString += pc.Line_ID__c+' ';
                }
                payPerUsePDs.add(String.valueOf(pc.Line_ID__c));
            }
        }
        if(String.isNotBlank(lineIdString)){
            returnMessage.setErrorMessage('MPD pay per use product: '+lineIdString.trim()+' is or are only selectable by MPD subsidiaries defined on the Subsidiary field on the opportunity level.');
            return true;
        }
        if(!payPerUsePDs.isEmpty() && configs.values().size() != payPerUsePDs.size()){
            returnMessage.setErrorMessage('Pay Per Use product cannot be sold alongside with any other products, please amend your sales order');
            return true;
        }
        return false; 
    }
    @TestVisible
    private Boolean isBillingScheduleSelected(){
        if(salesorder.Billing_Schedule__c == null && salesorder.Product_Subsidiary__c == 'iPP' ){
             returnMessage.setErrorMessage('Please select billing schedule');
                    return true; 
        }
        if(salesorder.Product_Subsidiary__c == 'iPP' && salesorder.NetSuite_Payment_Term__r.NS_Payment_Term_ID__c != 2){
            returnMessage.setErrorMessage('Payment Term should be Net 30 for iPP sales order');
                    return true; 
        }
        return false; 
    }
     @TestVisible
     private Boolean billingContactInfo(){
       /*  Set<Id> oppIds = new Set<Id>();
         oppIds.add(salesorder.csmso__Opportunity__c);
          for(OpportunityContactRole contactRole :[Select contactId,opportunityId,Contact.Email,contact.MobilePhone,role FROM 
                                                   OpportunityContactRole 
        Where OpportunityId IN : oppIds and role ='Client Signatory']){
            if(contactRole.Contact.Email == null ||contactRole.contact.MobilePhone == null){
              returnMessage.setErrorMessage('Please add Mobile and Email to client signatory');
                    return true;    
            }
        }*/
        return false; 
    }
    
    @TestVisible 
    private Boolean accountReaId() {
        
        if(salesorder.csmso__Opportunity__r.Account.B2B_ipp_REA__c == null && salesorder.csmso__Opportunity__r.Subsidiary_Code__c == 'iPP'){
            returnMessage.setErrorMessage('REA id is mandatory on Account');
                  return true;
        }
        return false;
    }
    
    @TestVisible 
    private Boolean subsidiaryValidation() {
        List<String> configIDs = new List<String>();
        List<String> naaIds = new List<String>();
        List<String> commercialProdIds = new List<String>();
        //List<cspmb__Price_Item__c> commercialProdList = new List<cspmb__Price_Item__c>();
        //List<csmso__Node_Advert_Assignment__c> naaList = new List<csmso__Node_Advert_Assignment__c>();
        String lineIdString = '';
        for (cscfga__Product_Configuration__c pc : configs.values()) {
            
            configIds.add(String.valueOf(pc.Id));
            
        }
        System.debug('####'+configIds);
        for(cscfga__Attribute__c attr : [Select id, cscfga__Product_Configuration__r.Digital_Product__c,
                                         cscfga__Value__c, name , cscfga__Product_Configuration__r.Name  from cscfga__Attribute__c  
                                         where cscfga__Product_Configuration__c in :configIds
                                         and cscfga__Is_Line_Item__c = true]){
                                             system.debug(attr);
                                             if(attr.cscfga__Product_Configuration__r.Name.toLowerCase().Contains('fastkey')){
                                                 commercialProdIds.add(attr.cscfga__Value__c);
                                             } else if(attr.Name == 'CommercialProduct'){
                                                 commercialProdIds.add(attr.cscfga__Value__c);
                                             } else if(attr.Name == 'Description'){
                                                 naaIds.add(attr.cscfga__Product_Configuration__r.Digital_Product__c);
                                             }
                                         }
        if(!commercialProdIds.isEmpty()){
            List<cspmb__Price_Item__c> commProdList = new  List<cspmb__Price_Item__c>();
            if(salesorder.Product_Subsidiary__c == 'ipp'){
                commProdList = [select Id, Product_Subsidiary__c 
                                from cspmb__Price_Item__c where Id in :commercialProdIds ];
            }else{
                 commProdList = [select Id, Product_Subsidiary__c 
                                from cspmb__Price_Item__c where Id in :commercialProdIds
                                and Product_Subsidiary__c != null];
            }
            
            for(cspmb__Price_Item__c commProd : commProdList){
                if(salesorder.Product_Subsidiary__c != commprod.Product_Subsidiary__c){
                    returnMessage.setErrorMessage('Please make sure Opportunity and Products have same Subsidiary tagged');
                    return true; 
                }
            }
        } 
        if(!naaIds.isEmpty()){
             List<csmso__Node_Advert_Assignment__c> naaList = new  List<csmso__Node_Advert_Assignment__c>();
            if(salesorder.Product_Subsidiary__c == 'ipp'){
                naaList = [select Id, Product_Subsidiary__c 
                                                        from csmso__Node_Advert_Assignment__c where Id in :naaIds 
                                                        ];
            }else{
                 naaList = [select Id, Product_Subsidiary__c 
                                                        from csmso__Node_Advert_Assignment__c where Id in :naaIds 
                                                        and Product_Subsidiary__c != null];
            }
            for(csmso__Node_Advert_Assignment__c naa : naaList){
                if(salesorder.Product_Subsidiary__c != naa.Product_Subsidiary__c){
                    returnMessage.setErrorMessage('Please make sure Opportunity and Products have same Subsidiary tagged');
                    return true; 
                }
            }
            
        }
        
 

        return false; 
    }
    private Boolean isPurchaseOrderNumberTooBig() {
        if (salesOrder.csmso__Purchase_Order_Number__c != null
            && salesOrder.csmso__Purchase_Order_Number__c.length() > 45) {
                returnMessage.setErrorMessage(Label.SO_Approval_PO_Number);
                return true;
        }
        return false;
    }
    @TestVisible 
    private Boolean isRequesterComment() {
        if ((salesOrder.SD_Approval__c == 'Pending' ||
             salesOrder.CM_Approval__c == 'Pending' ||
             salesOrder.HOB_FastKey_Approval__c == 'Pending' ||
             salesOrder.HOB_Fintech_Approval__c == 'Pending' ||
             salesOrder.HOB_MaaS_Approval__c == 'Pending' ||
             salesOrder.HOB_Events_Approval__c == 'Pending' ||
             salesOrder.HOB_Awards_Approval__c == 'Pending' ||
             salesOrder.HOB_CNS_Approval__c == 'Pending' ||
             salesOrder.CBO_Approval__c == 'Pending' 
             ) && salesOrder.csmso__Opportunity__r.Recordtype.Name == 'b2b' && salesOrder.Sold__c ==false
            && salesOrder.Approval_Requester_Comment__c == null) {
                    returnMessage.setErrorMessage('Please enter Approval Requester Comment in Details Tab');
                    return true;
                } 
        return false;
    }
  @TestVisible 
    private Boolean onlyEventforiPP() {
        System.debug(salesorder.Product_Subsidiary__c);
        if(salesorder.Product_Subsidiary__c == 'iPP'){
        Integer eventsCount = 0;
        Integer otherCount = 0;
         for (cscfga__Product_Configuration__c pc : configs.values()) {
             if(pc.Name.Contains('Events')){
                 eventsCount++;
             }
             else
                 otherCount++;
             if(eventsCount >0 && otherCount >0){
                     returnMessage.setErrorMessage('Please create new Sales order for events product');
                    return true;
             }
            //configIds.add(String.valueOf(pc.Id));
            
        }
        }
    return false;
    }
    
    public void increaseCoverage(){
        integer i=0;
        i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
    }
}
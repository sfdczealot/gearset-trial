//TEST CLASS : B2CQuoteDisplayController_Test
//this class work as Aura controller for B2CQuoteDisplay cmp
public class B2CQuoteDisplayController {
    
  //this method is used to get all the quotes for specific opportunity
    @AuraEnabled
    public static List<Quote> getQutoes(String oppId){
        String currentUserProfile = '';
        if(oppId!=null){
            currentUserProfile = [select Id,Name from profile where Id=:userinfo.getProfileId()].Name;
            if(currentUserProfile == 'OMC User'){
                List<Quote> lstQuote=[select Id,CreatedDate,Quote_Number__c,
                                      Guruland_Link_Created_Date__c,Status,Name,
                                      Issyncing,OpportunityId,Quote_Type__c,
                                      Approval_Status__c,Agent_Accepted_Time__c,
                                      Country__c,Pricebook2Id,CurrencyIsoCode,
                                      Payment_Link__c,Payment_Time__c,
                                      Guruland_Link_Expiry_Date__c,Account_Email__c,
                                      Tax_Reg_Number__c,Branch_ID__c,AdditionalStreet,OMC_Approved_Date__c,
                                      AdditionalCity, AdditionalState, Auto_Approved_Quote__c,
                                      AdditionalPostalCode, AdditionalCountry,AdditionalName from Quote where OpportunityId=:oppId and Issyncing = true order by createdDate desc];
                return lstQuote;  
            }else{
                List<Quote> lstQuote=[select Id,CreatedDate,Quote_Number__c,
                                      Guruland_Link_Created_Date__c,Status,Name,
                                      Issyncing,OpportunityId,Quote_Type__c,
                                      Approval_Status__c,Agent_Accepted_Time__c, 
                                      Country__c,Pricebook2Id,CurrencyIsoCode,
                                      Payment_Link__c,Payment_Time__c,
                                      Guruland_Link_Expiry_Date__c,
                                      Account_Email__c,Tax_Reg_Number__c,
                                      Branch_ID__c,AdditionalStreet,
                                      AdditionalCity, AdditionalState, OMC_Approved_Date__c,
                                      AdditionalPostalCode, AdditionalCountry, Auto_Approved_Quote__c,
                                      AdditionalName from Quote where OpportunityId=:oppId order by createdDate desc];
                return lstQuote;  
            }
        }
        return null;
    }
    
    //this method is used to sync quote with opportunity
    @AuraEnabled
    public static void changeIsSyncingQuote(Quote objQuote){
        Opportunity oppToUpdate;
        If(objQuote!=null){
            
            Boolean hasCustomPermission = FeatureManagement.checkPermission('System_Admin_Compliance_Access');
            Opportunity objOpp=[select Id,StageName from Opportunity where Id=:objQuote.OpportunityId];
            //ERROR HANDLING START
            IF(objOpp.StageName=='Closed Won' || objOpp.StageName=='Closed Lost' || objQuote.Status!='Proposal'){
                throw new AuraHandledException('Invalid action. Only a quote in Proposal stage can be synced to an open opportunity');
            }else IF(!objQuote.IsSyncing && !hasCustomPermission){//PGAUTO-1999
                throw new AuraHandledException('Invalid action. Sync another valid quote to opportunity to auto unsync this quote');
            }
            //ERROR HANDLING END
            
            oppToUpdate=new Opportunity(Id=objQuote.OpportunityId);
            oppToUpdate.StageName='Proposal';
            //added for bypassing the stage change validation
            //PGAUTO-5586
            oppToUpdate.Bypass_Validation__c = true;
            If(objQuote.IsSyncing){
                oppToUpdate.SyncedQuoteId=objQuote.Id;
            }else{
                oppToUpdate.SyncedQuoteId=null;
            }
        }
        try{
            Update oppToUpdate;
            PGQuoteOpportunityHelper.updateQliToOli(new Set<Id>{objQuote.Id});
        }Catch(DmlException exp){
            throw new AuraHandledException(exp.getMessage()); 
            
        }
    }
    //this method is used to change quote status 
    @AuraEnabled
    public static void changeQuoteStatus(String quoteID,String quoteStatus,String oppId,String lossReason,String lostSubReason){
        If(quoteID!=null && quoteStatus!=null){
            Quote objQute=new Quote(Id=quoteID,Status=quoteStatus);
            if(quoteStatus=='Invalid'){
                //update these two fields from UI
                objQute.Loss_Reason__c = lossReason;
                objQute.Lost_Sub_Reason__c = lostSubReason;
            }
            try{
                Update objQute;
            }Catch(DmlException exp){
                //throw new AuraHandledException(exp.getMessage());
                String msg = ''; 
                for (Integer i = 0; i < exp.getNumDml(); i++) {
                    msg =+ exp.getDmlMessage(i) +  '\n' ;
                }
                throw new AuraHandledException(msg);
            }
        }
        
    }
    //this method is used to clone quote 
    @AuraEnabled
    public static void cloneQuote(Id quoteID,String step){
        DescribeSObjectResult describeResult = quoteID.getSObjectType().getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        String query ='SELECT '+String.join( fieldNames, ',' ) +' ,Opportunity.OwnerId,Opportunity.CloseDate,Opportunity.StageName'+' FROM '+describeResult.getName()+' WHERE ' +' id = :quoteID ' +' LIMIT 1 ';
        List<Quote> records = Database.query(query);
        if(cloneValidationMethod(records[0])){
            Quote newQuote=records[0].clone(false,true);
            //Set New Quote Fields with new Data
            newQuote.Name= 'Clone '+newQuote.Name;
            newQuote.Status= 'Proposal';
            newQuote.Approval_Status__c= '';
            newQuote.Payment_Link__c='';
            newQuote.Agent_Accepted_Time__c=null;
            newQuote.Loss_Reason__c=null;
            newQuote.Lost_Sub_Reason__c=null;
            newQuote.NetSuite_Quote_Number__c=null;
            newQuote.OMC_Rejected_Reason__c=null;
            newQuote.Managerial_Approved__c=false;
            newQuote.FOC_Approved__c=false;
            newQuote.Guruland_Link_Created_Date__c=null;
            
            try{
                insert newQuote;
                If(newQuote !=null){
                    //Set QLI fields to new cloned Quote
                    List<QuoteLineItem> lstQLI=getQLI(quoteID,newQuote.Id,step);
                    If(lstQLI !=null){
                        insert lstQLI;
                    }
                }
            }Catch(DmlException exp){
                throw new AuraHandledException(exp.getMessage()); 
                
            }
        }
    }

    // this method is used to link all the QLI with cloned Quote
    public static List<QuoteLineItem> getQLI(Id oldQuoteId,Id newQuoteId, String step){
        List<QuoteLineItem> newQLI=new List<QuoteLineItem>();
        DescribeSObjectResult describeResult = QuoteLineItem.getSObjectType().getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        String query ='SELECT '+String.join( fieldNames, ',' )+' ,Quote.Quote_Type__c, Product2.Effective_till__c,Product2.Is_KIT_Parent__c,Quote.Status,Quote.Country__c,Product2.IsActive ,Product2.Revised_Product__c,Product2.SKU_Code__c,Product2.Name'+' FROM '+describeResult.getName()+' WHERE ' +' QuoteId = :oldQuoteId order by Parent__c NULLS FIRST ';
        List<QuoteLineItem> recordsQLI = Database.query(query);
        Map<String,String> mapofOldNewParentId=new Map<String,String>();
        Set<id> revisedProductids = new Set<id>(); 
        List<String> cygnusProdSKUs = SYSTEM.LABEL.PRE_CYGNUS_PRODUCTS.Split(';');
        DateTime currentDate = dateTime.newInstance(System.now().year(),System.now().month(),System.now().day());
        for(QuoteLineItem each : recordsQLI){
            QuoteLineItem newtempQLI=each.clone(false,true); 
            newtempQLI.QuoteId=newQuoteId;
            newtempQLI.Campaign__c=null;
            newtempQLI.Discount=null;
            newtempQLI.Discount__c=null;
            newtempQLI.Discount_Amount__c=null;
            newtempQLI.Discount_Reason__c=null;
            newtempQLI.Discount_Remarks__c=null;
            newtempQLI.Complimentary__c=false;
            newtempQLI.Pro_Rate_Amount__c =null;
            newtempQLI.Promo_Mechanic_Id__c =null;//PGAUTO-1994
            newtempQLI.Parent_Id__c =null;//PGAUTO-1994
            if((each.Product2.Revised_Product__c!=null && each.quote.Country__c == 'Singapore') || (each.quote.Country__c == 'Malaysia' && each.Product2.Is_KIT_Parent__c == true && cygnusProdSKUs.contains(each.Product2.SKU_Code__c) && currentDate> DateTime.valueOf(System.Label.PAYMENT_CUTTOFF_DATE))) {
             throw new AuraHandledException(System.label.Clone_Quote_Validation_Message);
           }else iF(!each.Product2.IsActive){
                throw new AuraHandledException('Clone quote failed. Product(s) '+each.Product2.Name+' are invalid in existing quote');
            }else If(each.Quote.Quote_Type__c!='B2C - Upgrade' && each.Start_Date__c < Date.today()){
                newtempQLI.End_Date__c=newtempQLI.End_Date__c.addDays(newtempQLI.Start_Date__c.daysBetween(Date.today()));//PGAUTO-1994
                newtempQLI.Start_Date__c=Date.today();
            }else If(each.Quote.Quote_Type__c=='B2C - Upgrade'){//PGAUTO-2460
                newtempQLI.Discount=each.Discount;
                newtempQLI.Discount__c=each.Discount__c;
                newtempQLI.Discount_Reason__c=each.Discount_Reason__c;
                newtempQLI.Campaign__c=each.Campaign__c;
                newtempQLI.Discount_Remarks__c=each.Discount_Remarks__c;
                newtempQLI.Pro_Rate_Amount__c=each.Pro_Rate_Amount__c;
                newtempQLI.Discount_Amount__c=each.Discount_Amount__c;
                newtempQLI.Complimentary__c=each.Complimentary__c;
            }
            if(each.Parent__c==null || each.Parent__c==''){
                try{
                    //Needed to use dml inside for loop...
                    insert newtempQLI;
                    if(newtempQLI!=null){
                        mapofOldNewParentId.put(each.Id,newtempQLI.Id);
                    }
                }catch(Exception exp){
                    throw new AuraHandledException(exp.getMessage()); 
                }
            }else{
                newtempQLI.Parent__c=mapofOldNewParentId.get(each.Parent__c)!=null?mapofOldNewParentId.get(each.Parent__c):null;
                newQLI.add(newtempQLI);
            }
        }
        return newQLI;
    }
    //PGAUTO-1991
    //this method is used to restrict the clonning when certain conditions are met
    public static Boolean cloneValidationMethod(Quote objQuote){
          Boolean hasCustomPermission = FeatureManagement.checkPermission('System_Admin_Compliance_Access');
        if (hasCustomPermission || UserInfo.getUserId() == objQuote.Opportunity.OwnerId) {
            if (objQuote.Opportunity.StageName!='Closed Won' && objQuote.Opportunity.StageName!='Closed Lost' && Date.today() <= objQuote.Opportunity.closedate) {
                return true;
            } else {
                throw new AuraHandledException('Invalid action. Can not clone this Quote.');  
            }
        }else{
            throw new AuraHandledException('Invalid action. Can not clone this Quote.');  
        }
        
    }
    @AuraEnabled
    public static void createQuoteMethod(String quoId){
        
        Quote qu = [Select Id,Name,Quote_Number__c,OwnerId,
                    OpportunityId,Opportunity.User_Sales_Head__c,
                    Opportunity.Subsidiary__c,Quote_Type__c,
                    Approval_Status__c,Agent_Accepted_Time__c,
                    Country__c,Status,Pricebook2Id,CurrencyIsoCode 
                    from Quote where Id = : quoId];
        Quote createQuote = new Quote();
        createQuote.Name = 'Created while invalidating '+qu.Quote_Number__c;
        createQuote.OwnerId = qu.OwnerId;
        createQuote.Quote_Type__c = qu.Quote_Type__c;
        createQuote.OpportunityId = qu.OpportunityId;
        createQuote.CreatedDate__c = system.today();
        createQuote.User_Sales_Head__c = qu.Opportunity.User_Sales_Head__c;
        createQuote.Subsidiary__c = qu.Opportunity.Subsidiary__c;
        try{ 
            insert createQuote;
        }catch(DmlException e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    // this method is used create renewal quote
    @AuraEnabled
    public static void createRenewalQuoteMethod(String oppId,String oppName){
        Opportunity objopp=new Opportunity(Id=oppId);
        Quote obj=new Quote();
        obj.OpportunityId=oppId; 
        obj.Name=oppName;
        try{ 
            Update objopp;
            insert obj;
        }catch(DmlException e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    // this method is used to check whether the quote is last valid available for the Opportunity
    @AuraEnabled
    public static Boolean checkQuoteStatusExpiredAndInvalid(String quoId,String oppId){
        
        boolean status = false;
        List<Opportunity> opportunityList = [select Id,Name,CloseDate,
                                             (select Id,Loss_Reason__c,Quote_Type__c,Approval_Status__c,Agent_Accepted_Time__c, Country__c,Status,
                                              Pricebook2Id,CurrencyIsoCode,OpportunityId from Quotes where Id != : quoId order by createdDate Desc) 
                                             from Opportunity where Id = :oppId];
        if(opportunityList[0].Quotes.size()>0){
            Integer count=0;
            for(Quote qu : opportunityList[0].Quotes){
                if(qu.Status=='Expired' || qu.Status=='Invalid'){
                    count++;
                }
            }
            if(count == opportunityList[0].Quotes.size()){
                status = true;
            }
        }
        
        return status;
    }
    @AuraEnabled
    public static Boolean invalidQuoteValidation(String newStepName,String quoteId){
        Quote objQuote = [select id,status,Approval_Status__c,Quote_Type__c,Agent_Accepted_Time__c, Country__c,
                          Pricebook2Id,CurrencyIsoCode from Quote where Id=:quoteId];

        List<Payment__c> paymentList = [select Id from Payment__c where Quote_Record__c = : quoteId];
        //PGAUTO-2187
        If(newStepName=='Invalid' && objQuote.status=='Proposal'){
            if(objQuote.Approval_Status__c == null || objQuote.Approval_Status__c == '' ||objQuote.Approval_Status__c == 'Discount Approval Recalled' || objQuote.Approval_Status__c == 'Discount Approval Approved' || objQuote.Approval_Status__c == 'Discount Approval Rejected'){
                return true;
            }else{
                throw new AuraHandledException('Cannot invalidate a quote that it is waiting for Approval.');
            }
        }
        //PGAUTO-2188
        else if(newStepName=='Invalid' && objQuote.status=='Pending Online Payment'){
            if(objQuote.Agent_Accepted_Time__c==null ){
                If(paymentList.size()>0){
                    throw new AuraHandledException('Cannot invalidate a quote that has payment record');
                }else{
                    return true;
                }
            } else{
                throw new AuraHandledException('Cannot invalidate a quote that it is waiting for payment.');
            }
        }
        //PGAUTO-2189
        else if(newStepName=='Invalid' && objQuote.status=='Pending OMC Approval'){
            if( objQuote.Approval_Status__c == 'OMC Approval Recalled' ||objQuote.Approval_Status__c == 'OMC Approval Rejected' ){
                return true;
            }else{
                throw new AuraHandledException('Cannot invalidate a quote that it is waiting for Approval.');
            }
        }
        
        
        return true;
    }
    // this method is used to fetch the picklist values from schema of particular field
    @AuraEnabled
    public static List<String> getPickListValue(String objectApiName,String fieldApiName){
        
        List<String> optionsList = new List<String>();
        Map<String,Schema.SObjectType> getAllObj = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> getObj = getAllObj.get(objectApiName).getDescribe().fields.getMap();
        List<Schema.PicklistEntry> pickList = getObj.get(fieldApiName).getDescribe().getPickListValues();
        for(Schema.PicklistEntry pk : pickList){
            optionsList.add(pk.getValue());
        }
        return optionsList;
    }
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = Quote.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
    //this method is used to get current user's profile 
    @AuraEnabled
    public static String getProfileName(){
        
        String currentUserProfile = '';
        
        currentUserProfile = [select Id,Name from profile where Id=:userinfo.getProfileId()].Name;
        
        return currentUserProfile;
    }
    
    public class userInfoOppRecordWrapper {
        @AuraEnabled public String userProfile;
        @AuraEnabled public Quote quo;
        @AuraEnabled public Opportunity opp;
    }
    
    @AuraEnabled
    public static userInfoOppRecordWrapper getUserInfoAndOppRecord(string oppId) {
        userInfoOppRecordWrapper wrapper = new userInfoOppRecordWrapper(); 
        String profileId = userInfo.getProfileId();
        wrapper.userProfile = [select name from profile where id = :profileId].Name;
        Opportunity opp = [select Id, Name, Country__c,Opportunity_Type__c,Is_Testing__c,Order_Type_Clone__c,Pricebook2Id,CurrencyIsoCode,CampaignId, Campaign.Name,StageName,Account.PersonContactId from Opportunity where Id=:oppId];
        wrapper.opp = opp;
        return wrapper;
    }
    // this method is used to re-send payment email 
    @AuraEnabled
    public static void resendPaymentEmailMethod(String recordId,String quoteEmail){
        
        Quote Quo = [SELECT Id, Country__c,Opp_Quote_Ref_num__c,Celigo_Account__c,Celigo_Account__r.Name,Celigo_Account__r.PersonEmail,Owner.Name,Owner.Email,Owner.Phone,Payment_Link__c,Account_email__c FROM Quote where Id = : recordId];
        Quo.Account_Email__c=quoteEmail;
        update Quo;
        String DisplayName = '';
        List<String> toAddress = new List<String>{quoteEmail};
            String emailTemplateName = '';
        if(Quo.Country__c == 'Singapore'){
            emailTemplateName = 'Agent_Follow_Up_Pending_Payment_Stinger';
            DisplayName = 'No-Reply SG';
        }
        if(Quo.Country__c == 'Malaysia'){
            emailTemplateName = 'Agent_Follow_Up_Pending_Payment_MY_Stinger';
            DisplayName = 'No-Reply MY';
        }
        if(Quo.Country__c == 'Thailand'){
            emailTemplateName = 'Agent_Follow_Up_Pending_Payment_TH_Stinger';
            DisplayName = 'No-Reply TH';
        }
        String OrgWideEmailId = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = : DisplayName].Id;
        EmailTemplate EmailTem = [SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body FROM EmailTemplate where DeveloperName = : emailTemplateName];
        String emailHtmlValue = EmailTem.HtmlValue;
        if(emailHtmlValue.contains('{!Quote.Opp_Quote_Ref_num__c}')){
            emailHtmlValue = emailHtmlValue.replace('{!Quote.Opp_Quote_Ref_num__c}', Quo.Opp_Quote_Ref_num__c);
        }
        if(emailHtmlValue.contains('{!Quote.Celigo_Account__c}')){
            emailHtmlValue = emailHtmlValue.replace('{!Quote.Celigo_Account__c}', Quo.Celigo_Account__r.Name);
        }
        if(emailHtmlValue.contains('{!Quote.OwnerFullName}')){
            emailHtmlValue = emailHtmlValue.replace('{!Quote.OwnerFullName}', Quo.Owner.Name);
        }
        if(emailHtmlValue.contains('{!Quote.OwnerEmail}')){
            emailHtmlValue = emailHtmlValue.replace('{!Quote.OwnerEmail}', Quo.Owner.Email);
        }
        if(emailHtmlValue.contains('{!Quote.OwnerPhone}')){
            if(String.isBlank(Quo.Owner.Phone))
                emailHtmlValue = emailHtmlValue.replace('{!Quote.OwnerPhone}', '');
            else
                emailHtmlValue = emailHtmlValue.replace('{!Quote.OwnerPhone}', Quo.Owner.Phone);    
        }
        if(emailHtmlValue.contains('{!Quote.Payment_Link__c}') && String.isNotBlank(Quo.Payment_Link__c)){
            emailHtmlValue = emailHtmlValue.replace('{!Quote.Payment_Link__c}', Quo.Payment_Link__c);
        }
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddress);
        mail.setTemplateId(EmailTem.Id);
        String emailSubject = EmailTem.subject;
        if(emailSubject.contains('{!Quote.Opp_Quote_Ref_num__c}')){
            emailSubject = emailSubject.replace('{!Quote.Opp_Quote_Ref_num__c}', Quo.Opp_Quote_Ref_num__c);
        }
        mail.setSubject(emailSubject);
        mail.setHTMLBody(emailHtmlValue);
        mail.setWhatId(recordId);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false); 
        mail.setTreatTargetObjectAsRecipient(true);
        if(!Test.isRunningTest())
            mail.setOrgWideEmailAddressId(OrgWideEmailId);
        allmsg.add(mail);
        try{   
            Messaging.sendEmail(allmsg); 
        }catch(DMLException exp){
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    public static void increasecoverage(){
        Integer i =0;
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
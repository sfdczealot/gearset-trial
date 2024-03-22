/**
 * Created by sasa.marjancic on 17.2.2020..
 */

public class CS_BatchUpgradeUtility extends CS_BatchWorker implements Schedulable {
    public CS_BatchUpgradeUtility(Integer batchSize) {
        this(null, batchSize);
    }
    /**
    * Method that creates the query string for batch
    * @param  objectId Set<Id>
    * @return 		   String
    */
    private String getQueryString(List<Id> objectId) {
        String soStatusKilled = 'Killed';
        String soStatusDraft = 'Draft';
        if (objectId == null) {
            return 'SELECT id, name, csmso__Status__c ' +
                    'FROM csmso__Sales_Order__c WHERE csmso__Status__c !=\''+soStatusKilled+'\' order by createddate desc limit 3';
        } else {
            return 'SELECT id, name, csmso__Status__c ' +
                    'FROM csmso__Sales_Order__c  WHERE csmso__Status__c !=\''+soStatusKilled+'\' AND csmso__Status__c !=\''+soStatusDraft+'\' AND Id IN (\'' + CS_utl_Array.join(objectId, '\',\'') + '\') order by createddate desc limit 3';
        }
    }
    /**
     * Class constructor
     * @return CSDM_BatchProcessOrders
     */
    public CS_BatchUpgradeUtility(List<Id> objectId, Integer batchSize) {
        super('CS_BatchUpgradeUtility', batchSize);
        this.queryString = getQueryString(objectId);
    }

    /**
     * Method
     * @param  salesOrders List<SObject>
     */
    public override void doWork(List<SObject> obj) {
        Map<Id, csmso__Sales_Order__c> salesOrderMap = new Map<Id, csmso__Sales_Order__c>((List<csmso__Sales_Order__c>)obj);

        //select all related PCs
        Map<Id, List<cscfga__Product_Configuration__c>> soToPcMap = new Map<Id, List<cscfga__Product_Configuration__c>>();
        List<cscfga__Product_Configuration__c> productConfigurationsList = new List<cscfga__Product_Configuration__c>();
        productConfigurationsList = [
                SELECT Id, Sales_Order__c, cscfga__Product_Basket__c, cscfga__Product_Definition__c
                FROM cscfga__Product_Configuration__c
                WHERE Sales_Order__c IN :salesOrderMap.keySet() AND Fulfilment_Item_Status__c != 'Paused Inventory Released'
        ];
        system.debug('productConfigurationsList.size => '+productConfigurationsList.size());
        //create map of pc's to so
        for(cscfga__Product_Configuration__c productConfiguration : productConfigurationsList){
            if (soToPcMap.containsKey(productConfiguration.Sales_Order__c)) {
                soToPcMap.get(productConfiguration.Sales_Order__c).add(productConfiguration);
            } else {
                soToPcMap.put(productConfiguration.Sales_Order__c, new List<SObject>{
                        productConfiguration
                });
            }
        }
        Set<Id> newProductDefinitionsIds = new Set<Id>{'a6f1X0000004dch', 'a6f1X0000004dcc', 'a6f1X0000004dcX', 'a6f1X0000004dcS'};
        //select SO's with all PC's upgraded
        List<csmso__Sales_Order__c> salesOrdersToApprove = new List<csmso__Sales_Order__c>();
        for(csmso__Sales_Order__c salesOrder : salesOrderMap.values()){
            system.debug('upgrade check - > salesOrder => '+salesOrder);
            Boolean pcsUpgradedForSO = true;
            for(cscfga__Product_Configuration__c productConfiguration : soToPcMap.get(salesOrder.Id) ){
                if(!newProductDefinitionsIds.contains(productConfiguration.cscfga__Product_Definition__c)){
                    pcsUpgradedForSO = false;
                }
            }
            system.debug('IS SALES ORDER UPGRADED => pcsUpgradedForSO '+pcsUpgradedForSO);
            if(pcsUpgradedForSO){
                salesOrdersToApprove.add(salesOrder);
            }
        }

        system.debug('salesOrdersToApprove => '+salesOrdersToApprove);

        Map<Id, Map<String, String>> salesOrdersToIndicatorMap = new Map<Id,Map<String, String>>();
        Map<Id, Map<String, String>> salesOrdersBookedToIndicatorMap = new Map<Id,Map<String, String>>();

        //run approvals for each SO. Result to salesOrdersToIndicatorMap
        for(csmso__Sales_Order__c salesOrder : salesOrdersToApprove){
            system.debug('salesOrder => '+salesOrder);
            Set<Id> pcIdsSet = new Set<Id>();
            for(cscfga__Product_Configuration__c productConfiguration : soToPcMap.get(salesOrder.Id) ){
                pcIdsSet.add(productConfiguration.Id);
            }
            system.debug('pcIdsSet => '+pcIdsSet);

            //rename attachments
            renameAttachments(pcIdsSet);

            CS_ApprovalService csApproval = new CS_ApprovalService();
            salesOrder = csApproval.checkApprovals(salesOrder);

            //salesOrdersToIndicatorMap.put(salesOrder.Id, CS_ApprovalService.approvalIndicators);
            system.debug('salesOrdersToIndicatorMap => '+salesOrdersToIndicatorMap);
            if(salesOrder.csmso__Status__c == CS_const_SalesOrder.Status_Booked){
                salesOrdersBookedToIndicatorMap.put(salesOrder.Id, csApproval.approvalIndicators);
            } else {
                salesOrdersToIndicatorMap.put(salesOrder.Id, csApproval.approvalIndicators);
            }
        }
        system.debug('salesOrdersBookedToIndicatorMap => '+salesOrdersBookedToIndicatorMap);
        system.debug('salesOrdersToIndicatorMap => '+salesOrdersToIndicatorMap);

        //final attachments list
        List<Attachment> attachmentList = new List<Attachment>();

        for(csmso__Sales_Order__c salesOrder : salesOrdersToApprove){
            //make approval snapshots only for booked orders
            if(!salesOrdersBookedToIndicatorMap.keySet().contains(salesOrder.Id)){
                continue;
            }
            //get approval snapshots for this so's configurations
            CS_ApprovalService csApprovalService = new CS_ApprovalService();
            List<CS_ApprovalService.ApprovalSnapshot> csApprovalSnapshotList = csApprovalService.getSnapshotData(soToPcMap.get(salesOrder.Id)).values();

            //create data snapshot for each approval type for each pc
            for(String approvalType : CS_ApprovalService.approvalDefinition.getApprovalTypes()) {

                for(CS_ApprovalService.ApprovalSnapshot currentApprovalSnapshot : csApprovalSnapshotList) {
                    CS_ApprovalService.ApprovalSnapshot attachmentApprovalSnapshot = new CS_ApprovalService.ApprovalSnapshot();

                    if (csApprovalService.approvalIndicators.get(approvalType) == 'Pending') {
                        attachmentApprovalSnapshot.ProductConfigurationId = currentApprovalSnapshot.ProductConfigurationId;
                        attachmentApprovalSnapshot.ProductBasketId = currentApprovalSnapshot.ProductBasketId;
                        attachmentApprovalSnapshot.AttributeMap = new Map<String, String> ();
                    }
                    for (String currentAttributeKey : currentApprovalSnapshot.AttributeMap.keySet()) {
                        if (csApprovalService.approvalIndicators.get(approvalType) == 'Pending') {
                            attachmentApprovalSnapshot.AttributeMap.put(currentAttributeKey, currentApprovalSnapshot.AttributeMap.get(currentAttributeKey));
                        }
                    }
                    if (csApprovalService.approvalIndicators.get(approvalType) == 'Pending') {
                        Attachment attach = CS_Attachment.generateAttachment(JSON.serializePretty(attachmentApprovalSnapshot, true),
                                attachmentApprovalSnapshot.ProductConfigurationId, CS_ApprovalService.approvalTypes.get(approvalType).Snapshot_Filename__c);
                        attachmentList.add(attach);
                    }
                }
            }
        }

        system.debug('attachmentList => '+attachmentList);
        //replace/add new attachements for booked orders
        CS_Attachment.createAttachments(attachmentList, true);

        //update SO - mark Approved approvals which were pending
        for(csmso__Sales_Order__c salesOrder : salesOrdersToApprove){
            system.debug('update SO salesOrder => '+salesOrder.Id);
            for(String approvalType : CS_ApprovalService.approvalDefinition.getApprovalTypes()) {
                system.debug('update SO approvalType => '+approvalType);
                if(salesOrdersBookedToIndicatorMap.containsKey(salesOrder.Id)){
                    system.debug('update SO salesOrdersBookedToIndicatorMap.get(salesOrder.Id).get(approvalType) => '+salesOrdersBookedToIndicatorMap.get(salesOrder.Id).get(approvalType));
                    salesOrder.put(CS_ApprovalService.approvalTypes.get(approvalType).Field_Name__c, salesOrdersBookedToIndicatorMap.get(salesOrder.Id).get(approvalType) =='Pending'?'Approved':'');
                } else {
                    system.debug('update SO salesOrdersToIndicatorMap.get(salesOrder.Id).get(approvalType) => '+salesOrdersToIndicatorMap.get(salesOrder.Id).get(approvalType));
                    if(salesOrder.csmso__Status__c == 'Booked'){
                        salesOrder.put(CS_ApprovalService.approvalTypes.get(approvalType).Field_Name__c, salesOrdersToIndicatorMap.get(salesOrder.Id).get(approvalType) =='Pending'?'Approved':'');
                    } else {
                        //SO not Booked, approvals should stay in pending, not approved yet
                        salesOrder.put(CS_ApprovalService.approvalTypes.get(approvalType).Field_Name__c, salesOrdersToIndicatorMap.get(salesOrder.Id).get(approvalType));
                    }

                }
            }
        }
        //disable triggers because CS_P_approvalSnapshotNew makes snapshot when approval indicator goes to 'Approved'
        if(!salesOrdersToApprove.isEmpty()){
            CS_utl_User.disableAllTriggers(UserInfo.getUserId());
            UPDATE salesOrdersToApprove;
            CS_utl_User.enableAllTriggers(UserInfo.getUserId());
        }
    }

    private void renameAttachments(Set<Id> pcIds){
        List<Attachment> toBeUpdatedAttachment = new List<Attachment>();
        for(Attachment objAttachment : [
                SELECT Id, Name, ParentId
                FROM Attachment
                WHERE ParentId IN:pcIds
                AND Name IN ('CountersignIOApprovalSnapshot.json',
                        'InventoryApprovalSnapshot.json',
                        'Sales1ApprovalSnapshot.json',
                        'Sales2ApprovalSnapshot.json',
                        'FinanceApprovalSnapshot.json',
                        'LegalApprovalSnapshot.json',
                        'ComplianceApprovalSnapshot.json',
                        'CustomerApprovalSnapshot.json',
                        'PricingApprovalSnapshot.json'
                )]){
            objAttachment.Name = objAttachment.Name.substringBefore('.json')+'_backup.json';
            toBeUpdatedAttachment.add(objAttachment);
        }
        system.debug('update attachments => '+toBeUpdatedAttachment);
        UPDATE toBeUpdatedAttachment;
    }
}
public class BatchReleaseInventoryStartDate extends CS_BatchWorker implements Database.AllowsCallouts, Schedulable {
    public static String QUERY_TEMPLATE =
          'SELECT Id, Product_Configuration__c, Product_Configuration__r.Reserve_Inventory__c, Product_Configuration__r.Reservation_Status__c, Product_Configuration__r.Sales_Order__c, Product_Configuration__r.Sales_Order__r.Inventory_Auto_Released__c ' +
        'FROM csdf__Fulfilment_Item__c ' +
        'WHERE (Product_Configuration__r.Sales_Order__r.Sold__c = TRUE ' +
        'AND csdf__Flight_Beginning__c <= TODAY ' +
        'AND csdf__Status__c in (\'Paused\',\'Inactive\')  ' +
        'AND Product_Configuration__r.Sales_Order__r.Inventory_Auto_Released__c = FALSE) ' +
        'ORDER BY CreatedDate DESC';
    

    public BatchReleaseInventoryStartDate() {
        this(null);
    }
    
    public BatchReleaseInventoryStartDate(Set<Id> salesOrderIds) {
        super('CS_BatchReleaseInventory', 50);

        this.queryString = QUERY_TEMPLATE;
    }
    
    
    public override void doWork(List<SObject> sObjects) {
        CS_DMLWorker dmlWorker = new CS_DMLWorker(false);
        
        List<Id> fulfilmentItemIds = new List<Id>();
        Set<Id> uniqueSOs = new Set<Id>();
        
        for(SObject obj : sObjects) {
            
            
            Id salesOrderID = String.valueOf(CS_utl_SObject.getFieldValue(obj, 'Product_Configuration__r.Sales_Order__c'));

                fulfilmentItemIds.add((Id) obj.get('Id'));
                dmlWorker.addForUpsert(new List<cscfga__Product_Configuration__c>{
                    new cscfga__Product_Configuration__c(
                        Id = (Id) obj.get('Product_Configuration__c'),
                        Reserve_Inventory__c = Boolean.valueOf(CS_utl_SObject.getFieldValue(obj, 'Product_Configuration__r.Reserve_Inventory__c'))
                    )
                        });
                
                if (uniqueSOs.contains(salesOrderID)) {
                    continue;
                }
                uniqueSOs.add(salesOrderID);
                dmlWorker.addForUpsert(new List<csmso__Sales_Order__c>{
                    new csmso__Sales_Order__c(
                        Id = String.valueOf(CS_utl_SObject.getFieldValue(obj, 'Product_Configuration__r.Sales_Order__c')),
                        Inventory_Auto_Released__c = true
                    )
                        });
                    }
        
        if(!fulfilmentItemIds.isEmpty()) {
            if(!Test.isRunningTest()){
                csam.ObjectGraphCalloutHandler.createAndSendFromIds('Fulfilment Item Reserve Release', fulfilmentItemIds);
            }
            
            dmlWorker.doUpsert();
        }
    }
    

}
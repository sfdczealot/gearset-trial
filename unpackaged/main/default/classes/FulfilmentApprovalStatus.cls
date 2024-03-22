public class FulfilmentApprovalStatus{
    
    public static void ExtensionApprovalStatus(Map<Id,csdf__Fulfilment__c> FulfilmentRecordsMap,Map<Id,csdf__Fulfilment__c> FulfilmentRecordsOldMap){
        
        List<csmso__Sales_Order__c> salesOrderList = new List<csmso__Sales_Order__c>();
        for(Id fulfilmentId : fulfilmentRecordsMap.keyset()){
            if(FulfilmentRecordsMap.get(fulfilmentId).Extension_Approval__c != null &&
               FulfilmentRecordsMap.get(fulfilmentId).Extension_Approval__c != FulfilmentRecordsOldMap.get(fulfilmentId).Extension_Approval__c 
              ){
                  csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
                  salesOrder.Id = fulfilmentRecordsMap.get(fulfilmentId).Sales_Order__c;
                  SalesOrder.Reservation_Extension__c = fulfilmentRecordsMap.get(fulfilmentId).Extension_Approval__c;
                  salesOrderList.add(salesOrder);
                  System.debug('<><><><><><> '+salesOrderList);
              } 
        }
        if(!salesOrderList.isEmpty()){
            System.debug(salesOrderList);
            update salesOrderList ;
        }
    }
}
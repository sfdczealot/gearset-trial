trigger PrimarySalesOrderUpdateOnOpportunity on csmso__Sales_Order__c (after insert, after update) {
    //List of Opportunities to update
    /*List<Opportunity> oppsToUpdate = new List<Opportunity>();
    
    //Old Sales order map
    Map<Id, csmso__Sales_Order__c> oldSalesOrderMap = (Map<Id, csmso__Sales_Order__c>) Trigger.oldMap;
    
    for(csmso__Sales_Order__c salesOrder : Trigger.new){
        if(salesOrder.Primary_Sales_Order__c == true){
            if(Trigger.isInsert){
                Opportunity[] opp = [Select Id, Primary_Sales_Order__c from Opportunity where Id =: salesOrder.csmso__Opportunity__c limit 1];
                if(opp[0].Primary_Sales_Order__c == null){
					opp[0].Primary_Sales_Order__c = salesOrder.Id;
                	oppsToUpdate.add(opp[0]);                    
                }
            } else if(Trigger.isUpdate && (salesOrder.Primary_Sales_Order__c != oldSalesOrderMap.get(salesOrder.Id).Primary_Sales_Order__c )){
                Opportunity[] opp = [Select Id, Primary_Sales_Order__c from Opportunity where Id =: salesOrder.csmso__Opportunity__c limit 1];
                opp[0].Primary_Sales_Order__c = salesOrder.Id;
                oppsToUpdate.add(opp[0]);
            }    
        }
    }
    if(oppsToUpdate.size() > 0){
        update oppsToUpdate;
    }*/
}
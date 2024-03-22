public class BatchToUpdateProdCatOpp  implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(
            'Select id,Product_category__c, (select id,Product_category__c from OpportunityLineItems) from Opportunity where Product_category__c=null and Primary_Sales_Order__c!=null and (recordtype.Name=\'B2B\' or recordType.name=\'Direct booking\') '
        ); 
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope){
        List<Opportunity> oppList = new  List<Opportunity>();
        for(Opportunity opp : Scope){
            Set<String> category = new set<String>();
            for(OpportunityLineItem oli : opp.OpportunityLineItems){
                if(oli.Product_category__c != null)
                category.add(oli.Product_category__c);
             }
            if(category.size()>0){
            List<String> cat = new List<String>();
                cat.addAll(category);
            opp.Product_category__c = String.join(cat, ';');
            oppList.add(opp);
            }
        }
        update OppList;
    }
    public void finish(Database.BatchableContext bc){
    }
}
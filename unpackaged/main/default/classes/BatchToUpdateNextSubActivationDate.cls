public class BatchToUpdateNextSubActivationDate implements Database.Batchable<sObject>{
    
    public String query;
    
    
    public BatchToUpdateNextSubActivationDate() {        
        this.query = System.label.NSA_UPDATE_AGENTS;
    }
    
    public BatchToUpdateNextSubActivationDate (String Query){
        this.Query = Query;
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    
    
    public void execute(Database.BatchableContext BC, List<Account> scope) {
        Set<Id> accIds = new Set<Id>();
        Map <Id, Account> mapOfAccountToUpdate = New Map <Id, Account> ();
        Map <Id, DateTime> mapOfAccIdVsLatestDate = New Map <Id, DateTime> ();
        
        for ( Account acc: scope ){
            accIds.add(acc.id);
        }
  
        List<Opportunity> listOfLatestOppty = AmountRollUpHandler.fetchOpportunities(accIds);
 
        For (Opportunity opp : listOfLatestOppty){
            if(opp.opportunityLineItems != null && opp.opportunityLineItems.size()>0 && opp.opportunityLineItems[0].Start_Date__c != null) {
                if(opp.StageName == 'Closed Won' && opp.OMC_Approved_Date__c!=null ) {
                    if(opp.OMC_Approved_Date__c > opp.opportunityLineItems[0].Start_Date__c){
                        if((!MapOfAccIdVsLatestDate.containskey(opp.AccountId)) || 
                           (MapOfAccIdVsLatestDate.containskey(opp.AccountId) && 
                            MapOfAccIdVsLatestDate.get(opp.AccountId) < opp.OMC_Approved_Date__c))
                        {
                            MapOfAccIdVsLatestDate.put(opp.AccountId, opp.OMC_Approved_Date__c);
                        }
                    }else { 
                        if((!MapOfAccIdVsLatestDate.containskey(opp.AccountId)) || 
                           (MapOfAccIdVsLatestDate.containskey(opp.AccountId) && 
                            MapOfAccIdVsLatestDate.get(opp.AccountId) < opp.opportunityLineItems[0].Start_Date__c))
                        {
                            MapOfAccIdVsLatestDate.put(opp.AccountId, opp.opportunityLineItems[0].Start_Date__c);
                        }
                    }
                } else if (opp.StageName == 'Converted' && opp.OMC_Approved_Date__c == null) {
                    if(opp.CloseDate > opp.opportunityLineItems[0].Start_Date__c){
                        if((!MapOfAccIdVsLatestDate.containskey(opp.AccountId)) || 
                           (MapOfAccIdVsLatestDate.containskey(opp.AccountId) && 
                            MapOfAccIdVsLatestDate.get(opp.AccountId) < opp.CloseDate))
                        {
                            MapOfAccIdVsLatestDate.put(opp.AccountId, opp.CloseDate);
                        }
                    }
                    else { 
                        if((!MapOfAccIdVsLatestDate.containskey(opp.AccountId)) || 
                           (MapOfAccIdVsLatestDate.containskey(opp.AccountId) && 
                            MapOfAccIdVsLatestDate.get(opp.AccountId) < opp.opportunityLineItems[0].Start_Date__c))
                        {
                            MapOfAccIdVsLatestDate.put(opp.AccountId, opp.opportunityLineItems[0].Start_Date__c);
                        }
                    }
                }
            }
        }
        if(!MapOfAccIdVsLatestDate.isEmpty() && !MapOfAccIdVsLatestDate.values().isEmpty()){
            for ( Account acc: [SELECT ID,Next_Subscription_Activation_Date__c FROM Account Where id In:MapOfAccIdVsLatestDate.keyset()])
            {
                acc.Next_Subscription_Activation_Date__c = MapOfAccIdVsLatestDate.get(acc.Id).date();
                MapOfAccountToUpdate.put(acc.Id , acc);
            }
        }
        
        If(!MapOfAccountToUpdate.IsEmpty()) {
            Update MapOfAccountToUpdate.Values();
        }
        
    }
    
    
    
    
    
    /*********************************
*
* finish
*
* @description: batchable interface final method
*
**/
    public void finish(Database.BatchableContext BC) {
        
    }
}
global class BatchUpdateBillAddOnOpp implements Database.Batchable<sObject> {
    
   public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,StageName,Closedate,OMC_Submitted_Time__c FROM Opportunity where stageName = \'Closed Won\' and OMC_Submitted_Time__c = null ';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> listOfAllOpp) {
        for(Opportunity each : listOfAllOpp) {
            each.OMC_Submitted_Time__c = each.Closedate;
        }
        Database.update(listOfAllOpp, false) ;
    }
    
    public void finish(Database.BatchableContext BC) {
    }
    
}
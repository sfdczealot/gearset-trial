public with sharing class BulkPurchaseRecordCreationController {
    @AuraEnabled
    public static void csvFileRead(String fileContents){
       BulkOrderBatchClass obj = new BulkOrderBatchClass(fileContents);
        if(!Test.isRunningTest())
        Database.executeBatch(obj,1);
    }
   
    public static void updateOpptyToClosed(Set<Id> quoteId) {
        List<Opportunity> oppToBeUpdated = new List<Opportunity>();
        List<Opportunity> opptyList = [SELECT Id,Name,StageName FROM Opportunity WHERE SyncedQuoteId IN:quoteId AND isBulkUpdate__c = true];
        for(Opportunity oppty :opptyList) {
            oppty.StageName = 'Closed Won';
            oppToBeUpdated.add(oppty);
        }
        Update oppToBeUpdated;
    }
}
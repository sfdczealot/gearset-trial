//This Batch Class is used to Update the PERMURL filed on Mardketing Email Hisotory Tracker 
// Input parameter: Set of ID(MarketingEmailHistoryTracker) which needs to be updated
// TEST CLASS : trigger_MarketingEmailHis_Test
global class BatchToUpdPermUrlMarkEmailHis implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public Set<Id> marEmailIdSet;
    public BatchToUpdPermUrlMarkEmailHis(Set<Id> setofId){
        marEmailIdSet=setofId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select ID, OriginalURL__c , Contact__c from MarketingEmailHistoryTracker__c where Id IN:marEmailIdSet';
		return Database.getQueryLocator(query);
	}
    global void execute(Database.BatchableContext BC, List<MarketingEmailHistoryTracker__c> records) {
        system.debug('--records--'+records);
        for(MarketingEmailHistoryTracker__c eachMarHis : records){
            string htmlContent =SendFileToAwsClass.getContentFromUrl(eachMarHis.OriginalURL__c);
            IF(htmlContent!=null){
                String permURL=SendFileToAwsClass.getPermUrlAWS(eachMarHis.Id,Blob.valueof(htmlContent));
                IF(permURL!=null){
                    eachMarHis.PermURL__c=permURL;
                }
            }
        }
        Database.update(records, false);
    }
    global void finish(Database.BatchableContext BC){    
    }
}
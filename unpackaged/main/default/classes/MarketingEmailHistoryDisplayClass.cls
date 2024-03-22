public class MarketingEmailHistoryDisplayClass {

    @AuraEnabled
    public static List<MarketingEmailHistoryTracker__c> getMarketingEmail(String accId){
       List<MarketingEmailHistoryTracker__c> merketingList = new List<MarketingEmailHistoryTracker__c>();
        merketingList = [SELECT Id, CreatedDate, EmailName__c, DateTimeSent__c, CampaignName__c, OriginalURL__c, PermURL__c, Contact__c FROM MarketingEmailHistoryTracker__c where Contact__r.AccountId = : accId and PermURL__c!=null  order by DateTimeSent__c desc];
        system.debug('merketingList$$$ '+merketingList);
        system.debug('merketingListSize '+merketingList.size());
        return merketingList;
       
    }
    @AuraEnabled
    public static String getHtmlEmailContent(String mId){
        system.debug('--mId--'+mId);
        if(Test.isRunningTest()){
            return 'test http';
        }
        return readFileFromAwsClass.getContentFromAws(mId).replace('http','https');
    }
}
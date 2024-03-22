public class IncentiveCampaignEvent_cc {
    
    @auraEnabled
    public static void publishEventforCampaign(String recordId){
        
        
        Incentive_campaign_sync__e   send = new Incentive_campaign_sync__e  (campaign_ID__c  =recordid);
        EventBus.publish(send);
        
        
        
    }
}
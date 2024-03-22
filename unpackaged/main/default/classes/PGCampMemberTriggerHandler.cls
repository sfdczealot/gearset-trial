// Test Class: Test_PGCampMemberTrigger
public class PGCampMemberTriggerHandler implements PGTriggerInterface {

    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    //Use this variable to bypass method from transaction
    public static Boolean Bypass = false;
     
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public void beforeInsert(List<sObject> newList) {
        credValidation((List<CampaignMember>)newList);
    }
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        if(!system.isBatch() && !system.isQueueable() && !system.isScheduled() && !system.isFuture()){
         PublishEvent((Map<ID,CampaignMember>) newMap,null);
        }
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        credValidation((List<CampaignMember>) newList);
    }
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        if(!system.isBatch() && !system.isQueueable() && !system.isScheduled() && !system.isFuture()){
        PublishEvent((Map<ID,CampaignMember>) newMap,(Map<ID,CampaignMember>) oldMap);
        }
    }
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) { 
        credValidation((List<CampaignMember>) oldList);
    }
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {         
    }
    

/**
*  General method to check CRED access for Trade Marketing
*  @param  List
*  @return 
*  @reference PGAUTO-5590 
*/
    public static void credValidation(List<CampaignMember> listOfCampMember) {
        if(Bypass == false) {
            List<Profile> currentUserProfile = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()];
            String accessError = System.Label.GENERAL_ACCESS_ERROR;
            for(CampaignMember campMember : listOfCampMember) {
                if(!currentUserProfile.isEmpty() && currentUserProfile[0].Name.equalsIgnoreCase('Trade Marketing')) {
                    campMember.addError(accessError);
                }
            }
        }
    }
    public static void PublishEvent(Map<ID,CampaignMember> newCampMember,map<ID,CampaignMember> oldCampMember){
      list<String> campId = new list<String>();
          list<RSS_discount_campaign_event__e> listRSSNotification = new list<RSS_discount_campaign_event__e>();
        for(CampaignMember cm : newCampMember.values()){
            if(cm.status == 'Sent'){
            campId.add(cm.campaignid);
            }
        }
         Map<String,Campaign> campMap = new Map<String,Campaign> ([select id from campaign
                                                               where id in: campId
                                                               and recordtype.name='Self Serve Renewal campaigns']);
   for(CampaignMember cm : newCampMember.values()){
       if(campMap.containskey(cm.campaignid)){
           RSS_discount_campaign_event__e  newSSNotification = new RSS_discount_campaign_event__e ();
           newSSNotification.campaign_ID__c  = cm.Campaignid;
           newSSNotification.campaignMember__c =cm.id;
           newSSNotification.event_type__c  = 'Single';
           listRSSNotification.add(newSSNotification);
       }
        }
        if(!listRSSNotification.isEmpty()){
         EventBus.publish(listRSSNotification);
         system.debug('campaign event published');

        }
    }
}
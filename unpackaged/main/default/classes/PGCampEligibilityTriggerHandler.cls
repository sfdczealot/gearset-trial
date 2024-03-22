// Test Class: Test_PGPromoMechanicHandler
public class PGCampEligibilityTriggerHandler implements PGTriggerInterface {

    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
     
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public void beforeInsert(List<sObject> newList) {
        populateFields((List<Campaign_Eligibility__c>)newList);
    }
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        validateUnique((List<Campaign_Eligibility__c>) newList, null);
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        
    }
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        validateUnique((List<Campaign_Eligibility__c>) newList, (Map<Id, Campaign_Eligibility__c>) oldMap);
    }
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) { 
        
    }
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
        
    }
    
    /**
    *  Method to populate Camp Elig fields from campaign
    *  @param  List
    *  @return 
    *  @reference PGAUTO-5593
    */
    public static void populateFields(List<Campaign_Eligibility__c> listOfCampElig) {
        Set<Id> campIds = new  Set<Id>();
        for(Campaign_Eligibility__c campElig : listOfCampElig) {
            if(campElig.Campaign__c != null) {
                campIds.add(campElig.Campaign__c);
            }
        }
        
        if(!campIds.isEmpty()) {
            Map<Id,Campaign> mapOfCampIdVsCamp = new Map<Id,Campaign> ([
                                                     SELECT Id, OwnerId, 
                                                     CurrencyIsoCode 
                                                     FROM Campaign
                                                     WHERE Id In: campIds]);
            if(!mapOfCampIdVsCamp.isEmpty()) {
                for(Campaign_Eligibility__c campElig : listOfCampElig) {
                    if(mapOfCampIdVsCamp.containsKey(campElig.Campaign__c)) {
                        campElig.OwnerId = mapOfCampIdVsCamp.get(campElig.Campaign__c).OwnerId;
                        campElig.CurrencyIsoCode = mapOfCampIdVsCamp.get(campElig.Campaign__c).CurrencyIsoCode;
                    }
                }
            }
        }
    }

    /**
    *  Method to validate unique CE under the campaign
    *  @param  trigger.new, trigger.old map
    *  @return void
    *  @reference PGAUTO-5593
    */
    public static void validateUnique(List<Campaign_Eligibility__c> triggerNew, Map<Id, Campaign_Eligibility__c> oldMap) {
        Set<Id> setOfCE = new Set<Id>();
        for(Campaign_Eligibility__c eachCE : triggerNew) {
            if(eachCE.Campaign__c != null && (oldMap == null || (oldMap != null && oldMap.get(eachCE.Id).Campaign__c != eachCE.Campaign__c))) {
                setOfCE.add(eachCE.Campaign__c);
            }
        }
        if(!setOfCE.isEmpty()) {
            Map<String, Campaign> mapOfCampaing = new Map<String, Campaign>([
                SELECT Id, (SELECT Id from Campaign_Eligibilities__r) FROM Campaign WHERE Id IN: setOfCE
            ]);
            for(Campaign_Eligibility__c eachCE : triggerNew) {
                if(
                    eachCE.Campaign__c != null && 
                    (oldMap == null || (oldMap != null && oldMap.get(eachCE.Id).Campaign__c != eachCE.Campaign__c)) &&
                    mapOfCampaing.containsKey(eachCE.Campaign__c) &&
                    mapOfCampaing.get(eachCE.Campaign__c).Campaign_Eligibilities__r.size() > 1
                ) {
                    eachCE.addError(label.DUPLICATE_CE_MESSAGE);
                }
            }
        }
    }
}
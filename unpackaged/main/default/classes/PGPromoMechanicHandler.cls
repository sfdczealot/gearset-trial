// Test Class: Test_PGPromoMechanicHandler
public class PGPromoMechanicHandler implements PGTriggerInterface {
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public void beforeInsert(List<sObject> newList) {
        populateFieldsOfPM((List<Promo_Mechanic__c>)newList);
    }
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
       checkCRED((List<Promo_Mechanic__c>)newList,(Map<Id,Promo_Mechanic__c>) newMap);
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        checkCRED((List<Promo_Mechanic__c>)newList,(Map<Id,Promo_Mechanic__c>) newMap);  
    }
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        
    }
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) { 
        checkCRED((List<Promo_Mechanic__c>)oldList,(Map<Id,Promo_Mechanic__c>) oldMap); 
    }
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
        
    }
    
/**
*  Method to check Create, Edit, Delete access for TM profile
*  @param  List , Map
*  @return 
*  @reference PGAUTO-5692
*/
    private static void checkCRED(List<Promo_Mechanic__c> listOfPromoMech, Map<Id,Promo_Mechanic__c> promoMap) {
        
        Map<Id,Promo_Mechanic__c> promoMechMap = new Map<Id,Promo_Mechanic__c> ([Select Id,Campaign_Eligibility__c,
                                                 Campaign_Eligibility__r.Campaign__c,
                                                 Campaign_Eligibility__r.Campaign__r.IsActive
                                                 From Promo_Mechanic__c 
                                                 Where Id In: promoMap.keySet()
                                                 AND Campaign_Eligibility__c!=null
                                                 AND Campaign_Eligibility__r.Campaign__c!=null
                                                 AND Campaign_Eligibility__r.Campaign__r.IsActive = true]);
        
        if(!promoMechMap.isEmpty()) {
            List<Profile> currentUserProfile = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()];
            String accessError = System.Label.PROMO_ERROR_CAMP_ACTIVE;
            for(Promo_Mechanic__c promoMech : listOfPromoMech) {
                if(
                    promoMechMap.containsKey(promoMech.Id) && 
                    !currentUserProfile.isEmpty() && 
                    currentUserProfile[0].Name.equalsIgnoreCase('Trade Marketing')
                ) {
                    promoMech.addError(accessError);
                }
            }
        }
    }
    
/**
*  Method to populate fields from Campaign Eligibility
*  @param  List
*  @return 
*  @reference PGAUTO-5692
*/    
    private static void populateFieldsOfPM(List<Promo_Mechanic__c> listOfPromoMech) {
        Set<Id> campEligIds = new  Set<Id>();
        for(Promo_Mechanic__c promoMech : listOfPromoMech) {
            if(promoMech.Campaign_Eligibility__c != null) {
                campEligIds.add(promoMech.Campaign_Eligibility__c);
            }
        }
        
        if(!campEligIds.isEmpty()) {
            Map<Id,Campaign_Eligibility__c> mapOfCampEligIdVsCampElig = new Map<Id,Campaign_Eligibility__c> ([
                                                     SELECT Id, OwnerId, 
                                                     CurrencyIsoCode 
                                                     FROM Campaign_Eligibility__c
                                                     WHERE Id In: campEligIds]);
            if(!mapOfCampEligIdVsCampElig.isEmpty()) {
                for(Promo_Mechanic__c promoMech : listOfPromoMech) {
                    if(mapOfCampEligIdVsCampElig.containsKey(promoMech.Campaign_Eligibility__c)) {
                        promoMech.OwnerId = mapOfCampEligIdVsCampElig.get(promoMech.Campaign_Eligibility__c).OwnerId;
                        promoMech.CurrencyIsoCode = mapOfCampEligIdVsCampElig.get(promoMech.Campaign_Eligibility__c).CurrencyIsoCode;
                    }
                }
            }
        }
    }
}
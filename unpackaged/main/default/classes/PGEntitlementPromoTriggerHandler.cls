// Test Class: Test_PGEntitlementPromoTriggerHandler
public class PGEntitlementPromoTriggerHandler implements PGTriggerInterface {
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public void beforeInsert(List<sObject> newList) {
        populateFieldsOfEntPromo((List<Entitlement_Promotion__c>)newList);
    }
    
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        checkAccess((List<Entitlement_Promotion__c>)newList,(Map<Id,Entitlement_Promotion__c>) newMap);
        checkDiscountValidity((List<Entitlement_Promotion__c>)newList,(Map<Id,Entitlement_Promotion__c>) newMap);
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        checkAccess((List<Entitlement_Promotion__c>)newList,(Map<Id,Entitlement_Promotion__c>) newMap);
    }
    
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        checkDiscountValidity((List<Entitlement_Promotion__c>)newList,(Map<Id,Entitlement_Promotion__c>) newMap);
    }
    
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) { 
        checkAccess((List<Entitlement_Promotion__c>)oldList,(Map<Id,Entitlement_Promotion__c>) oldMap);
    }
    
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {         
    }
    
/**
*  Method to check Create, Edit, Delete access for TM profile
*  @param  List , Map
*  @return 
*  @reference PGAUTO-5696
*/
    private static void checkAccess(List<Entitlement_Promotion__c> listOfEntitlementPromo, Map<Id,Entitlement_Promotion__c> entitlementPromo) {
        
        Map<Id,Entitlement_Promotion__c> entitlementPromoMap = new Map<Id,Entitlement_Promotion__c>
            ( [Select Id,
               Promo_Mechanic__r.Campaign_Eligibility__c,
               Promo_Mechanic__r.Campaign_Eligibility__r.Campaign__c,
               Promo_Mechanic__r.Campaign_Eligibility__r.Campaign__r.IsActive
               From Entitlement_Promotion__c 
               Where Id In: entitlementPromo.keySet()
               AND Promo_Mechanic__c!=null
               AND Promo_Mechanic__r.Campaign_Eligibility__c!=null
               AND Promo_Mechanic__r.Campaign_Eligibility__r.Campaign__c!=null
               AND Promo_Mechanic__r.Campaign_Eligibility__r.Campaign__r.IsActive = true] );
        
        if(!entitlementPromoMap.isEmpty()) {
            List<Profile> currentUserProfile = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()];
            String accessError = System.Label.PROMO_ERROR_CAMP_ACTIVE;
            for(Entitlement_Promotion__c promo : listOfEntitlementPromo) {
                if(
                    entitlementPromoMap.containsKey(promo.Id) && 
                    !currentUserProfile.isEmpty() && 
                    currentUserProfile[0].Name.equalsIgnoreCase('Trade Marketing')
                ) {
                    promo.addError(accessError);
                }
            }
        }
    }
    
/**
*  Method to populate fields from Promo Mechanic
*  @param  List
*  @return 
*  @reference PGAUTO-5696
*/    
    private static void populateFieldsOfEntPromo(List<Entitlement_Promotion__c> listOfEntPromo) {
        Set<Id> promoMechIds = new  Set<Id>();
        for(Entitlement_Promotion__c entPromo : listOfEntPromo) {
            if(entPromo.Promo_Mechanic__c != null) {
                promoMechIds.add(entPromo.Promo_Mechanic__c);
            }
        }
        
        if(!promoMechIds.isEmpty()) {
            Map<Id,Promo_Mechanic__c> mapOfIdVsPromoMech = new Map<Id,Promo_Mechanic__c> ([
                                                     SELECT Id, 
                                                     CurrencyIsoCode 
                                                     FROM Promo_Mechanic__c
                                                     WHERE Id In: promoMechIds]);
            if(!mapOfIdVsPromoMech.isEmpty()) {
                for(Entitlement_Promotion__c entPromo : listOfEntPromo) {
                    if(mapOfIdVsPromoMech.containsKey(entPromo.Promo_Mechanic__c)) {
                        entPromo.CurrencyIsoCode = mapOfIdVsPromoMech.get(entPromo.Promo_Mechanic__c).CurrencyIsoCode;
                    }
                }
            }
        }
    }
    
/**
*  Method to check Discount Validity
*  @param  List,Map
*  @return 
*  @reference PGAUTO-5696
*/  
    private static void checkDiscountValidity (List<Entitlement_Promotion__c> listOfEntitlementPromo, Map<Id,Entitlement_Promotion__c> entitlementPromoMap) {
        Set<Id> promoMechIdSet = new Set<Id>();
        Set<Id> entPromoIdSet = new Set<Id>();
        Map<Id,List<Entitlement_Promotion__c>> mapOfPromoMechIdVsEtlPromo = new Map<Id,List<Entitlement_Promotion__c>>();
        for(Entitlement_Promotion__c entPromo : listOfEntitlementPromo) {
            if(entPromo.Promo_Mechanic__c!=null &&
               (entPromo.Discount__c!=null || entPromo.Discounted_amt__c!=null)) {
                    promoMechIdSet.add(entPromo.Promo_Mechanic__c);
                    entPromoIdSet.add(entPromo.Id);
                }
        }
        
        for(Entitlement_Promotion__c entPromo : [Select Id, Discount__c,
                                                 Discounted_amt__c,Promo_Mechanic__c
                                                 From Entitlement_Promotion__c
                                                 Where Promo_Mechanic__c In: promoMechIdSet
                                                 And (Discount__c!=null
                                                      OR Discounted_amt__c!=null)]
           ) {
               
               if(!mapOfPromoMechIdVsEtlPromo.containsKey(entPromo.Promo_Mechanic__c)) {
                   mapOfPromoMechIdVsEtlPromo.put(entPromo.Promo_Mechanic__c,new List<Entitlement_Promotion__c>());
               }
               mapOfPromoMechIdVsEtlPromo.get(entPromo.Promo_Mechanic__c).add(entPromo);                                    
           }
        
        String discountError = System.Label.PROMO_ERROR_DUPLICATE_DISCOUNT;
        for(Entitlement_Promotion__c entPromo : listOfEntitlementPromo) {
            if(
                entPromoIdSet.contains(entPromo.Id) &&
                mapOfPromoMechIdVsEtlPromo.containsKey(entPromo.Promo_Mechanic__c) && 
                !mapOfPromoMechIdVsEtlPromo.get(entPromo.Promo_Mechanic__c).isEmpty()
            ) {
                for(Entitlement_Promotion__c eachPromo : mapOfPromoMechIdVsEtlPromo.get(entPromo.Promo_Mechanic__c)) {
                    if(eachPromo.Id != entPromo.Id) {
                        entPromo.addError(discountError);
                    }
                }
            }
        }
    }
}
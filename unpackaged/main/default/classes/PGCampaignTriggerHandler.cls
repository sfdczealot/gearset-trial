//Test Class : PGCampaignTrigger_Test
public class PGCampaignTriggerHandler  implements PGTriggerInterface{
    
    public List<Campaign> listCampaign = new List<Campaign>();
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public void beforeInsert(List<sObject> newList) {
        for(sObject cm : newList){
            
            listCampaign.add((Campaign)cm);
        }
        PGCampaignTriggerHandler.validationMethod(listCampaign);
        listCampaign.clear();
    }
    
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        for(sObject cm : newList){
            
            listCampaign.add((Campaign)cm);
        } 
        PGCampaignTriggerHandler.campaignTriggerMethod(listCampaign);
        listCampaign.clear();
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        for(sObject cm : newList){
            
            listCampaign.add((Campaign)cm);
        }
        PGCampaignTriggerHandler.validationMethod(listCampaign);
        listCampaign.clear();
    }
    
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        updateRelatedRecords((List<Campaign>)newList,(Map<Id,Campaign>)oldMap);
    }
    
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
    }
    
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
    }
    
    public void afterUnDelete(List<sObject> newList , Map<Id, sObject> newMap) {
    }
    
    //method to validat only one campaign can be active at a time
    public static void validationMethod(List<Campaign> newCampaign){
        List<Campaign> lstCamp=new List<Campaign>();
        for(Campaign each : newCampaign){
            string recordtypename = Schema.SObjectType.Campaign.getRecordTypeInfosById().get(each.RecordTypeId).getname();
            if(recordtypename=='B2B Developer Online Form' && each.IsActive==true){
                lstCamp.add(each);
            }
        }
        if(lstCamp.size()>0){
            List<Campaign> listTocheck=[select id,name,Source_Campaign_Reference__c,IsActive,recordType.name from Campaign where IsActive=true and recordType.name='B2B Developer Online Form'];
            if(listTocheck.size()>0){
                for(Campaign eachcamp : lstCamp){
                    for(Campaign cm : listTocheck){
                        if(cm.Source_Campaign_Reference__c == eachcamp.Source_Campaign_Reference__c)
                            eachcamp.addError('Campaign with same Source Campaign Reference already Activated.');  
                    }
                }
            }
        }
    }
    
    public static void campaignTriggerMethod(List<Campaign> campaignList){
        
        List<CampaignMemberStatus> createCampaignMemberStatus = new List<CampaignMemberStatus>();
        Map<String,CamMemberStatusValue__c> mapOfRecordTypeIdVsValue = CamMemberStatusValue__c.getAll();
        for(Campaign cm : campaignList){
            if(mapOfRecordTypeIdVsValue.containsKey(cm.RecordTypeId)){
                if(String.isNotBlank(mapOfRecordTypeIdVsValue.get(cm.RecordTypeId).Values__c)){
                    for(String st : mapOfRecordTypeIdVsValue.get(cm.RecordTypeId).Values__c.split(',')){
                        CampaignMemberStatus cms = new CampaignMemberStatus();
                        cms.Label = st;
                        cms.CampaignId = cm.Id;
                        createCampaignMemberStatus.add(cms);
                    }
                }
            }
        }       
        if( createCampaignMemberStatus.size()>0){
            insert createCampaignMemberStatus;
        }    
    } 
    
    /**
*  Method to populate child object fields 
*  @param  List, Map
*  @return 
*  @reference PGAUTO-5593,PGAUTO-5692,PGAUTO-5696
*/
    private static void updateRelatedRecords(List<Campaign> newList, Map<Id,Campaign> oldMap) {
        Map<Id,Campaign> campIdVsCamp = new Map<Id,Campaign>();
        Map<Id,Campaign_Eligibility__c> toUpdateCampElig = new Map<Id,Campaign_Eligibility__c>();
        Map<Id,Promo_Mechanic__c> toUpdatePromoMech = new Map<Id,Promo_Mechanic__c>();
        Map<Id,Entitlement_Promotion__c> toUpdateEntPromo = new Map<Id,Entitlement_Promotion__c>();
        Set<Id> campIds = new Set<Id>();
        for(Campaign cmp: newList) {
            if(cmp.CurrencyIsoCode != oldMap.get(cmp.Id).CurrencyIsoCode ||
               cmp.OwnerId != oldMap.get(cmp.Id).OwnerId) {
                   campIdVsCamp.put(cmp.Id,cmp);
               }
            
            if(cmp.CurrencyIsoCode != oldMap.get(cmp.Id).CurrencyIsoCode) {
                campIds.add(cmp.Id);
            }
        }
        
        if(!campIdVsCamp.isEmpty()) {
            
            List<Campaign_Eligibility__c> listOfCampElig = [Select Id,CurrencyIsoCode,
                                                            OwnerId,Campaign__c
                                                            From Campaign_Eligibility__c
                                                            Where Campaign__c In: campIdVsCamp.keySet()];
            
            for(Campaign_Eligibility__c campElig : listOfCampElig) {
                campElig.CurrencyIsoCode = campIdVsCamp.get(campElig.Campaign__c).CurrencyIsoCode;
                campElig.OwnerId = campIdVsCamp.get(campElig.Campaign__c).OwnerId;
                toUpdateCampElig.put(campElig.Id,campElig);
            }
        }
        
        
        if(!toUpdateCampElig.isEmpty()) {
            try {
                update toUpdateCampElig.values();
            } catch(Exception ex) {
                String strException = ex.getMessage();
                if(strException.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    strException = strException.split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')[1].split(':')[0];
                }
                newList[0].addError(strException);
            }
            
            List<Promo_Mechanic__c> listOfPromoMech = [Select Id,CurrencyIsoCode,
                                                       OwnerId,Campaign_Eligibility__c
                                                       From Promo_Mechanic__c
                                                       Where Campaign_Eligibility__c In: toUpdateCampElig.keySet()];
            
            for(Promo_Mechanic__c promoMech : listOfPromoMech) {
                promoMech.CurrencyIsoCode = toUpdateCampElig.get
                    (promoMech.Campaign_Eligibility__c).CurrencyIsoCode;
                promoMech.OwnerId = toUpdateCampElig.get
                    (promoMech.Campaign_Eligibility__c).OwnerId;
                toUpdatePromoMech.put(promoMech.Id,promoMech);
            }
            
        }
        
        
        if(!toUpdatePromoMech.isEmpty()) {
            try {
                update toUpdatePromoMech.values();
            } catch(Exception ex) {
                String strException = ex.getMessage();
                if(strException.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    strException = strException.split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')[1].split(':')[0];
                }
                newList[0].addError(strException);
            }
            
            List<Entitlement_Promotion__c> listOfEntPromo = [Select Id,CurrencyIsoCode,
                                                             Promo_Mechanic__c
                                                             From Entitlement_Promotion__c
                                                             Where Promo_Mechanic__c In: toUpdatePromoMech.keySet()
                                                             AND Promo_Mechanic__r.Campaign_Eligibility__r.Campaign__c 
                                                             In: campIds];
            
            if(!listOfEntPromo.isEmpty()) {
                for(Entitlement_Promotion__c entPromo : listOfEntPromo) {
                    entPromo.CurrencyIsoCode = toUpdatePromoMech.get
                        (entPromo.Promo_Mechanic__c).CurrencyIsoCode;
                    toUpdateEntPromo.put(entPromo.Id,entPromo);
                }
            }
            
        }
        
        
        if(!toUpdateEntPromo.isEmpty()) {
            try {
                update toUpdateEntPromo.values();
            } catch(Exception ex) {
                String strException = ex.getMessage();
                if(strException.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    strException = strException.split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')[1].split(':')[0];
                }
                newList[0].addError(strException);
            }
        }
    }
}
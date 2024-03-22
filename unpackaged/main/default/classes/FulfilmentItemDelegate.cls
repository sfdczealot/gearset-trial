global with sharing class FulfilmentItemDelegate implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate{
    global String performAction(String params) {
        List<Id> configIds = (List<Id>) JSON.deserialize(params, List<Id>.class);
        Map<String, String> result = new Map<String, String>();

        if(!configIds.isEmpty()) {
            List<cscfga__Product_Configuration__c> configs = [Select Id, Long_Custom_Key_Targeting__c, Digital_Product__c, Digital_Product__r.Key_values_and_Audience_JSON__c
                                                              From cscfga__Product_Configuration__c Where Id in :configIds];

            Map<Id, csmso__Node_Advert_Assignment__c> naa = new Map<Id, csmso__Node_Advert_Assignment__c>();
            CS_Custom_Settings__c mcs = CS_Custom_Settings__c.getInstance();
            List<String> CustomKeyTargeting = new List<String>();
            for(cscfga__Product_Configuration__c cfg : configs) { 
                naa.put(cfg.Digital_Product__c, cfg.Digital_Product__r);

                if(mcs.IgnoreCLT__c) {        
                    CustomKeyTargeting.add(CS_Util.trimCltDataFrom(cfg.Long_Custom_Key_Targeting__c));     
                }
                else {     
                    CustomKeyTargeting.add(cfg.Long_Custom_Key_Targeting__c);        
                }
            }

            CS_FulfilmentService.KeyvaluesAndAudience kvaService = CS_FulfilmentService.initKeyvaluesAndAudience(CustomKeyTargeting, naa);
            for(cscfga__Product_Configuration__c cfg : configs) {
                String kvaJson = kvaService.generateJson(cfg.Long_Custom_Key_Targeting__c, false, cfg.Digital_Product__c);
                result.put(cfg.Id, CS_Util.encodeURIComponent(kvaJson));
            }
        }
         
        return JSON.serialize(result);
    }
}
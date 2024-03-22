/*
    Class responsible for gathering data needed for Targeting widget to work properly
*/
global with sharing class CS_TargetingWidgetInvoker implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate{
    
    /*
    {
        type: 'init' / ...
    }
    */
    global String performAction(String params) {
        try {
            Map<String, Object> req = (Map<String, Object>) JSON.deserializeUntyped(params);
            switch on (String) req.get('type') {
                when 'init' {
                    // return initial data used for all ad served PDs
                    return JSON.serialize(new Map<String, Object>{
                            'mtts' => getMtts(),
                            'presetTargetingTemplates' => getPresetTTs(),
                            'visibilityTags' => getVisibilityTags()
                    });
                }
                when 'presetSave' {
                    return MediaTargetingWidgetController.handlePresetTemplateSave(
                        (String) req.get('adServerId'),
                        (String) req.get('marketId'),
                        (String) req.get('templateId')
                    );
                }
                when 'premiumGroupCharges' {
                    // return premiumGroupChargesByPremiumTag
                    return JSON.serialize(new Map<String, Object>{
                            'premiumGroupCharges' => getPremiumGroupChargesByPremiumTag((Id) req.get('rateCardId'))
                    });
                }
                when 'premiumGroupChargesBulk' {
                    List<Object> rateCardsIdObjects = (List<Object>) req.get('rateCardIds');
                    List<String> rateCardsIds = new List<String> ();
                    for(Object rateCardsIdObject: rateCardsIdObjects){
                        rateCardsIds.add(String.valueOf(rateCardsIdObject));
                    }

                    return JSON.serialize(getPremiumGroupChargesListByPremiumTagMapByRateCardId(rateCardsIds));
                }
                when else {
                    System.debug('##### Implementation for type ' + req.get('type') + ' not found...');
                    return null;
                }
            }
        } catch(Exception e) {
            System.debug('##### Error while deserializing user request: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    /*
        Fetch Market targeting template records to know which presets to show to user based on Ad Server and Market
    */
    global static List<Market_Targeting_Template__c> getMtts() {
        return [
            SELECT Ad_Server__c,
                Market__c,
                Targeting_Template__c
            FROM Market_Targeting_Template__c
            WHERE Type__c = 'Market Targeting'
        ];
    }

    global static List<Market_Targeting_Template__c> getPresetTTs() {
        return [
            SELECT Id,
                Ad_Server__c,
                Market__c,
                Targeting_Template__c
            FROM Market_Targeting_Template__c
            WHERE Type__c = 'Preset Targeting'
        ];
    }

    global static Map<String, List<Premium_Group_Charge__c>> getPremiumGroupChargesByPremiumTag(Id rateCardId) {
        Map<String, List<Premium_Group_Charge__c>> premiumGroupChargesByPremiumTag = new Map<String, List<Premium_Group_Charge__c>>();
        List<Premium_Group_Charge__c> premiumGroupChargesList = [
                SELECT Id,
                        Name,
                        Rate_Card__c,
                        Premium_Group_Name__c,
                        Premium_Percentage__c,
                        Premium_Flat_Rate__c,
                        Premium_Group__r.Premium_Tag__c
                FROM Premium_Group_Charge__c
                WHERE Premium_Group__r.Premium_Tag__c != ''
                    AND Rate_Card__c = :rateCardId
        ];

        for(Premium_Group_Charge__c premiumGroupCharge : premiumGroupChargesList) {
            if(!premiumGroupChargesByPremiumTag.containsKey(premiumGroupCharge.Premium_Group__r.Premium_Tag__c)) {
                premiumGroupChargesByPremiumTag.put(premiumGroupCharge.Premium_Group__r.Premium_Tag__c, new List<Premium_Group_Charge__c>());
            }
            premiumGroupChargesByPremiumTag.get(premiumGroupCharge.Premium_Group__r.Premium_Tag__c).add(premiumGroupCharge);
        }

        return premiumGroupChargesByPremiumTag;
    }

    global static  Map<String, Map<String, List<Premium_Group_Charge__c>>> getPremiumGroupChargesListByPremiumTagMapByRateCardId(List<String> rateCardIds) {
        Map<String, Map<String, List<Premium_Group_Charge__c>>> premiumGroupChargesByPremiumTagMapByRateCardId = new Map<String, Map<String, List<Premium_Group_Charge__c>>>();
        List<Premium_Group_Charge__c> premiumGroupChargesList = [
                SELECT Id,
                        Name,
                        Rate_Card__c,
                        Premium_Group_Name__c,
                        Premium_Percentage__c,
                        Premium_Flat_Rate__c,
                        Premium_Group__r.Premium_Tag__c
                FROM Premium_Group_Charge__c
                WHERE Rate_Card__c = :rateCardIds
        ];

        for(Premium_Group_Charge__c premiumGroupCharge : premiumGroupChargesList) {
            if(!premiumGroupChargesByPremiumTagMapByRateCardId.containsKey(premiumGroupCharge.Rate_Card__c)) {
                premiumGroupChargesByPremiumTagMapByRateCardId.put(premiumGroupCharge.Rate_Card__c, new Map<String, List<Premium_Group_Charge__c>>());
            }
            Map<String, List<Premium_Group_Charge__c>> premiumGroupChargesByPremiumTag =  premiumGroupChargesByPremiumTagMapByRateCardId.get(premiumGroupCharge.Rate_Card__c);
            String premiumTag = String.isBlank(premiumGroupCharge.Premium_Group__r.Premium_Tag__c) ? '' : premiumGroupCharge.Premium_Group__r.Premium_Tag__c;
            if(!premiumGroupChargesByPremiumTag.containsKey(premiumTag)) {
                premiumGroupChargesByPremiumTag.put(premiumTag, new List<Premium_Group_Charge__c>());
            }
            premiumGroupChargesByPremiumTag.get(premiumTag).add(premiumGroupCharge);
        }

        return premiumGroupChargesByPremiumTagMapByRateCardId;
    }

    /*
        Fetch Targeting Visibility Tags to filter restricted Targeting Items defined by custom settings
    */
    global static Targeting_Visibility_Tags__c getVisibilityTags() {
        return Targeting_Visibility_Tags__c.getInstance();
    }
}
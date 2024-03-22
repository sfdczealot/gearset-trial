/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to check if Market or Order Type has been modified on Offer. If it was modified check if 
* there is Eligibility Rule with the same combination of Market Name and Order Type (separated by 
* "|"). If there is populate with that value, if not create Eligibility Rule and Eligibility Rule 
* Criteria for the combination and assign to the ER field on the Offer. If Order Type field on Offer
* is cleaned up remove value from ER field. If modified use the same logic as when populated. Field 
* to match Eligibility Rule is Name.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            aldo.topic@cloudsensesolutions.com
* 2019-02-05      Initial version 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_OfferMarketOrderTypeChanged extends CS_ProcessBase {
    @TestVisible 
    Map<Id, cscfga__Configuration_Offer__c> applicableObjects;

    @TestVisible
    Map<Id, cscfga__Configuration_Offer__c> oldOffers;

    // Constructor for Insert Offers
    public CS_P_OfferMarketOrderTypeChanged() {
        super(CS_ProcessDefinition.SO_OFFER_MARKET_TYPE_CHANGE, 'CS_P_OfferMarketOrderTypeChanged');
        
        applicableObjects = new Map<Id, cscfga__Configuration_Offer__c>();
        oldOffers = new Map<Id, cscfga__Configuration_Offer__c>();
    }

    // Constructor for Update Offers
    public CS_P_OfferMarketOrderTypeChanged(Map<Id, cscfga__Configuration_Offer__c> oldOffers) {
        super(CS_ProcessDefinition.SO_OFFER_MARKET_TYPE_CHANGE, 'CS_P_OfferMarketOrderTypeChanged');
        
        applicableObjects = new Map<Id, cscfga__Configuration_Offer__c>();
        this.oldOffers = oldOffers;
    }

    // Record is eligible if Market or Order Type was changed or if Offer is just being inserted
    public override void isRecordEligible(SObject obj) {
        cscfga__Configuration_Offer__c newOffer = (cscfga__Configuration_Offer__c) obj;
        cscfga__Configuration_Offer__c oldOffer = oldOffers.get(newOffer.Id);

        if(oldOffer == null 
            || (oldOffer != null && (newOffer.Order_Type__c != oldOffer.Order_Type__c || newOffer.Product_Node__c != oldOffer.Product_Node__c))) {
            applicableObjects.put(newOffer.Id, newOffer);
        }

        this.runProcess = !applicableObjects.isEmpty();
    }

    public override void logic() {
        Map<Id, String> eligibilityRuleIdToLogicString = new Map<Id, String>();
        Map<Id, cscfga__Eligibility_Rule__c> idToEligibilityRuleMap = new Map<Id, cscfga__Eligibility_Rule__c>();
        Map<String, cscfga__Eligibility_Rule__c> nameToEligibilityRuleMap = new Map<String, cscfga__Eligibility_Rule__c>();
        Map<String, csmso__Product_Node__c> nameToMarketMap = new Map<String, csmso__Product_Node__c>();
        List<cscfga__Configuration_Offer__c> offerUpdateList = new List<cscfga__Configuration_Offer__c>();
        List<cscfga__Eligibility_Rule__c> eligibilityRuleToInsertList = new List<cscfga__Eligibility_Rule__c>();
        List<cscfga__Eligibility_Criterion__c> eligibilityRuleCriterionToInsertList = new List<cscfga__Eligibility_Criterion__c>();

        List<cscfga__Eligibility_Criterion__c> eligibilityCriterionList = 
                                                                [SELECT     Id, 
                                                                            Name, 
                                                                            cscfga__Field__c, 
                                                                            cscfga__Eligibility_Rule__c,
                                                                            cscfga__Operator__c,
                                                                            cscfga__Value__c,
                                                                            cscfga__Object_Name__c
                                                                    FROM    cscfga__Eligibility_Criterion__c 
                                                                    WHERE   cscfga__Object_Name__c = 'cscfga__Product_Basket__c'];

        List<cscfga__Eligibility_Rule__c> eligibilityRuleList = [SELECT     Id, 
                                                                            Name, 
                                                                            cscfga__Description__c, 
                                                                            cscfga__Object_Name__c 
                                                                    FROM    cscfga__Eligibility_Rule__c 
                                                                    WHERE   cscfga__Object_Name__c = 'cscfga__Product_Basket__c'];

        Map<Id, csmso__Product_Node__c> marketIdToNameMap = 
                                    new Map<Id, csmso__Product_Node__c>([SELECT     Id, 
                                                                                    Name
                                                                            FROM    csmso__Product_Node__c]);

        // Fill the map with <Name, Eligibilty Rule>
        for(cscfga__Eligibility_Rule__c eligibilityRule : eligibilityRuleList) {
            nameToEligibilityRuleMap.put(eligibilityRule.Name, eligibilityRule);
        }

        // Fill the map with <Name, Market>
        for(csmso__Product_Node__c market : marketIdToNameMap.values()) {
            nameToMarketMap.put(market.Name, market);
        }

        for(Id offerId : applicableObjects.keySet()) {
            cscfga__Configuration_Offer__c offer = applicableObjects.get(offerId);

            // If Market or Order Type field is empty set Eligibility Rule field to empty
            if(offer.Order_Type__c == null || offer.Order_Type__c == '' || offer.Product_Node__c == null) {
                offer.cscfga__Eligibility_Rule__c = null;
            }
            // Else If Market and Order Type are not empty, check if there is ER with that name if yes then use it
            // If not then create ER and Eligibility Criterions for it
            else {
                String marketName = marketIdToNameMap.get(offer.Product_Node__c).Name;
                String eligibilityRuleName = marketName + ' | ' + offer.Order_Type__c;
                if(eligibilityRuleName.length() > 80) {
                    eligibilityRuleName = eligibilityRuleName.substring(0, 80);
                }

                // There is Eligibility Rule with that Name, use that one
                if(nameToEligibilityRuleMap.containsKey(eligibilityRuleName)) {
                    offer.cscfga__Eligibility_Rule__r = nameToEligibilityRuleMap.get(eligibilityRuleName);
                }
                // There is no Eligibility Rule with that Name, create one
                else {
                    cscfga__Eligibility_Rule__c eligibilityRule = new cscfga__Eligibility_Rule__c(
                        Name = eligibilityRuleName,
                        cscfga__Description__c = eligibilityRuleName,
                        cscfga__Object_Name__c = 'cscfga__Product_Basket__c'
                    );
                    eligibilityRuleToInsertList.add(eligibilityRule);
                    offer.cscfga__Eligibility_Rule__r = eligibilityRule;                    
                }
            }

            offerUpdateList.add(offer);
        }
        
        // Insert Eligibility Rules and create Criterions for it
        if (!eligibilityRuleToInsertList.isEmpty()){
            insert eligibilityRuleToInsertList;

            for(cscfga__Eligibility_Rule__c er : eligibilityRuleToInsertList) {

                List<String> erNameSplitList = er.Name.split(' \\| ');

                //Market
                cscfga__Eligibility_Criterion__c eligibilityCriterionMarket = new cscfga__Eligibility_Criterion__c(
                    cscfga__Eligibility_Rule__c = er.Id,
                    cscfga__Field__c = 'csmso__Sales_Order__r.Market__c',
                    cscfga__Operator__c = 'equals',
                    cscfga__Value__c = nameToMarketMap.get(erNameSplitList[0]).Id
                );
                eligibilityRuleCriterionToInsertList.add(eligibilityCriterionMarket);

                //Order Type
                cscfga__Eligibility_Criterion__c eligibilityCriterionOrderType = new cscfga__Eligibility_Criterion__c(
                    cscfga__Eligibility_Rule__c = er.Id,
                    cscfga__Field__c = 'csmso__Sales_Order__r.Order_Type__c',
                    cscfga__Operator__c = 'equals',
                    cscfga__Value__c = erNameSplitList[1]
                );
                eligibilityRuleCriterionToInsertList.add(eligibilityCriterionOrderType);
            }

            // Insert Criterions
            if (!eligibilityRuleCriterionToInsertList.isEmpty()){
                insert eligibilityRuleCriterionToInsertList;
            }

            // Update Eligibility Rules with latest changes
            update eligibilityRuleToInsertList;
        }

        // Update Eligibility Rule Id on Offers
        for(cscfga__Configuration_Offer__c offer : offerUpdateList) {
            offer.cscfga__Eligibility_Rule__c = offer.cscfga__Eligibility_Rule__r.Id;
        }
    }
}
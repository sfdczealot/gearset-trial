/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Dynamic Lookup Class to calculate Premium Charge.
* @param searchFields
*        'Rate Card Item Price Final' - get from SOLI, used in totalPremiumPercentageCharges calculation
*        'Premiums' - List of Premium IDs added to the SOLI
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1            aldo.topic@cloudsense.com
* 2019-03-27      Added part to calculate Preimums differently depending on Rate Card Premium Type 
*                 ('Compounded' or 'Additive').
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
global class CS_SPPremiumGroupChargesCalc extends cscfga.ALookupSearch {
    public override Object[] doDynamicLookupSearch(Map<String, String> searchFields, String productDefinitionID){
        String premiumIdsJSONList       = searchFields.get( 'Premiums' );
        String priceFinal   = searchFields.get( 'Rate Card Item Price Exchange' );
        String rateCardPremiumType   = searchFields.get( 'Rate Card Premium Type' );

        Premium_Group_Charge__c premiumGroupToReturn = new Premium_Group_Charge__c();
        premiumGroupToReturn.Premium_Flat_Rate__c = 0;

        if(!String.isBlank(premiumIdsJSONList)) {
            List<String> premiumList = premiumIdsJSONList.split(',');

            Decimal totalPremiumPercentageCharges = 0;
            Decimal totalPremiumFlatCharges = 0;

            List<Premium_Group_Charge__c> premiumGroupChargesList = [SELECT     Id, 
                                                                                Premium_Percentage__c, 
                                                                                Premium_Flat_Rate__c 
                                                                        FROM    Premium_Group_Charge__c 
                                                                        WHERE   Id IN :premiumList 
                                                                            ORDER BY    Premium_Percentage__c ASC]; 

            if(rateCardPremiumType == 'Compounded') {
                for(Premium_Group_Charge__c premiumGroupCharges : premiumGroupChargesList) {
                    if(premiumGroupCharges.Premium_Percentage__c != null)
                        totalPremiumPercentageCharges += (Decimal.valueOf(priceFinal) + totalPremiumPercentageCharges) * premiumGroupCharges.Premium_Percentage__c / 100;
                    if(premiumGroupCharges.Premium_Flat_Rate__c != null)
                        totalPremiumFlatCharges += premiumGroupCharges.Premium_Flat_Rate__c;
                }
            }
            else if(rateCardPremiumType == 'Additive') {
                for(Premium_Group_Charge__c premiumGroupCharges : premiumGroupChargesList) {
                    if(premiumGroupCharges.Premium_Percentage__c != null)
                        totalPremiumPercentageCharges += Decimal.valueOf(priceFinal) * premiumGroupCharges.Premium_Percentage__c / 100;
                    if(premiumGroupCharges.Premium_Flat_Rate__c != null)
                        totalPremiumFlatCharges += premiumGroupCharges.Premium_Flat_Rate__c;
                }
            }

            premiumGroupToReturn.Premium_Flat_Rate__c = totalPremiumPercentageCharges + totalPremiumFlatCharges;
        }

        return new List<Premium_Group_Charge__c>{premiumGroupToReturn}; 
    }

    public override String getRequiredAttributes(){ return '["Rate Card Item Price Exchange", "Premiums", "Rate Card Premium Type"]'; } 
}
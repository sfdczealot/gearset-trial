global with sharing class CS_GetRateCardItemPriceInvoker {
    global String performAction(String parameters) {
        RequestObject request = (RequestObject) JSON.deserialize(parameters, RequestObject.class);
        csmso__Rate_Card_Item_Price__c rateCardItemPrice = [
                SELECT Id, csmso__Price_Per_Unit__c, Minimum_Line_Value__c, CurrencyIsoCode
                FROM csmso__Rate_Card_Item_Price__c
                WHERE Account_Tier__c =: request.AccountTier
                AND csmso__Advert_Assignment__c =: request.AdvertAssignment
                AND csmso__Rate_Card__c =: request.RateCard
                LIMIT 1
        ];

        return JSON.serialize(rateCardItemPrice);
    }

    private class RequestObject {
        public String AccountTier { get; set; }
        public Id AdvertAssignment { get; set; }
        public Id RateCard { get; set; }
    }
}
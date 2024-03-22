/**
 * Created by tvrtko.matosevic on 29/05/2019.
 */

@IsTest
public with sharing class CS_OfferTriggerTest {

    @IsTest
    private static void testOfferTriggerInsertAndUpdate(){
        // create Business Unit
        csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
        businessUnit.Name = 'Test Business Unit';
        businessUnit.csmso__Sales_Ledger_Code__c = 'Test Sales Ledger Code';
        businessUnit.Unique_Id__c = 'Test Unique Id Business Unit';
        insert businessUnit;

        // create geo targeting
        csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
        geoItem.Name = 'United States';
        geoItem.csdf__Ad_Server_Id__c = '2840';
        insert geoItem;

        Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
        bookingTimeZone.Booking_Time_Zone_Country__c = 'Europe/London';
        bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
        insert bookingTimeZone;

        // create Market (csmso__Product_Node__c)
        csmso__Product_Node__c market = new csmso__Product_Node__c();
        market.Name = 'Test Market';
        market.csmso__Description__c = 'Test Market Description';
        market.csmso__Business_Unit__c = businessUnit.Id;
        market.CurrencyIsoCode = 'USD';
        market.Unique_Id__c = 'Test Market Unique Id';
        market.csmso__Media_Types__c = 'Desktop';
        market.Geo_Targeting__c = geoItem.Id;
        market.Sponsorship_Booking_Timezone__c = bookingTimeZone.Id;
        market.NAA_supported_currency__c = 'SGD';
        insert market;

        // create Rate Card (csmso__Rate_Card__c)
        csmso__Rate_Card__c rateCard = new csmso__Rate_Card__c();
        rateCard.Short_Description__c = 'Test Short Description Rate Card';
        rateCard.Type__c = 'Base';
        rateCard.csmso__Product_Node__c = market.Id;
        rateCard.csmso__From_Date__c = Date.today().addDays(-30);
        rateCard.csmso__To_Date__c = Date.today().addDays(30);
        rateCard.CurrencyIsoCode = 'USD';
        rateCard.Unique_Id__c = 'Test Unique Id Rate Card';
        rateCard.Minimum_Deal_Value__c = 0;
        rateCard.Maximum_Production_Cost__c = 12;
        rateCard.Order_Type__c = 'Direct Commercial';
        insert rateCard;

        cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c();
        offer.cscfga__Description__c = 'Offer test';
        offer.Product_Node__c = market.Id;
        offer.Order_Type__c = 'Direct Commercial';
        offer.Rate_Card__c = rateCard.Id;
        offer.Account_Tier__c = 'Tier 1';
        insert offer;

        offer.Account_Tier__c = 'Tier 2';
        update offer;
    }
}
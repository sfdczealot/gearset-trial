@IsTest
private class CS_GetPodcastTargetingListTest {

    @IsTest
    static void testInvokeGetPodcastTargetingList() {
        csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
        insert testAdServer;

        // create Business Unit (csmso__Business_Unit__c)
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
        bookingTimeZone.Name = 'Europe/London';
        bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
        bookingTimeZone.Booking_Time_Zone_Country__c = 'British Summer Time';
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

        csdf__Ad_Slot__c testAdSlot = TestDataSetupTargetables.createAdSlot();
        testAdSlot.csdf__Sizes__c = '24x25';
        testAdSlot.csdf__Ad_Server__c = testAdServer.Id;
        insert testAdSlot;

        csdf__Ad_Slot__c testAdSlot2 = TestDataSetupTargetables.createAdSlot();
        testAdSlot2.csdf__Sizes__c = '25x26';
        testAdSlot2.csdf__Ad_Server__c = testAdServer.Id;
        insert testAdSlot2;

        csdf__Targeting_Template__c adSlotTemplate = new csdf__Targeting_Template__c();
        adSlotTemplate.Name = 'Test Ad Slot Template';
        adSlotTemplate.csdf__Ad_Server__c = testAdServer.Id;
        insert adSlotTemplate;

        Ad_Slot_Targeting_Template__c adSlotTargetingTemplate = new Ad_Slot_Targeting_Template__c();
        adSlotTargetingTemplate.Ad_Slot__c = testAdSlot.Id;
        adSlotTargetingTemplate.Targeting_Template__c = adSlotTemplate.Id;
        insert adSlotTargetingTemplate;

        Ad_Slot_Targeting_Template__c adSlotTargetingTemplate2 = new Ad_Slot_Targeting_Template__c();
        adSlotTargetingTemplate2.Ad_Slot__c = testAdSlot2.Id;
        adSlotTargetingTemplate2.Targeting_Template__c = adSlotTemplate.Id;
        insert adSlotTargetingTemplate2;

        CS_GetPodcastTargetingList csUnlockLinesInvoker = new CS_GetPodcastTargetingList();
        String result = csUnlockLinesInvoker.performAction('[{"configId" : "a931w0000000HoF", "podcastGeoTargetingId" : "'+ market.Id + '", "podcastTargetingId" : "' + adSlotTemplate.Id + '"}]');

        System.assertEquals('{"a931w0000000HoF":"Inventory (include) testadname, testadname | Geography (include) Test Market Description"}', result);
    }
}
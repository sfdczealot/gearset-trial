@IsTest
public class CS_FulfilmentItemDelegateTest {
    private static Id adServerId;

    @TestSetup
    public static void setupCommonData() {
        
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;

        //CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;

        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;

        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;

        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_Account').getRecordTypeId();
		Account acc = TestDataSetupSO.createAccount();
		acc.recordTypeId = recordTypeId;
		insert acc;
        

        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;

        csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
        insert so;

        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        insert prodBasket;

        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Long_Custom_Key_Targeting__c = 'testLongCustomKeyTargeting is 123456789012345';
        insert prodConfig;

        csdf__Ad_Server__c adServer = new csdf__Ad_Server__c();
        adServer.Name = 'Newsday DFP Production';
        adServer.csdf__Network_Code__c = '5819';
        adServer.csdf__Username__c = 'userTest';
        adServer.csdf__Password__c = 'userPass';
        insert adServer;

        adServerId = adServer.Id;

        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
        testFulfilment.csdf__Ad_Server__c = adServer.Id;
        insert testFulfilment;

        csdf__Ad_Slot__c adSlot = new csdf__Ad_Slot__c();
        adSlot.csdf__Name__c = 'NewsDay Traffic';
        adSlot.csdf__Active__c = true;
        adSlot.csdf__Ad_Server__c = adServer.Id;
        adSlot.csdf__Ad_Server_Id__c = adServer.Id;
        adSlot.csdf__Code__c = 'cblvsn.nwsd.traffic';
        insert adSlot;

        csdf__Targetable__c targ = new csdf__Targetable__c();
        targ.csdf__Targetable_Name__c = 'Zen';
        targ.csdf__Active__c = true;
        targ.csdf__Ad_Server_Id__c = '40343';
        targ.csdf__Ad_Server__c = adServer.Id;
        targ.csdf__Type__c = 'Device Manufacturer';
        insert targ;

        csdf__Targetable__c targ2 = new csdf__Targetable__c();
        targ2.csdf__Targetable_Name__c = 'Zen';
        targ2.csdf__Active__c = true;
        targ2.csdf__Ad_Server_Id__c = '40343';
        targ2.csdf__Ad_Server__c = adServer.Id;
        targ2.csdf__Type__c = 'Device Category';
        insert targ2;

        csdf__Site__c site = new csdf__Site__c();
        site.Name = 'Test Site';
        site.csdf__Ad_Server__c = adServer.Id;
        insert site;

        csdf__Browser__c browser = new csdf__Browser__c();
        browser.csdf__Ad_Server__c = adServer.Id;
        browser.csdf__Ad_Server_Id__c = '500011';
        browser.csdf__Browser_Name__c = 'FireFox';
        insert browser;

        csdf__Operating_System__c opSystem = new csdf__Operating_System__c();
        opSystem.Name = 'PlayStation3';
        opSystem.csdf__Ad_Server__c = adServer.Id;
        opSystem.csdf__Active__c = true;
        opSystem.csdf__Ad_Server_Id__c = '501015';
        insert opSystem;

        csdf__Operating_System__c opSystemIOS = new csdf__Operating_System__c();
        opSystemIOS.Name = 'Apple iOS';
        opSystemIOS.csdf__Ad_Server__c = adServer.Id;
        opSystemIOS.csdf__Active__c = true;
        opSystemIOS.csdf__Ad_Server_Id__c = '501012';
        insert opSystemIOS;

        csdf__Operating_System_Version__c opversion = new csdf__Operating_System_Version__c();
        opversion.csdf__Operating_System__c = opSystemIOS.Id;
        opversion.csdf__Active__c = true;
        opversion.csdf__Ad_Server_Id__c = '630239';
        insert opversion;

        csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
        geoItem.Name = 'Kansas';
        geoItem.csdf__Ad_Server_Id__c = '21149';
        insert geoItem;
    }

    static csdf__Fulfilment__c getFulfilment() {
        return [SELECT Id, Name FROM csdf__Fulfilment__c LIMIT 1];
    }

    static csmso__Sales_Order__c getSalesOrder() {
        return [SELECT Id, Name FROM csmso__Sales_Order__c LIMIT 1];
    }

    static cscfga__Product_Configuration__c getProdConfig() {
        return [SELECT Id, Name FROM cscfga__Product_Configuration__c LIMIT 1];
    }

    static csdf__Fulfilment_Item__c getFulfilmentItem() {
        return [SELECT Id, Name FROM csdf__Fulfilment_Item__c LIMIT 1];
    }

    static csdf__Ad_Slot__c getAdSlot() {
        return [SELECT Id, Name FROM csdf__Ad_Slot__c LIMIT 1];
    }

    static csdf__Ad_Server__c getAdServer() {
        return [SELECT Id, Name FROM csdf__Ad_Server__c LIMIT 1];
    }

    static csdf__Targetable__c getTargetable() {
        return [SELECT Id, Name FROM csdf__Targetable__c LIMIT 1];
    }

    static csdf__Targetable__c getTargetable_DeviceCategory() {
        return [SELECT Id, Name FROM csdf__Targetable__c WHERE csdf__Type__c = 'Device Category' LIMIT 1];
    }

    static csdf__Site__c getSite() {
        return [SELECT Id, Name FROM csdf__Site__c LIMIT 1];
    }

    static csdf__Browser__c getBrowser() {
        return [SELECT Id, Name FROM csdf__Browser__c LIMIT 1];
    }

    static csdf__Operating_System__c getOperatingSystem() {
        return [SELECT Id, Name FROM csdf__Operating_System__c WHERE Name = 'PlayStation3' LIMIT 1];
    }

    static csdf__Operating_System_Version__c getOperatingSystemVersion() {
        return [SELECT Id, Name FROM csdf__Operating_System_Version__c LIMIT 1];
    }

    static csdf__Geo_Item__c getGeoItem() {
        return [SELECT Id, Name FROM csdf__Geo_Item__c LIMIT 1];
    }

    //@isTest
    /*static void CS_FulfilmentItemTrigger_method1() {
        CSSX__No_Triggers__c notriggers = new CSSX__No_Triggers__c();
        notriggers.cssx__Flag__c = false;
        insert notriggers;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(getProdConfig(), getSalesOrder(), getFulfilment() );
        testFulfilmentItem.Long_Custom_Key_Targeting__c = 'Audience Segment is test';
        testFulfilmentItem.csdf__Day_Part_Targeting__c = 'Tuesday,03,15,Wednesday,00,24,Thursday,00,24,Friday,00,24,Saturday,00,24,Sunday,00,24,';
        testFulfilmentItem.csdf__Ad_Server_Id__c = getAdServer().Id;
        testFulfilmentItem.csdf__Fulfilment__c = getFulfilment().Id;

        CS_FulfilmentItemDelegate delegate = new CS_FulfilmentItemDelegate();

        //testFulfilmentItem.Day_Part_Targeting_JSON__c = delegate.generateJSONData(testFulfilmentItem.csdf__Day_Part_Targeting__c.replaceAll('#', ',')).replaceAll(',', '#');

        testFulfilmentItem.csdf__Flight_Beginning__c = DateTime.valueOfGmt('2018-01-03 10:00:00');
        testFulfilmentItem.csdf__Flight_End__c = DateTime.valueOfGmt('2018-01-05 10:00:00');
        testFulfilmentItem.Booking_Timezone__c = 'Europe/London';

        CS_Custom_Settings__c settings = new CS_Custom_Settings__c();
        settings.Fulfilment_Item_Propert_Map_Key__c = 'fitoattribute';
        insert settings;

        Test.startTest();
        insert testFulfilmentItem;

        testFulfilmentItem = [SELECT Id FROM csdf__Fulfilment_Item__c LIMIT 1];


        csdf__Ad_Slot_Targeting__c adSlotTargeting = new csdf__Ad_Slot_Targeting__c();
        adSlotTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        adSlotTargeting.csdf__Ad_Slot__c = getAdSlot().Id;
        insert adSlotTargeting;


        csdf__Targetable_Targeting__c targetTargeting = new csdf__Targetable_Targeting__c();
        targetTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        targetTargeting.csdf__Targetable__c = getTargetable().Id;
        insert targetTargeting;

        csdf__Targetable_Targeting__c targetTargeting2 = new csdf__Targetable_Targeting__c();
        targetTargeting2.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        targetTargeting2.csdf__Targetable__c = getTargetable_DeviceCategory().Id;
        insert targetTargeting2;

        csdf__Site_Targeting__c siteTargeting = new csdf__Site_Targeting__c();
        siteTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        siteTargeting.csdf__Site__c = getSite().Id;
        insert siteTargeting;

        csdf__Geo_Targeting__c geoTargeting = new csdf__Geo_Targeting__c();
        geoTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        geoTargeting.csdf__Geo_Item__c = getGeoItem().Id;
        insert geoTargeting;

        csdf__Browser_Targeting__c browserTargeting = new csdf__Browser_Targeting__c();
        browserTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        browserTargeting.csdf__Browser__c = getBrowser().Id;
        insert browserTargeting;

        csdf__Operating_System_Targeting__c opTargeting = new csdf__Operating_System_Targeting__c();
        opTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        opTargeting.csdf__Operating_System__c = getOperatingSystem().Id;
        insert opTargeting;

        csdf__Operating_System_Version_Targeting__c opvTargeting = new csdf__Operating_System_Version_Targeting__c();
        opvTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        opvTargeting.csdf__Operating_System_Version__c = getOperatingSystemVersion().Id;
        insert opvTargeting;


        testFulfilmentItem.Long_Custom_Key_Targeting__c = 'Audience Segment is not test';
        testFulfilmentItem.csdf__Flight_Beginning__c = DateTime.valueOfGmt('2018-01-03 11:00:00');
        testFulfilmentItem.csdf__Day_Part_Targeting__c = 'Monday,00,24,Tuesday,03,15,Wednesday,00,24,Thursday,00,24,Friday,00,24,Saturday,00,24,Sunday,00,24,';
        testFulfilmentItem.Last_Action_from_DFP__c = DateTime.valueOfGmt('2018-01-03 11:00:00');
        update testFulfilmentItem;

        testFulfilmentItem = [SELECT id, name, Last_Action_from_DFP__c from csdf__Fulfilment_Item__c where Id = :testFulfilmentItem.Id];
        update testFulfilmentItem;

        Test.stopTest();
    }

    //@isTest
    static void CS_FulfilmentItemTrigger_method2() {
        CSSX__No_Triggers__c notriggers = new CSSX__No_Triggers__c();
        notriggers.cssx__Flag__c = true;
        insert notriggers;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(getProdConfig(), getSalesOrder(), getFulfilment() );
        testFulfilmentItem.Long_Custom_Key_Targeting__c = 'Audience Segment is test';
        testFulfilmentItem.csdf__Day_Part_Targeting__c = 'Tuesday,03,15,Wednesday,00,24,Thursday,00,24,Friday,00,24,Saturday,00,24,Sunday,00,24,';

        Test.startTest();
        insert testFulfilmentItem;
        Test.stopTest();
    }

    //@isTest
    static void CS_FulfilmentItemTrigger_method3() {
        CSSX__No_Triggers__c notriggers = new CSSX__No_Triggers__c();
        notriggers.cssx__Flag__c = false;
        insert notriggers;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(getProdConfig(), getSalesOrder(), getFulfilment() );
        testFulfilmentItem.Long_Custom_Key_Targeting__c = 'Audience Segment is test';
        testFulfilmentItem.csdf__Day_Part_Targeting__c = 'Tuesday,03,15,Wednesday,00,24,Thursday,00,24,Friday,00,24,Saturday,00,24,Sunday,00,24,';
        testFulfilmentItem.csdf__Ad_Server_Id__c = getAdServer().Id;
        testFulfilmentItem.csdf__Fulfilment__c = getFulfilment().Id;

        CS_FulfilmentItemDelegate delegate = new CS_FulfilmentItemDelegate();

        String dateJSON = delegate.generateJSONContent('2018-01-03', '2018-01-05', 2);

        testFulfilmentItem.csdf__Flight_Beginning__c = DateTime.valueOfGmt('2018-01-03 10:00:00');
        testFulfilmentItem.csdf__Flight_End__c = DateTime.valueOfGmt('2018-01-05 10:00:00');
        testFulfilmentItem.Booking_Timezone__c = 'Europe/London';

        CS_Custom_Settings__c settings = new CS_Custom_Settings__c();
        settings.Fulfilment_Item_Propert_Map_Key__c = 'fitoattribute';
        insert settings;

        Test.startTest();
        insert testFulfilmentItem;

        testFulfilmentItem = [SELECT Id FROM csdf__Fulfilment_Item__c LIMIT 1];


        csdf__Ad_Slot_Targeting__c adSlotTargeting = new csdf__Ad_Slot_Targeting__c();
        adSlotTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        adSlotTargeting.csdf__Ad_Slot__c = getAdSlot().Id;
        insert adSlotTargeting;


        csdf__Targetable_Targeting__c targetTargeting = new csdf__Targetable_Targeting__c();
        targetTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        targetTargeting.csdf__Targetable__c = getTargetable().Id;
        insert targetTargeting;

        csdf__Targetable_Targeting__c targetTargeting2 = new csdf__Targetable_Targeting__c();
        targetTargeting2.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        targetTargeting2.csdf__Targetable__c = getTargetable_DeviceCategory().Id;
        insert targetTargeting2;

        csdf__Site_Targeting__c siteTargeting = new csdf__Site_Targeting__c();
        siteTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        siteTargeting.csdf__Site__c = getSite().Id;
        insert siteTargeting;

        csdf__Geo_Targeting__c geoTargeting = new csdf__Geo_Targeting__c();
        geoTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        geoTargeting.csdf__Geo_Item__c = getGeoItem().Id;
        insert geoTargeting;

        csdf__Browser_Targeting__c browserTargeting = new csdf__Browser_Targeting__c();
        browserTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        browserTargeting.csdf__Browser__c = getBrowser().Id;
        insert browserTargeting;

        csdf__Operating_System_Targeting__c opTargeting = new csdf__Operating_System_Targeting__c();
        opTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        opTargeting.csdf__Operating_System__c = getOperatingSystem().Id;
        insert opTargeting;

        csdf__Operating_System_Version_Targeting__c opvTargeting = new csdf__Operating_System_Version_Targeting__c();
        opvTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        opvTargeting.csdf__Operating_System_Version__c = getOperatingSystemVersion().Id;
        insert opvTargeting;

        testFulfilmentItem.Long_Custom_Key_Targeting__c = 'Audience Segment is not test';
        testFulfilmentItem.csdf__Flight_Beginning__c = DateTime.valueOfGmt('2018-01-03 11:00:00');
        testFulfilmentItem.csdf__Day_Part_Targeting__c = 'Monday,00,24,Tuesday,03,15,Wednesday,00,24,Thursday,00,24,Friday,00,24,Saturday,00,24,Sunday,00,24,';
        testFulfilmentItem.Last_Action_from_DFP__c = DateTime.valueOfGmt('2018-01-03 11:00:00');
        update testFulfilmentItem;

        testFulfilmentItem = [SELECT id, name, Last_Action_from_DFP__c from csdf__Fulfilment_Item__c where Id = :testFulfilmentItem.Id];
        update testFulfilmentItem;

        Test.stopTest();
    }*/

    @IsTest
    static void testFulfilmentItemTriggerDFP() {
        CS_Custom_Settings__c settings = new CS_Custom_Settings__c();
        settings.Fulfilment_Item_Propert_Map_Key__c = 'fitoattribute';
        settings.IgnoreCLT__c = true;
        settings.KeyValue_configuration__c = 'ID';
        insert settings;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(getProdConfig(), getSalesOrder(), getFulfilment());
        testFulfilmentItem.Long_Custom_Key_Targeting__c = 'Audience Segment is test';
        testFulfilmentItem.Served_By__c = 'DFP';
        testFulfilmentItem.Booking_Timezone__c = 'Europe/London';
        testFulfilmentItem.csdf__Ad_Server_Id__c = getAdServer().Id;
        insert testFulfilmentItem;

        testFulfilmentItem = [SELECT Id, Name, Last_Action_from_DFP__c FROM csdf__Fulfilment_Item__c WHERE Id = :testFulfilmentItem.Id];

        Test.startTest();
        testFulfilmentItem.Last_Action_from_DFP__c = Datetime.valueOfGmt('2019-01-03 11:00:00');
        update testFulfilmentItem;
        Test.stopTest();
    }

    @IsTest
    static void testFulfilmentItemTriggerDFP2() {
        CS_Custom_Settings__c settings = new CS_Custom_Settings__c();
        settings.Fulfilment_Item_Propert_Map_Key__c = 'fitoattribute';
        settings.IgnoreCLT__c = false;
        settings.KeyValue_configuration__c = 'ID';
        insert settings;

        String dayPartTarg = 'Monday#0#24#Tuesday#2#24#Wednesday#2#24#Thursday#1#24#Friday#1#4#Friday#5#24#Saturday#0#2#Saturday#3#24#Sunday#0#24';

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(getProdConfig(), getSalesOrder(), getFulfilment());
        testFulfilmentItem.Long_Custom_Key_Targeting__c = 'Audience Segment is test';
        testFulfilmentItem.Served_By__c = 'DFP';
        testFulfilmentItem.Booking_Timezone__c = 'Europe/London';
        testFulfilmentItem.csdf__Ad_Server_Id__c = getAdServer().Id;
        testFulfilmentItem.csdf__Day_Part_Targeting__c = dayPartTarg;
        //testFulfilmentItem.Ad_Slot__c = 'INCLUDE:'++';EXCLUDE:;';
        insert testFulfilmentItem;

        testFulfilmentItem = [SELECT Id, Name, Last_Action_from_DFP__c FROM csdf__Fulfilment_Item__c WHERE Id = :testFulfilmentItem.Id];

        csdf__Fulfilment__c fulfilment = getFulfilment();
        fulfilment.csdf__Ad_Server__c = adServerId;
        update fulfilment;

        //sd slot
        csdf__Ad_Slot__c adSlot = getAdSlot();
        adSlot.csdf__Ad_Server__c = adServerId;
        adSlot.csdf__Ad_Server_Id__c = (String) getAdServer().Id;
        adSlot.csdf__Active__c = true;
        update adSlot;

        csdf__Ad_Slot_Targeting__c adSlotTargeting = new csdf__Ad_Slot_Targeting__c();
        adSlotTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        adSlotTargeting.csdf__Ad_Slot__c = adSlot.Id;
        insert adSlotTargeting;

        csdf__Ad_Server__c adserver = [SELECT Id, Name FROM csdf__Ad_Server__c];
        //browser
        csdf__Browser__c browser = new csdf__Browser__c();
        browser.csdf__Ad_Server_Id__c = '500083';
        browser.csdf__Browser_Name__c = 'Firefox';
        browser.csdf__Ad_Server__c = adserver.Id;
        insert browser;

        csdf__Browser_Targeting__c browserTargeting = new csdf__Browser_Targeting__c();
        browserTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        browserTargeting.csdf__Browser__c = browser.Id;
        insert browserTargeting;

        adSlotTargeting = [SELECT Id, csdf__Fulfilment_Item__c, csdf__Ad_Slot__c FROM csdf__Ad_Slot_Targeting__c WHERE Id = :adSlotTargeting.Id];

        Test.startTest();
        testFulfilmentItem.Last_Action_from_DFP__c = Datetime.valueOfGmt('2019-01-03 11:00:00');
        testFulfilmentItem.Ad_Slot__c = 'INCLUDE:' + adSlotTargeting.Id + ';EXCLUDE:;';
        update testFulfilmentItem;
        Test.stopTest();
    }

    @IsTest
    static void testFulfilmentItemTriggerIgnoreCTL() {
        CS_Custom_Settings__c settings = new CS_Custom_Settings__c();
        settings.Fulfilment_Item_Propert_Map_Key__c = 'fitoattribute';
        settings.IgnoreCLT__c = false;
        settings.KeyValue_configuration__c = 'ID';
        insert settings;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(getProdConfig(), getSalesOrder(), getFulfilment());
        testFulfilmentItem.Long_Custom_Key_Targeting__c = 'Audience Segment is test';
        testFulfilmentItem.Served_By__c = 'NotDFP';
        testFulfilmentItem.Booking_Timezone__c = 'Europe/London';
        testFulfilmentItem.csdf__Ad_Server_Id__c = getAdServer().Id;
        insert testFulfilmentItem;

        testFulfilmentItem = [SELECT Id, Name, Last_Action_from_DFP__c FROM csdf__Fulfilment_Item__c WHERE Id = :testFulfilmentItem.Id];

        Test.startTest();
        testFulfilmentItem.Last_Action_from_DFP__c = Datetime.valueOfGmt('2019-01-03 11:00:00');
        update testFulfilmentItem;
        Test.stopTest();
    }

    @IsTest
    static void testFulfilmentItemNoTriggers() {
        CSSX__No_Triggers__c notriggers = (CSSX__No_Triggers__c) CSSX__No_Triggers__c.getInstance();
        notriggers.cssx__Flag__c = true;
        insert notriggers;

        CS_Custom_Settings__c settings = new CS_Custom_Settings__c();
        settings.Fulfilment_Item_Propert_Map_Key__c = 'fitoattribute';
        settings.IgnoreCLT__c = false;
        settings.KeyValue_configuration__c = 'ID';
        insert settings;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(getProdConfig(), getSalesOrder(), getFulfilment());
        testFulfilmentItem.Long_Custom_Key_Targeting__c = 'Audience Segment is test';
        testFulfilmentItem.Served_By__c = 'NotDFP';
        testFulfilmentItem.Booking_Timezone__c = 'Europe/London';
        testFulfilmentItem.csdf__Ad_Server_Id__c = getAdServer().Id;
        insert testFulfilmentItem;

        testFulfilmentItem = [SELECT Id, Name, Last_Action_from_DFP__c FROM csdf__Fulfilment_Item__c WHERE Id = :testFulfilmentItem.Id];

        Test.startTest();
        testFulfilmentItem.Last_Action_from_DFP__c = Datetime.valueOfGmt('2019-01-03 11:00:00');
        update testFulfilmentItem;
        Test.stopTest();
    }
}
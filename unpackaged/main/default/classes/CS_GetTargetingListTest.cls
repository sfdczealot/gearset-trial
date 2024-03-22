@IsTest
private class CS_GetTargetingListTest {
    private static Id adSlotId;
    private static Id adServerId;
    private static Id prodConfId;
    private static Id nodeAdvertAssignmentId;

    private static csdf__Ad_Slot__c adSlot;
    private static csdf__Browser__c browser;
    private static csdf__Geo_Item__c geoItemParent;
    private static csdf__Geo_Item__c geoItemChild;
    private static csdf__Targetable__c targDeviceCategory;
    private static csdf__Targetable__c targetableDeviceManufacturer;
    private static csdf__Custom_Targeting_Key__c customTargetingKey;
    private static csdf__Custom_Targeting_Value__c customTargetingValue;
    private static csdf__Operating_System__c opSystem;
    private static csdf__Operating_System__c opSystemIOS;
    private static csdf__Operating_System_Version__c opSystemIOSVersion;
    private static csmso__Node_Advert_Assignment__c nodeAdvertAssignment;

    private static void createTestData() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;

        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;

        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;

        Account acc = TestDataSetupTargetables.createAccount();
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
        insert prodConfig;
        prodConfId = prodConfig.Id;

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

        adSlot = new csdf__Ad_Slot__c();
        adSlot.csdf__Name__c = 'NewsDay Traffic';
        adSlot.csdf__Active__c = true;
        adSlot.csdf__Ad_Server__c = adServer.Id;
        adSlot.csdf__Ad_Server_Id__c = adServer.Id;
        adSlot.csdf__Code__c = 'cblvsn.nwsd.traffic';
        insert adSlot;

        adSlotId = adSlot.Id;

        targDeviceCategory = new csdf__Targetable__c();
        targDeviceCategory.csdf__Targetable_Name__c = 'Zen';
        targDeviceCategory.csdf__Active__c = true;
        targDeviceCategory.csdf__Ad_Server_Id__c = '40343';
        targDeviceCategory.csdf__Ad_Server__c = adServer.Id;
        targDeviceCategory.csdf__Type__c = 'Device Category';
        insert targDeviceCategory;

        targetableDeviceManufacturer = new csdf__Targetable__c();
        targetableDeviceManufacturer.csdf__Targetable_Name__c = 'Zen';
        targetableDeviceManufacturer.csdf__Active__c = true;
        targetableDeviceManufacturer.csdf__Ad_Server_Id__c = '40343';
        targetableDeviceManufacturer.csdf__Ad_Server__c = adServer.Id;
        targetableDeviceManufacturer.csdf__Type__c = 'Device Manufacturer';
        insert targetableDeviceManufacturer;

        csdf__Site__c site = new csdf__Site__c();
        site.Name = 'Test Site';
        site.csdf__Ad_Server__c = adServer.Id;
        insert site;

        browser = new csdf__Browser__c();
        browser.csdf__Ad_Server__c = adServer.Id;
        browser.csdf__Ad_Server_Id__c = '500011';
        browser.csdf__Browser_Name__c = 'FireFox';
        insert browser;

        opSystem = new csdf__Operating_System__c();
        opSystem.Name = 'Android';
        opSystem.csdf__Ad_Server__c = adServer.Id;
        opSystem.csdf__Active__c = true;
        opSystem.csdf__Ad_Server_Id__c = '501015';
        insert opSystem;

        opSystemIOS = new csdf__Operating_System__c();
        opSystemIOS.Name = 'Apple iOS';
        opSystemIOS.csdf__Ad_Server__c = adServer.Id;
        opSystemIOS.csdf__Active__c = true;
        opSystemIOS.csdf__Ad_Server_Id__c = '501012';
        insert opSystemIOS;

        opSystemIOSVersion = new csdf__Operating_System_Version__c();
        opSystemIOSVersion.csdf__Operating_System__c = opSystemIOS.Id;
        opSystemIOSVersion.csdf__Active__c = true;
        opSystemIOSVersion.csdf__Ad_Server_Id__c = '630239';
        opSystemIOSVersion.csdf__Major_Version__c = '11';
        insert opSystemIOSVersion;

        geoItemParent = new csdf__Geo_Item__c();
        geoItemParent.Name = 'Portugal';
        geoItemParent.csdf__Ad_Server__c = adServerId;
        geoItemParent.csdf__Ad_Server_Id__c = '21149';
        geoItemParent.csdf__Category__c = 'COUNTRY';
        geoItemParent.csdf__Active__c = true;
        geoItemParent.csdf__Code__c = 'PT';
        insert geoItemParent;

        geoItemChild = new csdf__Geo_Item__c();
        geoItemChild.Name = 'Vila Real District';
        geoItemChild.csdf__Ad_Server__c = adServerId;
        geoItemChild.csdf__Ad_Server_Id__c = '21150';
        geoItemChild.csdf__Category__c = 'REGION';
        geoItemChild.csdf__Active__c = true;
        geoItemChild.csdf__Code__c = 'PT';
        insert geoItemChild;

        csdf__Geo_Item_Assignment__c geoItemAssignment = new csdf__Geo_Item_Assignment__c();
        geoItemAssignment.csdf__Geo_Item_Child__c = geoItemChild.Id;
        geoItemAssignment.csdf__Geo_Item_Parent__c = geoItemParent.Id;
        insert geoItemAssignment;

        customTargetingKey = new csdf__Custom_Targeting_Key__c();
        customTargetingKey.csdf__Ad_Server_Id__c = adServerId;
        customTargetingKey.csdf__Ad_Server__c = adServerId;
        customTargetingKey.Name = 'gender';
        customTargetingKey.csdf__Display_Name__c = 'gender';
        customTargetingKey.csdf__Ad_Server_Id__c = '208978';
        customTargetingKey.csdf__Type__c = 'Predefined';
        insert customTargetingKey;

        customTargetingValue = new csdf__Custom_Targeting_Value__c();
        customTargetingValue.csdf__Custom_Targeting_Key__c = customTargetingKey.Id;
        customTargetingValue.Name = 'female';
        customTargetingValue.csdf__Display_Name__c = 'female';
        customTargetingValue.csdf__Ad_Server_Id__c = '64574527498';
        insert customTargetingValue;

        nodeAdvertAssignment = new csmso__Node_Advert_Assignment__c();
        nodeAdvertAssignment.Name = 'testadname';
        nodeAdvertAssignment.Product_Name__c = 'testadname';
        nodeAdvertAssignment.Ad_Slot__c = 'INCLUDE:' + Id.valueOf(adSlotId) + ';EXCLUDE:;';
        nodeAdvertAssignment.Priority__c = '8';
        nodeAdvertAssignment.Ad_Server__c = adServerId;
        nodeAdvertAssignment.Served_by__c = 'DFP';
        nodeAdvertAssignment.Ad_Slot_Names__c = 'SPT_AD_Unit';
        nodeAdvertAssignment.Line_Item_Type__c = 'Standard';
        nodeAdvertAssignment.Inventory_sizes__c = '970x250';
        nodeAdvertAssignment.Line_Item_Category__c = 'Rotational';
        nodeAdvertAssignment.Rate_Type__c = 'CPM';
        nodeAdvertAssignment.Rate_Type_Display__c = 'CPM';
        nodeAdvertAssignment.Unique_Id__c = 'NAA_03RotationalTest';
        nodeAdvertAssignment.Product_Family__c = 'Audio';
        nodeAdvertAssignment.Ad_Location_Description__c = 'Everywhere';
        nodeAdvertAssignment.Product_Group__c = 'Audio';
        nodeAdvertAssignment.Key_values_and_Audience__c = '#208978 is #64574527618';
        nodeAdvertAssignment.Key_values_and_Audience_JSON__c = '%7B%22set_1%22%3A%20%7B%22key_1%22%3A%20%7B%22sfId%22%3A%20%22a5G6E0000008y4JUAQ%22%2C%22userLabel%22%3A%20%22gender%22%2C%22adId%22%3A%20%22%23208978%22%2C%22operator%22%3A%20%22is%22%2C%22values%22%3A%20%7B%22value_0%22%3A%20%7B%22sfId%22%3A%20%22a5H6E000000RpDIUA0%22%2C%22userLabel%22%3A%20%22male%22%2C%22adId%22%3A%20%22%2364574527618%22%7D%7D%7D%7D%7D';
        insert nodeAdvertAssignment;

        nodeAdvertAssignmentId = nodeAdvertAssignment.Id;

    }

    @IsTest
    static void testLoadStandardTemplateInput() {
        createTestData();

        CS_CurrentTargetingsTransformer.IncludeExclude adslotIE = new CS_CurrentTargetingsTransformer.IncludeExclude();
        adslotIE.include.add(adSlot.Id);

        CS_CurrentTargetingsTransformer.IncludeExclude geoIE = new CS_CurrentTargetingsTransformer.IncludeExclude();
        geoIE.include.add(geoItemParent.Id);
        geoIE.exclude.add(geoItemChild.Id);

        CS_CurrentTargetingsTransformer.IncludeExclude browserIE = new CS_CurrentTargetingsTransformer.IncludeExclude();
        browserIE.include.add(browser.Id);

        CS_CurrentTargetingsTransformer.IncludeExclude targDeviceIE = new CS_CurrentTargetingsTransformer.IncludeExclude();
        targDeviceIE.include.add(targDeviceCategory.Id);

        CS_CurrentTargetingsTransformer.IncludeExclude targDeviceManuIE = new CS_CurrentTargetingsTransformer.IncludeExclude();
        targDeviceManuIE.exclude.add(targetableDeviceManufacturer.Id);

        CS_CurrentTargetingsTransformer.IncludeExclude operSysIE = new CS_CurrentTargetingsTransformer.IncludeExclude();
        operSysIE.include.add(opSystemIOS.Id);
        operSysIE.exclude.add(opSystem.Id);

        CS_CurrentTargetingsTransformer.IncludeExclude operSysVerIE = new CS_CurrentTargetingsTransformer.IncludeExclude();
        operSysVerIE.exclude.add(opSystemIOSVersion.Id);

        Map<String, String> req = new Map<String, String>();
        Map<String, Object> currentTargeting = new Map<String, Object>{
                'AdSlots' => adslotIE,
                'Geography' => geoIE,
                'Browsers' => browserIE,
                'DeviceCategories' => targDeviceIE,
                'DeviceManufacturer' => targDeviceIE,
                'OperatingSystems' => operSysIE,
                'OperatingSystemVersions' => operSysVerIE,
                'VideoPosition' => (Map<String, Object>)JSON.deserializeUntyped('{"targeting":[{"videoPositionTargeting":{"targetedPositions":[{"positionType":"PREROLL","midrollIndex":0},{"positionType":"MIDROLL","videoPositionWithinPod":100,"midrollIndex":0},{"positionType":"MIDROLL","midrollIndex":1}]}}]}'),
                'KVA' =>  (Map<String, Object>)JSON.deserializeUntyped('{"query":"#208978 is #64574527498","JSON":null}')
        };
        req.put('guid', JSON.serialize(currentTargeting));

        Test.startTest();
        String reqJSON = JSON.serialize(req);
        System.debug('reqJSON => ' + reqJSON);
        CS_GetTargetingList getTargetingList = new CS_GetTargetingList();
        String json = getTargetingList.performAction(reqJSON);
        System.debug('JSON => ' + json);
        Test.stopTest();
    }
}
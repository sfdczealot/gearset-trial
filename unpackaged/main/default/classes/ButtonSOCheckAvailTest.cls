@IsTest
private class ButtonSOCheckAvailTest {
    private static Account[] accs;
    private static csmso__Sales_Order__c salesOrder;

    private static void createTestData() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();
        customSettings.Max_n_Templates_for_Sync_Execution__c = 5000;
        customSettings.Max_n_Lines_for_Sync_Execution__c = 50;
        update customSettings;

        accs = TestDataSetupBasic.createAccounts(5);
        Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
        Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs, cons);

        salesOrder = new csmso__Sales_Order__c();
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.SO_Lines_Number_of_lines__c = 2;
        salesOrder.csmso__Opportunity__c = opps[0].Id;
        insert salesOrder;
    }

    @IsTest
    static void testButtonButtonSOCheckAvail() {
        createTestData();

        Test.startTest();
        ButtonSOCheckAvail button = new ButtonSOCheckAvail();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }

    @IsTest
    static void testButtonButtonSOCheckAvailError() {
        createTestData();

        salesOrder.SO_Lines_All_Valid__c = false;
        update salesOrder;

        Test.startTest();
        ButtonSOCheckAvail button = new ButtonSOCheckAvail();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }

    @IsTest
    static void testButtonButtonSOCheckAvailNoLines() {
        createTestData();

        salesOrder.SO_Lines_Number_of_lines__c = 0;
        update salesOrder;

        Test.startTest();
        ButtonSOCheckAvail button = new ButtonSOCheckAvail();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }

    @IsTest
    static void testButtonButtonSOCheckAvailException() {
        createTestData();

        salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_PENDING_BOOKING;
        salesOrder.SO_Lines_Ad_Server_Items__c = 2;
        salesOrder.Order_Type__c = CS_Constants.ORDER_TYPE_HOUSE_GUARANTEED;
        update salesOrder;

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{salesOrder});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1, new List<csmso__Sales_Order__c>{salesOrder}, accs);

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1, fulfilment, prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        fulfilmentItem[0].Product_Configuration__c = prodConfigs[0].Id;
        fulfilmentItem[0].csdf__Availability_Check_Status__c = 'Completed';
        update fulfilmentItem;

        for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
            pConfig.Sales_Order__c = salesOrder.Id;
            pConfig.cscfga__Product_Basket__c = prodBaskets[0].Id;
            pConfig.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
            pConfig.Flight_Begin__c = Date.today().addDays(2);
            pConfig.Ad_Type__c = 'Standard';
            pConfig.Insertion_Unit_Type_Display__c = 'CPD';
            pConfig.Served_By__c = 'DFP';
            pConfig.csmso__Flight_End__c = Date.today().addDays(5);
            pConfig.Fulfilment_Item_Status__c = 'Draft';
        }
        update prodConfigs;

        Test.startTest();
        ButtonSOCheckAvail button = new ButtonSOCheckAvail();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }
}
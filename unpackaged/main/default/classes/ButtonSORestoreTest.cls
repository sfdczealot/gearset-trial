@IsTest
private class ButtonSORestoreTest {
    private static Account[] accs;
    private static csmso__Sales_Order__c salesOrder;

    private static void createTestData() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
        cs.Integration_Chunk_Size__c = 10;
        cs.Sync_Retraction_SOLI_Limit__c = 10;
        insert cs;

        accs = TestDataSetupBasic.createAccounts(1);
        Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
        Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);

        salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opps[0].Id;
        salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL_READY;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.SO_Lines_Number_lines_RI__c = 2;
        salesOrder.SO_Lines_Ad_Server_Items__c = 0;
        salesOrder.Is_Archived__c = true;
        salesOrder.Never_Archive__c = false;
        insert salesOrder;
    }

    @IsTest
    static void testButtonSORestore() {
        createTestData();

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
                salesOrder
        });

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
            pConfig.Sales_Order__c = salesOrder.Id;
            pConfig.Reserve_Inventory__c = true;
            pConfig.Inventory_Available__c = 'Yes';
        }
        update prodConfigs;

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1, new List<csmso__Sales_Order__c>{
                salesOrder
        }, accs);

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1, fulfilment, prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        prodConfigs = [
                SELECT Id, Sales_Order__c
                FROM cscfga__Product_Configuration__c
        ];

        Test.startTest();
        ButtonSORestore button = new ButtonSORestore();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }

    @IsTest
    static void testButtonSORestoreFailedToRestore() {
        createTestData();

        Test.startTest();
        ButtonSORestore button = new ButtonSORestore();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }

    @IsTest
    static void testButtonSORestoreErrorMessage() {
        createTestData();

        salesOrder.Is_Archived__c = false;
        update salesOrder;

        Test.startTest();
        ButtonSORestore button = new ButtonSORestore();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }
}
@IsTest
private class CS_ArchiveActionInvokerTest {
    private static csmso__Sales_Order__c so;
    private static csdf__Fulfilment__c testFulfilment;
    private static cscfga__Product_Configuration__c prodConfig;

    private static void createTestData() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        Account acc = TestDataSetupBasic.createAccount();
        insert acc;

        Contact con = TestDataSetupBasic.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        insert opp;

        so = TestDataSetupSO.createSalesOrder(acc, opp);
        insert so;

        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        insert prodBasket;

        testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
        insert testFulfilment;

        prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Sales_Order__c = so.Id;
        insert prodConfig;
    }

    @IsTest
    static void testArchiveActionAdServedValidResponse() {
        createTestData();

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
        testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
        testFulfilmentItem.csdf__Pause_Resume_Message_Status__c = 'Completed';
        testFulfilmentItem.Reservation_Status__c = 'RELEASED';
        testFulfilmentItem.Served_By__c = 'DFP';
        insert testFulfilmentItem;

        Test.startTest();
        CS_ArchiveActionInvoker.ArchiveRequest request = new CS_ArchiveActionInvoker.ArchiveRequest();
        request.action = 'Test';
        request.configurationIds = new List<Id>{
                prodConfig.Id
        };

        String parameters = JSON.serialize(request);
        CS_ArchiveActionInvoker caPollClass = new CS_ArchiveActionInvoker();
        String str = caPollClass.performAction(parameters);
        System.assert(!String.isEmpty(str));
        Test.stopTest();
    }

    @IsTest
    static void testArchiveActionNonAdServedValidResponse() {
        createTestData();

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
        testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
        testFulfilmentItem.csdf__Pause_Resume_Message_Status__c = 'Completed';
        testFulfilmentItem.Reservation_Status__c = 'RELEASED';
        testFulfilmentItem.Served_By__c = 'Megaphone';
        insert testFulfilmentItem;

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = so.Id;
        insert salesOrderSchedule;

        CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
        bs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        insert bs;

        CS_Revenue_Schedule__c rs = new CS_Revenue_Schedule__c();
        rs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        insert rs;

        CS_Billing_Schedule_Item__c bsItem = new CS_Billing_Schedule_Item__c();
        bsItem.Status__c = 'Open';
        bsItem.Sales_Order__c = so.Id;
        bsItem.Product_Configuration__c = prodConfig.Id;
        bsItem.Billing_Schedule__c = bs.Id;
        insert bsItem;

        CS_Revenue_Schedule_Item__c rsItem = new CS_Revenue_Schedule_Item__c();
        rsItem.Sales_Order__c = so.Id;
        rsItem.Status__c = 'Open';
        rsItem.Product_Configuration__c = prodConfig.Id;
        rsItem.Revenue_Schedule__c = rs.Id;
        insert rsItem;

        Test.startTest();
        CS_ArchiveActionInvoker.ArchiveRequest request = new CS_ArchiveActionInvoker.ArchiveRequest();
        request.configurationIds = new List<Id>{
                prodConfig.Id
        };

        String parameters = JSON.serialize(request);
        CS_ArchiveActionInvoker caPollClass = new CS_ArchiveActionInvoker();
        String str = caPollClass.performAction(parameters);
        System.assert(!String.isEmpty(str));
        Test.stopTest();
    }

    @IsTest
    static void testArchiveActionAdServedExceptionNullConfigs() {
        createTestData();

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
        testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
        testFulfilmentItem.csdf__Pause_Resume_Message_Status__c = 'Completed';
        testFulfilmentItem.Reservation_Status__c = 'RELEASED';
        testFulfilmentItem.Served_By__c = 'DFP';
        insert testFulfilmentItem;

        Test.startTest();
        CS_ArchiveActionInvoker.ArchiveRequest request = new CS_ArchiveActionInvoker.ArchiveRequest();

        try {
            String parameters = JSON.serialize(request);
            CS_ArchiveActionInvoker caPollClass = new CS_ArchiveActionInvoker();
            String str = caPollClass.performAction(parameters);
            System.assert(!String.isEmpty(str));
        } catch (Exception e) {
        }
        Test.stopTest();
    }

    @IsTest
    static void testArchiveActionAdServedExceptionNullFulfilmentItems() {
        createTestData();

        Test.startTest();
        CS_ArchiveActionInvoker.ArchiveRequest request = new CS_ArchiveActionInvoker.ArchiveRequest();
        request.configurationIds = new List<Id>{
                prodConfig.Id
        };

        try {
            String parameters = JSON.serialize(request);
            CS_ArchiveActionInvoker caPollClass = new CS_ArchiveActionInvoker();
            String str = caPollClass.performAction(parameters);
            System.assert(!String.isEmpty(str));
        } catch (Exception e) {
        }
        Test.stopTest();
    }
}
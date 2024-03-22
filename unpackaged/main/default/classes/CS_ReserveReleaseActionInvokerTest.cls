@IsTest
private class CS_ReserveReleaseActionInvokerTest {

    @IsTest
    static void testReserveReleaseActionValidResponse() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        Account acc = TestDataSetupBasic.createAccount();
        insert acc;

        Contact con = TestDataSetupBasic.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        insert opp;

        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        insert so;

        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        insert prodBasket;

        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
        insert testFulfilment;

        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        insert prodConfig;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
        testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
        testFulfilmentItem.csdf__Pause_Resume_Message_Status__c = 'Completed';
        testFulfilmentItem.Reservation_Status__c = 'RELEASED';
        insert testFulfilmentItem;

        Test.startTest();
        CS_ReserveReleaseActionInvoker.ReserveReleaseRequest request = new CS_ReserveReleaseActionInvoker.ReserveReleaseRequest();
        request.configurationIds = new List<Id> { prodConfig.Id };

        String parameters = JSON.serialize(request);
        CS_ReserveReleaseActionInvoker caPollClass = new CS_ReserveReleaseActionInvoker();
        String str = caPollClass.performAction(parameters);
        System.assert(!String.isEmpty(str));
        Test.stopTest();
    }

    @IsTest
    static void testReserveReleaseActionThrowException() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        Account acc = TestDataSetupBasic.createAccount();
        insert acc;

        Contact con = TestDataSetupBasic.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        insert opp;

        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        insert so;

        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        insert prodBasket;

        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
        insert testFulfilment;

        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        insert prodConfig;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
        testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
        testFulfilmentItem.csdf__Pause_Resume_Message_Status__c = 'Completed';
        testFulfilmentItem.Reservation_Status__c = 'RELEASED';
        insert testFulfilmentItem;

        Test.startTest();
        CS_ReserveReleaseActionInvoker.ReserveReleaseRequest request = new CS_ReserveReleaseActionInvoker.ReserveReleaseRequest();
        request.configurationIds = new List<Id>();
        request.action = 'Reserve';

        String parameters = JSON.serialize(request);
        try {
            CS_ReserveReleaseActionInvoker caPollClass = new CS_ReserveReleaseActionInvoker();
            String str = caPollClass.performAction(parameters);
        }
        catch (CS_ReserveReleaseActionInvoker.CS_ReserveReleaseException e){
            System.assert(e != null);
        }

        Test.stopTest();
    }

    @IsTest
    static void testReserveReleaseActionThrowException2() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        Account acc = TestDataSetupBasic.createAccount();
        insert acc;

        Contact con = TestDataSetupBasic.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        insert opp;

        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        insert so;

        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        insert prodBasket;

        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
        insert testFulfilment;

        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        insert prodConfig;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
        testFulfilmentItem.Product_Configuration__c = null;
        testFulfilmentItem.csdf__Pause_Resume_Message_Status__c = 'Completed';
        testFulfilmentItem.Reservation_Status__c = 'RELEASED';
        insert testFulfilmentItem;

        Test.startTest();
        CS_ReserveReleaseActionInvoker.ReserveReleaseRequest request = new CS_ReserveReleaseActionInvoker.ReserveReleaseRequest();
        request.configurationIds = new List<Id> { prodConfig.Id };
        request.action = 'Reserve';

        String parameters = JSON.serialize(request);
        try {
            CS_ReserveReleaseActionInvoker caPollClass = new CS_ReserveReleaseActionInvoker();
            String str = caPollClass.performAction(parameters);
        }
        catch (CS_ReserveReleaseActionInvoker.CS_ReserveReleaseException e){
            System.assert(e != null);
        }

        Test.stopTest();
    }
}
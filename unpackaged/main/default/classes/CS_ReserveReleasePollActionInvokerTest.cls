/**
 * Created by tvrtko.matosevic on 06/02/2020.
 */

@IsTest
private class CS_ReserveReleasePollActionInvokerTest {
    @IsTest
    static void testReserveReleasePollActionValidResponse() {
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

        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so,acc);
        insert testFulfilment;

        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        insert prodConfig;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig,so,testFulfilment);
        testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
        testFulfilmentItem.csdf__Availability_Check_Status__c ='Completed';
        testFulfilmentItem.csdf__Pause_Resume_Message_Status__c ='Completed';
        testFulfilmentItem.csdf__Cancel_Message_Status__c = 'Completed';
        testFulfilmentItem.Reservation_Status__c = 'RESERVED';
        insert testFulfilmentItem;

        Test.startTest();
        String parameters = JSON.serialize(new List<Id> {prodConfig.Id});
        CS_ReserveReleasePollActionInvoker caPollClass = new CS_ReserveReleasePollActionInvoker();
        String str = caPollClass.performAction(parameters);
        System.debug('str => ' + str);
        System.assert(!String.isEmpty(str));
        Test.stopTest();
    }

    @IsTest
    static void testReserveReleasePollActionInvalidResponse() {
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

        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so,acc);
        insert testFulfilment;

        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        insert prodConfig;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig,so,testFulfilment);
        testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
        testFulfilmentItem.csdf__Pause_Resume_Message_Status__c ='Error';
        testFulfilmentItem.Reservation_Status__c = 'RELEASED';
        insert testFulfilmentItem;

        Test.startTest();
        String parameters = JSON.serialize(new List<Id> {prodConfig.Id});
        CS_ReserveReleasePollActionInvoker caPollClass = new CS_ReserveReleasePollActionInvoker();
        String str = caPollClass.performAction(parameters);
        System.assert(!String.isEmpty(str));
        Test.stopTest();
    }
}
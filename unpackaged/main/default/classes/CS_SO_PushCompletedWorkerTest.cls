/**
 * Created by tvrtko.matosevic on 19/02/2019.
 */

@IsTest
private class CS_SO_PushCompletedWorkerTest {
    @IsTest
    static void testAsyncPushCompletedWorker() {

        Account acc = TestDataSetupTargetables.createAccount();
        insert acc;

        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;

        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'Draft';
        salesOrder.Applicable_IO_Volume_Discount_Range__c =1;
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Advertiser_Final__c = acc.id;
        insert salesOrder;

        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;

        Test.startTest();
        CS_SO_PushCompletedWorker.prepareWork(salesOrder.Id);
        Test.stopTest();

        csmso__Sales_Order__c salesOrder2 = [SELECT Id, csmso__Status__c FROM csmso__Sales_Order__c WHERE Id =: salesOrder.Id];
        System.assertEquals(CS_const_SalesOrder.Status_PendingLegalApproval, salesOrder2.csmso__Status__c);
    }
}
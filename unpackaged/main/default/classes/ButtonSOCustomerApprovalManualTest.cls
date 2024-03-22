@IsTest
private class ButtonSOCustomerApprovalManualTest {

    @IsTest
    static void testButtonSOCustomerApprovalManualNegative() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        // Needs an opp for the flow on SO
        Account[] accs = TestDataSetupBasic.createAccounts(5);
        Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
        Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs, cons);
        update opps[0];

        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opps[0].Id;
        insert salesOrder;

        Test.startTest();
        update salesOrder;
        ButtonSOCustomerApprovalManual button = new ButtonSOCustomerApprovalManual();
        button.performAction(salesOrder.Id);

        salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL_READY;
        update salesOrder;
        button.performAction(salesOrder.Id);

        salesOrder.csmso__From__c = Date.today() ;
        salesOrder.csmso__To__c = Date.today().addMonths(3);
        salesOrder.csmso__Status__c = 'Pending Booking';
        update SalesOrder;
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }

    @IsTest
    static void testButtonSOCustomerApprovalManualPositive() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        // Needs an opp for the flow on SO
        Account[] accs = TestDataSetupBasic.createAccounts(5);
        Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
        Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs, cons);
        opps[0].Agreement_Status__c = 'Out for Signature';
        opps[0].Agreement_Status_Date__c = Date.today();
        update opps[0];

        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opps[0].Id;
        salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL_READY;
        salesOrder.Approval_Customer_Required__c = true;
        insert salesOrder;

        Test.startTest();
        ButtonSOCustomerApprovalManual button = new ButtonSOCustomerApprovalManual();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }
}
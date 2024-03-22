@isTest
private class CS_SalesOrderInvokerTest {
	
	@isTest static void testSOInvoker() {
		Account acc = TestDataSetupBasic.createAccount();
        insert acc;
        
        Contact con = TestDataSetupBasic.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        insert so;
       
        Test.startTest();
        CS_SalesOrderInvoker soInvoker = new CS_SalesOrderInvoker();
     	soInvoker.performAction(JSON.serialize(so.id));
        Test.stopTest();
	}
}
@isTest
private class CS_SalesOrderRollUpInvokerTest {
	
	@isTest static void testSORollUpInvoker() {
		Account acc = TestDataSetupBasic.createAccount();
        insert acc;
        
        Contact con = TestDataSetupBasic.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        insert so;
       
        Test.startTest();
        CS_SalesOrderRollUpInvoker soRollupInvoker = new CS_SalesOrderRollUpInvoker();
     	soRollupInvoker.performAction(JSON.serialize(so.id));
        Test.stopTest();
	}
}
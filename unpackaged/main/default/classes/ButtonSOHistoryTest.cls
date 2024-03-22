@isTest
private class ButtonSOHistoryTest {
	
	@isTest static void testButtonSOHistory() {
		Account[] testAccounts = TestDataSetupSO.createAccounts(1);
		Contact[] testContacts = TestDatasetupSO.createContacts(1, testAccounts);
		Opportunity[] testOpportunities = TestDataSetupSO.createOpportunities(1, testAccounts, testContacts);
		csmso__Sales_Order__c[] testSOs = TestDatasetupSO.createSalesOrders(1, testAccounts, testOpportunities);


		ButtonSOHistory button = new ButtonSOHistory();
		button.performAction(testSOs[0].id);
		testSOs[0].Reason_for_Cancellation__c = 'Duration';
		update testSOs[0];
		button.performAction(testSOs[0].id);
	}
	
	
}
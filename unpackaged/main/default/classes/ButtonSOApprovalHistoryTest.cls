@isTest
private class ButtonSOApprovalHistoryTest {
	
		@isTest static void testButtonSOApprovalHistory() {
		Account[] testAccounts = TestDataSetupSO.createAccounts(1);
		Contact[] testContacts = TestDatasetupSO.createContacts(1, testAccounts);
		Opportunity[] testOpportunities = TestDataSetupSO.createOpportunities(1, testAccounts, testContacts);
		csmso__Sales_Order__c[] testSOs = TestDatasetupSO.createSalesOrders(1, testAccounts, testOpportunities);

		ButtonSOApprovalHistory button = new ButtonSOApprovalHistory();
		button.performAction(testSOs[0].id);
	}
	

}
@IsTest
private class CS_P_ClickApproveApproverPendingTest {
	private static Contact con;
	private static Opportunity opp;
	private static CSCAP__Customer_Approval__c customerApproval;

	private static void createTestData() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account acc = TestDataSetupBasic.createAccount();
		insert acc;

		con = TestDataSetupBasic.createContact(acc);
		insert con;

		opp = TestDataSetupBasic.createOpportunity(acc, con);
		insert opp;

		customerApproval = new CSCAP__Customer_Approval__c();
		customerApproval.CSCAP__Opportunity__c = opp.Id;
		insert customerApproval;
	}

	@IsTest
	static void testClickApproveApproverPending() {
		createTestData();

		CSCAP__ClickApprove_Approver__c clickApproveApprover = new CSCAP__ClickApprove_Approver__c();
		clickApproveApprover.CSCAP__Approver_Approval_Status__c = 'Pending';
		clickApproveApprover.CSCAP__Contact__c = con.Id;
		clickApproveApprover.CSCAP__Customer_Approval__c = customerApproval.Id;
		insert clickApproveApprover;

		Test.startTest();
		CS_P_ClickApproveApproverPending clickApproveApproverPending = new CS_P_ClickApproveApproverPending();
		clickApproveApproverPending.applicableObjects = new List<CSCAP__ClickApprove_Approver__c>{clickApproveApprover};
		clickApproveApproverPending.isRecordEligible(clickApproveApprover);
		clickApproveApproverPending.logic();
		Test.stopTest();

		opp = [
				SELECT 	Id,
						Agreement_Status__c
				FROM Opportunity
				WHERE Id = :opp.Id
		];

		System.assertEquals(opp.Agreement_Status__c, 'Out for Signature');
	}
}
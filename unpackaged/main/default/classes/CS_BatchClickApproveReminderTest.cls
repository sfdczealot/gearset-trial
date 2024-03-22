@IsTest
private class CS_BatchClickApproveReminderTest {

	private static void createTestData(Integer clickApproveReminderDays) {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());

		//Batch worker needs custom setting
		Worker__c setting = CS_th_Worker.create(1, 200, 20, null, null, CS_const_ApexJob.JobType_BatchApex, CS_const_ApexJob.JobType_BatchApex, true);

		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CSCAP__ClickApprove_Constants__c caConstsSetting = new CSCAP__ClickApprove_Constants__c();
		caConstsSetting.ClickApprove_Reminder_Days__c = clickApproveReminderDays;
		insert caConstsSetting;

		List<Account> accs = TestDataSetupBasic.createAccounts(2);
		//insert accs;

		List<Contact> cons = TestDataSetupBasic.createContacts(2, accs);
		//insert cons;

		List<Opportunity> opps = TestDataSetupBasic.createOpportunities(2, accs, cons);
		//insert opps;

		List<CSCAP__Customer_Approval__c> approvals = new List<CSCAP__Customer_Approval__c>();
		approvals.add(new CSCAP__Customer_Approval__c(cscap__Opportunity__c = opps[0].Id));
		approvals.add(new CSCAP__Customer_Approval__c(cscap__Opportunity__c = opps[0].Id));
		insert approvals;
	}

	@IsTest
	static void testBatchClickApproveReminderFuture() {
		createTestData(-1);

		Test.startTest();
		CS_BatchClickApproveReminder clickApproveReminderBatch = new CS_BatchClickApproveReminder();
		//clickApproveReminderBatch.execute();
		Database.executeBatch(clickApproveReminderBatch);
		Test.stopTest();

		List<CSCAP__Customer_Approval__c> customerApprovals = [SELECT Id FROM CSCAP__Customer_Approval__c WHERE Reminder_Sent__c = TRUE];
		System.assertEquals(2, customerApprovals.size(), 'Two emails should have been sent');
	}

	@IsTest
	static void testBatchClickApproveReminderPast() {
		createTestData(5);

		Test.startTest();
		CS_BatchClickApproveReminder clickApproveReminderBatch = new CS_BatchClickApproveReminder();
		//clickApproveReminderBatch.execute();
		Database.executeBatch(clickApproveReminderBatch);
		Test.stopTest();

		List<CSCAP__Customer_Approval__c> customerApprovals = [SELECT Id FROM CSCAP__Customer_Approval__c WHERE Reminder_Sent__c = TRUE];
		System.assertEquals(0, customerApprovals.size(), 'No emails should have been sent');
	}
}
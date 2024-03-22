@IsTest
private class ButtonSOApprovalAcceptTest {
	private static String soID;
	private static User standardUser;
	private static User standardUser2;
	private static User systemAdminUser;
	private static csmso__Sales_Order__c salesOrder;

	private static void createTestData() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name IN ('System Administrator', 'Systeembeheerder') LIMIT 1];
		systemAdminUser = new User(Alias = 'standta', Email = 'standardusear@testorg.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = systemAdminProfile.Id,
				TimeZoneSidKey = 'America/Los_Angeles', Username = 'standamarkordusera1234@testorg.com');
		insert systemAdminUser;

		Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
		standardUser = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = standardUserProfile.Id, ManagerId = systemAdminUser.Id,
				TimeZoneSidKey = 'America/Los_Angeles', Username = 'standamarkorduser1234@testorg.com');
		insert standardUser;

		standardUser2 = new User(Alias = 'standtar', Email = 'standardusfer@testorg.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = standardUserProfile.Id, ManagerId = systemAdminUser.Id,
				TimeZoneSidKey = 'America/Los_Angeles', Username = 'standamarkorduaser1234@testorg.com');
		insert standardUser2;

		Group g1 = new Group(Name = 'Commercial Director Approval', Type = 'Queue');
		insert g1;

		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		Opportunity o = opps[0];
		update o;

		salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = o.Id;
		salesOrder.isTestRunning__c = true;
		salesOrder.csmso__Advertiser__c = accs[0].Id;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		salesOrder.Inventory_Approval__c = 'Pending';
		salesOrder.Approval_Custom_Button__c = true;
		salesOrder.Approval_Inventory_Required__c = true;
		salesOrder.Billing_Calendar__c = 'Standard';
		salesOrder.csmso__Booking_Contact__c = cons[0].Id;
		salesOrder.Paper_Type__c = 'Spotify Paper';
		salesOrder.csmso__Purchase_Order_Number__c = '1234';
		salesOrder.Bill_To_Account__c = accs[0].Id;
		insert salesOrder;

		soID = salesOrder.Id;
	}

	@IsTest
	static void testButtonSOApprovalAccept() {
		createTestData();

		Test.startTest();
		System.runAs(standardUser) {
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(soID);
		}

		System.runAs(systemAdminUser) {
			ButtonSOApprovalAccept button = new ButtonSOApprovalAccept();
			button.performAction(soID);
		}

		System.runAs(standardUser) {
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(soID);
		}

		System.runAs(standardUser2) {
			ButtonSOApprovalAccept button = new ButtonSOApprovalAccept();
			button.performAction(soID);
			button.performAction(soID);
		}
		Test.stopTest();
	}

	@IsTest
	static void testButtonSOApprovalAcceptSystemsAdmin() {
		createTestData();

		salesOrder.Submitted_By__c = systemAdminUser.Id;
		update salesOrder;

		Test.startTest();
		System.runAs(systemAdminUser) {
			// Create an approval request for the account
			Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
			req1.setComments('Submitting request for approval.');
			req1.setObjectId(salesOrder.Id);

			// Submit on behalf of a specific submitter
			req1.setSubmitterId(systemAdminUser.Id);

			// Submit the record to specific process and skip the criteria evaluation
			req1.setProcessDefinitionNameOrId('Inventory_ARM_Pricing_Approval_Process');
			req1.setSkipEntryCriteria(true);

			// Submit the approval request for the account
			Approval.process(req1);
			Approval.lock(salesOrder.Id);

			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(soID);
		}

		System.runAs(systemAdminUser) {
			ButtonSOApprovalAccept button = new ButtonSOApprovalAccept();
			button.performAction(soID);
		}
		Test.stopTest();
	}

	@IsTest
	static void testButtonSOApprovalAcceptSystemsAdminValidation() {
		createTestData();

		Test.startTest();
		System.runAs(standardUser) {
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(soID);

			ButtonSOApprovalAccept button = new ButtonSOApprovalAccept();
			button.performAction(soID);
		}
		Test.stopTest();
	}

	@IsTest
	static void testButtonSOApprovalAcceptSystemsAdminValidationNoProcess() {
		createTestData();

		salesOrder.Inventory_Approval__c = '';
		salesOrder.Approval_Custom_Button__c = false;
		update salesOrder;

		Test.startTest();
		System.runAs(standardUser) {
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(soID);

			ButtonSOApprovalAccept button = new ButtonSOApprovalAccept();
			button.performAction(soID);
		}
		Test.stopTest();
	}

	@IsTest
	static void testButtonSOApprovalAcceptSystemsAdminValidationAccept() {
		createTestData();

		Test.startTest();
		System.runAs(standardUser) {
			// Create an approval request for the account
			Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
			req1.setComments('Submitting request for approval.');
			req1.setObjectId(salesOrder.Id);

			// Submit on behalf of a specific submitter
			req1.setSubmitterId(standardUser.Id);

			// Submit the record to specific process and skip the criteria evaluation
			req1.setProcessDefinitionNameOrId('Inventory_ARM_Pricing_Approval_Process');
			req1.setSkipEntryCriteria(true);

			// Submit the approval request for the account
			Approval.process(req1);
			Approval.lock(salesOrder.Id);

			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(soID);
		}

		System.runAs(standardUser2) {
			ButtonSOApprovalAccept button = new ButtonSOApprovalAccept();
			button.performAction(soID);
		}
		Test.stopTest();
	}
}
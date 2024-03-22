@IsTest
private class ButtonSOApprovalRejectTest {

	@TestSetup
	static void testSetup() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Profile p0 = [SELECT Id FROM Profile WHERE Name IN ('S: Systems Administrator', 'Systeembeheerder') LIMIT 1];
		User u0 = new User(Alias = 'standta', Email = 'standardusear@testorg.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p0.Id,
				TimeZoneSidKey = 'America/Los_Angeles', Username = 'standamarkordusera1234@testorg.com');
		insert u0;

		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
		User u1 = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p.Id, ManagerId = u0.Id,
				TimeZoneSidKey = 'America/Los_Angeles', Username = 'standamarkorduser1234@testorg.com');
		insert u1;
		User u2 = new User(Alias = 'standtar', Email = 'standardusfer@testorg.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p.Id, ManagerId = u0.Id,
				TimeZoneSidKey = 'America/Los_Angeles', Username = 'standamarkorduaser1234@testorg.com');
		insert u2;
		Group g1 = new Group(Name = 'Commercial Director Approval', Type = 'Queue');
		insert g1;
		System.runAs(u0){
			GroupMember gm = new GroupMember(GroupId = g1.Id, UserOrGroupId = u0.Id);
			insert gm;
		}
	}

	@IsTest
	static void testButtonSOApprovalReject() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		User u0 = [SELECT Id FROM User WHERE Username = 'standamarkorduser1234@testorg.com'];

		CSSX__No_Triggers__c notriggers = (CSSX__No_Triggers__c) CSSX__No_Triggers__c.getInstance();
		notriggers.cssx__Flag__c = true;
		insert notriggers;

		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		Opportunity o = opps[0];
		update o;

		csmso__Sales_Order__c salesOrder;
		salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = o.Id;
		salesOrder.isTestRunning__c = true;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.csmso__Advertiser__c = accs[0].Id;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.Billing_Calendar__c = 'Standard';
		salesOrder.csmso__Booking_Contact__c = cons[0].Id;
		salesOrder.Paper_Type__c = 'Spotify Paper';
		salesOrder.csmso__Purchase_Order_Number__c = '1234';
		salesOrder.Bill_To_Account__c = accs[0].Id;
		salesOrder.Inventory_Approval__c = 'Pending';
		salesOrder.Approval_Custom_Button__c = true;
		salesOrder.Comments__c = 'Rejected';
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		Test.startTest() ;
		System.runAs(u0) {
			// Create an approval request for the account
			Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
			req1.setComments('Submitting request for approval.');
			req1.setObjectId(salesOrder.Id);

			// Submit on behalf of a specific submitter
			req1.setSubmitterId(u0.Id);

			// Submit the record to specific process and skip the criteria evaluation
			req1.setProcessDefinitionNameOrId('Inventory_ARM_Pricing_Approval_Process');
			req1.setSkipEntryCriteria(true);

			// Submit the approval request for the account
			Approval.ProcessResult result = Approval.process(req1);
			Approval.lock(salesOrder.Id);
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(salesOrder.Id);
		}
		System.runAs(u0) {
			salesOrder = [SELECT Id, Comments__c, csmso__Status__c FROM csmso__Sales_Order__c WHERE Id = :salesOrder.Id];
			ButtonSOApprovalReject button = new ButtonSOApprovalReject();
			button.performAction(salesOrder.Id);
			button.performAction(salesOrder.Id);
		}
		Test.stopTest();
	}

	@IsTest
	static void testButtonSOApprovalReject_Negative() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		User u0 = [SELECT Id FROM User WHERE Username = 'standamarkorduser1234@testorg.com'];
		User u1 = [SELECT Id FROM User WHERE Username = 'standamarkorduser1234@testorg.com'];
		User u2 = [SELECT Id FROM User WHERE Username = 'standamarkordusera1234@testorg.com'];

		csmso__Sales_Order__c salesOrder;
		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		Opportunity o = opps[0];
		update o;

		salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = o.Id;
		salesOrder.isTestRunning__c = true;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.Approval_Inventory_Required__c = true;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		Test.startTest() ;
		System.runAs(u1) {
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(salesOrder.Id);
		}

		System.runAs(u0) {
			salesOrder.Comments__c = 'test';
			update salesOrder;
			ButtonSOApprovalReject button = new ButtonSOApprovalReject();
			button.performAction(salesOrder.Id);
			button.performAction(salesOrder.Id);
		}

		System.runAs(u1) {
			salesOrder.Comments__c = '';
			update salesOrder;
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(salesOrder.Id);
			button1.performAction(salesOrder.Id);
		}

		System.runAs(u2) {
			ButtonSOApprovalReject button = new ButtonSOApprovalReject();
			button.performAction(salesOrder.Id);
		}
		Test.stopTest();
	}

	@IsTest static void testButtonSOApprovalRejectSystemsAdmin() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		User u0 = [SELECT Id FROM User WHERE Username = 'standamarkorduser1234@testorg.com'];
		User u1 = [SELECT Id FROM User WHERE Username = 'standamarkorduser1234@testorg.com'];
		User u2 = [SELECT Id FROM User WHERE Username = 'standamarkordusera1234@testorg.com'];

		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		Opportunity o = opps[0];
		update o;

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = o.Id;
		salesOrder.isTestRunning__c = true;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		Test.startTest();
		System.runAs(u1) {
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(salesOrder.Id);
		}

		System.runAs(u0) {
			salesOrder.Comments__c = 'test';
			update salesOrder;
			ButtonSOApprovalReject button = new ButtonSOApprovalReject();
			button.performAction(salesOrder.Id);
			button.performAction(salesOrder.Id);
		}

		System.runAs(u1) {
			salesOrder.Comments__c = '';
			update salesOrder;
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(salesOrder.Id);
			button1.performAction(salesOrder.Id);
		}

		System.runAs(u2) {
			ButtonSOApprovalReject button = new ButtonSOApprovalReject();
			button.performAction(salesOrder.Id);
		}
		Test.stopTest();
	}

	@IsTest
	static void testButtonSOApprovalRejectValidation() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		User u1 = [SELECT Id FROM User WHERE Username = 'standamarkorduaser1234@testorg.com'];

		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		Opportunity o = opps[0];
		update o;

		csmso__Sales_Order__c salesOrder;
		salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = o.Id;
		salesOrder.isTestRunning__c = true;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.csmso__Opportunity__c = o.Id;
		salesOrder.isTestRunning__c = true;
		salesOrder.csmso__Advertiser__c = accs[0].Id;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.Billing_Calendar__c = 'Standard';
		salesOrder.csmso__Booking_Contact__c = cons[0].Id;
		salesOrder.Paper_Type__c = 'Spotify Paper';
		salesOrder.csmso__Purchase_Order_Number__c = '1234';
		salesOrder.Bill_To_Account__c = accs[0].Id;
		salesOrder.Approval_Inventory_Required__c = true;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		Test.startTest() ;
		System.runAs(u1) {
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(salesOrder.Id);
		}
		Test.stopTest();
	}

	@IsTest
	static void testButtonSOApprovalRejectValidationNegative() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		User u1 = [SELECT Id FROM User WHERE Username = 'standamarkorduaser1234@testorg.com'];

		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		Opportunity o = opps[0];
		update o;

		csmso__Sales_Order__c salesOrder;
		salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = o.Id;
		salesOrder.isTestRunning__c = true;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.csmso__Opportunity__c = o.Id;
		salesOrder.isTestRunning__c = true;
		salesOrder.csmso__Advertiser__c = accs[0].Id;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.Billing_Calendar__c = 'Standard';
		salesOrder.csmso__Booking_Contact__c = cons[0].Id;
		salesOrder.Paper_Type__c = 'Spotify Paper';
		salesOrder.csmso__Purchase_Order_Number__c = '1234';
		salesOrder.Bill_To_Account__c = accs[0].Id;
		salesOrder.Approval_Inventory_Required__c = true;
		salesOrder.Comments__c = 'Rejected';
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		Test.startTest() ;
		System.runAs(u1) {
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(salesOrder.Id);
		}
		Test.stopTest();
	}

	@isTest
	static void testButtonSOApprovalRejectValidationSuccess() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs,cons);
		Opportunity o = opps[0];

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_FIRST_APPROVAL;
		salesOrder.csmso__Opportunity__c = o.id;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.Comments__c = 'Comment';
		salesOrder.Inventory_Approval__c = 'Pending';
		salesOrder.Approval_Custom_Button__c = true;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		// Create an approval request for the account
		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setComments('Submitting request for approval.');
		req1.setObjectId(salesOrder.Id);

		// Submit on behalf of a specific submitter
		req1.setSubmitterId(UserInfo.getUserId());

		// Submit the record to specific process and skip the criteria evaluation
		req1.setProcessDefinitionNameOrId('Inventory_ARM_Pricing_Approval_Process');
		req1.setSkipEntryCriteria(true);

		// Submit the approval request for the account
		Approval.ProcessResult result = Approval.process(req1);

		Approval.lock(salesOrder.Id);

		Test.startTest();
		ButtonSOApprovalReject button = new ButtonSOApprovalReject();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void testButtonSOApprovalRejectNoComment() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		User u0 = [SELECT Id FROM User WHERE Username = 'standamarkorduser1234@testorg.com'];

		CSSX__No_Triggers__c notriggers = (CSSX__No_Triggers__c) CSSX__No_Triggers__c.getInstance();
		notriggers.cssx__Flag__c = true;
		insert notriggers;

		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		Opportunity o = opps[0];
		update o;

		csmso__Sales_Order__c salesOrder;
		salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = o.Id;
		salesOrder.isTestRunning__c = true;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.csmso__Advertiser__c = accs[0].Id;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.Billing_Calendar__c = 'Standard';
		salesOrder.csmso__Booking_Contact__c = cons[0].Id;
		salesOrder.Paper_Type__c = 'Spotify Paper';
		salesOrder.csmso__Purchase_Order_Number__c = '1234';
		salesOrder.Bill_To_Account__c = accs[0].Id;
		salesOrder.Inventory_Approval__c = 'Pending';
		salesOrder.Approval_Custom_Button__c = true;
		salesOrder.Comments__c = '';
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		Test.startTest() ;
		System.runAs(u0) {
			// Create an approval request for the account
			Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
			req1.setComments('Submitting request for approval.');
			req1.setObjectId(salesOrder.Id);

			// Submit on behalf of a specific submitter
			req1.setSubmitterId(u0.Id);

			// Submit the record to specific process and skip the criteria evaluation
			req1.setProcessDefinitionNameOrId('Inventory_ARM_Pricing_Approval_Process');
			req1.setSkipEntryCriteria(true);

			// Submit the approval request for the account
			Approval.ProcessResult result = Approval.process(req1);
			Approval.lock(salesOrder.Id);
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(salesOrder.Id);
		}
		System.runAs(u0) {
			salesOrder = [SELECT Id, Comments__c, csmso__Status__c FROM csmso__Sales_Order__c WHERE Id = :salesOrder.Id];
			ButtonSOApprovalReject button = new ButtonSOApprovalReject();
			button.performAction(salesOrder.Id);
			button.performAction(salesOrder.Id);
		}
		Test.stopTest();
	}

	@IsTest
	static void testButtonSOApprovalRejectNotInApproval() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		User u0 = [SELECT Id FROM User WHERE Username = 'standamarkorduser1234@testorg.com'];

		CSSX__No_Triggers__c notriggers = (CSSX__No_Triggers__c) CSSX__No_Triggers__c.getInstance();
		notriggers.cssx__Flag__c = true;
		insert notriggers;

		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		Opportunity o = opps[0];
		update o;

		csmso__Sales_Order__c salesOrder;
		salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = o.Id;
		salesOrder.isTestRunning__c = true;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.csmso__Advertiser__c = accs[0].Id;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.Billing_Calendar__c = 'Standard';
		salesOrder.csmso__Booking_Contact__c = cons[0].Id;
		salesOrder.Paper_Type__c = 'Spotify Paper';
		salesOrder.csmso__Purchase_Order_Number__c = '1234';
		salesOrder.Bill_To_Account__c = accs[0].Id;
		salesOrder.Inventory_Approval__c = 'Pending';
		salesOrder.Approval_Custom_Button__c = true;
		salesOrder.Comments__c = '';
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		Test.startTest() ;
		System.runAs(u0) {
			// Create an approval request for the account
			Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
			req1.setComments('Submitting request for approval.');
			req1.setObjectId(salesOrder.Id);

			// Submit on behalf of a specific submitter
			req1.setSubmitterId(u0.Id);

			// Submit the record to specific process and skip the criteria evaluation
			req1.setProcessDefinitionNameOrId('Inventory_ARM_Pricing_Approval_Process');
			req1.setSkipEntryCriteria(true);

			// Submit the approval request for the account
			Approval.ProcessResult result = Approval.process(req1);
		}
		System.runAs(u0) {
			salesOrder = [SELECT Id, Comments__c, csmso__Status__c FROM csmso__Sales_Order__c WHERE Id = :salesOrder.Id];
			ButtonSOApprovalReject button = new ButtonSOApprovalReject();
			button.performAction(salesOrder.Id);
			button.performAction(salesOrder.Id);
		}
		Test.stopTest();
	}

	@IsTest
	static void testButtonSOApprovalRejectCantBeRejectedByCurrentUser() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		User u1 = [SELECT Id FROM User WHERE Username = 'standamarkorduser1234@testorg.com'];

		CSSX__No_Triggers__c notriggers = (CSSX__No_Triggers__c) CSSX__No_Triggers__c.getInstance();
		notriggers.cssx__Flag__c = true;
		insert notriggers;

		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		Opportunity o = opps[0];
		update o;

		csmso__Sales_Order__c salesOrder;
		salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = o.Id;
		salesOrder.isTestRunning__c = true;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.csmso__Advertiser__c = accs[0].Id;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.Billing_Calendar__c = 'Standard';
		salesOrder.csmso__Booking_Contact__c = cons[0].Id;
		salesOrder.Paper_Type__c = 'Spotify Paper';
		salesOrder.csmso__Purchase_Order_Number__c = '1234';
		salesOrder.Bill_To_Account__c = accs[0].Id;
		salesOrder.Inventory_Approval__c = 'Pending';
		salesOrder.Approval_Custom_Button__c = true;
		salesOrder.Comments__c = 'Rejected';
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		Test.startTest() ;
		System.runAs(u1) {
			// Create an approval request for the account
			Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
			req1.setComments('Submitting request for approval.');
			req1.setObjectId(salesOrder.Id);

			// Submit on behalf of a specific submitter
			req1.setSubmitterId(u1.Id);

			// Submit the record to specific process and skip the criteria evaluation
			req1.setProcessDefinitionNameOrId('Inventory_ARM_Pricing_Approval_Process');
			req1.setSkipEntryCriteria(true);

			// Submit the approval request for the account
			Approval.ProcessResult result = Approval.process(req1);
			Approval.lock(salesOrder.Id);
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(salesOrder.Id);
		}
		System.runAs(u1) {
			salesOrder = [SELECT Id, Comments__c, csmso__Status__c FROM csmso__Sales_Order__c WHERE Id = :salesOrder.Id];
			ButtonSOApprovalReject button = new ButtonSOApprovalReject();
			button.performAction(salesOrder.Id);
			button.performAction(salesOrder.Id);
		}
		Test.stopTest();
	}
}
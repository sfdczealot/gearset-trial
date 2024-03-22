@IsTest
private class ButtonSOApprovalRecallTest {

	@IsTest
	static void testButtonSORecallAccept() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Profile p0 = [SELECT Id FROM Profile WHERE Name IN ('System Administrator', 'Systeembeheerder') LIMIT 1];
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

		String soID;
		Account[] accs = TestDataSetupBasic.createAccountForB2B(1);
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

		soID = salesOrder.Id;

		Test.startTest() ;
		System.runAs(u1) {
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(soID);
		}

		System.runAs(u0) {
			ButtonSOApprovalRecall button = new ButtonSOApprovalRecall();
			button.performAction(soID);
			button.performAction(soID);
		}

		System.runAs(u1) {
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(soID);
		}

		System.runAs(u2) {
			ButtonSOApprovalRecall button = new ButtonSOApprovalRecall();
			button.performAction(soID);
		}
		Test.stopTest();
	}

	@IsTest
	static void testButtonSORecallAcceptFull() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Profile p0 = [SELECT Id FROM Profile WHERE Name IN ('System Administrator', 'Systeembeheerder') LIMIT 1];
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

		String soID;
		Account [] accs = TestDataSetupBasic.createAccountForB2B(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		Opportunity o = opps[0];
		update o;

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = o.Id;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.Inventory_Approval__c = 'Pending';
		salesOrder.Approval_Custom_Button__c = true;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_FIRST_APPROVAL;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		soID = salesOrder.Id;

		// Create an approval request for the account
		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setComments('Submitting request for approval.');
		req1.setObjectId(soID);

		// Submit on behalf of a specific submitter
		req1.setSubmitterId(u1.Id);

		// Submit the record to specific process and skip the criteria evaluation
		req1.setProcessDefinitionNameOrId('Inventory_ARM_Pricing_Approval_Process');
		req1.setSkipEntryCriteria(true);

		// Submit the approval request for the account
		Approval.ProcessResult result = Approval.process(req1);

		System.runAs(u1) {
			Test.startTest();
			Approval.lock(soID);
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(soID);
		}

		System.runAs(u0) {
			ButtonSOApprovalRecall button = new ButtonSOApprovalRecall();
			button.performAction(soID);
		}

		System.runAs(u1) {
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(soID);
		}

		Test.stopTest();
	}

	@IsTest
	static void testButtonSORecallAcceptSystemsAdmin() {
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

		String soID;
		Account[] accs = TestDataSetupBasic.createAccountForB2B(1);
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

		soID = salesOrder.Id;

		Test.startTest();
		System.runAs(u1) {
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(soID);
		}

		System.runAs(u0) {
			ButtonSOApprovalRecall button = new ButtonSOApprovalRecall();
			button.performAction(soID);
			button.performAction(soID);
		}

		System.runAs(u1) {
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(soID);
		}

		System.runAs(u2) {
			ButtonSOApprovalRecall button = new ButtonSOApprovalRecall();
			button.performAction(soID);
		}
		Test.stopTest();
	}

	@IsTest
	static void testButtonSORecallAcceptNotSubmitter() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Profile p0 = [SELECT Id FROM Profile WHERE Name IN ('System Administrator', 'Systeembeheerder') LIMIT 1];
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

		String soID;
		Account[] accs = TestDataSetupBasic.createAccountForB2B(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		Opportunity o = opps[0];
		update o;

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = o.Id;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.Inventory_Approval__c = 'Pending';
		salesOrder.Approval_Custom_Button__c = true;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_FIRST_APPROVAL;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		soID = salesOrder.Id;

		// Create an approval request for the account
		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setComments('Submitting request for approval.');
		req1.setObjectId(soID);

		// Submit on behalf of a specific submitter
		req1.setSubmitterId(u1.Id);

		// Submit the record to specific process and skip the criteria evaluation
		req1.setProcessDefinitionNameOrId('Inventory_ARM_Pricing_Approval_Process');
		req1.setSkipEntryCriteria(true);

		// Submit the approval request for the account
		Approval.ProcessResult result = Approval.process(req1);

		System.runAs(u0) {
			Test.startTest();
			Approval.lock(soID);
			ButtonSOApprovalStart button1 = new ButtonSOApprovalStart();
			button1.performAction(soID);
		}

		System.runAs(u1) {
			ButtonSOApprovalRecall button = new ButtonSOApprovalRecall();
			button.performAction(soID);
		}

		Test.stopTest();
	}
}
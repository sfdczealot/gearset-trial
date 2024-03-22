@IsTest
private class CS_P_CustomerApprovalStatusChangedTest {
	private static CSCAP__Customer_Approval__c customerApproval;

	private static void createTestData() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Account agency = TestDataSetupTargetables.createAccount();
		agency.Type = 'Media Agency';
		insert agency;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opportunity = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opportunity;

		csmso__Sales_Order__c salesOrder = TestDataSetupTargetables.createSalesOrder(acc, opportunity);
		salesOrder.csmso__Status__c = 'Draft';
		insert salesOrder;

		customerApproval = new CSCAP__Customer_Approval__c();
		customerApproval.CSCAP__Opportunity__c = opportunity.Id;
		insert customerApproval;
	}

	@IsTest
	static void testCustomerApprovalStatusChangedApproved() {
		createTestData();

		CSCAP__Customer_Approval__c oldCustomerApproval = [
				SELECT
						Id,
						CSCAP__Approved_By_Customer__c,
						CSCAP__Rejected_By_Customer__c,
						CSCAP__Opportunity__c
				FROM CSCAP__Customer_Approval__c
				WHERE Id = :customerApproval.Id
		];

		customerApproval.CSCAP__Approved_By_Customer__c = true;
		update customerApproval;

		customerApproval = [
				SELECT
						Id,
						CSCAP__Approved_By_Customer__c,
						CSCAP__Rejected_By_Customer__c,
						CSCAP__Opportunity__c
				FROM CSCAP__Customer_Approval__c
				WHERE Id = :customerApproval.Id
		];

		Test.startTest();
		CS_P_CustomerApprovalStatusChanged customerApprovalStatusChanged = new CS_P_CustomerApprovalStatusChanged(new Map<Id, CSCAP__Customer_Approval__c>{
				oldCustomerApproval.Id => oldCustomerApproval
		});
		customerApprovalStatusChanged.isRecordEligible((CSCAP__Customer_Approval__c) customerApproval);
		customerApprovalStatusChanged.logic();
		Test.stopTest();

		Opportunity afterUpdateOpp = [SELECT Id, Agreement_Status__c FROM Opportunity WHERE Id = :customerApproval.CSCAP__Opportunity__c];
		System.assertEquals(afterUpdateOpp.Agreement_Status__c, 'Signed via Client IO Link');
	}

	@IsTest
	static void testCustomerApprovalStatusChangedRejected() {
		createTestData();

		CSCAP__Customer_Approval__c oldCustomerApproval = [
				SELECT
						Id,
						CSCAP__Approved_By_Customer__c,
						CSCAP__Rejected_By_Customer__c,
						CSCAP__Opportunity__c
				FROM CSCAP__Customer_Approval__c
				WHERE Id = :customerApproval.Id
		];

		customerApproval.CSCAP__Rejected_By_Customer__c = true;
		update customerApproval;

		customerApproval = [
				SELECT
						Id,
						CSCAP__Approved_By_Customer__c,
						CSCAP__Rejected_By_Customer__c,
						CSCAP__Opportunity__c
				FROM CSCAP__Customer_Approval__c
				WHERE Id = :customerApproval.Id
		];

		Test.startTest();
		CS_P_CustomerApprovalStatusChanged customerApprovalStatusChanged = new CS_P_CustomerApprovalStatusChanged(new Map<Id, CSCAP__Customer_Approval__c>{
				oldCustomerApproval.Id => oldCustomerApproval
		});
		customerApprovalStatusChanged.isRecordEligible((CSCAP__Customer_Approval__c) customerApproval);
		customerApprovalStatusChanged.logic();
		Test.stopTest();

		Opportunity afterUpdateOpp = [SELECT Id, Agreement_Status__c FROM Opportunity WHERE Id = :customerApproval.CSCAP__Opportunity__c];
		System.assertEquals(afterUpdateOpp.Agreement_Status__c, 'Cancelled / Declined');
	}

	@IsTest
	static void testCustomerApprovalStatusChangedFalse() {
		createTestData();

		customerApproval.CSCAP__Approved_By_Customer__c = true;
		update customerApproval;

		CSCAP__Customer_Approval__c oldCustomerApproval = [
				SELECT
						Id,
						CSCAP__Approved_By_Customer__c,
						CSCAP__Rejected_By_Customer__c,
						CSCAP__Opportunity__c
				FROM CSCAP__Customer_Approval__c
				WHERE Id = :customerApproval.Id
		];

		customerApproval.CSCAP__Approved_By_Customer__c = false;
		update customerApproval;

		customerApproval = [
				SELECT
						Id,
						CSCAP__Approved_By_Customer__c,
						CSCAP__Rejected_By_Customer__c,
						CSCAP__Opportunity__c
				FROM CSCAP__Customer_Approval__c
				WHERE Id = :customerApproval.Id
		];

		Test.startTest();
		CS_P_CustomerApprovalStatusChanged customerApprovalStatusChanged = new CS_P_CustomerApprovalStatusChanged(new Map<Id, CSCAP__Customer_Approval__c>{
				oldCustomerApproval.Id => oldCustomerApproval
		});
		customerApprovalStatusChanged.isRecordEligible((CSCAP__Customer_Approval__c) customerApproval);
		customerApprovalStatusChanged.logic();
		Test.stopTest();

		Opportunity afterUpdateOpp = [SELECT Id, Agreement_Status__c FROM Opportunity WHERE Id = :customerApproval.CSCAP__Opportunity__c];
		System.assertEquals(afterUpdateOpp.Agreement_Status__c, null);
	}
}
@IsTest
private class CS_OppCustomerApprovalControllerTest {
	private static Opportunity opp;
	private static csmso__Sales_Order__c so;

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
             acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
		acc.NetSuite_Id__c = 'CUSTOMER APPROVAL TEST CONTACT ID';
        
        
        acc.Phone = '2345';
		insert acc;
        Account childAcc = TestDataSetupTargetables.createAccount();
        childAcc.name='child acc';
        childAcc.Tax_Reg_Number__c ='tyg';
        childAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        childAcc.NetSuite_Id__c = 'CUSTOMED';
        childAcc.ParentId = acc.id;

        childAcc.Phone = '2345';
        insert childAcc;
		Account agency = TestDataSetupTargetables.createAccount();
		agency.Type = 'Media Agency';
        agency.Phone = '2345';
		insert agency;

		Contact con = TestDataSetupTargetables.createContact(acc);
		con.NetSuite_Id__c = 'TEST CONTACT ID'; //CUSTOM VALIDATION ON CONTACT ROLES
		insert con;

		opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
		opp.Re_print_Contract__c = false;
        opp.Product_category__c='Discretionary';
        opp.billing_entity__c = childAcc.id;
        opp.Subsidiary_Type__c = 'iPP';
		insert opp;

		so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		so.csmso__Status__c = 'Ready For Customer Approval';
		insert so;
	}

	private static void createOppContactRoles() {
		Contact con = [SELECT Id FROM Contact LIMIT 1];

		List<OpportunityContactRole> oppContactRoles = new List<OpportunityContactRole>{
				new OpportunityContactRole(ContactId= con.Id,Role = CS_OppCustomerApprovalController.BILLING_CONTACT,IsPrimary=true,OpportunityId = opp.Id),
				new OpportunityContactRole(ContactId= con.Id,Role = CS_OppCustomerApprovalController.CLIENT_SIGNATORY, OpportunityId = opp.Id)
		};

		insert oppContactRoles;
	}

	@IsTest
	static void testOppCustomerApprovalControllerClickApprove() {
		createTestData();
		createOppContactRoles();
		opp.StageName = 'Negotiating';
		opp.SO_for_Customer_Approval__c = so.Id;
		update opp;

		Test.startTest();
		ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
		ApexPages.currentPage().getParameters().put('oppId', opp.Id);
		ApexPages.currentPage().getParameters().put('buttonClicked', 'Send_Approval_ClickApprove');

		CS_OppCustomerApprovalController oppCustomerApprovalController = new CS_OppCustomerApprovalController(stdController);
		PageReference pageReference = oppCustomerApprovalController.doAction();

		System.assertEquals(pageReference.getUrl(), '/apex/CSCAP__SendFormalEmailForApproval_LE?Id=' + opp.Id);
		Test.stopTest();
	}

	@IsTest
	static void testOppCustomerApprovalControllerManual() {
		createTestData();
		createOppContactRoles();
		opp.StageName = 'Negotiating';
		opp.SO_for_Customer_Approval__c = so.Id;
		update opp;

		Test.startTest();
		ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
		ApexPages.currentPage().getParameters().put('oppId', opp.Id);
		ApexPages.currentPage().getParameters().put('buttonClicked', 'Send_Approval_Manual');

		CS_OppCustomerApprovalController oppCustomerApprovalController = new CS_OppCustomerApprovalController(stdController);
		PageReference pageReference = oppCustomerApprovalController.doAction();

		System.assertEquals(pageReference, null);
		Test.stopTest();
	}

	@IsTest
	static void testOppCustomerApprovalControllerWrongStatus() {
		createTestData();

		Test.startTest();
		ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
		ApexPages.currentPage().getParameters().put('oppId', opp.Id);
		ApexPages.currentPage().getParameters().put('buttonClicked', 'Send_Approval_ClickApprove');

		CS_OppCustomerApprovalController oppCustomerApprovalController = new CS_OppCustomerApprovalController(stdController);
		PageReference pageReference = oppCustomerApprovalController.doAction();

		System.assertEquals(pageReference, null);
		Test.stopTest();
	}
}
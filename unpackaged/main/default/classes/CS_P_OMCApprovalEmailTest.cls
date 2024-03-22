@IsTest
private class CS_P_OMCApprovalEmailTest {
	private static Opportunity opportunity;
	private static csmso__Sales_Order__c salesOrder;

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

		opportunity = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opportunity;

		salesOrder = TestDataSetupTargetables.createSalesOrder(acc, opportunity);
		salesOrder.csmso__Status__c = CS_const_SalesOrder.Status_Draft;
		insert salesOrder;

		Subsidiary__c subsidiarySingapore = new Subsidiary__c();
		subsidiarySingapore.Name = 'PropertyGuru Pte Ltd';
		subsidiarySingapore.Tax_Label__c = 'GST';
		subsidiarySingapore.CurrencyIsoCode = 'SGD';
		subsidiarySingapore.Country__c = 'Singapore';
		subsidiarySingapore.Subsidiary_Code__c = 'PG SG';
		insert subsidiarySingapore;

		opportunity.Subsidiary__c = subsidiarySingapore.Id;
		opportunity.Primary_Sales_Order__c = salesOrder.Id;
		update opportunity;
	}

	@IsTest
	static void testCustomerApprovalStatusChangedApproved() {
		createTestData();

		csmso__Sales_Order__c oldSalesOrder = [
				SELECT
						Id,
						OwnerId,
						csmso__Status__c,
						Primary_Sales_Order__c,
						csmso__Opportunity__c,
						csmso__Opportunity__r.Subsidiary__r.Subsidiary_Code__c
				FROM csmso__Sales_Order__c
				WHERE Id = :salesOrder.Id
		];

		salesOrder.csmso__Status__c = CS_const_SalesOrder.Status_PendingOMCApproval;
		update salesOrder;

		salesOrder = [
				SELECT
						Id,
						OwnerId,
						csmso__Status__c,
						Primary_Sales_Order__c,
						csmso__Opportunity__c,
						csmso__Opportunity__r.Subsidiary__r.Subsidiary_Code__c
				FROM csmso__Sales_Order__c
		];

		Test.startTest();
		CS_P_OMCApprovalEmail omcApprovalEmail = new CS_P_OMCApprovalEmail(new Map<Id, csmso__Sales_Order__c>{oldSalesOrder.Id => oldSalesOrder});
		omcApprovalEmail.isRecordEligible((SObject) salesOrder);
		omcApprovalEmail.logic();
		omcApprovalEmail.salesOrder = salesOrder;
		Test.stopTest();

		System.assertEquals(omcApprovalEmail.applicableObjects.isEmpty(), false);
	}
}
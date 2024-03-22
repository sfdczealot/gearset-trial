@IsTest
private class CS_P_PrimarySOInProgressOppQualifiedTest {
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
		salesOrder.csmso__Status__c = 'Draft';
		insert salesOrder;

		opportunity.Primary_Sales_Order__c = salesOrder.Id;
		update opportunity;
	}

	@IsTest
	static void testPrimarySOInProgressOppQualified() {
		createTestData();

		csmso__Sales_Order__c oldSalesOrder = [
				SELECT
						Id,
						csmso__Status__c,
						Primary_Sales_Order__c,
						csmso__Opportunity__c
				FROM csmso__Sales_Order__c
				WHERE Id = :salesOrder.Id
		];

		salesOrder.csmso__Status__c = CS_const_SalesOrder.Status_InProgress;
		update salesOrder;

		salesOrder = [
				SELECT
						Id,
						csmso__Status__c,
						Primary_Sales_Order__c,
						csmso__Opportunity__c
				FROM csmso__Sales_Order__c
		];

		Test.startTest();
		CS_P_PrimarySOInProgressOppQualified primarySOInProgressOppQualified = new CS_P_PrimarySOInProgressOppQualified(new Map<Id, csmso__Sales_Order__c>{oldSalesOrder.Id => oldSalesOrder});
		primarySOInProgressOppQualified.isRecordEligible((SObject) salesOrder);
		primarySOInProgressOppQualified.logic();
		Test.stopTest();

		System.assertEquals(primarySOInProgressOppQualified.applicableObjects.isEmpty(), false);

		Opportunity afterUpdateOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :salesOrder.csmso__Opportunity__c];
		System.assertEquals(afterUpdateOpp.StageName, 'Qualifying');
	}
}
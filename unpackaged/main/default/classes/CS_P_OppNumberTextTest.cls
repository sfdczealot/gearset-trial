@IsTest
private class CS_P_OppNumberTextTest {
	private static Opportunity opp;

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
		insert agency;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		opp = TestDataSetupTargetables.createOpportunity(acc, con);
	}

	@IsTest
	static void testOppNumberTextTest() {
		createTestData();

		Test.startTest();
		insert opp;

		opp = [
				SELECT Id,
						Opportunity_Number__c,
						Opportunity_Number_Text__c
				FROM Opportunity
				LIMIT 1
		];

		//System.assertEquals(opp.Opportunity_Number__c, opp.Opportunity_Number_Text__c);
		Test.stopTest();
	}
}
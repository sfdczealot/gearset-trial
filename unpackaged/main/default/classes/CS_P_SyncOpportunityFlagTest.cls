@IsTest
private class CS_P_SyncOpportunityFlagTest {
	private static cscfga__Product_Configuration__c prodConfig;

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
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();


		Account acc = TestDataSetupTargetables.createAccount();
        acc.recordtypeid = accRectype;
        
        
        acc.Phone = '2345';
		insert acc;

		Account agency = TestDataSetupTargetables.createAccount();
		agency.Type = 'Media Agency';
		insert agency;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opportunity = TestDataSetupTargetables.createOpportunity(acc, con);
        opportunity.Subsidiary_Type__c = 'iPP';
		insert opportunity;

		csmso__Sales_Order__c salesOrder = TestDataSetupTargetables.createSalesOrder(acc, opportunity);
		salesOrder.csmso__Status__c = 'In Progress';
		salesOrder.Sold__c = false;
		salesOrder.Synchronized_with_Opportunity__c = true;
		insert salesOrder;

		opportunity.Primary_Sales_Order__c = salesOrder.Id;
		update opportunity;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
		insert prodBasket;

		prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Ad_Type__c = 'Standard';
		prodConfig.Fulfilment_Item_Status__c = 'Draft';
		prodConfig.csmso__Flight_End__c = Date.today().addDays(4);
		prodConfig.Sales_Order__c = salesOrder.Id;
		insert prodConfig;
	}

	@IsTest
	static void testSyncOpportunityFlag() {
		createTestData();

		Test.startTest();
		CS_P_SyncOpportunityFlag syncOpportunityFlag = new CS_P_SyncOpportunityFlag();
		syncOpportunityFlag.isRecordEligible((SObject) prodConfig);
		syncOpportunityFlag.logic();
		Test.stopTest();

		csmso__Sales_Order__c salesOrder = [
				SELECT
						Id,
						csmso__Status__c,
						Sold__c,
						Synchronized_with_Opportunity__c
				FROM csmso__Sales_Order__c
		];

		System.assertEquals(salesOrder.Synchronized_with_Opportunity__c, false);
	}
}
@IsTest
private class CS_P_PCCurrencyIsoCodeUpdateTest {
	private static csmso__Sales_Order__c salesOrder;
	private static cscfga__Product_Basket__c prodBasket;

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

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);

		salesOrder = TestDataSetupTargetables.createSalesOrder(acc, opp);
		salesOrder.SO_Lines_Gross_Total__c = 6;
		salesOrder.Flighting_Pending_Check_Avail__c = false;
		salesOrder.SO_Lines_All_Valid__c = true;
		insert salesOrder;

		prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(salesOrder, acc);
		insert testFulfilment;
	}

	@IsTest
	static void testPCCurrencyIsoCodeUpdateSGD() {
		createTestData();

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Sales_Order__c = salesOrder.Id;
		prodConfig.CurrencyIsoCode = 'SGD';
		prodConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.Status_Draft;
		insert prodConfig;

		cscfga__Product_Configuration__c oldProdConfig = [
				SELECT Id,
						CurrencyIsoCode
				FROM cscfga__Product_Configuration__c
		];

		Test.startTest();
		prodConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.Status_InProgress;
		update prodConfig;

		CS_P_PCCurrencyIsoCodeUpdate pcCurrencyIsoCodeUpdate = new CS_P_PCCurrencyIsoCodeUpdate(new Map<Id, cscfga__Product_Configuration__c>{oldProdConfig.Id => oldProdConfig});
		pcCurrencyIsoCodeUpdate.isRecordEligible((SObject) prodConfig);
		pcCurrencyIsoCodeUpdate.logic();

		System.assertEquals(prodConfig.CurrencyIsoCode, 'SGD');
		Test.stopTest();
	}

	@IsTest
	static void testPCCurrencyIsoCodeUpdateMYR() {
		createTestData();

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Sales_Order__c = salesOrder.Id;
		prodConfig.CurrencyIsoCode = 'MYR';
		prodConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.Status_Draft;
		insert prodConfig;

		cscfga__Product_Configuration__c oldProdConfig = [
				SELECT Id,
						CurrencyIsoCode
				FROM cscfga__Product_Configuration__c
		];

		Test.startTest();
		prodConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.Status_InProgress;
		update prodConfig;

		CS_P_PCCurrencyIsoCodeUpdate pcCurrencyIsoCodeUpdate = new CS_P_PCCurrencyIsoCodeUpdate(new Map<Id, cscfga__Product_Configuration__c>{oldProdConfig.Id => oldProdConfig});
		pcCurrencyIsoCodeUpdate.isRecordEligible((SObject) prodConfig);
		pcCurrencyIsoCodeUpdate.logic();

		System.assertEquals(prodConfig.CurrencyIsoCode, 'MYR');
		Test.stopTest();
	}

	@IsTest
	static void testPCCurrencyIsoCodeUpdateNull() {
		createTestData();

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Sales_Order__c = salesOrder.Id;
		prodConfig.CurrencyIsoCode = null;
		prodConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.Status_Draft;
		insert prodConfig;

		cscfga__Product_Configuration__c oldProdConfig = [
				SELECT Id,
						CurrencyIsoCode
				FROM cscfga__Product_Configuration__c
		];

		Test.startTest();
		prodConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.Status_InProgress;
		update prodConfig;

		CS_P_PCCurrencyIsoCodeUpdate pcCurrencyIsoCodeUpdate = new CS_P_PCCurrencyIsoCodeUpdate(new Map<Id, cscfga__Product_Configuration__c>{oldProdConfig.Id => oldProdConfig});
		pcCurrencyIsoCodeUpdate.isRecordEligible((SObject) prodConfig);
		pcCurrencyIsoCodeUpdate.logic();

		System.assertEquals(prodConfig.CurrencyIsoCode, 'SGD');
		Test.stopTest();
	}
}
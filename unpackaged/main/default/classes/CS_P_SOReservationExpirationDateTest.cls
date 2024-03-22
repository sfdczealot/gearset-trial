@IsTest
private class CS_P_SOReservationExpirationDateTest {
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

		Opportunity opportunity = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opportunity;

		salesOrder = TestDataSetupTargetables.createSalesOrder(acc, opportunity);
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.Expiration_Date__c = null;
		insert salesOrder;

		opportunity.Primary_Sales_Order__c = salesOrder.Id;
		update opportunity;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(salesOrder, acc);
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Ad_Type__c = 'Standard';
		prodConfig.Fulfilment_Item_Status__c = 'Draft';
		prodConfig.csmso__Flight_End__c = Date.today().addDays(4);
		prodConfig.Sales_Order__c = salesOrder.Id;
		insert prodConfig;

		Map<Id, cscfga__Product_Configuration__c> configs = new Map<Id, cscfga__Product_Configuration__c>();
		configs.put(prodConfig.Id, prodConfig);

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, salesOrder, testFulfilment);
		testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
		insert testFulfilmentItem;
	}

	@IsTest
	static void testPrimarySOInProgressOppQualified() {
		createTestData();

		csmso__Sales_Order__c oldSalesOrder = [
				SELECT
						Id,
						csmso__Status__c,
						Expiration_Date__c,
						csmso__Sales_Order__c.Name
				FROM csmso__Sales_Order__c
				WHERE Id = :salesOrder.Id
		];

		salesOrder.Expiration_Date__c = Date.today().addDays(4);
		update salesOrder;

		salesOrder = [
				SELECT
						Id,
						csmso__Status__c,
						Expiration_Date__c,
						csmso__Sales_Order__c.Name
				FROM csmso__Sales_Order__c
		];

		Test.startTest();
		CS_P_SOReservationExpirationDate soReservationExpirationDate = new CS_P_SOReservationExpirationDate(new Map<Id, csmso__Sales_Order__c>{oldSalesOrder.Id => oldSalesOrder});
		soReservationExpirationDate.isRecordEligible((SObject) salesOrder);
		soReservationExpirationDate.logic();
		Test.stopTest();

		System.assertEquals(soReservationExpirationDate.applicableObjects.isEmpty(), false);

		csdf__Fulfilment_Item__c afterUpdateFI = [SELECT Id, Reserve_Expiration_Date__c FROM csdf__Fulfilment_Item__c WHERE Sales_Order__c = :salesOrder.Name];
		System.assertEquals(afterUpdateFI.Reserve_Expiration_Date__c, salesOrder.Expiration_Date__c);

		cscfga__Product_Configuration__c afterUpdatePC = [SELECT Id, Reserve_Expiration_Date__c FROM cscfga__Product_Configuration__c WHERE Sales_Order__c = :salesOrder.Id];
		System.assertEquals(afterUpdatePC.Reserve_Expiration_Date__c, salesOrder.Expiration_Date__c);
	}
}
@IsTest
private class ButtonSORequestAcceptanceTest {
	private static csmso__Sales_Order__c salesOrder;
	private static List<cscfga__Product_Configuration__c> prodConfigs;

	private static void createTestData() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();
		customSettings.Max_n_Templates_for_Sync_Execution__c = 5000;
		customSettings.Max_n_Lines_for_Sync_Execution__c = 50;
		customSettings.Integration_Chunk_Size__c = 10.0;
		customSettings.Integration_Delay_Between_Callouts__c = 300.0;
		update customSettings;

		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);

		salesOrder = new csmso__Sales_Order__c();
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_RESERVED;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.SO_Lines_Ad_Server_Items__c = 1;
		insert salesOrder;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				salesOrder
		});

		//Product Configs creation.
		prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);
		prodConfigs[0].Fulfilment_Item_Status__c = 'Inactive';
		prodConfigs[0].Served_By__c = 'DFP';
		prodConfigs[0].Reserve_Inventory__c = true;
		prodConfigs[0].Inventory_Available__c = 'Yes';
		prodConfigs[0].Reservation_Status__c = '';
		prodConfigs[0].Sales_Order__c = salesOrder.Id;
		update prodConfigs;

		List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1, new List<csmso__Sales_Order__c>{
				salesOrder
		}, accs);

		List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1, fulfilment, prodConfigs);
		fulfilmentItem[0].csdf__Flight_Beginning__c = Date.today().addDays(4);
		fulfilmentItem[0].csdf__Type__c = 'Standard';
		fulfilmentItem[0].Served_By__c = 'DFP';
		fulfilmentItem[0].Product_Configuration__c = prodConfigs[0].Id;
		update fulfilmentItem;
	}

	@IsTest
	static void testButtonSORequestAcceptanceNotReserved() {
		createTestData();

		ButtonSORequestAcceptance button = new ButtonSORequestAcceptance();

		Test.startTest();
		button.performAction(salesOrder.Id);
		Test.stopTest();

		csmso__Sales_Order__c salesOrderQueried = [
				SELECT
						Id, csmso__Process_Message__c, csmso__Process_Message_Type__c
				FROM csmso__Sales_Order__c
				WHERE Id = :salesOrder.Id
		];
		System.assertEquals(salesOrderQueried.csmso__Process_Message__c, null, 'Sales Order should not have error message after the process.');
	}

	@IsTest
	static void testButtonSORequestAcceptanceHasReserved() {
		createTestData();

		ButtonSORequestAcceptance button = new ButtonSORequestAcceptance();

		//update pc Fulfilment_Item_Status__c
		cscfga__Product_Configuration__c prodConfig = [
				SELECT Id
				FROM cscfga__Product_Configuration__c
				WHERE Id = :prodConfigs[0].Id
		];
		prodConfig.Fulfilment_Item_Status__c = 'Paused Inventory Released';
		update prodConfig;

		Test.startTest();
		button.performAction(salesOrder.Id);
		Test.stopTest();

		csmso__Sales_Order__c salesOrderQueried = [
				SELECT Id, csmso__Process_Message__c, csmso__Process_Message_Type__c
				FROM csmso__Sales_Order__c
				WHERE Id = :salesOrder.Id
		];
		System.assertEquals(salesOrderQueried.csmso__Process_Message__c, null, 'Sales Order should not have error message after the process.');
	}
}
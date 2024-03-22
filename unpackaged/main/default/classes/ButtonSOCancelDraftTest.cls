@IsTest
private class ButtonSOCancelDraftTest {
	private static cscfga__Product_Configuration__c productConfiguration;
	private static CS_Custom_Settings__c settings;

	private static void createTestData() {
		settings = new CS_Custom_Settings__c(Sync_Retraction_SOLI_Limit__c = 1);
		upsert settings;

		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.Last_Date_Retracted__c = System.now();
		salesOrder.Last_Date_Booked__c = System.now();
		salesOrder.Reason_for_Cancellation__c = 'Agency';
		salesOrder.Reason_for_Retraction__c = 'Optimization request by Spotify';
		salesOrder.Last_Date_Retracted__c = Date.today();
		salesOrder.Last_Date_Booked__c = Date.today().addDays(-1);
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
		insert prodBasket;

		productConfiguration = new cscfga__Product_Configuration__c();
		productConfiguration.Sales_Order__c = salesOrder.Id;
		productConfiguration.cscfga__Product_Basket__c = prodBasket.Id;
		productConfiguration.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
		productConfiguration.Fulfilment_Item_Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Paused;
		productConfiguration.Flight_Begin__c = Date.today().addDays(2);
		productConfiguration.Served_By__c = 'DFP';
		insert productConfiguration;

		csdf__Fulfilment__c fulfilment = TestDataSetupTargetables.createFulfilment(salesOrder, accs[0]);
		insert fulfilment;

		csdf__Fulfilment_Item__c fulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(productConfiguration, salesOrder, fulfilment);
		fulfilmentItem.csdf__Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Paused;
		insert fulfilmentItem;
	}

	@IsTest
	static void testButtonSOCancelDraftSuccess() {
		createTestData();

		csmso__SalesOrderAPI__c soapi = [SELECT Id FROM csmso__SalesOrderAPI__c LIMIT 1];
		delete soapi;

		csmso__Sales_Order__c salesOrder = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1];

		Test.startTest();
		ButtonSOCancelDraft button = new ButtonSOCancelDraft();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void testButtonSOCancelDraftCannotBeProcessed() {
		createTestData();

		productConfiguration.Fulfilment_Item_Status__c = CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased;
		upsert productConfiguration;

		csmso__SalesOrderAPI__c soapi = [SELECT Id FROM csmso__SalesOrderAPI__c LIMIT 1];
		delete soapi;

		csmso__Sales_Order__c salesOrder = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1];

		Test.startTest();
		ButtonSOCancelDraft button = new ButtonSOCancelDraft();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void testButtonSOCancelDraftFailed() {
		createTestData();

		settings.Sync_Retraction_SOLI_Limit__c = 0;
		upsert settings;

		csmso__SalesOrderAPI__c soapi = [SELECT Id FROM csmso__SalesOrderAPI__c LIMIT 1];
		delete soapi;

		csmso__Sales_Order__c salesOrder = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1];

		Test.startTest();
		ButtonSOCancelDraft button = new ButtonSOCancelDraft();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void testButtonSOCancelDraftCutOff() {
		createTestData();

		settings.Cancel_Retraction_cut_off_date__c = Datetime.now().addDays(2);
		upsert settings;

		csmso__SalesOrderAPI__c soapi = [SELECT Id FROM csmso__SalesOrderAPI__c LIMIT 1];
		delete soapi;

		csmso__Sales_Order__c salesOrder = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1];

		Test.startTest();
		ButtonSOCancelDraft button = new ButtonSOCancelDraft();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}
}
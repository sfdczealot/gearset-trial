@IsTest
private class ButtonSOBookTests {
	private static Account[] accs;
	private static Opportunity opportunity;
	private static csmso__Sales_Order__c salesOrder;

	private static void createTestData() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c settings = new CS_Custom_Settings__c();
		settings.Max_n_Templates_for_Sync_Execution__c = 10;
		settings.Max_n_Lines_for_Sync_Execution__c = 5;
		insert settings;

		accs = TestDataSetupBasic.createAccounts(2);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		opportunity = opps[0];

		accs[0].Type = 'Creative Agency';
		accs[1].Type = 'Advertiser';
		update accs;

		salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opportunity.Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_PENDING_BOOKING;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.SO_Lines_Ad_Server_Items__c = 0;
		salesOrder.Last_Date_Retracted__c = Date.today();
		salesOrder.Last_Date_Booked__c = Date.today().addDays(-1);
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		salesOrder.Agency_Final__c = accs[0].Id;
		salesOrder.Advertiser_Final__c = accs[1].Id;
		insert salesOrder;
	}

	@IsTest
	static void test1ButtonSOBookTests() {
		createTestData();

		salesOrder.Order_Type__c = CS_Constants.ORDER_TYPE_HOUSE_GUARANTEED;
		update salesOrder;

		Test.startTest();
		ButtonSOBook button = new ButtonSOBook();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void test2ButtonSOBookTests() {
		createTestData();

		salesOrder.SO_Lines_Ad_Server_Items__c = 4;
		salesOrder.SO_Lines_Ad_Server_Inventory_Avail_Ov__c = 5;
		salesOrder.Order_Synced_before_final_approval__c = true;
		salesOrder.Order_Type__c = CS_Constants.ORDER_TYPE_LABELS_ADCREDIT;
		update salesOrder;

		Test.startTest();
		ButtonSOBook button = new ButtonSOBook();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void test3ButtonSOBookTests() {
		createTestData();

		salesOrder.SO_Lines_All_Valid__c = false;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Number_of_lines__c = 2;
		update salesOrder;

		Test.startTest();
		ButtonSOBook button = new ButtonSOBook();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void test4ButtonSOBookTests() {
		createTestData();

		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_BOOKED;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		update salesOrder;

		Test.startTest();
		ButtonSOBook button = new ButtonSOBook();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void test5ButtonSOBookTests() {
		createTestData();

		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Number_of_lines__c = 2;
		salesOrder.Last_Date_Retracted__c = Date.today().addDays(-2);
		salesOrder.Primary_Sales_Order__c = false;
		update salesOrder;

		csdf__Ad_Server__c adServer = new csdf__Ad_Server__c();
		adServer.Name = 'Test Ad Server';
		adServer.csdf__Type__c = 'DFP';
		adServer.csdf__Network_Code__c = 'Test Network Code';
		adServer.csdf__Network_Name__c = 'Test Network Name';
		adServer.csdf__Description__c = '‚Test Ad Server Description';
		adServer.csdf__Client_Id__c = 'Test Client Id';
		adServer.csdf__Client_Secret__c = 'Test Client Secret';
		adServer.csdf__Refresh_Token__c = 'Test Refresh Token';
		insert adServer;

		csdf__Buyer__c buyer = new csdf__Buyer__c();
		buyer.csdf__Name__c = 'Test1234';
		buyer.csdf__Ad_Server_Id__c = 'xx12';
		buyer.csdf__Ad_Server__c = adServer.Id;
		insert buyer;

		opportunity.Buyer__c = buyer.Id;
		opportunity.Order_Type__c = 'Programmatic Guaranteed';
		//update opportunity;

		csmso__Sales_Order__c salesOrder2 = new csmso__Sales_Order__c();
		salesOrder2.csmso__Opportunity__c = opportunity.Id;
		salesOrder2.csmso__Status__c = CS_const_SalesOrder.Status_PendingBooking;
		salesOrder2.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Number_of_lines__c = 2;
		salesOrder2.Last_Date_Retracted__c = Date.today().addDays(-2);
		salesOrder2.Last_Date_Booked__c = Date.today();
		salesOrder2.Primary_Sales_Order__c = true;
		salesOrder2.Order_Type__c = 'Programmatic Guaranteed';
		insert salesOrder2;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
		insert prodBasket;

		cscfga__Product_Configuration__c productConfiguration = new cscfga__Product_Configuration__c();
		productConfiguration.Sales_Order__c = salesOrder.Id;
		productConfiguration.cscfga__Product_Basket__c = prodBasket.Id;
		productConfiguration.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
		productConfiguration.Fulfilment_Item_Status__c = 'Paused';
		productConfiguration.Net_Cost__c = 100;
		productConfiguration.Flight_Begin__c = Date.today().addDays(2);
		productConfiguration.Served_By__c = 'DFP';
		insert productConfiguration;

		productConfiguration = [SELECT Id FROM cscfga__Product_Configuration__c LIMIT 1];

		salesOrder = [SELECT Id FROM csmso__Sales_Order__c WHERE Id = :salesOrder.Id LIMIT 1];
		salesOrder2 = [SELECT Id FROM csmso__Sales_Order__c WHERE Id = :salesOrder2.Id LIMIT 1];

		Test.startTest();
		ButtonSOBook button = new ButtonSOBook();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}
}
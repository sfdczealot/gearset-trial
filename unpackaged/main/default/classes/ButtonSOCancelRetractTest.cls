@IsTest
private class ButtonSOCancelRetractTest {

	@TestSetup
	static void testSetup() {
		CS_Custom_Settings__c settings = new CS_Custom_Settings__c(Sync_Retraction_SOLI_Limit__c = 1);
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

		cscfga__Product_Configuration__c productConfiguration = new cscfga__Product_Configuration__c();
		productConfiguration.Sales_Order__c = salesOrder.Id;
		productConfiguration.cscfga__Product_Basket__c = prodBasket.Id;
		productConfiguration.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
		productConfiguration.Fulfilment_Item_Status__c = 'Paused';
		productConfiguration.Flight_Begin__c = Date.today().addDays(2);
		productConfiguration.Served_By__c = 'DFP';
		insert productConfiguration;

		csdf__Fulfilment__c fulfilment = TestDataSetupTargetables.createFulfilment(salesOrder, accs[0]);
		insert fulfilment;

		csdf__Fulfilment_Item__c fulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(productConfiguration, salesOrder, fulfilment);
		fulfilmentItem.csdf__Status__c = 'Paused';
		insert fulfilmentItem;
	}

	@IsTest
	static void testButtonSOCancelRetract() {
		csmso__SalesOrderAPI__c soapi = [SELECT Id FROM csmso__SalesOrderAPI__c LIMIT 1];
		delete soapi;

		csmso__Sales_Order__c salesOrder = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1];

		Test.startTest();
		ButtonSOCancelRetract button = new ButtonSOCancelRetract();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void test2ButtonSOCancelRetract() {
		Test.startTest();
		Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = o.Id;
		insert salesOrder;

		ButtonSOCancelRetract button = new ButtonSOCancelRetract();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void test3ButtonSOCancelRetract() {
		Account acc = [SELECT Id FROM Account LIMIT 1];
		Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];

		Test.startTest();
		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = o.Id;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.Last_Date_Retracted__c = System.now();
		salesOrder.Last_Date_Booked__c = Date.today().addDays(-1);
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
		insert prodBasket;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Sales_Order__c = salesOrder.Id;
		prodConfig.cscfga__Product_Basket__c = prodBasket.Id;
		prodConfig.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
		prodConfig.Fulfilment_Item_Status__c = 'Paused';
		prodConfig.Flight_Begin__c = Date.today().addDays(2);
		prodConfig.Served_By__c = 'DFP';
		insert prodConfig;

		List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1, new List<csmso__Sales_Order__c>{
				salesOrder
		}, new List<Account>{
				acc
		});

		List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1, fulfilment, new List<cscfga__Product_Configuration__c>{
				prodConfig
		});
		update fulfilmentItem;

		prodConfig.Fulfilment_Item_Status__c = 'Draft';
		update prodConfig;

		ButtonSOCancelRetract button = new ButtonSOCancelRetract();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void test4ButtonSOCancelRetract() {
		Test.startTest();
		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.Integration_Chunk_Size__c = 10;
		cs.Sync_Retraction_SOLI_Limit__c = 1;
		insert cs;

		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		Account acc = [SELECT Id FROM Account LIMIT 1];

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opp.Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_BOOKED;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.Reason_for_Retraction__c = 'Optimization request by Spotify';
		salesOrder.Last_Date_Retracted__c = Date.today();
		salesOrder.Last_Date_Booked__c = Date.today().addDays(-1);
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				salesOrder
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

		List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1, new List<csmso__Sales_Order__c>{
				salesOrder
		}, new List<Account>{
				acc
		});

		List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1, fulfilment, prodConfigs);
		fulfilmentItem[0].csdf__Flight_Beginning__c = Date.today().addDays(4);
		fulfilmentItem[0].csdf__Type__c = 'Standard';
		fulfilmentItem[0].Served_By__c = 'DFP';
		fulfilmentItem[0].csdf__Status__c = 'Inventory Released';
		update fulfilmentItem;

		for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
			pConfig.Sales_Order__c = salesOrder.Id;
			pConfig.Fulfilment_Item_Status__c = 'Inventory Released';
			pConfig.cscfga__Product_Basket__c = prodBaskets[0].Id;
			pConfig.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
			pConfig.Flight_Begin__c = Date.today().addDays(2);
			pConfig.Served_By__c = 'DFP';
		}
		update prodConfigs;

		ButtonSORetract button = new ButtonSORetract();
		button.performAction(salesOrder.Id);

		ButtonSOCancelRetract button2 = new ButtonSOCancelRetract();
		button2.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void test5ButtonSOCancelRetract() {
		Test.startTest();
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.Integration_Chunk_Size__c = 10;
		cs.Sync_Retraction_SOLI_Limit__c = 1;
		insert cs;

		Account acc = [SELECT Id FROM Account LIMIT 1];
		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opp.Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_BOOKED;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.Reason_for_Retraction__c = 'Optimization request by Spotify';
		salesOrder.Last_Date_Retracted__c = Date.today();
		salesOrder.Last_Date_Booked__c = Date.today().addDays(-1);
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Attribute definition Creation.
		List<cscfga__Attribute_Definition__c> attDefs = TestDataSetupSO.createAttributeDefinitions(1, prodDef);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				salesOrder
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

		List<cscfga__Attribute__c> attributes = TestDataSetupSO.createAttributes(1, prodConfigs, attDefs);
		attributes[0].Name = 'Fulfilment Item Status';
		update attributes[0];

		List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1, new List<csmso__Sales_Order__c>{
				salesOrder
		}, new List<Account>{
				acc
		});

		List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1, fulfilment, prodConfigs);
		fulfilmentItem[0].csdf__Flight_Beginning__c = Date.today().addDays(4);
		fulfilmentItem[0].csdf__Type__c = 'Standard';
		fulfilmentItem[0].Served_By__c = 'DFP';
		fulfilmentItem[0].csdf__Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Paused;
		update fulfilmentItem;

		for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
			pConfig.Sales_Order__c = salesOrder.Id;
			pConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Paused;
			pConfig.cscfga__Product_Basket__c = prodBaskets[0].Id;
			pConfig.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
			pConfig.Flight_Begin__c = Date.today().addDays(2);
			pConfig.Served_By__c = 'DFP';
		}
		update prodConfigs;

		ButtonSORetract button = new ButtonSORetract();
		button.performAction(salesOrder.Id);

		ButtonSOCancelRetract button2 = new ButtonSOCancelRetract();
		button2.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void test6ButtonSOCancelRetract() {
		Test.startTest();
		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.Integration_Chunk_Size__c = 10;
		cs.Sync_Retraction_SOLI_Limit__c = 1;
		insert cs;

		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		Account acc = [SELECT Id FROM Account LIMIT 1];

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opp.Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_BOOKED;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.Reason_for_Retraction__c = 'Optimization request by Spotify';
		salesOrder.Last_Date_Retracted__c = null;
		salesOrder.Last_Date_Booked__c = Date.today().addDays(-1);
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				salesOrder
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

		List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1, new List<csmso__Sales_Order__c>{
				salesOrder
		}, new List<Account>{
				acc
		});

		List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1, fulfilment, prodConfigs);
		fulfilmentItem[0].csdf__Flight_Beginning__c = Date.today().addDays(4);
		fulfilmentItem[0].csdf__Type__c = 'Standard';
		fulfilmentItem[0].Served_By__c = 'DFP';
		fulfilmentItem[0].csdf__Status__c = 'Inventory Released';
		update fulfilmentItem;

		for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
			pConfig.Sales_Order__c = salesOrder.Id;
			pConfig.Fulfilment_Item_Status__c = 'Inventory Released';
			pConfig.cscfga__Product_Basket__c = prodBaskets[0].Id;
			pConfig.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
			pConfig.Flight_Begin__c = Date.today().addDays(2);
			pConfig.Served_By__c = 'DFP';
		}
		update prodConfigs;

		ButtonSORetract button = new ButtonSORetract();
		button.performAction(salesOrder.Id);

		ButtonSOCancelRetract button2 = new ButtonSOCancelRetract();
		button2.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void test7ButtonSOCancelRetract() {
		Test.startTest();
		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.Integration_Chunk_Size__c = 10;
		cs.Sync_Retraction_SOLI_Limit__c = 1;
		cs.Cancel_Retraction_cut_off_date__c = Datetime.now().addDays(-2);
		insert cs;

		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		Account acc = [SELECT Id FROM Account LIMIT 1];

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opp.Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_BOOKED;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.Reason_for_Retraction__c = 'Optimization request by Spotify';
		salesOrder.Last_Date_Retracted__c = Date.today();
		salesOrder.Last_Date_Booked__c = Date.today().addDays(-1);
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				salesOrder
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

		List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1, new List<csmso__Sales_Order__c>{
				salesOrder
		}, new List<Account>{
				acc
		});

		List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1, fulfilment, prodConfigs);
		fulfilmentItem[0].csdf__Flight_Beginning__c = Date.today().addDays(4);
		fulfilmentItem[0].csdf__Type__c = 'Standard';
		fulfilmentItem[0].Served_By__c = 'DFP';
		fulfilmentItem[0].csdf__Status__c = 'Inventory Released';
		update fulfilmentItem;

		for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
			pConfig.Sales_Order__c = salesOrder.Id;
			pConfig.Fulfilment_Item_Status__c = 'Inventory Released';
			pConfig.cscfga__Product_Basket__c = prodBaskets[0].Id;
			pConfig.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
			pConfig.Flight_Begin__c = Date.today().addDays(2);
			pConfig.Served_By__c = 'DFP';
		}
		update prodConfigs;

		ButtonSORetract button = new ButtonSORetract();
		button.performAction(salesOrder.Id);

		ButtonSOCancelRetract button2 = new ButtonSOCancelRetract();
		button2.performAction(salesOrder.Id);
		Test.stopTest();
	}
}
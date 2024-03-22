@IsTest
private class CS_RetractionServiceTest {
	private static csmso__Sales_Order__c salesOrder;
	private static cscfga__Product_Basket__c prodBasket;
	private static cscfga__Product_Configuration__c productConfiguration;
	private static Map<Id, cscfga__Product_Configuration__c> productConfigurationsMap;

	private static void createTestData() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.Integration_Chunk_Size__c = 3;
		cs.Sync_Retraction_SOLI_Limit__c = 1;
		insert cs;

		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);

		salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.Last_Date_Retracted__c = System.now();
		salesOrder.Last_Date_Booked__c = System.now();
		salesOrder.Reason_for_Cancellation__c = 'Agency';
		salesOrder.Reason_for_Retraction__c = 'Optimization request by Spotify';
		salesOrder.Last_Date_Retracted__c = Date.today();
		salesOrder.Last_Date_Booked__c = Date.today().addDays(-1);
		insert salesOrder;

		prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
		insert prodBasket;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		testProDef.cscfga__Allow_progress_from_incomplete_screens__c = true;
		insert testProDef;

		cscfga__Configuration_Screen__c screenFlow = TestDataSetupTargetables.createConfigurationScreen(testProDef, 'Default Screen');
		insert screenFlow;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef.cscfga__Column__c = 0;
		testAttrDef.cscfga__Row__c = 0;
		testAttrDef.cscfga__Data_Type__c = 'Integer';
		testAttrDef.Name = 'Insertion Quantity';
		testAttrDef.cscfga__configuration_output_mapping__c = 'Insertion_Quantity__c';

		cscfga__Attribute_Definition__c testAttrDef2 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef2.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef2.cscfga__Column__c = 0;
		testAttrDef2.cscfga__Row__c = 1;
		testAttrDef2.cscfga__Data_Type__c = 'String';
		testAttrDef2.Name = 'Fulfilment Item Status';

		SObject[] attDefs = new SObject[]{
				testAttrDef, testAttrDef2
		};
		insert attDefs;

		productConfiguration = new cscfga__Product_Configuration__c();
		productConfiguration.Sales_Order__c = salesOrder.Id;
		productConfiguration.cscfga__Product_Basket__c = prodBasket.Id;
		productConfiguration.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
		productConfiguration.Fulfilment_Item_Status__c = CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased;
		insert productConfiguration;

		productConfigurationsMap = new Map<Id, cscfga__Product_Configuration__c>();
		productConfigurationsMap.put(productConfiguration.Id, productConfiguration);

		csdf__Fulfilment__c fulfilment = TestDataSetupTargetables.createFulfilment(salesOrder, accs[0]);
		insert fulfilment;

		csdf__Fulfilment_Item__c fulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(productConfiguration, salesOrder, fulfilment);
		fulfilmentItem.csdf__Status__c = CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased;
		fulfilmentItem.Product_Configuration__c = productConfiguration.Id;
		insert fulfilmentItem;

		cscfga__Attribute__c attQty = new cscfga__Attribute__c(cscfga__Product_Configuration__c = productConfiguration.Id, Name = 'Insertion Quantity', cscfga__Value__c = '10000', cscfga__Attribute_Definition__c = testAttrDef.Id);
		cscfga__Attribute__c attFIStatus = new cscfga__Attribute__c(cscfga__Product_Configuration__c = productConfiguration.Id, Name = 'Fulfilment Item Status', cscfga__Value__c = CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased, cscfga__Attribute_Definition__c = testAttrDef2.Id);

		SObject[] atts = new SObject[]{
				attQty, attFIStatus
		};
		insert atts;
	}

	@IsTest
	static void testCancelRetraction() {
		createTestData();

		Test.startTest();
		CS_RetractionService.cancelRetraction(salesOrder.Id, CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);
		CS_RetractionService.SObjectInstance sobjectInstance = new CS_RetractionService.SObjectInstance();
		Test.stopTest();
	}

	@IsTest
	static void testCancelRetractionMultiplePCs() {
		createTestData();

		Test.startTest();
		List<cscfga__Product_Configuration__c> pcsToInsert = new List<cscfga__Product_Configuration__c>();

		for (Integer i = 0; i < 4; i++) {
			cscfga__Product_Configuration__c productConfiguration = new cscfga__Product_Configuration__c();
			productConfiguration.Sales_Order__c = salesOrder.Id;
			productConfiguration.cscfga__Product_Basket__c = prodBasket.Id;
			productConfiguration.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
			productConfiguration.Fulfilment_Item_Status__c = 'Paused';
			pcsToInsert.add(productConfiguration);
		}
		insert pcsToInsert;

		try {
			CS_RetractionService.cancelRetraction(salesOrder.Id, CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);
			Test.stopTest();
		} catch (Exception e) {
			System.debug(e.getStackTraceString());
		}
	}

	@IsTest
	static void testCancelRetractionNoPCs() {
		Test.startTest();

		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);

		salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.Last_Date_Retracted__c = System.now();
		salesOrder.Last_Date_Booked__c = System.now();
		salesOrder.Reason_for_Cancellation__c = 'Agency';
		salesOrder.Reason_for_Retraction__c = 'Optimization request by Spotify';
		salesOrder.Last_Date_Retracted__c = Date.today();
		salesOrder.Last_Date_Booked__c = Date.today().addDays(-1);
		insert salesOrder;

		CS_RetractionService.cancelRetraction(salesOrder.Id, CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);
		Test.stopTest();
	}

	@IsTest
	static void testGenerateScreenshot() {
		createTestData();

		Test.startTest();
		CS_RetractionService.generateScreenshot(salesOrder.Id, productConfigurationsMap, CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);
		Test.stopTest();
	}

	@IsTest
	static void testGenerateScreenshotAndCancelRetraction() {
		createTestData();

		Test.startTest();
		CS_RetractionService.generateScreenshot(salesOrder.Id, productConfigurationsMap, CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);
		CS_RetractionService.cancelRetraction(salesOrder.Id, CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);
		Test.stopTest();
	}

	@IsTest
	static void testGenSSAndCancelRetWithLastDate() {
		createTestData();

		Test.startTest();
		productConfiguration.Last_Changed_Date__c = Date.today().addDays(-1);
		update productConfiguration;

		CS_RetractionService.generateScreenshot(salesOrder.Id, productConfigurationsMap, CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);
		CS_RetractionService.cancelRetraction(salesOrder.Id, CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);
		Test.stopTest();
	}

	@IsTest
	static void testGenerateScreenshotRetractionService() {
		createTestData();

		Test.startTest();
		salesOrder.Callout_Type__c = 'RetractionService';
		update salesOrder;

		CS_RetractionService.generateScreenshot(salesOrder.Id, productConfigurationsMap, CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);
		Test.stopTest();
	}

	@IsTest
	static void testGenerateScreenshotMultiplePCs() {
		createTestData();

		Test.startTest();
		List<cscfga__Product_Configuration__c> pcsToInsert = new List<cscfga__Product_Configuration__c>();

		for (Integer i = 0; i < 4; i++) {
			cscfga__Product_Configuration__c productConfiguration = new cscfga__Product_Configuration__c();
			productConfiguration.Sales_Order__c = salesOrder.Id;
			productConfiguration.cscfga__Product_Basket__c = prodBasket.Id;
			productConfiguration.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
			productConfiguration.Fulfilment_Item_Status__c = 'Paused';
			pcsToInsert.add(productConfiguration);
		}
		insert pcsToInsert;

		try {
			CS_RetractionService.generateScreenshot(salesOrder.Id, productConfigurationsMap, CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);
			Test.stopTest();
		} catch (Exception e) {
			System.debug(e.getStackTraceString());
		}
	}

	@IsTest
	static void testGenerateScreenshotNoPCs() {
		Test.startTest();

		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);

		salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.Last_Date_Retracted__c = System.now();
		salesOrder.Last_Date_Booked__c = System.now();
		salesOrder.Reason_for_Cancellation__c = 'Agency';
		salesOrder.Reason_for_Retraction__c = 'Optimization request by Spotify';
		salesOrder.Last_Date_Retracted__c = Date.today();
		salesOrder.Last_Date_Booked__c = Date.today().addDays(-1);
		insert salesOrder;

		CS_RetractionService.generateScreenshot(salesOrder.Id, productConfigurationsMap, CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);
		Test.stopTest();
	}

	@IsTest
	static void testRetractionServiceWorkerGenerate() {
		createTestData();

		Test.startTest();
		Map<String, Object> params = new Map<String, Object>();
		params.put('type', 'generate');
		params.put('salesOrderId', salesOrder.Id);
		params.put('existingIds', new Set<Id>{
				productConfiguration.Id
		});
		params.put('productConfigurationIds', new Set<Id>{
				productConfiguration.Id
		});

		try {
			CS_RetractionService.CS_RetractionServiceWorker retractionWorker = new CS_RetractionService.CS_RetractionServiceWorker(params);
			retractionWorker.doWork();
			Test.stopTest();
		} catch (Exception e) {
			System.debug(e.getStackTraceString());
		}
	}

	@IsTest
	static void testRetractionServiceWorkerGenerateCalloutType() {
		createTestData();

		salesOrder.Callout_Type__c = 'RetractionService';
		update salesOrder;

		Test.startTest();
		Map<String, Object> params = new Map<String, Object>();
		params.put('type', 'generate');
		params.put('salesOrderId', salesOrder.Id);
		params.put('existingIds', new Set<Id>{
				productConfiguration.Id
		});
		params.put('productConfigurationIds', new Set<Id>{
				productConfiguration.Id
		});

		try {
			CS_RetractionService.CS_RetractionServiceWorker retractionWorker = new CS_RetractionService.CS_RetractionServiceWorker(params);
			retractionWorker.doWork();
			Test.stopTest();
		} catch (Exception e) {
			System.debug(e.getStackTraceString());
		}
	}

	@IsTest
	static void testRetractionServiceWorkerGenerateParams() {
		createTestData();

		Test.startTest();
		Map<String, Object> params = new Map<String, Object>();
		params.put('type', 'generate');
		params.put('salesOrderId', salesOrder.Id);
		params.put('existingIds', new Set<Id>{
				productConfiguration.Id
		});
		params.put('productConfigurationIds', new Set<Id>{
				productConfiguration.Id
		});
		params.put('screenshotName', CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT);
		params.put('aajsScreenshotName', CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);

		CS_RetractionService.generateScreenshot(salesOrder.Id, productConfigurationsMap, CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);
		CS_RetractionService.CS_RetractionServiceWorker retractionWorker = new CS_RetractionService.CS_RetractionServiceWorker(params);
		retractionWorker.nextWorker = retractionWorker;
		retractionWorker.doWork();
		Test.stopTest();
	}

	@IsTest
	static void testRetractionServiceWorkerCancel() {
		createTestData();

		Test.startTest();
		Map<String, Object> params = new Map<String, Object>();
		params.put('type', 'cancel');
		params.put('salesOrderId', salesOrder.Id);
		params.put('existingIds', new Set<Id>{
				productConfiguration.Id
		});
		params.put('productConfigurationIds', new Set<Id>{
				productConfiguration.Id
		});
		params.put('screenshotName', CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT);
		params.put('aajsScreenshotName', CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);

		CS_RetractionService.generateScreenshot(salesOrder.Id, productConfigurationsMap, CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);
		CS_RetractionService.CS_RetractionServiceWorker retractionWorker = new CS_RetractionService.CS_RetractionServiceWorker(params);
		retractionWorker.doWork();
		Test.stopTest();
	}

	@IsTest
	static void testRetractionServiceWorkerCancelParams() {
		createTestData();

		Test.startTest();
		Map<String, Object> params = new Map<String, Object>();
		params.put('type', 'cancel');
		params.put('salesOrderId', salesOrder.Id);
		params.put('existingIds', new Set<Id>{
				productConfiguration.Id
		});
		params.put('productConfigurationIds', new Set<Id>{
				productConfiguration.Id
		});
		params.put('screenshotName', CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT);
		params.put('aajsScreenshotName', CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);

		CS_RetractionService.generateScreenshot(salesOrder.Id, productConfigurationsMap, CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);
		CS_RetractionService.CS_RetractionServiceWorker retractionWorker = new CS_RetractionService.CS_RetractionServiceWorker(params);
		retractionWorker.nextWorker = retractionWorker;
		retractionWorker.doWork();
		Test.stopTest();
	}

	@IsTest
	static void testRetractionServiceWorkerCancelException() {
		createTestData();

		Test.startTest();
		Map<String, Object> params = new Map<String, Object>();
		params.put('type', 'cancel');

		try {
			CS_RetractionService.CS_RetractionServiceWorker retractionWorker = new CS_RetractionService.CS_RetractionServiceWorker(params);
			retractionWorker.doWork();
			Test.stopTest();
		} catch (Exception e) {
			System.debug(e.getStackTraceString());
		}
	}
}
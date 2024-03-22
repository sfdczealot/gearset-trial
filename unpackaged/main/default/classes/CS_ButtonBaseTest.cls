@IsTest
private class CS_ButtonBaseTest {

	@IsTest
	static void testButtonBaseCancelRetract() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.Integration_Chunk_Size__c = 10;
		cs.Sync_Retraction_SOLI_Limit__c = 1;
		insert cs;

		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		Account acc = accs[0];
		Opportunity opp = opps[0];

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

		Test.startTest();
		ButtonSORetract button = new ButtonSORetract();
		button.performAction(salesOrder.Id);

		ButtonSOCancelRetract button2 = new ButtonSOCancelRetract();
		button2.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void testButtonBaseCancelRetractGTChunkSize() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.Integration_Chunk_Size__c = 10;
		cs.Sync_Retraction_SOLI_Limit__c = 1;
		cs.Max_n_Lines_for_Sync_Execution__c = 1;
		insert cs;

		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		Account acc = accs[0];
		Opportunity opp = opps[0];

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

		cscfga__Product_Configuration__c productConfiguration2 = new cscfga__Product_Configuration__c();
		productConfiguration2.Sales_Order__c = salesOrder.Id;
		productConfiguration2.cscfga__Product_Basket__c = prodBaskets[0].Id;
		productConfiguration2.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
		productConfiguration2.Fulfilment_Item_Status__c = 'Paused';
		productConfiguration2.Flight_Begin__c = Date.today().addDays(2);
		productConfiguration2.Served_By__c = 'DFP';
		insert productConfiguration2;

		prodConfigs.add(productConfiguration2);

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

		Test.startTest();
		try {
			ButtonSORetract button = new ButtonSORetract();
			button.performAction(salesOrder.Id);

			ButtonSOCancelRetract button2 = new ButtonSOCancelRetract();
			button2.performAction(salesOrder.Id);
			Test.stopTest();
		} catch (Exception e) {
			System.debug(e.getStackTraceString());
		}
	}

	@IsTest
	static void testButtonButtonSOCheckAvail() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		ButtonSOCheckAvail button = new ButtonSOCheckAvail();
		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		insert salesOrder;

		Test.startTest();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void testCheckAvailInvalid() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		ButtonSOCheckAvail button = new ButtonSOCheckAvail();
		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.SO_Lines_All_Valid__c = false;
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		insert salesOrder;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				salesOrder
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);
		for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
			pConfig.Sales_Order__c = salesOrder.Id;
			pConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Paused;
			pConfig.cscfga__Product_Basket__c = prodBaskets[0].Id;
			pConfig.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Incomplete;
			pConfig.Flight_Begin__c = Date.today().addDays(2);
			pConfig.Served_By__c = 'DFP';
		}
		update prodConfigs;

		Test.startTest();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void testCheckAvailStartDFPDateInPast() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		ButtonSOCheckAvail button = new ButtonSOCheckAvail();
		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		insert salesOrder;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				salesOrder
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);
		for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
			pConfig.Sales_Order__c = salesOrder.Id;
			pConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Paused;
			pConfig.cscfga__Product_Basket__c = prodBaskets[0].Id;
			pConfig.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
			pConfig.Flight_Begin__c = Date.today().addDays(-2);
			pConfig.Flight_Begin_Logged_User_Timezone__c = Date.today().addDays(-2);
			pConfig.Order_Line_ID__c = String.valueOf(salesOrder.Id);
			pConfig.Served_By__c = 'DFP';
		}
		update prodConfigs;

		Test.startTest();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void testCheckAvailStartNonDFPDateInPast() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		ButtonSOCheckAvail button = new ButtonSOCheckAvail();
		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		insert salesOrder;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				salesOrder
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);
		for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
			pConfig.Sales_Order__c = salesOrder.Id;
			pConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Paused;
			pConfig.cscfga__Product_Basket__c = prodBaskets[0].Id;
			pConfig.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
			pConfig.Flight_Begin__c = Date.today().addDays(-2);
			pConfig.Flight_Begin_Logged_User_Timezone__c = Date.today().addDays(-2);
			pConfig.Served_By__c = 'Non-Ad Served';
		}
		update prodConfigs;

		Test.startTest();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void testCheckAvailExpiredDigitalProduct() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		ButtonSOCheckAvail button = new ButtonSOCheckAvail();
		Account[] accs = TestDataSetupBasic.createAccounts(1);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		insert salesOrder;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				salesOrder
		});

		// create Ad Server (csdf__Ad_Server__c)
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

		// create Advert Assignment (csmso__Node_Advert_Assignment__c)
		csmso__Node_Advert_Assignment__c advertAssignment = new csmso__Node_Advert_Assignment__c();
		advertAssignment.Name = 'Test Market';
		advertAssignment.Product_Name__c = 'Test Product Name';
		advertAssignment.Rate_Type__c = 'CPM';
		advertAssignment.Rate_Type_Display__c = 'CPCV';
		advertAssignment.Line_Item_Type__c = 'Standard';
		advertAssignment.Inventory_sizes__c = '1000x1000';
		advertAssignment.Unique_Id__c = 'someUniqueTestId';
		advertAssignment.Product_Category__c = 'Standard Products';
		advertAssignment.Product_Group__c = 'Audio';
		advertAssignment.Line_Item_Category__c = 'House';
		advertAssignment.Product_Family__c = 'Audio';
		advertAssignment.Served_by__c = 'DFP';
		advertAssignment.Ad_Slot__c = 'Test Ad Slot';
		advertAssignment.Ad_Location_Description__c = 'Everywhere';
		advertAssignment.Ad_Server__c = adServer.Id;
		advertAssignment.Ad_Slot_Names__c = 'SPT_AD_Unit';
		advertAssignment.Invoice_GL_Code__c = '123456789';
		advertAssignment.Rev_Accrual_GL_Code__c = '123456789';
		advertAssignment.Priority__c = '6';
		advertAssignment.Expiration_Date__c = Date.today().addDays(-2);
		insert advertAssignment;

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);
		for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
			pConfig.Sales_Order__c = salesOrder.Id;
			pConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Paused;
			pConfig.cscfga__Product_Basket__c = prodBaskets[0].Id;
			pConfig.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
			pConfig.Flight_Begin__c = Date.today().addDays(-2);
			pConfig.Flight_Begin_Logged_User_Timezone__c = Date.today().addDays(-2);
			pConfig.Served_By__c = 'DFP';
			pConfig.Digital_Product__c = advertAssignment.Id;
		}
		update prodConfigs;

		Test.startTest();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void testButtonSOApprovalHistoryRedirectMsg() {

		QliToOliFieldMapping__c objcustomsetting=new QliToOliFieldMapping__c();
        objcustomsetting.Name='Start_Date__c';
        objcustomsetting.OliField__c='Start_Date__c';
        insert objcustomsetting;
		Account[] testAccounts = TestDataSetupSO.createAccounts(1);
		Contact[] testContacts = TestDataSetupSO.createContacts(1, testAccounts);
		Opportunity[] testOpportunities = TestDataSetupSO.createOpportunities(1, testAccounts, testContacts);
		csmso__Sales_Order__c[] testSOs = TestDataSetupSO.createSalesOrders(1, testAccounts, testOpportunities);

		ButtonSOApprovalHistory button = new ButtonSOApprovalHistory();
		button.performAction(testSOs[0].Id);
	}

	@IsTest
	static void testButtonSOApprovalStart() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());

		// Needs an opp for the flow on SO
		Account[] accs = TestDataSetupBasic.createAccounts(2);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		update opps[0];

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.csmso__Advertiser__c = accs[0].Id;
		salesOrder.Bill_To_Account__c = accs[1].Id;
		salesOrder.Advertiser_Final__c = accs[1].Id;
		salesOrder.Bill_To_Account_Final__c = accs[1].Id;
		salesOrder.csmso__Purchase_Order_Number__c = 'test';
		salesOrder.IO_Template__c = 'Spotify';
		salesOrder.csmso__Booking_Contact__c = cons[0].Id;
		salesOrder.Billing_Email__c = 'test@test.com';
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.SO_Lines_Ad_Server_Items__c = 1;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				salesOrder
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);
		for (cscfga__Product_Configuration__c productConfiguration : prodConfigs) {
			productConfiguration.Sales_Order__c = salesOrder.Id;
			productConfiguration.cscfga__Product_Basket__c = prodBaskets[0].Id;
			productConfiguration.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
			productConfiguration.Fulfilment_Item_Status__c = 'Paused';
			productConfiguration.Flight_Begin__c = Date.today().addDays(2);
			productConfiguration.Served_By__c = 'DFP';
		}
		update prodConfigs;

		Test.startTest();
		ButtonSOApprovalStart button = new ButtonSOApprovalStart();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@isTest static void testMisc(){
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());

		// Needs an opp for the flow on SO
		Account[] accs = TestDataSetupBasic.createAccounts(2);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		update opps[0];

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.csmso__Advertiser__c = accs[0].Id;
		salesOrder.Bill_To_Account__c = accs[1].Id;
		salesOrder.Advertiser_Final__c = accs[1].Id;
		salesOrder.Bill_To_Account_Final__c = accs[1].Id;
		salesOrder.csmso__Purchase_Order_Number__c = 'test';
		salesOrder.IO_Template__c = 'Spotify';
		salesOrder.csmso__Booking_Contact__c = cons[0].Id;
		salesOrder.Billing_Email__c = 'test@test.com';
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.SO_Lines_Ad_Server_Items__c = 1;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				salesOrder
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);
		for (cscfga__Product_Configuration__c productConfiguration : prodConfigs) {
			productConfiguration.Sales_Order__c = salesOrder.Id;
			productConfiguration.cscfga__Product_Basket__c = prodBaskets[0].Id;
			productConfiguration.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
			productConfiguration.Fulfilment_Item_Status__c = 'Paused';
			productConfiguration.Flight_Begin__c = Date.today().addDays(2);
			productConfiguration.Served_By__c = 'DFP';
		}
		update prodConfigs;

		Test.startTest();
		CS_ButtonBase.ButtonReturnMessage message = new CS_ButtonBase.ButtonReturnMessage();
		message.isSuccess();
		CS_ButtonBase base = new CS_ButtonBase();
		Map<String, Object> testMap = new Map<String, Object>();
		testMap.put('salesOrderId', salesOrder.id);
		base.call('TestAction', testMap);
		base.areAllLinesItemsAvailable();
		CS_Custom_Settings__c settings = base.customSettings;
		Test.stopTest();

	}

	@IsTest
	static void testButtonSOApprovalStartInvalidLines() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());

		// Needs an opp for the flow on SO
		Account[] accs = TestDataSetupBasic.createAccounts(2);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		update opps[0];

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.csmso__Advertiser__c = accs[0].Id;
		salesOrder.Bill_To_Account__c = accs[1].Id;
		salesOrder.Advertiser_Final__c = accs[1].Id;
		salesOrder.Bill_To_Account_Final__c = accs[1].Id;
		salesOrder.csmso__Purchase_Order_Number__c = 'test';
		salesOrder.IO_Template__c = 'Spotify';
		salesOrder.csmso__Booking_Contact__c = cons[0].Id;
		salesOrder.Billing_Email__c = 'test@test.com';
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.SO_Lines_Ad_Server_Items__c = 1;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				salesOrder
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);
		for (cscfga__Product_Configuration__c productConfiguration : prodConfigs) {
			productConfiguration.Sales_Order__c = salesOrder.Id;
			productConfiguration.cscfga__Product_Basket__c = prodBaskets[0].Id;
			productConfiguration.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
			productConfiguration.Fulfilment_Item_Status__c = 'Paused';
			productConfiguration.Flight_Begin__c = Date.today().addDays(2);
			productConfiguration.csmso__Availability_Check_Status__c = 'Not Applicable';
			productConfiguration.Inventory_Available__c = 'No';
			productConfiguration.Overbook__c = false;
			productConfiguration.Served_By__c = 'DFP';
		}
		update prodConfigs;

		Test.startTest();
		ButtonSOApprovalStart button = new ButtonSOApprovalStart();
		button.performAction(salesOrder.Id);
		Test.stopTest();
	}

	/** @IsTest
		static void testButtonBaseSOFulfilmentInvokerWorker() {
			CS_utl_User.disableAllTriggers(UserInfo.getUserId());
			csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
			insert soapi;

			ButtonSOCheckAvail button = new ButtonSOCheckAvail();
			Account[] accs = TestDataSetupBasic.createAccounts(1);
			Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
			Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);

			csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
			salesOrder.SO_Lines_All_Valid__c = true;
			salesOrder.csmso__Opportunity__c = opps[0].Id;
			insert salesOrder;

			//Product Definition Creation.
			List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

			//Product Baskets  Creation.
			List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
					salesOrder
			});

			// create Ad Server (csdf__Ad_Server__c)
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

			// create Advert Assignment (csmso__Node_Advert_Assignment__c)
			csmso__Node_Advert_Assignment__c advertAssignment = new csmso__Node_Advert_Assignment__c();
			advertAssignment.Name = 'Test Market';
			advertAssignment.Product_Name__c = 'Test Product Name';
			advertAssignment.Rate_Type__c = 'CPM';
			advertAssignment.Rate_Type_Display__c = 'CPCV';
			advertAssignment.Line_Item_Type__c = 'Standard';
			advertAssignment.Inventory_sizes__c = '1000x1000';
			advertAssignment.Unique_Id__c = 'someUniqueTestId';
			advertAssignment.Product_Category__c = 'Standard Products';
			advertAssignment.Product_Group__c = 'Audio';
			advertAssignment.Line_Item_Category__c = 'House';
			advertAssignment.Product_Family__c = 'Audio';
			advertAssignment.Served_by__c = 'DFP';
			advertAssignment.Ad_Slot__c = 'Test Ad Slot';
			advertAssignment.Ad_Location_Description__c = 'Everywhere';
			advertAssignment.Ad_Server__c = adServer.Id;
			advertAssignment.Ad_Slot_Names__c = 'SPT_AD_Unit';
			advertAssignment.Invoice_GL_Code__c = '123456789';
			advertAssignment.Rev_Accrual_GL_Code__c = '123456789';
			advertAssignment.Priority__c = '6';
			advertAssignment.Expiration_Date__c = Date.today().addDays(-2);
			insert advertAssignment;

			//Product Configs creation.
			List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);
			for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
				pConfig.Sales_Order__c = salesOrder.Id;
				pConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Paused;
				pConfig.cscfga__Product_Basket__c = prodBaskets[0].Id;
				pConfig.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
				pConfig.Flight_Begin__c = Date.today().addDays(-2);
				pConfig.Flight_Begin_Logged_User_Timezone__c = Date.today().addDays(-2);
				pConfig.Served_By__c = 'DFP';
				pConfig.Digital_Product__c = advertAssignment.Id;
			}
			update prodConfigs;

			Test.startTest();
			Set<Id> currentConfigIds = new Set<Id>();
			for (cscfga__Product_Configuration__c pc : prodConfigs) {
				currentConfigIds.add(pc.Id);
			}
			button.performAction(salesOrder.Id);
			CS_ButtonBase.FulfilmentInvokerWorker fIW = new CS_ButtonBase.FulfilmentInvokerWorker(new Map<String, Object>{
					'retry' => 0,
					'configIds' => currentConfigIds,
					'className' => 'ButtonSOCheckAvail',
					'salesOrderId' => salesOrder.Id
			});
			fIW.doWork();
			Test.stopTest();
		}

		@IsTest
		static void testButtonBaseSOFulfilmentInvokerWorkerRetry() {
			CS_utl_User.disableAllTriggers(UserInfo.getUserId());
			csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
			insert soapi;

			ButtonSOCheckAvail button = new ButtonSOCheckAvail();
			Account[] accs = TestDataSetupBasic.createAccounts(1);
			Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
			Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);

			csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
			salesOrder.SO_Lines_All_Valid__c = true;
			salesOrder.csmso__Opportunity__c = opps[0].Id;
			insert salesOrder;

			//Product Definition Creation.
			List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

			//Product Baskets  Creation.
			List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
					salesOrder
			});

			// create Ad Server (csdf__Ad_Server__c)
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

			// create Advert Assignment (csmso__Node_Advert_Assignment__c)
			csmso__Node_Advert_Assignment__c advertAssignment = new csmso__Node_Advert_Assignment__c();
			advertAssignment.Name = 'Test Market';
			advertAssignment.Product_Name__c = 'Test Product Name';
			advertAssignment.Rate_Type__c = 'CPM';
			advertAssignment.Rate_Type_Display__c = 'CPCV';
			advertAssignment.Line_Item_Type__c = 'Standard';
			advertAssignment.Inventory_sizes__c = '1000x1000';
			advertAssignment.Unique_Id__c = 'someUniqueTestId';
			advertAssignment.Product_Category__c = 'Standard Products';
			advertAssignment.Product_Group__c = 'Audio';
			advertAssignment.Line_Item_Category__c = 'House';
			advertAssignment.Product_Family__c = 'Audio';
			advertAssignment.Served_by__c = 'DFP';
			advertAssignment.Ad_Slot__c = 'Test Ad Slot';
			advertAssignment.Ad_Location_Description__c = 'Everywhere';
			advertAssignment.Ad_Server__c = adServer.Id;
			advertAssignment.Ad_Slot_Names__c = 'SPT_AD_Unit';
			advertAssignment.Invoice_GL_Code__c = '123456789';
			advertAssignment.Rev_Accrual_GL_Code__c = '123456789';
			advertAssignment.Priority__c = '6';
			advertAssignment.Expiration_Date__c = Date.today().addDays(-2);
			insert advertAssignment;

			//Product Configs creation.
			List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);
			for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
				pConfig.Sales_Order__c = salesOrder.Id;
				pConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Paused;
				pConfig.cscfga__Product_Basket__c = prodBaskets[0].Id;
				pConfig.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
				pConfig.Flight_Begin__c = Date.today().addDays(-2);
				pConfig.Flight_Begin_Logged_User_Timezone__c = Date.today().addDays(-2);
				pConfig.Served_By__c = 'DFP';
				pConfig.Digital_Product__c = advertAssignment.Id;
			}
			update prodConfigs;

			Test.startTest();
			Set<Id> currentConfigIds = new Set<Id>();
			for (cscfga__Product_Configuration__c pc : prodConfigs) {
				currentConfigIds.add(pc.Id);
			}
			button.performAction(salesOrder.Id);
			CS_ButtonBase.FulfilmentInvokerWorker fIW = new CS_ButtonBase.FulfilmentInvokerWorker(new Map<String, Object>{
					'retry' => 6,
					'configIds' => currentConfigIds,
					'className' => 'ButtonSOCheckAvail',
					'salesOrderId' => salesOrder.Id
			});
			fIW.doWork();
			Test.stopTest();
		}

		@IsTest static void testSyncCreateFulfilmentItems(){
			CS_Custom_Settings__c settings = new CS_Custom_Settings__c();
			settings.Max_n_Templates_for_Sync_Execution__c = 10;
			settings.Max_n_Lines_for_Sync_Execution__c = 5;
			insert settings;

			Account testAccount = TestDataSetupSO.createAccount();
			insert testAccount;

			Contact testContact = TestDataSetupSO.createContact(testAccount);
			insert testContact;

			Opportunity testOpportunity = TestDataSetupSO.createOpportunity(testAccount, testContact);
			insert testOpportunity;

			csmso__Sales_Order__c testSalesOrder = TestDataSetupSO.createSalesOrder(testAccount, testOpportunity);
			insert testSalesOrder;

			csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(testSalesOrder, testAccount);
			testFulfilment.Sales_Order__c = testSalesOrder.id;
			insert testFulfilment;

			cscfga__Product_Basket__c testProductBasket = TestDataSetupTargetables.createProdBasket(testSalesOrder);
			insert testProductBasket;

			cscfga__Product_Configuration__c testConfiguration = TestDataSetupTargetables.createProdConfig(testProductBasket);
			insert testConfiguration;

			csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(testConfiguration, testSalesOrder, testFulfilment);
			insert testFulfilmentItem;

			CS_ButtonBase base = new CS_ButtonBase();
			Test.startTest();
			base.performAction(testSalesOrder.Id);
			base.createFulfilmentItems();
			Test.stopTest();
		}

		@IsTest static void testAsyncCreateFulfilmentItems(){
			CS_Custom_Settings__c settings = new CS_Custom_Settings__c();
			settings.Max_n_Templates_for_Sync_Execution__c = 10;
			settings.Max_n_Lines_for_Sync_Execution__c = 3;
			insert settings;

			Account testAccount = TestDataSetupSO.createAccount();
			insert testAccount;

			Contact testContact = TestDataSetupSO.createContact(testAccount);
			insert testContact;

			Opportunity testOpportunity = TestDataSetupSO.createOpportunity(testAccount, testContact);
			insert testOpportunity;

			csmso__Sales_Order__c testSalesOrder = TestDataSetupSO.createSalesOrder(testAccount, testOpportunity);
			insert testSalesOrder;

			csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(testSalesOrder, testAccount);
			testFulfilment.Sales_Order__c = testSalesOrder.id;
			insert testFulfilment;

			for (Integer i = 0; i < 5; i++) {
				cscfga__Product_Basket__c testProductBasket = TestDataSetupTargetables.createProdBasket(testSalesOrder);
				insert testProductBasket;

				cscfga__Product_Configuration__c testConfiguration = TestDataSetupTargetables.createProdConfig(testProductBasket);
				insert testConfiguration;

				csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(testConfiguration, testSalesOrder, testFulfilment);
				testFulfilmentItem.csdf__Name__c = 'Test'+i;
				insert testFulfilmentItem;
			}

			CS_ButtonBase base = new CS_ButtonBase();
			Test.startTest();
			base.performAction(testSalesOrder.Id);
			base.createFulfilmentItems();
			Test.stopTest();
		}*/
}
@IsTest
private class CS_FulfilmentUpdateWorkerTest {
	private static Map<String, Object> params;
	private static List<csmso__Sales_Order__c> salesOrders;
	private static List<csdf__Fulfilment__c> fulfilments;
	private static List<csdf__Fulfilment_Item__c> fulfilmentItems;

	private static void createTestData() {
		params = new Map<String, Object>();
		salesOrders = new List<csmso__Sales_Order__c>();
		fulfilments = new List<csdf__Fulfilment__c>();
		fulfilmentItems = new List<csdf__Fulfilment_Item__c>();

		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.X3rd_Party_Actuals_Rolling_Days__c = 10;
		insert cs;

		Account[] accs = TestDataSetupBasic.createAccounts(5);
		Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs, cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.SO_Lines_All_Valid__c = true;
		insert salesOrder;

		salesOrders.add(salesOrder);

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{salesOrder});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

		List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1, new List<csmso__Sales_Order__c>{salesOrder}, accs);
		fulfilments.addAll(fulfilment);

		List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1, fulfilment, prodConfigs);
		fulfilmentItem[0].csdf__Flight_Beginning__c = Date.today().addDays(4);
		fulfilmentItem[0].csdf__Type__c = 'Standard';
		fulfilmentItem[0].Served_By__c = 'DFP';
		update fulfilmentItem;

		fulfilmentItems.addAll(fulfilmentItem);

		CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = salesOrder.Id;
		insert salesOrderSchedule;

		// create Business Unit (csmso__Business_Unit__c)
		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Test Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = 'Test Sales Ledger Code';
		businessUnit.Unique_Id__c = 'Test Unique Id Business Unit';
		insert businessUnit;

		// create geo targeting
		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'United States';
		geoItem.csdf__Ad_Server_Id__c = '2840';
		insert geoItem;

		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Europe/London';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
		insert bookingTimeZone;

		// create Market (csmso__Product_Node__c)
		csmso__Product_Node__c market = new csmso__Product_Node__c();
		market.Name = 'Test Market';
		market.csmso__Description__c = 'Test Market Description';
		market.csmso__Business_Unit__c = businessUnit.Id;
		market.CurrencyIsoCode = 'USD';
		market.Unique_Id__c = 'Test Market Unique Id';
		market.csmso__Media_Types__c = 'Desktop';
		market.Geo_Targeting__c = geoItem.Id;
		market.Sponsorship_Booking_Timezone__c = bookingTimeZone.Id;
		market.NAA_supported_currency__c = 'SGD';
		insert market;

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
		insert advertAssignment;

		// create Rate Card (csmso__Rate_Card__c)
		csmso__Rate_Card__c rateCard = new csmso__Rate_Card__c();
		rateCard.Short_Description__c = 'Test Short Description Rate Card';
		rateCard.Type__c = 'Base';
		rateCard.csmso__Product_Node__c = market.Id;
		rateCard.csmso__From_Date__c = Date.today();
		rateCard.csmso__To_Date__c = Date.today().addDays(5);
		rateCard.CurrencyIsoCode = 'USD';
		rateCard.Unique_Id__c = 'Test Unique Id Rate Card';
		rateCard.Minimum_Deal_Value__c = 0;
		rateCard.Maximum_Production_Cost__c = 12;
		rateCard.Order_Type__c = 'Direct Commercial';
		insert rateCard;

		// create Rate Card Item Price (csmso__Rate_Card_Item_Price__c)
		csmso__Rate_Card_Item_Price__c rateCardItemPrice = new csmso__Rate_Card_Item_Price__c();
		rateCardItemPrice.csmso__Rate_Card__c = rateCard.Id;
		rateCardItemPrice.csmso__Advert_Assignment__c = advertAssignment.Id;
		rateCardItemPrice.Account_Tier__c = 'Tier 3';
		rateCardItemPrice.List_Floor__c = 'List';
		rateCardItemPrice.csmso__Product_Node__c = market.Id;
		rateCardItemPrice.CurrencyIsoCode = 'USD';
		rateCardItemPrice.Unique_Id__c = 'Test Unique Id Rate Card Item Price';
		rateCardItemPrice.csmso__Price_Per_Unit__c = 12;
		rateCardItemPrice.Minimum_Line_Value__c = 4;
		insert rateCardItemPrice;

		//CS Biling Schedule
		CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
		bScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		bScheduleHeader.Under_IFC__c = true;
		insert bScheduleHeader;

		//CS Revenue Schedule
		CS_Revenue_Schedule__c rScheduleHeader = new CS_Revenue_Schedule__c();
		rScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert rScheduleHeader;

		for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
			pConfig.Sales_Order__c = salesOrder.Id;
			pConfig.Reserve_Inventory__c = true;
			pConfig.Inventory_Available__c = 'Yes';
			//pConfig.Fulfilment_Item__c = fulfilmentItem[0].Id;
		}
		update prodConfigs;

		cscfga__Product_Configuration__c pc = [
				SELECT Id, Sales_Order__c
				FROM cscfga__Product_Configuration__c
				LIMIT 1
		][0];

		// put all params
		params.put('salesOrders', salesOrders);
		params.put('fulfilments', fulfilments);
		params.put('fulfilmentItems', fulfilmentItems);
	}

	@IsTest(SeeAllData=false)
	static void testFulfilmentUpdateWorker() {
		createTestData();

		Test.startTest();
		CS_FulfilmentUpdateWorker fulfilmentUpdateWorker = new CS_FulfilmentUpdateWorker(params);
		CS_FulfilmentUpdateWorker.prepareWork(fulfilmentItems, fulfilments, salesOrders);
		fulfilmentUpdateWorker.doWork();
		Test.stopTest();
	}

	@IsTest(SeeAllData=false)
	static void testFulfilmentUpdateWorkerNegative() {
		createTestData();

		for (csdf__Fulfilment__c fulfilment : fulfilments) {
			fulfilment.csdf__Advertiser__c = null;
		}

		params.remove('fulfilments');
		params.put('fulfilments', fulfilments);

		for (csdf__Fulfilment_Item__c fi : fulfilmentItems) {
			fi.csdf__Fulfilment__c = null;
		}

		params.remove('fulfilmentItems');
		params.put('fulfilmentItems', fulfilmentItems);

		Test.startTest();
		CS_FulfilmentUpdateWorker fulfilmentUpdateWorker = new CS_FulfilmentUpdateWorker(params);
		//CS_FulfilmentUpdateWorker.prepareWork(fulfilmentItems, fulfilments, salesOrders);
		fulfilmentUpdateWorker.doWork();
		Test.stopTest();
	}
}
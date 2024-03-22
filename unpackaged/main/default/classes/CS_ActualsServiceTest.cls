@IsTest
private class CS_ActualsServiceTest {
	private static csmso__Sales_Order__c salesOrder;
	private static CS_Billing_Schedule__c bScheduleHeader;
	private static CS_Revenue_Schedule__c rScheduleHeader;
	private static CS_Billing_Schedule_Item__c bschedule;
	private static CS_Revenue_Schedule_Item__c rSchedule;
	private static Third_Party_Actual__c thirdPartyActual;

	private static void createTestData() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.X3rd_Party_Actuals_Rolling_Days__c = 10;
		cs.Ad_Server_Network_Code__c = 'Test Network Code';
		insert cs;

		Account[] accs = TestDataSetupBasic.createAccounts(5);
		Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs, cons);

		salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.SO_Lines_All_Valid__c = true;
		insert salesOrder;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{salesOrder});

		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Name = 'Europe/London';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
		bookingTimeZone.Booking_Time_Zone_Country__c = 'British Summer Time';
		insert bookingTimeZone;

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);
		prodConfigs[0].Booking_Timezone__c = bookingTimeZone.Id;
		prodConfigs[0].Served_By__c = 'DFP';
		update prodConfigs;

		List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1, new List<csmso__Sales_Order__c>{salesOrder}, accs);

		List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1, fulfilment, prodConfigs);
		fulfilmentItem[0].csdf__Flight_Beginning__c = Date.today().addDays(4);
		fulfilmentItem[0].csdf__Type__c = 'Standard';
		fulfilmentItem[0].Served_By__c = 'DFP';
		update fulfilmentItem;

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
		bScheduleHeader = new CS_Billing_Schedule__c();
		bScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		bScheduleHeader.Under_IFC__c = true;
		insert bScheduleHeader;

		//CS Revenue Schedule
		rScheduleHeader = new CS_Revenue_Schedule__c();
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

		//CS Biling Schedule Item
		bschedule = new CS_Billing_Schedule_Item__c();
		bschedule.Product_Configuration__c = pc.Id;
		bschedule.Status__c = 'Locked';
		bschedule.Sales_Order__c = pc.Sales_Order__c;
		bschedule.DFP_Actuals__c = 100;
		bschedule.Net_Rate__c = 100.0;
		bschedule.Billing_Period_Start_Date__c = Date.today().addDays(-4);
		bschedule.Billing_Period_End_Date__c = Date.today().addDays(4);
		bschedule.Billing_Schedule__c = bScheduleHeader.Id;
		bschedule.DFP_Order_Line_ID__c = 'External ID Test 123';
		bschedule.X3rd_Party_Ad_Server__c = 'Test Server Name';
		bschedule.Flight_Begin_GMT__c = System.now().addDays(-4);
		bschedule.Flight_End_GMT__c = System.now().addDays(4);
		bschedule.Insertion_Unit_Type__c = 'CPC';
		insert bschedule;

		//CS Revenue Schedule Item
		rSchedule = new CS_Revenue_Schedule_Item__c();
		rSchedule.Sales_Order__c = pc.Sales_Order__c;
		rSchedule.Product_Configuration__c = pc.Id;
		rSchedule.Status__c = 'Locked';
		rSchedule.Rev_Rec_Period_Start_Date__c = Date.today().addDays(-4);
		rSchedule.Rev_Rec_Period_End_Date__c = Date.today().addDays(4);
		rSchedule.Revenue_Schedule__c = rScheduleHeader.Id;
		rSchedule.DFP_Order_Line_ID__c = 'External ID Test 123';
		rSchedule.Flight_Begin_GMT__c = System.now().addDays(-4);
		rSchedule.Flight_End_GMT__c = System.now().addDays(4);
		rSchedule.Insertion_Unit_Type__c = 'CPC';
		insert rSchedule;

		//Custom Report Definition
		csdf__Custom_Report_Definition__c customReportDefinition = new csdf__Custom_Report_Definition__c();
		customReportDefinition.Name = 'Test Custom Report Definition Name';
		customReportDefinition.csdf__Ad_Server__c = adServer.Id;
		customReportDefinition.csdf__Query_Id__c = 'Test Query Id';
		customReportDefinition.csdf__Result_Object_Name__c = 'Test Result Object Name';
		insert customReportDefinition;

		//Custom Report Execution
		csdf__Custom_Report_Execution__c customReportExecution = new csdf__Custom_Report_Execution__c();
		customReportExecution.Name = 'Test Custom Report Execution Name';
		customReportExecution.csdf__Custom_Report_Definition__c = customReportDefinition.Id;
		customReportExecution.csdf__Report_Status__c = 'Completed';
		insert customReportExecution;

		// Third Party Actual
		thirdPartyActual = new Third_Party_Actual__c();
		thirdPartyActual.CurrencyIsoCode = 'USD';
		thirdPartyActual.Impressions__c = 1000;
		thirdPartyActual.Total_Impressions__c = 800;
		thirdPartyActual.Clicks__c = 300;
		thirdPartyActual.Report_Date__c = Date.today();
		thirdPartyActual.Order_Line_Id__c = 'External ID Test 123';
		thirdPartyActual.Local_Server_Name__c = '';
		insert thirdPartyActual;

		CS_DFP_Actuals_By_Hour_Report_Data__c dfpActualsByHourReportData = new CS_DFP_Actuals_By_Hour_Report_Data__c();
		dfpActualsByHourReportData.CurrencyIsoCode = 'USD';
		dfpActualsByHourReportData.Impressions__c = 1000;
		dfpActualsByHourReportData.Total_Impressions__c = 800;
		dfpActualsByHourReportData.Clicks__c = 300;
		dfpActualsByHourReportData.Report_Date__c = Date.today();
		dfpActualsByHourReportData.Order_Line_Id__c = 'External ID Test 123';
		insert dfpActualsByHourReportData;
	}

	@IsTest(SeeAllData=false)
	static void testActualsServiceBillingDoCalculate() {
		createTestData();

		Test.startTest();
		Type processService = Type.forName('CS_ActualsService.CS_BillingActualsService');
		CS_ActualsService actualsServiceBilling = (CS_ActualsService) processService.newInstance();
		actualsServiceBilling.doCalculate(new Set<Id>{salesOrder.Id}, Date.today().addDays(1));
		Test.stopTest();
	}

	@IsTest(SeeAllData=false)
	static void testActualsServiceRevenueDoCalculate() {
		createTestData();

		Test.startTest();
		Type processService = Type.forName('CS_ActualsService.CS_RevenueActualsService');
		CS_ActualsService actualsServiceRevenue = (CS_ActualsService) processService.newInstance();
		actualsServiceRevenue.doCalculate(new Set<Id>{salesOrder.Id}, Date.today());
		Test.stopTest();
	}

	@IsTest(SeeAllData=false)
	static void testActualsServiceRevenueGetStartDate() {
		createTestData();

		Test.startTest();
		Type processService = Type.forName('CS_ActualsService.CS_RevenueActualsService');
		CS_ActualsService actualsServiceRevenue = (CS_ActualsService) processService.newInstance();
		Date startDate = actualsServiceRevenue.getStartDate(rSchedule);
		System.assertEquals(startDate, rSchedule.Rev_Rec_Period_Start_Date__c);
		Test.stopTest();
	}

	@IsTest(SeeAllData=false)
	static void testActualsServiceRevenueGetEndDate() {
		createTestData();

		Test.startTest();
		Type processService = Type.forName('CS_ActualsService.CS_RevenueActualsService');
		CS_ActualsService actualsServiceRevenue = (CS_ActualsService) processService.newInstance();
		Date endDate = actualsServiceRevenue.getEndDate(rSchedule);
		System.assertEquals(endDate, rSchedule.Rev_Rec_Period_End_Date__c);
		Test.stopTest();
	}

	/*
	@isTest(seeAllData=false)
	static void testActualsServiceBillingIsAplicableTrue() {
		createTestData();

		Test.startTest();
		Type processService = Type.forName('CS_ActualsService.CS_BillingActualsService');
		CS_ActualsService actualsServiceBilling = (CS_ActualsService) processService.newInstance();
		Boolean isAplicable = actualsServiceBilling.isApplicable(dfpActualsReportData, bSchedule, new Set<Date>{Date.today().addDays(1)}, null);
		System.assertEquals(isAplicable, true);
		Test.stopTest();
	}
	*/

	/*
	@isTest(seeAllData=false)
	static void testActualsServiceBillingIsAplicableFalse() {
		createTestData();

		Test.startTest();
		Type processService = Type.forName('CS_ActualsService.CS_BillingActualsService');
		CS_ActualsService actualsServiceBilling = (CS_ActualsService) processService.newInstance();
		Boolean isAplicable = actualsServiceBilling.isApplicable(dfpActualsReportData, bSchedule, new Set<Date>{Date.today().addDays(1)}, Date.today());
		System.assertEquals(isAplicable, false);
		Test.stopTest();
	}
	*/

	/*
	@isTest(seeAllData=false)
	static void testActualsServiceBillingTotalClosedDfpActuals() {
		createTestData();

		Test.startTest();
		Type processService = Type.forName('CS_ActualsService.CS_BillingActualsService');
		CS_ActualsService actualsServiceBilling = (CS_ActualsService) processService.newInstance();
		Integer totalClosedDfpActuals = actualsServiceBilling.getTotalClosedDfpActuals(bScheduleHeader);
		System.assertEquals(totalClosedDfpActuals, 0);
		Test.stopTest();
	}
	*/

	/*
	@isTest(seeAllData=false)
	static void testActualsServiceBillingTotalClosed3rdPartyActuals() {
		createTestData();

		Test.startTest();
		Type processService = Type.forName('CS_ActualsService.CS_BillingActualsService');
		CS_ActualsService actualsServiceBilling = (CS_ActualsService) processService.newInstance();
		Integer totalClosed3rdPartyActuals = actualsServiceBilling.getTotalClosed3rdPartyActuals(bScheduleHeader);
		System.assertEquals(totalClosed3rdPartyActuals, 0);
		Test.stopTest();
	}
	*/

	/*
	@isTest(seeAllData=false)
	static void testActualsServiceRevenueIsAplicableTrue() {
		createTestData();

		Test.startTest();
		Type processService = Type.forName('CS_ActualsService.CS_RevenueActualsService');
		CS_ActualsService actualsServiceRevenue = (CS_ActualsService) processService.newInstance();
		Boolean isAplicable = actualsServiceRevenue.isApplicable(dfpActualsReportData, rSchedule, new Set<Date>{Date.today().addDays(1)}, null);
		System.assertEquals(isAplicable, true);
		Test.stopTest();
	}
	*/

	/*
	@isTest(seeAllData=false)
	static void testActualsServiceRevenueIsAplicableFalse() {
		createTestData();

		Test.startTest();
		Type processService = Type.forName('CS_ActualsService.CS_RevenueActualsService');
		CS_ActualsService actualsServiceRevenue = (CS_ActualsService) processService.newInstance();
		Boolean isAplicable = actualsServiceRevenue.isApplicable(dfpActualsReportData, rSchedule, new Set<Date>{Date.today().addDays(1)}, Date.today());
		System.assertEquals(isAplicable, false);
		Test.stopTest();
	}
	*/

	/*
	@isTest(seeAllData=false)
	static void testActualsServiceRevenueTotalClosedDfpActuals() {
		createTestData();

		Test.startTest();
		Type processService = Type.forName('CS_ActualsService.CS_RevenueActualsService');
		CS_ActualsService actualsServiceRevenue = (CS_ActualsService) processService.newInstance();
		Integer totalClosedDfpActuals = actualsServiceRevenue.getTotalClosedDfpActuals(rScheduleHeader);
		System.assertEquals(totalClosedDfpActuals, 0);
		Test.stopTest();
	}
	*/

	/*
	@isTest(seeAllData=false)
	static void testActualsServiceRevenueTotalClosed3rdPartyActuals() {
		createTestData();

		Test.startTest();
		Type processService = Type.forName('CS_ActualsService.CS_RevenueActualsService');
		CS_ActualsService actualsServiceRevenue = (CS_ActualsService) processService.newInstance();
		Integer totalClosed3rdPartyActuals = actualsServiceRevenue.getTotalClosed3rdPartyActuals(rScheduleHeader);
		System.assertEquals(totalClosed3rdPartyActuals, 0);
		Test.stopTest();
	}
	*/
}
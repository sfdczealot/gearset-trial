@IsTest
private class CS_P_BillingScheduleItemCalcTest {
	private static csmso__Rate_Card__c rateCard;
	private static csmso__Product_Node__c market;
	private static CS_Billing_Schedule_Item__c bschedule;

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
		Account acc2 = TestDataSetupTargetables.createAccount();
		insert acc2;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.SO_Lines_Number_lines_RI__c = 0;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_PRICE_RECALCULATION_REQUIRED;
		salesOrder.csmso__Opportunity__c = opp.Id;
		salesOrder.csmso__Advertiser__c = acc.Id;
		salesOrder.Bill_To_Account__c = acc2.Id;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Purchase_Order_Number__c = null;
		salesOrder.IO_Template__c = 'Spotify';
		salesOrder.csmso__Booking_Contact__c = con.Id;
		salesOrder.SO_Lines_All_Valid__c = false;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Ad_Server_Inventory_Avail_Ov__c = 10;
		insert salesOrder;

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				salesOrder
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, new List<cscfga__Product_Definition__c>{
				testProDef
		});

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
		bookingTimeZone.Name = 'Europe/London';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
		bookingTimeZone.Booking_Time_Zone_Country__c = 'British Summer Time';
		insert bookingTimeZone;

		// create Market (csmso__Product_Node__c)
		market = new csmso__Product_Node__c();
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
		rateCard = new csmso__Rate_Card__c();
		rateCard.Short_Description__c = 'Test Short Description Rate Card';
		rateCard.Type__c = 'Base';
		rateCard.csmso__Product_Node__c = market.Id;
		rateCard.csmso__From_Date__c = Date.today().addDays(-30);
		rateCard.csmso__To_Date__c = Date.today().addDays(30);
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
		rateCardItemPrice.Account_Tier__c = 'Tier 1';
		rateCardItemPrice.List_Floor__c = 'List';
		rateCardItemPrice.csmso__Product_Node__c = market.Id;
		rateCardItemPrice.CurrencyIsoCode = 'USD';
		rateCardItemPrice.Unique_Id__c = 'Test Unique Id Rate Card Item Price';
		rateCardItemPrice.csmso__Price_Per_Unit__c = 12;
		rateCardItemPrice.Minimum_Line_Value__c = 4;
		insert rateCardItemPrice;

		CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
		sOs.Sales_Order__c = salesOrder.Id;
		insert sOs;

		CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
		bScheduleHeader.CS_Sales_Order_Schedule__c = sOs.Id;
		bScheduleHeader.Under_IFC__c = true;
		insert bScheduleHeader;

		for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
			pConfig.Sales_Order__c = salesOrder.Id;
			pConfig.Flight_Begin__c = Date.today();
		}
		update prodConfigs;

		cscfga__Product_Configuration__c pc = [
				SELECT Id, Sales_Order__c
				FROM cscfga__Product_Configuration__c
				LIMIT 1
		][0];

		bschedule = new CS_Billing_Schedule_Item__c();
		bschedule.Product_Configuration__c = pc.Id;
		bschedule.Status__c = 'Locked';
		bschedule.Sales_Order__c = pc.Sales_Order__c;
		bschedule.DFP_Actuals__c = 100;
		bschedule.Net_Rate__c = 100.0;
		bschedule.Gross_Rate__c = 20;
		bschedule.Billing_Period_Start_Date__c = Date.today().addDays(-4);
		bschedule.Billing_Gross_Amount__c = 5;
		bschedule.Billing_Schedule__c = bScheduleHeader.Id;
		bschedule.Billing_Quantity__c = 10;
		bschedule.Insertion_Unit_Type__c = 'CPM';
		bschedule.Billing_Date__c = Date.today().addDays(-4);
		insert bschedule;
	}

	@IsTest
	static void billingScheduleItemCalcTest() {
		createTestData();

		Test.startTest();
		CS_P_BillingScheduleItemCalc billingScheduleItemCalc = new CS_P_BillingScheduleItemCalc();

		billingScheduleItemCalc.isRecordEligible((SObject) bschedule);
		billingScheduleItemCalc.logic();

		update bschedule;

		CS_Billing_Schedule_Item__c bsiNew = [
				SELECT Id,
						Billing_Net_Amount__c,
						Billing_Gross_Amount__c,
						Billing_Amount__c
				FROM CS_Billing_Schedule_Item__c
				LIMIT 1
		];

		System.assertEquals(bsiNew.Billing_Net_Amount__c, 1);
		System.assertEquals(bsiNew.Billing_Gross_Amount__c, 0.2);
		System.assertEquals(bsiNew.Billing_Amount__c, 0.2);

		Test.stopTest();
	}
}
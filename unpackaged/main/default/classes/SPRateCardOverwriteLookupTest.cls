@IsTest
public class SPRateCardOverwriteLookupTest {

	@IsTest
	public static void test_rateCardPerformAction() {
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

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

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
		bookingTimeZone.Name = 'GMT';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+00:00';
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Greenwich Mean Time';
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

		Map<String, String> searchFieldsMap = new Map<String, String>();
		searchFieldsMap.put('Market', market.Id);
		searchFieldsMap.put('Order Type', 'Direct Commercial');
		searchFieldsMap.put('SO Currency', 'USD');
		searchFieldsMap.put('Package Id', '');
		searchFieldsMap.put('Node Advert Assignments', advertAssignment.Id);

		String prodDefinitionID;

		Test.startTest();
		SPRateCardOverwriteLookup rciplkp = new SPRateCardOverwriteLookup();
		rciplkp.getRequiredAttributes();
		Object[] result = rciplkp.doDynamicLookupSearch(searchFieldsMap, prodDefinitionID);
		Test.stopTest();

		System.assertNotEquals(null, result);
	}

	@IsTest
	public static void test_rateCardItemPerformAction() {
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

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

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
		bookingTimeZone.Name = 'GMT';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+00:00';
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Greenwich Mean Time';
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

		cscfga__Configuration_Offer__c confOffer = new cscfga__Configuration_Offer__c();
		confOffer.Name = 'testOffer';
		confOffer.Rate_Card__c = rateCard.Id;
		confOffer.Account_Tier__c = 'Tier 1';
		confOffer.Product_Node__c = market.Id;
		insert confOffer;

		// create Rate Card (csmso__Rate_Card__c)
		csmso__Rate_Card__c rateCardTwo = new csmso__Rate_Card__c();
		rateCardTwo.Short_Description__c = 'Test Short Description Rate Card2';
		rateCardTwo.Type__c = 'Customer Price List';
		rateCardTwo.csmso__Product_Node__c = market.Id;
		rateCardTwo.csmso__From_Date__c = Date.today().addDays(-30);
		rateCardTwo.csmso__To_Date__c = Date.today().addDays(30);
		rateCardTwo.CurrencyIsoCode = 'USD';
		rateCardTwo.Unique_Id__c = 'Test Unique Id Rate Card6546';
		rateCardTwo.Minimum_Deal_Value__c = 0;
		rateCardTwo.Maximum_Production_Cost__c = 12;
		rateCardTwo.Order_Type__c = 'Direct Commercial';
		rateCardTwo.Account__c = acc.Id;
		insert rateCardTwo;

		// create Rate Card Item Price (csmso__Rate_Card_Item_Price__c)
		csmso__Rate_Card_Item_Price__c rateCardItemPriceTwo = new csmso__Rate_Card_Item_Price__c();
		rateCardItemPriceTwo.csmso__Rate_Card__c = rateCardTwo.Id;
		rateCardItemPriceTwo.csmso__Advert_Assignment__c = advertAssignment.Id;
		rateCardItemPriceTwo.Account_Tier__c = 'Tier 1';
		rateCardItemPriceTwo.List_Floor__c = 'List';
		rateCardItemPriceTwo.csmso__Product_Node__c = market.Id;
		rateCardItemPriceTwo.CurrencyIsoCode = 'USD';
		rateCardItemPriceTwo.Unique_Id__c = 'Test Unique Id Rate Card Item Price65465';
		rateCardItemPriceTwo.csmso__Price_Per_Unit__c = 12;
		rateCardItemPriceTwo.Minimum_Line_Value__c = 4;
		rateCardItemPriceTwo.Package__c = confOffer.Id;
		insert rateCardItemPriceTwo;

		// create Rate Card (csmso__Rate_Card__c)
		csmso__Rate_Card__c rateCardThree = new csmso__Rate_Card__c();
		rateCardThree.Short_Description__c = 'Test Short Description Rate Card3';
		rateCardThree.Type__c = 'Customer Price List';
		rateCardThree.csmso__Product_Node__c = market.Id;
		rateCardThree.csmso__From_Date__c = Date.today().addDays(-30);
		rateCardThree.csmso__To_Date__c = Date.today().addDays(30);
		rateCardThree.CurrencyIsoCode = 'HRK';
		rateCardThree.Unique_Id__c = 'Test Unique Id Rate Card9195';
		rateCardThree.Minimum_Deal_Value__c = 0;
		rateCardThree.Maximum_Production_Cost__c = 12;
		rateCardThree.Order_Type__c = 'Direct Commercial';
		rateCardThree.Account__c = acc.Id;
		insert rateCardThree;

		Map<String, String> searchFieldsMap = new Map<String, String>();
		searchFieldsMap.put('Market', market.Id);
		searchFieldsMap.put('Order Type', 'Direct Commercial');
		searchFieldsMap.put('SO Currency', 'USD');
		searchFieldsMap.put('Package Id', confOffer.Id);
		searchFieldsMap.put('Node Advert Assignments', advertAssignment.Id);

		String prodDefinitionID;

		Test.startTest();
		SPRateCardOverwriteLookup rciplkp = new SPRateCardOverwriteLookup();
		rciplkp.getRequiredAttributes();
		Object[] result = rciplkp.doDynamicLookupSearch(searchFieldsMap, prodDefinitionID);
		Test.stopTest();

		System.assertNotEquals(null, result);
	}

	@IsTest
	public static void test_rateCardItemPerformActionThree() {
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

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

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
		bookingTimeZone.Name = 'GMT';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+00:00';
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Greenwich Mean Time';
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

		cscfga__Configuration_Offer__c confOffer = new cscfga__Configuration_Offer__c();
		confOffer.Name = 'testOffer';
		confOffer.Rate_Card__c = rateCard.Id;
		confOffer.Account_Tier__c = 'Tier 1';
		confOffer.Product_Node__c = market.Id;
		insert confOffer;

		// create Rate Card (csmso__Rate_Card__c)
		csmso__Rate_Card__c rateCardTwo = new csmso__Rate_Card__c();
		rateCardTwo.Short_Description__c = 'Test Short Description Rate Card2';
		rateCardTwo.Type__c = 'Customer Price List';
		rateCardTwo.csmso__Product_Node__c = market.Id;
		rateCardTwo.csmso__From_Date__c = Date.today().addDays(-30);
		rateCardTwo.csmso__To_Date__c = Date.today().addDays(30);
		rateCardTwo.CurrencyIsoCode = 'USD';
		rateCardTwo.Unique_Id__c = 'Test Unique Id Rate Card6546';
		rateCardTwo.Minimum_Deal_Value__c = 0;
		rateCardTwo.Maximum_Production_Cost__c = 12;
		rateCardTwo.Order_Type__c = 'Direct Commercial';
		rateCardTwo.Account__c = acc.Id;
		insert rateCardTwo;

		// create Rate Card Item Price (csmso__Rate_Card_Item_Price__c)
		csmso__Rate_Card_Item_Price__c rateCardItemPriceTwo = new csmso__Rate_Card_Item_Price__c();
		rateCardItemPriceTwo.csmso__Rate_Card__c = rateCardTwo.Id;
		rateCardItemPriceTwo.csmso__Advert_Assignment__c = advertAssignment.Id;
		rateCardItemPriceTwo.Account_Tier__c = 'Tier 1';
		rateCardItemPriceTwo.List_Floor__c = 'List';
		rateCardItemPriceTwo.csmso__Product_Node__c = market.Id;
		rateCardItemPriceTwo.CurrencyIsoCode = 'USD';
		rateCardItemPriceTwo.Unique_Id__c = 'Test Unique Id Rate Card Item Price65465';
		rateCardItemPriceTwo.csmso__Price_Per_Unit__c = 12;
		rateCardItemPriceTwo.Minimum_Line_Value__c = 4;
		rateCardItemPriceTwo.Package__c = confOffer.Id;
		insert rateCardItemPriceTwo;

		Map<String, String> searchFieldsMap = new Map<String, String>();
		searchFieldsMap.put('Market', market.Id);
		searchFieldsMap.put('Order Type', 'Direct Commercial');
		searchFieldsMap.put('SO Currency', 'USD');
		searchFieldsMap.put('Package Id', confOffer.Id);
		searchFieldsMap.put('Node Advert Assignments', advertAssignment.Id);

		String prodDefinitionID;

		Test.startTest();
		SPRateCardOverwriteLookup rciplkp = new SPRateCardOverwriteLookup();
		rciplkp.getRequiredAttributes();
		Object[] result = rciplkp.doDynamicLookupSearch(searchFieldsMap, prodDefinitionID);
		Test.stopTest();

		System.assertNotEquals(null, result);
	}

	@IsTest
	public static void test_rateCardItemPerformActionFour() {
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

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

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
		bookingTimeZone.Name = 'GMT';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+00:00';
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Greenwich Mean Time';
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

		cscfga__Configuration_Offer__c confOffer = new cscfga__Configuration_Offer__c();
		confOffer.Name = 'testOffer';
		confOffer.Rate_Card__c = rateCard.Id;
		confOffer.Account_Tier__c = 'Tier 1';
		confOffer.Product_Node__c = market.Id;
		insert confOffer;

		// create Rate Card (csmso__Rate_Card__c)
		csmso__Rate_Card__c rateCardTwo = new csmso__Rate_Card__c();
		rateCardTwo.Short_Description__c = 'Test Short Description Rate Card2';
		rateCardTwo.Type__c = 'Customer Price List';
		rateCardTwo.csmso__Product_Node__c = market.Id;
		rateCardTwo.csmso__From_Date__c = Date.today().addDays(-30);
		rateCardTwo.csmso__To_Date__c = Date.today().addDays(30);
		rateCardTwo.CurrencyIsoCode = 'USD';
		rateCardTwo.Unique_Id__c = 'Test Unique Id Rate Card6546';
		rateCardTwo.Minimum_Deal_Value__c = 0;
		rateCardTwo.Maximum_Production_Cost__c = 12;
		rateCardTwo.Order_Type__c = 'Direct Commercial';
		rateCardTwo.Account__c = acc.Id;
		insert rateCardTwo;

		// create Rate Card (csmso__Rate_Card__c)
		csmso__Rate_Card__c rateCardThree = new csmso__Rate_Card__c();
		rateCardThree.Short_Description__c = 'Test Short Description Rate Card3';
		rateCardThree.Type__c = 'Customer Price List';
		rateCardThree.csmso__Product_Node__c = market.Id;
		rateCardThree.csmso__From_Date__c = Date.today().addDays(-30);
		rateCardThree.csmso__To_Date__c = Date.today().addDays(30);
		rateCardThree.CurrencyIsoCode = 'USD';
		rateCardThree.Unique_Id__c = 'Test Unique Id Rate Card918516';
		rateCardThree.Minimum_Deal_Value__c = 0;
		rateCardThree.Maximum_Production_Cost__c = 12;
		rateCardThree.Order_Type__c = 'Direct Commercial';
		rateCardThree.Account__c = acc.Id;
		insert rateCardThree;

		// create Rate Card Item Price (csmso__Rate_Card_Item_Price__c)
		csmso__Rate_Card_Item_Price__c rateCardItemPriceTwo = new csmso__Rate_Card_Item_Price__c();
		rateCardItemPriceTwo.csmso__Rate_Card__c = rateCardTwo.Id;
		rateCardItemPriceTwo.csmso__Advert_Assignment__c = advertAssignment.Id;
		rateCardItemPriceTwo.Account_Tier__c = 'Tier 1';
		rateCardItemPriceTwo.List_Floor__c = 'List';
		rateCardItemPriceTwo.csmso__Product_Node__c = market.Id;
		rateCardItemPriceTwo.CurrencyIsoCode = 'USD';
		rateCardItemPriceTwo.Unique_Id__c = 'Test Unique Id Rate Card Item Price65465';
		rateCardItemPriceTwo.csmso__Price_Per_Unit__c = 12;
		rateCardItemPriceTwo.Minimum_Line_Value__c = 4;
		insert rateCardItemPriceTwo;

		Map<String, String> searchFieldsMap = new Map<String, String>();
		searchFieldsMap.put('Market', market.Id);
		searchFieldsMap.put('Order Type', 'Direct Commercial');
		searchFieldsMap.put('SO Currency', 'USD');
		searchFieldsMap.put('Package Id', confOffer.Id);
		searchFieldsMap.put('Node Advert Assignments', advertAssignment.Id);

		String prodDefinitionID;

		Test.startTest();
		SPRateCardOverwriteLookup rciplkp = new SPRateCardOverwriteLookup();
		rciplkp.getRequiredAttributes();
		Object[] result = rciplkp.doDynamicLookupSearch(searchFieldsMap, prodDefinitionID);
		Test.stopTest();

		System.assertNotEquals(null, result);
	}

	@IsTest
	public static void test_rateCardItemPerformActionFive() {
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

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

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
		bookingTimeZone.Name = 'GMT';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+00:00';
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Greenwich Mean Time';
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

		cscfga__Configuration_Offer__c confOffer = new cscfga__Configuration_Offer__c();
		confOffer.Name = 'testOffer';
		confOffer.Rate_Card__c = rateCard.Id;
		confOffer.Account_Tier__c = 'Tier 1';
		confOffer.Product_Node__c = market.Id;
		insert confOffer;

		// create Rate Card Item Price (csmso__Rate_Card_Item_Price__c)
		csmso__Rate_Card_Item_Price__c rateCardItemPriceTwo = new csmso__Rate_Card_Item_Price__c();
		rateCardItemPriceTwo.csmso__Rate_Card__c = rateCard.Id;
		rateCardItemPriceTwo.csmso__Advert_Assignment__c = advertAssignment.Id;
		rateCardItemPriceTwo.Account_Tier__c = 'Tier 1';
		rateCardItemPriceTwo.List_Floor__c = 'List';
		rateCardItemPriceTwo.csmso__Product_Node__c = market.Id;
		rateCardItemPriceTwo.CurrencyIsoCode = 'USD';
		rateCardItemPriceTwo.Unique_Id__c = 'Test Unique Id Rate Card Item Price65465';
		rateCardItemPriceTwo.csmso__Price_Per_Unit__c = 12;
		rateCardItemPriceTwo.Minimum_Line_Value__c = 4;
		insert rateCardItemPriceTwo;

		Map<String, String> searchFieldsMap = new Map<String, String>();
		searchFieldsMap.put('Market', market.Id);
		searchFieldsMap.put('Order Type', 'Direct Commercial');
		searchFieldsMap.put('SO Currency', 'USD');
		searchFieldsMap.put('Package Id', confOffer.Id);
		searchFieldsMap.put('Node Advert Assignments', advertAssignment.Id);

		String prodDefinitionID;

		Test.startTest();
		SPRateCardOverwriteLookup rciplkp = new SPRateCardOverwriteLookup();
		rciplkp.getRequiredAttributes();
		Object[] result = rciplkp.doDynamicLookupSearch(searchFieldsMap, prodDefinitionID);
		Test.stopTest();

		System.assertNotEquals(null, result);
	}

	@IsTest
	public static void test_rateCardItemPerformActionSix() {
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

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

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
		bookingTimeZone.Name = 'GMT';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+00:00';
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Greenwich Mean Time';
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

		cscfga__Configuration_Offer__c confOffer = new cscfga__Configuration_Offer__c();
		confOffer.Name = 'testOffer';
		confOffer.Rate_Card__c = rateCard.Id;
		confOffer.Account_Tier__c = 'Tier 1';
		confOffer.Product_Node__c = market.Id;
		insert confOffer;

		// create Rate Card (csmso__Rate_Card__c)
		csmso__Rate_Card__c rateCardTwo = new csmso__Rate_Card__c();
		rateCardTwo.Short_Description__c = 'Test Short Description Rate Card2';
		rateCardTwo.Type__c = 'Base';
		rateCardTwo.csmso__Product_Node__c = market.Id;
		rateCardTwo.csmso__From_Date__c = Date.today().addDays(-30);
		rateCardTwo.csmso__To_Date__c = Date.today().addDays(30);
		rateCardTwo.CurrencyIsoCode = 'USD';
		rateCardTwo.Unique_Id__c = 'Test Unique Id Rate Card6546';
		rateCardTwo.Minimum_Deal_Value__c = 0;
		rateCardTwo.Maximum_Production_Cost__c = 12;
		rateCardTwo.Order_Type__c = 'Direct Commercial';
		//rateCardTwo.Account__c = acc.Id;
		insert rateCardTwo;

		// create Rate Card Item Price (csmso__Rate_Card_Item_Price__c)
		csmso__Rate_Card_Item_Price__c rateCardItemPriceTwo = new csmso__Rate_Card_Item_Price__c();
		rateCardItemPriceTwo.csmso__Rate_Card__c = rateCardTwo.Id;
		rateCardItemPriceTwo.csmso__Advert_Assignment__c = advertAssignment.Id;
		rateCardItemPriceTwo.Account_Tier__c = 'Tier 1';
		rateCardItemPriceTwo.List_Floor__c = 'List';
		rateCardItemPriceTwo.csmso__Product_Node__c = market.Id;
		rateCardItemPriceTwo.CurrencyIsoCode = 'USD';
		rateCardItemPriceTwo.Unique_Id__c = 'Test Unique Id Rate Card Item Price65465';
		rateCardItemPriceTwo.csmso__Price_Per_Unit__c = 12;
		rateCardItemPriceTwo.Minimum_Line_Value__c = 4;
		rateCardItemPriceTwo.Package__c = confOffer.Id;
		insert rateCardItemPriceTwo;

		// create Rate Card (csmso__Rate_Card__c)
		csmso__Rate_Card__c rateCardThree = new csmso__Rate_Card__c();
		rateCardThree.Short_Description__c = 'Test Short Description Rate Card3';
		rateCardThree.Type__c = 'Seasonal';
		rateCardThree.csmso__Product_Node__c = market.Id;
		rateCardThree.csmso__From_Date__c = Date.today().addDays(-30);
		rateCardThree.csmso__To_Date__c = Date.today().addDays(30);
		rateCardThree.CurrencyIsoCode = 'HRK';
		rateCardThree.Unique_Id__c = 'Test Unique Id Rate Card9195';
		rateCardThree.Minimum_Deal_Value__c = 0;
		rateCardThree.Maximum_Production_Cost__c = 12;
		rateCardThree.Order_Type__c = 'Direct Commercial';
		//rateCardThree.Account__c = acc.Id;
		insert rateCardThree;

		Map<String, String> searchFieldsMap = new Map<String, String>();
		searchFieldsMap.put('Market', market.Id);
		searchFieldsMap.put('Order Type', 'Direct Commercial');
		searchFieldsMap.put('SO Currency', 'USD');
		searchFieldsMap.put('Package Id', confOffer.Name);
		searchFieldsMap.put('Node Advert Assignments', advertAssignment.Id);

		String prodDefinitionID;

		Test.startTest();
		SPRateCardOverwriteLookup rciplkp = new SPRateCardOverwriteLookup();
		rciplkp.getRequiredAttributes();
		Object[] result = rciplkp.doDynamicLookupSearch(searchFieldsMap, prodDefinitionID);
		System.assertNotEquals(null, result);

		String requredAttributes = rciplkp.getRequiredAttributes();
		System.assertEquals('["Market", "Order Type", "SO Currency", "Package Id", "Node Advert Assignments"]', requredAttributes);
		Test.stopTest();
	}
}
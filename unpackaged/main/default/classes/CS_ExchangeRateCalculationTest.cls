@IsTest
private class CS_ExchangeRateCalculationTest {

	@IsTest
	static void testExchangeRateCalculationDifferentCurrency() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account acc = TestDataSetupBasic.createAccount();
		insert acc;

		Contact con = TestDataSetupBasic.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		so.CurrencyIsoCode = 'USD';
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		insert prodConfig;

		// create Business Unit (csmso__Business_Unit__c)
		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Test Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = 'Test Sales Ledger Code';
		businessUnit.Unique_Id__c = 'Test Unique Id Business Unit';
		insert businessUnit;

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
		csmso__Product_Node__c market = new csmso__Product_Node__c();
		market.Name = 'US';
		market.csmso__Business_Unit__c = businessUnit.Id;
		market.CurrencyIsoCode = 'USD';
		market.csmso__Description__c = 'Description';
		market.Unique_Id__c = 'US';
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
		rateCard.CurrencyIsoCode = 'BRL';
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
		rateCardItemPrice.CurrencyIsoCode = 'BRL';
		rateCardItemPrice.Unique_Id__c = 'Test Unique Id Rate Card Item Price';
		rateCardItemPrice.csmso__Price_Per_Unit__c = 12;
		rateCardItemPrice.Minimum_Line_Value__c = 4;
		insert rateCardItemPrice;

		Test.startTest();
		CS_ExchangeRateCalculation.ExchangeRateAttributes exchangeRateAttributes = new CS_ExchangeRateCalculation.ExchangeRateAttributes();
		exchangeRateAttributes.rcCurrencyIsoCode = 'BRL';
		exchangeRateAttributes.soCurrencyIsoCode = 'USD';

		String parameters = JSON.serialize(exchangeRateAttributes);

		CS_ExchangeRateCalculation rcipAttributesWrapper = new CS_ExchangeRateCalculation();
		String returnJSON = rcipAttributesWrapper.performAction(parameters);
		Test.stopTest();

		System.assertNotEquals(returnJSON, '1.00');
	}

	@IsTest
	static void testExchangeRateCalculationSameCurrency() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account acc = TestDataSetupBasic.createAccount();
		insert acc;

		Contact con = TestDataSetupBasic.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		so.CurrencyIsoCode = 'USD';
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		insert prodConfig;

		// create Business Unit (csmso__Business_Unit__c)
		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Test Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = 'Test Sales Ledger Code';
		businessUnit.Unique_Id__c = 'Test Unique Id Business Unit';
		insert businessUnit;

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
		csmso__Product_Node__c market = new csmso__Product_Node__c();
		market.Name = 'US';
		market.csmso__Business_Unit__c = businessUnit.Id;
		market.CurrencyIsoCode = 'USD';
		market.csmso__Description__c = 'Description';
		market.Unique_Id__c = 'US';
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

		Test.startTest();
		CS_ExchangeRateCalculation.ExchangeRateAttributes exchangeRateAttributes = new CS_ExchangeRateCalculation.ExchangeRateAttributes();
		exchangeRateAttributes.rcCurrencyIsoCode = 'USD';
		exchangeRateAttributes.soCurrencyIsoCode = 'USD';

		String parameters = JSON.serialize(exchangeRateAttributes);

		CS_ExchangeRateCalculation rcipAttributesWrapper = new CS_ExchangeRateCalculation();
		String returnJSON = rcipAttributesWrapper.performAction(parameters);
		Test.stopTest();

		System.assertEquals(returnJSON, '1.00');
	}

	@IsTest
	static void testExchangeRateCalculationNoCurrency() {
		CS_ExchangeRateCalculation.ExchangeRateAttributes exchangeRateAttributes = new CS_ExchangeRateCalculation.ExchangeRateAttributes();
		exchangeRateAttributes.rcCurrencyIsoCode = '';
		exchangeRateAttributes.soCurrencyIsoCode = '';

		String parameters = JSON.serialize(exchangeRateAttributes);

		CS_ExchangeRateCalculation rcipAttributesWrapper = new CS_ExchangeRateCalculation();
		String returnJSON = rcipAttributesWrapper.performAction(parameters);

		System.assertEquals(returnJSON, null);
	}

	@IsTest
	static void testExchangeRateCalculationConvertNoValue() {
		Decimal returnJSON = CS_ExchangeRateCalculation.convertCurrency('USD', 'USD', null);
		System.assertEquals(returnJSON, null);
	}

	@IsTest
	static void testExchangeRateCalculationConvertSameValue() {
		Decimal returnJSON = CS_ExchangeRateCalculation.convertCurrency('USD', 'USD', 2);
		System.assertEquals(returnJSON, 2);
	}

	@IsTest
	static void testExchangeRateCalculationConvertSourceCurrencyRateOne() {
		Decimal returnJSON = CS_ExchangeRateCalculation.convertCurrency('EUR', 'USD', 2);
		System.assertNotEquals(returnJSON, 2);
	}

	@IsTest
	static void testExchangeRateCalculationConvertTargetCurrencyRateOne() {
		Decimal returnJSON = CS_ExchangeRateCalculation.convertCurrency('USD', 'EUR', 2);
		System.assertNotEquals(returnJSON, 2);
	}
}
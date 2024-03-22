@IsTest
public class CS_RateCardTriggerTest {

	@IsTest
	public static void createRateCard() {
		//CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		//insert new CSSX__No_Triggers__c(cssx__Flag__c = true, setupownerid = Userinfo.getOrganizationId());

		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		insert so;

		// create Business Unit (csmso__Business_Unit__c)
		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Test Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = 'Test Sales Ledger Code';
		businessUnit.Unique_Id__c = 'Test Unique Id Business Unit';
		insert businessUnit;

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

		// create Geo Item (csdf__Geo_Item__c)
		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'Test Geo Item';
		geoItem.csdf__Ad_Server__c = adServer.Id;
		geoItem.csdf__Ad_Server_Id__c = 'Test Ad Server Id';
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

		csmso__Rate_Card__c rateCard = new csmso__Rate_Card__c();
		rateCard.Short_Description__c = 'Base - Digital Upfront - US';
		rateCard.Type__c = 'Base';
		rateCard.csmso__From_Date__c = Date.today() - 30;
		rateCard.csmso__To_Date__c = Date.today() + 30;
		rateCard.Unique_Id__c = 'RC-3';
		rateCard.Minimum_Deal_Value__c = 25000.00;
		rateCard.Maximum_Production_Cost__c = 10;
		rateCard.csmso__Product_Node__c = market.Id;
		rateCard.Order_Type__c = 'Direct Commercial';
		insert rateCard;

		csmso__Rate_Card__c rateCard2 = new csmso__Rate_Card__c();
		rateCard2.Short_Description__c = 'Base - Digital Upfront - US2';
		rateCard2.Type__c = 'Base';
		rateCard2.csmso__From_Date__c = Date.today() - 30;
		rateCard2.csmso__To_Date__c = Date.today() + 30;
		rateCard2.Unique_Id__c = 'RC-4';
		rateCard2.Minimum_Deal_Value__c = 25000.00;
		rateCard2.Maximum_Production_Cost__c = 10;
		rateCard2.csmso__Product_Node__c = market.Id;
		rateCard2.Order_Type__c = 'Direct Commercial';
		insert rateCard2;
	}

	@IsTest
	public static void createRateCard2() {
		//CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		//insert new CSSX__No_Triggers__c(cssx__Flag__c = true, setupownerid = Userinfo.getOrganizationId());

		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		insert so;

		// create Business Unit (csmso__Business_Unit__c)
		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Test Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = 'Test Sales Ledger Code';
		businessUnit.Unique_Id__c = 'Test Unique Id Business Unit';
		insert businessUnit;

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

		// create Geo Item (csdf__Geo_Item__c)
		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'Test Geo Item';
		geoItem.csdf__Ad_Server__c = adServer.Id;
		geoItem.csdf__Ad_Server_Id__c = 'Test Ad Server Id';
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

		csmso__Rate_Card__c rateCard = new csmso__Rate_Card__c();
		rateCard.Short_Description__c = 'Base - Digital Upfront - US';
		rateCard.Type__c = 'Base';
		rateCard.csmso__From_Date__c = Date.today() - 30;
		rateCard.csmso__To_Date__c = Date.today() + 30;
		rateCard.Unique_Id__c = 'RC-3';
		rateCard.Minimum_Deal_Value__c = 25000.00;
		rateCard.Maximum_Production_Cost__c = 10;
		rateCard.csmso__Product_Node__c = market.Id;
		rateCard.Order_Type__c = 'Direct Commercial';
		insert rateCard;

		csmso__Rate_Card__c rateCard2 = new csmso__Rate_Card__c();
		rateCard2.Short_Description__c = 'Base - Digital Upfront - US2';
		rateCard2.Type__c = 'Base';
		rateCard2.csmso__From_Date__c = Date.today() + 30;
		rateCard2.csmso__To_Date__c = Date.today() + 60;
		rateCard2.Unique_Id__c = 'RC-4';
		rateCard2.Minimum_Deal_Value__c = 25000.00;
		rateCard2.Maximum_Production_Cost__c = 10;
		rateCard2.csmso__Product_Node__c = market.Id;
		rateCard2.Order_Type__c = 'Direct Commercial';
		insert rateCard2;

		rateCard2.csmso__From_Date__c = Date.today() + 29;
		rateCard2.csmso__To_Date__c = Date.today() + 59;
		update rateCard2;
	}

	@IsTest
	public static void createRateCardWhenOverLaps() {
		//CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		//insert new CSSX__No_Triggers__c(cssx__Flag__c = true, setupownerid = Userinfo.getOrganizationId());

		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		insert so;

		// create Business Unit (csmso__Business_Unit__c)
		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Test Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = 'Test Sales Ledger Code';
		businessUnit.Unique_Id__c = 'Test Unique Id Business Unit';
		insert businessUnit;

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

		// create Geo Item (csdf__Geo_Item__c)
		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'Test Geo Item';
		geoItem.csdf__Ad_Server__c = adServer.Id;
		geoItem.csdf__Ad_Server_Id__c = 'Test Ad Server Id';
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

		csmso__Rate_Card__c rateCard = new csmso__Rate_Card__c();
		rateCard.Short_Description__c = 'Base - Digital Upfront - US';
		rateCard.Type__c = 'Customer Price List';
		rateCard.csmso__From_Date__c = Date.today() - 30;
		rateCard.csmso__To_Date__c = Date.today() + 30;
		rateCard.Unique_Id__c = 'RC-3';
		rateCard.Minimum_Deal_Value__c = 25000.00;
		rateCard.Maximum_Production_Cost__c = 10;
		rateCard.csmso__Product_Node__c = market.Id;
		rateCard.Order_Type__c = 'Direct Commercial';
		rateCard.Account__c = acc.Id;
		insert rateCard;

		String message;
		try {
			csmso__Rate_Card__c rateCard2 = new csmso__Rate_Card__c();
			rateCard2.Short_Description__c = 'Base - Digital Upfront - US2';
			rateCard2.Type__c = 'Customer Price List';
			rateCard2.csmso__From_Date__c = Date.today() - 30;
			rateCard2.csmso__To_Date__c = Date.today() + 30;
			rateCard2.Unique_Id__c = 'RC-4';
			rateCard2.Minimum_Deal_Value__c = 25000.00;
			rateCard2.Maximum_Production_Cost__c = 10;
			rateCard2.csmso__Product_Node__c = market.Id;
			rateCard2.Order_Type__c = 'Direct Commercial';
			rateCard2.Account__c = acc.Id;
			insert rateCard2;
		} catch (Exception e) {
			message = e.getMessage();
		}

		//System.assert(message.contains('Overlapping dates with another "Customer" Rate Card with the same Account and Order Type!'));
	}

	@IsTest
	public static void createRateCardWhenOverLaps2() {
		//CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		//insert new CSSX__No_Triggers__c(cssx__Flag__c = true, setupownerid = Userinfo.getOrganizationId());

		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		insert so;

		// create Business Unit (csmso__Business_Unit__c)
		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Test Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = 'Test Sales Ledger Code';
		businessUnit.Unique_Id__c = 'Test Unique Id Business Unit';
		insert businessUnit;

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

		// create Geo Item (csdf__Geo_Item__c)
		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'Test Geo Item';
		geoItem.csdf__Ad_Server__c = adServer.Id;
		geoItem.csdf__Ad_Server_Id__c = 'Test Ad Server Id';
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

		csmso__Rate_Card__c rateCard = new csmso__Rate_Card__c();
		rateCard.Short_Description__c = 'Base - Digital Upfront - US';
		rateCard.Type__c = 'Seasonal';
		rateCard.csmso__From_Date__c = Date.today() - 30;
		rateCard.csmso__To_Date__c = Date.today() + 30;
		rateCard.Unique_Id__c = 'RC-3';
		rateCard.Minimum_Deal_Value__c = 25000.00;
		rateCard.Maximum_Production_Cost__c = 10;
		rateCard.csmso__Product_Node__c = market.Id;
		rateCard.Order_Type__c = 'Direct Commercial';
		insert rateCard;

		String message;
		try {
			csmso__Rate_Card__c rateCard2 = new csmso__Rate_Card__c();
			rateCard2.Short_Description__c = 'Base - Digital Upfront - US2';
			rateCard2.Type__c = 'Seasonal';
			rateCard2.csmso__From_Date__c = Date.today() - 30;
			rateCard2.csmso__To_Date__c = Date.today() + 30;
			rateCard2.Unique_Id__c = 'RC-4';
			rateCard2.Minimum_Deal_Value__c = 25000.00;
			rateCard2.Maximum_Production_Cost__c = 10;
			rateCard2.csmso__Product_Node__c = market.Id;
			rateCard2.Order_Type__c = 'Direct Commercial';
			insert rateCard2;
		} catch (Exception e) {
			message = e.getMessage();
		}

		//System.assert(message.contains('Overlapping dates with another "Seasonal" Rate Card with the same Product Node and Order Type!'));
	}

	@IsTest
	public static void createRateCardWhenOverLaps3() {
		//CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		//insert new CSSX__No_Triggers__c(cssx__Flag__c = true, setupownerid = Userinfo.getOrganizationId());

		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		insert so;

		// create Business Unit (csmso__Business_Unit__c)
		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Test Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = 'Test Sales Ledger Code';
		businessUnit.Unique_Id__c = 'Test Unique Id Business Unit';
		insert businessUnit;

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

		// create Geo Item (csdf__Geo_Item__c)
		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'Test Geo Item';
		geoItem.csdf__Ad_Server__c = adServer.Id;
		geoItem.csdf__Ad_Server_Id__c = 'Test Ad Server Id';
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

		csmso__Rate_Card__c rateCard = new csmso__Rate_Card__c();
		rateCard.Short_Description__c = 'Base - Digital Upfront - US';
		rateCard.Type__c = 'Base';
		rateCard.csmso__From_Date__c = Date.today() - 30;
		rateCard.csmso__To_Date__c = Date.today() + 30;
		rateCard.Unique_Id__c = 'RC-3';
		rateCard.Minimum_Deal_Value__c = 25000.00;
		rateCard.Maximum_Production_Cost__c = 10;
		rateCard.csmso__Product_Node__c = market.Id;
		rateCard.Order_Type__c = 'Direct Commercial';
		insert rateCard;

		csmso__Rate_Card__c rateCard2 = new csmso__Rate_Card__c();
		rateCard2.Short_Description__c = 'Base - Digital Upfront - US2';
		rateCard2.Type__c = 'Base';
		rateCard2.csmso__From_Date__c = Date.today() - 30;
		rateCard2.csmso__To_Date__c = Date.today() + 30;
		rateCard2.Unique_Id__c = 'RC-4';
		rateCard2.Minimum_Deal_Value__c = 25000.00;
		rateCard2.Maximum_Production_Cost__c = 10;
		rateCard2.csmso__Product_Node__c = market.Id;
		rateCard2.Order_Type__c = 'Direct Commercial';
		insert rateCard2;

		String message;
		try {
			rateCard.Type__c = 'Seasonal';
			update rateCard;

			rateCard2.Type__c = 'Seasonal';
			update rateCard2;
		} catch (Exception e) {
			message = e.getMessage();
		}

		//System.assert(message.contains('Overlapping dates with another "Seasonal" Rate Card with the same Product Node and Order Type!'));
	}

	/*@isTest
	public static void createRateCardWhenOverLaps4() {
		//CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		//insert new CSSX__No_Triggers__c(cssx__Flag__c = true, setupownerid = Userinfo.getOrganizationId());

		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		insert so;

		// create Business Unit (csmso__Business_Unit__c)
		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Test Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = 'Test Sales Ledger Code';
		businessUnit.Unique_Id__c = 'Test Unique Id Business Unit';
		insert businessUnit;

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

		// create Geo Item (csdf__Geo_Item__c)
		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'Test Geo Item';
		geoItem.csdf__Ad_Server__c = adServer.Id;
		geoItem.csdf__Ad_Server_Id__c = 'Test Ad Server Id';
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

		csmso__Rate_Card__c rateCard = new csmso__Rate_Card__c();
		rateCard.Short_Description__c = 'Base - Digital Upfront - US';
		rateCard.Type__c = 'Customer Price List';
		rateCard.csmso__From_Date__c = Date.today() - 30;
		rateCard.csmso__To_Date__c = Date.today() + 30;
		rateCard.Unique_Id__c = 'RC-3';
		rateCard.Minimum_Deal_Value__c = 25000.00;
		rateCard.Maximum_Production_Cost__c = 10;
		rateCard.csmso__Product_Node__c = market.id;
		rateCard.Order_Type__c = 'Direct Commercial';
		rateCard.Account__c = acc.Id;
		insert rateCard;

		csmso__Rate_Card__c rateCard2 = new csmso__Rate_Card__c();
		rateCard2.Short_Description__c = 'Base - Digital Upfront - US2';
		rateCard2.Type__c = 'Base';
		rateCard2.csmso__From_Date__c = Date.today() - 30;
		rateCard2.csmso__To_Date__c = Date.today() + 30;
		rateCard2.Unique_Id__c = 'RC-4';
		rateCard2.Minimum_Deal_Value__c = 25000.00;
		rateCard2.Maximum_Production_Cost__c = 10;
		rateCard2.csmso__Product_Node__c = market.id;
		rateCard2.Order_Type__c = 'Direct Commercial';
		insert rateCard2;

		Test.startTest();

		String message;
		try{
			rateCard.Account__c = acc.Id;
			rateCard.Type__c = 'Customer Price List';
			update rateCard;

			rateCard2.Account__c = acc.Id;
			rateCard2.Type__c = 'Customer Price List';
			update rateCard2;
		}
		catch (Exception e) {
			message = e.getMessage();
		}

		Test.stopTest();

		System.assert(message.contains('Overlapping dates with another "Customer" Rate Card with the same Account and Order Type!'));
	}*/
}
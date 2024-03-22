@IsTest
public class CS_SalesOrderDelegateTest {

	@IsTest
	static void testPopulatingRateCard() {
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Trigger_Execute__c obj = new Trigger_Execute__c(name='Trigger_OpportunitySplit');
		insert obj;
		Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_Account').getRecordTypeId();
		Account acc = TestDataSetupSO.createAccount();
		acc.recordTypeId = recordTypeId;
       
        acc.Phone = '2345';
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        opp.Subsidiary_Type__c = 'iPP';
		insert opp;

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
		rateCard.csmso__From_Date__c = Date.today().addDays(-30);
		rateCard.csmso__To_Date__c = Date.today().addDays(30);
		rateCard.CurrencyIsoCode = 'USD';
		rateCard.Unique_Id__c = 'Test Unique Id Rate Card';
		rateCard.Minimum_Deal_Value__c = 0;
		rateCard.Maximum_Production_Cost__c = 12;
		rateCard.Order_Type__c = 'Direct Commercial';
		rateCard.csmso__Product_Node__c = market.Id;
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
       // rateCardItemPrice.Revenue_Recognition_Rules__c = 'Default One-Time Direct Posting';
        rateCardItemPrice.Rev_Rec_Forecast_Rules__c = 'Default Standard';
        rateCardItemPrice.Create_Revenue_based_on__c = 'Fulfillment';  
		//insert rateCardItemPrice;

		csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc, opp);
		salesOrder.isTestRunning__c = true;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		salesOrder.Order_Type__c = 'Direct Commercial';
		salesOrder.Market__c = market.Id;
		insert salesOrder;

		csmso__Sales_Order__c salesOrder2 = [SELECT Id, Rate_Card__c FROM csmso__Sales_Order__c WHERE Id = :salesOrder.Id];
		System.assert(salesOrder2.Rate_Card__c != null);
	}

	@IsTest
	static void testPopulatingRateCard2() {
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Trigger_Execute__c obj = new Trigger_Execute__c(name='Trigger_OpportunitySplit');
		insert obj;
		Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_Account').getRecordTypeId();
		Account acc = TestDataSetupSO.createAccount();
		acc.recordTypeId = recordTypeId;
       
        acc.Phone = '2345';
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        opp.Subsidiary_Type__c = 'iPP';
		insert opp;

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
		rateCard.Type__c = 'Customer Price List';
		rateCard.Account__c = acc.Id;
		rateCard.csmso__Product_Node__c = market.Id;
		rateCard.csmso__From_Date__c = Date.today().addDays(-30);
		rateCard.csmso__To_Date__c = Date.today().addDays(30);
		rateCard.CurrencyIsoCode = 'USD';
		rateCard.Unique_Id__c = 'Test Unique Id Rate Card';
		rateCard.Minimum_Deal_Value__c = 0;
		rateCard.Maximum_Production_Cost__c = 12;
		rateCard.Order_Type__c = 'Direct Commercial';
		rateCard.csmso__Product_Node__c = market.Id;
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
       // rateCardItemPrice.Revenue_Recognition_Rules__c = 'Default One-Time Direct Posting';
        rateCardItemPrice.Rev_Rec_Forecast_Rules__c = 'Default Standard';
        rateCardItemPrice.Create_Revenue_based_on__c = 'Fulfillment'; 
	//	insert rateCardItemPrice;

		csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc, opp);
		salesOrder.isTestRunning__c = true;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		salesOrder.Order_Type__c = 'Direct Commercial';
		salesOrder.Market__c = market.Id;
		salesOrder.Company_on_Agreement__c = acc.Id;
		insert salesOrder;

		csmso__Sales_Order__c salesOrder2 = [SELECT Id, Rate_Card__c FROM csmso__Sales_Order__c WHERE Id = :salesOrder.Id];
		System.assert(salesOrder2.Rate_Card__c != null);
	}

	@IsTest
	static void testPopulatingRateCard3() {
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Trigger_Execute__c obj = new Trigger_Execute__c(name='Trigger_OpportunitySplit');
		insert obj;
		Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_Account').getRecordTypeId();
		Account acc = TestDataSetupSO.createAccount();
		acc.recordTypeId = recordTypeId;
       
        acc.Phone = '2345';
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        opp.Subsidiary_Type__c = 'iPP';
		insert opp;

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
		rateCard.Type__c = 'Customer Price List';
		rateCard.Account__c = acc.Id;
		rateCard.csmso__Product_Node__c = market.Id;
		rateCard.csmso__From_Date__c = Date.today().addDays(-30);
		rateCard.csmso__To_Date__c = Date.today().addDays(30);
		rateCard.CurrencyIsoCode = 'USD';
		rateCard.Unique_Id__c = 'Test Unique Id Rate Card';
		rateCard.Minimum_Deal_Value__c = 0;
		rateCard.Maximum_Production_Cost__c = 12;
		rateCard.Order_Type__c = 'Direct Commercial';
		rateCard.csmso__Product_Node__c = market.Id;
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
        rateCardItemPrice.Revenue_Recognition_Rules__c = 'Default One-Time Direct Posting';
        rateCardItemPrice.Rev_Rec_Forecast_Rules__c = 'Default Standard';
        rateCardItemPrice.Create_Revenue_based_on__c = 'Fulfillment'; 
		//insert rateCardItemPrice;

		csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc, opp);
		salesOrder.isTestRunning__c = true;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		salesOrder.Order_Type__c = 'Direct Commercial';
		salesOrder.Market__c = market.Id;
		salesOrder.Media_Agency__c = acc.Id;
		insert salesOrder;

		csmso__Sales_Order__c salesOrder2 = [SELECT Id, Rate_Card__c FROM csmso__Sales_Order__c WHERE Id = :salesOrder.Id];
		System.assert(salesOrder2.Rate_Card__c != null);
	}

	@IsTest
	static void testPopulatingRateCard4() {
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Trigger_Execute__c obj = new Trigger_Execute__c(name='Trigger_OpportunitySplit');
		insert obj;
		Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_Account').getRecordTypeId();
		Account acc = TestDataSetupSO.createAccount();
		acc.recordTypeId = recordTypeId;
       
        acc.Phone = '2345';
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        opp.Subsidiary_Type__c = 'iPP';
		insert opp;

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
		rateCard.Type__c = 'Customer Price List';
		rateCard.Account__c = acc.Id;
		rateCard.csmso__Product_Node__c = market.Id;
		rateCard.csmso__From_Date__c = Date.today().addDays(-30);
		rateCard.csmso__To_Date__c = Date.today().addDays(30);
		rateCard.CurrencyIsoCode = 'USD';
		rateCard.Unique_Id__c = 'Test Unique Id Rate Card';
		rateCard.Minimum_Deal_Value__c = 0;
		rateCard.Maximum_Production_Cost__c = 12;
		rateCard.Order_Type__c = 'Direct Commercial';
		rateCard.csmso__Product_Node__c = market.Id;
		rateCard.CurrencyIsoCode = 'EUR';
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
		rateCardItemPrice.CurrencyIsoCode = 'EUR';
      //  rateCardItemPrice.Revenue_Recognition_Rules__c = 'Default One-Time Direct Posting';
        rateCardItemPrice.Rev_Rec_Forecast_Rules__c = 'Default Standard';
        rateCardItemPrice.Create_Revenue_based_on__c = 'Fulfillment'; 
		//insert rateCardItemPrice;

		csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc, opp);
		salesOrder.isTestRunning__c = true;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		salesOrder.Order_Type__c = 'Direct Commercial';
		salesOrder.Market__c = market.Id;
		salesOrder.Media_Agency__c = acc.Id;
		salesOrder.CurrencyIsoCode = 'USD';
		insert salesOrder;

		csmso__Sales_Order__c salesOrder2 = [SELECT Id, Rate_Card__c FROM csmso__Sales_Order__c WHERE Id = :salesOrder.Id];
		System.assert(salesOrder2.Rate_Card__c != null);
	}

	@IsTest
	static void testConvertingCurrency() {
		Trigger_Execute__c obj = new Trigger_Execute__c(name='Trigger_OpportunitySplit');
		insert obj;
		Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_Account').getRecordTypeId();
		Account acc = TestDataSetupSO.createAccount();
		acc.recordTypeId = recordTypeId;
       
        acc.Phone = '2345';
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        opp.Subsidiary_Type__c = 'iPP';
		insert opp;

		csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc, opp);
		salesOrder.isTestRunning__c = true;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Booked';
		salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		insert salesOrder;

		Decimal convertedCurreny = CS_SalesOrderDelegate.convertCurrency('EUR', 'USD', null);
		System.assertEquals(null, convertedCurreny);

		Decimal convertedCurreny2 = CS_SalesOrderDelegate.convertCurrency('EUR', 'USD', 1.0);
		System.assert(convertedCurreny2 != null);
	}

	@IsTest
	static void testRecallApprovalFromFulfilments() {
		Trigger_Execute__c obj = new Trigger_Execute__c(name='Trigger_OpportunitySplit');
		insert obj;
		Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_Account').getRecordTypeId();
		Account acc = TestDataSetupSO.createAccount();
		acc.recordTypeId = recordTypeId;
       
        acc.Phone = '2345';
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        opp.Subsidiary_Type__c = 'iPP';
		insert opp;

		csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc, opp);
		salesOrder.Reservation_Extension__c = 'Pending';
		salesOrder.Expiration_Date__c = Date.Today().addDays(4);
        insert salesOrder;

		csdf__Fulfilment__c fulfilment = new csdf__Fulfilment__c();
        fulfilment.csdf__Name__c = 'Test fulfilment';
        fulfilment.csdf__Advertiser__c = acc.Id;
        fulfilment.Sales_Order__c = salesOrder.Id;
		fulfilment.Extension_Approval__c = '';
		insert fulfilment;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
		insert prodBasket;
		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Ad_Type__c = 'Standard';
		prodConfig.Fulfilment_Item_Status__c = 'Draft';
		prodConfig.csmso__Flight_End__c = Date.today().addDays(4);
		prodConfig.Sales_Order__c = salesOrder.Id;
		insert prodConfig;
		
		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, salesOrder, fulfilment);
		testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
		insert testFulfilmentItem;
                
		Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
		app.setObjectId(fulfilment.id);
		app.setProcessDefinitionNameOrId('SD_Approval');
	
		Approval.ProcessResult result = Approval.process(app);
		
		Test.startTest();
		salesOrder.Expiration_Date__c = null;
		update salesOrder;
		Test.stopTest();

	}
}
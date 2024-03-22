@IsTest
private class CS_P_OfferTriggerMonitorTest {
	private static csdf__Ad_Server__c adServer;
	private static csdf__Fulfilment__c testFulfilment;
	private static cscfga__Product_Configuration__c prodConfig;
	private static csmso__Sales_Order__c so;

	private static void createTestData() {
		CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();
		customSettings.Fulfilment_Item_Propert_Map_Key__c = 'fitoattribute';
		update customSettings;

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

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		adServer = new csdf__Ad_Server__c();
		adServer.Name = 'Newsday DFP Production';
		adServer.csdf__Network_Code__c = '5819';
		adServer.csdf__Username__c = 'userTest';
		adServer.csdf__Password__c = 'userPass';
		insert adServer;

		testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		testFulfilment.csdf__Ad_Server__c = adServer.Id;
		insert testFulfilment;

		csdf__Ad_Slot__c adSlot = new csdf__Ad_Slot__c();
		adSlot.csdf__Name__c = 'NewsDay Traffic';
		adSlot.csdf__Active__c = true;
		adSlot.csdf__Ad_Server__c = adServer.Id;
		adSlot.csdf__Ad_Server_Id__c = adServer.Id;
		adSlot.csdf__Code__c = 'cblvsn.nwsd.traffic';
		insert adSlot;

		csdf__Targetable__c targ = new csdf__Targetable__c();
		targ.csdf__Targetable_Name__c = 'Zen';
		targ.csdf__Active__c = true;
		targ.csdf__Ad_Server_Id__c = '40343';
		targ.csdf__Ad_Server__c = adServer.Id;
		targ.csdf__Type__c = 'Device Manufacturer';
		insert targ;

		csdf__Targetable__c targ2 = new csdf__Targetable__c();
		targ2.csdf__Targetable_Name__c = 'Zen';
		targ2.csdf__Active__c = true;
		targ2.csdf__Ad_Server_Id__c = '40343';
		targ2.csdf__Ad_Server__c = adServer.Id;
		targ2.csdf__Type__c = 'Device Category';
		insert targ2;

		csdf__Site__c site = new csdf__Site__c();
		site.Name = 'Test Site';
		site.csdf__Ad_Server__c = adServer.Id;
		insert site;

		csdf__Browser__c browser = new csdf__Browser__c();
		browser.csdf__Ad_Server__c = adServer.Id;
		browser.csdf__Ad_Server_Id__c = '500011';
		browser.csdf__Browser_Name__c = 'FireFox';
		insert browser;

		csdf__Operating_System__c opSystem = new csdf__Operating_System__c();
		opSystem.Name = 'PlayStation3';
		opSystem.csdf__Ad_Server__c = adServer.Id;
		opSystem.csdf__Active__c = true;
		opSystem.csdf__Ad_Server_Id__c = '501015';
		insert opSystem;

		csdf__Operating_System__c opSystemIOS = new csdf__Operating_System__c();
		opSystemIOS.Name = 'Apple iOS';
		opSystemIOS.csdf__Ad_Server__c = adServer.Id;
		opSystemIOS.csdf__Active__c = true;
		opSystemIOS.csdf__Ad_Server_Id__c = '501012';
		insert opSystemIOS;

		csdf__Operating_System_Version__c opversion = new csdf__Operating_System_Version__c();
		opversion.csdf__Operating_System__c = opSystemIOS.Id;
		opversion.csdf__Active__c = true;
		opversion.csdf__Ad_Server_Id__c = '630239';
		insert opversion;

		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'Kansas';
		geoItem.csdf__Ad_Server_Id__c = '21149';
		insert geoItem;

		// create Business Unit (csmso__Business_Unit__c)
		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Test Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = 'Test Sales Ledger Code';
		businessUnit.Unique_Id__c = 'Test Unique Id Business Unit';
		insert businessUnit;


		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Name = 'Europe/London';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
		bookingTimeZone.Booking_Time_Zone_Country__c = 'British Summer Time';
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

		cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c(Name = 'test offer-00011', cscfga__Active__c = true, Account_Tier__c = 'Tier 1', Product_Node__c = market.Id, Rate_Card__c = rateCard.Id);
		insert offer;

		prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.FLAG_Package_Item__c = 'Yes';
		prodConfig.cscfga__originating_offer__c = offer.Id;
		insert prodConfig;
	}

	@IsTest
	static void testOfferTriggerMonitor() {
		createTestData();

		CSSX__No_Triggers__c notriggers = new CSSX__No_Triggers__c();
		notriggers.cssx__Flag__c = false;
		insert notriggers;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		testFulfilmentItem.Long_Custom_Key_Targeting__c = 'Audience Segment is test';
		testFulfilmentItem.csdf__Day_Part_Targeting__c = 'Tuesday,03,15,Wednesday,00,24,Thursday,00,24,Friday,00,24,Saturday,00,24,Sunday,00,24,';
		testFulfilmentItem.csdf__Ad_Server_Id__c = adServer.Id;
		testFulfilmentItem.csdf__Fulfilment__c = testFulfilment.Id;

		CS_FulfilmentItemDelegate delegate = new CS_FulfilmentItemDelegate();

		//testFulfilmentItem.Day_Part_Targeting_JSON__c = delegate.generateJSONData(testFulfilmentItem.csdf__Day_Part_Targeting__c.replaceAll('#', ',')).replaceAll(',', '#');

		testFulfilmentItem.csdf__Flight_Beginning__c = Datetime.valueOfGmt('2018-01-03 10:00:00');
		testFulfilmentItem.csdf__Flight_End__c = Datetime.valueOfGmt('2018-01-05 10:00:00');
		testFulfilmentItem.Booking_Timezone__c = 'Europe/London';

		Test.startTest();
		insert testFulfilmentItem;

		testFulfilmentItem = [SELECT Id FROM csdf__Fulfilment_Item__c LIMIT 1];

		/*
		csdf__Ad_Slot_Targeting__c adSlotTargeting = new csdf__Ad_Slot_Targeting__c();
		adSlotTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
		adSlotTargeting.csdf__Ad_Slot__c = getAdSlot().Id;
		insert adSlotTargeting;
		*/
		/*
		csdf__Targetable_Targeting__c targetTargeting = new csdf__Targetable_Targeting__c();
		targetTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
		targetTargeting.csdf__Targetable__c = getTargetable().Id;
		insert targetTargeting;

		csdf__Targetable_Targeting__c targetTargeting2 = new csdf__Targetable_Targeting__c();
		targetTargeting2.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
		targetTargeting2.csdf__Targetable__c = getTargetable_DeviceCategory().Id;
		insert targetTargeting2;

		csdf__Site_Targeting__c siteTargeting = new csdf__Site_Targeting__c();
		siteTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
		siteTargeting.csdf__Site__c = getSite().Id;
		insert siteTargeting;

		csdf__Geo_Targeting__c geoTargeting = new csdf__Geo_Targeting__c();
		geoTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
		geoTargeting.csdf__Geo_Item__c = getGeoItem().Id;
		insert geoTargeting;

		csdf__Browser_Targeting__c browserTargeting = new csdf__Browser_Targeting__c();
		browserTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
		browserTargeting.csdf__Browser__c = getBrowser().Id;
		insert browserTargeting;

		csdf__Operating_System_Targeting__c opTargeting = new csdf__Operating_System_Targeting__c();
		opTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
		opTargeting.csdf__Operating_System__c = getOperatingSystem().Id;
		insert opTargeting;

		csdf__Operating_System_Version_Targeting__c opvTargeting = new csdf__Operating_System_Version_Targeting__c();
		opvTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
		opvTargeting.csdf__Operating_System_Version__c = getOperatingSystemVersion().Id;
		insert opvTargeting;
		*/


		testFulfilmentItem.Long_Custom_Key_Targeting__c = 'Audience Segment is not test';
		testFulfilmentItem.csdf__Flight_Beginning__c = Datetime.valueOfGmt('2018-01-03 11:00:00');
		testFulfilmentItem.csdf__Day_Part_Targeting__c = 'Monday,00,24,Tuesday,03,15,Wednesday,00,24,Thursday,00,24,Friday,00,24,Saturday,00,24,Sunday,00,24,';
		testFulfilmentItem.Last_Action_from_DFP__c = Datetime.valueOfGmt('2018-01-03 11:00:00');
		update testFulfilmentItem;

		testFulfilmentItem = [SELECT Id, Name, Last_Action_from_DFP__c FROM csdf__Fulfilment_Item__c WHERE Id = :testFulfilmentItem.Id];
		update testFulfilmentItem;

		CS_P_OfferTriggerMonitor offerTriggerMonitor = new CS_P_OfferTriggerMonitor(true);
		offerTriggerMonitor.logic();

		Test.stopTest();
	}
}
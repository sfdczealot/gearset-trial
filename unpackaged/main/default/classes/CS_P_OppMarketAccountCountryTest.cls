@IsTest
private class CS_P_OppMarketAccountCountryTest {
	private static Opportunity opp;
	private static csmso__Product_Node__c marketSingapore;
	private static csmso__Product_Node__c marketInternational;

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

		Account agency = TestDataSetupTargetables.createAccount();
		agency.Type = 'Media Agency';
		insert agency;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Test Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = 'Test Sales Ledger Code';
		businessUnit.Unique_Id__c = 'Test Unique Id Business Unit';
		insert businessUnit;

		List<csdf__Geo_Item__c> geoItemsToInsert = new List<csdf__Geo_Item__c>();
		csdf__Geo_Item__c geoItemUS = new csdf__Geo_Item__c();
		geoItemUS.Name = 'United States';
		geoItemUS.csdf__Ad_Server_Id__c = '2840';
		geoItemsToInsert.add(geoItemUS);

		csdf__Geo_Item__c geoItemSingapore = new csdf__Geo_Item__c();
		geoItemSingapore.Name = 'Singapore';
		geoItemSingapore.csdf__Ad_Server_Id__c = '2840';
		geoItemsToInsert.add(geoItemSingapore);
		insert geoItemsToInsert;

		List<Booking_Time_Zone__c> bookingTimeZonesToInsert = new List<Booking_Time_Zone__c>();
		Booking_Time_Zone__c bookingTimeZoneUS = new Booking_Time_Zone__c();
		bookingTimeZoneUS.Name = 'America/New_York';
		bookingTimeZoneUS.Time_Zone_Code__c = 'GMT-04:00';
		bookingTimeZoneUS.Booking_Time_Zone_Country__c = 'United States';
		bookingTimeZonesToInsert.add(bookingTimeZoneUS);

		Booking_Time_Zone__c bookingTimeZoneSingapore = new Booking_Time_Zone__c();
		bookingTimeZoneSingapore.Name = 'Asia/Singapore';
		bookingTimeZoneSingapore.Time_Zone_Code__c = 'GMT+08:00';
		bookingTimeZoneSingapore.Booking_Time_Zone_Country__c = 'Singapore';
		bookingTimeZonesToInsert.add(bookingTimeZoneSingapore);
		insert bookingTimeZonesToInsert;

		List<csmso__Product_Node__c> marketsToInsert = new List<csmso__Product_Node__c>();
		marketInternational = new csmso__Product_Node__c();
		marketInternational.Name = 'International';
		marketInternational.csmso__Business_Unit__c = businessUnit.Id;
		marketInternational.CurrencyIsoCode = 'USD';
		marketInternational.csmso__Description__c = 'Description';
		marketInternational.Unique_Id__c = 'INT';
		marketInternational.Geo_Targeting__c = geoItemUS.Id;
		marketInternational.Sponsorship_Booking_Timezone__c = bookingTimeZoneUS.Id;
		marketInternational.csmso__Media_Types__c = 'Digital';
		marketInternational.NAA_supported_currency__c = 'SGD';
		marketsToInsert.add(marketInternational);

		marketSingapore = new csmso__Product_Node__c();
		marketSingapore.Name = 'Singapore';
		marketSingapore.csmso__Business_Unit__c = businessUnit.Id;
		marketSingapore.CurrencyIsoCode = 'SGD';
		marketSingapore.csmso__Description__c = 'Description';
		marketSingapore.Unique_Id__c = 'SG';
		marketSingapore.Geo_Targeting__c = geoItemSingapore.Id;
		marketSingapore.Sponsorship_Booking_Timezone__c = bookingTimeZoneSingapore.Id;
		marketSingapore.csmso__Media_Types__c = 'Digital';
		marketSingapore.NAA_supported_currency__c = 'SGD';
		marketsToInsert.add(marketSingapore);
		insert marketsToInsert;

		opp = TestDataSetupTargetables.createOpportunity(acc, con);
	}

	@IsTest
	static void testOppMarketAccountCountrySingapore() {
		createTestData();

		Test.startTest();
		User runningUser = [SELECT Id, Subsidiary__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
		update runningUser;

		Subsidiary__c subsidiarySingapore = new Subsidiary__c();
		subsidiarySingapore.Name = 'PropertyGuru Pte Ltd';
		subsidiarySingapore.Tax_Label__c = 'GST';
		subsidiarySingapore.CurrencyIsoCode = 'SGD';
		subsidiarySingapore.Country__c = 'Singapore';
		insert subsidiarySingapore;

		opp.Subsidiary__c = subsidiarySingapore.Id;
		insert opp;

		Opportunity opp = [
				SELECT Id,
						Name,
						Market__c,
						Country__c
				FROM Opportunity
				LIMIT 1
		];

		//System.assertEquals(opp.Market__c, marketSingapore.Id);
		Test.stopTest();
	}

	@IsTest
	static void testOppMarketAccountCountryEmpty() {
		createTestData();

		Test.startTest();
		opp.Subsidiary__c = null;
		insert opp;

		Opportunity opp = [
				SELECT Id,
						Name,
						Market__c,
						Agency_Client_del__c
				FROM Opportunity
				LIMIT 1
		];

		//System.assertEquals(opp.Market__c, marketInternational.Id);
		Test.stopTest();
	}
}
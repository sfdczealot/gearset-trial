@IsTest
public with sharing class CS_P_SOMarketTest {
	private static csmso__Sales_Order__c so;
	private static csmso__Product_Node__c market2;

	private static void createTestData() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());

		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Account agency = TestDataSetupTargetables.createAccount();
		agency.Type = 'Media Agency';
		insert agency;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		opp.Media_Agency2__c = agency.Id;
		opp.Agency_Client_del__c = acc.Id;
		insert opp;

		// create Business Unit (csmso__Business_Unit__c)
		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Test Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = 'Test Sales Ledger Code';
		businessUnit.Unique_Id__c = 'Test Unique Id Business Unit';
		insert businessUnit;

		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Name = 'GMT';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+00:00';
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Greenwich Mean Time';
		insert bookingTimeZone;

		// create geo targeting
		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'United States';
		geoItem.csdf__Ad_Server_Id__c = '2840';
		insert geoItem;

		// create geo targeting
		csdf__Geo_Item__c geoItem2 = new csdf__Geo_Item__c();
		geoItem2.Name = 'United States 2';
		geoItem2.csdf__Ad_Server_Id__c = '28405';
		insert geoItem2;

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

		// create Market (csmso__Product_Node__c)
		market2 = new csmso__Product_Node__c();
		market2.Name = 'Test Market 2';
		market2.csmso__Description__c = 'Test Market Description 2';
		market2.csmso__Business_Unit__c = businessUnit.Id;
		market2.CurrencyIsoCode = 'USD';
		market2.Unique_Id__c = 'Test Market Unique Id 2';
		market2.csmso__Media_Types__c = 'Desktop';
		market2.Geo_Targeting__c = geoItem2.Id;
		market2.Sponsorship_Booking_Timezone__c = bookingTimeZone.Id;
		market2.NAA_supported_currency__c = 'SGD';
		insert market2;

		so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		so.csmso__Status__c = CS_const_SalesOrder.Status_InProgress;
		so.Market__c = market.Id;
		insert so;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

		for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
			pConfig.Sales_Order__c = so.Id;
		}
		update prodConfigs;
	}

	@IsTest
	public static void testMarketChange() {
		createTestData();

		Test.startTest();
		Map<Id, csmso__Sales_Order__c> mapOld = new Map<Id, csmso__Sales_Order__c>();
		mapOld.put(so.Id, so);
		CS_P_SOMarket process = new CS_P_SOMarket(mapOld);
		process.applicableObjects = mapOld;

		so.Market__c = market2.Id;
		update so;

		so = [
				SELECT Id,
						Name,
						csmso__Status__c,
						Market__c
				FROM csmso__Sales_Order__c
				LIMIT 1
		];

		process.isRecordEligible(so);
		process.logic();
		Test.stopTest();
	}
}
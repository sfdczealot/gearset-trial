@IsTest
public class TargetingControllerRefactoredTest {

	@IsTest
	public static void targetTest() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csmso__Business_Unit__c tmpBU = new csmso__Business_Unit__c();
		tmpBU.csmso__Sales_Ledger_Code__c = '123';
		insert tmpBU;

		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'United States';
		geoItem.csdf__Ad_Server_Id__c = '2840';
		insert geoItem;

		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Europe/London';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
		insert bookingTimeZone;

		csmso__Product_Node__c tmpPN = new csmso__Product_Node__c();
		tmpPN.csmso__Business_Unit__c = tmpBU.Id;
		tmpPN.Name = 'US';
		tmpPN.csmso__Description__c = 'United States';
		tmpPN.CurrencyIsoCode = 'USD';
		tmpPN.Unique_Id__c = 'US';
		tmpPN.csmso__Media_Types__c = 'Desktop';
		tmpPN.Geo_Targeting__c = geoItem.Id;
		tmpPN.Sponsorship_Booking_Timezone__c = bookingTimeZone.Id;
		tmpPN.NAA_supported_currency__c = 'SGD';
		insert tmpPN;

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

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		insert prodConfig;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		testFulfilmentItem.Product_Configuration__c = null;
		insert testFulfilmentItem;

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		csmso__Node_Advert_Assignment__c advertAssignment = new csmso__Node_Advert_Assignment__c();
		advertAssignment.csmso__Media_Types__c = 'Desktop';
		advertAssignment.csmso__Title_Product_Node__c = tmpPN.Id;
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
		advertAssignment.Ad_Server__c = testAdServer.Id;
		advertAssignment.Ad_Slot_Names__c = 'SPT_AD_Unit';
		advertAssignment.Invoice_GL_Code__c = '123456789';
		advertAssignment.Rev_Accrual_GL_Code__c = '123456789';
		advertAssignment.Priority__c = '6';
		insert advertAssignment;

		csdf__Ad_Slot__c testAdSlot = new csdf__Ad_Slot__c(csdf__Ad_Server__c = testAdServer.Id, csdf__Ad_Server_Id__c = 'testserverid', csdf__Code__c = 'testcodeName', csdf__Name__c = 'testadname');
		insert testAdSlot;

		csdf__Targeting_Template__c testTargetTemp = TestDataSetupTargetables.createTargetTemp(testAdServer);
		insert testTargetTemp;

		csdf__Geo_Item__c testGeoItem = TestDataSetupTargetables.createGeoItem();
		insert testGeoItem;

		csdf__Geo_Item_Targeting_Template__c testGeoItemTargetTemp = TestDataSetupTargetables.createGeoItemTargetTemp(testGeoItem, testTargetTemp);
		insert testGeoItemTargetTemp;

		csdf__Browser__c testBrowser = TestDataSetupTargetables.createBrowser(testAdServer);
		insert testBrowser;

		csdf__Browser_Targeting_Template__c testBrowserTargetTemp = TestDataSetupTargetables.createBrowserTargetTemp(testBrowser, testTargetTemp);
		insert testBrowserTargetTemp;

		csdf__Targetable__c testTargetable = TestDataSetupTargetables.createTargetable(testAdServer);
		insert testTargetable;

		csdf__Targetable_Targeting_Template__c testTargetableTargetTemp = TestDataSetupTargetables.createTargetableTargetTemp(testTargetable, testTargetTemp);
		insert testTargetableTargetTemp;

		csdf__Operating_System__c testOS = TestDataSetupTargetables.createOS(testAdServer);
		insert testOS;

		csdf__Operating_System_Targeting_Template__c testOSTargetTemp = TestDataSetupTargetables.createOSTargetTemp(testOS, testTargetTemp);
		insert testOSTargetTemp;

		csdf__Operating_System_Version__c testOSVer = TestDataSetupTargetables.createOSVer(testOS);
		insert testOSVer;

		csdf__Operating_System_Version_Target_Template__c testOSVerTargTemp = TestDataSetupTargetables.createOSVerTargTemp(testOSVer, testTargetTemp);
		insert testOSVerTargTemp;

		List<TargetingQueryStrings__c> testTargetingQueryStrings = TestDataSetupTargetables.createTargetingQueryStrings();
		insert testTargetingQueryStrings;

		Test.startTest();
		TargetingControllerRefactored.TargetSearch targ = new TargetingControllerRefactored.TargetSearch();
		targ.targetType = 'tsttype';
		targ.searchText = 'tsttype';
		targ.selectedId = testAdServer.Id;
		targ.adServer = testAdServer.Id;
		targ.naa_Ids = advertAssignment.Id;
		targ.includedItems = testAdServer.Id;
		targ.excludedItems = testAdServer.Id;

		TargetingControllerRefactored.TargetInfo targinf = new TargetingControllerRefactored.TargetInfo();
		targinf.targetType = 'tsttype';
		targinf.searchText = 'tsttype';
		targinf.selectedId = testAdServer.Id;
		targinf.breadCrumbList = new List<TargetingControllerRefactored.BreadCrumb>();
		targinf.results = new List<TargetingControllerRefactored.TargetItem>();

		TargetingControllerRefactored.BreadCrumb br = new TargetingControllerRefactored.BreadCrumb();
		br.sortIndex = 5;
		br.targetId = testAdServer.Id;
		br.targetText = 'tst';

		TargetingControllerRefactored.TargetItem trg = new TargetingControllerRefactored.TargetItem();
		trg.itemId = testAdServer.Id;
		trg.name = 'tst';
		trg.selected = TargetingControllerRefactored.SELECTED_YES_INCLUDE;
		trg.hasChilds = true;

		String parameters = JSON.serialize(targ);

		TargetingControllerRefactored avClass = new TargetingControllerRefactored();
		String str = avClass.performAction(parameters);
		Test.stopTest();
	}

	@IsTest
	public static void target_inventoryTest() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		csmso__Business_Unit__c tmpBU = new csmso__Business_Unit__c();
		tmpBU.csmso__Sales_Ledger_Code__c = '123';
		insert tmpBU;

		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'United States';
		geoItem.csdf__Ad_Server_Id__c = '2840';
		insert geoItem;

		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Europe/London';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
		insert bookingTimeZone;

		csmso__Product_Node__c tmpPN = new csmso__Product_Node__c();
		tmpPN.csmso__Business_Unit__c = tmpBU.Id;
		tmpPN.Name = 'US';
		tmpPN.csmso__Description__c = 'United States';
		tmpPN.CurrencyIsoCode = 'USD';
		tmpPN.Unique_Id__c = 'US';
		tmpPN.csmso__Media_Types__c = 'Desktop';
		tmpPN.Geo_Targeting__c = geoItem.Id;
		tmpPN.Sponsorship_Booking_Timezone__c = bookingTimeZone.Id;
		tmpPN.NAA_supported_currency__c = 'SGD';
		insert tmpPN;

		csdf__Ad_Slot__c testAdSlot = new csdf__Ad_Slot__c(csdf__Ad_Server__c = testAdServer.Id,
				csdf__Ad_Server_Id__c = 'testserverid',
				csdf__Code__c = 'testcodeName',
				csdf__Name__c = 'testadname');
		insert testAdSlot;

		csmso__Node_Advert_Assignment__c advertAssignment = new csmso__Node_Advert_Assignment__c();
		advertAssignment.csmso__Media_Types__c = 'Desktop';
		advertAssignment.csmso__Title_Product_Node__c = tmpPN.Id;
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
		advertAssignment.Ad_Server__c = testAdServer.Id;
		advertAssignment.Ad_Slot_Names__c = 'SPT_AD_Unit';
		advertAssignment.Invoice_GL_Code__c = '123456789';
		advertAssignment.Rev_Accrual_GL_Code__c = '123456789';
		advertAssignment.Priority__c = '6';
		insert advertAssignment;

		List<TargetingQueryStrings__c> testTargetingQueryStrings = TestDataSetupTargetables.createTargetingQueryStrings();
		insert testTargetingQueryStrings;

		Test.startTest();
		TargetingControllerRefactored.TargetSearch targ = new TargetingControllerRefactored.TargetSearch();
		targ.targetType = 'Inventory';
		targ.searchText = 'tsttype';
		targ.selectedId = testAdServer.Id;
		targ.adServer = testAdServer.Id;
		targ.naa_Ids = advertAssignment.Id;
		targ.includedItems = testAdServer.Id;
		targ.excludedItems = testAdServer.Id;

		String parameters = JSON.serialize(targ);

		TargetingControllerRefactored avClass = new TargetingControllerRefactored();
		String str = avClass.performAction(parameters);

		targ = new TargetingControllerRefactored.TargetSearch();
		targ.targetType = 'Ad Unit & Placements';
		targ.searchText = 'tsttype';
		targ.selectedId = testAdServer.Id;
		targ.adServer = testAdServer.Id;
		targ.naa_Ids = advertAssignment.Id;
		targ.includedItems = testAdServer.Id;
		targ.excludedItems = testAdServer.Id;
		parameters = JSON.serialize(targ);
		avClass = new TargetingControllerRefactored();
		str = avClass.performAction(parameters);
		Test.stopTest();
	}

	@IsTest
	public static void target_geoTest() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		csmso__Business_Unit__c tmpBU = new csmso__Business_Unit__c();
		tmpBU.csmso__Sales_Ledger_Code__c = '123';
		insert tmpBU;

		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'United States';
		geoItem.csdf__Ad_Server_Id__c = '2840';
		insert geoItem;

		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Europe/London';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
		insert bookingTimeZone;

		csmso__Product_Node__c tmpPN = new csmso__Product_Node__c();
		tmpPN.csmso__Business_Unit__c = tmpBU.Id;
		tmpPN.Name = 'US';
		tmpPN.csmso__Description__c = 'United States';
		tmpPN.CurrencyIsoCode = 'USD';
		tmpPN.Unique_Id__c = 'US';
		tmpPN.csmso__Media_Types__c = 'Desktop';
		tmpPN.Geo_Targeting__c = geoItem.Id;
		tmpPN.Sponsorship_Booking_Timezone__c = bookingTimeZone.Id;
		tmpPN.NAA_supported_currency__c = 'SGD';
		insert tmpPN;

		csmso__Node_Advert_Assignment__c advertAssignment = new csmso__Node_Advert_Assignment__c();
		advertAssignment.csmso__Media_Types__c = 'Desktop';
		advertAssignment.csmso__Title_Product_Node__c = tmpPN.Id;
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
		advertAssignment.Ad_Server__c = testAdServer.Id;
		advertAssignment.Ad_Slot_Names__c = 'SPT_AD_Unit';
		advertAssignment.Invoice_GL_Code__c = '123456789';
		advertAssignment.Rev_Accrual_GL_Code__c = '123456789';
		advertAssignment.Priority__c = '6';
		insert advertAssignment;

		List<TargetingQueryStrings__c> testTargetingQueryStrings = TestDataSetupTargetables.createTargetingQueryStrings();
		insert testTargetingQueryStrings;

		Test.startTest();
		TargetingControllerRefactored.TargetSearch targ = new TargetingControllerRefactored.TargetSearch();
		targ.targetType = 'Geography';
		targ.searchText = 'tsttype';
		targ.selectedId = testAdServer.Id;
		targ.adServer = testAdServer.Id;
		targ.naa_Ids = advertAssignment.Id;
		targ.includedItems = testAdServer.Id;
		targ.excludedItems = testAdServer.Id;
		String parameters = JSON.serialize(targ);
		TargetingControllerRefactored avClass = new TargetingControllerRefactored();
		String str = avClass.performAction(parameters);
		Test.stopTest();
	}

	@IsTest
	public static void target_osTest() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		csmso__Business_Unit__c tmpBU = new csmso__Business_Unit__c();
		tmpBU.csmso__Sales_Ledger_Code__c = '123';
		insert tmpBU;

		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'United States';
		geoItem.csdf__Ad_Server_Id__c = '2840';
		insert geoItem;

		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Europe/London';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
		insert bookingTimeZone;

		csmso__Product_Node__c tmpPN = new csmso__Product_Node__c();
		tmpPN.csmso__Business_Unit__c = tmpBU.Id;
		tmpPN.Name = 'US';
		tmpPN.csmso__Description__c = 'United States';
		tmpPN.CurrencyIsoCode = 'USD';
		tmpPN.Unique_Id__c = 'US';
		tmpPN.csmso__Media_Types__c = 'Desktop';
		tmpPN.Geo_Targeting__c = geoItem.Id;
		tmpPN.Sponsorship_Booking_Timezone__c = bookingTimeZone.Id;
		tmpPN.NAA_supported_currency__c = 'SGD';
		insert tmpPN;

		csmso__Node_Advert_Assignment__c advertAssignment = new csmso__Node_Advert_Assignment__c();
		advertAssignment.csmso__Media_Types__c = 'Desktop';
		advertAssignment.csmso__Title_Product_Node__c = tmpPN.Id;
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
		advertAssignment.Ad_Server__c = testAdServer.Id;
		advertAssignment.Ad_Slot_Names__c = 'SPT_AD_Unit';
		advertAssignment.Invoice_GL_Code__c = '123456789';
		advertAssignment.Rev_Accrual_GL_Code__c = '123456789';
		advertAssignment.Priority__c = '6';
		insert advertAssignment;

		csdf__Operating_System__c testOS = TestDataSetupTargetables.createOS(testAdServer);
		testOS.Name = 'searchTextSoql';
		testOS.csdf__Active__c = true;
		insert testOS;

		csdf__Targeting_Template__c testTargetTemp = TestDataSetupTargetables.createTargetTemp(testAdServer);
		insert testTargetTemp;

		csdf__Operating_System_Targeting_Template__c testOSTargetTemp = TestDataSetupTargetables.createOSTargetTemp(testOS, testTargetTemp);
		insert testOSTargetTemp;

		csdf__Operating_System_Version__c testOSVer = TestDataSetupTargetables.createOSVer(testOS);
		insert testOSVer;

		List<TargetingQueryStrings__c> testTargetingQueryStrings = TestDataSetupTargetables.createTargetingQueryStrings();
		insert testTargetingQueryStrings;

		Test.startTest();
		TargetingControllerRefactored.TargetSearch targ = new TargetingControllerRefactored.TargetSearch();
		targ.targetType = 'Operating System';
		targ.searchText = 'searchTextSoql';
		targ.selectedId = testAdServer.Id;
		targ.adServer = testAdServer.Id;
		targ.naa_Ids = advertAssignment.Id;
		targ.includedItems = testAdServer.Id;
		targ.excludedItems = testAdServer.Id;
		String parameters = JSON.serialize(targ);
		TargetingControllerRefactored avClass = new TargetingControllerRefactored();
		String str = avClass.performAction(parameters);
		Test.stopTest();
	}

	@IsTest
	public static void target_browserTest() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		csmso__Business_Unit__c tmpBU = new csmso__Business_Unit__c();
		tmpBU.csmso__Sales_Ledger_Code__c = '123';
		insert tmpBU;

		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'United States';
		geoItem.csdf__Ad_Server_Id__c = '2840';
		insert geoItem;

		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Europe/London';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
		insert bookingTimeZone;

		csmso__Product_Node__c tmpPN = new csmso__Product_Node__c();
		tmpPN.csmso__Business_Unit__c = tmpBU.Id;
		tmpPN.Name = 'US';
		tmpPN.csmso__Description__c = 'United States';
		tmpPN.CurrencyIsoCode = 'USD';
		tmpPN.Unique_Id__c = 'US';
		tmpPN.csmso__Media_Types__c = 'Desktop';
		tmpPN.Geo_Targeting__c = geoItem.Id;
		tmpPN.Sponsorship_Booking_Timezone__c = bookingTimeZone.Id;
		tmpPN.NAA_supported_currency__c = 'SGD';
		insert tmpPN;

		csmso__Node_Advert_Assignment__c advertAssignment = new csmso__Node_Advert_Assignment__c();
		advertAssignment.csmso__Media_Types__c = 'Desktop';
		advertAssignment.csmso__Title_Product_Node__c = tmpPN.Id;
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
		advertAssignment.Ad_Server__c = testAdServer.Id;
		advertAssignment.Ad_Slot_Names__c = 'SPT_AD_Unit';
		advertAssignment.Invoice_GL_Code__c = '123456789';
		advertAssignment.Rev_Accrual_GL_Code__c = '123456789';
		advertAssignment.Priority__c = '6';
		insert advertAssignment;

		csdf__Browser__c testBrowser = TestDataSetupTargetables.createBrowser(testAdServer);
		testBrowser.csdf__Browser_Name__c = 'tsttype';
		testBrowser.csdf__Active__c = true;
		insert testBrowser;

		List<TargetingQueryStrings__c> testTargetingQueryStrings = TestDataSetupTargetables.createTargetingQueryStrings();
		insert testTargetingQueryStrings;

		Test.startTest();
		TargetingControllerRefactored.TargetSearch targ = new TargetingControllerRefactored.TargetSearch();
		targ.targetType = 'Browser';
		targ.searchText = 'tsttype';
		targ.selectedId = testAdServer.Id;
		targ.adServer = testAdServer.Id;
		targ.naa_Ids = advertAssignment.Id;
		targ.includedItems = testAdServer.Id;
		targ.excludedItems = testAdServer.Id;
		String parameters = JSON.serialize(targ);
		TargetingControllerRefactored avClass = new TargetingControllerRefactored();
		String str = avClass.performAction(parameters);

		targ.targetType = 'ZipSearch';
		String parametersZip = JSON.serialize(targ);
		avClass.performAction(parametersZip);
		Test.stopTest();
	}

	@IsTest
	public static void target_targetableTest() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		csmso__Business_Unit__c tmpBU = new csmso__Business_Unit__c();
		tmpBU.csmso__Sales_Ledger_Code__c = '123';
		insert tmpBU;

		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'United States';
		geoItem.csdf__Ad_Server_Id__c = '2840';
		insert geoItem;

		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Europe/London';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
		insert bookingTimeZone;

		csmso__Product_Node__c tmpPN = new csmso__Product_Node__c();
		tmpPN.csmso__Business_Unit__c = tmpBU.Id;
		tmpPN.Name = 'US';
		tmpPN.csmso__Description__c = 'United States';
		tmpPN.CurrencyIsoCode = 'USD';
		tmpPN.Unique_Id__c = 'US';
		tmpPN.csmso__Media_Types__c = 'Desktop';
		tmpPN.Geo_Targeting__c = geoItem.Id;
		tmpPN.Sponsorship_Booking_Timezone__c = bookingTimeZone.Id;
		tmpPN.NAA_supported_currency__c = 'SGD';
		insert tmpPN;

		csmso__Node_Advert_Assignment__c advertAssignment = new csmso__Node_Advert_Assignment__c();
		advertAssignment.csmso__Media_Types__c = 'Desktop';
		advertAssignment.csmso__Title_Product_Node__c = tmpPN.Id;
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
		advertAssignment.Ad_Server__c = testAdServer.Id;
		advertAssignment.Ad_Slot_Names__c = 'SPT_AD_Unit';
		advertAssignment.Invoice_GL_Code__c = '123456789';
		advertAssignment.Rev_Accrual_GL_Code__c = '123456789';
		advertAssignment.Priority__c = '6';
		insert advertAssignment;

		csdf__Targetable__c testTargetable = TestDataSetupTargetables.createTargetable(testAdServer);
		testTargetable.csdf__Targetable_Name__c = 'tsttype';
		testTargetable.csdf__Active__c = true;
		insert testTargetable;

		List<TargetingQueryStrings__c> testTargetingQueryStrings = TestDataSetupTargetables.createTargetingQueryStrings();
		insert testTargetingQueryStrings;

		Test.startTest();
		TargetingControllerRefactored.TargetSearch targ = new TargetingControllerRefactored.TargetSearch();
		targ.targetType = 'Targetable';
		targ.searchText = 'tsttype';
		targ.selectedId = testAdServer.Id;
		targ.adServer = testAdServer.Id;
		targ.naa_Ids = advertAssignment.Id;
		targ.includedItems = testAdServer.Id;
		targ.excludedItems = testAdServer.Id;
		String parameters = JSON.serialize(targ);
		TargetingControllerRefactored avClass = new TargetingControllerRefactored();
		String str = avClass.performAction(parameters);

		targ.targetType = 'ZipSearch';
		String parametersZip = JSON.serialize(targ);
		avClass.performAction(parametersZip);
		Test.stopTest();
	}

	@IsTest
	public static void target_DeviceManTest() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		csmso__Business_Unit__c tmpBU = new csmso__Business_Unit__c();
		tmpBU.csmso__Sales_Ledger_Code__c = '123';
		insert tmpBU;

		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'United States';
		geoItem.csdf__Ad_Server_Id__c = '2840';
		insert geoItem;

		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Europe/London';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
		insert bookingTimeZone;

		csmso__Product_Node__c tmpPN = new csmso__Product_Node__c();
		tmpPN.csmso__Business_Unit__c = tmpBU.Id;
		tmpPN.Name = 'US';
		tmpPN.csmso__Description__c = 'United States';
		tmpPN.CurrencyIsoCode = 'USD';
		tmpPN.Unique_Id__c = 'US';
		tmpPN.csmso__Media_Types__c = 'Desktop';
		tmpPN.Geo_Targeting__c = geoItem.Id;
		tmpPN.Sponsorship_Booking_Timezone__c = bookingTimeZone.Id;
		tmpPN.NAA_supported_currency__c = 'SGD';
		insert tmpPN;

		csmso__Node_Advert_Assignment__c advertAssignment = new csmso__Node_Advert_Assignment__c();
		advertAssignment.csmso__Media_Types__c = 'Desktop';
		advertAssignment.csmso__Title_Product_Node__c = tmpPN.Id;
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
		advertAssignment.Ad_Server__c = testAdServer.Id;
		advertAssignment.Ad_Slot_Names__c = 'SPT_AD_Unit';
		advertAssignment.Invoice_GL_Code__c = '123456789';
		advertAssignment.Rev_Accrual_GL_Code__c = '123456789';
		advertAssignment.Priority__c = '6';
		insert advertAssignment;

		csdf__Targetable__c testTargetable = TestDataSetupTargetables.createTargetable(testAdServer);
		testTargetable.csdf__Targetable_Name__c = 'tsttype';
		testTargetable.csdf__Active__c = true;
		insert testTargetable;

		List<TargetingQueryStrings__c> testTargetingQueryStrings = TestDataSetupTargetables.createTargetingQueryStrings();
		insert testTargetingQueryStrings;

		Test.startTest();
		TargetingControllerRefactored.TargetSearch targ = new TargetingControllerRefactored.TargetSearch();
		targ.targetType = 'Manufacturer/device';
		targ.searchText = 'tsttype';
		targ.selectedId = null;
		targ.adServer = testAdServer.Id;
		targ.includedItems = testAdServer.Id;
		targ.excludedItems = testAdServer.Id;
		String parameters = JSON.serialize(targ);
		TargetingControllerRefactored avClass = new TargetingControllerRefactored();
		String str = avClass.performAction(parameters);

		targ.selectedId = testAdServer.Id;
		targ.adServer = testAdServer.Id;
		targ.includedItems = testAdServer.Id;
		targ.excludedItems = testAdServer.Id;
		parameters = JSON.serialize(targ);
		avClass = new TargetingControllerRefactored();
		str = avClass.performAction(parameters);

		targ.targetType = 'ZipSearch';
		String parametersZip = JSON.serialize(targ);
		avClass.performAction(parametersZip);
		Test.stopTest();
	}

	@IsTest
	public static void target_MobileCarriersTest() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		csmso__Business_Unit__c tmpBU = new csmso__Business_Unit__c();
		tmpBU.csmso__Sales_Ledger_Code__c = '123';
		insert tmpBU;

		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'United States';
		geoItem.csdf__Ad_Server_Id__c = '2840';
		insert geoItem;

		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Europe/London';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
		insert bookingTimeZone;

		csmso__Product_Node__c tmpPN = new csmso__Product_Node__c();
		tmpPN.csmso__Business_Unit__c = tmpBU.Id;
		tmpPN.Name = 'US';
		tmpPN.csmso__Description__c = 'United States';
		tmpPN.CurrencyIsoCode = 'USD';
		tmpPN.Unique_Id__c = 'US';
		tmpPN.csmso__Media_Types__c = 'Desktop';
		tmpPN.Geo_Targeting__c = geoItem.Id;
		tmpPN.Sponsorship_Booking_Timezone__c = bookingTimeZone.Id;
		tmpPN.NAA_supported_currency__c = 'SGD';
		insert tmpPN;

		csmso__Node_Advert_Assignment__c advertAssignment = new csmso__Node_Advert_Assignment__c();
		advertAssignment.csmso__Media_Types__c = 'Desktop';
		advertAssignment.csmso__Title_Product_Node__c = tmpPN.Id;
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
		advertAssignment.Ad_Server__c = testAdServer.Id;
		advertAssignment.Ad_Slot_Names__c = 'SPT_AD_Unit';
		advertAssignment.Invoice_GL_Code__c = '123456789';
		advertAssignment.Rev_Accrual_GL_Code__c = '123456789';
		advertAssignment.Priority__c = '6';
		insert advertAssignment;

		csdf__Targetable__c testTargetable = TestDataSetupTargetables.createTargetable(testAdServer);
		testTargetable.csdf__Targetable_Name__c = 'tsttype';
		testTargetable.csdf__Type__c = 'Mobile Carrier';
		testTargetable.csdf__Active__c = true;
		insert testTargetable;

		List<TargetingQueryStrings__c> testTargetingQueryStrings = TestDataSetupTargetables.createTargetingQueryStrings();
		insert testTargetingQueryStrings;

		Test.startTest();
		TargetingControllerRefactored.TargetSearch targ = new TargetingControllerRefactored.TargetSearch();
		targ.targetType = 'Mobile Carrier';
		targ.searchText = 'tsttype';
		targ.selectedId = null;
		targ.adServer = testAdServer.Id;
		targ.includedItems = testAdServer.Id;
		targ.excludedItems = testAdServer.Id;
		String parameters = JSON.serialize(targ);
		TargetingControllerRefactored avClass = new TargetingControllerRefactored();
		String str = avClass.performAction(parameters);

		targ.selectedId = testAdServer.Id;
		targ.adServer = testAdServer.Id;
		targ.includedItems = testAdServer.Id;
		targ.excludedItems = testAdServer.Id;
		parameters = JSON.serialize(targ);
		avClass = new TargetingControllerRefactored();
		str = avClass.performAction(parameters);
		Test.stopTest();
	}

	@IsTest
	public static void target_DeviceCategories() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		csmso__Business_Unit__c tmpBU = new csmso__Business_Unit__c();
		tmpBU.csmso__Sales_Ledger_Code__c = '123';
		insert tmpBU;

		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'United States';
		geoItem.csdf__Ad_Server_Id__c = '2840';
		insert geoItem;

		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Europe/London';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
		insert bookingTimeZone;

		csmso__Product_Node__c tmpPN = new csmso__Product_Node__c();
		tmpPN.csmso__Business_Unit__c = tmpBU.Id;
		tmpPN.Name = 'US';
		tmpPN.csmso__Description__c = 'United States';
		tmpPN.CurrencyIsoCode = 'USD';
		tmpPN.Unique_Id__c = 'US';
		tmpPN.csmso__Media_Types__c = 'Desktop';
		tmpPN.Geo_Targeting__c = geoItem.Id;
		tmpPN.Sponsorship_Booking_Timezone__c = bookingTimeZone.Id;
		tmpPN.NAA_supported_currency__c = 'SGD';
		insert tmpPN;

		csmso__Node_Advert_Assignment__c advertAssignment = new csmso__Node_Advert_Assignment__c();
		advertAssignment.csmso__Media_Types__c = 'Desktop';
		advertAssignment.csmso__Title_Product_Node__c = tmpPN.Id;
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
		advertAssignment.Ad_Server__c = testAdServer.Id;
		advertAssignment.Ad_Slot_Names__c = 'SPT_AD_Unit';
		advertAssignment.Invoice_GL_Code__c = '123456789';
		advertAssignment.Rev_Accrual_GL_Code__c = '123456789';
		advertAssignment.Priority__c = '6';
		insert advertAssignment;

		csdf__Targetable__c testTargetable = TestDataSetupTargetables.createTargetable(testAdServer);
		testTargetable.csdf__Targetable_Name__c = 'tsttype';
		testTargetable.csdf__Type__c = 'Device Category';
		testTargetable.csdf__Active__c = true;
		insert testTargetable;

		List<TargetingQueryStrings__c> testTargetingQueryStrings = TestDataSetupTargetables.createTargetingQueryStrings();
		insert testTargetingQueryStrings;

		Test.startTest();
		TargetingControllerRefactored.TargetSearch targ = new TargetingControllerRefactored.TargetSearch();
		targ.targetType = 'Device Category';
		targ.searchText = 'tsttype';
		targ.selectedId = null;
		targ.adServer = testAdServer.Id;
		targ.includedItems = testAdServer.Id;
		targ.excludedItems = testAdServer.Id;
		String parameters = JSON.serialize(targ);
		TargetingControllerRefactored avClass = new TargetingControllerRefactored();
		String str = avClass.performAction(parameters);

		targ.selectedId = testAdServer.Id;
		targ.adServer = testAdServer.Id;
		targ.includedItems = testAdServer.Id;
		targ.excludedItems = testAdServer.Id;
		parameters = JSON.serialize(targ);
		avClass = new TargetingControllerRefactored();
		str = avClass.performAction(parameters);
		Test.stopTest();
	}

	@IsTest
	public static void target_loadKeys() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		csdf__Custom_Targeting_Key__c ctk = new csdf__Custom_Targeting_Key__c();
		ctk.csdf__Ad_Server_Id__c = testAdServer.Id;
		ctk.csdf__Ad_Server__c = testAdServer.Id ;
		ctk.Name = 'SomeName';
		ctk.csdf__Display_Name__c = 'SomeDisplayName';
		insert ctk;

		List<TargetingQueryStrings__c> testTargetingQueryStrings = TestDataSetupTargetables.createTargetingQueryStrings();
		insert testTargetingQueryStrings;

		CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();

		Test.startTest();
		TargetingControllerRefactored.TargetSearch targ = new TargetingControllerRefactored.TargetSearch();
		targ.targetType = 'Key-value and Audience';
		targ.searchText = 'tsttype';
		targ.adServer = testAdServer.Id;

		String parameters = JSON.serialize(targ);
		TargetingControllerRefactored avClass = new TargetingControllerRefactored();
		String str = avClass.performAction(parameters);
		String parametersZip = JSON.serialize(targ);
		avClass.performAction(parametersZip);

		customSettings.KeyValue_configuration__c = 'ID';
		update customSettings;

		parameters = JSON.serialize(targ);
		avClass = new TargetingControllerRefactored();
		str = avClass.performAction(parameters);
		parametersZip = JSON.serialize(targ);
		avClass.performAction(parametersZip);
		Test.stopTest();
	}

	@IsTest
	public static void target_loadValues() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		csdf__Targetable__c target = TestDataSetupTargetables.createTargetable(testAdServer);
		target.csdf__Active__c = true;
		target.csdf__Ad_Server__c = testAdServer.Id;
		insert target;

		List<TargetingQueryStrings__c> testTargetingQueryStrings = TestDataSetupTargetables.createTargetingQueryStrings();
		insert testTargetingQueryStrings;

		CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();

		Test.startTest();
		TargetingControllerRefactored.TargetSearch targ = new TargetingControllerRefactored.TargetSearch();
		targ.adServer = testAdServer.Id;

		String parameters = JSON.serialize(targ);
		TargetingControllerRefactored avClass = new TargetingControllerRefactored();
		String str = avClass.performAction(parameters);
		String parametersZip = JSON.serialize(targ);
		avClass.performAction(parametersZip);

		customSettings.KeyValue_configuration__c = 'ID';
		update customSettings;

		parameters = JSON.serialize(targ);
		avClass = new TargetingControllerRefactored();
		str = avClass.performAction(parameters);
		parametersZip = JSON.serialize(targ);
		avClass.performAction(parametersZip);
		Test.stopTest();
	}


	@IsTest
	public static void target_loadBeginingKeysAndValues1() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		csdf__Custom_Targeting_Key__c ctk = new csdf__Custom_Targeting_Key__c();
		ctk.csdf__Ad_Server_Id__c = testAdServer.Id;
		ctk.csdf__Ad_Server__c = testAdServer.Id ;
		ctk.Name = 'SomeName';
		ctk.csdf__Display_Name__c = 'SomeDisplayName';
		insert ctk;

		csdf__Custom_Targeting_Value__c ctv = new csdf__Custom_Targeting_Value__c();
		ctv.csdf__Ad_Server_Id__c = testAdServer.Id;
		ctv.csdf__Custom_Targeting_Key__c = ctk.Id;
		ctv.csdf__Display_Name__c = 'SomeValueDisplayName';
		ctv.Name = 'SomeValueName';
		insert ctv;

		List<TargetingQueryStrings__c> testTargetingQueryStrings = TestDataSetupTargetables.createTargetingQueryStrings();
		insert testTargetingQueryStrings;

		Test.startTest();

		TargetingControllerRefactored.TargetSearch targ;
		TargetingControllerRefactored avClass;

		targ = new TargetingControllerRefactored.TargetSearch();
		targ.adServer = testAdServer.Id;
		targ.searchText = 'someSearch';
		targ.targetType = 'Channels';
		avClass = new TargetingControllerRefactored();
		avClass.performAction(JSON.serialize(targ));

		targ = new TargetingControllerRefactored.TargetSearch();
		targ.adServer = testAdServer.Id;
		targ.searchText = 'someSearch';
		targ.targetType = 'Device Category';
		avClass = new TargetingControllerRefactored();
		avClass.performAction(JSON.serialize(targ));

		targ = new TargetingControllerRefactored.TargetSearch();
		targ.adServer = testAdServer.Id;
		targ.searchText = 'someSearch';
		targ.targetType = 'Inventory';
		avClass = new TargetingControllerRefactored();
		avClass.performAction(JSON.serialize(targ));

		targ = new TargetingControllerRefactored.TargetSearch();
		targ.adServer = testAdServer.Id;
		targ.searchText = 'someSearch';
		targ.targetType = 'Geography';
		avClass = new TargetingControllerRefactored();
		avClass.performAction(JSON.serialize(targ));
		Test.stopTest();
	}

	@IsTest
	public static void target_loadBeginingKeysAndValues2() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		csdf__Custom_Targeting_Key__c ctk = new csdf__Custom_Targeting_Key__c();
		ctk.csdf__Ad_Server_Id__c = testAdServer.Id;
		ctk.csdf__Ad_Server__c = testAdServer.Id ;
		ctk.Name = 'SomeName';
		ctk.csdf__Display_Name__c = 'SomeDisplayName';
		insert ctk;

		csdf__Custom_Targeting_Value__c ctv = new csdf__Custom_Targeting_Value__c();
		ctv.csdf__Ad_Server_Id__c = testAdServer.Id;
		ctv.csdf__Custom_Targeting_Key__c = ctk.Id;
		ctv.csdf__Display_Name__c = 'SomeValueDisplayName';
		ctv.Name = 'SomeValueName';
		insert ctv;

		List<TargetingQueryStrings__c> testTargetingQueryStrings = TestDataSetupTargetables.createTargetingQueryStrings();
		insert testTargetingQueryStrings;

		Test.startTest();

		TargetingControllerRefactored.TargetSearch targ;
		TargetingControllerRefactored avClass;

		targ = new TargetingControllerRefactored.TargetSearch();
		targ.adServer = testAdServer.Id;
		targ.searchText = 'someSearch';
		targ.targetType = 'Operating System';
		avClass = new TargetingControllerRefactored();
		avClass.performAction(JSON.serialize(targ));

		targ = new TargetingControllerRefactored.TargetSearch();
		targ.adServer = testAdServer.Id;
		targ.searchText = 'someSearch';
		targ.targetType = 'Browser';
		avClass = new TargetingControllerRefactored();
		avClass.performAction(JSON.serialize(targ));

		targ = new TargetingControllerRefactored.TargetSearch();
		targ.adServer = testAdServer.Id;
		targ.searchText = 'someSearch';
		targ.targetType = 'Manufacturer/device';
		avClass = new TargetingControllerRefactored();
		avClass.performAction(JSON.serialize(targ));

		targ = new TargetingControllerRefactored.TargetSearch();
		targ.adServer = testAdServer.Id;
		targ.searchText = 'someSearch';
		targ.targetType = 'ZipSearch';
		avClass = new TargetingControllerRefactored();
		avClass.performAction(JSON.serialize(targ));

		targ = new TargetingControllerRefactored.TargetSearch();
		targ.adServer = testAdServer.Id;
		targ.searchText = 'someSearch';
		targ.targetType = 'Mobile Carrier';
		avClass = new TargetingControllerRefactored();
		avClass.performAction(JSON.serialize(targ));
		Test.stopTest();
	}
}
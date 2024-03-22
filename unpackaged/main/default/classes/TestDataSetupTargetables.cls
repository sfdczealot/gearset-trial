public class TestDataSetupTargetables {
	/*method to create a test account*/
	public static Account createAccount() {
		TestDataSetupBasic.insertPGAccountTrigger();

		String randomNumber = String.valueOf(Integer.valueOf((Math.random() * 100)));
		Corporate_Brand_Name__c corporateBrandName = new Corporate_Brand_Name__c();

		List<Corporate_Brand_Name__c> corporateBrandNameList = [SELECT Id FROM Corporate_Brand_Name__c];
		if (corporateBrandNameList.size() > 0) {
			corporateBrandName = corporateBrandNameList[0];
		} else {
			corporateBrandName = new Corporate_Brand_Name__c(Name = 'Test Corporate Brand Name ' + randomNumber,
					Global_Customer_Segment__c = 'Advertiser');
			insert corporateBrandName;
		}

		Id recordTypeId = CS_utl_RecordType.getRecordTypeId(Account.getSObjectType(), 'AD Sales - Commercial');

		Account testAccount = new Account(Name = 'testAccountForSalesOrderSupportTest ' + randomNumber, Website = 'www.cloudsense.com',
				BillingCity = 'City', BillingCountry = 'United States', BillingCountryCode = 'US', BillingPostalCode = '10000',
				BillingState = 'Alabama', BillingStateCode = 'AL', BillingStreet = 'Some Street', Billing_email__c = 'some@some.com',
				Industry = 'Agency', Industry_Tier_2__c = 'Media Agency', Type = 'Advertiser', CurrencyIsoCode = 'EUR',
				Corporate_Brand_Name__c = corporateBrandName.Id, RecordTypeId = recordTypeId);
		return testAccount;
	}

	/*method to create a test contact*/
	public static Contact createContact(Account acc) {
		Contact testContact = new Contact(FirstName = 'test', LastName = 'Con', AccountId = acc.Id,email='test@test.com');
		return testContact ;
	}

	/*method to create a test opportunity*/
	public static Opportunity createOpportunity(Account acc, Contact con) {
		Opportunity testOpportunity = new Opportunity(Name = 'testOpportunityForSalesOrderSupportTest' + System.now().getTime(),
				AccountId = acc.Id,
				StageName = 'Prospecting',
				CloseDate = System.today()
		);

		return testOpportunity ;
	}

	/*method to create a test Sales Order*/
	public static csmso__Sales_Order__c createSalesOrder(Account acc, Opportunity opp) {
		csmso__Sales_Order__c testSalesOrder = new csmso__Sales_Order__c();
		testSalesOrder.csmso__Advertiser__c = acc.Id;
		testSalesOrder.Advertiser_Final__c = acc.Id;
		testSalesOrder.csmso__Status__c = 'In Progress';
		testSalesOrder.csmso__Opportunity__c = opp.Id;
		testSalesOrder.Primary_Sales_Order__c = true;

		return testSalesOrder;
	}

	public static List<Account> createAccounts(Integer count) {
		TestDataSetupBasic.insertPGAccountTrigger();

		String randomNumber = String.valueOf(Integer.valueOf((Math.random() * 100)));
		Corporate_Brand_Name__c corporateBrandName = new Corporate_Brand_Name__c();

		List<Corporate_Brand_Name__c> corporateBrandNameList = [SELECT Id FROM Corporate_Brand_Name__c];
		if (corporateBrandNameList.size() > 0) {
			corporateBrandName = corporateBrandNameList[0];
		} else {
			corporateBrandName = new Corporate_Brand_Name__c(Name = 'Test Corporate Brand Name ' + randomNumber,
					Global_Customer_Segment__c = 'Advertiser');
			insert corporateBrandName;
		}

		Id recordTypeId = CS_utl_RecordType.getRecordTypeId(Account.getSObjectType(), 'AD Sales - Commercial');

		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < count; i++) {
			Account acc = new Account(Name = 'Test Account' + i, Website = 'www.cloudsense.com',
					BillingCity = 'City', BillingCountry = 'United States', BillingCountryCode = 'US', BillingPostalCode = '10000',
					BillingState = 'Alabama', BillingStateCode = 'AL', BillingStreet = 'Some Street', Billing_email__c = 'some@some.com',
					Industry = 'Agency', Industry_Tier_2__c = 'Media Agency', Type = 'Advertiser', CurrencyIsoCode = 'EUR',
					Corporate_Brand_Name__c = corporateBrandName.Id, RecordTypeId = recordTypeId);
			accounts.add(acc);
		}

		if (!accounts.isEmpty()) {
			insert accounts;
		}

		return accounts;
	}

	/****************************************************************************
	* Method Name : createContacts
	* Description : Used to create contacts
	* Parameters  : Integer which specifies the number of contacts to be created.
	* Return      : List of contacts created
	****************************************************************************/
	public static List<Contact> createContacts(Integer count, List<Account> accounts) {
		List<Contact> contacts = new List<Contact>();
		for (Integer i = 0; i < count; i++) {
			Contact con = new Contact(FirstName = 'Test', LastName = 'Con' + i, AccountId = accounts[i].Id,email='test'+i+'@test.com');
			contacts.add(con);
		}

		if (!contacts.isEmpty()) {
			insert contacts;
		}

		return contacts;
	}

	/*********************************************************************************
	* Method Name : createOpportunities
	* Description : Used to create opportunities
	* Parameters  : Integer which specifies the number of opportunities to be created.
	* Return      : List of opportunities created
	*********************************************************************************/
	public static List<Opportunity> createOpportunities(Integer count, List<Account> accounts, List<Contact> contacts) {
		List<Opportunity> opportunities = new List<Opportunity>();
		for (Integer i = 0; i < count; i++) {
			Opportunity opp = new Opportunity(Name = 'Test Opportunity' + i,
					AccountId = accounts[i].Id,
					SO_Booking_Contact__c = contacts[i].Id,
					StageName = 'Prospecting',
					CloseDate = System.today().addDays(10)
			);
			opportunities.add(opp);
		}

		if (!opportunities.isEmpty()) {
			insert opportunities;
		}

		return opportunities;
	}

	/*******************************************************************************
	* Method Name : createSalesOrders
	* Description : Used to create salesorders
	* Parameters  : Integer which specifies the number of salesorders to be created.
	* Return      : List of salesorders created
	********************************************************************************/
	public static List<csmso__Sales_Order__c> createSalesOrders(Integer count, List<Account> accounts, List<Opportunity> opportunities) {
		List<csmso__Sales_Order__c> salesOrders = new List<csmso__Sales_Order__c>();
		for (Integer i = 0; i < count; i++) {
			csmso__Sales_Order__c so = new csmso__Sales_Order__c();
			so.csmso__Advertiser__c = accounts[i].Id;
			so.csmso__Status__c = 'In Progress';
			so.csmso__Opportunity__c = opportunities[i].Id;
			so.Advertiser_Final__c = accounts[i].Id;
			salesOrders.add(so);
		}

		if (!salesOrders.isEmpty()) {
			insert salesOrders;
		}

		return salesOrders;
	}

	/*method to create a test Upload Approval*/
	public static csmso__Upload_Approval__c createUploadApproval(csmso__Sales_Order__c so) {
		csmso__Upload_Approval__c testUploadApproval = new csmso__Upload_Approval__c (Name = 'testName');
		testUploadApproval.csmso__Sales_Order__c = so.Id;
		return testUploadApproval ;
	}

	/*method to create a test ProductBasket*/
	public static cscfga__Product_Basket__c createProdBasket(csmso__Sales_Order__c so) {
		cscfga__Product_Basket__c testProdBasket = new cscfga__Product_Basket__c ();
		testProdBasket.csmso__Sales_Order__c = so.Id;
		return testProdBasket ;
	}

	/*method to create a test Product Configuration*/
	public static cscfga__Product_Configuration__c createProdConfig(cscfga__Product_Basket__c ProdBasket) {
		cscfga__Product_Configuration__c testProdConfig = new cscfga__Product_Configuration__c();
		// CPS test if the basket is null first
		testProdConfig.cscfga__Product_Basket__c = ProdBasket == null ? null : ProdBasket.Id;
		return testProdConfig ;
	}

	/*method to create a test Fulfilment*/
	public static csdf__Fulfilment__c createFulfilment(csmso__Sales_Order__c so, Account acc) {
		csdf__Fulfilment__c testFulfilment = new csdf__Fulfilment__c();
		testFulfilment.csdf__Advertiser__c = acc.Id;
		testFulfilment.Sales_Order__c = so.Id;
		testFulfilment.csdf__Name__c = 'Test_' + Datetime.now();
		return testFulfilment;
	}

	/*method to create a test Fulfilment item*/
	public static csdf__Fulfilment_Item__c createFulfilmentItem(cscfga__Product_Configuration__c prodConfig, csmso__Sales_Order__c so, csdf__Fulfilment__c testFulfilment) {
		csdf__Fulfilment_Item__c testFulfilmentItem = new csdf__Fulfilment_Item__c();
		testFulfilmentItem.csdf__Fulfilment__c = testFulfilment.Id;
		testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
		testFulfilmentItem.csdf__Flight_End__c = System.now();
		testFulfilmentItem.csdf__Name__c = 'testful';
		testFulfilmentItem.csdf__Availability_Check_Total_Amount__c = 1;
		testFulfilmentItem.csdf__Quantity__c = 20;
		testFulfilmentItem.csdf__Billing_Category__c = 'CPM';
		testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
		testFulfilmentItem.csdf__Flight_End__c = System.now();
		testFulfilmentItem.csdf__Quantity__c = 10;
		return testFulfilmentItem;
	}

	/*method to create a test product category*/
	public static cscfga__Product_Category__c createProdCateg() {
		cscfga__Product_Category__c testProdCateg = new cscfga__Product_Category__c();
		return testProdCateg ;
	}

	/*method to create a test product Definition*/
	public static cscfga__Product_Definition__c createProDef(cscfga__Product_Category__c prodCateg) {
		cscfga__Product_Definition__c testProDef = new cscfga__Product_Definition__c();
		testProDef.cscfga__Product_Category__c = prodCateg.Id;
		testProDef.cscfga__Description__c = 'testDescription';
		return testProDef ;
	}

	/*method to create a test Attribute Definition*/
	public static cscfga__Attribute_Definition__c createAttrDef(cscfga__Product_Definition__c proDef) {
		cscfga__Attribute_Definition__c testAttrDef = new cscfga__Attribute_Definition__c();
		testAttrDef.cscfga__Product_Definition__c = proDef.Id;
		testAttrDef.Name = 'Available Amount';
		return testAttrDef ;
	}

	public static cscfga__Configuration_Screen__c createConfigurationScreen(cscfga__Product_Definition__c prodDef, String Name) {
		cscfga__Configuration_Screen__c screenFlow = new cscfga__Configuration_Screen__c();
		screenFlow.cscfga__Product_Definition__c = prodDef.Id;
		screenFlow.cscfga__Index__c = 0;
		screenFlow.Name = Name;
		return screenFlow;
	}

	/*method to create a test Attribute*/
	public static cscfga__Attribute__c createAttr(cscfga__Product_Configuration__c prodConfig, csmso__Sales_Order__c so, cscfga__Attribute_Definition__c testAttrdef, csdf__Fulfilment_Item__c testFulfilmentItem) {
		cscfga__Attribute__c testAttr = new cscfga__Attribute__c();
		testAttr.cscfga__Product_Configuration__c = prodConfig.Id;
		testAttr.cscfga__Value__c = testFulfilmentItem.Id;
		testAttr.Name = 'Fulfilment Item';
		testAttr.cscfga__Attribute_Definition__c = testAttrdef.Id;
		return testAttr;
	}

	/*method to create a test adSlot*/
	public static csdf__Ad_Slot__c createAdSlot() {
		csdf__Ad_Slot__c testAdSlot = new csdf__Ad_Slot__c();
		testAdSlot.csdf__Ad_Server_Id__c = 'testserverid';
		testAdSlot.csdf__Code__c = 'testcodeName';
		testAdSlot.csdf__Name__c = 'testadname';
		return testAdSlot;
	}

	/*method to create a test ad server*/
	public static csdf__Ad_Server__c createAdServer() {
		csdf__Ad_Server__c testAdServer = new csdf__Ad_Server__c();
		testAdServer.csdf__Username__c = 'testUsername';
		testAdServer.csdf__Password__c = 'testPassword';
		testAdServer.csdf__Network_Code__c = 'testNetworkCode';
		return testAdServer;
	}

	/*method to create a test site*/
	public static csdf__Site__c createSite(csdf__Ad_Server__c testAdServer) {
		csdf__Site__c testSite = new csdf__Site__c();
		testSite.csdf__Ad_Server__c = testAdServer.Id;
		return testSite;
	}

	/*method to create a test Site targeting*/
	public static csdf__Site_Targeting__c createSiteTarget(csdf__Site__c testSite, csdf__Fulfilment_Item__c testFulfilmentItem) {
		csdf__Site_Targeting__c testSiteTarget = new csdf__Site_Targeting__c();
		testSiteTarget.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
		testSiteTarget.csdf__Site__c = testSite.Id;
		return testSiteTarget;
	}

	/*method to create a test targeting template*/
	public static csdf__Targeting_Template__c createTargetTemp(csdf__Ad_Server__c testAdServer) {
		csdf__Targeting_Template__c testTargetTemp = new csdf__Targeting_Template__c();
		testTargetTemp.csdf__Ad_Server__c = testAdServer.Id;
		testTargetTemp.csdf__Day_Part_Targeting__c = 'testDayPartTarget';
		testTargetTemp.csdf__Custom_Key_Targeting__c = 'testCustomKeyTarget';
		testTargetTemp.csdf__Description__c = 'testDesc';
		return testTargetTemp;
	}

	/*method to create a test geo item*/
	public static csdf__Geo_Item__c createGeoItem() {
		csdf__Geo_Item__c testGeoItem = new csdf__Geo_Item__c();
		testGeoItem.csdf__Ad_Server_Id__c = 'testAServerId';
		return testGeoItem;
	}

	/*method to create a test geo item targeting template*/
	public static csdf__Geo_Item_Targeting_Template__c createGeoItemTargetTemp(csdf__Geo_Item__c testGeoItem, csdf__Targeting_Template__c testTargetTemp) {
		csdf__Geo_Item_Targeting_Template__c testGeoItemTargetTemp = new csdf__Geo_Item_Targeting_Template__c();
		testGeoItemTargetTemp.csdf__Geo_Item__c = testGeoItem.Id;
		testGeoItemTargetTemp.csdf__Targeting_Template__c = testTargetTemp.Id;
		return testGeoItemTargetTemp;
	}

	/*method to create a test browser*/
	public static csdf__Browser__c createBrowser(csdf__Ad_Server__c testAdServer) {
		csdf__Browser__c testBrowser = new csdf__Browser__c();
		testBrowser.csdf__Ad_Server_Id__c = 'testAdserid';
		testBrowser.csdf__Ad_Server__c = testAdServer.Id;
		testBrowser.csdf__Browser_Name__c = 'testBrowser';
		return testBrowser;
	}

	/*method to create a test browser Targeting Template */
	public static csdf__Browser_Targeting_Template__c createBrowserTargetTemp(csdf__Browser__c testBrowser, csdf__Targeting_Template__c testTargetTemp) {
		csdf__Browser_Targeting_Template__c testBrowserTargetTemp = new csdf__Browser_Targeting_Template__c();
		testBrowserTargetTemp.csdf__Browser__c = testBrowser.Id;
		testBrowserTargetTemp.csdf__Targeting_Template__c = testTargetTemp.Id;
		return testBrowserTargetTemp;
	}

	/*method to create a test targetable*/
	public static csdf__Targetable__c createTargetable(csdf__Ad_Server__c testAdServer) {
		csdf__Targetable__c testTargetable = new csdf__Targetable__c();
		testTargetable.csdf__Ad_Server_Id__c = 'testAdserid';
		testTargetable.csdf__Ad_Server__c = testAdServer.Id;
		testTargetable.csdf__Type__c = 'Device Manufacturer';
		testTargetable.csdf__Targetable_Name__c = 'testTargetable';
		return testTargetable;
	}

	/*method to create a test targets Targeting Template */
	public static csdf__Targetable_Targeting_Template__c createTargetableTargetTemp(csdf__Targetable__c testTargetable, csdf__Targeting_Template__c testTargetTemp) {
		csdf__Targetable_Targeting_Template__c testTargetableTargetTemp = new csdf__Targetable_Targeting_Template__c();
		testTargetableTargetTemp.csdf__Targetable__c = testTargetable.Id;
		testTargetableTargetTemp.csdf__Targeting_Template__c = testTargetTemp.Id;
		return testTargetableTargetTemp;
	}

	/*method to create a test targets Targeting Template */
	public static List<TargetingQueryStrings__c> createTargetingQueryStrings() {
		List<TargetingQueryStrings__c> testTargetingQueryStrings = new List<TargetingQueryStrings__c>();
		TargetingQueryStrings__c tempQueryStrings = new TargetingQueryStrings__c();
		tempQueryStrings.Name = 'ChannelsNAA';
		tempQueryStrings.Base__c = 'FROM csmso__Node_Advert_Assignment__c';
		tempQueryStrings.Object__c = 'csmso__Node_Advert_Assignment__c';
		testTargetingQueryStrings.add(tempQueryStrings);
		tempQueryStrings = new TargetingQueryStrings__c();
		tempQueryStrings.Name = 'ChannelsRateCard';
		tempQueryStrings.Base__c = 'FROM csmso__Rate_Card_Item_Price__c';
		tempQueryStrings.Object__c = 'csmso__Rate_Card_Item_Price__c';
		testTargetingQueryStrings.add(tempQueryStrings);
		tempQueryStrings = new TargetingQueryStrings__c();
		tempQueryStrings.Name = 'DeviceCategories';
		tempQueryStrings.Base__c = 'FROM csdf__Targetable__c';
		tempQueryStrings.Object__c = 'csdf__Targetable__c';
		testTargetingQueryStrings.add(tempQueryStrings);
		tempQueryStrings = new TargetingQueryStrings__c();
		tempQueryStrings.Name = 'InventoryNAA';
		tempQueryStrings.Base__c = 'FROM csmso__Node_Advert_Assignment__c';
		tempQueryStrings.Object__c = 'csmso__Node_Advert_Assignment__c';
		testTargetingQueryStrings.add(tempQueryStrings);
		tempQueryStrings = new TargetingQueryStrings__c();
		tempQueryStrings.Name = 'InventoryAdSlots';
		tempQueryStrings.Base__c = 'FROM csdf__Ad_Slot__c';
		tempQueryStrings.Object__c = 'csdf__Ad_Slot__c';
		testTargetingQueryStrings.add(tempQueryStrings);
		tempQueryStrings = new TargetingQueryStrings__c();
		tempQueryStrings.Name = 'Geography';
		tempQueryStrings.Base__c = 'FROM csdf__Geo_Item__c';
		tempQueryStrings.Object__c = 'csdf__Geo_Item__c';
		testTargetingQueryStrings.add(tempQueryStrings);
		tempQueryStrings = new TargetingQueryStrings__c();
		tempQueryStrings.Name = 'OperatingSystems';
		tempQueryStrings.Base__c = 'FROM csdf__Operating_System__c';
		tempQueryStrings.Object__c = 'csdf__Operating_System__c';
		testTargetingQueryStrings.add(tempQueryStrings);
		tempQueryStrings = new TargetingQueryStrings__c();
		tempQueryStrings.Name = 'OperatingSystemsVersions';
		tempQueryStrings.Base__c = ',csdf__Operating_System__r.Name FROM csdf__Operating_System_Version__c';
		tempQueryStrings.Object__c = 'csdf__Operating_System_Version__c';
		testTargetingQueryStrings.add(tempQueryStrings);
		tempQueryStrings = new TargetingQueryStrings__c();
		tempQueryStrings.Name = 'Browsers';
		tempQueryStrings.Base__c = 'FROM csdf__Browser__c';
		tempQueryStrings.Object__c = 'csdf__Browser__c';
		testTargetingQueryStrings.add(tempQueryStrings);
		tempQueryStrings = new TargetingQueryStrings__c();
		tempQueryStrings.Name = 'DeviceManufacturer';
		tempQueryStrings.Base__c = 'FROM csdf__Targetable__c';
		tempQueryStrings.Object__c = 'csdf__Targetable__c';
		testTargetingQueryStrings.add(tempQueryStrings);
		tempQueryStrings = new TargetingQueryStrings__c();
		tempQueryStrings.Name = 'InventoryHierarchy';
		tempQueryStrings.Base__c = 'from csdf__Ad_Slot__c';
		tempQueryStrings.Object__c = 'csdf__Ad_Slot__c';
		testTargetingQueryStrings.add(tempQueryStrings);
		tempQueryStrings = new TargetingQueryStrings__c();
		tempQueryStrings.Name = 'MobileCarrier';
		tempQueryStrings.Base__c = 'from csdf__Targetable__c';
		tempQueryStrings.Object__c = 'csdf__Targetable__c';
		testTargetingQueryStrings.add(tempQueryStrings);
		return testTargetingQueryStrings;
	}

	/*method to create a test OS*/
	public static csdf__Operating_System__c createOS(csdf__Ad_Server__c testAdServer) {
		csdf__Operating_System__c testOS = new csdf__Operating_System__c();
		testOS.csdf__Ad_Server_Id__c = 'tstOsid';
		testOS.csdf__Ad_Server__c = testAdServer.Id;
		return testOS;
	}

	/*method to create a test OS Targeting Template */
	public static csdf__Operating_System_Targeting_Template__c createOSTargetTemp(csdf__Operating_System__c testOS, csdf__Targeting_Template__c testTargetTemp) {
		csdf__Operating_System_Targeting_Template__c testOSTargetTemp = new csdf__Operating_System_Targeting_Template__c();
		testOSTargetTemp.csdf__Operating_System__c = testOS.Id;
		testOSTargetTemp.csdf__Targeting_Template__c = testTargetTemp.Id;
		return testOSTargetTemp;
	}

	/*method to create a test OS version*/
	public static csdf__Operating_System_Version__c createOSVer(csdf__Operating_System__c testOS) {
		csdf__Operating_System_Version__c testOSVer = new csdf__Operating_System_Version__c();
		testOSVer.csdf__Ad_Server_Id__c = 'testVerId';
		testOSVer.csdf__Operating_System__c = testOS.Id;
		return testOSVer;
	}

	/*method to create a test OS version target template*/
	public static csdf__Operating_System_Version_Target_Template__c createOSVerTargTemp(csdf__Operating_System_Version__c testOSVer, csdf__Targeting_Template__c testTargetTemp) {
		csdf__Operating_System_Version_Target_Template__c testOSVerTargTemp = new csdf__Operating_System_Version_Target_Template__c ();
		testOSVerTargTemp.csdf__Operating_System_Version__c = testOSVer.Id;
		testOSVerTargTemp.csdf__Targeting_Template__c = testTargetTemp.Id;
		return testOSVerTargTemp;
	}

	/*method to create a test Click Approve contact role Setting*/
	public static CSCAP__Click_Approve_Setting__c createClkAppSet() {
		CSCAP__Click_Approve_Setting__c testClkAppSet = new CSCAP__Click_Approve_Setting__c();
		testClkAppSet.Name = 'IO Email Approval Setting';
		return testClkAppSet;
	}

	/*method to create a test Click Approve contact role Setting*/
	public static CSCAP__ClickApprove_Contact_Role__c createClkAppConRoleSet(csmso__Upload_Approval__c testUploadApproval) {
		CSCAP__ClickApprove_Contact_Role__c testClkAppConRoleSet = new CSCAP__ClickApprove_Contact_Role__c();
		testClkAppConRoleSet.Upload_Approval__c = testUploadApproval.Id;
		return testClkAppConRoleSet;
	}

	/*method to create a test ObjectGraph Callout Handler*/
	public static csam__ObjectGraph_Callout_Handler__c createObjGrph() {
		csam__ObjectGraph_Callout_Handler__c testObjGrph = new csam__ObjectGraph_Callout_Handler__c();
		testObjGrph.Name = 'Ad Server Fulfilment New';
		testObjGrph.csam__Method__c = 'PUT';
		testObjGrph.csam__Integration_Endpoint_Name__c = 'Ad Server Integration';
		testObjGrph.csam__URL_Path__c = '/services/adserver/fulfilment/new';
		testObjGrph.csam__Startpoint_Type_Name__c = 'csdf__Fulfilment_Item__c';
		return testObjGrph;
	}

	public static csdf__Performance_Log__c createPerform() {
		csdf__Performance_Log__c testperf = new csdf__Performance_Log__c();
		return testperf;
	}

	public static csmso__Node_Advert_Assignment__c createad() {
		csmso__Node_Advert_Assignment__c testad = new csmso__Node_Advert_Assignment__c();
		testad.Name = 'testadname';
		return testad;
	}

	/****************************************************************************
	* Method Name : createIncomingMsgs
	* Description : Used to create Incoming Messages
	****************************************************************************/
	public static List<csam__Incoming_Message__c> createInMsgs(Integer count) {
		List<csam__Incoming_Message__c> inMsgs = new List<csam__Incoming_Message__c>();
		for (Integer i = 0; i < count; i++) {
			csam__Incoming_Message__c im = new csam__Incoming_Message__c(Name = 'Test msg' + i, csam__HTTP_Method__c = 'test');
			inMsgs.add(im);
		}

		if (!inMsgs.isEmpty()) {
			insert inMsgs;
		}

		return inMsgs;
	}

	/*******************************************************************
	* Method Name : createCSCustomSettings - Modified by CPS
	* Description : Used to create Org Default entry in CSCustomSettings
	* Parameters  : NA
	* Return      : NA
	*******************************************************************/
	public static CS_Custom_Settings__c createCSCustomSettings() {
		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.SetupOwnerId = UserInfo.getOrganizationId();
		cs.Ad_Server_Network_Code__c = '5819';
		cs.KeyValue_configuration__c = 'string';
		insert cs;
		return cs;
	}

	/*******************************************************************
	* Method Name : createPurgeBatchJob - Modified by CPS
	* Description : Used to create Org Default entry in Purge Batch Job
	* Parameters  : NA
	* Return      : NA
	*******************************************************************/
	public static void createPurgeBatchJob() {
		Purge_Batch_Job__c pb = new Purge_Batch_Job__c();
		pb.Name = 'testName';
		pb.Object_API_Name__c = 'csam__Incoming_Message__c';
		pb.Number_of_Days_To_Purge__c = 0;
		insert pb;
	}
}
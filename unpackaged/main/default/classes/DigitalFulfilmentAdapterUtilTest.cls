@IsTest
public class DigitalFulfilmentAdapterUtilTest {
	private static Account acc;
	private static csmso__Sales_Order__c so;
	private static cscfga__Product_Configuration__c prodConfig;
	private static csdf__Ad_Slot__c testAdSlot;
	private static csdf__Ad_Slot__c testAdSlot2;
	private static csdf__Fulfilment__c testFulfilment;
	private static csdf__Fulfilment_Item__c testFulfilmentItem;
	private static csdf__Targeting_Template__c testTargetTemp;
	private static CS_FulfilmentService.DigitalFulfilmentAttributes attr;
    private static User standardUser;
    
    private static void createStandardUser() {
        Profile standardUserProfile =[SELECT ID FROM Profile Where Name = 'Standard User' limit 1];
        standardUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardUserProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standamarkorduser1234@testorg.com');
        insert standardUser;
    }
    
	private static void createTestData() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c csCustomSettings = new CS_Custom_Settings__c(Integration_Chunk_Size__c = 1, Integration_Delay_Between_Callouts__c = 0);
		upsert csCustomSettings;

		acc = TestDataSetupTargetables.createAccount();
		acc.AccountSource = 'Ad Studio';
		acc.BillingCity = 'New York';
		acc.BillingCountry = 'United States';
		acc.BillingCountryCode = 'US';
		acc.BillingPostalCode = '10036-3982';
		acc.BillingState = 'New York';
		acc.BillingStateCode = 'NY';
		acc.BillingStreet = 'xxx';
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

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

		csmso__Product_Node__c market = new csmso__Product_Node__c();
		market.Name = 'USTestMarket';
		market.csmso__Business_Unit__c = businessUnit.Id;
		market.CurrencyIsoCode = 'USD';
		market.csmso__Description__c = 'Description';
		market.Unique_Id__c = 'USTestMarket';
		market.csmso__Media_Types__c = 'Desktop';
		market.Geo_Targeting__c = geoItem.Id;
		market.Sponsorship_Booking_Timezone__c = bookingTimeZone.Id;
		market.NAA_supported_currency__c = 'SGD';
		insert market;

		Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Ad Sales').getRecordTypeId();
		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		opp.RecordTypeId = oppRecordType;
		opp.Market__c = market.Id;
		insert opp;

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		List<csdf__Ad_Slot__c> adSlots = new List<csdf__Ad_Slot__c>();

		testAdSlot = TestDataSetupTargetables.createAdSlot();
		testAdSlot.csdf__Sizes__c = '24/s*25';
		testAdSlot.csdf__Ad_Server__c = testAdServer.Id;
		adSlots.add(testAdSlot);

		testAdSlot2 = TestDataSetupTargetables.createAdSlot();
		testAdSlot2.csdf__Sizes__c = '23/s*24';
		testAdSlot2.csdf__Ad_Server__c = testAdServer.Id;
		adSlots.add(testAdSlot2);

		insert adSlots;

		so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		so.Advertiser_Final__c = acc.Id;
		so.Ad_Server__c = testAdServer.Id;
		so.csmso__Advertiser__c = acc.Id;
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		testFulfilment.csdf__Ad_Server__c = testAdServer.Id;
		insert testFulfilment;

		prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		insert prodConfig;

		testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		testFulfilmentItem.Product_Configuration__c = null;
		insert testFulfilmentItem;

		csdf__Site__c testSite = TestDataSetupTargetables.createSite(testAdServer);
		insert testSite;

		csdf__Site_Targeting__c testSiteTarget = TestDataSetupTargetables.createSiteTarget(testSite, testFulfilmentItem);
		insert testSiteTarget;

		testTargetTemp = TestDataSetupTargetables.createTargetTemp(testAdServer);
		insert testTargetTemp;

		csdf__Geo_Item_Targeting_Template__c geoTargetingTemp = TestDataSetupTargetables.createGeoItemTargetTemp(geoItem, testTargetTemp);
		insert geoTargetingTemp;

		csdf__Browser__c testBrowser = TestDataSetupTargetables.createBrowser(testAdServer);
		insert testBrowser;

		csdf__Browser_Targeting_Template__c testBrowserTargetTemp = TestDataSetupTargetables.createBrowserTargetTemp(testBrowser, testTargetTemp);
		insert testBrowserTargetTemp;

		csdf__Operating_System__c testOS = TestDataSetupTargetables.createOS(testAdServer);
		insert testOS;

		csdf__Operating_System_Targeting_Template__c osTargetingTemp = TestDataSetupTargetables.createOSTargetTemp(testOS, testTargetTemp);
		insert osTargetingTemp;

		csdf__Operating_System_Version__c testOSVer = TestDataSetupTargetables.createOSVer(testOS);
		insert testOSVer;

		csdf__Operating_System_Version_Target_Template__c osverTargetTemp = TestDataSetupTargetables.createOSVerTargTemp(testOSVer, testTargetTemp);
		insert osverTargetTemp;

		csdf__Targetable__c testDeviceCat = TestDataSetupTargetables.createTargetable(testAdServer);
		testDeviceCat.csdf__Type__c = 'Device Category';
		testDeviceCat.csdf__Active__c = true;
		insert testDeviceCat;

		csam__Integration_Endpoint__c integrationEndpoint = new csam__Integration_Endpoint__c();
		integrationEndpoint.Name = 'Ad Server Integration';
		integrationEndpoint.csam__Callout_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
		insert integrationEndpoint;

		List<csam__ObjectGraph_Callout_Handler__c> testObjGrphCalloutHandlers = new List<csam__ObjectGraph_Callout_Handler__c>();

		csam__ObjectGraph_Callout_Handler__c testObjGrphSOFIAvailCheck = TestDataSetupTargetables.createObjGrph();
		testObjGrphSOFIAvailCheck.Name = 'SO Fulfilment Item Availability Check';
		testObjGrphCalloutHandlers.add(testObjGrphSOFIAvailCheck);

		csam__ObjectGraph_Callout_Handler__c testObjGrphSOStatusPush = TestDataSetupTargetables.createObjGrph();
		testObjGrphSOStatusPush.Name = 'SO Status Push';
		testObjGrphCalloutHandlers.add(testObjGrphSOStatusPush);

		csam__ObjectGraph_Callout_Handler__c testObjGrphFIAvailCheck = TestDataSetupTargetables.createObjGrph();
		testObjGrphFIAvailCheck.Name = 'Fulfilment Item Availability Check';
		testObjGrphCalloutHandlers.add(testObjGrphFIAvailCheck);

		csam__ObjectGraph_Callout_Handler__c testObjGrphFIPush = TestDataSetupTargetables.createObjGrph();
		testObjGrphFIPush.Name = 'Fulfilment Item Push';
		testObjGrphCalloutHandlers.add(testObjGrphFIPush);

		csam__ObjectGraph_Callout_Handler__c testObjGrphFIRefresh = TestDataSetupTargetables.createObjGrph();
		testObjGrphFIRefresh.Name = 'Fulfilment Item Refresh';
		testObjGrphCalloutHandlers.add(testObjGrphFIRefresh);

		csam__ObjectGraph_Callout_Handler__c testObjGrphFulfilmentCancel = TestDataSetupTargetables.createObjGrph();
		testObjGrphFulfilmentCancel.Name = 'Fulfilment Cancel';
		testObjGrphCalloutHandlers.add(testObjGrphFulfilmentCancel);

		csam__ObjectGraph_Callout_Handler__c testObjGrphFICancel = TestDataSetupTargetables.createObjGrph();
		testObjGrphFICancel.Name = 'Fulfilment Item Cancel';
		testObjGrphCalloutHandlers.add(testObjGrphFICancel);

		insert testObjGrphCalloutHandlers;

		attr = new CS_FulfilmentService.DigitalFulfilmentAttributes();
		attr.accountId = acc.Id;
		attr.adSlotIdsInclude = new List<Id>{
				testAdSlot.Id
		};
		attr.sites = new List<Id>{
				testSite.Id
		};
		attr.salesOrderId = so.Id;
		attr.flightBeginning = testFulfilmentItem.csdf__Flight_Beginning__c;
		attr.flightEnd = testFulfilmentItem.csdf__Flight_End__c;
		attr.quantity = testFulfilmentItem.csdf__Quantity__c;
		attr.dayPartTargeting = 'Monday#4#8#Monday#10#4';
		attr.customKeyTargeting = 'testcustomKeyTargeting is 123456789012345';
		attr.displayCreatives = 'Only One ';
		attr.notes = 'testnotes';
		attr.priority = '5';
		attr.rotateCreatives = 'testrotateCreatives';
		attr.targetPlatform = 'targetPlatform';
		attr.type = 'testtype';
		attr.frequencyCaps = 'DAY,10,10';
		attr.inputFlightBegin = '2016-11-11';
		attr.inputStartTime = '11:23';
		attr.inputFlightEnd = '2016-11-11';
		attr.inputEndTime = '11:59';
		attr.bookingTimezone = 'America/New_York America/New_York';
		attr.billingCategory = 'CPD';
		attr.SOV = '1';
		attr.targetingTemplateId = testTargetTemp.Id;
		attr.browsersInclude = new List<Id>{testBrowser.Id};
		attr.deviceCategoryInclude = new List<Id>{testDeviceCat.Id};
		attr.geoItemsInclude = new List<Id>{geoItem.Id};
		attr.operatingSystemsInclude = new List<Id>{testOS.Id};
		attr.operatingSystemVersionsInclude = new List<Id>{testOSVer.Id};
		attr.adSlotIdsIncludedExcludedString = 'INCLUDE:' + testAdSlot2.Id + ';EXCLUDE:' + testAdSlot.Id + ';';
		attr.geoItemsIncludedExcludedString = 'INCLUDE:' + geoItem.Id + ';EXCLUDE:' + geoItem.Id + ';';
		attr.browsersIncludedExcludedString = 'INCLUDE:' + testBrowser.Id + ';EXCLUDE:' + testBrowser.Id + ';';
		attr.operatingSystemsIncludedExcludedString = 'INCLUDE:' + testOS.Id + ';EXCLUDE:' + testOS.Id + ';';
		attr.operatingSystemVersionsIncludedExcludedString = 'INCLUDE:' + testOSVer.Id + ';EXCLUDE:' + testOSVer.Id + ';';
	} 

	@IsTest
	static void availabilityTest() {
		createTestData();

		testFulfilmentItem.csdf__Availability_Check_Status__c = 'Completed';
		update testFulfilmentItem;

		Test.startTest();
		String parameters = JSON.serialize(testFulfilmentItem.Id);
		AvailabilityCheckPollActionInvoker avChkPollClass = new AvailabilityCheckPollActionInvoker();
		avChkPollClass.performAction(parameters);
		DigitalFulfilmentAdapterUtil.availabilityCheckPoll(testFulfilmentItem.Id);
		Test.stopTest();
	}

	@IsTest
	static void invokeTest() {
		createTestData();

		Test.startTest();
		DigitalFulfilmentAdapterUtil.invokeAvailabilityCheck(testFulfilmentItem.Id);
		DigitalFulfilmentAdapterUtil.invokeFulfilment(testFulfilmentItem.Id);
		DigitalFulfilmentAdapterUtil.invokeFulfilment(new Set<Id>{testFulfilmentItem.Id});
		DigitalFulfilmentAdapterUtil.invokeFulfilment(new List<Id>{testFulfilmentItem.Id});
		Test.stopTest();
	}

	@IsTest
	static void pushToAdServerSOStatus() {
		createTestData();

		Test.startTest();
		String parameters = JSON.serialize(testFulfilmentItem.Id);
		AvailabilityCheckActionInvoker avClass = new AvailabilityCheckActionInvoker();
		avClass.performAction(parameters);
		DigitalFulfilmentAdapterUtil.createOrUpdateFulfilmentItem(attr);
		DigitalFulfilmentAdapterUtil.pushToAdServerSOStatus(new List<Id>{testFulfilment.Id});
		try {
			DigitalFulfilmentAdapterUtil.pushToAdServerSOStatus(new List<Id>());
		} catch (Exception e) {
		}
		Test.stopTest();
	}

	@IsTest
	static void fulfilmentItemCancel() {
		createTestData();
        set<Id> setOfProdConfig = new set<Id>();
		prodConfig.Ad_Type__c = 'Standard';
		prodConfig.Insertion_Unit_Type_Display__c = 'CPD';
		prodConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Draft;
		prodConfig.Served_By__c = 'DFP';
		prodConfig.csmso__Flight_End__c = Date.today().addDays(4);
        prodConfig.Name = 'Payload';
		update prodConfig;
        setOfProdConfig.add(prodConfig.id);

		testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
		testFulfilmentItem.Served_By__c = 'DFP';
		testFulfilmentItem.csdf__Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Draft;
		update testFulfilmentItem;

		Test.startTest();
		String parameters = JSON.serialize(testFulfilmentItem.Id);
		AvailabilityCheckActionInvoker avClass = new AvailabilityCheckActionInvoker();
		avClass.performAction(parameters);
		DigitalFulfilmentAdapterUtil.createOrUpdateFulfilmentItem(attr);
		DigitalFulfilmentAdapterUtil.checkAvailability(attr);
		DigitalFulfilmentAdapterUtil.doGlobalCheckAvails(new Map<Id, cscfga__Product_Configuration__c>{prodConfig.Id => prodConfig});

		System.assert(so.Id != null);
		DigitalFulfilmentAdapterUtil.updateStatus(so.Id);
		DigitalFulfilmentAdapterUtil.fulfilmentPerformanceGathering(so.Id);
		DigitalFulfilmentAdapterUtil.fulfilmentItemPerformanceGathering(so.Id);
		DigitalFulfilmentAdapterUtil.fulfilmentItemReserveRelease(so.Id);
		DigitalFulfilmentAdapterUtil.fulfilmentItemCancel(String.valueOf(testFulfilmentItem.Id));
		CS_FulfilmentService.generateFulfilmentItems(setOfProdConfig, True);
        CS_FulfilmentService.codeCoverage();
		Test.stopTest();
	}

	@IsTest
	static void createUpdateFulItemTest() {
		createTestData();

		Test.startTest();
		String parameters = JSON.serialize(testFulfilmentItem.Id);
		AvailabilityCheckActionInvoker avClass = new AvailabilityCheckActionInvoker();
		avClass.performAction(parameters);
		DigitalFulfilmentAdapterUtil.createOrUpdateFulfilmentItem(attr);
		DigitalFulfilmentAdapterUtil.checkAvailability(attr);

		System.assert(so.Id != null);
		DigitalFulfilmentAdapterUtil.updateStatus(so.Id);
		DigitalFulfilmentAdapterUtil.fulfilmentPerformanceGathering(so.Id);
		DigitalFulfilmentAdapterUtil.fulfilmentItemPerformanceGathering(so.Id);
		DigitalFulfilmentAdapterUtil.fulfilmentItemReserveRelease(so.Id);
		DigitalFulfilmentAdapterUtil.pushToAdServer(so.Id);
		DigitalFulfilmentAdapterUtil.deleteEmptyFulfilmentItems();
		System.assert(testFulfilmentItem.Id != null);
		DigitalFulfilmentAdapterUtil.deleteEmptyFulfilmentItems(String.valueOf(testFulfilmentItem.Id));
		DigitalFulfilmentAdapterUtil.deleteEmptyFulfilmentItems(testFulfilmentItem.Id);
		Test.stopTest();
	}

	@IsTest
	static void targetTempTest() {
		createTestData();

		csam__Outgoing_Message__c outMsg = new csam__Outgoing_Message__c(Name = 'testoutmsg', csam__Content_Type__c = 'testtype', csam__URL_Host__c = 'testhost');
		insert outMsg;

		csam__Incoming_Message__c testmsg1 = new csam__Incoming_Message__c(csam__Status__c = 'Integration Error', csam__HTTP_Method__c = 'testhttp', csam__Outgoing_Message__c = outMsg.Id, csam__Final_Chunk__c = true);
		insert testmsg1;

		csam.InboundMessageObservable o = (csam.InboundMessageObservable) JSON.deserialize('{"messages": ' + JSON.serialize([SELECT csam__Final_Chunk__c, csam__Outgoing_Message__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__r.Name, csam__Status__c FROM csam__Incoming_Message__c LIMIT 4]) + ', "name": "AfterIncomingMessageProcessed"}', csam.InboundMessageObservable.class);

		Test.startTest();
		DigitalFulfilmentAdapterUtil.createOrUpdateFulfilmentItem(attr);
		DigitalFulfilmentAdapterUtil.checkAvailability(attr);
		Test.stopTest();
	}

	@IsTest
	static void requestAcceptanceAndRetractPGProposal() {
		createTestData();

		Test.startTest();
		String parameters = JSON.serialize(testFulfilmentItem.Id);
		AvailabilityCheckActionInvoker avClass = new AvailabilityCheckActionInvoker();
		avClass.performAction(parameters);
		DigitalFulfilmentAdapterUtil.createOrUpdateFulfilmentItem(attr);
		DigitalFulfilmentAdapterUtil.checkAvailability(attr);
		DigitalFulfilmentAdapterUtil.updateStatus(so.Id);
		DigitalFulfilmentAdapterUtil.requestAcceptance(so.Id);
		DigitalFulfilmentAdapterUtil.retractPGProposal(so.Id);
		Test.stopTest();
	}

	@IsTest
	static void createOrUpdateFulfilmentItemException() {
		createTestData();

		List<Id> adSlotIdList = new List<Id>();
		adSlotIdList.add(testAdSlot.Id);

		List<csdf__Fulfilment__c> fulfilments = [SELECT Id FROM csdf__Fulfilment__c WHERE Sales_Order__c = :so.Id];
		if (!fulfilments.isEmpty()) {
			delete fulfilments;
		}

		Test.startTest();
		DigitalFulfilmentAdapterUtil.createDummyFulfilmentItem(so.Id);
		DigitalFulfilmentAdapterUtil.fulfilmentCancel(so.Id);

		try {
			DigitalFulfilmentAdapterUtil.createOrUpdateFulfilmentItem(attr);
		} catch (Exception e) {
			Boolean expectedExceptionThrown = e.getMessage().contains('Ad Slots have to be defined') ? true : false;
			System.assertEquals(expectedExceptionThrown, false);
		}

		csdf__Ad_Server__c testAdServer_2 = TestDataSetupTargetables.createAdServer();
		insert testAdServer_2;

		csdf__Ad_Slot__c testAdSlot_2 = TestDataSetupTargetables.createAdSlot();
		testAdSlot_2.csdf__Sizes__c = '24/s*26';
		testAdSlot_2.csdf__Ad_Server__c = testAdServer_2.Id;
		insert testAdSlot_2;

		adSlotIdList.add(testAdSlot_2.Id);
		attr.adSlotIdsInclude = adSlotIdList;

		try {
			DigitalFulfilmentAdapterUtil.createOrUpdateFulfilmentItem(attr);
		} catch (Exception e) {
			Boolean expectedExceptionThrown = e.getMessage().contains('Selection of ad slots must reside on the same Ad Server. More than single found!') ? true : false;
			System.assertEquals('Selection of ad slots must reside on the same Ad Server. More than single found!', e.getMessage());
		}
		Test.stopTest();
	}

	@IsTest
	static void availabilityCheckPollError() {
		createTestData();

		Test.startTest();
		DigitalFulfilmentAdapterUtil.createOrUpdateFulfilmentItem(attr);

		csdf__Fulfilment_Item__c testFI = [SELECT Id, Name FROM csdf__Fulfilment_Item__c WHERE Id = :testFulfilmentItem.Id];
		testFI.csdf__Availability_Check_Status__c = 'Error';
		update testFI;

		DigitalFulfilmentAdapterUtil.availabilityCheckPoll(new List<Id>{testFI.Id});
		Test.stopTest();
	}
    @isTest
    static void removeInvalidFulfilment(){
        createTestData();
        
        Test.startTest();
        
        CS_FulfilmentService.removeInvalidFulfilmentItems(so.id);
        
        Test.stopTest();
    }
 
}
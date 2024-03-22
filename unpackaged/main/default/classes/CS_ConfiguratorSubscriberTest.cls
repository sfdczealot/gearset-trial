/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description : Test Class for CS_ConfiguratorSubscriber
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author     : Kalyan Erraguntla <kalyan.erraguntla@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

@IsTest
public class CS_ConfiguratorSubscriberTest {

	/**
	  *  do_soliRollup
	  */
	@IsTest
	public static void test_do_soliRollupWithoutUpsert() {
		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opp.Id;
		salesOrder.isTestRunning__c = true;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
		salesOrder.Primary_Sales_Order__c = false;
		salesOrder.csmso__Advertiser__c = acc.Id;
		salesOrder.Advertiser_Final__c = acc.Id;
		insert salesOrder;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
		insert prodBasket;

		Set<Id> basketIds = new Set<Id>();
		basketIds.add(prodBasket.Id);

		Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Sales_Order__c = salesOrder.Id;
		prodConfig.IO_Volume_Discount_Range_1__c = 10;
		prodConfig.Revenue_Schedule_Rule__c = rScheduleRule.Id;
		prodConfig.FLAG_Running_in_MLE__c = true;
		insert prodConfig;

		cscfga__Configuration_Screen__c screenFlow = TestDataSetupTargetables.createConfigurationScreen(testProDef, 'Default Screen');
		insert screenFlow;

		cscfga__Attribute_Definition__c testAttrDef1 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef1.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef1.cscfga__Column__c = 0;
		testAttrDef1.cscfga__Row__c = 0;
		testAttrDef1.Name = 'Price';

		cscfga__Attribute_Definition__c testAttrDef2 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef2.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef2.cscfga__Column__c = 0;
		testAttrDef2.cscfga__Row__c = 1;
		testAttrDef2.cscfga__Data_Type__c = 'Integer';
		testAttrDef2.Name = 'Insertion Quantity';
		testAttrDef2.cscfga__configuration_output_mapping__c = 'Insertion_Quantity__c';

		cscfga__Attribute_Definition__c testAttrDef3 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef3.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef3.cscfga__Column__c = 1;
		testAttrDef3.cscfga__Row__c = 0;
		testAttrDef3.cscfga__Data_Type__c = 'Boolean';
		testAttrDef3.Name = 'FLAG Running in MLE';

		cscfga__Attribute_Definition__c testAttrDef4 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef4.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef4.cscfga__Column__c = 1;
		testAttrDef4.cscfga__Row__c = 0;
		testAttrDef4.cscfga__Data_Type__c = 'String';
		testAttrDef4.Name = 'Flighting Status';

		cscfga__Attribute_Definition__c testAttrDef5 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef5.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef5.cscfga__Column__c = 1;
		testAttrDef5.cscfga__Row__c = 0;
		testAttrDef5.cscfga__Data_Type__c = 'String';
		testAttrDef5.Name = 'Payload';

		cscfga__Attribute_Definition__c testAttrDef6 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef6.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef6.cscfga__Column__c = 1;
		testAttrDef6.cscfga__Row__c = 0;
		testAttrDef6.cscfga__Data_Type__c = 'String';
		testAttrDef6.Name = 'Flight Begin Date Time Selected';

		cscfga__Attribute_Definition__c testAttrDef7 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef7.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef7.cscfga__Column__c = 1;
		testAttrDef7.cscfga__Row__c = 0;
		testAttrDef7.cscfga__Data_Type__c = 'String';
		testAttrDef7.Name = 'Flight End Date Time Selected';

		cscfga__Attribute_Definition__c testAttrDef8 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef8.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef8.cscfga__Column__c = 1;
		testAttrDef8.cscfga__Row__c = 0;
		testAttrDef8.cscfga__Data_Type__c = 'String';
		testAttrDef8.Name = 'Flight Begin Date Time';

		cscfga__Attribute_Definition__c testAttrDef9 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef9.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef9.cscfga__Column__c = 1;
		testAttrDef9.cscfga__Row__c = 0;
		testAttrDef9.cscfga__Data_Type__c = 'String';
		testAttrDef9.Name = 'Flight End Date Time';

		cscfga__Attribute_Definition__c testAttrDef10 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef10.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef10.cscfga__Column__c = 1;
		testAttrDef10.cscfga__Row__c = 0;
		testAttrDef10.cscfga__Data_Type__c = 'String';
		testAttrDef10.Name = 'Served By';

		cscfga__Attribute_Definition__c testAttrDef11 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef11.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef11.cscfga__Column__c = 1;
		testAttrDef11.cscfga__Row__c = 0;
		testAttrDef11.cscfga__Data_Type__c = 'String';
		testAttrDef11.Name = 'FLAG Run On Open';

		cscfga__Attribute_Definition__c testAttrDef12 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef12.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef12.cscfga__Column__c = 1;
		testAttrDef12.cscfga__Row__c = 0;
		testAttrDef12.cscfga__Data_Type__c = 'String';
		testAttrDef12.Name = 'Current Targetings';

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(salesOrder, acc);
		testFulfilment.csdf__Ad_Server__c = testAdServer.Id;
		insert testFulfilment;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, salesOrder, testFulfilment);
		testFulfilmentItem.Product_Configuration__c = null;
		insert testFulfilmentItem;

		csdf__Site__c testSite = TestDataSetupTargetables.createSite(testAdServer);
		insert testSite;

		csdf__Site_Targeting__c testSiteTarget = TestDataSetupTargetables.createSiteTarget(testSite, testFulfilmentItem);
		insert testSiteTarget;

		csdf__Ad_Slot__c testAdSlot = TestDataSetupTargetables.createAdSlot();
		testAdSlot.csdf__Sizes__c = '24/s*25';
		testAdSlot.csdf__Ad_Server__c = testAdServer.Id;
		insert testAdSlot;

		List<Id> adSlotIdList = new List<Id>();
		List<Id> siteList = new List<Id>();

		adSlotIdList.add(testAdSlot.Id);
		siteList.add(testSite.Id);

		CS_FulfilmentService.DigitalFulfilmentAttributes attr = new CS_FulfilmentService.DigitalFulfilmentAttributes();
		//attr.fulfilmentItemId = testFulfilmentItem.Id;
		attr.accountId = acc.Id;
		attr.adSlotIdsInclude = adSlotIdList;
		attr.sites = siteList;
		attr.salesOrderId = salesOrder.Id;
		attr.flightBeginning = testFulfilmentItem.csdf__Flight_Beginning__c;
		attr.flightEnd = testFulfilmentItem.csdf__Flight_End__c;
		attr.quantity = testFulfilmentItem.csdf__Quantity__c;
		attr.dayPartTargeting = 'Monday#0#24#Tuesday#2#24#Wednesday#2#24#Thursday#1#24#Friday#1#4#Friday#5#24#Saturday#0#2#Saturday#3#24#Sunday#0#24';
		attr.customKeyTargeting = '#209218 is #64602340258 AND #208978 is #180410279338 AND #11699833 is #447952429713';
		attr.displayCreatives = 'Only One';
		attr.notes = 'testnotes';
		attr.priority = '5';
		attr.rotateCreatives = 'Weight';
		attr.targetPlatform = 'Web';
		attr.type = 'Billing Category';
		attr.frequencyCaps = 'DAY,10,10';
		attr.inputFlightBegin = '2016-11-11';
		attr.inputStartTime = '11:23';
		attr.inputFlightEnd = '2016-11-11';
		attr.inputEndTime = '11:59';
		attr.bookingTimezone = 'GMT';
		attr.billingCategory = 'CPM';
		attr.itemName = 'Test FI';

		List<cscfga__Attribute__c> attributesToPayload = new List<cscfga__Attribute__c>();
		cscfga__Attribute__c attQty = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Insertion Quantity', cscfga__Value__c = '10000', cscfga__Attribute_Definition__c = testAttrDef2.Id);
		cscfga__Attribute__c attPrice = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Price', cscfga__Value__c = '250', cscfga__Attribute_Definition__c = testAttrDef1.Id);
		cscfga__Attribute__c attFlagMLE = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'FLAG Running in MLE', cscfga__Value__c = 'Yes', cscfga__Attribute_Definition__c = testAttrDef3.Id);
		cscfga__Attribute__c attFlightingStatus = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'From Flighting', cscfga__Value__c = 'From Flighting', cscfga__Attribute_Definition__c = testAttrDef4.Id);
		cscfga__Attribute__c attPayload = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Payload', cscfga__Value__c = JSON.serialize(attr), cscfga__Attribute_Definition__c = testAttrDef5.Id);
		cscfga__Attribute__c attFlightBeginDateTimeSelected = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Flight Begin Date Time Selected', cscfga__Value__c = '2020-01-02 00:00 America/New_York', cscfga__Attribute_Definition__c = testAttrDef6.Id);
		cscfga__Attribute__c attFlightEndDateTimeSelected = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Flight End Date Time Selected', cscfga__Value__c = '2020-01-03 23:59 America/New_York', cscfga__Attribute_Definition__c = testAttrDef7.Id);
		cscfga__Attribute__c attFlightBeginDateTime = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Flight Begin Date Time', cscfga__Value__c = '2020-01-02 00:00', cscfga__Attribute_Definition__c = testAttrDef8.Id);
		cscfga__Attribute__c attFlightEndDateTime = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Flight End Date Time', cscfga__Value__c = '2020-01-03 23:59', cscfga__Attribute_Definition__c = testAttrDef9.Id);
		cscfga__Attribute__c attServedBy = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Served By', cscfga__Value__c = 'Megaphone', cscfga__Attribute_Definition__c = testAttrDef10.Id);
		cscfga__Attribute__c attFlagRunOnOpen = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'FLAG Run On Open', cscfga__Value__c = '', cscfga__Attribute_Definition__c = testAttrDef11.Id);
		cscfga__Attribute__c attCurrentTargetings = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Current Targetings', cscfga__Value__c = '', cscfga__Attribute_Definition__c = testAttrDef12.Id);


		attributesToPayload.add(attQty);
		attributesToPayload.add(attPrice);
		attributesToPayload.add(attFlagMLE);
		attributesToPayload.add(attFlightingStatus);
		attributesToPayload.add(attPayload);
		attributesToPayload.add(attFlightBeginDateTimeSelected);
		attributesToPayload.add(attFlightEndDateTimeSelected);
		attributesToPayload.add(attFlightBeginDateTime);
		attributesToPayload.add(attFlightEndDateTime);
		attributesToPayload.add(attServedBy);
		attributesToPayload.add(attFlagRunOnOpen);
		attributesToPayload.add(attCurrentTargetings);
		insert attributesToPayload;

		attributesToPayload = [SELECT Id, cscfga__Product_Configuration__c, Name, cscfga__Value__c, cscfga__Attribute_Definition__c FROM cscfga__Attribute__c];
		prodConfig = [SELECT Id, cscfga__Product_Family__c FROM cscfga__Product_Configuration__c LIMIT 1];

		List<cscfga__Product_Configuration__c> prodConfigs = new List<cscfga__Product_Configuration__c>();
		prodConfigs.add(prodConfig);

		Map<Id, csmso__Sales_Order__c> salesOrders = new Map<Id, csmso__Sales_Order__c>();
		salesOrders.put(salesOrder.Id, salesOrder);

		Map<Id, List<cscfga__Product_Configuration__c>> productConfigurations = new Map<Id, List<cscfga__Product_Configuration__c>> ();
		productConfigurations.put(salesOrder.Id, prodConfigs);

		Map<String, Object> payload = new Map<String, Object> ();
		payload.put('Container', prodBasket);
		payload.put('AllConfigs', prodConfigs);
		payload.put('AllAttrs', attributesToPayload);

		Test.startTest();
		CS_ConfiguratorSubscriber cs = new CS_ConfiguratorSubscriber();

		//Map<String, Set<Id>> configToFulfilmentItem2 = CS_ConfiguratorSubscriber.configToFulfilmentItem;
		//cs.do_soliRollup(salesOrders,productConfigurations);

		csmso__Sales_Order__c so = new csmso__Sales_Order__c();
		so = [
				SELECT Id,
						SO_Lines_Number_of_lines__c,
						SO_Lines_Ad_Server_Items__c,
						SO_Lines_All_Valid__c,
						SO_Lines_Ad_Server_Inventory_Avail_Ov__c
				FROM csmso__Sales_Order__c
				WHERE Id = :salesOrder.Id
		];

		cs.onMessage('Topic', 'AfterSaveV2', payload);
		cs.onMessage('Topic', 'BeforeSaveV2', payload);
		cs.onMessage('Topic', 'Deleted', payload);
		System.assertEquals(so.SO_Lines_All_Valid__c, true);
		System.assertEquals(cs.getSalesOrders(basketIds).size(), 1);
		Test.stopTest();
	}

	/**
	 *  do_soliRollup
	 */
	@IsTest
	public static void test_do_soliRollupWithUpsert() {
		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opp.Id;
		salesOrder.isTestRunning__c = true;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
		salesOrder.Primary_Sales_Order__c = false;
		salesOrder.csmso__Advertiser__c = acc.Id;
		salesOrder.Advertiser_Final__c = acc.Id;
		insert salesOrder;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
		insert prodBasket;

		Set<Id> basketIds = new Set<Id>();
		basketIds.add(prodBasket.Id);

		Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Sales_Order__c = salesOrder.Id;
		prodConfig.IO_Volume_Discount_Range_1__c = 10;
		prodConfig.Revenue_Schedule_Rule__c = rScheduleRule.Id;
		prodConfig.cscfga__Key__c = 'Test123';
		insert prodConfig;

		cscfga__Configuration_Screen__c screenFlow = TestDataSetupTargetables.createConfigurationScreen(testProDef, 'Default Screen');
		insert screenFlow;

		cscfga__Attribute_Definition__c testAttrDef1 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef1.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef1.cscfga__Column__c = 0;
		testAttrDef1.cscfga__Row__c = 0;
		testAttrDef1.Name = 'Price';

		cscfga__Attribute_Definition__c testAttrDef2 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef2.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef2.cscfga__Column__c = 0;
		testAttrDef2.cscfga__Row__c = 1;
		testAttrDef2.cscfga__Data_Type__c = 'Integer';
		testAttrDef2.Name = 'Insertion Quantity';
		testAttrDef2.cscfga__configuration_output_mapping__c = 'Insertion_Quantity__c';

		cscfga__Attribute_Definition__c testAttrDef3 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef3.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef3.cscfga__Column__c = 1;
		testAttrDef3.cscfga__Row__c = 0;
		testAttrDef3.cscfga__Data_Type__c = 'String';
		testAttrDef3.Name = 'Payload';

		cscfga__Attribute_Definition__c testAttrDef4 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef4.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef4.cscfga__Column__c = 1;
		testAttrDef4.cscfga__Row__c = 1;
		testAttrDef4.cscfga__Data_Type__c = 'String';
		testAttrDef4.Name = 'Fulfilment Item';

		cscfga__Attribute_Definition__c testAttrDef5 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef5.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef5.cscfga__Column__c = 2;
		testAttrDef5.cscfga__Row__c = 0;
		testAttrDef5.cscfga__Data_Type__c = 'String';
		testAttrDef5.Name = 'Line ID';

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(salesOrder, acc);
		testFulfilment.csdf__Ad_Server__c = testAdServer.Id;
		insert testFulfilment;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, salesOrder, testFulfilment);
		testFulfilmentItem.Product_Configuration__c = null;
		insert testFulfilmentItem;

		testFulfilmentItem = [SELECT Id, csdf__Flight_Beginning__c, csdf__Flight_End__c, csdf__Quantity__c FROM csdf__Fulfilment_Item__c WHERE Id = :testFulfilmentItem.Id];

		csdf__Site__c testSite = TestDataSetupTargetables.createSite(testAdServer);
		insert testSite;

		csdf__Site_Targeting__c testSiteTarget = TestDataSetupTargetables.createSiteTarget(testSite, testFulfilmentItem);
		insert testSiteTarget;

		csdf__Ad_Slot__c testAdSlot = TestDataSetupTargetables.createAdSlot();
		testAdSlot.csdf__Sizes__c = '24/s*25';
		testAdSlot.csdf__Ad_Server__c = testAdServer.Id;
		insert testAdSlot;

		List<Id> adSlotIdList = new List<Id>();
		List<Id> siteList = new List<Id>();

		adSlotIdList.add(testAdSlot.Id);
		siteList.add(testSite.Id);

		CS_FulfilmentService.DigitalFulfilmentAttributes attr = new CS_FulfilmentService.DigitalFulfilmentAttributes();
		//attr.fulfilmentItemId = testFulfilmentItem.Id;
		attr.accountId = acc.Id;
		attr.adSlotIdsInclude = adSlotIdList;
		attr.sites = siteList;
		attr.salesOrderId = salesOrder.Id;
		attr.flightBeginning = testFulfilmentItem.csdf__Flight_Beginning__c;
		attr.flightEnd = testFulfilmentItem.csdf__Flight_End__c;
		attr.quantity = testFulfilmentItem.csdf__Quantity__c;
		attr.dayPartTargeting = 'Monday#0#24#Tuesday#2#24#Wednesday#2#24#Thursday#1#24#Friday#1#4#Friday#5#24#Saturday#0#2#Saturday#3#24#Sunday#0#24';
		attr.customKeyTargeting = '#209218 is #64602340258 AND #208978 is #180410279338 AND #11699833 is #447952429713';
		attr.displayCreatives = 'Only One';
		attr.notes = 'testnotes';
		attr.priority = '5';
		attr.rotateCreatives = 'Weight';
		attr.targetPlatform = 'Web';
		attr.type = 'Billing Category';
		attr.frequencyCaps = 'DAY,10,10';
		attr.inputFlightBegin = '2016-11-11';
		attr.inputStartTime = '11:23';
		attr.inputFlightEnd = '2016-11-11';
		attr.inputEndTime = '11:59';
		attr.bookingTimezone = 'GMT';
		attr.billingCategory = 'CPM';
		attr.itemName = 'Test FI';

		/*
		csdf__Fulfilment_Item__c testFulfilmentItem = new csdf__Fulfilment_Item__c();
		testFulfilmentItem.csdf__Fulfilment__c = testFulfilment.id;
		testFulfilmentItem.csdf__Availability_Check_Total_Amount__c=1;
		*/

		List<cscfga__Attribute__c> attributesToPayload = new List<cscfga__Attribute__c>();
		cscfga__Attribute__c attQty = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Insertion Quantity', cscfga__Value__c = '10000', cscfga__Attribute_Definition__c = testAttrDef2.Id);
		cscfga__Attribute__c attPrice = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Price', cscfga__Value__c = '250', cscfga__Attribute_Definition__c = testAttrDef1.Id);
		cscfga__Attribute__c attPayload = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Payload', cscfga__Value__c = JSON.serialize(attr), cscfga__Attribute_Definition__c = testAttrDef3.Id);
		cscfga__Attribute__c attFulfilmentItem = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Fulfilment Item', cscfga__Value__c = JSON.serialize(testFulfilmentItem), cscfga__Attribute_Definition__c = testAttrDef4.Id);
		cscfga__Attribute__c attLineId = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Line ID', cscfga__Value__c = '0000001', cscfga__Attribute_Definition__c = testAttrDef5.Id);

		insert attLineId;
		cscfga__Attribute__c attLineIdQueried = new cscfga__Attribute__c();
		attLineIdQueried = [
				SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Value__c, cscfga__Attribute_Definition__c
				FROM cscfga__Attribute__c
				WHERE Id = :attLineId.Id
		];

		attributesToPayload.add(attQty);
		attributesToPayload.add(attPrice);
		attributesToPayload.add(attPayload);
		attributesToPayload.add(attFulfilmentItem);
		attributesToPayload.add(attLineIdQueried);

		List<cscfga__Product_Configuration__c> prodConfigs = new List<cscfga__Product_Configuration__c>();
		prodConfigs.add(prodConfig);

		Map<Id, csmso__Sales_Order__c> salesOrders = new Map<Id, csmso__Sales_Order__c>();
		salesOrders.put(salesOrder.Id, salesOrder);

		Map<Id, List<cscfga__Product_Configuration__c>> productConfigurations = new Map<Id, List<cscfga__Product_Configuration__c>> ();
		productConfigurations.put(salesOrder.Id, prodConfigs);

		Map<String, Object> payload = new Map<String, Object> ();
		payload.put('Container', prodBasket);
		payload.put('AllConfigs', prodConfigs);
		payload.put('AllAttrs', attributesToPayload);

		Test.startTest();
		CS_ConfiguratorSubscriber cs = new CS_ConfiguratorSubscriber();

		//Map<String, Set<Id>> configToFulfilmentItem2 = CS_ConfiguratorSubscriber.configToFulfilmentItem;
		//cs.do_soliRollup(salesOrders,productConfigurations);

		csmso__Sales_Order__c so = new csmso__Sales_Order__c();
		so = [
				SELECT Id,
						SO_Lines_Number_of_lines__c,
						SO_Lines_Ad_Server_Items__c,
						SO_Lines_All_Valid__c,
						SO_Lines_Ad_Server_Inventory_Avail_Ov__c
				FROM csmso__Sales_Order__c
				WHERE Id = :salesOrder.Id
		];

		cs.onMessage('Topic', 'AfterSaveV2', payload);
		cs.onMessage('Topic', 'BeforeSaveV2', payload);
		cs.onMessage('Topic', 'Deleted', payload);
		System.assertEquals(so.SO_Lines_All_Valid__c, true);
		System.assertEquals(cs.getSalesOrders(basketIds).size(), 1);
		Test.stopTest();
	}
}
@IsTest
public class CS_LineCalendarWidgetControllerTest {

	@IsTest
	public static void test_getMarkets() {
		Test.startTest();
		String result = CS_LineCalendarWidgetController.getMarkets('{"page": 1, "term": ""}');
		System.assert(String.isNotBlank(result));
        Test.stopTest();
	}

	@IsTest
	public static void test_getProducts() {
		Test.startTest();
		String result = CS_LineCalendarWidgetController.getProducts('{"page": 1, "term": ""}');
		System.assert(String.isNotBlank(result));
        Test.stopTest();
	}

	@IsTest
	public static void test_performAction() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();
		customSettings.Integration_Chunk_Size__c = 25;
		customSettings.Integration_Delay_Between_Callouts__c = 0;
		update customSettings;

		Account acc = TestDataSetupTargetables.createAccount();
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

		csdf__Ad_Slot__c testAdSlot = TestDataSetupTargetables.createAdSlot();
		testAdSlot.csdf__Sizes__c = '24/s*25';
		testAdSlot.csdf__Ad_Server__c = adServer.Id;
		insert testAdSlot;

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
		advertAssignment.Ad_Slot__c = 'INCLUDE:' + testAdSlot.Id + ';EXCLUDE:;';
		advertAssignment.Ad_Location_Description__c = 'Everywhere';
		advertAssignment.Ad_Server__c = adServer.Id;
		advertAssignment.Ad_Slot_Names__c = 'SPT_AD_Unit';
		advertAssignment.Invoice_GL_Code__c = '123456789';
		advertAssignment.Rev_Accrual_GL_Code__c = '123456789';
		advertAssignment.Priority__c = '6';
		insert advertAssignment;

		Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Ad Sales').getRecordTypeId();
		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		opp.RecordTypeId = oppRecordType;
		opp.Market__c = market.Id;
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		so.Advertiser_Final__c = acc.Id;
		so.Ad_Server__c = adServer.Id;
		insert so;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		testFulfilment.csdf__Ad_Server__c = adServer.Id;
		insert testFulfilment;

		Test.startTest();
		CS_LineCalendarWidgetController.SponsorshipCalendarAttributes attr = new CS_LineCalendarWidgetController.SponsorshipCalendarAttributes();
		attr.startDate = String.valueOf(Date.today());
		attr.endDate = String.valueOf(Date.today().addDays(1));
		attr.market = market.Id;
		attr.nodeAdvertAssignment = advertAssignment.Id;
		attr.salesOrderId = so.Id;

		String parameters = JSON.serialize(attr);
		String fulfilmentItemIds = CS_LineCalendarWidgetController.performAction(parameters);

		List<csdf__Fulfilment_Item__c> fiToUpdate = new List<csdf__Fulfilment_Item__c>();
		for (String fiId : (Set<Id>) JSON.deserialize(fulfilmentItemIds, Set<Id>.class)) {
			fiToUpdate.add(new csdf__Fulfilment_Item__c(Id = fiId, csdf__Availability_Check_Status__c = 'Completed'));
		}
		update fiToUpdate;

		CS_LineCalendarWidgetController.poll(fulfilmentItemIds);
		CS_LineCalendarWidgetController.deleteItems(fulfilmentItemIds);
		Test.stopTest();
	}
}
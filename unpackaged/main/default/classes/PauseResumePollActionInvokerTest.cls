@IsTest(SeeAllData=true)
public class PauseResumePollActionInvokerTest {

	@IsTest
    static void test_method_one() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());

		Account acc = TestDataSetupBasic.createAccount();
		acc.BillingCity = 'New York';
		acc.BillingCountry = 'United States';
		acc.BillingCountryCode = 'US';
		acc.BillingPostalCode = '10036-3982';
		acc.BillingState = 'New York';
		acc.BillingStateCode = 'NY';
		acc.BillingStreet = 'xxx';
		insert acc;

		Contact con = TestDataSetupBasic.createContact(acc);
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

		Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Ad Sales').getRecordTypeId();
		Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
		opp.RecordTypeId = oppRecordType;
		opp.Market__c = market.Id;
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Ad_Type__c = 'Standard';
		prodConfig.Fulfilment_Item_Status__c = 'Draft';
		prodConfig.Served_By__c = 'DFP';
		prodConfig.csmso__Flight_End__c = Date.today().addDays(4);
		insert prodConfig;

		Map<Id, cscfga__Product_Configuration__c> configs = new Map<Id, cscfga__Product_Configuration__c>();
		configs.put(prodConfig.Id, prodConfig);

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
		testFulfilmentItem.csdf__Availability_Check_Status__c = 'Completed';
		testFulfilmentItem.csdf__Pause_Resume_Message_Status__c = 'Completed';
		testFulfilmentItem.Served_By__c = 'DFP';
		insert testFulfilmentItem;

		Test.startTest();
		String parameters = JSON.serialize(testFulfilmentItem.Id);
		PauseResumePollActionInvoker avChkPollClass = new PauseResumePollActionInvoker();
		avChkPollClass.performAction(parameters);
		DigitalFulfilmentAdapterUtil.availabilityCheckPoll(testFulfilmentItem.Id);
		Test.stopTest();
	}

	@IsTest
	static void test_method_fail() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());

		Account acc = TestDataSetupBasic.createAccount();
		acc.BillingCity = 'New York';
		acc.BillingCountry = 'United States';
		acc.BillingCountryCode = 'US';
		acc.BillingPostalCode = '10036-3982';
		acc.BillingState = 'New York';
		acc.BillingStateCode = 'NY';
		acc.BillingStreet = 'xxx';
		insert acc;

		Contact con = TestDataSetupBasic.createContact(acc);
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

		Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Ad Sales').getRecordTypeId();
		Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
		opp.RecordTypeId = oppRecordType;
		opp.Market__c = market.Id;
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		insert prodConfig;

		Map<Id, cscfga__Product_Configuration__c> configs = new Map<Id, cscfga__Product_Configuration__c>();
		configs.put(prodConfig.Id, prodConfig);

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
		testFulfilmentItem.csdf__Availability_Check_Status__c = 'Completed';
		testFulfilmentItem.csdf__Pause_Resume_Message_Status__c = 'Completed';
		insert testFulfilmentItem;

		Test.startTest();
		String parameters = JSON.serialize(prodConfig.Id);
		PauseResumePollActionInvoker avChkPollClass = new PauseResumePollActionInvoker();
		avChkPollClass.performAction(parameters);
		Test.stopTest();
	}
}
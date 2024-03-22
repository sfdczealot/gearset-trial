/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class for CS_SPPremiumGroupChargesCalc
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@IsTest(SeeAllData=false)
public class CS_SPPremiumGroupChargesCalcTest {
	private static Map<String, String> searchFieldsMap = new Map<String, String>();
	private static String prodDefinitionID;

	private static void createTestData() {
		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		insert so;

		// create Business Unit (csmso__Business_Unit__c)
		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Test Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = 'Test Sales Ledger Code';
		businessUnit.Unique_Id__c = 'Test Unique Id Business Unit';
		insert businessUnit;

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

		// create Geo Item (csdf__Geo_Item__c)
		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'Test Geo Item';
		geoItem.csdf__Ad_Server__c = adServer.Id;
		geoItem.csdf__Ad_Server_Id__c = 'Test Ad Server Id';
		insert geoItem;

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

		// create Advert Assignment (csmso__Node_Advert_Assignment__c)
		csmso__Node_Advert_Assignment__c advertAssignment = new csmso__Node_Advert_Assignment__c();
		advertAssignment.Name = 'Test Market';
		advertAssignment.Product_Name__c = 'Test Product Name';
		advertAssignment.Rate_Type__c = 'CPM';
		advertAssignment.Rate_Type_Display__c = 'CPCV';
		advertAssignment.Line_Item_Type__c = 'Standard';
		advertAssignment.Inventory_sizes__c = '1000x1000';
		advertAssignment.Invoice_GL_Code__c = 'Test Invoice GL Code';
		advertAssignment.Rev_Accrual_GL_Code__c = 'Test Rev Accrual GL Code';
		advertAssignment.Unique_Id__c = 'someUniqueTestId';
		advertAssignment.Product_Category__c = 'Standard Products';
		advertAssignment.Product_Group__c = 'Audio';
		advertAssignment.Line_Item_Category__c = 'House';
		advertAssignment.Product_Family__c = 'Audio';
		advertAssignment.Served_by__c = 'DFP';
		advertAssignment.Ad_Slot__c = 'Test Ad Slot';
		advertAssignment.Ad_Slot_Names__c = 'Test Ad Slot Names';
		advertAssignment.Ad_Location_Description__c = 'Everywhere';
		advertAssignment.Ad_Server__c = adServer.Id;
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

		// create Rate Card Item Price (csmso__Rate_Card_Item_Price__c)
		csmso__Rate_Card_Item_Price__c rateCardItemPrice = new csmso__Rate_Card_Item_Price__c();
		rateCardItemPrice.csmso__Rate_Card__c = rateCard.Id;
		rateCardItemPrice.csmso__Advert_Assignment__c = advertAssignment.Id;
		rateCardItemPrice.Account_Tier__c = 'Tier 3';
		rateCardItemPrice.List_Floor__c = 'List';
		rateCardItemPrice.csmso__Product_Node__c = market.Id;
		rateCardItemPrice.CurrencyIsoCode = 'USD';
		rateCardItemPrice.Unique_Id__c = 'Test Unique Id Rate Card Item Price';
		rateCardItemPrice.csmso__Price_Per_Unit__c = 12;
		rateCardItemPrice.Minimum_Line_Value__c = 4;
		insert rateCardItemPrice;

		// create Premium Group (Premium_Group__c)
		Premium_Group__c premiumGroup = new Premium_Group__c();
		premiumGroup.Name = 'Test Premium Group';
		premiumGroup.CurrencyIsoCode = 'USD';
		premiumGroup.Premium_Group_Category__c = 'Test Category';
		premiumGroup.Premium_Group_Name__c = 'Test Premium Group Name';
		premiumGroup.Short_Description__c = 'Short Description';
		premiumGroup.Unique_Id__c = 'Test Unique Premium Group';
		insert premiumGroup;

		// create Premium Group Charge (Premium_Group_Charge__c)
		Premium_Group_Charge__c premiumGroupCharge = new Premium_Group_Charge__c();
		premiumGroupCharge.Premium_Percentage__c = 20;
		premiumGroupCharge.CurrencyIsoCode = 'USD';
		premiumGroupCharge.Rate_Card__c = rateCard.Id;
		premiumGroupCharge.Premium_Group__c = premiumGroup.Id;
		premiumGroupCharge.Unique_Id__c = 'Test Unique Id';
		insert premiumGroupCharge;

		searchFieldsMap.put('Rate Card Item Price Exchange', '12');
		searchFieldsMap.put('Premiums', premiumGroupCharge.Id);
	}

	@IsTest
	public static void dynamicSearchPremiumGroupChargesCompoundedCalcTest() {
		createTestData();

		searchFieldsMap.put('Rate Card Premium Type', 'Compounded');

		Test.startTest();
		CS_SPPremiumGroupChargesCalc lkp = new CS_SPPremiumGroupChargesCalc();
		lkp.getRequiredAttributes();
		Object[] result = lkp.doDynamicLookupSearch(searchFieldsMap, prodDefinitionID);
		Test.stopTest();

		System.assertNotEquals(null, result);
	}

	@IsTest
	public static void dynamicSearchPremiumGroupChargesAdditiveCalcTest() {
		createTestData();

		searchFieldsMap.put('Rate Card Premium Type', 'Additive');

		Test.startTest();
		CS_SPPremiumGroupChargesCalc lkp = new CS_SPPremiumGroupChargesCalc();
		lkp.getRequiredAttributes();
		Object[] result = lkp.doDynamicLookupSearch(searchFieldsMap, prodDefinitionID);
		Test.stopTest();

		System.assertNotEquals(null, result);
	}

	@IsTest
	public static void dynamicSearchPremiumGroupChargesFlatRateCompoundedCalcTest() {
		createTestData();

		searchFieldsMap.put('Rate Card Premium Type', 'Compounded');

		Premium_Group_Charge__c premiumGroupCharge = [SELECT Id, Premium_Percentage__c FROM Premium_Group_Charge__c LIMIT 1];
		premiumGroupCharge.Premium_Flat_Rate__c = 5;
		premiumGroupCharge.Premium_Percentage__c = null;
		update premiumGroupCharge;

		Test.startTest();
		CS_SPPremiumGroupChargesCalc lkp = new CS_SPPremiumGroupChargesCalc();
		lkp.getRequiredAttributes();
		Object[] result = lkp.doDynamicLookupSearch(searchFieldsMap, prodDefinitionID);
		Test.stopTest();

		System.assertNotEquals(null, result);
	}

	@IsTest
	public static void dynamicSearchPremiumGroupChargesFlatRateAdditiveCalcTest() {
		createTestData();

		searchFieldsMap.put('Rate Card Premium Type', 'Additive');

		Premium_Group_Charge__c premiumGroupCharge = [SELECT Id, Premium_Percentage__c FROM Premium_Group_Charge__c LIMIT 1];
		premiumGroupCharge.Premium_Flat_Rate__c = 5;
		premiumGroupCharge.Premium_Percentage__c = null;
		update premiumGroupCharge;

		Test.startTest();
		CS_SPPremiumGroupChargesCalc lkp = new CS_SPPremiumGroupChargesCalc();
		lkp.getRequiredAttributes();
		Object[] result = lkp.doDynamicLookupSearch(searchFieldsMap, prodDefinitionID);
		Test.stopTest();

		System.assertNotEquals(null, result);
	}
}
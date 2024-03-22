/**
  * @author       Ankur
  * @description  Test class for Implementation of method for customised lookup, filters NAA based on Market and RateCard
  * @date         2020-10-29
 */
@IsTest
private class SPProductNodeLookupChipperTest {

	@IsTest
	public static void test_productNodePerformAction() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;
		PGTestDataFactory_v2.CreateTriggerExecuteCS('Trigger_OpportunitySplit',false);
		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		Account acc = TestDataSetupTargetables.createAccount();
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        acc.RecordTypeId = accRectype ;
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.Subsidiary_Type__c = 'iPP';
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

		// create Business Unit (csmso__Business_Unit__c)
		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Test Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = 'Test Sales Ledger Code';
		businessUnit.Unique_Id__c = 'Test Unique Id Business Unit';
		insert businessUnit;

		// create geo targeting
		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'United States';
		geoItem.csdf__Ad_Server_Id__c = '2840';
		insert geoItem;

		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Europe/London';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
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
		market.Served_By__c = 'Ad Served';
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
		advertAssignment.Starting_Day__c = 'Monday';
		advertAssignment.Product_Info__c = 'test prod info';
		advertAssignment.SOV__c = 50;
		advertAssignment.Product_Info__c = market.Id;
		insert advertAssignment;

		// create Rate Card (csmso__Rate_Card__c)
		csmso__Rate_Card__c rateCard = new csmso__Rate_Card__c();
		rateCard.Short_Description__c = 'Test Short Description Rate Card';
		rateCard.Type__c = 'Base';
		rateCard.csmso__Product_Node__c = market.Id;
		rateCard.csmso__From_Date__c = Date.today().addDays(-30);
		rateCard.csmso__To_Date__c = Date.today().addDays(30);
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
		rateCardItemPrice.Account_Tier__c = 'Tier 1';
		rateCardItemPrice.List_Floor__c = 'List';
		rateCardItemPrice.csmso__Product_Node__c = market.Id;
        rateCardItemPrice.CurrencyIsoCode = 'USD';
        rateCardItemPrice.Unique_Id__c = 'Test Unique Id Rate Card Item Price';
        rateCardItemPrice.csmso__Price_Per_Unit__c = 12;
        rateCardItemPrice.Minimum_Line_Value__c = 4;
        rateCardItemPrice.Rev_Rec_Forecast_Rules__c='2';
        rateCardItemPrice.Create_Revenue_based_on__c='-1';
        rateCardItemPrice.Revenue_Recognition_Rules__c='2';
        insert rateCardItemPrice;

		Map<String, String> searchFieldsMap = new Map<String, String>();
		searchFieldsMap.put('Served By', market.Id);
		searchFieldsMap.put('Account Tier', 'Tier 1');
		searchFieldsMap.put('Rate Card', rateCard.Id);
		searchFieldsMap.put('Market', market.Id);
		searchFieldsMap.put('searchValue', 'Test Product Name');

	
        
		String prodDefinitionID;

		Test.startTest();
		SPProductNodeLookupChipper spProductNodeLookup = new SPProductNodeLookupChipper();
		spProductNodeLookup.getRequiredAttributes();
		Object[] result = spProductNodeLookup.doLookupSearch(searchFieldsMap, prodDefinitionID, null, 2, 25);
		System.assertNotEquals(null, result);

		searchFieldsMap.remove('searchValue');

		result = spProductNodeLookup.doLookupSearch(searchFieldsMap, prodDefinitionID, null, 2, 25);
		System.assertNotEquals(null, result);
         searchFieldsMap.put('FLAG Package Creation','yes');
		result = spProductNodeLookup.doLookupSearch(searchFieldsMap, prodDefinitionID, null, 2, 25);

		Test.stopTest();
	}
    
    @isTest
    public static void test(){
        
       Map<String, String> searchFieldsMap = new Map<String, String>();
        searchFieldsMap.put('Product Subsidiary', 'iPP');
        
        String prodDefinitionID;
        
        Test.startTest();
		SPProductNodeLookupChipper spProductNodeLookup = new SPProductNodeLookupChipper();
        Object[] result = spProductNodeLookup.doLookupSearch(searchFieldsMap, prodDefinitionID, null, 2, 25);
        
        Test.stopTest();
    }
}
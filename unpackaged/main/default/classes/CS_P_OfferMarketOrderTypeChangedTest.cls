@IsTest
private class CS_P_OfferMarketOrderTypeChangedTest {
	private static csmso__Rate_Card__c rateCard;
	private static csmso__Product_Node__c market;

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

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
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
		market = new csmso__Product_Node__c();
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
		insert advertAssignment;

		// create Rate Card (csmso__Rate_Card__c)
		rateCard = new csmso__Rate_Card__c();
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
		insert rateCardItemPrice;
	}

	@IsTest
	static void offerMarketOrderTypeChangedNoEligibilityRule() {
		createTestData();

		cscfga__Configuration_Offer__c confOffer = new cscfga__Configuration_Offer__c();
		confOffer.Name = 'testOffer';
		confOffer.Rate_Card__c = rateCard.Id;
		confOffer.Account_Tier__c = 'Tier 1';
		confOffer.Product_Node__c = market.Id;
		insert confOffer;

		Test.startTest();
		CS_P_OfferMarketOrderTypeChanged offerMarketOrderTypeChanged = new CS_P_OfferMarketOrderTypeChanged();

		offerMarketOrderTypeChanged.isRecordEligible((SObject) confOffer);
		offerMarketOrderTypeChanged.logic();

		cscfga__Configuration_Offer__c selectedOffer = [
				SELECT Id, cscfga__Eligibility_Rule__c
				FROM cscfga__Configuration_Offer__c
				LIMIT 1
		];

		update confOffer;

		System.assertEquals(selectedOffer.cscfga__Eligibility_Rule__c, null);
		Test.stopTest();
	}

	@IsTest
	static void offerMarketOrderTypeChangedUpdateNoEligibilityRule() {
		createTestData();

		cscfga__Configuration_Offer__c confOffer = new cscfga__Configuration_Offer__c();
		confOffer.Name = 'testOffer';
		confOffer.Rate_Card__c = rateCard.Id;
		confOffer.Account_Tier__c = 'Tier 1';
		confOffer.Product_Node__c = market.Id;
		insert confOffer;

		confOffer.Name = 'testOffer2222';
		update confOffer;

		Test.startTest();
		CS_P_OfferMarketOrderTypeChanged offerMarketOrderTypeChanged =
				new CS_P_OfferMarketOrderTypeChanged(new Map<Id, cscfga__Configuration_Offer__c>{
						confOffer.Id => confOffer
				});

		offerMarketOrderTypeChanged.isRecordEligible((SObject) confOffer);
		offerMarketOrderTypeChanged.logic();

		cscfga__Configuration_Offer__c selectedOffer = [
				SELECT Id, cscfga__Eligibility_Rule__c
				FROM cscfga__Configuration_Offer__c
				LIMIT 1
		];

		update confOffer;

		System.assertEquals(selectedOffer.cscfga__Eligibility_Rule__c, null);
		Test.stopTest();
	}

	@IsTest
	static void offerMarketOrderTypeChangedCreateEligibilityRule() {
		createTestData();

		cscfga__Configuration_Offer__c confOffer = new cscfga__Configuration_Offer__c();
		confOffer.Name = 'testOffer';
		confOffer.Rate_Card__c = rateCard.Id;
		confOffer.Account_Tier__c = 'Tier 1';
		confOffer.Product_Node__c = market.Id;
		confOffer.Order_Type__c = 'Direct Commercial';
		insert confOffer;

		Test.startTest();
		CS_P_OfferMarketOrderTypeChanged offerMarketOrderTypeChanged = new CS_P_OfferMarketOrderTypeChanged();

		offerMarketOrderTypeChanged.isRecordEligible((SObject) confOffer);
		offerMarketOrderTypeChanged.logic();

		update confOffer;

		cscfga__Configuration_Offer__c selectedOffer = [
				SELECT Id, cscfga__Eligibility_Rule__c, cscfga__Eligibility_Rule__r.Name
				FROM cscfga__Configuration_Offer__c
				WHERE Id = :confOffer.Id
		];

		System.debug('***** selectedOffer');
		System.debug(selectedOffer);

		System.assertEquals(selectedOffer.cscfga__Eligibility_Rule__r.Name, market.Name + ' | ' + confOffer.Order_Type__c);
		Test.stopTest();
	}

	@IsTest
	static void offerMarketOrderTypeChangedLongMarketName() {
		createTestData();

		market.Name = 'Test Market Name Really Long More Than 80 Characters Amazing How Long!!!';
		update market;

		cscfga__Configuration_Offer__c confOffer = new cscfga__Configuration_Offer__c();
		confOffer.Name = 'testOffer';
		confOffer.Rate_Card__c = rateCard.Id;
		confOffer.Account_Tier__c = 'Tier 1';
		confOffer.Product_Node__c = market.Id;
		confOffer.Order_Type__c = 'Direct Commercial';
		insert confOffer;

		Test.startTest();
		CS_P_OfferMarketOrderTypeChanged offerMarketOrderTypeChanged = new CS_P_OfferMarketOrderTypeChanged();

		offerMarketOrderTypeChanged.isRecordEligible((SObject) confOffer);
		offerMarketOrderTypeChanged.logic();

		update confOffer;

		cscfga__Configuration_Offer__c selectedOffer = [
				SELECT Id, cscfga__Eligibility_Rule__c, cscfga__Eligibility_Rule__r.Name
				FROM cscfga__Configuration_Offer__c
				WHERE Id = :confOffer.Id
		];

		System.debug('***** selectedOffer');
		System.debug(selectedOffer);

		String fullName = market.Name + ' | ' + confOffer.Order_Type__c;
		if (fullName.length() > 80) {
			fullName = fullName.substring(0, 80);
		}

		System.assertEquals(selectedOffer.cscfga__Eligibility_Rule__r.Name, fullName);
		Test.stopTest();
	}

	@IsTest
	static void offerMarketOrderTypeChangedERAlreadyExists() {
		createTestData();

		cscfga__Configuration_Offer__c confOffer = new cscfga__Configuration_Offer__c();
		confOffer.Name = 'testOffer';
		confOffer.Rate_Card__c = rateCard.Id;
		confOffer.Account_Tier__c = 'Tier 1';
		confOffer.Product_Node__c = market.Id;
		confOffer.Order_Type__c = 'Direct Commercial';
		insert confOffer;

		String eligibilityRuleName = market.Name + ' | ' + confOffer.Order_Type__c;
		if (eligibilityRuleName.length() > 80) {
			eligibilityRuleName = eligibilityRuleName.substring(0, 80);
		}

		List<cscfga__Eligibility_Criterion__c> eligibilityRuleCriterionToInsertList = new List<cscfga__Eligibility_Criterion__c>();

		cscfga__Eligibility_Rule__c eligibilityRule = new cscfga__Eligibility_Rule__c(
				Name = eligibilityRuleName,
				cscfga__Description__c = eligibilityRuleName,
				cscfga__Object_Name__c = 'cscfga__Product_Basket__c'
		);
		insert eligibilityRule;

		//Market
		cscfga__Eligibility_Criterion__c eligibilityCriterionMarket = new cscfga__Eligibility_Criterion__c(
				cscfga__Eligibility_Rule__c = eligibilityRule.Id,
				cscfga__Field__c = 'csmso__Sales_Order__r.Market__c',
				cscfga__Operator__c = 'equals',
				cscfga__Value__c = market.Id
		);
		eligibilityRuleCriterionToInsertList.add(eligibilityCriterionMarket);

		//Order Type
		cscfga__Eligibility_Criterion__c eligibilityCriterionOrderType = new cscfga__Eligibility_Criterion__c(
				cscfga__Eligibility_Rule__c = eligibilityRule.Id,
				cscfga__Field__c = 'csmso__Sales_Order__r.Order_Type__c',
				cscfga__Operator__c = 'equals',
				cscfga__Value__c = confOffer.Order_Type__c
		);
		eligibilityRuleCriterionToInsertList.add(eligibilityCriterionOrderType);

		insert eligibilityRuleCriterionToInsertList;

		Test.startTest();
		CS_P_OfferMarketOrderTypeChanged offerMarketOrderTypeChanged = new CS_P_OfferMarketOrderTypeChanged();

		offerMarketOrderTypeChanged.isRecordEligible((SObject) confOffer);
		offerMarketOrderTypeChanged.logic();

		update confOffer;

		cscfga__Configuration_Offer__c selectedOffer = [
				SELECT Id, cscfga__Eligibility_Rule__c, cscfga__Eligibility_Rule__r.Name
				FROM cscfga__Configuration_Offer__c
				WHERE Id = :confOffer.Id
		];

		System.debug('***** selectedOffer');
		System.debug(selectedOffer);

		System.assertEquals(selectedOffer.cscfga__Eligibility_Rule__c, eligibilityRule.Id);
		Test.stopTest();
	}
}
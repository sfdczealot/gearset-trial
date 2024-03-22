@IsTest
public class SyncOpportunityTest {
	private static csmso__Sales_Order__c salesOrder;

	private static void createTestData() {
        PGTestDataFactory_v2.CreateTriggerExecuteCS('Trigger_OpportunitySplit',true);
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;
  PGTestDataFactory_v2.initSetupData();
		Id stdPriceBook = Test.getStandardPricebookId();

		Account acc = TestDataSetupBasic.createAccount();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
		insert acc;

		List<Product2> product2sToInsert = new List<Product2>();
		List<String> product2Names = new List<String>{
				'Awards', 'AddOn Product Definition', 'Ad Served', 'Developer Listings', 'Database Marketing','FastKey'
		};
		for (String product2Name : product2Names) {
			Product2 product2Awards = new Product2();
			product2Awards.Name = product2Name;
			product2Awards.CurrencyIsoCode = 'SGD';
			product2sToInsert.add(product2Awards);
		}
		insert product2sToInsert;

		List<Pricebook2> pricebook2sToInsert = new List<Pricebook2>();
		Pricebook2 pricebookPGSG = new Pricebook2();
		pricebookPGSG.Name = 'PG SG';
		pricebookPGSG.IsActive = true;
		pricebookPGSG.CurrencyIsoCode = 'SGD';
		pricebook2sToInsert.add(pricebookPGSG);

		Pricebook2 pricebook2Standard = new Pricebook2();
		pricebook2Standard.Name = 'Standard Price Book';
		pricebook2Standard.IsActive = true;
		pricebook2Standard.CurrencyIsoCode = 'SGD';
		pricebook2sToInsert.add(pricebook2Standard);
		insert pricebook2sToInsert;

		List<PricebookEntry> pricebookEntriesToInsert = new List<PricebookEntry>();
		for (Product2 product2 : product2sToInsert) {
			PricebookEntry pricebookEntryStandard = new PricebookEntry();
			pricebookEntryStandard.UnitPrice = 20;
			pricebookEntryStandard.IsActive = true;
			pricebookEntryStandard.CurrencyIsoCode = 'SGD';
			pricebookEntryStandard.Product2Id = product2.Id;
			pricebookEntryStandard.Pricebook2Id = stdPriceBook;
			pricebookEntriesToInsert.add(pricebookEntryStandard);

			PricebookEntry pricebookEntryPGSG = new PricebookEntry();
			pricebookEntryPGSG.UnitPrice = 40;
			pricebookEntryPGSG.IsActive = true;
			pricebookEntryPGSG.CurrencyIsoCode = 'SGD';
			pricebookEntryPGSG.Product2Id = product2.Id;
			pricebookEntryPGSG.Pricebook2Id = pricebookPGSG.Id;
			pricebookEntriesToInsert.add(pricebookEntryPGSG);
		}
		insert pricebookEntriesToInsert;

		Payment_Term__c paymentTerm = new Payment_Term__c();
		paymentTerm.Name = 'Payment Term test';
		paymentTerm.NS_Payment_Term_ID__c = 65;
		insert paymentTerm;

		Contact con = TestDataSetupBasic.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
		opp.Pricebook2Id = pricebookPGSG.Id;
		insert opp;

		salesOrder = TestDataSetupSO.createSalesOrder(acc, opp);
		salesOrder.Sale_type__c = 'Sales';
		salesOrder.Billing_Email__c = 'test@abc.com';
		salesOrder.Bill_To_Account__c = acc.Id;
		salesOrder.Bill_To_Account_Final__c = acc.Id;
		salesOrder.Bill_To_Account_Filter__c = acc.Id;
		salesOrder.NetSuite_Payment_Term__c = paymentTerm.Id;
		insert salesOrder;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
		prodBasket.Name = 'Basket test';
		prodBasket.Appr_Code__c = '2';
		prodBasket.Payment_Amount__c = 2;
		prodBasket.cscfga__Total_Price__c = 100;
		prodBasket.Payment_Date__c = System.today();
		prodBasket.Payment_Reference__c = 'PayPal';
		prodBasket.Payment_Gateway__c = 'PayPal';
		prodBasket.Payment_Mode__c = 'PayPal';
		prodBasket.EcomReference__c = 'test';
		insert prodBasket;

		List<cscfga__Product_Configuration__c> productConfigurationsToInsert = new List<cscfga__Product_Configuration__c>();
		List<String> productConfigNames = new List<String>{
				'Awards', 'AddOn Product Definition', 'Ad Served', 'Developer Listings', 'Database Marketing', 'FastKey'
		};

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		productConfigurationsToInsert.add(prodConfig);
		cscfga__Product_Configuration__c prodConfig2 = TestDataSetupTargetables.createProdConfig(prodBasket);
		productConfigurationsToInsert.add(prodConfig2);
		cscfga__Product_Configuration__c prodConfig3 = TestDataSetupTargetables.createProdConfig(prodBasket);
		productConfigurationsToInsert.add(prodConfig3);
		cscfga__Product_Configuration__c prodConfig4 = TestDataSetupTargetables.createProdConfig(prodBasket);
		productConfigurationsToInsert.add(prodConfig4);
		cscfga__Product_Configuration__c prodConfig5 = TestDataSetupTargetables.createProdConfig(prodBasket);
		productConfigurationsToInsert.add(prodConfig5);
		cscfga__Product_Configuration__c prodConfig6 = TestDataSetupTargetables.createProdConfig(prodBasket);
		productConfigurationsToInsert.add(prodConfig6);

		for (Integer i = 0; i < productConfigurationsToInsert.size(); i++) {
			productConfigurationsToInsert[i].Name = productConfigNames[i];
			productConfigurationsToInsert[i].cscfga__Description__c = productConfigNames[i];
			productConfigurationsToInsert[i].cscfga__Quantity__c = 2;
			productConfigurationsToInsert[i].Start_Date__c = System.today();
			productConfigurationsToInsert[i].cscfga__Unit_Price__c = 20;
			productConfigurationsToInsert[i].End_Date__c = System.today() + 3;
			productConfigurationsToInsert[i].cscfga__Product_Family__c = productConfigNames[i];
			productConfigurationsToInsert[i].cscfga__Parent_Configuration__c = null;
			productConfigurationsToInsert[i].cscfga__Product_Basket__c = prodBasket.Id;
			productConfigurationsToInsert[i].Sales_Order__c = salesOrder.Id;
			productConfigurationsToInsert[i].Aggregated_Status__c = 'Draft';
            productConfigurationsToInsert[i].Flight_Begin_Logged_User_Timezone__c = system.today();
		}
		insert productConfigurationsToInsert;
		
		prodConfig2.cscfga__Parent_Configuration__c = prodConfig.Id;
		update prodConfig2;

		Tax_Code__c taxCode = new Tax_Code__c();
		taxCode.Name = 'Tax Code test';
		taxCode.Active__c = true;
		taxCode.NS_Tax_Internal_ID__c = '20';
		taxCode.Tax_Rate__c = 20;
		insert taxCode;

		cspmb__Price_Item__c priceItem = new cspmb__Price_Item__c ();
		priceItem.Name = 'Price Item test';
		priceItem.Tax_Code__c = taxCode.Id;
		priceItem.Product_Category__c = 'Awards';
		insert priceItem;

		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Name = 'Booking Time Zone test';
		insert bookingTimeZone;

		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = '236';
		insert businessUnit;

		csmso__Product_Node__c productNode = new csmso__Product_Node__c();
		productNode.Name = 'Product Node';
		productNode.Unique_Id__c = '6567';
		productNode.csmso__Root_Node__c = true;
		productNode.csmso__Description__c = 'Test';
		productNode.NAA_supported_currency__c = 'THB';
		productNode.Served_By__c = 'Database Marketing';
		productNode.csmso__Media_Types__c = 'Classified';
		productNode.csmso__Business_Unit__c = businessUnit.Id;
		productNode.Sponsorship_Booking_Timezone__c = bookingTimeZone.Id;
		insert productNode;

		csmso__Rate_Card__c rateCard = new csmso__Rate_Card__c();
		rateCard.Type__c = 'Base';
		rateCard.Unique_Id__c = '654';
		rateCard.Order_Type__c = 'Reseller';
		rateCard.Short_Description__c = 'Test';
		rateCard.csmso__From_Date__c = System.today();
		rateCard.csmso__To_Date__c = System.today() + 3;
		rateCard.csmso__Product_Node__c = productNode.Id;
		insert rateCard;

		csmso__Node_Advert_Assignment__c nodeAdvertAssignment = new csmso__Node_Advert_Assignment__c();
		nodeAdvertAssignment.Name = 'Node Advert Assignment';
		nodeAdvertAssignment.Unique_Id__c = '75';
		nodeAdvertAssignment.Rate_Type__c = 'CPM';
		nodeAdvertAssignment.Rate_Type_Display__c = 'CPCV';
		nodeAdvertAssignment.Product_Name__c = 'Product';
		nodeAdvertAssignment.Product_Family__c = 'Audio';
		nodeAdvertAssignment.Served_by__c = 'Megaphone';
		nodeAdvertAssignment.Product_Group__c = 'Audio';
		nodeAdvertAssignment.Line_Item_Type__c = 'Podcast';
		nodeAdvertAssignment.Line_Item_Category__c = 'Other';
		nodeAdvertAssignment.Ad_Location_Description__c = 'Mobile';
		insert nodeAdvertAssignment;

		csmso__Rate_Card_Item_Price__c rateCardItemPrice = new csmso__Rate_Card_Item_Price__c();
		rateCardItemPrice.csmso__Rate_Card__c = rateCard.Id;
		rateCardItemPrice.csmso__Product_Node__c = productNode.Id;
		rateCardItemPrice.csmso__Advert_Assignment__c = nodeAdvertAssignment.Id;
		rateCardItemPrice.Unique_Id__c = '76';
		rateCardItemPrice.Account_Tier__c = 'Tier 1';
		rateCardItemPrice.csmso__Price_Per_Unit__c = 34;
		insert rateCardItemPrice;

		List<cscfga__Attribute__c> attributesToInsert = new List<cscfga__Attribute__c>();
		Map<String, String> attributeNameToValueForPCs = new Map<String, String>{
				'CommercialProduct' => String.valueOf(priceItem.Id),
				'Rate Card' => String.valueOf(rateCard.Id),
				'Node Advert Assignments' => String.valueOf(nodeAdvertAssignment.Id),
				'Net Rate' => '10',
				'Net Rate Adjustment Flat' => '10'
		};

		List<Attachment> attachList = new List<Attachment>();
		for (cscfga__Product_Configuration__c productConfiguration : productConfigurationsToInsert) {
			Attachment aajson = new Attachment();
			aajson.ParentId = productConfiguration.Id;
			aajson.Name = 'Attributes as JSON';
			SyncOpportunity.aajson aaobj = new SyncOpportunity.aajson();
			aaobj.attributesByAttrDefId = new Map<String, cscfga__Attribute__c>();
			for (String attributeName : attributeNameToValueForPCs.keySet()) {
				String attValue = attributeNameToValueForPCs.get(attributeName);
				cscfga__Attribute__c attribute = new cscfga__Attribute__c ();
				attribute.Name = attributeName;
				attribute.cscfga__Is_Line_Item__c = attValue == '10' ? false : true;
				attribute.cscfga__Value__c = attValue;
				attribute.cscfga__Price__c = 10;
				attribute.cscfga__List_Price__c = 20;
				attribute.cscfga__Product_Configuration__c = productConfiguration.Id;
				attribute.cscfga__Line_Item_Description__c = productConfiguration.cscfga__Product_Family__c;
				attributesToInsert.add(attribute);
				aaobj.attributesByAttrDefId.put(String.valueOf('test'+ attributeName ),attribute );
			}
			aajson.Body = Blob.valueOf(JSON.serialize(aaobj));
			attachList.add(aajson);
		}

		insert attachList;
		cscfga__Attribute__c attrTaxCodeOverridePC1 = new cscfga__Attribute__c ();
		attrTaxCodeOverridePC1.Name = 'Tax Code Override';
		attrTaxCodeOverridePC1.cscfga__Value__c = taxCode.Id;
		attrTaxCodeOverridePC1.cscfga__Product_Configuration__c = prodConfig.Id;
		attrTaxCodeOverridePC1.cscfga__Line_Item_Description__c = 'Tax Code Override';
		attributesToInsert.add(attrTaxCodeOverridePC1);

		cscfga__Attribute__c attrAddOnPC2 = new cscfga__Attribute__c ();
		attrAddOnPC2.Name = 'AddOn';
		attrAddOnPC2.cscfga__Value__c = 'AddOn';
		attrAddOnPC2.cscfga__Is_Line_Item__c = false;
		attrAddOnPC2.cscfga__Product_Configuration__c = prodConfig2.Id;
		attrAddOnPC2.cscfga__Line_Item_Description__c = prodConfig2.Id;
		attributesToInsert.add(attrAddOnPC2);

		cscfga__Attribute__c attrInsertionQuantityPC3 = new cscfga__Attribute__c ();
		attrInsertionQuantityPC3.Name = 'Insertion Quantity';
		attrInsertionQuantityPC3.cscfga__Value__c = '5';
		attrInsertionQuantityPC3.cscfga__Product_Configuration__c = prodConfig3.Id;
		attrInsertionQuantityPC3.cscfga__Line_Item_Description__c = prodConfig3.Id;
		attributesToInsert.add(attrInsertionQuantityPC3);

		cscfga__Attribute__c attrInsertionUnitTypeDisplayPC3 = new cscfga__Attribute__c ();
		attrInsertionUnitTypeDisplayPC3.Name = 'Insertion Unit Type Display';
		attrInsertionUnitTypeDisplayPC3.cscfga__Value__c = 'CPD';
		attrInsertionUnitTypeDisplayPC3.cscfga__Product_Configuration__c = prodConfig3.Id;
		attrInsertionUnitTypeDisplayPC3.cscfga__Line_Item_Description__c = prodConfig3.Id;
		attributesToInsert.add(attrInsertionUnitTypeDisplayPC3);

		cscfga__Attribute__c attrMultiplierToMinimumContractQuantityDaysPC3 = new cscfga__Attribute__c ();
		attrMultiplierToMinimumContractQuantityDaysPC3.Name = 'Multiplier to Minimum Contract Quantity Days';
		attrMultiplierToMinimumContractQuantityDaysPC3.cscfga__Value__c = '3';
		attrMultiplierToMinimumContractQuantityDaysPC3.cscfga__Product_Configuration__c = prodConfig3.Id;
		attrMultiplierToMinimumContractQuantityDaysPC3.cscfga__Line_Item_Description__c = prodConfig3.Id;
		attributesToInsert.add(attrMultiplierToMinimumContractQuantityDaysPC3);

		cscfga__Attribute__c attrCalculatedQuantityPC5 = new cscfga__Attribute__c ();
		attrCalculatedQuantityPC5.Name = 'Calculated Quantity';
		attrCalculatedQuantityPC5.cscfga__Value__c = '3';
		attrCalculatedQuantityPC5.cscfga__Product_Configuration__c = prodConfig5.Id;
		attrCalculatedQuantityPC5.cscfga__Line_Item_Description__c = prodConfig5.Id;
		attributesToInsert.add(attrCalculatedQuantityPC5);
		insert attributesToInsert;
	}

	@IsTest
	static void testSyncOpportunity() {
		createTestData();

		Test.startTest();
		SyncOpportunity sync = new SyncOpportunity();
		sync.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void testSyncOpportunityNonPrimarySO() {
		createTestData();

		salesOrder.Primary_Sales_Order__c = false;
		update salesOrder;

		Test.startTest();
		SyncOpportunity sync = new SyncOpportunity();
		sync.performAction(salesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void testSyncOpportunityNoProduct2s() {
		createTestData();

		List<Product2> product2s = [
				SELECT Id
				FROM Product2
		];
		delete product2s;

		Test.startTest();
		SyncOpportunity sync = new SyncOpportunity();
		sync.performAction(salesOrder.Id);
		Test.stopTest();
	} 
}
public class TestDataSetupSO {
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
		Contact testContact = new Contact(FirstName = 'test', LastName = 'Con', AccountId = acc.Id,email = 'test@test.com');
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

	/*method to create a test csmso__SalesOrderAPI__c custom setting */
	public static csmso__SalesOrderAPI__c createSalesOrderAPI() {
		//PropertyGuru Specific custom settings
		//PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger', true);

		csmso__SalesOrderAPI__c soapi = new csmso__SalesOrderAPI__c();
		soapi.csmso__No_Triggers__c = false;
		return soapi;
	}

	/*method to create a test Sales Order*/
	public static csmso__Sales_Order__c createSalesOrder(Account acc, Opportunity opp) {
		csmso__Sales_Order__c testSalesOrder = new csmso__Sales_Order__c();
		testSalesOrder.csmso__Advertiser__c = acc.Id;
		testSalesOrder.csmso__Status__c = 'In Progress';
		testSalesOrder.csmso__Opportunity__c = opp.Id;
		testSalesOrder.Primary_Sales_Order__c = true;
		testSalesOrder.Advertiser_Final__c = acc.Id; 

		return testSalesOrder;
	}

	/****************************************************************************
   * Method Name : createAccounts
   * Description : Used to create accounts
   * Parameters  : Integer which specifies the number of accounts to be created.
   * Return      : List of accounts created
   ****************************************************************************/
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
					Corporate_Brand_Name__c = corporateBrandName.Id, RecordTypeId = recordTypeId,Status__c = 'Active',AgentNet_ID__c = 'test');
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
			Contact con = new Contact(FirstName = 'Test', LastName = 'Con' + i, AccountId = accounts[i].Id,email = 'test'+i+'@test.com');
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
		Id idRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
		List<Opportunity> opportunities = new List<Opportunity>();
		for (Integer i = 0; i < count; i++) {
			Opportunity opp = new Opportunity(Name = 'Test Opportunity' + i,
					AccountId = accounts[i].Id,
					SO_Booking_Contact__c = contacts[i].Id,
					RecordTypeId = idRecordType,                          
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
			so.Advertiser_Final__c = accounts[i].Id;
			so.csmso__Advertiser__c = accounts[i].Id;
			so.csmso__Status__c = 'In Progress';
			so.csmso__Opportunity__c = opportunities[i].Id;
			so.Primary_Sales_Order__c = true;
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

	/*****************************************************************************************
	* Method Name : createProductDefinitions
	* Description : Used to create Product Definitions
	* Parameters  : Integer which specifies the number of Product definitions to be created.
	* Return      : List of Product definitions created
	*****************************************************************************************/
	public static List<cscfga__Product_Definition__c> createProductDefinitions(Integer count) {
		List<cscfga__Product_Definition__c> prodDefinitions = new List<cscfga__Product_Definition__c>();
		for (Integer i = 0; i < count; i++) {
			cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
			prodDef.Name = 'Sample Product Definition' + i;
			prodDef.cscfga__Description__c = 'Sample Product Definition';
			prodDefinitions.add(prodDef);
		}

		if (!prodDefinitions.isEmpty()) {
			insert prodDefinitions;
		}

		return prodDefinitions;
	}

	/*****************************************************************************************
	* Method Name : createAttributeDefinitions
	* Description : Used to create Attribute Definitions
	* Parameters  : Integer which specifies the number of attribute definitions to be created.
	* Return      : List of attribute definitions created
	*****************************************************************************************/
	public static List<cscfga__Attribute_Definition__c> createAttributeDefinitions(Integer count, List<cscfga__Product_Definition__c> prodDefinitions) {
		List<cscfga__Attribute_Definition__c> attrDefinitions = new List<cscfga__Attribute_Definition__c>();
		for (Integer i = 0; i < count; i++) {
			cscfga__Attribute_Definition__c attrDef = new cscfga__Attribute_Definition__c();
			attrDef.Name = 'Sample Attribute Definition' + i;
			attrDef.cscfga__Product_Definition__c = prodDefinitions[i].Id;
			attrDefinitions.add(attrDef);
		}

		if (!attrDefinitions.isEmpty()) {
			insert attrDefinitions;
		}

		return attrDefinitions;
	}

	/***********************************************************************************
	* Method Name : createProdBaskets
	* Description : Used to create product baskets
	* Parameters  : Integer which specifies the number of product baskets to be created.
	* Return      : List of product baskets created
	***********************************************************************************/
	public static List<cscfga__Product_Basket__c> createProdBaskets(Integer count, List<csmso__Sales_Order__c> salesOrders) {
		List<cscfga__Product_Basket__c> prodBaskets = new List<cscfga__Product_Basket__c>();
		for (Integer i = 0; i < count; i++) {
			cscfga__Product_Basket__c prodBasket = new cscfga__Product_Basket__c();
			prodBasket.csmso__Sales_Order__c = salesOrders[i].Id;
			prodBaskets.add(prodBasket);
		}

		if (!prodBaskets.isEmpty()) {
			insert prodBaskets;
		}

		return prodBaskets;
	}

	/******************************************************************************************
	* Method Name : createProdConfigs
	* Description : Used to create product configurations
	* Parameters  : Integer which specifies the number of product configurations to be created.
	* Return      : List of product configurations created
	******************************************************************************************/
	public static List<cscfga__Product_Configuration__c> createProdConfigs(Integer count, List<cscfga__Product_Basket__c> prodBaskets, List<cscfga__Product_Definition__c> prodDefinitions) {
		List<cscfga__Product_Configuration__c> prodConfigs = new List<cscfga__Product_Configuration__c>();
		for (Integer i = 0; i < count; i++) {
			cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c();
			prodConfig.cscfga__Product_Basket__c = prodBaskets[i].Id;
			prodConfig.cscfga__Product_Definition__c = prodDefinitions[i].Id;
			prodConfig.Configuration_Status_Tmp__c = 'Valid';
			prodConfig.csmso__Flight_Begin__c = System.now();
			prodConfig.csmso__Flight_End__c = System.now() + 50;
			prodConfig.Insertion_Quantity__c = 15000;
			prodConfig.Price__c = 12.34;
			prodConfigs.add(prodConfig);
		}

		if (!prodConfigs.isEmpty()) {
			insert prodConfigs;
		}

		return prodConfigs;
	}

	/******************************************************************************************
	* Method Name : createAttributes
	* Description : Used to create Attributes
	* Parameters  : Integer which specifies the number of product configurations to be created.
	* Return      : List of product configurations created
	******************************************************************************************/
	public static List<cscfga__Attribute__c> createAttributes(Integer count, List<cscfga__Product_Configuration__c> prodConfigs, List<cscfga__Attribute_Definition__c> attrDefinitions) {
		List<cscfga__Attribute__c> attributes = new List<cscfga__Attribute__c>();
		for (Integer i = 0; i < count; i++) {
			cscfga__Attribute__c attr = new cscfga__Attribute__c();
			attr.cscfga__Product_Configuration__c = prodConfigs[i].Id;
			attr.cscfga__Attribute_Definition__c = attrDefinitions[i].Id;
			attr.cscfga__Value__c = 'Sample Value';
			attr.cscfga__Display_Value__c = 'Sample Display Value';
			attributes.add(attr);
		}

		if (!attributes.isEmpty()) {
			insert attributes;
		}

		return attributes;
	}


	public static cscfga__Product_Configuration__c createproductConfigAndDef(String name) {
		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		testProDef.cscfga__Allow_progress_from_incomplete_screens__c = true;
		insert testProDef;

		cscfga__Configuration_Screen__c screenFlow = TestDataSetupTargetables.createConfigurationScreen(testProDef, 'Default Screen');
		insert screenFlow;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef.cscfga__Column__c = 0;
		testAttrDef.cscfga__Row__c = 0;
		testAttrDef.Name = 'Price';

		cscfga__Attribute_Definition__c testAttrDef2 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef2.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef2.cscfga__Column__c = 0;
		testAttrDef2.cscfga__Row__c = 1;
		testAttrDef2.Name = 'Insertion Quantity';

		cscfga__Attribute_Definition__c testAttrDef3 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef3.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef3.cscfga__Column__c = 0;
		testAttrDef3.cscfga__Row__c = 1;
		testAttrDef3.Name = 'Flight Begin';

		cscfga__Attribute_Definition__c testAttrDef4 = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef4.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef4.cscfga__Column__c = 0;
		testAttrDef4.cscfga__Row__c = 1;
		testAttrDef4.Name = 'Flght End';

		SObject[] attDefs = new SObject[]{testAttrDef, testAttrDef2, testAttrDef3, testAttrDef4};
		insert attDefs;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(null);
		prodConfig.Configuration_Status_Tmp__c = 'Valid';
		prodConfig.cscfga__Product_Definition__c = testProDef.Id;
		insert prodConfig;

		cscfga__Attribute__c attQty = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Insertion Quantity', cscfga__Value__c = '10000', cscfga__Attribute_Definition__c = testAttrDef2.Id);
		cscfga__Attribute__c attPrice = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Price', cscfga__Value__c = '250', cscfga__Attribute_Definition__c = testAttrDef.Id);
		cscfga__Attribute__c attFrom = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Flight Begin', cscfga__Value__c = '2017-01-01', cscfga__Attribute_Definition__c = testAttrDef3.Id);
		cscfga__Attribute__c attTo = new cscfga__Attribute__c(cscfga__Product_Configuration__c = prodConfig.Id, Name = 'Flight End', cscfga__Value__c = '2017-01-16', cscfga__Attribute_Definition__c = testAttrDef4.Id);

		SObject[] Atts = new SObject[]{attQty, attPrice, attFrom, attTo};
		insert Atts;

		return prodConfig;
	}
	
	public static Account createB2BAcc(){
		
		Trigger_Execute__c TE = new Trigger_Execute__c();
		TE.Name = 'PGAccountTrigger';
		TE.Enable_del__c = true;
		insert TE;
		
		Id idRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
		Account acc = new Account(Name = 'Test Account', Website = 'www.cloudsense.com',
								BillingCity = 'City', BillingCountry = 'United States', BillingCountryCode = 'US', BillingPostalCode = '10000',
								BillingState = 'Alabama', BillingStateCode = 'AL', BillingStreet = 'Some Street', Billing_email__c = 'some@some.com',
								Industry = 'Agency', Industry_Tier_2__c = 'Media Agency', Type = 'Advertiser', CurrencyIsoCode = 'EUR',
								RecordTypeId =idRecordType ); 
		
		return acc;
		
	}
}
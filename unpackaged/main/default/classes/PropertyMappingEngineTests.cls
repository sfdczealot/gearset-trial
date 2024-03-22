@IsTest(SeeAllData=false)
public class PropertyMappingEngineTests {
	//
	// Push values fromAttributes to sObject
	//
	@IsTest
	public static void TestAttrToObject() {
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		// ARRANGE
		/*method to create a test product Definition*/
		cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
		prodDef.cscfga__Description__c = 'testDescription';
		prodDef.Name = 'Map Test';
		insert prodDef;

		SObject[] atts = new SObject[]{};

		cscfga__Attribute_Definition__c AttDef = TestDataSetupTargetables.createAttrDef(prodDef);
		AttDef.cscfga__Data_Type__c = 'String';
		atts.add(AttDef);

		cscfga__Attribute_Definition__c AttDef2 = TestDataSetupTargetables.createAttrDef(prodDef);
		AttDef2.cscfga__Data_Type__c = 'Integer';
		atts.add(AttDef2);

		cscfga__Attribute_Definition__c AttDef3 = TestDataSetupTargetables.createAttrDef(prodDef);
		AttDef3.cscfga__Data_Type__c = 'Boolean';
		atts.add(AttDef3);

		cscfga__Attribute_Definition__c AttDef4 = TestDataSetupTargetables.createAttrDef(prodDef);
		AttDef4.cscfga__Data_Type__c = 'Decimal';
		atts.add(AttDef4);

		cscfga__Attribute_Definition__c AttDef5 = TestDataSetupTargetables.createAttrDef(prodDef);
		AttDef5.cscfga__Data_Type__c = 'Double';
		atts.add(AttDef5);

		cscfga__Attribute_Definition__c AttDef6 = TestDataSetupTargetables.createAttrDef(prodDef);
		AttDef6.cscfga__Data_Type__c = 'Date';
		atts.add(AttDef6);
		insert atts;

		cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();

		cscfga__Product_Configuration__c config = TestDataSetupTargetables.createProdConfig(basket);
		insert config;

		atts.clear();

		// Create an Attribute
		cscfga__Attribute__c testAttr = new cscfga__Attribute__c();
		testAttr.cscfga__Product_Configuration__c = config.Id;
		testAttr.cscfga__Value__c = 'hello1234';
		testAttr.Name = 'Fulfilment Item';
		testAttr.cscfga__Attribute_Definition__c = AttDef.Id;
		atts.add(testAttr);

		// Create an Attribute
		cscfga__Attribute__c testAttr2 = new cscfga__Attribute__c();
		testAttr2.cscfga__Product_Configuration__c = config.Id;
		testAttr2.cscfga__Value__c = '123';
		testAttr2.Name = 'Fulfilment Item';
		testAttr2.cscfga__Attribute_Definition__c = AttDef2.Id;
		atts.add(testAttr2);

		// Create an Attribute
		cscfga__Attribute__c testAttr3 = new cscfga__Attribute__c();
		testAttr3.cscfga__Product_Configuration__c = config.Id;
		testAttr3.cscfga__Value__c = 'false';
		testAttr3.Name = 'Fulfilment Item';
		testAttr3.cscfga__Attribute_Definition__c = AttDef3.Id;
		atts.add(testAttr3);

		// Create an Attribute
		cscfga__Attribute__c testAttr4 = new cscfga__Attribute__c();
		testAttr4.cscfga__Product_Configuration__c = config.Id;
		testAttr4.cscfga__Value__c = '1.20';
		testAttr4.Name = 'Fulfilment Item';
		testAttr4.cscfga__Attribute_Definition__c = AttDef4.Id;
		atts.add(testAttr4);

		// Create an Attribute
		cscfga__Attribute__c testAttr5 = new cscfga__Attribute__c();
		testAttr5.cscfga__Product_Configuration__c = config.Id;
		testAttr5.cscfga__Value__c = '4';
		testAttr5.Name = 'Fulfilment Item';
		testAttr5.cscfga__Attribute_Definition__c = AttDef5.Id;
		atts.add(testAttr5);

		// Create an Attribute
		cscfga__Attribute__c testAttr6 = new cscfga__Attribute__c();
		testAttr6.cscfga__Product_Configuration__c = config.Id;
		testAttr6.cscfga__Value__c = '2017-01-01';
		testAttr6.Name = 'Fulfilment Item';
		testAttr6.cscfga__Attribute_Definition__c = AttDef6.Id;
		atts.add(testAttr6);
		insert atts;

		Property_Map__c newMap2 = new Property_Map__c();
		newMap2.Attribute_Mapping_Direction__c = 'Map Attributes to Fields';
		newMap2.Unique_Name__c = 'testingAttrToObj' + Datetime.now();
		insert newMap2;

		SObject[] mappers = new SObject[]{};

		Attribute_Mapper__c attMap = new Attribute_Mapper__c();
		attMap.Property_Map__c = newMap2.Id;
		attMap.Attribute_Definition__c = AttDef.Id;
		attMap.Object_Name__c = 'Account';
		attMap.Field_Name__c = 'Name';
		attMap.Attribute_Definition_Name__c = 'Name';
		mappers.add(attMap);

		Attribute_Mapper__c attMap2 = new Attribute_Mapper__c();
		attMap2.Property_Map__c = newMap2.Id;
		attMap2.Attribute_Definition__c = AttDef2.Id;
		attMap2.Object_Name__c = 'Account';
		attMap2.Field_Name__c = 'NumberOfEmployees';
		attMap2.Attribute_Definition_Name__c = 'NumberOfEmployees';
		mappers.add(attMap2);

		Attribute_Mapper__c attMap4 = new Attribute_Mapper__c();
		attMap4.Property_Map__c = newMap2.Id;
		attMap4.Attribute_Definition__c = AttDef4.Id;
		attMap4.Object_Name__c = 'Account';
		attMap4.Field_Name__c = 'AnnualRevenue';
		attMap4.Attribute_Definition_Name__c = 'AnnualRevenue';
		mappers.add(attMap4);
		System.debug('Mappers are ' + mappers);
		insert mappers;
		update mappers; // Hit the update leg of the trigger too!

		Map<Id, SObject[]> thingsToMap = new Map<Id, SObject[]>();

		SObject[] errorLogsToUpdate = new SObject[]{};
		Account newAccount = new Account();

		thingsToMap.put(config.Id, new SObject[]{newAccount});

		Test.startTest();
		// ACT
		cscfga__Attribute__c[] retVal = PropertyMappingEngine.mapAtrributesAndFields(newMap2.Unique_Name__c, thingsToMap);

		// ASSERT;
		System.debug('#### comparing' + newAccount.Name + ' with ' + testAttr.cscfga__Value__c);
		Test.stopTest();
	}


	@IsTest
	public static void TestObjectToAttr() {
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		// ARRANGE
		/*method to create a test product Definition*/
		cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
		prodDef.cscfga__Description__c = 'testDescription';
		prodDef.Name = 'Map Test';
		insert prodDef;

		SObject[] atts = new SObject[]{};
		cscfga__Attribute_Definition__c AttDef = TestDataSetupTargetables.createAttrDef(prodDef);
		AttDef.cscfga__Data_Type__c = 'String';
		atts.add(AttDef);

		cscfga__Attribute_Definition__c AttDef2 = TestDataSetupTargetables.createAttrDef(prodDef);
		AttDef2.cscfga__Data_Type__c = 'Integer';
		atts.add(AttDef2);

		cscfga__Attribute_Definition__c AttDef3 = TestDataSetupTargetables.createAttrDef(prodDef);
		AttDef3.cscfga__Data_Type__c = 'Boolean';
		atts.add(AttDef3);

		cscfga__Attribute_Definition__c AttDef4 = TestDataSetupTargetables.createAttrDef(prodDef);
		AttDef4.cscfga__Data_Type__c = 'Decimal';
		atts.add(AttDef4);

		cscfga__Attribute_Definition__c AttDef5 = TestDataSetupTargetables.createAttrDef(prodDef);
		AttDef5.cscfga__Data_Type__c = 'Double';
		atts.add(AttDef5);

		cscfga__Attribute_Definition__c AttDef6 = TestDataSetupTargetables.createAttrDef(prodDef);
		AttDef6.cscfga__Data_Type__c = 'Date';
		atts.add(AttDef6);
		insert atts;

		cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();

		cscfga__Product_Configuration__c config = TestDataSetupTargetables.createProdConfig(basket);
		insert config;

		atts.clear();

		// Create an Attribute
		cscfga__Attribute__c testAttr = new cscfga__Attribute__c();
		testAttr.cscfga__Product_Configuration__c = config.Id;
		testAttr.cscfga__Value__c = 'hello1234';
		testAttr.Name = 'Fulfilment Item';
		testAttr.cscfga__Attribute_Definition__c = AttDef.Id;
		atts.add(testAttr);

		// Create an Attribute
		cscfga__Attribute__c testAttr2 = new cscfga__Attribute__c();
		testAttr2.cscfga__Product_Configuration__c = config.Id;
		testAttr2.cscfga__Value__c = '123';
		testAttr2.Name = 'Fulfilment Item';
		testAttr2.cscfga__Attribute_Definition__c = AttDef2.Id;
		atts.add(testAttr2);

		// Create an Attribute
		cscfga__Attribute__c testAttr3 = new cscfga__Attribute__c();
		testAttr3.cscfga__Product_Configuration__c = config.Id;
		testAttr3.cscfga__Value__c = 'false';
		testAttr3.Name = 'Fulfilment Item';
		testAttr3.cscfga__Attribute_Definition__c = AttDef3.Id;
		atts.add(testAttr3);

		// Create an Attribute
		cscfga__Attribute__c testAttr4 = new cscfga__Attribute__c();
		testAttr4.cscfga__Product_Configuration__c = config.Id;
		testAttr4.cscfga__Value__c = '1.20';
		testAttr4.Name = 'Fulfilment Item';
		testAttr4.cscfga__Attribute_Definition__c = AttDef4.Id;
		atts.add(testAttr4);

		// Create an Attribute
		cscfga__Attribute__c testAttr5 = new cscfga__Attribute__c();
		testAttr5.cscfga__Product_Configuration__c = config.Id;
		testAttr5.cscfga__Value__c = '1.20';
		testAttr5.Name = 'Fulfilment Item';
		testAttr5.cscfga__Attribute_Definition__c = AttDef5.Id;
		atts.add(testAttr5);

		// Create an Attribute
		cscfga__Attribute__c testAttr6 = new cscfga__Attribute__c();
		testAttr6.cscfga__Product_Configuration__c = config.Id;
		testAttr6.cscfga__Value__c = '2017-01-01';
		testAttr6.Name = 'Fulfilment Item';
		testAttr6.cscfga__Attribute_Definition__c = AttDef6.Id;
		atts.add(testAttr6);
		insert atts;

		Property_Map__c newMap2 = new Property_Map__c();
		newMap2.Attribute_Mapping_Direction__c = 'Map Fields to Attributes';
		newMap2.Unique_Name__c = 'testingObjToAttr' + Datetime.now();
		insert newMap2;

		Map<Id, SObject[]> thingsToMap = new Map<Id, SObject[]>();

		SObject[] errorLogsToUpdate = new SObject[]{};

		Test.startTest();
		// ACT
		cscfga__Attribute__c[] retVal = PropertyMappingEngine.mapAtrributesAndFields(newMap2.Unique_Name__c, thingsToMap);
		update retVal;

		// ASSERT;
		Test.stopTest();
	}

	//
	// Push values from sObkject to Attributes
	// You need to change the Property Map to say you're writing not reading!
	//
	private static testMethod void TestObjectToObject() {
		// ARRANGE
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Test.startTest();
		SObject[] objs = createData();
		Property_Map__c newMap2 = new Property_Map__c();
		newMap2.Attribute_Mapping_Direction__c = 'Map Fields to Attributes';
		newMap2.Unique_Name__c = 'testingObjToObj';
		insert newMap2;

		createFieldMappings(newMap2);

		PropertyMappingEngine.FieldMappingPair[] fmps = new PropertyMappingEngine.FieldMappingPair[]{};

		PropertyMappingEngine.FieldMappingPair pair = new PropertyMappingEngine.FieldMappingPair();
		pair.Source = objs[0];
		pair.Destinations = new SObject[]{objs[1]};
		fmps.add(pair);

		// ACT
		SObject[] toUpdate = PropertyMappingEngine.mapsObjectFields('testingObjToObj', fmps);

		// ASSERT
		System.assert (toUpdate[0].get('QuoteToName') == pair.Source.get('Name'));
		Test.stopTest();
	}


	@IsTest
	private static void Test_FindObjectsSuccess() {
		Account a = TestDataSetupTargetables.createAccount();
		SObject[] accs = new SObject[]{a};

		List<SObject[]> listOfLists = new List<SObject[]>();
		listOfLists.add(accs);

		Set<String> objectNames = AttributeMappingEngine.findObjects(listOfLists);

		System.assert(objectNames.size() == 1);
	}

	@IsTest
	private static void Test_IdToStringSuccess() {
		Account a = TestDataSetupTargetables.createAccount();
		String accIdString = String.valueOf(a.Id);
		Id retId = AttributeMappingEngine.convertStringToId(accIdString);

		System.assertEquals(retId, a.Id);
	}

	@IsTest
	private static void Test_IdToStringFail() {
		String dummId = '393839393XX!';
		Id retId = AttributeMappingEngine.convertStringToId(dummId);

		System.assert(retId == null);
	}

	@IsTest
	private static void test_StringToDecimalSuccess() {
		String goodDecimal = '2.32';
		Decimal retVal = AttributeMappingEngine.convertStringToDecimal(goodDecimal);

		System.assertEquals(Decimal.valueOf(goodDecimal), retVal);
	}

	@IsTest
	private static void test_StringToDecimalFail() {
		String goodDecimal = 'ZZZ2.32XXXCCC!!!!!';
		Decimal retVal = AttributeMappingEngine.convertStringToDecimal(goodDecimal);

		System.assert(retVal == null);
	}

	private static List<SObject> createData() {
		List<Account> accountsToInsert = new List<Account>();
		List<Contact> contactsToInsert = new List<Contact>();
		List<Opportunity> oppsToInsert = new List<Opportunity>();

		// src
		Account a = TestDataSetupTargetables.createAccount();
		accountsToInsert.add(a);

		// dest
		Account ACC_test = TestDataSetupTargetables.createAccount();
		accountsToInsert.add(ACC_test);

		insert accountsToInsert;

		Contact testContact = TestDataSetupTargetables.createContact(a);
		contactsToInsert.add(testContact);

		Contact testContact2 = TestDataSetupTargetables.createContact(ACC_test);
		contactsToInsert.add(testContact2);

		insert contactsToInsert;

		Opportunity Opp_test = TestDataSetupTargetables.createOpportunity(a, testContact);
		oppsToInsert.add(Opp_test);

		Opportunity Opp_tmp = TestDataSetupTargetables.createOpportunity(ACC_test, testContact2);
		oppsToInsert.add(Opp_tmp);

		insert oppsToInsert;

		Quote Q_test = new Quote(
				Name = 'Test Q',
				OpportunityId = Opp_tmp.Id,
				ShippingName = 'SN',
				Tax = 24.35,
				ExpirationDate = Date.newInstance(Date.today().year() + 2, 4, 4),
				CreatedDate__c = Date.today()
		);
		insert Q_test;

		List<SObject> sO = new List<SObject>();
		sO.add(Opp_test);
		sO.add(Q_test);

		return sO;
	}

	static cscfga__Object_Mapping__c createFieldMappings(Property_Map__c propertyMap) {
		// data creation
		List<SObject> sO = createData();

		cscfga__Object_Mapping__c OM = new cscfga__Object_Mapping__c(Name = 'TestOM1 Opp to Q',
				cscfga__From_Type__c = 'Opportunity',
				cscfga__To_Type__c = 'Quote',
				Property_Map__c = propertyMap.Id);
		insert OM;

		cscfga__Field_Mapping__c FM1 = new cscfga__Field_Mapping__c(Name = 'Test1 Amount to Tax',
				cscfga__Object_Mapping__c = OM.Id,
				cscfga__From_Field__c = 'Amount',
				cscfga__To_Field__c = 'Tax');
		insert FM1;
		cscfga__Field_Mapping__c FM2 = new cscfga__Field_Mapping__c(Name = 'Test1 Opp to QuoteToName',
				cscfga__Object_Mapping__c = OM.Id,
				cscfga__From_Field__c = 'Name',
				cscfga__To_Field__c = 'QuoteToName');
		insert FM2;
		cscfga__Field_Mapping__c FM3 = new cscfga__Field_Mapping__c(Name = 'Test1 StageName to ShippingName',
				cscfga__Object_Mapping__c = OM.Id,
				cscfga__From_Field__c = 'StageName',
				cscfga__To_Field__c = 'ShippingName');
		insert FM3;
		// end data creation

		return OM;
	}
}
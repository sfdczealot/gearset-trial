@isTest
private class CS_utl_SObjectTest {
	/**
	 * Test getDecimalValue method
	 */
	@isTest
	public static void test_getDecimalValue() {
		Account acc = CS_th_Account.create('TestAccount', false);
		acc.NumberOfEmployees = 5;
		
		Test.startTest();
		
		System.assertEquals(5.0, CS_utl_SObject.getDecimalValue('NumberOfEmployees', acc));
		
		Test.stopTest();
	}
	
	/**
	 * Test isNotNull method
	 */
	@isTest
	public static void test_isNotNull() {
		Account acc = CS_th_Account.create('TestName', false);
		
		Test.startTest();
		
		System.assert(CS_utl_SObject.isNotNull('Name', acc));
		
		acc.Name = null;
		System.assert(!CS_utl_SObject.isNotNull('Name', acc));
		
		Test.stopTest();
	}
	 
	/**
	 * Test getFieldValue method
	 */
	@isTest
	public static void test_getFieldValue() {
		Account acc = CS_th_Account.create('TestAccount', false);
		Contact obj = CS_th_Contact.create('TestFirst', 'TestLast', acc, false);
		obj.Account = acc;

		Set<String> fieldNames = new Set<String>{'FirstName', 'LastName', 'Account.Name'};

		Test.startTest();

		System.assertEquals(CS_utl_SObject.getFieldValue(obj, 'FirstName'), 'TestFirst');

		System.assertEquals(CS_utl_SObject.getFieldValue(obj, 'LastName'), 'TestLast');

		System.assertEquals(CS_utl_SObject.getFieldValue(obj, 'Account.Name'), 'TestAccount');

		System.assertEquals(CS_utl_SObject.getFieldValue(obj, 'invalidField'), null);

		System.assertEquals(CS_utl_SObject.getFieldValue(null, 'LastName'), null);

		Test.stopTest();
	}

	/**
	 * Test getFieldList method, no excluded fields
	 */
	@isTest
	public static void test_getFieldListNoExcluded() {
		Test.startTest();

		String fieldList = CS_utl_SObject.getFieldList(Account.getSObjectType());

		System.assert(String.isNotBlank(fieldList));
		System.assert(fieldList.contains(Account.Name.getDescribe().Name));

		Test.stopTest();		
	}
	
	/**
	 * Test getFieldList method, prefix
	 */
	@isTest
	public static void test_getFieldListprefix() {
		Test.startTest();

		String fieldList = CS_utl_SObject.getFieldList(Account.getSObjectType(), 'Contract.');

		System.assert(String.isNotBlank(fieldList));
		System.assert(fieldList.contains('Contract.' + Account.Name.getDescribe().Name));

		Test.stopTest();		
	}

	/**
	 * Test getFieldList method, excluded fields
	 */
	@isTest
	public static void test_getFieldListExcluded() {
		Set<Schema.SObjectField> excluded = new Set<Schema.SObjectField>{Account.Name};

		Test.startTest();

		String fieldList = CS_utl_SObject.getFieldList(Account.getSObjectType(), '', excluded);

		System.assert(String.isNotBlank(fieldList));
		System.assert(!fieldList.contains(',' + Account.Name.getDescribe().Name + ','));

		Test.stopTest();		
	}
	
	/**
	 * Test join method, using fields
	 */
	@isTest
	public static void test_joinFieldList() {
		Account account = CS_th_Account.create('TestAccount', false);
		Contact obj = CS_th_Contact.create('TestFirst', 'TestLast', account, false);
		obj.Account = account;

		Set<String> fieldNames = new Set<String>{'FirstName', 'LastName', 'Account.Name'};

		Test.startTest();

		String result = CS_utl_SObject.joinFieldList(obj, fieldNames, ',');
		System.assertEquals('TestFirst,TestLast,TestAccount', result);

		Test.stopTest();
	}
	
	/**
	 * Test getRelationshipField method
	 */
	@isTest
	public static void test_getRelationshipField() {
		Account account = CS_th_Account.create('TestAccount', false);
		Contact obj = CS_th_Contact.create('TestFirst', 'TestLast', account, false);
		
		Test.startTest();

		Schema.DescribeFieldResult result = CS_utl_SObject.getRelationshipField(account.getSObjectType(), obj.getSObjectType());
		System.assertEquals(Contact.AccountId.getDescribe().getName(), result.getName());

		Test.stopTest();
	}
}
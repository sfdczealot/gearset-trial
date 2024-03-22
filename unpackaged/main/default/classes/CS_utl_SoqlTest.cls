/**
 * @name CS_utl_SoqlTest
 * @description Test class for CS_utl_Soql
 * @revision
 *
 */
@isTest
public class CS_utl_SoqlTest {
	/**
	 * Tests buildCritera method, SObject
	 */
	@isTest
	public static void test_buildCriteriaSObject() {
		Account account = CS_th_Account.create('TestAccount', false);
		account.NumberOfEmployees = 4;
		insert account;

		Test.startTest();

		String critera = CS_utl_Soql.buildCriteria(account);

		System.assert(String.isNotBlank(critera));
		System.assert(critera.contains('WHERE'));
		System.assert(critera.contains('name=\'' + account.Name + '\''));
		System.assert(critera.contains('numberofemployees=' + account.NumberOfEmployees + ''));

		Test.stopTest();
	}

	/**
	 * Tests buildCritera method, single id
	 */
	@isTest
	public static void test_buildCriteriaSingleId() {
		Account account = CS_th_Account.create('TestAccount');

		Test.startTest();

		String critera = CS_utl_Soql.buildCriteria(new Map<String, Set<Id>>{'Id' => new Set<Id>{account.Id}});

		System.assert(String.isNotBlank(critera));
		System.assert(critera.contains('WHERE (Id IN (\'' + account.Id + '\'))'));

		Test.stopTest();
	}

	/**
	 * Tests buildCritera method, multiple ids
	 */
	@isTest
	public static void test_buildCriteriaMultipleIds() {
		Id firstId = CS_utl_Id.getFakeId(Account.getSObjectType());
		Id secondId = CS_utl_Id.getFakeId(Account.getSObjectType());

		Test.startTest();

		String critera = CS_utl_Soql.buildCriteria(new Map<String, Set<Id>>{'Id' => new Set<Id>{firstId, secondId}});

		System.assert(String.isNotBlank(critera));
		System.assert(critera.contains('WHERE (Id IN (\'' + firstId + '\',\'' + secondId +'\'))'));

		Test.stopTest();
	}

	/**
	 * Tests buildQuery method, SObject
	 */
	@isTest
	public static void test_buildQuerySObject() {
		Account account = CS_th_Account.create('TestAccount');

		Test.startTest();

		String query = CS_utl_Soql.buildQuery(account);

		System.assert(String.isNotBlank(query));

		Account accountDb = Database.query(query);
		System.assertEquals(account.Id, accountDb.Id);

		Test.stopTest();
	}

	/**
	 * Tests buildQuery method, SObject additional fields
	 */
	@isTest
	public static void test_buildQuerySObjectAdditionalFields() {
		Account account = CS_th_Account.create('TestAccount');
		Contact contact = CS_th_Contact.create('TestFirst', 'TestLast', account);

		Test.startTest();

		String query = CS_utl_Soql.buildQuery(contact, 'Account.Name');

		System.assert(String.isNotBlank(query));

		Contact contactDb = Database.query(query);
		System.assertEquals(contactDb.Id, contactDb.Id);
		System.assertEquals(account.Name, contactDb.Account.Name);

		Test.stopTest();
	}

	/**
	 * Tests buildQuery method, Id
	 */
	@isTest
	public static void test_buildQueryId() {
		Account account = CS_th_Account.create('TestAccount');

		Test.startTest();

		String query = CS_utl_Soql.buildQuery(Schema.Account.getSObjectType(), new Map<String, Set<Id>>{'Id' => new Set<Id>{account.Id}});

		System.assert(String.isNotBlank(query));

		Account accountDb = Database.query(query);
		System.assertEquals(account.Id, accountDb.Id);

		Test.stopTest();
	}

	/**
	 * Tests buildQuery method, Id additional fields
	 */
	@isTest
	public static void test_buildQueryIdAdditionalFields() {
		Account account = CS_th_Account.create('TestAccount');
		Contact contact = CS_th_Contact.create('TestFirst', 'TestLast', account);

		Test.startTest();

		String query = CS_utl_Soql.buildQuery(Schema.Contact.getSObjectType(), new Map<String, Set<Id>>{'Id' => new Set<Id>{contact.Id}},
											 'Account.Name');

		System.assert(String.isNotBlank(query));

		Contact contactDb = Database.query(query);
		System.assertEquals(contactDb.Id, contactDb.Id);
		System.assertEquals(account.Name, contactDb.Account.Name);

		Test.stopTest();
	}
}
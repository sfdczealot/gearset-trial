/**
 * @name CS_DMLWorkerTest
 * @description Test for CS_DMLWorker class
 * @revision
 *
 */
@isTest
public class CS_DMLWorkerTest {
	/**
	 * Tests insertRecords, with error
	 */
	@isTest
	public static void test_insertRecordsError() {
		Account account = CS_th_Account.create('Test');
		account.Id = CS_utl_Id.getFakeId(Account.getSObjectType());

		CS_DMLWorker dml = new CS_DMLWorker();

		Test.startTest();

		dml.upsertRecords(new List<SObject>{account}, false);

		Test.stopTest();
		
		System.assert(!dml.success);
		System.assertEquals(0, dml.recordCount);
	}

	/**
	 * Tests insertRecords
	 */
	@isTest
	public static void test_insertRecords() {
		Account account = CS_th_Account.create('Test', false);

		CS_DMLWorker dml = new CS_DMLWorker();

		Test.startTest();

		dml.upsertRecords(new List<SObject>{account}, true);

		Test.stopTest();
		
		List<Account> accounts = [SELECT Id FROM Account];
		System.assert(!accounts.isEmpty());
		System.assert(dml.success);
		System.assertEquals(1, dml.recordCount);
	}

	/**
	 * Tests updateRecords, with error
	 */
	@isTest
	public static void test_updateRecordsError() {
		Account account = CS_th_Account.create('Test');
		account.Id = CS_utl_Id.getFakeId(Account.getSObjectType());

		CS_DMLWorker dml = new CS_DMLWorker();

		Test.startTest();

		dml.upsertRecords(new List<SObject>{account}, false);
		System.assertEquals(0, dml.recordCount);

		Test.stopTest();
	}

	/**
	 * Tests updateRecords
	 */
	@isTest
	public static void test_updateRecords() {
		Account account = CS_th_Account.create('Test');

		CS_DMLWorker dml = new CS_DMLWorker();

		Test.startTest();

		dml.upsertRecords(new List<SObject>{account}, true);
		System.assertEquals(1, dml.recordCount);

		Test.stopTest();
	}

	/**
	 * Tests deleteRecords, with error
	 */
	@isTest
	public static void test_deleteRecordsError() {
		Account account = CS_th_Account.create('Test');
		account.Id = CS_utl_Id.getFakeId(Account.getSObjectType());

		CS_DMLWorker dml = new CS_DMLWorker();

		Test.startTest();

		dml.deleteRecords(new List<SObject>{account}, false);
		System.assertEquals(0, dml.recordCount);

		Test.stopTest();
	}

	/**
	 * Tests deleteRecords
	 */
	@isTest
	public static void test_deleteRecords() {
		Account account = CS_th_Account.create('Test');

		CS_DMLWorker dml = new CS_DMLWorker();

		Test.startTest();

		dml.deleteRecords(new List<SObject>{account}, true);
		System.assertEquals(1, dml.recordCount);

		Test.stopTest();
	}
}
/**
 * @name CS_SalesOrderScheduleBatchTest
 * @description Test for CS_SalesOrderScheduleBatch class
 * @revision
 *
 */
@isTest
private class CS_SalesOrderScheduleBatchTest {
	/**
	 * Tests getNextBatchName no next
	 */
	@IsTest
	private static void test_getNextBatchNameEmpty() {
		CS_th_Worker.create();
		
		Test.startTest();
		
		CS_mock_SalesOrderScheduleBatch batch = new CS_mock_SalesOrderScheduleBatch();
		System.assertEquals(null, batch.getNextBatchName());
		
		Test.stopTest();
	}

	/**
	 * Tests getNextBatchName
	 */
	@IsTest
	private static void test_getNextBatchName() {
		CS_th_Worker.create();
		
		Test.startTest();
		
		CS_mock_SalesOrderScheduleBatch batch = new CS_mock_SalesOrderScheduleBatch();
		batch.salesOrderScheduleBatches = new List<Sales_Order_Schedule_Batch__mdt> {
			new Sales_Order_Schedule_Batch__mdt(DeveloperName = 'CS_mock_SalesOrderScheduleBatch', Order__c = 1),
			new Sales_Order_Schedule_Batch__mdt(DeveloperName = 'CS_mock_SalesOrderScheduleBatch', Order__c = 2)
		};
		System.assertEquals('CS_mock_SalesOrderScheduleBatch', batch.getNextBatchName());
		
		Test.stopTest();
	}
	
	/**
	 * Tests startNextBatch no next
	 */
	@IsTest
	private static void test_startNextBatchNoNext() {
		CS_th_Worker.create();
		
		Test.startTest();
		
		CS_mock_SalesOrderScheduleBatch batch = new CS_mock_SalesOrderScheduleBatch();
		System.assertEquals(false, batch.startNextBatch(batch.getNextBatchName()));
		
		Test.stopTest();
	}
	
	/**
	 * Tests startNextBatch
	 */
	@IsTest
	private static void test_startNextBatch() {
		CS_th_Worker.create();
		
		Test.startTest();
		
		CS_mock_SalesOrderScheduleBatch batch = new CS_mock_SalesOrderScheduleBatch();
		batch.salesOrderScheduleBatches = new List<Sales_Order_Schedule_Batch__mdt> {
			new Sales_Order_Schedule_Batch__mdt(DeveloperName = 'CS_mock_SalesOrderScheduleBatch', Order__c = 1),
			new Sales_Order_Schedule_Batch__mdt(DeveloperName = 'CS_mock_SalesOrderScheduleBatch', Order__c = 2)
		};
		System.assertEquals(true, batch.startNextBatch(batch.getNextBatchName()));
		
		Test.stopTest();
	}
	
	/**
	 * Tests escapeString
	 */
	@IsTest
	private static void test_escapeString() {
		CS_th_Worker.create();
		
		Test.startTest();
		
		CS_mock_SalesOrderScheduleBatch batch = new CS_mock_SalesOrderScheduleBatch();
		System.assertEquals('\'Test\'', batch.escapeString('Test'));
		
		Test.stopTest();
	}
}
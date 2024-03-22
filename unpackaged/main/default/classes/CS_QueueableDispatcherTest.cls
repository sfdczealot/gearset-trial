/**
 * @name CS_QueueableDispatcherTest
 * @description Test for CS_QueueableDispatcher
 * @revision
 *
 */
@isTest
public class CS_QueueableDispatcherTest {
	/**
	 * Tests getting queue size
	 */
	@isTest
	public static void test_getQueueSize() {
		CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();
		
		Test.startTest();
		
		System.assertEquals(0, dispatcher.getQueueSize());
		
		CS_mock_QueueableWorker worker = new CS_mock_QueueableWorker(null);
		dispatcher.addWorker(worker);
		System.assertEquals(1, dispatcher.getQueueSize());

		Test.stopTest();
	}
	
	/**
	 * Tests adding multiple workers
	 */
	@isTest
	public static void test_addWorkerMultiple() {
		CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();
		List<CS_mock_QueueableWorker> workers = new List<CS_mock_QueueableWorker>();
		for(Integer i = 0; i < 5; i++) {
			workers.add(new CS_mock_QueueableWorker(null));
		}
		
		Test.startTest();
		
		for(CS_mock_QueueableWorker worker : workers) {
			dispatcher.addWorker(worker);
		}
		
		System.assertEquals(5, dispatcher.getQueueSize());
		System.assertEquals(workers.get(4), dispatcher.workers.get(3).nextWorker);

		Test.stopTest();
	}
	
	/**
	 * Tests dispatching
	 */
	@isTest
	public static void test_dispatch() {
		CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();
		CS_mock_QueueableWorker worker = new CS_mock_QueueableWorker(null);
		dispatcher.addWorker(worker);
		
		Test.startTest();
		
		dispatcher.dispatch();

		Test.stopTest();
		
    	List<AsyncApexJob> jobs = [SELECT
    									Id, Status, JobType
    							   FROM
    									AsyncApexJob
    							   WHERE
    									JobType = :CS_const_ApexJob.JobType_Queueable];
    	System.assert(!jobs.isEmpty());
    	System.assertEquals(CS_const_ApexJob.Status_Completed, jobs.get(0).Status);
	}
}
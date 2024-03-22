/**
 * @name CS_CS_QueueableWorkerTest
 * @description Test for CS_QueueableWorker class
 * @revision
 *
 */
@isTest
public class CS_QueueableWorkerTest {
	/**
	 * Tests execute method
	 */
    @isTest
    public static void test_execute() {
		List<Account> accounts = new List<Account>();
		for(Integer i = 0; i < 5; i++) {
    		accounts.add(CS_th_Account.create('Test', false));
    	}
    	insert accounts;

    	Test.startTest();

    	CS_mock_QueueableWorker worker = new CS_mock_QueueableWorker(accounts);
    	
    	System.enqueueJob(worker);

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
    
	/**
	 * Tests setting next worker
	 */
    @isTest
    public static void test_executeTwoWorkers() {
		List<Account> accounts = new List<Account>();
		for(Integer i = 0; i < 5; i++) {
    		accounts.add(CS_th_Account.create('Test', false));
    	}
    	insert accounts;

    	Test.startTest();

    	CS_mock_QueueableWorker workerParent = new CS_mock_QueueableWorker(accounts);
    	CS_mock_QueueableWorker workerChild = new CS_mock_QueueableWorker(accounts);
    	workerParent.setNextWorker(workerChild);
    	
    	System.assertEquals(workerChild, workerParent.nextWorker);

    	Test.stopTest();
    }

	/**
	 * Tests execute method
	 */
    @isTest
    public static void test_executeException() {
    	Worker__c setting = CS_th_Worker.create(1, 200, 20, null, null, CS_const_ApexJob.JobType_Queueable, CS_const_ApexJob.JobType_Queueable, true);
		List<Account> accounts = new List<Account>();
		for(Integer i = 0; i < 1; i++) {
    		accounts.add(CS_th_Account.create('Test', false));
    	}
    	insert accounts;

    	Test.startTest();

    	CS_mock_QueueableWorker worker = new CS_mock_QueueableWorker(accounts);
    	System.enqueueJob(worker);

    	Test.stopTest();

    	List<AsyncApexJob> jobs = [SELECT
    									Id, Status, JobType
    							   FROM
    									AsyncApexJob
    							   WHERE
    									JobType = :CS_const_ApexJob.JobType_Queueable];
    	System.assert(!jobs.isEmpty());
    	System.assertEquals(CS_const_ApexJob.Status_Completed, jobs.get(0).Status);

    	List<Log__c> logs = [SELECT
    							Id, Success__c
    						 FROM
    						 	Log__c];
    	System.assert(!logs.isEmpty());
    	System.assert(!logs.get(0).Success__c);
    }
}
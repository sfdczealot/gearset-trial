/**
 * @name CS_ScheduledWorkerTest
 * @description Test for CS_ScheduledWorker class
 * @revision
 *
 */
@isTest
public class CS_ScheduledWorkerTest {
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

    	CS_mock_ScheduledWorker worker = new CS_mock_ScheduledWorker();
    	
    	String jobId = System.schedule('TestProcess', CS_utl_Cron.getCron(System.now().addMinutes(1)), worker);

    	Test.stopTest();

    	CronTrigger ct = [SELECT
    						Id, CronExpression, TimesTriggered, NextFireTime
    					  FROM
    					  	CronTrigger
    					  WHERE
    					  	Id = :jobId];
    	System.assertEquals(0, ct.TimesTriggered);
    }

	/**
	 * Tests execute method
	 */
    @isTest
    public static void test_executeException() {
    	Worker__c setting = CS_th_Worker.create(1, 200, 20, null, null, CS_const_ApexJob.JobType_ScheduledApex, CS_const_ApexJob.JobType_ScheduledApex, true);
		List<Account> accounts = new List<Account>();
		for(Integer i = 0; i < 1; i++) {
    		accounts.add(CS_th_Account.create('Test', false));
    	}
    	insert accounts;

    	Test.startTest();

    	CS_mock_ScheduledWorker worker = new CS_mock_ScheduledWorker();
    	
    	String jobId = System.schedule('TestProcess', CS_utl_Cron.getCron(System.now().addMinutes(1)), worker);

    	Test.stopTest();

    	CronTrigger ct = [SELECT
    						Id, CronExpression, TimesTriggered, NextFireTime
    					  FROM
    					  	CronTrigger
    					  WHERE
    					  	Id = :jobId];
    	System.assertEquals(0, ct.TimesTriggered);

    	List<Log__c> logs = [SELECT
    							Id, Success__c
    						 FROM
    						 	Log__c];
    	System.assert(!logs.isEmpty());
    	System.assert(!logs.get(0).Success__c);
    }
}
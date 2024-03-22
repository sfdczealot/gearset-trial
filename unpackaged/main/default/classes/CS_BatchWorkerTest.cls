/**
 * @name CS_BatchWorkerTest
 * @description Test for CS_BatchWorker class
 * @revision
 *
 */
@isTest
public class CS_BatchWorkerTest {
    /**
     * Tests execute method
     */
    @isTest
    public static void test_execute() {
        Worker__c setting = CS_th_Worker.create(1, 200, 20, null, null, CS_const_ApexJob.JobType_BatchApex, CS_const_ApexJob.JobType_BatchApex, true);
        
        List<Account> accounts = new List<Account>();
        accounts.addAll(CS_th_Account.createMultiple('Test', false, 5));
        insert accounts;

        Test.startTest();

        CS_mock_BatchWorker worker = new CS_mock_BatchWorker(10);
        worker.execute();

        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT
                                        Id, Status, JobType
                                   FROM
                                        AsyncApexJob
                                   WHERE
                                        JobType = :CS_const_ApexJob.JobType_BatchApex];
        System.assert(!jobs.isEmpty());
        System.assertEquals(CS_const_ApexJob.Status_Completed, jobs.get(0).Status);

        List<Log__c> logs = [SELECT
                                Id, Success__c
                             FROM
                                Log__c];
        System.assert(!logs.isEmpty());
        System.assert(logs.get(0).Success__c);
    }

    /**
     * Tests execute method, with maximum number of batches already present in the system
     */
    @isTest
    public static void test_executeMaximumBatches() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        Test.startTest();
        Worker__c setting = CS_th_Worker.create(1, 10, 20, null, null, CS_const_ApexJob.JobType_BatchApex, CS_const_ApexJob.JobType_BatchApex, true);
        List<Account> accounts = new List<Account>();
        accounts.addAll(CS_th_Account.createMultiple('Test', false, 6));
        insert accounts;

        for(Integer i = 0; i < 5; i++) {
            CS_mock_BatchWorker CS_BatchWorkerQueue = new CS_mock_BatchWorker();
            Database.executeBatch(CS_BatchWorkerQueue, setting.Batch_Size_Limit__c.intValue());
        }

        CS_mock_BatchWorker worker = new CS_mock_BatchWorker();
        Id cronTriggerId = worker.execute();

        List<CronTrigger> triggers = [SELECT
                                        Id, State, CronExpression, TimesTriggered
                                     FROM
                                        CronTrigger
                                     WHERE
                                        Id = :cronTriggerId];
        System.assert(!triggers.isEmpty());
        System.assertEquals(0, triggers.get(0).TimesTriggered);

        Test.stopTest();
    }

    /**
     * Tests execute method, exception thrown
     */
    @isTest
    public static void test_executeException() {
        Worker__c setting = CS_th_Worker.create(1, 200, 20, null, null, CS_const_ApexJob.JobType_BatchApex, CS_const_ApexJob.JobType_BatchApex, true);
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < 1; i++) {
            accounts.add(CS_th_Account.create('Test', false));
        }
        insert accounts;

        Test.startTest();

        CS_mock_BatchWorker worker = new CS_mock_BatchWorker();
        worker.execute();

        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT
                                        Id, Status, JobType
                                   FROM
                                        AsyncApexJob
                                   WHERE
                                        JobType = :CS_const_ApexJob.JobType_BatchApex];
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
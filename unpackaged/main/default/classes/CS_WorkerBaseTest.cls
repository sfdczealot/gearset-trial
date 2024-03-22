/**
 * @name CS_WorkerBaseTest
 * @description Test for WorkerBase
 * @revision
 *
 */
@isTest
public class CS_WorkerBaseTest {
    /**
     * Tests getting message
     */
    @isTest
    public static void test_getMessage() {
        CS_mock_WorkerBase worker = new CS_mock_WorkerBase();
        
        Test.startTest();

        System.assertEquals('TestMessage', worker.getMessage());

        Test.stopTest();
    }
    
    /**
     * Tests getting job type
     */
    @isTest
    public static void test_getJobType() {
        CS_mock_WorkerBase worker = new CS_mock_WorkerBase();
        
        Test.startTest();

        System.assertEquals('CS_mock_WorkerBase', worker.getJobType());

        Test.stopTest();
    }
    
    /**
     * Tests getting job id
     */
    @isTest
    public static void test_getJobId() {
        CS_mock_WorkerBase worker = new CS_mock_WorkerBase();
        
        Test.startTest();

        System.assertNotEquals(null, worker.getJobId());

        Test.stopTest();
    }
    
    /**
     * Tests stopping job
     */
    @isTest
    public static void test_stopJob() {
        Boolean exceptionThrown = false;
        CS_mock_WorkerBase worker = new CS_mock_WorkerBase();
        
        Test.startTest();
        
        try {
            worker.stopJob();
        }
        catch(System.StringException e) {
            exceptionThrown = true;
            System.assertEquals('Only CronTrigger IDs and batch, future, and queueable job IDs are supported.', e.getMessage());
            
        }
        
        System.assert(exceptionThrown);

        Test.stopTest();
    }

    /**
     * Tests saving log
     */
    @isTest
    public static void test_saveLog() {
        Worker__c settings = CS_th_Worker.create(5, 2000, 10, null, null, 'CS_mock_WorkerBase', 'CS_mock_WorkerBase', true);
        CS_mock_WorkerBase worker = new CS_mock_WorkerBase();
        
        Test.startTest();
        
        worker.saveLog();
        
        List<Log__c> logs = [SELECT
                                Id, Success__c
                             FROM
                                Log__c];
        System.assert(!logs.isEmpty());
        System.assert(logs.get(0).Success__c);

        Test.stopTest();
    }
    
    /**
     * Tests saving log on error, success
     */
    @isTest
    public static void test_saveLogOnErrorSuccess() {
        Worker__c settings = CS_th_Worker.create(5, 2000, 10, null, null, null, 'CS_mock_WorkerBase', true);
        CS_mock_WorkerBase worker = new CS_mock_WorkerBase();
        
        Test.startTest();
        
        worker.saveLog();
        
        List<Log__c> logs = [SELECT
                                Id, Success__c
                             FROM
                                Log__c];
        System.assert(logs.isEmpty());

        Test.stopTest();
    }
    
    /**
     * Tests saving log on error, fail
     */
    @isTest
    public static void test_saveLogOnErrorFail() {
        Worker__c settings = CS_th_Worker.create(5, 2000, 10, null, null, null, 'CS_mock_WorkerBase', true);
        CS_mock_WorkerBase worker = new CS_mock_WorkerBase();
        
        Test.startTest();
        
        worker.setSuccess(false);
        
        worker.saveLog();
        
        List<Log__c> logs = [SELECT
                                Id, Success__c
                             FROM
                                Log__c];
        System.assert(!logs.isEmpty());
        System.assert(!logs.get(0).Success__c);

        Test.stopTest();
    }
    
    /**
     * Tests saving log, no log
     */
    @isTest
    public static void test_saveLogNoLog() {
        Worker__c settings = CS_th_Worker.create();
        CS_mock_WorkerBase worker = new CS_mock_WorkerBase();
        
        Test.startTest();
        
        worker.saveLog();
        
        List<Log__c> logs = [SELECT
                                Id, Success__c
                             FROM
                                Log__c];
        System.assert(logs.isEmpty());

        Test.stopTest();
    }
    
    /**
     * Tests sending email
     */
    @isTest
    public static void test_sendEmail() {
        Worker__c settings = CS_th_Worker.create(5, 2000, 10, 'CS_mock_WorkerBase', 'CS_mock_WorkerBase', null, null, true);
        CS_mock_WorkerBase worker = new CS_mock_WorkerBase();
        
        Test.startTest();
        
        Integer emailLimits = Limits.getEmailInvocations();
        
        worker.sendEmail();
        
        System.assertNotEquals(emailLimits, Limits.getEmailInvocations());

        Test.stopTest();
    }
    
    /**
     * Tests sending email on error, success
     */
    @isTest
    public static void test_sendEmailOnErrorSuccess() {
        Worker__c settings = CS_th_Worker.create(5, 2000, 10, null, 'CS_mock_WorkerBase', null, null, true);
        CS_mock_WorkerBase worker = new CS_mock_WorkerBase();
        
        Test.startTest();
        
        Integer emailLimits = Limits.getEmailInvocations();
        
        worker.sendEmail();
        
        System.assertEquals(emailLimits, Limits.getEmailInvocations());

        Test.stopTest();
    }
    
    /**
     * Tests sending email on error, fail
     */
    @isTest
    public static void test_sendEmailOnErrorFail() {
        Worker__c settings = CS_th_Worker.create(5, 2000, 10, null, 'CS_mock_WorkerBase', null, null, true);
        CS_mock_WorkerBase worker = new CS_mock_WorkerBase();
        
        Test.startTest();
        
        worker.setSuccess(false);
        
        Integer emailLimits = Limits.getEmailInvocations();
        
        worker.sendEmail();
        
        System.assertNotEquals(emailLimits, Limits.getEmailInvocations());

        Test.stopTest();
    }
    
    /**
     * Tests sending email, no email
     */
    @isTest
    public static void test_sendEmailNoEmail() {
        Worker__c settings = CS_th_Worker.create();
        CS_mock_WorkerBase worker = new CS_mock_WorkerBase();
        
        Test.startTest();
            
        Integer emailLimits = Limits.getEmailInvocations();
        
        worker.sendEmail();
        
        System.assertEquals(emailLimits, Limits.getEmailInvocations());

        Test.stopTest();
    }           
}
/**
 * @name CS_LogWorkerTest
 * @description Test for CS_LogWorker class
 * @revision
 *
 */
@isTest
public class CS_LogWorkerTest {
    /**
     * Tests getInstance method
     */
    @isTest
    public static void test_getInstance() {
        Test.startTest();

        CS_LogWorker log = CS_LogWorker.getInstance();
        System.assertNotEquals(null, log);
        System.assertEquals(log, CS_LogWorker.getInstance());

        Test.stopTest();
    }

    /**
     * Tests setInstance method
     */
    @isTest
    public static void test_setInstance() {
        CS_LogWorker log = CS_LogWorker.getInstance();
        CS_LogWorker.instance = null;

        Test.startTest();

        CS_LogWorker.setInstance(log);

        System.assertEquals(log, CS_LogWorker.getInstance());

        Test.stopTest();
    }
    
    /**
     * Tests getLog method
     */
    @isTest
    public static void test_getLog() {
        Test.startTest();

        CS_LogWorker log = CS_LogWorker.getInstance();
        System.assertNotEquals(null, log.getLog());

        Test.stopTest();
    }

    /**
     * Tests setStartTime method
     */
    @isTest
    public static void test_setStartTime() {
        Datetime startTime;
        
        Test.startTest();

        CS_LogWorker log = CS_LogWorker.getInstance();
        startTime = log.log.Start_Time__c;

        System.assertEquals(Date.today(), Date.newinstance(startTime.year(), startTime.month(), startTime.day()));

        log.setStartTime(Datetime.now().addDays(5));
        startTime = log.log.Start_Time__c;
        System.assertEquals(Date.today().addDays(5), Date.newinstance(startTime.year(), startTime.month(), startTime.day()));

        Test.stopTest();
    }

    /**
     * Tests addErrorMessage, using Exception
     */
    @isTest
    public static void test_addErrorMessageException() {
        Account account = CS_th_Account.create('Test');
        account.Id = CS_utl_Id.getFakeId(Account.getSObjectType());

        CS_LogWorker log = CS_LogWorker.getInstance();

        Test.startTest();

        try {
            update account;
            System.assert(false, 'Expected Exception to be thrown.');
        }
        catch(Exception e) {
            log.addMessage(e);
            System.assert(!log.logMessages.isEmpty(), 'Expected one error message.');
            System.assertEquals(e.getMessage(), log.logMessages.get(0).Message__c);
            System.assertEquals(e.getTypeName(), log.logMessages.get(0).Status_Code__c);
            System.assertEquals(e.getStackTraceString(), log.logMessages.get(0).Stack_Trace__c);
            System.assertEquals(CS_const_LogMessage.Type_Error, log.logMessages.get(0).Type__c);
        }

        Test.stopTest();        
    }

    /**
     * Tests addErrorMessage, using Database.SaveResult
     */
    @isTest
    public static void test_addErrorMessageSaveResult() {
        Account account = CS_th_Account.create('Test');
        account.Id = CS_utl_Id.getFakeId(Account.getSObjectType());

        CS_LogWorker log = CS_LogWorker.getInstance();

        Test.startTest();

        Database.SaveResult result = Database.update(account, false);
        log.addMessage(account, result);

        System.assert(!log.logMessages.isEmpty(), 'Expected one error message.');
        System.assertEquals(account.Id, log.logMessages.get(0).Record_Id__c);
        System.assertEquals(result.getErrors().get(0).getMessage(), log.logMessages.get(0).Message__c);
        System.assertEquals(String.valueOf(result.getErrors().get(0).getStatusCode()),
                            log.logMessages.get(0).Status_Code__c);
        System.assertEquals(CS_const_LogMessage.Type_Error, log.logMessages.get(0).Type__c);
        
        Test.stopTest();
    }

    /**
     * Tests addErrorMessage, using Database.DeleteResult
     */
    @isTest
    public static void test_addErrorMessageDeleteResult() {
        Account account = CS_th_Account.create('Test');
        account.Id = CS_utl_Id.getFakeId(Account.getSObjectType());

        CS_LogWorker log = CS_LogWorker.getInstance();

        Test.startTest();

        Database.DeleteResult result = Database.delete(account, false);
        log.addMessage(account, result);

        System.assert(!log.logMessages.isEmpty(), 'Expected one error message.');
        System.assertEquals(result.getId(), log.logMessages.get(0).Record_Id__c);
        System.assertEquals(result.getErrors().get(0).getMessage(), log.logMessages.get(0).Message__c);
        System.assertEquals(String.valueOf(result.getErrors().get(0).getStatusCode()),
                            log.logMessages.get(0).Status_Code__c);
        System.assertEquals(CS_const_LogMessage.Type_Error, log.logMessages.get(0).Type__c);
        
        Test.stopTest();
    }

    /**
     * Tests addErrorMessage method, using Strings
     */
    @isTest
    public static void test_addErrorMessage() {
        CS_LogWorker log = CS_LogWorker.getInstance();

        Test.startTest();

        log.addMessage('TestRecordId', 'TestMessage', 'TestCode', CS_const_LogMessage.Type_Error);

        System.assert(!log.logMessages.isEmpty(), 'Expected one error message.');
        System.assertEquals('TestRecordId', log.logMessages.get(0).Record_Id__c);
        System.assertEquals('TestMessage', log.logMessages.get(0).Message__c);
        System.assertEquals('TestCode', log.logMessages.get(0).Status_Code__c);
        System.assertEquals(CS_const_LogMessage.Type_Error, log.logMessages.get(0).Type__c);

        log.logMessages = new List<Log_Message__c>();
        System.assert(log.logMessages.isEmpty());

        log.addMessage('TestRecordId', 'TestMessage', 'TestCode', CS_const_LogMessage.Type_Error, 'TestStackTrace');

        System.assert(!log.logMessages.isEmpty(), 'Expected one error message.');
        System.assertEquals('TestRecordId', log.logMessages.get(0).Record_Id__c);
        System.assertEquals('TestMessage', log.logMessages.get(0).Message__c);
        System.assertEquals('TestCode', log.logMessages.get(0).Status_Code__c);
        System.assertEquals('TestStackTrace', log.logMessages.get(0).Stack_Trace__c);
        System.assertEquals(CS_const_LogMessage.Type_Error, log.logMessages.get(0).Type__c);
        
        Test.stopTest();
    }
    
    /**
     * Tests adding attachment
     */
    @isTest
    public static void test_addAttachment() {
        CS_LogWorker log = CS_LogWorker.getInstance();

        Test.startTest();

        log.addAttachment('TestAttachment', Blob.valueOf('TestAttachmentBody'), CS_const_Http.Content_Type_Application_Json);

        System.assert(!log.attachments.isEmpty(), 'Expected one error message.');
        System.assertEquals('TestAttachment', log.attachments.get(0).Name);
        System.assertEquals(CS_const_Http.Content_Type_Application_Json, log.attachments.get(0).ContentType);
        
        Test.stopTest();
    }

    /**
     * Tests saveCS_LogWorker method, no errors
     */
    @isTest
    public static void test_saveCS_LogWorkerNoErrors() {
        CS_LogWorker log = CS_LogWorker.getInstance();

        Test.startTest();

        log.save('TestProcess', 'TestJobType', 'TestId', true);

        List<Log__c> logs = [SELECT
                                Id, Job_Id__c, Process_Name__c, Job_Type__c
                             FROM
                                Log__c];
        System.assertEquals(1, logs.size(), 'Only 1 CS_LogWorker record expected.');
        System.assertEquals('TestId', logs.get(0).Job_Id__c);
        System.assertEquals('TestJobType', logs.get(0).Job_Type__c);
        System.assertEquals('TestProcess', logs.get(0).Process_Name__c);

        Test.stopTest();
    }

    /**
     * Tests saveCS_LogWorker method, with errors
     */
    @isTest
    public static void test_saveCS_LogWorkerWithErrors() {
        CS_LogWorker log = CS_LogWorker.getInstance();
        log.addMessage('TestRecordId', 'TestMessage', 'TestCode', CS_const_LogMessage.Type_Error);

        Test.startTest();

        log.save('TestProcess','TestJobType', 'TestId', false);

        List<Log__c> logs = [SELECT
                                Id, Job_Id__c, Process_Name__c, Job_Type__c
                             FROM
                                Log__c];
        System.assertEquals(1, logs.size(), 'Only 1 CS_LogWorker record expected.');
        System.assertEquals('TestId', logs.get(0).Job_Id__c);
        System.assertEquals('TestJobType', logs.get(0).Job_Type__c);
        System.assertEquals('TestProcess', logs.get(0).Process_Name__c);

        List<Log_Message__c> messages = [SELECT
                                            Id, Record_Id__c, Message__c
                                         FROM
                                            Log_Message__c];
        System.assertEquals(1, messages.size(), 'Only 1 CS_LogWorker Error Message record expected.');
        System.assertEquals('TestRecordId', messages.get(0).Record_Id__c);
        System.assertEquals('TestMessage', messages.get(0).Message__c);

        Test.stopTest();
    }
    
    /**
     * Tests saveCS_LogWorker method, with attachments
     */
    @isTest
    public static void test_saveCS_LogWorkerWithAttachments() {
        CS_LogWorker log = CS_LogWorker.getInstance();
        log.addAttachment('TestAttachment', Blob.valueOf('TestAttachmentBody'), CS_const_Http.Content_Type_Application_Json);

        Test.startTest();

        log.save('TestProcess','TestJobType', 'TestId', false);

        List<Log__c> logs = [SELECT
                                Id, Job_Id__c, Process_Name__c, Job_Type__c
                             FROM
                                Log__c];
        System.assertEquals(1, logs.size(), 'Only 1 CS_LogWorker record expected.');
        System.assertEquals('TestId', logs.get(0).Job_Id__c);
        System.assertEquals('TestJobType', logs.get(0).Job_Type__c);
        System.assertEquals('TestProcess', logs.get(0).Process_Name__c);

        List<Attachment> attachments = [SELECT
                                            Id, Name, ContentType, ParentId
                                         FROM
                                            Attachment
                                         WHERE
                                            ParentId = :logs.get(0).Id];
        System.assert(!attachments.isEmpty(), 'Expected one error message.');
        System.assertEquals('TestAttachment', attachments.get(0).Name);
        System.assertEquals(CS_const_Http.Content_Type_Application_Json, attachments.get(0).ContentType);

        Test.stopTest();
    }

    /**
     * Tests sendEmail method
     */
    @isTest
    public static void test_sendEmail() {
        CS_LogWorker log = CS_LogWorker.getInstance();
        log.addMessage('TestRecordId', 'TestMessage', 'TestCode', CS_const_LogMessage.Type_Error);

        Test.startTest();

        List<Messaging.SendEmailResult> results = log.sendEmail();
        System.assert(!results.isEmpty());
        System.assert(results.get(0).success);

        Test.stopTest();
    }

    /**
     * Tests formatMessage method
     */
    @isTest
    public static void test_formatMessage() {
        CS_LogWorker log = CS_LogWorker.getInstance();
        String message;
        
        Test.startTest();

        message = log.formatMessage(log.message, 'TestProcess', 'TestJobType', false, 'TestAppend');
        System.assert(message.contains('failed'));
        System.assert(message.endsWith('TestAppend'));

        message = log.formatMessage(log.message, 'TestProcess', 'TestJobType', true, 'TestAppend');
        System.assert(message.contains('completed successfully'));
        System.assert(message.endsWith('TestAppend'));

        Test.stopTest();
    }
}
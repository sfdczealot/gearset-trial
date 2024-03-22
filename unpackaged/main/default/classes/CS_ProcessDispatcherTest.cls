/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for CS_ProcessDispatcher
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ivan Ravnjak   <ivan.ravnjak@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest

public class CS_ProcessDispatcherTest {
	/**
	 * Test constructor out of trigger context
	 */
	@isTest
    public static void test_outOfTriggerConstructor() {
    	Test.startTest();

        try {
            new CS_ProcessDispatcher();
            System.assert(false, 'Expected exception to be thrown.');
        } 
        catch(CS_ProcessDispatcher.CS_ProcessDispatcherException e) {
            System.assertEquals(e.getMessage(), 'This CS_ProcessDispatcher constructor is invalid when not in the context of a trigger.');
        }

        Test.stopTest();
    }

    /**
     * Test addProcess method
     */
    @isTest
    public static void test_addProcess() {
    	Test.startTest();

        System.assertEquals(1, new CS_ProcessDispatcher(null,null,null,null,null,null,null,null,null).
        					addProcess(new CS_ProcessBaseTest.TestProcess()).processes.size());

        Test.stopTest();
    }

    /**
     * Test addProcess method, should not add ineligable process
     */
    @isTest
    public static void test_addIneligableProcess() {
    	Test.startTest();

        CS_ProcessBase p = new CS_ProcessBaseTest.TestProcess();

        //th_ProcessDeactivation.create(ProcessDefinition.UNIT_TEST_PROCESS.name(), UserInfo.getUserId()); 
        Process_Deactivation__c processDeactivation = Process_Deactivation__c.getInstance();

        if(processDeactivation == null) {
            processDeactivation = new Process_Deactivation__c();
            processDeactivation.Active__c = true;
            processDeactivation.Processes__c = CS_ProcessDefinition.UNIT_TEST_PROCESS.name();
            processDeactivation.SetupOwnerId = UserInfo.getUserId();
        }
        else {
        	processDeactivation.Active__c = true;
        	processDeactivation.Processes__c = CS_ProcessDefinition.UNIT_TEST_PROCESS.name();
        }

        upsert processDeactivation;

        System.assertEquals(0, new CS_ProcessDispatcher(null,null,null,null,null,null,null,null,null).
        					addProcess(p).processes.size(),
            				'The deactivated process should not be added to the operations list.');

        Test.stopTest();
    }

    /**
     * Test addProcesses method
     */
    @isTest
    public static void test_addProcesses() {
    	Test.startTest();

        System.assertEquals(4, new CS_ProcessDispatcher(null,null,null,null,null,null,null,null,null).
        					addProcesses(new List<CS_ProcessBase>{
        						new CS_ProcessBaseTest.TestProcess(), new CS_ProcessBaseTest.TestProcess(),
        						new CS_ProcessBaseTest.TestProcess(), new CS_ProcessBaseTest.TestProcess()}).processes.size());

        Test.stopTest();
    }

    /**
     * Test dispatch method, should call isRecordEligible only once
     */
    @isTest
    public static void test_dispatchIsRecordEligibleOnceForEachRecord () {
    	Test.startTest();

        CS_ProcessBaseTest.TestProcess p = new CS_ProcessBaseTest.TestProcess();
        new CS_ProcessDispatcher(new List<Account>{new Account(), new Account(), new Account()},
        					  null, null, null, true, false, true, false, false).addProcess(p).dispatch();
        
        System.assertEquals(3, p.numberOfTimesTestWasCalled);

        Test.stopTest();
    }

    /**
     * Test dispatch method, should call logic only once
     */
    public static void test_dispatchLogicOnceInTotal () {
    	Test.startTest();

        CS_ProcessBaseTest.TestProcess p = new CS_ProcessBaseTest.TestProcess();
        new CS_ProcessDispatcher(new Account[]{new Account(), new Account()},
        					  null, null, null, true, false, true, false, false).addProcess(p).dispatch();
        
        System.assertEquals(1, p.numberOfTimesLogicWasCalled);

        Test.stopTest();
    }

    /**
     * Test dispatch method, should iterate old objects on delete
     */
    @isTest
    public static void test_dispatchIterateOldObjectsOnDelete () {
    	Test.startTest();

        CS_ProcessBaseTest.TestProcess p = new CS_ProcessBaseTest.TestProcess();
        new CS_ProcessDispatcher(null, null, new Account[]{new Account(), new Account()},
        					  null, true, false, false, true, false).addProcess(p).dispatch();
        
        System.assertEquals(2, p.numberOfTimesTestWasCalled);

        Test.stopTest();
    }
}
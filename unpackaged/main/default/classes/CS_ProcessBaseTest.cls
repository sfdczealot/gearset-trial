/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for CS_ProcessBase
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ivan Ravnjak   <ivan.ravnjak@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class CS_ProcessBaseTest {
    public static Boolean ThrowException = false;

/*------------------------------------------------------------
Author:        Sasa Marjancic
Company:       CloudSense
Description:   inner class which extends the abstract 
               CS_ProcessBase class
     
History               
<Date>       <Authors Name>      <Brief Description of Change>
03-Dec-15     Sasa Marjancic      Created the inner class

07-Mar-16     Mamta Chintalapudi Changed the parameter passed 
                                 to runAsync method by sending 
                                 the inner class by calling 
                                 the outer class.inner class
------------------------------------------------------------*/
    public class TestProcess extends CS_ProcessBase { 
    	public TestProcess() {
    		super(CS_ProcessDefinition.UNIT_TEST_PROCESS, 'CS_ProcessBaseTest.TestProcess');
    		this.applicableObjectIds = new Set<Id>();
    	}
        

    	public TestProcess(Boolean runAsync) {
    		super(CS_ProcessDefinition.UNIT_TEST_PROCESS, 'CS_ProcessBaseTest.TestProcess', true);
    		this.applicableObjectIds = new Set<Id>();
    	}

        public Integer numberOfTimesLogicWasCalled = 0;
        public Integer numberOfTimesTestWasCalled = 0;
        
        protected override void logic() {
            numberOfTimesLogicWasCalled++;
            if(ThrowException) {
                throw new TestProcessException();
            }
        }
        
        public override void isRecordEligible(SObject obj) {
        	this.runProcess = true;
            numberOfTimesTestWasCalled++;
        }
    }

    public class TestProcessException extends Exception {}

    /**
     * Tests isEnabledForMe method
     */
    @isTest
    public static void test_isEnabledForMe() {
        CS_ProcessBase p = new TestProcess();

        //th_ProcessDeactivation.create(CS_ProcessDefinition.UNIT_TEST_PROCESS.name(), UserInfo.getUserId());
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
        
        System.assert(!p.isEnabledForMe(),'The process should be deactivated');
    }
    
    /**
     * Tests execute method
     */
    @isTest
    public static void test_execute() {
        TestProcess p = new TestProcess();

        Test.startTest();

        p.isRecordEligible(null);
        p.execute();

        Test.stopTest();

        System.assertEquals(1, p.numberOfTimesLogicWasCalled);
        System.assert(CS_ProcessExecution.wasProcessExecuted(p.processName));
    }

    /**
     * Tests execute method async
     */
    @isTest
    public static void test_executeAsync() {
        TestProcess p = new TestProcess(true);

        Test.startTest();

        p.isRecordEligible(null);
        p.execute();

        Test.stopTest();

        System.assert(CS_ProcessExecution.wasProcessExecuted(p.processName));
    }

    /**
     * Tests execute method async
     */
    @isTest
    public static void test_executeAsyncException() {
        ThrowException = true;
        TestProcess p = new TestProcess(true);

        Test.startTest();

        p.isRecordEligible(null);
        p.execute();

        Test.stopTest();

        System.assert(CS_ProcessExecution.wasProcessExecuted(p.processName));
    }
}
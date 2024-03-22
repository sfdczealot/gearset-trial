/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for CS_ProcessExecution
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ivan Ravnjak   <ivan.ravnjak@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public with sharing class CS_ProcessExecutionTest {
    /**
     * Test addProcess method
     */
     
    @isTest
    public static void test_addProcess() {
    	Test.startTest();

    	CS_ProcessExecution.addProcess(CS_ProcessDefinition.UNIT_TEST_PROCESS);

    	System.assert(CS_ProcessExecution.processesExecuted.contains(CS_ProcessDefinition.UNIT_TEST_PROCESS));

    	Test.stopTest();
    }


    /**
     * Test wasProcessExecuted method
     */
    @isTest
    public static void test_wasProcessExecuted() {
    	Test.startTest();

    	System.assert(!CS_ProcessExecution.wasProcessExecuted(CS_ProcessDefinition.UNIT_TEST_PROCESS));

    	CS_ProcessExecution.addProcess(CS_ProcessDefinition.UNIT_TEST_PROCESS);
    	System.assert(CS_ProcessExecution.wasProcessExecuted(CS_ProcessDefinition.UNIT_TEST_PROCESS));

    	Test.stopTest();
    }
}
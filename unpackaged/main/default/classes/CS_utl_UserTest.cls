/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for CS_utl_User
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ivan Ravnjak   <ivan.ravnjak@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest

private class CS_utl_UserTest {
    /**
     * Test isTriggerActiveForMe method
     */
    @isTest
    public static void test_isTriggerActiveForMe() {
        Test.startTest();

        System.assert(CS_utl_User.isTriggerActiveForMe());

        CS_utl_User.isTriggerDeactivationEnabledForAllTriggers = true;
        System.assert(!CS_utl_User.isTriggerActiveForMe());

        CS_utl_User.isTriggerDeactivationEnabledForAllTriggers = false;
        System.assert(CS_utl_User.isTriggerActiveForMe());

        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        System.assert(!CS_utl_User.isTriggerActiveForMe());

        CS_utl_User.enableAllTriggers(UserInfo.getUserId());
        System.assert(CS_utl_User.isTriggerActiveForMe());

        Test.stopTest();
    }

    /**
     * Test isProcessActiveForMe method
     */
    @isTest
    public static void test_isProcessActiveForMe() {
        Test.startTest();

        System.assert(CS_utl_User.isProcessActiveForMe(CS_ProcessDefinition.UNIT_TEST_PROCESS));

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
        System.assert(!CS_utl_User.isProcessActiveForMe(CS_ProcessDefinition.UNIT_TEST_PROCESS));

        Process_Deactivation__c processDeactivationAll = Process_Deactivation__c.getInstance();

        if(processDeactivation == null) {
            processDeactivation = new Process_Deactivation__c();
            processDeactivation.Active__c = true;
            processDeactivation.Processes__c = CS_ProcessDefinition.ALL.name();
            processDeactivation.SetupOwnerId = UserInfo.getUserId();
        }
        else {
        	processDeactivation.Active__c = true;
        	processDeactivation.Processes__c = CS_ProcessDefinition.ALL.name();
        }

        upsert processDeactivation;
        System.assert(!CS_utl_User.isProcessActiveForMe(CS_ProcessDefinition.UNIT_TEST_PROCESS));

        Test.stopTest();
    }

    /**
     * Test enableAllTriggers and disableAllTriggers methods
     */
    @isTest
    public static void test_enableDisableAllTriggers() {
        Id userId = UserInfo.getUserId();
        No_Triggers__c noTriggers;

        Test.startTest();
        CS_utl_User.disableAllTriggers(userId);
        noTriggers = No_Triggers__c.getInstance(userId);
        System.assert(noTriggers.Flag__c);

        CS_utl_User.enableAllTriggers(userId);
        noTriggers = No_Triggers__c.getInstance(userId);
        System.assert(!noTriggers.Flag__c);

        CS_utl_User.disableAllTriggers(userId);
        noTriggers = No_Triggers__c.getInstance(userId);
        System.assert(noTriggers.Flag__c);

        Test.stopTest();
    }
    
   
}
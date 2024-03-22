/**
 * Created by jameshladek on 4/9/20.
 */
@IsTest
public with sharing class CS_PostToChatterHandlerTest {

    @TestSetup
    static void setupData() {
        User user = (User) TestFactory.createSObject(new User(), 'TestFactory.UserDefaults');
        user.ProfileId = [SELECT Id FROM Profile WHERE Name = :TestFactory.SYSTEM_ADMIN_PROFILE_NAME][0].Id;
        user.FirstName = 'SpotifyTest';
        user.LastName = 'User1';
        insert user;

        Group testGroup = new Group();
        testGroup.Name = 'Test Group';
        insert testGroup;

        CS_Custom_Settings__c settings = new CS_Custom_Settings__c();
        settings.Integration_Chunk_Size__c = 10.0;
        settings.Integration_Delay_Between_Callouts__c = 300.0;
        insert settings;

        // B2B Account
        Account testAccount = TestDataSetupSO.createB2BAcc();
        insert testAccount;
        
        Account testAccount1 = TestDataSetupSO.createAccount();
        insert testAccount1;
        
        Contact testContact = TestDataSetupSO.createContact(testAccount);
        insert testContact;

        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;
        
        Opportunity testOpportunity = TestDataSetupSO.createOpportunity(testAccount, testContact);
        testOpportunity.Subsidiary_Type__c = '	iPP';
        insert testOpportunity;
/*
        csmso__Sales_Order__c testSalesOrder = TestDataSetupSO.createSalesOrder(testAccount, testOpportunity);
        insert testSalesOrder;
*/
        CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
 //       testProcess.Sales_Order__c = testSalesOrder.Id;
        testProcess.Name = 'Check Availability';
        insert testProcess;

        CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
        testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
        testOrchestrationStep.Chatter_Post_Message__c = 'Generic Message';
        testOrchestrationStep.Chatter_Target__c = 'Sales_Order__c';
        testOrchestrationStep.Add_mentions__c = 'ownerid';
        //testOrchestrationStep.Record_link_field__c = 'csmso__Opportunity__c';
//testOrchestrationStep.Sales_Order__c = testSalesOrder.id;
 //       testOrchestrationStep.CSPOFA__external_id__c = testSalesOrder.Id;
        insert testOrchestrationStep;
    }

    @IsTest
    static void testForNoInputs() {
        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, Sales_Order__c, Chatter_Post_Message__c, Chatter_Target__c, Add_mentions__c, Merge_Field__c,
                        CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name,
                        CSPOFA__Orchestration_Process__r.Sales_Order__r.Owner.Name, Orchestration_Process_Name__c,
                        CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        Test.startTest();
        CS_PostToChatterHandler handler = new CS_PostToChatterHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testForMergeFieldInput() {
        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, Sales_Order__c, Chatter_Post_Message__c, Chatter_Target__c, Add_mentions__c, Merge_Field__c,
                        CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name,
                        CSPOFA__Orchestration_Process__r.Sales_Order__r.Owner.Name, Orchestration_Process_Name__c,
                        CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];
        
        for (CSPOFA__Orchestration_Step__c step : steps) {
            step.Chatter_Post_Message__c = 'Here is a test for SO {0}';
            step.Merge_Field__c = 'Sales_Order__r.Name';
        }
        update steps;

        Test.startTest();
        CS_PostToChatterHandler handler = new CS_PostToChatterHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testTargetBlank() {
        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, Sales_Order__c, Chatter_Post_Message__c, Chatter_Target__c, Add_mentions__c, Merge_Field__c,
                        CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name,
                        CSPOFA__Orchestration_Process__r.Sales_Order__r.Owner.Name, Orchestration_Process_Name__c,
                        CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        for (CSPOFA__Orchestration_Step__c step : steps) {
            step.Chatter_Target__c = '';
        }
        update steps;

        Test.startTest();
        CS_PostToChatterHandler handler = new CS_PostToChatterHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testAddMentionBlank() {
        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, Sales_Order__c, Chatter_Post_Message__c, Chatter_Target__c, Add_mentions__c, Merge_Field__c,
                        CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name,
                        CSPOFA__Orchestration_Process__r.Sales_Order__r.Owner.Name, Orchestration_Process_Name__c,
                        CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        for (CSPOFA__Orchestration_Step__c step : steps) {
            step.Add_mentions__c = '';
        }
        update steps;

        Test.startTest();
        CS_PostToChatterHandler handler = new CS_PostToChatterHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testAddMentionIsUser() {
        User user = (User) TestFactory.createSObject(new User(), 'TestFactory.UserDefaults');
        user.ProfileId = [SELECT Id FROM Profile WHERE Name = :TestFactory.SYSTEM_ADMIN_PROFILE_NAME][0].Id;
        user.FirstName = 'SpotifyTest';
        user.LastName = 'User';
        insert user;

        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, Sales_Order__c, Chatter_Post_Message__c, Chatter_Target__c, Add_mentions__c, Merge_Field__c,
                        CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name,
                        CSPOFA__Orchestration_Process__r.Sales_Order__r.Owner.Name, Orchestration_Process_Name__c,
                        CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        for (CSPOFA__Orchestration_Step__c step : steps) {
            step.Add_mentions__c = 'SpotifyTest User';
        }
        update steps;

        Test.startTest();
        CS_PostToChatterHandler handler = new CS_PostToChatterHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testAddMentionIsGroup() {
        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, Sales_Order__c, Chatter_Post_Message__c, Chatter_Target__c, Add_mentions__c, Merge_Field__c,
                        CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name,
                        CSPOFA__Orchestration_Process__r.Sales_Order__r.Owner.Name, Orchestration_Process_Name__c,
                        CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        for (CSPOFA__Orchestration_Step__c step : steps) {
            step.Add_mentions__c = '(Group) Test Group';
        }
        update steps;

        Test.startTest();
        CS_PostToChatterHandler handler = new CS_PostToChatterHandler();
        handler.process(steps);
        Test.stopTest();
    }
}
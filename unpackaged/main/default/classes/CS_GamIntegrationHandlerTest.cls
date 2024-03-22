/**
 * Created by jameshladek on 3/16/20.
 */
@IsTest
public with sharing class CS_GamIntegrationHandlerTest {

    @TestSetup
    static void setupData() {
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
        
        CS_Custom_Settings__c settings = new CS_Custom_Settings__c();
        settings.Integration_Chunk_Size__c = 10.0;
        settings.Integration_Delay_Between_Callouts__c = 300.0;
        insert settings;

        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_Account').getRecordTypeId();
        Account testAccount = TestDataSetupSO.createAccount();
        testAccount.RecordTypeId = recordTypeId;
        insert testAccount;

        Contact testContact = TestDataSetupSO.createContact(testAccount);
        insert testContact;

        Opportunity testOpportunity = TestDataSetupSO.createOpportunity(testAccount, testContact);
        insert testOpportunity;

        csmso__Sales_Order__c testSalesOrder = TestDataSetupSO.createSalesOrder(testAccount, testOpportunity);
        insert testSalesOrder;

        csdf__Fulfilment__c testFulfilment = [SELECT Id FROM csdf__Fulfilment__c WHERE Sales_Order__c = :testSalesOrder.Id];

        cscfga__Product_Configuration__c testConfiguration = TestDataSetupSO.createproductConfigAndDef('Test Config');
        testConfiguration.Sales_Order__c = testSalesOrder.Id;
        testConfiguration.Ad_Type__c = 'Standard';
        testConfiguration.Insertion_Unit_Type_Display__c = 'CPD';
        testConfiguration.Served_By__c = 'DFP';
        testConfiguration.csmso__Flight_End__c = Date.today().addDays(5);
        testConfiguration.Fulfilment_Item_Status__c = 'Draft';
        update testConfiguration;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(testConfiguration, testSalesOrder, testFulfilment);
        testFulfilmentItem.Product_Configuration__c = testConfiguration.Id;
        testFulfilmentItem.csdf__Availability_Check_Status__c = 'Completed';
        insert testFulfilmentItem;

        CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
        testProcess.Sales_Order__c = testSalesOrder.Id;
        testProcess.Name = 'Check Availability';
        insert testProcess;

        CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
        testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
        insert testOrchestrationStep;
    }

    @IsTest
    static void testForCheckAvails() {
        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        Test.startTest();
        CS_GamIntegrationHandler handler = new CS_GamIntegrationHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testForPushToGam() {
        List<CSPOFA__Orchestration_Process__c> processes = [SELECT Id, Name FROM CSPOFA__Orchestration_Process__c];
        for (CSPOFA__Orchestration_Process__c op : processes) {
            op.Name = 'Push To GAM';
        }
        update processes;

        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        Test.startTest();
        CS_GamIntegrationHandler handler = new CS_GamIntegrationHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testForStatusPushToGam() {
        List<CSPOFA__Orchestration_Process__c> processes = [SELECT Id, Name FROM CSPOFA__Orchestration_Process__c];
        for (CSPOFA__Orchestration_Process__c op : processes) {
            op.Name = 'Status Push to GAM';
        }
        update processes;

        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        Test.startTest();
        CS_GamIntegrationHandler handler = new CS_GamIntegrationHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testForRequestBuyerAssistance() {
        List<CSPOFA__Orchestration_Process__c> processes = [SELECT Id, Name FROM CSPOFA__Orchestration_Process__c];
        for (CSPOFA__Orchestration_Process__c op : processes) {
            op.Name = 'Request Buyer Assistance';
        }
        update processes;

        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        Test.startTest();
        CS_GamIntegrationHandler handler = new CS_GamIntegrationHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testForUpdateOrder() {
        List<CSPOFA__Orchestration_Process__c> processes = [SELECT Id, Name FROM CSPOFA__Orchestration_Process__c];
        for (CSPOFA__Orchestration_Process__c op : processes) {
            op.Name = 'Update Order';
        }
        update processes;

        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        Test.startTest();
        CS_GamIntegrationHandler handler = new CS_GamIntegrationHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testForInventoryReserve() {
        List<CSPOFA__Orchestration_Process__c> processes = [SELECT Id, Name FROM CSPOFA__Orchestration_Process__c];
        for (CSPOFA__Orchestration_Process__c op : processes) {
            op.Name = 'Reserve Inventory';
        }
        update processes;

        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        Test.startTest();
        CS_GamIntegrationHandler handler = new CS_GamIntegrationHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testForInventoryRelease() {
        List<CSPOFA__Orchestration_Process__c> processes = [SELECT Id, Name FROM CSPOFA__Orchestration_Process__c];
        for (CSPOFA__Orchestration_Process__c op : processes) {
            op.Name = 'Inventory Release';
        }
        update processes;

        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        Test.startTest();
        CS_GamIntegrationHandler handler = new CS_GamIntegrationHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testForBadAction() {
        List<CSPOFA__Orchestration_Process__c> processes = [SELECT Id, Name FROM CSPOFA__Orchestration_Process__c];
        for (CSPOFA__Orchestration_Process__c op : processes) {
            op.Name = 'Bad Action';
        }
        update processes;

        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        Test.startTest();
        CS_GamIntegrationHandler handler = new CS_GamIntegrationHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testForNoLinesCheckAvails() {
        cscfga__Product_Configuration__c pc = [SELECT Id, Served_By__c FROM cscfga__Product_Configuration__c LIMIT 1];
        update new cscfga__Product_Configuration__c(Id = pc.Id, Served_By__c = 'Non-Ad Served');

        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        Test.startTest();
        CS_GamIntegrationHandler handler = new CS_GamIntegrationHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testForNoLinesPushToGam() {
        cscfga__Product_Configuration__c pc = [SELECT Id, Served_By__c FROM cscfga__Product_Configuration__c LIMIT 1];
        update new cscfga__Product_Configuration__c(Id = pc.Id, Served_By__c = 'Non-Ad Served');

        List<CSPOFA__Orchestration_Process__c> processes = [SELECT Id, Name FROM CSPOFA__Orchestration_Process__c];
        for (CSPOFA__Orchestration_Process__c op : processes) {
            op.Name = 'Push To GAM';
        }
        update processes;

        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        Test.startTest();
        CS_GamIntegrationHandler handler = new CS_GamIntegrationHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testForNoLinesStatusPushToGam() {
        cscfga__Product_Configuration__c pc = [SELECT Id, Served_By__c FROM cscfga__Product_Configuration__c LIMIT 1];
        update new cscfga__Product_Configuration__c(Id = pc.Id, Served_By__c = 'Non-Ad Served');

        List<CSPOFA__Orchestration_Process__c> processes = [SELECT Id, Name FROM CSPOFA__Orchestration_Process__c];
        for (CSPOFA__Orchestration_Process__c op : processes) {
            op.Name = 'Status Push to GAM';
        }
        update processes;

        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        Test.startTest();
        CS_GamIntegrationHandler handler = new CS_GamIntegrationHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testForNoLinesInventoryRelease() {
        cscfga__Product_Configuration__c pc = [SELECT Id, Served_By__c FROM cscfga__Product_Configuration__c LIMIT 1];
        update new cscfga__Product_Configuration__c(Id = pc.Id, Served_By__c = 'Non-Ad Served');

        List<CSPOFA__Orchestration_Process__c> processes = [SELECT Id, Name FROM CSPOFA__Orchestration_Process__c];
        for (CSPOFA__Orchestration_Process__c op : processes) {
            op.Name = 'Inventory Release';
        }
        update processes;

        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        Test.startTest();
        CS_GamIntegrationHandler handler = new CS_GamIntegrationHandler();
        handler.process(steps);
        Test.stopTest();
    }
}
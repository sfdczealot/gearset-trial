/**
 * Created by jameshladek on 4/28/20.
 */
@IsTest
public with sharing class CS_ValidateSalesOrderHandlerTest {

    @TestSetup
    static void setupData() {
        CS_Custom_Settings__c settings = new CS_Custom_Settings__c();
        settings.Integration_Chunk_Size__c = 10.0;
        settings.Integration_Delay_Between_Callouts__c = 300.0;
        insert settings;

        Account testAccount = TestDataSetupSO.createAccount();
        insert testAccount;

        Contact testContact = TestDataSetupSO.createContact(testAccount);
        insert testContact;

        Opportunity testOpportunity = TestDataSetupSO.createOpportunity(testAccount, testContact);
        insert testOpportunity;

        csmso__Sales_Order__c testSalesOrder = TestDataSetupSO.createSalesOrder(testAccount, testOpportunity);
        testSalesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_FIRST_APPROVAL;
        testSalesOrder.csmso__Opportunity__c = testOpportunity.Id;
        testSalesOrder.SO_Lines_All_Valid__c = true;
        testSalesOrder.Inventory_Approval__c = 'Pending';
        testSalesOrder.Approval_Custom_Button__c = true;
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
        testProcess.Name = 'Validate Sales Order';
        insert testProcess;

        CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
        testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
        insert testOrchestrationStep;

        testOrchestrationStep = [
                SELECT Id, Name, Sales_Order__c, CSPOFA__Orchestration_Process__c
                FROM CSPOFA__Orchestration_Step__c
                LIMIT 1
        ];
    }

    @IsTest
    static void testSuccess() {
        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, CSPOFA__external_id__c, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        for (CSPOFA__Orchestration_Step__c step : steps) {
            step.CSPOFA__Status__c = 'Waiting For Feedback';
            step.CSPOFA__external_id__c = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1].Id;
        }
        update steps;

        steps = [
                SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        Test.startTest();
        CS_ValidateSalesOrderHandler handler = new CS_ValidateSalesOrderHandler();
        handler.process(steps);
        Test.stopTest();

        List<CSPOFA__Orchestration_Step__c> results = [SELECT Id, CSPOFA__external_id__c, CSPOFA__Message__c, CSPOFA__Status__c, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c, Orchestration_Process_Name__c FROM CSPOFA__Orchestration_Step__c];

        System.assertEquals('Waiting For Feedback', results[0].CSPOFA__Status__c);
        System.assertEquals(null, results[0].CSPOFA__Message__c);
    }

    @IsTest
    static void testFailure() {
        cscfga__Product_Configuration__c pc1 = [SELECT Id, Served_By__c, Fulfilment_Item_Status__c, Flight_Begin_Logged_User_Timezone__c FROM cscfga__Product_Configuration__c];
        pc1.Served_By__c = 'DFP';
        pc1.Fulfilment_Item_Status__c = 'Draft';
        pc1.Flight_Begin_Logged_User_Timezone__c = System.now();
        update pc1;

        cscfga__Product_Configuration__c pc = [SELECT Id, Served_By__c, Fulfilment_Item_Status__c FROM cscfga__Product_Configuration__c];
        System.debug(pc.Served_By__c + ' ' + pc.Fulfilment_Item_Status__c);

        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, CSPOFA__external_id__c, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        for (CSPOFA__Orchestration_Step__c step : steps) {
            step.CSPOFA__Status__c = 'Waiting For Feedback';
            step.CSPOFA__external_id__c = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1].Id;
        }
        update steps;

        Test.startTest();
        CS_ValidateSalesOrderHandler handler = new CS_ValidateSalesOrderHandler();
        handler.process(steps);
        Test.stopTest();

        List<CSPOFA__Orchestration_Step__c> results = [
                SELECT Id, CSPOFA__external_id__c, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c, CSPOFA__Orchestration_Step__c.CSPOFA__Message__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        csmso__Sales_Order__c so = [SELECT Id, csmso__Process_Message_Type__c FROM csmso__Sales_Order__c];

        System.assertEquals('information', so.csmso__Process_Message_Type__c);

        System.assertEquals('Waiting For Feedback', results[0].CSPOFA__Status__c);
        System.assertEquals(null, results[0].CSPOFA__Message__c);
    }
}
@IsTest
public with sharing class CS_StepHandlerBaseTest {

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
        insert testSalesOrder;

        List<cscfga__Product_Basket__c> testProductBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
                testSalesOrder
        });

        csdf__Fulfilment__c testFulfilment = [SELECT Id FROM csdf__Fulfilment__c WHERE Sales_Order__c = :testSalesOrder.Id];

        cscfga__Product_Configuration__c testConfiguration = TestDataSetupSO.createproductConfigAndDef('Test Config');
        testConfiguration.Sales_Order__c = testSalesOrder.Id;
        testConfiguration.Ad_Type__c = 'Standard';
        testConfiguration.Insertion_Unit_Type_Display__c = 'CPD';
        testConfiguration.Served_By__c = 'Megaphone';
        testConfiguration.csmso__Flight_End__c = Date.today().addDays(5);
        testConfiguration.Fulfilment_Item_Status__c = 'Draft';
        update testConfiguration;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(testConfiguration, testSalesOrder, testFulfilment);
        testFulfilmentItem.Product_Configuration__c = testConfiguration.Id;
        testFulfilmentItem.csdf__Availability_Check_Status__c = 'Completed';
        insert testFulfilmentItem;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;

        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        testProDef.cscfga__Allow_progress_from_incomplete_screens__c = true;
        insert testProDef;

        cscfga__Configuration_Screen__c screenFlow = TestDataSetupTargetables.createConfigurationScreen(testProDef, 'Default Screen');
        insert screenFlow;

        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        testAttrDef.cscfga__Configuration_Screen__c = screenFlow.Id;
        testAttrDef.cscfga__Column__c = 0;
        testAttrDef.cscfga__Row__c = 0;
        testAttrDef.cscfga__Data_Type__c = 'String';
        testAttrDef.Name = 'Fulfilment Item Status';

        cscfga__Attribute__c attFIStatus = new cscfga__Attribute__c(cscfga__Product_Configuration__c = testConfiguration.Id, Name = 'Fulfilment Item Status', cscfga__Value__c = '10000', cscfga__Attribute_Definition__c = testAttrDef.Id);
        insert attFIStatus;

        CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
        testProcess.Sales_Order__c = testSalesOrder.Id;
        testProcess.Name = 'Fulfilment Start';
        insert testProcess;

        CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
        testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
        insert testOrchestrationStep;
    }

    @IsTest
    static void testStepHandlerBase() {
        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        Test.startTest();
        CS_SORollupHandler handler = new CS_SORollupHandler();
        handler.process(steps);
        Test.stopTest();
    }

    @IsTest
    static void testStepHandlerBase2() {
        List<CSPOFA__Orchestration_Step__c> steps = [
                SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
        ];

        Test.startTest();
        CS_ApprovalCheckHandler handler = new CS_ApprovalCheckHandler();
        handler.process(steps);
        Test.stopTest();
    }
}
/**
 * Created by jameshladek on 3/23/20.
 */
@IsTest
public with sharing class CS_ApprovalStartHandlerTest {

    @IsTest
    static void testAll() {
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

        cscfga__Product_Basket__c testBasket = TestDataSetupTargetables.createProdBasket(testSalesOrder);
        insert testBasket;

        CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
        testProcess.Sales_Order__c = testSalesOrder.Id;
        insert testProcess;

        CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
        testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
        insert testOrchestrationStep;

        testOrchestrationStep = [
                SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                        Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                FROM CSPOFA__Orchestration_Step__c
                LIMIT 1
        ];

        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(testOrchestrationStep);

        Test.startTest();
        CS_ApprovalStartHandler handler = new CS_ApprovalStartHandler();
        List<SObject> results = handler.process(steps);
        Test.stopTest();
        List<CSPOFA__Orchestration_Step__c> stepResults = (List<CSPOFA__Orchestration_Step__c>) results;

        System.assertEquals('Sales Order submitted for approval', stepResults[0].CSPOFA__Message__c);
    }
}
@IsTest
public with sharing class CS_ApprovalCheckHandlerTest {

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
		testProcess.Name = 'Approval Check';
		insert testProcess;

		CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
		testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
		insert testOrchestrationStep;
	}

	@IsTest
	static void testApprovalCheckHandler() {
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
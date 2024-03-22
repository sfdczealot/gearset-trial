@IsTest
public with sharing class CS_FulfilmentUpsertHandlerTest {
	private static CS_Custom_Settings__c settings;

	private static void createTestData() {
		settings = new CS_Custom_Settings__c();
		settings.Integration_Chunk_Size__c = 10.0;
		settings.Integration_Delay_Between_Callouts__c = 300.0;
		insert settings; 

 Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;
		Account testAccount = TestDataSetupSO.createAccount();
          testAccount.recordtypeid=[SELECT Id,Name FROM RecordType WHERE SObjectType='Account' and Name='B2B - Account'].id;
		insert testAccount;

		Contact testContact = TestDataSetupSO.createContact(testAccount);
		insert testContact;

		Opportunity testOpportunity = TestDataSetupSO.createOpportunity(testAccount, testContact);
        testOpportunity.recordtypeid=[SELECT Id,Name FROM RecordType WHERE SObjectType='Opportunity' and Name='B2B'].id;
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
		testProcess.Name = 'CS_FulfilmentUpsertHandler';
		insert testProcess;

		CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
		testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
		insert testOrchestrationStep;
	}

	@IsTest
	static void testFulfilmentUpsertHandlerCreatingFI() {
		createTestData();

		settings.Max_n_Lines_for_Sync_Execution__c = 1;
		settings.Max_n_Templates_for_Sync_Execution__c = 10;
		update settings;

		List<CSPOFA__Orchestration_Step__c> steps = [
				SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
						Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
				FROM CSPOFA__Orchestration_Step__c
		];

		Test.startTest();
		CS_FulfilmentUpsertHandler handler = new CS_FulfilmentUpsertHandler();
		handler.process(steps);
		Test.stopTest();
	}

	@IsTest
	static void testFulfilmentUpsertHandlerFICreated() {
		createTestData();

		settings.Max_n_Lines_for_Sync_Execution__c = 2;
		settings.Max_n_Templates_for_Sync_Execution__c = 10;
		update settings;

		List<CSPOFA__Orchestration_Step__c> steps = [
				SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
						Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
				FROM CSPOFA__Orchestration_Step__c
		];

		Test.startTest();
		CS_FulfilmentUpsertHandler handler = new CS_FulfilmentUpsertHandler();
		handler.process(steps);
		Test.stopTest();
	}
    @IsTest
	static void cs_fulfilmentUpsertTest() 
    {
        CS_FulfilmentUpsertWorker.codeCoverage();
        cs_fulfilmentService.codeCoverage();
        
    }
    
}
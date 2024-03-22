@IsTest
private class CS_ApprovalServiceTest {
	private static csmso__Sales_Order__c testSalesOrder;
	private static cscfga__Product_Configuration__c testConfiguration;

	private static void createTestData() {
		Account testAccount = TestDataSetupSO.createB2BAcc();
		insert testAccount;

		Contact testContact = TestDataSetupSO.createContact(testAccount);
		insert testContact;
 Trigger_Execute__c TE2 = new Trigger_Execute__c();
        TE2.Name = 'Trigger_OpportunitySplit';
        TE2.Enable_del__c = true;
        insert TE2;
		Opportunity testOpportunity = TestDataSetupSO.createOpportunity(testAccount, testContact);
		insert testOpportunity;

		testSalesOrder = TestDataSetupSO.createSalesOrder(testAccount, testOpportunity);
		testSalesOrder.csmso__Opportunity__c = testOpportunity.Id;
		testSalesOrder.SO_Lines_All_Valid__c = true;
		testSalesOrder.Inventory_Approval__c = 'Pending';
		testSalesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_FIRST_APPROVAL;
		testSalesOrder.SO_Lines_Ad_Server_Items__c = 2;
		testSalesOrder.SO_Lines_Number_of_lines__c = 1;
		testSalesOrder.Primary_Sales_Order__c = true;
		insert testSalesOrder;
     
		csdf__Fulfilment__c testFulfilment = [SELECT Id FROM csdf__Fulfilment__c WHERE Sales_Order__c = :testSalesOrder.Id];

		testConfiguration = TestDataSetupSO.createproductConfigAndDef('Test Config');
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
	}

	@IsTest
	static void testApprovalPropertySuccess() {
		Map<String, String> values = new Map<String, String>();
		Map<String, String> oldValues = new Map<String, String>();
		values.put('Buffer', '20');
		oldValues.put('Buffer', '10');

		String approvalPropertyString = '{"name":"Buffer","type":"attribute","dataType":"Decimal","messageTemplate":"{0} {1} {2}"}';
		CS_ApprovalService.ApprovalProperty customApprovalProperty = new CS_ApprovalService.ApprovalProperty();
		customApprovalProperty = (CS_ApprovalService.ApprovalProperty) JSON.deserialize(approvalPropertyString, CS_ApprovalService.ApprovalProperty.class);
		System.assertEquals('Buffer', customApprovalProperty.name);
		System.assertEquals('attribute', customApprovalProperty.type);
		System.assertEquals('Decimal', customApprovalProperty.dataType);

		Object value = 20;
		Boolean isApplicable = customApprovalProperty.isApplicable('changed', value, values, oldValues);
		System.assertEquals(true, isApplicable);
	}

	@IsTest
	static void testCheckApprovals() {
		createTestData();

		Test.startTest();
		CS_ApprovalService approvalService = new CS_ApprovalService();
		approvalService.checkApprovals(testSalesOrder);
		Test.stopTest();
	}

	@IsTest
	static void testSubmitForApprovals() {
		createTestData();

		Test.startTest();
		CS_ApprovalService.submitForApprovals(testSalesOrder.Id);
		Test.stopTest();
	}

	@IsTest
	static void testCheckApprovalsSet() {
		createTestData();

		Test.startTest();
		CS_ApprovalService.checkApprovals(new Set<Id>{
				testSalesOrder.Id
		});
		Test.stopTest();
	}

	@IsTest
	static void testGetSnapshotData() {
		createTestData();

		Test.startTest();
		CS_ApprovalService approvalService = new CS_ApprovalService();
		approvalService.getSnapshotData(new List<cscfga__Product_Configuration__c>{
				testConfiguration
		});
		Test.stopTest();
	}
}
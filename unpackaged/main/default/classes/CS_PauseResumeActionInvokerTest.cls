@IsTest
private class CS_PauseResumeActionInvokerTest {
	private static csmso__Sales_Order__c so;
	private static csdf__Fulfilment__c testFulfilment;
	private static cscfga__Product_Configuration__c prodConfig;

	private static void createTestData() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account acc = TestDataSetupBasic.createAccount();
		insert acc;

		Contact con = TestDataSetupBasic.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
		insert opp;

		so = TestDataSetupSO.createSalesOrder(acc, opp);
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		insert testFulfilment;

		prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		insert prodConfig;
	}

	@IsTest
	static void testPauseResumeActionValidResponse() {
		createTestData();

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
		testFulfilmentItem.csdf__Pause_Resume_Message_Status__c = 'Completed';
		testFulfilmentItem.Reservation_Status__c = 'RELEASED';
		insert testFulfilmentItem;

		Test.startTest();
		CS_PauseResumeActionInvoker.PauseResumeRequest request = new CS_PauseResumeActionInvoker.PauseResumeRequest();
		request.action = 'Test';
		request.configurationIds = new List<Id>{
				prodConfig.Id
		};

		String parameters = JSON.serialize(request);
		CS_PauseResumeActionInvoker caPollClass = new CS_PauseResumeActionInvoker();
		String str = caPollClass.performAction(parameters);
		System.assert(!String.isEmpty(str));
		Test.stopTest();
	}

	@IsTest
	static void testPauseResumeActionExceptionNullConfigs() {
		createTestData();

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
		testFulfilmentItem.csdf__Pause_Resume_Message_Status__c = 'Completed';
		testFulfilmentItem.Reservation_Status__c = 'RELEASED';
		insert testFulfilmentItem;

		Test.startTest();
		CS_PauseResumeActionInvoker.PauseResumeRequest request = new CS_PauseResumeActionInvoker.PauseResumeRequest();

		try {
			String parameters = JSON.serialize(request);
			CS_PauseResumeActionInvoker caPollClass = new CS_PauseResumeActionInvoker();
			caPollClass.performAction(parameters);
		} catch (Exception e) {
		}

		Test.stopTest();
	}

	@IsTest
	static void testPauseResumeActionExceptionNullFulfilmentItems() {
		createTestData();

		Test.startTest();
		CS_PauseResumeActionInvoker.PauseResumeRequest request = new CS_PauseResumeActionInvoker.PauseResumeRequest();
		request.configurationIds = new List<Id>{
				prodConfig.Id
		};

		try {
			String parameters = JSON.serialize(request);
			CS_PauseResumeActionInvoker caPollClass = new CS_PauseResumeActionInvoker();
			caPollClass.performAction(parameters);
		} catch (Exception e) {
		}

		Test.stopTest();
	}
}
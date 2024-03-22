@IsTest
private class CS_PauseResumePollActionInvokerTest {
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
	static void testPauseResumePollActionFICompleted() {
		createTestData();

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
		testFulfilmentItem.csdf__Pause_Resume_Message_Status__c = 'Completed';
		testFulfilmentItem.Reservation_Status__c = 'RELEASED';
		insert testFulfilmentItem;

		Test.startTest();
		CS_PauseResumePollActionInvoker caPollClass = new CS_PauseResumePollActionInvoker();
		String str = caPollClass.performAction(JSON.serialize(new List<Id>{
				prodConfig.Id
		}));
		System.assert(!String.isEmpty(str));
		Test.stopTest();
	}

	@IsTest
	static void testPauseResumePollActionFIError() {
		createTestData();

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
		testFulfilmentItem.csdf__Pause_Resume_Message_Status__c = 'Completed (Error)';
		testFulfilmentItem.Reservation_Status__c = 'RELEASED';
		insert testFulfilmentItem;

		Test.startTest();
		CS_PauseResumePollActionInvoker caPollClass = new CS_PauseResumePollActionInvoker();
		String str = caPollClass.performAction(JSON.serialize(new List<Id>{
				prodConfig.Id
		}));
		System.assert(!String.isEmpty(str));
		Test.stopTest();
	}
}
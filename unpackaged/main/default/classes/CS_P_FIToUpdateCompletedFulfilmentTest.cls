@IsTest
private class CS_P_FIToUpdateCompletedFulfilmentTest {
	private static csdf__Fulfilment__c testFulfilment;
	private static csdf__Fulfilment_Item__c testFulfilmentItem;
	private static csdf__Fulfilment_Item__c testFulfilmentItem2;

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

		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
		insert testAdServer;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		so.Ad_Server__c = testAdServer.Id;
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		testFulfilment.csdf__Status__c = CS_const_SalesOrder.FulfilmentStatus_Draft;
		testFulfilment.csdf__Ad_Server__c = testAdServer.Id;
		insert testFulfilment;

		List<cscfga__Product_Configuration__c> pcsToInsert = new List<cscfga__Product_Configuration__c>();
		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		pcsToInsert.add(prodConfig);

		cscfga__Product_Configuration__c prodConfig2 = TestDataSetupTargetables.createProdConfig(prodBasket);
		pcsToInsert.add(prodConfig2);
		insert pcsToInsert;

		List<csdf__Fulfilment_Item__c> fisToInsert = new List<csdf__Fulfilment_Item__c>();
		testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
		testFulfilmentItem.csdf__Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Draft;
		testFulfilmentItem.csdf__Name__c = 'Test FI 1';
		fisToInsert.add(testFulfilmentItem);

		testFulfilmentItem2 = TestDataSetupTargetables.createFulfilmentItem(prodConfig2, so, testFulfilment);
		testFulfilmentItem2.Product_Configuration__c = prodConfig2.Id;
		testFulfilmentItem2.csdf__Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Draft;
		testFulfilmentItem2.csdf__Name__c = 'Test FI 2';
		fisToInsert.add(testFulfilmentItem2);
		insert fisToInsert;
	}

	@IsTest
	static void testFIToUpdateCompletedFulfilmentNotCompleted() {
		createTestData();

		csdf__Fulfilment_Item__c oldFulfilmentItem = [
				SELECT
						Id,
						csdf__Status__c,
						csdf__Fulfilment__c
				FROM csdf__Fulfilment_Item__c
				WHERE Id = :testFulfilmentItem.Id
		];

		testFulfilmentItem.csdf__Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Completed;
		update testFulfilmentItem;

		testFulfilmentItem = [
				SELECT
						Id,
						csdf__Status__c,
						csdf__Fulfilment__c
				FROM csdf__Fulfilment_Item__c
				WHERE Id = :testFulfilmentItem.Id
		];

		Test.startTest();
		CS_P_FIToUpdateCompletedFulfilment fiToUpdateCompletedFulfilment = new CS_P_FIToUpdateCompletedFulfilment(new Map<Id, csdf__Fulfilment_Item__c>{oldFulfilmentItem.Id => oldFulfilmentItem});
		fiToUpdateCompletedFulfilment.isRecordEligible((SObject) testFulfilmentItem);
		fiToUpdateCompletedFulfilment.logic();
		Test.stopTest();

		System.assertEquals(fiToUpdateCompletedFulfilment.applicableObjects.isEmpty(), false);

		testFulfilment = [SELECT Id, csdf__Status__c FROM csdf__Fulfilment__c];
		System.assertEquals(testFulfilment.csdf__Status__c, CS_const_SalesOrder.FulfilmentStatus_Draft);
	}

	@IsTest
	static void testFIToUpdateCompletedFulfilmentCompleted() {
		createTestData();

		csdf__Fulfilment_Item__c oldFulfilmentItem = [
				SELECT
						Id,
						csdf__Status__c,
						csdf__Fulfilment__c
				FROM csdf__Fulfilment_Item__c
				WHERE Id = :testFulfilmentItem.Id
		];

		testFulfilmentItem.csdf__Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Completed;
		update testFulfilmentItem;

		testFulfilmentItem2.csdf__Status__c = CS_const_SalesOrder.FulfilmentItemStatus_Completed;
		update testFulfilmentItem2;

		testFulfilmentItem = [
				SELECT
						Id,
						csdf__Status__c,
						csdf__Fulfilment__c
				FROM csdf__Fulfilment_Item__c
				WHERE Id = :testFulfilmentItem.Id
		];

		Test.startTest();
		CS_P_FIToUpdateCompletedFulfilment fiToUpdateCompletedFulfilment = new CS_P_FIToUpdateCompletedFulfilment(new Map<Id, csdf__Fulfilment_Item__c>{oldFulfilmentItem.Id => oldFulfilmentItem});
		fiToUpdateCompletedFulfilment.isRecordEligible((SObject) testFulfilmentItem);
		fiToUpdateCompletedFulfilment.logic();
		Test.stopTest();

		System.assertEquals(fiToUpdateCompletedFulfilment.applicableObjects.isEmpty(), false);

		testFulfilment = [SELECT Id, csdf__Status__c FROM csdf__Fulfilment__c];
		System.assertEquals(testFulfilment.csdf__Status__c, CS_const_SalesOrder.FulfilmentStatus_Completed);
	}
}
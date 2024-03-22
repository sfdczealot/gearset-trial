@isTest
private class ButtonSORetractTest {

	@isTest
	static void testButtonSORetractAfterBookingNoAdServerLines() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.Integration_Chunk_Size__c = 10;
		insert cs;

		ButtonSORetract button = new ButtonSORetract();
		Account[] accs = TestDataSetupBasic.createAccounts(5);
		Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs,cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_BOOKED;
		salesOrder.Reason_for_Retraction__c = 'Optimization request by Spotify';
		insert salesOrder;

		Test.startTest();
		button.performAction(salesOrder.id);
		Test.stopTest();
	}

	@isTest
	static void testButtonSORetractAfterBookingWithAdServerLines() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.Integration_Chunk_Size__c = 10;
		insert cs;

		ButtonSORetract button = new ButtonSORetract();
		Account[] accs = TestDataSetupBasic.createAccounts(5);
		Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs,cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_BOOKED;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.Reason_for_Retraction__c = 'Optimization request by Spotify';
		insert salesOrder;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Attribute definition Creation.
		List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1,prodDef);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1,new List<csmso__Sales_Order__c>{salesOrder});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1,prodBaskets,prodDef);

		for(cscfga__product_Configuration__c pConfig: prodConfigs){
			pConfig.Sales_Order__c = salesOrder.id;
		}
		update prodConfigs;

		List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{salesOrder},accs);

		List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
		fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
		fulfilmentItem[0].csdf__Type__c = 'Standard';
		fulfilmentItem[0].Served_By__c = 'DFP';
		update fulfilmentItem;

		cscfga__Product_Configuration__c pc = [SELECT Id, Sales_Order__c
		FROM cscfga__Product_Configuration__c
		LIMIT 1][0];

		Test.startTest();
		button.performAction(salesOrder.id);
		Test.stopTest();
	}

	@isTest
	static void testButtonSORetractBeforeBooking() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.Integration_Chunk_Size__c = 10;
		insert cs;

		ButtonSORetract button = new ButtonSORetract();
		Account[] accs = TestDataSetupBasic.createAccounts(5);
		Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs,cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL_READY;
		insert salesOrder;

		Test.startTest();
		button.performAction(salesOrder.id);
		Test.stopTest();
	}

	@isTest
	static void testButtonSORetractError() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		ButtonSORetract button=new ButtonSORetract();
		Account[] accs = TestDataSetupBasic.createAccounts(5);
		Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs,cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		insert salesOrder;

		Test.startTest();
		button.performAction(salesOrder.id);
		Test.stopTest();
	}

	@isTest
	static void testButtonSORetractException() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.Integration_Chunk_Size__c = 10;
		insert cs;

		ButtonSORetract button = new ButtonSORetract();
		Account[] accs = TestDataSetupBasic.createAccounts(5);
		Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs,cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_BOOKED;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.Reason_for_Retraction__c = 'Optimization request by Spotify';
		insert salesOrder;

		Test.startTest();
		button.performAction(salesOrder.id);
		Test.stopTest();
	}

	@isTest
	static void testButtonSORetractAfterBookingWithAdServerLines2() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.Integration_Chunk_Size__c = 10;
		cs.Sync_Retraction_SOLI_Limit__c = 1;
		insert cs;

		Account[] accs = TestDataSetupBasic.createAccounts(5);
		Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs,cons);

		CS_utl_User.enableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi2 = [SELECT Id FROM csmso__SalesOrderAPI__c LIMIT 1];
		delete soapi2;

		Test.startTest();
		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_BOOKED;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.Reason_for_Retraction__c = 'Optimization request by Spotify';
		salesOrder.csmso__Advertiser__c = accs[0].Id;
		salesOrder.Advertiser_Final__c = accs[0].Id;
		insert salesOrder;

		csmso__Sales_Order__c salesOrder1 = new csmso__Sales_Order__c();
		salesOrder1.csmso__Opportunity__c = opps[0].Id;
		salesOrder1.csmso__Status__c = StandardSalesOrderStateManager.SO_BOOKED;
		salesOrder1.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder1.Reason_for_Retraction__c = 'Optimization request by Spotify';
		salesOrder1.csmso__Advertiser__c = accs[1].Id;
		salesOrder1.Advertiser_Final__c = accs[1].Id;
		insert salesOrder1;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(2);

		//Attribute definition Creation.
		List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(2, prodDef);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(2, new List<csmso__Sales_Order__c>{salesOrder, salesOrder1});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(2, prodBaskets, prodDef);

		for(cscfga__product_Configuration__c pConfig: prodConfigs){
			pConfig.Sales_Order__c = salesOrder.id;
		}
		update prodConfigs;

		List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{salesOrder},accs);

		List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
		fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
		fulfilmentItem[0].csdf__Type__c = 'Standard';
		fulfilmentItem[0].Served_By__c = 'DFP';
		update fulfilmentItem;

		cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
		FROM    cscfga__Product_Configuration__c
		LIMIT   1][0];

		String message;
		try{
			ButtonSORetract button = new ButtonSORetract();
			button.performAction(salesOrder.id);
			Test.stopTest();
		}
		catch (Exception e){
			message = e.getMessage();
		}

		//System.assertEquals('Maximum stack depth has been reached.', message);
		System.assertEquals(null, message);
	}
}
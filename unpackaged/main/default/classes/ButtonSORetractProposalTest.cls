@isTest
private class ButtonSORetractProposalTest {

	@isTest
	static void testButtonSORetractProposalReserved() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		ButtonSORetractProposal button = new ButtonSORetractProposal();
		Account[] accs = TestDataSetupBasic.createAccounts(5);
		Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs,cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_RESERVED;
		salesOrder.SO_Lines_All_Valid__c = true;
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
			pConfig.Reserve_Inventory__c = true;
			pConfig.Inventory_Available__c = 'Yes';
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
	static void testButtonSORetractProposalBooked() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.Integration_Chunk_Size__c = 10;
		cs.Sync_Retraction_SOLI_Limit__c = 1;
		cs.Max_n_Lines_for_Sync_Execution__c = 1;
		insert cs;

		ButtonSORetractProposal button = new ButtonSORetractProposal();
		Account[] accs = TestDataSetupBasic.createAccounts(5);
		Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs,cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_BOOKED;
		salesOrder.SO_Lines_All_Valid__c = true;
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
			pConfig.Reserve_Inventory__c = true;
			pConfig.Inventory_Available__c = 'Yes';
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
	static void testButtonSORetractProposalInRetractionFinalized() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
		cs.Integration_Chunk_Size__c = 10;
		cs.Sync_Retraction_SOLI_Limit__c = 1;
		cs.Max_n_Lines_for_Sync_Execution__c = 1;
		insert cs;

		ButtonSORetractProposal button = new ButtonSORetractProposal();
		Account[] accs = TestDataSetupBasic.createAccounts(5);
		Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs,cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_PENDING;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.Reason_for_Retraction__c = 'Optimization request by Spotify';
		salesOrder.Negotiation_Status__c = 'Finalized';
		salesOrder.Order_Type__c = 'Programmatic Guaranteed';
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
			pConfig.Reserve_Inventory__c = true;
			pConfig.Inventory_Available__c = 'Yes';
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
	static void testButtonSORetractProposalCustomerApproval() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		ButtonSORetractProposal button = new ButtonSORetractProposal();
		Account[] accs = TestDataSetupBasic.createAccounts(5);
		Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs,cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL;
		salesOrder.SO_Lines_All_Valid__c = true;
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
			pConfig.Reserve_Inventory__c = true;
			pConfig.Inventory_Available__c = 'Yes';
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
	static void testButtonSORetractProposalNotReserved() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		ButtonSORetractProposal button = new ButtonSORetractProposal();
		Account[] accs = TestDataSetupBasic.createAccounts(5);
		Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs,cons);

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opps[0].Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_PENDING_BOOKING;
		salesOrder.SO_Lines_All_Valid__c = true;
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
			pConfig.Reserve_Inventory__c = true;
			pConfig.Inventory_Available__c = 'Yes';
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
		try  {
			button.performAction(salesOrder.id);
			Test.stopTest();
		}
		catch (Exception e) {

		}
	}

}
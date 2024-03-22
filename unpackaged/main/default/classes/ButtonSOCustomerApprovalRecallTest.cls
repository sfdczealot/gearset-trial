@isTest
private class ButtonSOCustomerApprovalRecallTest {

	@isTest
	static void testButtonSOCustomerApprovalRecall() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		ButtonSOCustomerApprovalRecall button = new ButtonSOCustomerApprovalRecall();

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		update opp;

		salesOrder.csmso__Opportunity__c = opp.Id;
		insert salesOrder;

		String soID = salesOrder.id;

		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL_READY;
		update salesOrder;

		csmso__Upload_Approval__c TestCSCAPUP = new csmso__Upload_Approval__c();
		TestCSCAPUP.Name = 'TestCSCAPUP123';
		TestCSCAPUP.csmso__Sales_Order__c = salesorder.id;

		insert TestCSCAPUP;

		CSCAP__Customer_Approval__c TestCSCAP = new CSCAP__Customer_Approval__c();
		TestCSCAP.CSCAP__Rejected_By_Customer__c = false;
		TestCSCAP.CSCAP__Opportunity__c = opp.Id;
		TestCSCAP.Upload_Approval__c = TestCSCAPUP.id;
		TestCSCAP.CSCAP__Approved_By_Customer__c = false;
		TestCSCAP.CSCAP__Status__c = 'Active';

		insert TestCSCAP;

		Test.startTest();
		button.performAction(soID);

		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL;
		update salesOrder;
		button.performAction(soID);

		salesOrder.csmso__From__c = Date.today() ;
		salesOrder.csmso__To__c = Date.today().addMonths(3);
		salesOrder.csmso__Status__c = 'Pending Booking';

		update salesOrder;
		button.performAction(soID);
		Test.stopTest();
	}

	@isTest
	static void testButtonSOCustomerApprovalRecallBookedWithLine() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		ButtonSOCustomerApprovalRecall button = new ButtonSOCustomerApprovalRecall();

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opp.Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL_READY;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.SO_Lines_Ad_Server_Items__c = 1;
		salesOrder.Order_Type__c = CS_Constants.ORDER_TYPE_LABELS_ADCREDIT;
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
			pConfig.Sales_Order__c = salesOrder.Id;
		}
		update prodConfigs;

		List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{salesOrder},new List<Account> {acc});

		List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
		fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
		fulfilmentItem[0].csdf__Type__c = 'Standard';
		fulfilmentItem[0].Served_By__c = 'DFP';
		fulfilmentItem[0].csdf__Status__c = 'Reserved';
		update fulfilmentItem;

		cscfga__Product_Configuration__c pc = [SELECT Id, Sales_Order__c
		FROM cscfga__Product_Configuration__c
		LIMIT 1][0];

		String soID = salesOrder.id;

		csmso__Upload_Approval__c TestCSCAPUP = new csmso__Upload_Approval__c();
		TestCSCAPUP.Name = 'TestCSCAPUP123';
		TestCSCAPUP.csmso__Sales_Order__c = salesorder.id;

		insert TestCSCAPUP;

		CSCAP__Customer_Approval__c TestCSCAP = new CSCAP__Customer_Approval__c();
		TestCSCAP.CSCAP__Rejected_By_Customer__c = false;
		TestCSCAP.CSCAP__Opportunity__c = opp.Id;
		TestCSCAP.Upload_Approval__c = TestCSCAPUP.id;
		TestCSCAP.CSCAP__Approved_By_Customer__c = false;
		TestCSCAP.CSCAP__Status__c = 'Active';

		insert TestCSCAP;

		Test.startTest();
		button.performAction(soID);

		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL;
		update salesOrder;
		button.performAction(soID);

		salesOrder.csmso__From__c = Date.today() ;
		salesOrder.csmso__To__c = Date.today().addMonths(3);
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_BOOKED;

		update salesOrder;
		button.performAction(soID);
		Test.stopTest();
	}

	@isTest
	static void testButtonSOCustomerApprovalRecallBookedNoLine() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		ButtonSOCustomerApprovalRecall button = new ButtonSOCustomerApprovalRecall();

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opp.Id;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL_READY;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.SO_Lines_Ad_Server_Items__c = 0;
		salesOrder.Order_Type__c = CS_Constants.ORDER_TYPE_LABELS_ADCREDIT;
		insert salesOrder;

		String soID = salesOrder.Id;

		csmso__Upload_Approval__c TestCSCAPUP = new csmso__Upload_Approval__c();
		TestCSCAPUP.Name = 'TestCSCAPUP123';
		TestCSCAPUP.csmso__Sales_Order__c = salesOrder.Id;

		insert TestCSCAPUP;

		CSCAP__Customer_Approval__c TestCSCAP = new CSCAP__Customer_Approval__c();
		TestCSCAP.CSCAP__Rejected_By_Customer__c = false;
		TestCSCAP.CSCAP__Opportunity__c = opp.Id;
		TestCSCAP.Upload_Approval__c = TestCSCAPUP.Id;
		TestCSCAP.CSCAP__Approved_By_Customer__c = false;
		TestCSCAP.CSCAP__Status__c = 'Active';

		insert TestCSCAP;

		Test.startTest();
		button.performAction(soID);
		Test.stopTest();
	}

	@isTest
	static void testButtonSOCustomerApprovalBookedLine() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		ButtonSOCustomerApprovalRecall button = new ButtonSOCustomerApprovalRecall();

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opp.Id;
		salesOrder.isTestRunning__c = true;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_RESERVE_REJECTED;
		salesOrder.SO_Lines_Ad_Server_Items__c = 0;
		salesOrder.Primary_Sales_Order__c = true;
		salesOrder.Order_Type__c = CS_Constants.ORDER_TYPE_LABELS_ADCREDIT;
		salesOrder.Reason_for_Retraction__c = 'Optimization request by Spotify';
		salesOrder.Callout_Type__c = 'RetractionService';
		insert salesOrder;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
		insert prodBasket;

		csmso__Upload_Approval__c testCSCAPUP = new csmso__Upload_Approval__c();
		testCSCAPUP.Name = 'TestCSCAPUP123';
		testCSCAPUP.csmso__Sales_Order__c = salesOrder.Id;
		insert testCSCAPUP;

		CSCAP__Customer_Approval__c testCSCAP = new CSCAP__Customer_Approval__c();
		testCSCAP.CSCAP__Rejected_By_Customer__c = false;
		testCSCAP.CSCAP__Opportunity__c = opp.Id;
		testCSCAP.Upload_Approval__c = testCSCAPUP.Id;
		testCSCAP.CSCAP__Approved_By_Customer__c = false;
		testCSCAP.CSCAP__Status__c = 'Active';
		insert testCSCAP;

		Test.startTest();
		String returnMessqage = button.performAction(salesOrder.Id);
		System.debug('returnMessqage => ' + returnMessqage);
		Test.stopTest();
	}
}
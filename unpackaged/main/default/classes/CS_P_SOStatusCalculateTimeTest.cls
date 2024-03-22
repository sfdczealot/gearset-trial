@isTest 
private class CS_P_SOStatusCalculateTimeTest {

	@testSetup 
	static void testSetup() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());

		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;
		
		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;
		
		Account agency = TestDataSetupTargetables.createAccount();
		agency.Type = 'Media Agency';
		insert agency;
		
		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;
		
		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		opp.Media_Agency2__c = agency.id;
		opp.Agency_Client_del__c = acc.id;
		insert opp;
	
		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		so.csmso__Status__c = CS_const_SalesOrder.Status_InProgress;
		insert so;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Attribute definition Creation.
		List<cscfga__Attribute_Definition__c> attDef =	TestDataSetupSO.createAttributeDefinitions(1, prodDef);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

		for(cscfga__product_Configuration__c pConfig: prodConfigs){
			pConfig.Sales_Order__c = so.id;
		}
		update prodConfigs;
		
	}

	@isTest()
	public static void testStatusChange() {
		
		csmso__Sales_Order__c so = 
		[
			SELECT	Id, 
					Name,
					csmso__Status__c,
					Last_Status_Change__c,
					Pending_Inventory_Approval_Time__c
			FROM	csmso__Sales_Order__c 
			LIMIT	1
		];
		
		Test.startTest();
		Map<Id, csmso__Sales_Order__c> mapOld = new Map<Id, csmso__Sales_Order__c>();
		mapOld.put(so.Id, so);
		CS_P_SOStatusCalculateTime process = new CS_P_SOStatusCalculateTime(mapOld);

		so.csmso__Status__c = CS_const_SalesOrder.Status_PendingApprovals;
		update so;
		
		so = 
		[
			SELECT	Id, 
					Name,
					csmso__Status__c,
					Last_Status_Change__c,
					Pending_Inventory_Approval_Time__c
			FROM	csmso__Sales_Order__c 
			LIMIT	1
		];
		
		process.isRecordEligible(so);
		process.logic();
		Test.stopTest();
	}

	@isTest()
	public static void testStatusChangeWithLastStatusChange() {
		
		csmso__Sales_Order__c so = 
		[
			SELECT	Id, 
					Name,
					csmso__Status__c,
					Last_Status_Change__c,
					Pending_Inventory_Approval_Time__c
			FROM	csmso__Sales_Order__c 
			LIMIT	1
		];

		Test.startTest();
		Map<Id, csmso__Sales_Order__c> mapOld = new Map<Id, csmso__Sales_Order__c>();
		mapOld.put(so.Id, so);
		CS_P_SOStatusCalculateTime process = new CS_P_SOStatusCalculateTime(mapOld);

		so.csmso__Status__c = CS_const_SalesOrder.Status_PendingApprovals;
		update so;

		so = 
		[
			SELECT	Id, 
					Name,
					csmso__Status__c,
					Last_Status_Change__c,
					Pending_Inventory_Approval_Time__c
			FROM	csmso__Sales_Order__c 
			LIMIT	1
		];
		
		process.isRecordEligible(so);
		process.logic();

		so.csmso__Status__c = CS_const_SalesOrder.Status_PendingApprovals;
		so.Last_Status_Change__c = Datetime.now().addDays(-1);
		so.Pending_Inventory_Approval_Time__c = 0;
		update so;
		
		so = 
		[
			SELECT	Id, 
					Name,
					csmso__Status__c,
					Last_Status_Change__c,
					Pending_Inventory_Approval_Time__c
			FROM	csmso__Sales_Order__c 
			LIMIT	1
		];
		
		process.isRecordEligible(so);
		process.logic();
		Test.stopTest();
	}
}
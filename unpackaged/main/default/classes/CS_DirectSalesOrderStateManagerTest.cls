@IsTest
private class CS_DirectSalesOrderStateManagerTest {
	private static User systemAdminUser;
	private static User ssystemAdminUser;

	private static void createSystemAdminUser() {
		Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name IN ('System Administrator', 'Systeembeheerder') LIMIT 1];
		systemAdminUser = new User(Alias = 'standta', Email = 'standardusear@testorg.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = systemAdminProfile.Id,
				TimeZoneSidKey = 'America/Los_Angeles', Username = 'standamarkordusera1234@testorg.com');
		insert systemAdminUser;
	}

	private static void createSSystemAdminUser() {
		Profile ssystemAdminProfile = [SELECT Id FROM Profile WHERE Name IN ('S: Systems Administrator') LIMIT 1];
		ssystemAdminUser = new User(Alias = 'standta', Email = 'standardusear@testorg.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = ssystemAdminProfile.Id,
				TimeZoneSidKey = 'America/Los_Angeles', Username = 'standamarkordusera1234@testorg.com');
		insert ssystemAdminUser;
	}

	@IsTest
	static void testDSOSMSSystemAdminCompliance() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		createSSystemAdminUser();

		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		so.Order_Type__c = 'Direct Commercial';
		so.SO_Lines_Ad_Server_Items__c = 0;
		so.Last_Date_Booked__c = Date.today();
		so.Primary_Sales_Order__c = true;
		so.csmso__Status__c = StandardSalesOrderStateManager.SO_PENDING_BOOKING;
		so.Last_Date_Retracted__c = Date.today();
		so.Legal_Check__c = 'Approved';
		so.Counter_Sign_IO__c = 'Approved';
		insert so;

		so = (csmso__Sales_Order__c) sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c', 'Id= \'' + so.Id + '\'', 1, true)[0];

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				so
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

		for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
			pConfig.Sales_Order__c = so.Id;
		}
		update prodConfigs;

		List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1, new List<csmso__Sales_Order__c>{
				so
		}, new List<Account>{
				acc
		});

		List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1, fulfilment, prodConfigs);
		fulfilmentItem[0].csdf__Flight_Beginning__c = Date.today().addDays(4);
		fulfilmentItem[0].csdf__Type__c = 'Standard';
		fulfilmentItem[0].Served_By__c = 'DFP';
		update fulfilmentItem;

		cscfga__Product_Configuration__c pc = [
				SELECT Id, Sales_Order__c
				FROM cscfga__Product_Configuration__c
				LIMIT 1
		][0];

		System.runAs(ssystemAdminUser) {
			Test.startTest();
			Type stateManagerType = Type.forName(so.State_Manager_Class__c);
			CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase) stateManagerType.newInstance();
			stateManager.init(so);
			stateManager.validateChange();
			stateManager.getFieldProperties();
			Test.stopTest();
		}
	}

	@IsTest
	static void testDSOSMSSystemAdminDisableBookBttn() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		createSSystemAdminUser();

		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		so.Order_Type__c = 'Direct Commercial';
		so.SO_Lines_Ad_Server_Items__c = 2;
		so.Order_Synced_before_final_approval__c = true;
		so.SO_Lines_Ad_Server_Inventory_Avail_Ov__c = 1;
		so.Last_Date_Booked__c = Date.today();
		so.Primary_Sales_Order__c = true;
		so.csmso__Status__c = StandardSalesOrderStateManager.SO_PENDING_BOOKING;
		so.Last_Date_Retracted__c = Date.today();
		so.Legal_Check__c = 'Approved';
		so.Counter_Sign_IO__c = 'Approved';
		insert so;

		so = (csmso__Sales_Order__c) sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c', 'Id= \'' + so.Id + '\'', 1, true)[0];

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				so
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

		for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
			pConfig.Sales_Order__c = so.Id;
		}
		update prodConfigs;

		List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1, new List<csmso__Sales_Order__c>{
				so
		}, new List<Account>{
				acc
		});

		List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1, fulfilment, prodConfigs);
		fulfilmentItem[0].csdf__Flight_Beginning__c = Date.today().addDays(4);
		fulfilmentItem[0].csdf__Type__c = 'Standard';
		fulfilmentItem[0].Served_By__c = 'DFP';
		update fulfilmentItem;

		cscfga__Product_Configuration__c pc = [
				SELECT Id, Sales_Order__c
				FROM cscfga__Product_Configuration__c
				LIMIT 1
		][0];

		System.runAs(ssystemAdminUser) {
			Test.startTest();
			Type stateManagerType = Type.forName(so.State_Manager_Class__c);
			CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase) stateManagerType.newInstance();
			stateManager.init(so);
			stateManager.validateChange();
			stateManager.getFieldProperties();
			Test.stopTest();
		}
	}

	@IsTest
	static void testDSOSMSSystemAdminRejected() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		createSSystemAdminUser();

		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		so.Order_Type__c = 'Direct Commercial';
		so.SO_Lines_Ad_Server_Items__c = 2;
		so.Order_Synced_before_final_approval__c = true;
		so.SO_Lines_Ad_Server_Inventory_Avail_Ov__c = 1;
		so.Last_Date_Booked__c = Date.today();
		so.Primary_Sales_Order__c = true;
		so.csmso__Status__c = StandardSalesOrderStateManager.SO_REJECTED;
		so.Last_Date_Retracted__c = Date.today();
		so.Legal_Check__c = 'Approved';
		so.Counter_Sign_IO__c = 'Approved';
		so.From_Date_Time_Calculated__c = Date.today().addDays(4);
		insert so;

		so = (csmso__Sales_Order__c) sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c', 'Id= \'' + so.Id + '\'', 1, true)[0];

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				so
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

		for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
			pConfig.Sales_Order__c = so.Id;
		}
		update prodConfigs;

		List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1, new List<csmso__Sales_Order__c>{
				so
		}, new List<Account>{
				acc
		});

		List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1, fulfilment, prodConfigs);
		fulfilmentItem[0].csdf__Flight_Beginning__c = Date.today().addDays(4);
		fulfilmentItem[0].csdf__Type__c = 'Standard';
		fulfilmentItem[0].Served_By__c = 'DFP';
		update fulfilmentItem;

		cscfga__Product_Configuration__c pc = [
				SELECT Id, Sales_Order__c
				FROM cscfga__Product_Configuration__c
				LIMIT 1
		][0];

		System.runAs(ssystemAdminUser) {
			Test.startTest();
			Type stateManagerType = Type.forName(so.State_Manager_Class__c);
			CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase) stateManagerType.newInstance();
			stateManager.init(so);
			stateManager.validateChange();
			stateManager.getFieldProperties();
			Test.stopTest();
		}
	}

	@IsTest
	static void testDSOSMSystemAdminNoPermission() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		createSystemAdminUser();

		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		so.Order_Type__c = 'Direct Commercial';
		insert so;

		so = (csmso__Sales_Order__c) sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c', 'Id= \'' + so.Id + '\'', 1, true)[0];

		System.runAs(systemAdminUser) {
			Test.startTest();
			Type stateManagerType = Type.forName(so.State_Manager_Class__c);
			CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase) stateManagerType.newInstance();
			stateManager.init(so);
			stateManager.validateChange();
			stateManager.getFieldProperties();
			Test.stopTest();
		}
	}
}
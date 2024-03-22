@isTest
public with sharing class CS_P_OppBlockChangesTest {
	private static Account acc2;
	private static Opportunity opp;

	private static void createTestData() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
 string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;
		
		List<Account> accs = TestDataSetupTargetables.createAccounts(2);

		Account acc = accs[0];
          acc.RecordTypeID = accRectype;
        update acc;
		acc2 = accs[1];
		
		Account agency = TestDataSetupTargetables.createAccount();
		agency.Type = 'Media Agency';
        agency.RecordTypeID = accRectype;
		insert agency;
		
		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;
		
		opp = TestDataSetupTargetables.createOpportunity(acc, con);
		opp.AccountId = acc.id;
        opp.Media_Agency2__c = agency.id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        opp.Agency_Client_del__c = acc.id;
        opp.Subsidiary_Type__c = 'iPP';
		insert opp;
	
		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		so.csmso__Status__c = CS_const_SalesOrder.Status_PendingApprovals;
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
	public static void testBlockChanges() {
		createTestData();
        
        Account account = new Account();
        account.Name = 'test';
        account.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        insert account;
		
		Test.startTest();
		Map<Id, Opportunity> mapOld = new Map<Id, Opportunity>();
        opportunity opp1 = new opportunity();
        opp1 = [Select Id,AccountId ,Media_Agency2__c,RecordTypeId,Agency_Client_del__c ,Subsidiary_Type__c from opportunity where id =: opp.id];
		mapOld.put(opp1.Id, opp1);
		CS_P_OppBlockChanges process = new CS_P_OppBlockChanges(mapOld);

		String message;
	/*	try {
			opp.Agency_Client_del__c = acc2.Id;
			update opp;
			
		Opportunity	opp1 = 
			[
				SELECT	Id, 
						Name,
						AccountId,
						Media_Agency2__c,
						Agency_Client_del__c
				FROM	Opportunity 
				LIMIT	1
			];

			process.isRecordEligible(opp);
			process.logic();
		}
		catch (Exception e){
           message = e.getMessage();*/
        
        opp.AccountId = account.Id;
        update opp;
        process.isRecordEligible(opp);
        process.logic();
        
        
		Test.stopTest();

       // System.assert(message.contains('You can not change the Advertiser or Media Agency when a Sales Order is in an approval process. If you need to update this opportunity, recall your Sales Order.'), message);
	}
}
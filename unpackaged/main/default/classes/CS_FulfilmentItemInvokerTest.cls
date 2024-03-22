@isTest
public with sharing class CS_FulfilmentItemInvokerTest {
	@isTest
	public static void testInvoker1() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;

        cscfga__Configuration_Screen__c screenFlow = TestDataSetupTargetables.createConfigurationScreen(testProDef,'Default Screen');
        insert screenflow;
        
        Account[] accs = TestDataSetupBasic.createAccounts(2);   
        Contact[] cons = TestDataSetupBasic.createContacts(2, accs);
        Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs,cons);
        Opportunity opp = opps[0];
        Contact con = cons[0];
        
        csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(accs[0], opp);
        insert so;

        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        insert prodBasket;
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket );
        insert prodConfig;

        cscfga__Product_Configuration__c prodConfig2 = TestDataSetupTargetables.createProdConfig(prodBasket );
        insert prodConfig2;

        List<cscfga__Product_Configuration__c> prodConfigs = new List<cscfga__Product_Configuration__c>{prodConfig, prodConfig2};

        Set<Id> confIdSet = new Set<Id>();
        confIdSet.add(prodConfig.Id);
        confIdSet.add(prodConfig2.Id);

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},accs);

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);

        Test.startTest();
		CS_FulfilmentItemInvoker invokerHandler = new CS_FulfilmentItemInvoker();
		invokerHandler.performAction(JSON.serialize(confIdSet));

		Test.stopTest();

	}
}
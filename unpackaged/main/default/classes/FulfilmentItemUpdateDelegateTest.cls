@isTest
public with sharing class FulfilmentItemUpdateDelegateTest {
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
        
        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so,accs.get(0));
        insert testFulfilment;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
        testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
        insert testFulfilmentItem;

        Test.startTest();
        
        FulfilmentItemUpdateDelegate invokerHandler = new FulfilmentItemUpdateDelegate();
        FulfilmentItemUpdateDelegate.KvaParams param = new FulfilmentItemUpdateDelegate.KvaParams();
        param.fulfilmentItemId = testFulfilmentItem.Id;
        param.kva = '';
        invokerHandler.performAction(JSON.serialize(param));

        Test.stopTest();

    }
}
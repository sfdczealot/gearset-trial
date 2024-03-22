@isTest
private class CancelArchivePollActionInvokerTest {
	
	@isTest static void test_method_one() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

		Account acc = TestDataSetupBasic.createAccount();
        insert acc;
        
        Contact con = TestDataSetupBasic.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        insert so;
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        insert prodBasket;
        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so,acc);      
        insert testFulfilment;
    
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        insert prodConfig;
        
    	csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig,so,testFulfilment); 
        testFulfilmentItem.Product_Configuration__c = null;
        testFulfilmentItem.csdf__Availability_Check_Status__c ='Completed';
        testFulfilmentItem.csdf__Pause_Resume_Message_Status__c ='Completed';
        testFulfilmentItem.csdf__Cancel_Message_Status__c = 'Completed';
        insert testFulfilmentItem;              
        
        csam__Integration_Endpoint__c custSetting = new csam__Integration_Endpoint__c();
	    custSetting.Name = 'Ad Server Integration';
	    custSetting.csam__Callout_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
	    insert custSetting;
        
        csam__ObjectGraph_Callout_Handler__c testObjGrph_3 = TestDataSetupTargetables.createObjGrph();
        testObjGrph_3.Name = 'Fulfilment Availability Check';
        insert testObjGrph_3;
        
        Test.startTest();
        String parameters = JSON.serialize(testFulfilmentItem.Id);
        CancelArchivePollActionInvoker caPollClass = new CancelArchivePollActionInvoker();
        String str = caPollClass.performAction(parameters);
        Test.stopTest();
	}
	
	@isTest static void test_method_two() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

		Account acc = TestDataSetupBasic.createAccount();
        insert acc;
        
        Contact con = TestDataSetupBasic.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        insert so;
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        insert prodBasket;
        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so,acc);      
        insert testFulfilment;
    
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        insert prodConfig;
        
    	csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig,so,testFulfilment); 
        testFulfilmentItem.Product_Configuration__c = null;
        testFulfilmentItem.csdf__Availability_Check_Status__c ='Completed';
        testFulfilmentItem.csdf__Pause_Resume_Message_Status__c ='Completed';
        testFulfilmentItem.csdf__Cancel_Message_Status__c = 'Completed';
        insert testFulfilmentItem;              
        
        csam__Integration_Endpoint__c custSetting = new csam__Integration_Endpoint__c();
	    custSetting.Name = 'Ad Server Integration';
	    custSetting.csam__Callout_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
	    insert custSetting;
        
        csam__ObjectGraph_Callout_Handler__c testObjGrph_3 = TestDataSetupTargetables.createObjGrph();
        testObjGrph_3.Name = 'Fulfilment Availability Check';
        insert testObjGrph_3;
        
        Test.startTest();
        String parameters = JSON.serialize(testFulfilmentItem.Id);
        CancelArchivePollActionInvoker caPollClass = new CancelArchivePollActionInvoker();
        delete testFulfilmentItem;
        String str = caPollClass.performAction(parameters);
        DigitalFulfilmentAdapterUtil.availabilityCheckPoll(testFulfilmentItem.Id);
        Test.stopTest();
	}
	
}
@isTest
private class UpdateFulfilmentItemsSchedulerTest {
    
     static testmethod void testupdateFulfilmentItems_Single(){
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        Account acc = TestDataSetupTargetables.createAccount();
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
        insert so;

        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        insert prodBasket;

        csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
        insert testAdServer;

        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so,acc);        
        insert testFulfilment;

        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        insert prodConfig;
        
        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig,so,testFulfilment); 
        testFulfilmentItem.Product_Configuration__c = null;
        insert testFulfilmentItem; 

        csam__Integration_Endpoint__c custSetting = new csam__Integration_Endpoint__c();
        custSetting.Name = 'Ad Server Availability Check';
        custSetting.csam__Callout_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
        insert custSetting;
        
        csam__ObjectGraph_Callout_Handler__c testObjGrph = TestDataSetupTargetables.createObjGrph();
        testObjGrph.Name = 'Fulfilment Item Refresh';
        testObjGrph.csam__Integration_Endpoint_Name__c = 'Ad Server Availability Check';
        insert testObjGrph; 
   
        TestDataSetupTargetables.createCSCustomSettings();
        TestDataSetupTargetables.createObjGrph();
        Test.startTest();
        UpdateFulfilmentItemsScheduler.scheduleIt();
        Test.stopTest();
    }
    
    @isTest 
    static void test_method_two() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
        cs.Integration_Chunk_Size__c = 10;
        insert cs;
    
        Database.BatchableContext bc;
        List<sObject> scope= new list<sObject>();
        UpdateFulfilmentItemsBatch batch = new UpdateFulfilmentItemsBatch();
        Test.startTest();
        batch.execute(bc,scope);
        Test.stopTest();
    }
    
}
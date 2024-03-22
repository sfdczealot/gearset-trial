@isTest
private class AttributeArchiveBatchTest {
	
	@Istest 
    public static void BatchArchiveTest()
   {
       /*
       csmso__Sales_Order__c so = setup();
       so.Can_archive__c = true;
       update so;
        
        cscfga__product_Configuration__c[] pc = [select id from cscfga__product_Configuration__c];
    
       AttributeArchiveBatch batch = new AttributeArchiveBatch();
       Database.BatchableContext bc;
       
       cscfga__Attribute__c[] attsbefore = [select id from cscfga__Attribute__c];
  
       batch.execute(bc, pc);
       cscfga__Attribute__c[] attsAfter = [select id from cscfga__Attribute__c];
       attachment[] attx = [select Id from attachment];
       */
   }
	@isTest 
    public static void Setup(){
        insert new CSSX__No_Triggers__c(cssx__Flag__c = true, setupownerid = Userinfo.getOrganizationId());
        
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        Account acc = TestDataSetupBasic.createAccount();
        insert acc;
        
        Contact con = TestDataSetupBasic.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c testSalesOrder= TestDataSetupSO.createSalesOrder(acc, opp);
        insert testSalesOrder;
        
        testSalesOrder.Can_archive__c = true;
        update testSalesOrder;
        
        cscfga__Product_basket__c basket = new cscfga__Product_basket__c();
        basket.csmso__Sales_Order__c = testSalesOrder.Id;
        insert basket;
        
        cscfga__product_Configuration__c config = TestDataSetupSO.createproductConfigAndDef('test');
        config.Sales_order__c = testSalesOrder.id;
        config.cscfga__Product_basket__c = basket.Id;
        config.JSON_Archive_Id__c = '';
        update config;
        
        AttributeArchiveBatch batch = new AttributeArchiveBatch();
        Database.BatchableContext bc;

        
        cscfga__Attribute__c[] attsbefore = [select id from cscfga__Attribute__c];
        Test.startTest();
        List<cscfga__product_Configuration__c> pcs = [SELECT Id, cscfga__product_basket__r.csmso__Sales_Order__c, Is_archived__c FROM cscfga__product_Configuration__c LIMIT 1];
        System.debug('osvaldo' + pcs);
        batch.start(bc);
        batch.execute(bc, pcs);
        batch.finish(bc);
        cscfga__Attribute__c[] attsAfter = [select id from cscfga__Attribute__c];
        attachment[] attx = [select Id from attachment];
        Test.stopTest();
    }
}
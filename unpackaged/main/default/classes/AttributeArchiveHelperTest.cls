@isTest
private class AttributeArchiveHelperTest {

	@isTest
    public static void ArchiveProductConfigsTest(){
        csmso__Sales_Order__c so = setup();
        so.Can_archive__c = true;
        update so;
        
        List<cscfga__Product_Configuration__c> prodConfigs = [select id, Is_archived__c, cscfga__product_basket__r.csmso__Sales_Order__c, (select cscfga__Attribute__c.Id from cscfga__Attributes__r)
        from cscfga__Product_Configuration__c LIMIT 1];

        CS_Custom_Settings__c setting = new CS_Custom_Settings__c();
        setting.Sync_Retraction_SOLI_Limit__c = 1;
        insert setting;
        
        AttributeArchiveHelper.prepareWork(so.Id, prodConfigs, 'restore');        

        SchedulableContext sc;
        AttributeArchiveHelper helper = new AttributeArchiveHelper(so.Id);
        helper.execute(sc);
        AttributeArchiveHelper.archiveProductConfigs(prodConfigs);
   	}

	@isTest
   	public static void ArchiveAttributesRestoreTest(){
        csmso__Sales_Order__c so = setup();
        so.Can_archive__c = true;
        update so;
           
        AttributeArchiveHelper.restoreSalesOrderConfigs(so.Id);
        cscfga__Attribute__c[] attsAfterRest = [select id from cscfga__Attribute__c];
        attachment[] attxAfterRest = [select Id from attachment];
       
        List<cscfga__Product_Configuration__c> prodConfigs = [select id, Is_archived__c, cscfga__product_basket__r.csmso__Sales_Order__c from cscfga__Product_Configuration__c];
       
        Attachment attach=new Attachment();       
        attach.Name='Attribute_JSON.json';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=prodConfigs[0].id;
        insert attach;
        
        prodConfigs[0].JSON_Archive_Id__c = attach.id;
        update prodConfigs;
        
        prodConfigs = [select id, Is_archived__c, cscfga__product_basket__r.csmso__Sales_Order__c from cscfga__Product_Configuration__c];
        String oType = 'Account';
       
        AttributeArchiveHelper helper = new AttributeArchiveHelper(so.Id);
        helper.restoreSalesOrderConfigs(prodConfigs);
        AttributeArchiveHelper.CS_AttributeArchiveHelperWorker helperWorker = new AttributeArchiveHelper.CS_AttributeArchiveHelperWorker(new Map<String, Object> {
                'type' => oType,
                'salesOrderId' => so.Id,
                'productConfigurationList' => prodConfigs
            });
        helperWorker.doWork();
   	}

	@isTest 
    public static csmso__Sales_Order__c Setup(){

        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
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
        testSalesOrder.never_archive__c = false;
        update testSalesOrder;
        
        cscfga__Product_basket__c basket = new cscfga__Product_basket__c();
        basket.csmso__Sales_Order__c = testSalesOrder.Id;
        insert basket;
        
        cscfga__product_Configuration__c config = TestDataSetupSO.createproductConfigAndDef('test');
        config.Sales_order__c = testSalesOrder.id;
        config.cscfga__Product_basket__c = basket.Id;
        upsert config;
        
        cscfga__product_Configuration__c configTwo = TestDataSetupSO.createproductConfigAndDef('testTwo');
        configTwo.Sales_order__c = testSalesOrder.id;
        configTwo.cscfga__Product_basket__c = basket.Id;
        upsert configTwo; 
        
        List<cscfga__Product_Definition__c> pds = [select id from cscfga__Product_Definition__c];
        List<cscfga__product_Configuration__c> pcs = [select id, cscfga__product_basket__r.csmso__Sales_Order__c from cscfga__product_Configuration__c];
        List<cscfga__Attribute_Definition__c> attDef = TestDataSetupSO.createAttributeDefinitions(1, pds);
        List<cscfga__Attribute__c> atts = TestDataSetupSO.createAttributes(1, pcs, attDef);
        return  testSalesOrder;
    }
	
}
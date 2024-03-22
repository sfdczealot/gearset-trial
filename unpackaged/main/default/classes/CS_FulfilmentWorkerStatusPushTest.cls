@isTest
public class CS_FulfilmentWorkerStatusPushTest {
	private static csmso__Sales_Order__c salesOrder;
	private static csdf__Fulfilment__c testFulfilment;

	private static void createTestData() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        CS_Custom_Settings__c csCustomSettings = new CS_Custom_Settings__c(Integration_Chunk_Size__c = 1, Integration_Delay_Between_Callouts__c = 0);
        upsert csCustomSettings;

    	Account acc = TestDataSetupTargetables.createAccount();
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);        
        insert testAttrDef;
        
        salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = CS_const_SalesOrder.Status_PendingBooking;
        salesOrder.Applicable_IO_Volume_Discount_Range__c =1;
    	salesOrder.Primary_Sales_Order__c = true;
        insert salesOrder;

        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;

        testFulfilment = TestDataSetupTargetables.createFulfilment(salesOrder,acc);
        insert testFulfilment;

        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Sales_Order__c = salesOrder.Id;
        insert prodConfig;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, salesOrder, testFulfilment);
        insert testFulfilmentItem;
	}
	
	@isTest
    public static void testFulfilmentWorkerStatusPushSOBooked() {
        createTestData();

        CS_utl_User.enableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi2 = [SELECT Id FROM csmso__SalesOrderAPI__c LIMIT 1];
		delete soapi2;

        Test.startTest();

        salesOrder.csmso__Status__c = CS_const_SalesOrder.Status_Booked;
        update salesOrder;
        
        Test.stopTest();
    }

    @isTest
    public static void testFulfilmentWorkerStatusPushDoWork() {
    	csam__Integration_Endpoint__c integrationEndpoint = new csam__Integration_Endpoint__c(Name = 'Ad Server Integration');
        integrationEndpoint.csam__Callout_Host__c = 'CS';
        insert integrationEndpoint;

    	createTestData();

    	csam__ObjectGraph_Callout_Handler__c objectGraphCalloutHandler = new csam__ObjectGraph_Callout_Handler__c();
        objectGraphCalloutHandler.Name = 'SO Status Push';
        objectGraphCalloutHandler.csam__Method__c = 'PUT';
        objectGraphCalloutHandler.csam__Integration_Endpoint_Name__c = 'Ad Server Integration';
        objectGraphCalloutHandler.csam__URL_Path__c = '/services/adserver/fulfilment/new';
        objectGraphCalloutHandler.csam__Startpoint_Type_Name__c = 'csdf__Fulfilment__c';
        insert objectGraphCalloutHandler;

    	CS_FulfilmentWorkerStatusPush fulfilmentWorkerStatusPush = new CS_FulfilmentWorkerStatusPush(new Map<String, Object> {
			'handlerType' => 'SO Status Push',
			'fulfilmentIds' => new List<Id>{testFulfilment.Id},
            'spinWaitBeforeCallout_ms' => 1
		});
    	fulfilmentWorkerStatusPush.doWork();
    }
}
/**
* Test Class to for CloudSense Class,  UpdateFulfilmentItemsBatch
 */
@isTest
private class UpdateFulfilmentItemsBatchTests {

    static testMethod void testFulfilmentBatchStart() {

		//SetupData();

		UpdateFulfilmentItemsBatch batch = new UpdateFulfilmentItemsBatch();

		test.startTest();
		
		Database.BatchableContext bc = null;
		Database.QueryLocator locator = batch.start(bc);
		
		
		System.Assert( locator.iterator() != null);
		test.stopTest();
        
    }
    
     static testMethod void testExecute() {

		//SetupData();

		UpdateFulfilmentItemsBatch batch = new UpdateFulfilmentItemsBatch();

		test.startTest();
		
		Database.BatchableContext bc = null;
		
		sObject[] objects = [SELECT Id, Name FROM csdf__Fulfilment__c ];
		batch.execute(bc, objects);
		
		batch.finish(bc);
		
		test.stopTest();
		
		csdf__Fulfilment_Item__c[] fis = [SELECT Id, Name, csdf__Fulfilment__r.Sales_Order__r.Last_Date_Booked__c,
                    csdf__Fulfilment__r.Sales_Order__r.Last_Date_Retracted__c, csdf__status__c
             		FROM csdf__Fulfilment_Item__c];

		//system.assert(fis[0].csdf__status__c == 'Waiting');


	
        
        
  
    }
    
    
    
    @testsetup
    static void setupData()
    {
    	
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;

        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;

        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;

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
        
        cscfga__Product_Configuration__c config = TestDataSetupTargetables.createProdConfig(ProdBasket);
        insert config;
        
 
 		csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
        insert testAdServer;

 
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so,acc);
        system.debug('#####' +testFulfilment );
        testFulfilment.csdf__Ad_Server_Id__c = '123499';
        testFulFilment.csdf__Ad_server__c = testAdServer.Id;
        testFulfilment.csdf__Status__c = 'Ready';
        
       
        insert testFulfilment;
        
     	CSSX__No_Triggers__c notriggers = new CSSX__No_Triggers__c();
    		notriggers.cssx__Flag__c = true;
    		insert notriggers;
    
    		CS_Custom_Settings__c settings = new CS_Custom_Settings__c();
    		settings.Integration_Chunk_Size__c = 1024;
    		settings.Integration_Delay_Between_Callouts__c = 60;
    		insert settings;
    
    
        //if (notriggers == null || !notriggers.cssx__Flag__c) 
     
        csdf__Fulfilment_Item__c fi = TestDataSetupTargetables.createFulfilmentItem(config  ,so,  testFulfilment  );
        fi.csdf__status__c = 'Ready';
        fi.Served_by__c = 'DFP';
        fi.Product_Configuration__c = null;
        fi.csdf__Ad_Server_Id__c = '123456999';
    
        insert fi;
        
      
    		//notriggers.cssx__Flag__c = false;
    		//update notriggers;
     }
    
    
    
}
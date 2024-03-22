@isTest
private class CS_BatchConsolidateActualsTest {
	
	@isTest(seeAllData=false)
    static void testBatchConsolidateActuals() {

    	CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        Account[] accs = TestDataSetupBasic.createAccounts(5);   
        Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
        Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs,cons);

        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opps[0].Id;
        salesOrder.SO_Lines_All_Valid__c = true;
        insert salesOrder;

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);
        
        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1,prodDef);
        
        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1,new List<csmso__Sales_Order__c>{salesOrder});
        
        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1,prodBaskets,prodDef);

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{salesOrder},accs);

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        List<CS_Sales_Order_Schedule__c> salesOrderSchedules = new List<CS_Sales_Order_Schedule__c>();
        
        CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
        sos.sales_order__c = salesOrder.id;
        insert sOs;
        
        CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
        bScheduleHeader.CS_Sales_Order_Schedule__c = sOs.id;
        bScheduleHeader.Under_IFC__c = true;
        insert bScheduleHeader;

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = salesOrder.id;
            pConfig.Reserve_Inventory__c = true;
            pConfig.Inventory_Available__c = 'Yes';
            //pConfig.Fulfilment_Item__c = fulfilmentItem[0].Id;
        }
        update prodConfigs;

        cscfga__Product_Configuration__c pc = [SELECT Id, Sales_Order__c 
                                                    FROM cscfga__Product_Configuration__c 
                                                    LIMIT 1][0];
        
        CS_Billing_Schedule_Item__c bschedule = new CS_Billing_Schedule_Item__c();
        bSchedule.Product_Configuration__c = pc.id;
        bSchedule.Status__c = 'Locked';
        bSchedule.Sales_Order__c = pc.Sales_Order__c;
        bSchedule.DFP_Actuals__c = 100;
        bSchedule.Net_Rate__c = 100.0;
        bSchedule.Billing_Period_Start_Date__c = Date.Today().addDays(-4);
        bSchedule.Billing_Period_End_Date__c = Date.Today().addDays(4);
        bschedule.billing_schedule__c=bScheduleHeader.id;
        insert bSchedule;
        
        Test.startTest();
        CS_BatchConsolidateActuals batchConsolidateActuals = new CS_BatchConsolidateActuals();
        batchConsolidateActuals.onStart();
		batchConsolidateActuals.doWork(new List<SObject>{sOs});
        Test.stopTest();
    }

	@isTest(seeAllData=false)
    static void testBatchConsolidateActuals_prepareWork() {
        CS_Custom_Settings__c settings = new CS_Custom_Settings__c(Consolidation_Size__c = 1);
        insert settings;
        
    	CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        Account[] accs = TestDataSetupBasic.createAccounts(5);   
        Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
        Opportunity[] opps = TestDataSetupBasic.createOpportunities(5, accs,cons);

        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opps[0].Id;
        salesOrder.SO_Lines_All_Valid__c = true;
        insert salesOrder;

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);
        
        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1,prodDef);
        
        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1,new List<csmso__Sales_Order__c>{salesOrder});
        
        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1,prodBaskets,prodDef);

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{salesOrder},accs);

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        List<CS_Sales_Order_Schedule__c> salesOrderSchedules = new List<CS_Sales_Order_Schedule__c>();
        
        CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
        sos.sales_order__c = salesOrder.id;
        insert sOs;
        
        CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
        bScheduleHeader.CS_Sales_Order_Schedule__c = sOs.id;
        bScheduleHeader.Under_IFC__c = true;
        insert bScheduleHeader;

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = salesOrder.id;
            pConfig.Reserve_Inventory__c = true;
            pConfig.Inventory_Available__c = 'Yes';
            //pConfig.Fulfilment_Item__c = fulfilmentItem[0].Id;
        }
        update prodConfigs;

        cscfga__Product_Configuration__c pc = [SELECT Id, Sales_Order__c 
                                                    FROM cscfga__Product_Configuration__c 
                                                    LIMIT 1][0];
        
        CS_Billing_Schedule_Item__c bschedule = new CS_Billing_Schedule_Item__c();
        bSchedule.Product_Configuration__c = pc.id;
        bSchedule.Status__c = 'Locked';
        bSchedule.Sales_Order__c = pc.Sales_Order__c;
        bSchedule.DFP_Actuals__c = 100;
        bSchedule.Net_Rate__c = 100.0;
        bSchedule.Billing_Period_Start_Date__c = Date.Today().addDays(-4);
        bSchedule.Billing_Period_End_Date__c = Date.Today().addDays(4);
        bschedule.billing_schedule__c=bScheduleHeader.id;
        insert bSchedule;
        
        Test.startTest();
        CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();

        CS_BatchConsolidateActuals.prepareWork(dispatcher, new List<SObject>{bSchedule}, new Set<Id>{salesOrder.Id}, Date.today(), 'CS_ActualsService.CS_BillingActualsService');
		dispatcher.dispatch();

        Test.stopTest();
    }
}
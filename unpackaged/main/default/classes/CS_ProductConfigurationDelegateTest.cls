@isTest
private class CS_ProductConfigurationDelegateTest {
    
    @testSetup 
    public static void  setupCommonData() {  
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);        
        insert testAttrDef;
        
        Account acc = TestDataSetupTargetables.createAccount();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();

        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
        so.SO_Lines_Gross_Total__c = 6;
        so.Flighting_Pending_Check_Avail__c = false;
        so.SO_Lines_All_Valid__c = true;                                
        insert so;
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        insert prodBasket;
                        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so,acc);      
        insert testFulfilment;   
    }
        
    @isTest 
    public static void CS_ProductConfigurationTrigger_method2() {
        csmso__Sales_Order__c salesOrder = [SELECT id, name, 
                                                       From_Calculated__c, 
                                                       To_Calculated__c, 
                                                       Flighting_Pending_Check_Avail__c, 
                                                       SO_Lines_All_Valid__c
                                                FROM csmso__Sales_Order__c LIMIT 1];

        csmso__Sales_Order__c soAux = [SELECT id, name, 
                                              SO_Lines_All_Valid__c,
                                              From_Calculated__c, 
                                              To_Calculated__c 
                                       FROM csmso__Sales_Order__c where Id = :salesOrder.Id];
        soAux.SO_Lines_All_Valid__c = true;
        update soAux;
        
        cscfga__Product_Basket__c prodBasket = [SELECT id, name from cscfga__Product_Basket__c LIMIT 1];

        cscfga__Product_Basket__c prodBasketAux = [SELECT id, name from cscfga__Product_Basket__c where Id = :prodBasket.Id];
        prodBasketAux.csmso__Sales_Order__c = soAux.Id;
        update prodBasketAux;
        
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasketAux);
        prodConfig.Sales_Order__c = soAux.Id;
        prodConfig.Insertion_Quantity__c = 5;
        prodConfig.csmso__Availability_Check_Status__c = 'From Flighting';
        prodConfig.cscfga__Configuration_Status__c = 'Incomplete';
        prodConfig.Flight_Begin__c = null;
        prodConfig.Flight_End__c = null;
        
        Test.startTest();
        
        insert prodConfig;
        
        cscfga__Product_Configuration__c pcTest = [SELECT id
                                                   FROM cscfga__Product_Configuration__c where id = :prodConfig.Id];
        pcTest.Flight_Begin__c = Date.newInstance(2018, 2, 2);
        pcTest.Flight_End__c = Date.newInstance(2018, 2, 5);
        update pcTest;

        Test.stopTest(); 
    }
    
    @isTest 
    public static void CS_ProductConfigurationTrigger_method3() {
        csmso__Sales_Order__c salesOrder = [SELECT id, name, 
                                                       From_Calculated__c, 
                                                       To_Calculated__c, 
                                                       Flighting_Pending_Check_Avail__c, 
                                                       SO_Lines_All_Valid__c
                                                FROM csmso__Sales_Order__c LIMIT 1];

        csmso__Sales_Order__c soAux = [SELECT id, name, SO_Lines_All_Valid__c, From_Calculated__c, To_Calculated__c from csmso__Sales_Order__c where Id = :salesOrder.Id];
        soAux.SO_Lines_All_Valid__c = false;
        soAux.From_Calculated__c = Date.newInstance(2018, 6, 17);
        soAux.To_Calculated__c = Date.newInstance(2018, 2, 3);
        update soAux;

        cscfga__Product_Basket__c prodBasket = [SELECT id, name from cscfga__Product_Basket__c LIMIT 1];
        
        cscfga__Product_Basket__c prodBasketAux = [SELECT id, name from cscfga__Product_Basket__c where Id = :prodBasket.Id];
        prodBasketAux.csmso__Sales_Order__c = soAux.Id;
        update prodBasketAux;
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasketAux);
        prodConfig.Sales_Order__c = soAux.Id;
        prodConfig.Insertion_Quantity__c = 5;
        prodConfig.csmso__Availability_Check_Status__c = 'Not Applicable';
        prodConfig.cscfga__Configuration_Status__c = 'Valid';
        prodConfig.Flight_Begin__c = null;
        prodConfig.Flight_End__c = null;
        
        Test.startTest();
        
        insert prodConfig;
        
        cscfga__Product_Configuration__c pcTest = [SELECT id
                                                   FROM cscfga__Product_Configuration__c where id = :prodConfig.Id];
        pcTest.Flight_Begin__c = Date.newInstance(2018, 2, 2);
        pcTest.Flight_End__c = Date.newInstance(2018, 2, 5);
        update pcTest;
        
        Test.stopTest(); 
    }
    
    @isTest 
    public static void  CS_ProductConfigurationTrigger_method4() {
        cscfga__Product_Basket__c prodBasket = [SELECT id, name from cscfga__Product_Basket__c LIMIT 1];

        csdf__Fulfilment__c fulfilment = [SELECT id, name from csdf__Fulfilment__c LIMIT 1];

        csmso__Sales_Order__c salesOrder = [SELECT id, name, 
                                                   From_Calculated__c, 
                                                   To_Calculated__c, 
                                                   Flighting_Pending_Check_Avail__c, 
                                                   SO_Lines_All_Valid__c
                                            FROM csmso__Sales_Order__c LIMIT 1];

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.sales_order__c = salesOrder.id;
        insert salesOrderSchedule;

        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Sales_Order__c = salesOrder.Id;
        insert prodConfig;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, salesOrder, fulfilment);
        testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
        insert testFulfilmentItem;

        //CS Biling Schedule
        CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
        bScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        bScheduleHeader.Under_IFC__c = true;
        insert bScheduleHeader;

        //CS Revenue Schedule
        CS_Revenue_Schedule__c rScheduleHeader = new CS_Revenue_Schedule__c();
        rScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        insert rScheduleHeader;
        
        //CS Biling Schedule Item
        CS_Billing_Schedule_Item__c bschedule = new CS_Billing_Schedule_Item__c();
        bSchedule.Product_Configuration__c = prodConfig.id;
        bSchedule.Status__c = 'Locked';
        bSchedule.Sales_Order__c = prodConfig.Sales_Order__c;
        bSchedule.DFP_Actuals__c = 100;
        bSchedule.Net_Rate__c = 100.0;
        bSchedule.DFP_Order_Line_ID__c = salesOrder.Id;
        bSchedule.Billing_Period_Start_Date__c = Date.Today().addDays(-4);
        bSchedule.Billing_Period_End_Date__c = Date.Today().addDays(4);
        bschedule.billing_schedule__c = bScheduleHeader.id;
        bschedule.DFP_Order_Line_ID__c = 'External ID Test 123';
        bschedule.X3rd_Party_Ad_Server__c = 'Test Server Name';
        insert bSchedule;

        //CS Revenue Schedule Item
        CS_Revenue_Schedule_Item__c rSchedule = new CS_Revenue_Schedule_Item__c();
        rSchedule.Sales_Order__c = prodConfig.Sales_Order__c;
        rSchedule.Product_Configuration__c = prodConfig.id;
        rSchedule.Status__c = 'Locked';
        rSchedule.Rev_Rec_Period_Start_Date__c = Date.Today().addDays(-4);
        rSchedule.Rev_Rec_Period_End_Date__c = Date.Today().addDays(4);
        rSchedule.Revenue_Schedule__c = rScheduleHeader.Id;
        insert rSchedule;
        
        Test.startTest();
        CS_ProductConfigurationDelegate prodConfigDelegate = new CS_ProductConfigurationDelegate();
        prodConfigDelegate.beforeDelete(prodConfig);
        prodConfigDelegate.finish();
        prodConfig.Fulfilment_Item_Status__c='Active';
        prodConfig.cscfga__package_guid__c = '123';
        update prodConfig;
        CS_utl_User.enableAllTriggers(UserInfo.getUserId());
        try{
           delete prodConfig;
        }
        catch(Exception e){}
         prodConfig.Fulfilment_Item_Status__c='draft';
         update prodConfig;
         delete prodConfig;
         CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        Test.stopTest();
    }
    
    @isTest 
    public static void  CS_ProductConfigurationTrigger_method5() {
        CSSX__No_Triggers__c notriggers = new CSSX__No_Triggers__c();
        notriggers.cssx__Flag__c = true;
        insert notriggers;
        
        cscfga__Product_Basket__c prodBasket = [SELECT id, name from cscfga__Product_Basket__c LIMIT 1];

        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        
        Test.startTest();
        insert prodConfig;
        Test.stopTest(); 
    }  

    @isTest 
    public static void  CS_ProductConfigurationTrigger_methodIncomplete() {
        cscfga__Product_Basket__c prodBasket = [SELECT id, name from cscfga__Product_Basket__c LIMIT 1];

        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.cscfga__Configuration_Status__c = 'Incomplete';
        insert prodConfig;
        
        csdf__Fulfilment__c fulfilment = [SELECT id, name from csdf__Fulfilment__c LIMIT 1];

        csmso__Sales_Order__c salesOrder = [SELECT id, name, 
                                                   From_Calculated__c, 
                                                   To_Calculated__c, 
                                                   Flighting_Pending_Check_Avail__c, 
                                                   SO_Lines_All_Valid__c
                                            FROM csmso__Sales_Order__c LIMIT 1];

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, salesOrder, fulfilment);
        testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
        insert testFulfilmentItem;
        
        Test.startTest();
        CS_ProductConfigurationDelegate prodConfigDelegate = new CS_ProductConfigurationDelegate();
        prodConfigDelegate.beforeInsert(prodConfig);
        prodConfigDelegate.afterInsert(prodConfig);
        Test.stopTest();
    }

    @isTest 
    public static void  CS_ProductConfigurationTrigger_methodValid() {
        cscfga__Product_Basket__c prodBasket = [SELECT id, name from cscfga__Product_Basket__c LIMIT 1];

        cscfga__Screen_Flow__c screenFlow = new cscfga__Screen_Flow__c();
        screenFlow.Name = 'Test Screen Flow';
        screenFlow.cscfga__Template_Reference__c = 'Test Template Reference';
        insert screenFlow;

        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.cscfga__Configuration_Status__c = 'Valid';
        prodConfig.cscfga__Screen_Flow__c = screenFlow.Id;
        insert prodConfig;
        
        csdf__Fulfilment__c fulfilment = [SELECT id, name from csdf__Fulfilment__c LIMIT 1];

        csmso__Sales_Order__c salesOrder = [SELECT id, name, 
                                                   From_Calculated__c, 
                                                   To_Calculated__c, 
                                                   Flighting_Pending_Check_Avail__c, 
                                                   SO_Lines_All_Valid__c
                                            FROM csmso__Sales_Order__c LIMIT 1];

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, salesOrder, fulfilment);
        testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
        insert testFulfilmentItem;
        
        Test.startTest();
        CS_ProductConfigurationDelegate prodConfigDelegate = new CS_ProductConfigurationDelegate();
        prodConfigDelegate.beforeUpdate(prodConfig, prodConfig);
        Test.stopTest();
    }
}
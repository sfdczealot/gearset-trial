/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description : Test Class for CS_utl_SalesOrder
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author     : Kalyan Erraguntla <kalyan.erraguntla@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

@IsTest
public class CS_utl_SalesOrderTest {
    /**
* Checks if Sales Order is in progress
*/
    @IsTest
    public static void test_isInProgress() {
        Account acc = TestDataSetupTargetables.createAccount();
        Id recordTypeId = CS_utl_RecordType.getRecordTypeId(Account.getSObjectType(), 'B2B - Account');
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'Trigger_OpportunitySplit';
        TE.Enable_del__c = true;
        Insert TE;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.Subsidiary_Type__c = 'iPP';
        insert opp;
        
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'Booked';
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Advertiser_Final__c = acc.Id;
        salesorder.Approval_Requester_Comment__c='true';
        insert salesOrder;
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;
        
        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.IO_Volume_Discount_Range_1__c = 10;
        prodConfig.Revenue_Schedule_Rule__c = rScheduleRule.Id;
        insert prodConfig;
        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(salesOrder, acc);
        insert testFulfilment;
        
        Test.startTest();
        System.assertEquals(CS_utl_SalesOrder.isInProgress(salesOrder), false);
        System.assertEquals(CS_utl_SalesOrder.areSchedulesApplicable(salesOrder), true);
        System.assertEquals(CS_utl_SalesOrder.isRetracted(salesOrder), false);
        System.assertEquals(salesOrder.csmso__Status__c, 'Booked');
        Test.stopTest();
    }
    
    /**
* Gets Product Configurations based on Sales Order Ids
*/
    @IsTest
    public static void test_getProductConfigurations() {
        Account acc = TestDataSetupTargetables.createAccount();
        Id recordTypeId = CS_utl_RecordType.getRecordTypeId(Account.getSObjectType(), 'B2B - Account');
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'Trigger_OpportunitySplit';
        TE.Enable_del__c = true;
        Insert TE;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.Subsidiary_Type__c = 'iPP';
        insert opp;
        
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'Draft';
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        salesOrder.csmso__Status__c = 'Draft';
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Advertiser_Final__c = acc.Id;
        salesorder.Approval_Requester_Comment__c='true';
        insert salesOrder;
        
        Set<Id> salesOrderIds = new Set<Id>();
        salesOrderIds.add(salesOrder.Id);
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;
        
        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.IO_Volume_Discount_Range_1__c = 10;
        prodConfig.Revenue_Schedule_Rule__c = rScheduleRule.Id;
        prodConfig.Sales_Order__c = salesOrder.Id;
        insert prodConfig;
        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(salesOrder, acc);
        insert testFulfilment;
        
        Test.startTest();
        System.assertEquals(CS_utl_SalesOrder.getProductConfigurations(salesOrderIds).size(), 1);
        Test.stopTest();
    }
    
    
    /**
* Gets Sales Order Schedules based on Sales Order Ids
*/
    @IsTest
    public static void test_getSalesOrderSchedules() {
        Account acc = TestDataSetupTargetables.createAccount();
        Id recordTypeId = CS_utl_RecordType.getRecordTypeId(Account.getSObjectType(), 'B2B - Account');
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'Trigger_OpportunitySplit';
        TE.Enable_del__c = true;
        Insert TE;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.Subsidiary_Type__c = 'iPP';
        insert opp;
        
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'Draft';
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        salesOrder.csmso__Status__c = 'Draft';
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Advertiser_Final__c = acc.Id;
        salesorder.Approval_Requester_Comment__c='true';
        insert salesOrder;
        
        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.Id;
        insert salesOrderSchedule;
        
        Set<Id> salesOrderIds = new Set<Id>();
        salesOrderIds.add(salesOrder.Id);
        
        Set<Id> opportunityIds = new Set<Id>();
        opportunityIds.add(opp.Id);
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;
        
        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.IO_Volume_Discount_Range_1__c = 10;
        prodConfig.Revenue_Schedule_Rule__c = rScheduleRule.Id;
        prodConfig.Sales_Order__c = salesOrder.Id;
        insert prodConfig;
        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(salesOrder, acc);
        insert testFulfilment;
        
        Test.startTest();
        System.assertEquals(CS_utl_SalesOrder.getSalesOrderSchedules(salesOrderIds, opportunityIds).size(), 1);
        Test.stopTest();
    }
    
    @IsTest
    public static void test_killSalesOrder() {
        Account acc = TestDataSetupTargetables.createAccount();
        Id recordTypeId = CS_utl_RecordType.getRecordTypeId(Account.getSObjectType(), 'B2B - Account');
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'Trigger_OpportunitySplit';
        TE.Enable_del__c = true;
        Insert TE;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.Subsidiary_Type__c = 'iPP';
        insert opp;
        
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'Draft';
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        salesOrder.csmso__Status__c = 'Draft';
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Advertiser_Final__c = acc.Id;
        salesorder.Approval_Requester_Comment__c='true';
        insert salesOrder;
        
        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.Id;
        insert salesOrderSchedule;
        
        Set<Id> salesOrderIds = new Set<Id>();
        salesOrderIds.add(salesOrder.Id);
        
        Set<Id> opportunityIds = new Set<Id>();
        opportunityIds.add(opp.Id);
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;
        
        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.IO_Volume_Discount_Range_1__c = 10;
        prodConfig.Revenue_Schedule_Rule__c = rScheduleRule.Id;
        prodConfig.Sales_Order__c = salesOrder.Id;
        insert prodConfig;
        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(salesOrder, acc);
        insert testFulfilment;
        
        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, salesOrder, testFulfilment);
        insert testFulfilmentItem;
        
        CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
        sOs.Sales_Order__c = salesOrder.Id;
        insert sOs;
        
        CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
        bs.CS_Sales_Order_Schedule__c = sOs.Id;
        bs.Under_IFC__c = false;
        insert bs;
        
        CS_Billing_Schedule_Item__c bsi = new CS_Billing_Schedule_Item__c();
        bsi.Sales_Order__c = salesOrder.Id;
        bsi.Billing_Period_Start_Date__c = Date.today().addDays(-10);
        bsi.Billing_Period_End_Date__c = Date.today().addDays(5);
        bsi.Billing_Schedule__c = bs.Id;
        bsi.DFP_Order_Line_ID__c = '12345';
        insert bsi;
        
        CS_Revenue_Schedule__c rScheduleHeader = new CS_Revenue_Schedule__c();
        rScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        insert rScheduleHeader;
        
        CS_Revenue_Schedule_Item__c rsi = new CS_Revenue_Schedule_Item__c();
        rsi.Sales_Order__c = prodConfig.Sales_Order__c;
        rsi.Product_Configuration__c = prodConfig.Id;
        rsi.Status__c = 'Locked';
        rsi.Rev_Rec_Period_Start_Date__c = Date.today().addDays(-4);
        rsi.Rev_Rec_Period_End_Date__c = Date.today().addDays(4);
        rsi.Revenue_Schedule__c = rScheduleHeader.Id;
        rsi.DFP_Order_Line_ID__c = 'External ID Test 123';
        rsi.Flight_Begin_GMT__c = System.now().addDays(-4);
        rsi.Flight_End_GMT__c = System.now().addDays(4);
        rsi.Insertion_Unit_Type__c = 'CPC';
        insert rsi;
        
        Test.startTest();
        CS_utl_SalesOrder.killSalesOrder(salesOrder, new Map<Id, cscfga__Product_Configuration__c>{prodConfig.Id => prodConfig},
                                         new List<csdf__Fulfilment_Item__c>{testFulfilmentItem}, new List<CS_Billing_Schedule_Item__c>{bsi},
                                         new List<CS_Revenue_Schedule_Item__c>{rsi});
        Test.stopTest();
    }
    
  /*  @IsTest
    public static void test_killSalesOrderSold() {
        Account acc = TestDataSetupTargetables.createAccount();
        Id recordTypeId = CS_utl_RecordType.getRecordTypeId(Account.getSObjectType(), 'B2B - Account');
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'Trigger_OpportunitySplit';
        TE.Enable_del__c = true;
        Insert TE;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;
        
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'Draft';
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        salesOrder.csmso__Status__c = 'Draft';
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Advertiser_Final__c = acc.Id;
        salesOrder.Sold__c = true;
        insert salesOrder;
        
        csmso__Sales_Order__c salesOrder2 = new csmso__Sales_Order__c();
        salesOrder2.csmso__Opportunity__c = opp.Id;
        salesOrder2.isTestRunning__c = true;
        salesOrder2.SO_Lines_All_Valid__c = true;
        salesOrder2.csmso__Status__c = 'Draft';
        salesOrder2.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder2.Primary_Sales_Order__c = true;
        salesOrder2.csmso__Status__c = 'Draft';
        salesOrder2.csmso__Advertiser__c = acc.Id;
        salesOrder2.Advertiser_Final__c = acc.Id;
        insert salesOrder2;
        
        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.Id;
        insert salesOrderSchedule;
        
        Set<Id> salesOrderIds = new Set<Id>();
        salesOrderIds.add(salesOrder.Id);
        
        Set<Id> opportunityIds = new Set<Id>();
        opportunityIds.add(opp.Id);
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;
        
        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.IO_Volume_Discount_Range_1__c = 10;
        prodConfig.Revenue_Schedule_Rule__c = rScheduleRule.Id;
        prodConfig.Sales_Order__c = salesOrder.Id;
        insert prodConfig;
        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(salesOrder, acc);
        insert testFulfilment;
        
        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, salesOrder, testFulfilment);
        insert testFulfilmentItem;
        
        CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
        sOs.Sales_Order__c = salesOrder.Id;
        insert sOs;
          Test.startTest();
        CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
        bs.CS_Sales_Order_Schedule__c = sOs.Id;
        bs.Under_IFC__c = false;
        insert bs;
      
        CS_Billing_Schedule_Item__c bsi = new CS_Billing_Schedule_Item__c();
        bsi.Sales_Order__c = salesOrder.Id;
        bsi.Billing_Period_Start_Date__c = Date.today().addDays(-10);
        bsi.Billing_Period_End_Date__c = Date.today().addDays(5);
        bsi.Billing_Schedule__c = bs.Id;
        bsi.DFP_Order_Line_ID__c = '12345';
        insert bsi;
        
        CS_Revenue_Schedule__c rScheduleHeader = new CS_Revenue_Schedule__c();
        rScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        insert rScheduleHeader;
        
        CS_Revenue_Schedule_Item__c rsi = new CS_Revenue_Schedule_Item__c();
        rsi.Sales_Order__c = prodConfig.Sales_Order__c;
        rsi.Product_Configuration__c = prodConfig.Id;
        rsi.Status__c = 'Locked';
        rsi.Rev_Rec_Period_Start_Date__c = Date.today().addDays(-4);
        rsi.Rev_Rec_Period_End_Date__c = Date.today().addDays(4);
        rsi.Revenue_Schedule__c = rScheduleHeader.Id;
        rsi.DFP_Order_Line_ID__c = 'External ID Test 123';
        rsi.Flight_Begin_GMT__c = System.now().addDays(-4);
        rsi.Flight_End_GMT__c = System.now().addDays(4);
        rsi.Insertion_Unit_Type__c = 'CPC';
        insert rsi;
        
        bsi = [SELECT Id, Valid_for_Auto_Cancellation__c, Sales_Order__c, Billing_Period_Start_Date__c,
               Billing_Period_End_Date__c, Billing_Schedule__c, DFP_Order_Line_ID__c
               FROM CS_Billing_Schedule_Item__c
               LIMIT 1];
        
        rsi = [SELECT Id, Valid_for_Auto_Cancellation__c, Sales_Order__c, Product_Configuration__c, Status__c,
               Rev_Rec_Period_Start_Date__c, Rev_Rec_Period_End_Date__c, Revenue_Schedule__c,
               DFP_Order_Line_ID__c, Flight_Begin_GMT__c, Flight_End_GMT__c, Insertion_Unit_Type__c
               FROM CS_Revenue_Schedule_Item__c
               LIMIT 1];
        
        
        CS_utl_SalesOrder.killSalesOrder(salesOrder, new Map<Id, cscfga__Product_Configuration__c>{prodConfig.Id => prodConfig},
                                         new List<csdf__Fulfilment_Item__c>{testFulfilmentItem}, new List<CS_Billing_Schedule_Item__c>{bsi},
                                         new List<CS_Revenue_Schedule_Item__c>{rsi});
        Test.stopTest();
    }
    */
    @IsTest
    public static void test_killSalesOrderConfigNull() {
        Account acc = TestDataSetupTargetables.createAccount();
        Id recordTypeId = CS_utl_RecordType.getRecordTypeId(Account.getSObjectType(), 'B2B - Account');
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'Trigger_OpportunitySplit';
        TE.Enable_del__c = true;
        Insert TE;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.Subsidiary_Type__c = 'iPP';
        insert opp;
        
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'Draft';
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        salesOrder.csmso__Status__c = 'Draft';
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Advertiser_Final__c = acc.Id;
        insert salesOrder;
        
        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.Id;
        insert salesOrderSchedule;
        
        Set<Id> salesOrderIds = new Set<Id>();
        salesOrderIds.add(salesOrder.Id);
        
        Set<Id> opportunityIds = new Set<Id>();
        opportunityIds.add(opp.Id);
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;
        
        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.IO_Volume_Discount_Range_1__c = 10;
        prodConfig.Revenue_Schedule_Rule__c = rScheduleRule.Id;
        prodConfig.Sales_Order__c = salesOrder.Id;
        insert prodConfig;
        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(salesOrder, acc);
        insert testFulfilment;
        
        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, salesOrder, testFulfilment);
        insert testFulfilmentItem;
        
        CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
        sOs.Sales_Order__c = salesOrder.Id;
        insert sOs;
        
        CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
        bs.CS_Sales_Order_Schedule__c = sOs.Id;
        bs.Under_IFC__c = false;
        insert bs;
        
        CS_Billing_Schedule_Item__c bsi = new CS_Billing_Schedule_Item__c();
        bsi.Sales_Order__c = salesOrder.Id;
        bsi.Billing_Period_Start_Date__c = Date.today().addDays(-10);
        bsi.Billing_Period_End_Date__c = Date.today().addDays(5);
        bsi.Billing_Schedule__c = bs.Id;
        bsi.DFP_Order_Line_ID__c = '12345';
        insert bsi;
        
        CS_Revenue_Schedule__c rScheduleHeader = new CS_Revenue_Schedule__c();
        rScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        insert rScheduleHeader;
        
        CS_Revenue_Schedule_Item__c rsi = new CS_Revenue_Schedule_Item__c();
        rsi.Sales_Order__c = prodConfig.Sales_Order__c;
        rsi.Product_Configuration__c = prodConfig.Id;
        rsi.Status__c = 'Locked';
        rsi.Rev_Rec_Period_Start_Date__c = Date.today().addDays(-4);
        rsi.Rev_Rec_Period_End_Date__c = Date.today().addDays(4);
        rsi.Revenue_Schedule__c = rScheduleHeader.Id;
        rsi.DFP_Order_Line_ID__c = 'External ID Test 123';
        rsi.Flight_Begin_GMT__c = System.now().addDays(-4);
        rsi.Flight_End_GMT__c = System.now().addDays(4);
        rsi.Insertion_Unit_Type__c = 'CPC';
        insert rsi;
        
        Test.startTest();
        CS_utl_SalesOrder.killSalesOrder(salesOrder, null, new List<csdf__Fulfilment_Item__c>{testFulfilmentItem},
                                         new List<CS_Billing_Schedule_Item__c>{bsi}, new List<CS_Revenue_Schedule_Item__c>{rsi});
        Test.stopTest();
    }
}
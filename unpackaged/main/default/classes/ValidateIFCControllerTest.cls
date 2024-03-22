/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class for ValidateIFCController
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* @changes
* v0.1            aldo.topic@cloudsensesolutions.com
* 2018-12-05      Commented out Revenue_Recognition_Schedule__c legacy object. Class should be 
*                 changed to use new custom object (CS_Revenue_Schedule__c and 
*                 CS_Revenue_Schedule_Item__c).
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest(seeAllData=false)
public class ValidateIFCControllerTest {


    // Valid test method for IFCController
    @isTest
    public static void validateIFCControllerValidTest() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        //Account Creation.
        List<Account> Acc = TestDataSetupSO.createAccounts(1);

        //Contact Creation.
        List<Contact> con = TestDataSetupSO.createContacts(1,Acc);

        //Opportunity Creation.
        List<Opportunity> opp = TestDataSetupSO.createOpportunities(1,Acc,con);

        //SalesOrder Creation.
        List<csmso__Sales_Order__c> salesOrders = TestDataSetupSO.createSalesOrders(1,Acc,opp);

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1,prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1,salesorders);

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1,prodBaskets,prodDef);


        //Fulfilment Creation.
        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,salesorders,Acc);
        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            if(salesOrders.size()>0)
                pConfig.Sales_Order__c = salesOrders[0].id;
            pConfig.Billing_Schedule_Rule__c = bScheduleRule.id;
            pConfig.Revenue_Schedule_Rule__c = rScheduleRule.id;
            pConfig.Requires_Rescheduling__c= true;
            pConfig.cscfga__Configuration_Status__c ='Valid';
        }
        update prodConfigs;
        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,ProdConfigs);

        //List<Revenue_Recognition_Schedule__c> rSchedules = testDataSetupBilling.createRevenueSchedules(3,salesOrders,fulfilmentItem,prodConfigs);
        List<CS_Sales_Order_Schedule__c> salesOrderSchedules = new List<CS_Sales_Order_Schedule__c>();

        for(csmso__Sales_Order__c salesOrder:salesOrders){
            CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
            sos.sales_order__c = salesOrder.id;
            salesOrderSchedules.add(sOs);
        }

        insert salesOrderSchedules;

        List<CS_Billing_Schedule__c> bSchedules = new List<CS_Billing_Schedule__c>();

        for(CS_Sales_Order_Schedule__c sOrderSchedule:salesOrderSchedules){
            CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
            bScheduleHeader.CS_Sales_Order_Schedule__c = sOrderSchedule.id;
            bSchedules.add(bScheduleHeader);
        }

        insert bSchedules;

        CS_Billing_Schedule__c bScheduleHeader = bSchedules[0];


        cscfga__Product_Configuration__c pc = [SELECT Id, Sales_Order__c
        FROM cscfga__Product_Configuration__c
        LIMIT 1][0];

        CS_Billing_Schedule_Item__c bschedule = new CS_Billing_Schedule_Item__c();
        bSchedule.Product_Configuration__c = pc.id;
        bSchedule.Status__c = 'Locked';
        bSchedule.Sales_Order__c = pc.Sales_Order__c;
        bSchedule.DFP_Actuals__c = 100;
        //bSchedule.Billing_Quantity__c = 10.0;
        bSchedule.Net_Rate__c = 100.0;
        bSchedule.Billing_Period_Start_Date__c = Date.Today();
        bschedule.billing_schedule__c=bScheduleHeader.id;
        insert bSchedule;

        Map<String, Object> paramsObj = new Map<String, Object>();
        paramsObj.clear();
        paramsObj.put('ConfigId', pc.Id);
        paramsObj.put('Sales_Order_Id_0', pc.Sales_Order__c);
        paramsObj.put('Insertion_Quantity_0', 1000);
        paramsObj.put('Start_Date_0', Date.today());
        paramsObj.put('End_Date_0', Date.today()+15);
        paramsObj.put('Rate_0', 100000);
        paramsObj.put('Price_0', 100000);
        Date dateToday = Date.Today()+1;
        DateTime now = DateTime.now().addHours(6);
        Integer hours = now.hour(), minutes = now.minute(), seconds = now.second();
        paramsObj.put('Flight_Begin_Date_Time_Selected_0', dateToday.year()+'-'+dateToday.month()+'-'+dateToday.day()+' '+hours+':'+minutes+':'+seconds+' GMT');
        paramsObj.put('Flight_End_Date_Time_Selected_0', dateToday.year()+'-'+dateToday.month()+'-'+dateToday.day()+' '+hours+':'+minutes+':'+seconds+' GMT');

        Test.startTest();
        ValidateIFCController validateIFCController = new ValidateIFCController();
        String performActionResult = validateIFCController.performAction(JSON.serialize(paramsObj));
        Map<String, Object> resultJSONObject = (Map<String, Object>) JSON.deserializeUntyped(performActionResult);
        Test.stopTest();

        System.assertEquals((Boolean)resultJSONObject.get('isError'), false);
        System.assertEquals((String)resultJSONObject.get('errorMsg'), null);
    }

    // Invalid test when billing period started
    @isTest
    public static void billingPeriodStartedInvalidTest() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        //Account Creation.
        List<Account> Acc = TestDataSetupSO.createAccounts(1);

        //Contact Creation.
        List<Contact> con = TestDataSetupSO.createContacts(1,Acc);

        //Opportunity Creation.
        List<Opportunity> opp = TestDataSetupSO.createOpportunities(1,Acc,con);

        //SalesOrder Creation.
        List<csmso__Sales_Order__c> salesOrders = TestDataSetupSO.createSalesOrders(1,Acc,opp);

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1,prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1,salesorders);

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1,prodBaskets,prodDef);


        //Fulfilment Creation.
        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,salesorders,Acc);
        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            if(salesOrders.size()>0)
                pConfig.Sales_Order__c = salesOrders[0].id;
            pConfig.Billing_Schedule_Rule__c = bScheduleRule.id;
            pConfig.Revenue_Schedule_Rule__c = rScheduleRule.id;
            pConfig.Requires_Rescheduling__c= true;
            pConfig.Flight_Begin__c = Date.Today().addDays(-4);
            pConfig.cscfga__Configuration_Status__c ='Valid';
        }
        update prodConfigs;
        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,ProdConfigs);

        //List<Revenue_Recognition_Schedule__c> rSchedules = testDataSetupBilling.createRevenueSchedules(3,salesOrders,fulfilmentItem,prodConfigs);
        List<CS_Sales_Order_Schedule__c> salesOrderSchedules = new List<CS_Sales_Order_Schedule__c>();

        for(csmso__Sales_Order__c salesOrder:salesOrders){
            CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
            sos.sales_order__c = salesOrder.id;
            salesOrderSchedules.add(sOs);
        }

        insert salesOrderSchedules;

        List<CS_Billing_Schedule__c> bSchedules = new List<CS_Billing_Schedule__c>();

        for(CS_Sales_Order_Schedule__c sOrderSchedule:salesOrderSchedules){
            CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
            bScheduleHeader.CS_Sales_Order_Schedule__c = sOrderSchedule.id;
            bScheduleHeader.Under_IFC__c = true;
            bSchedules.add(bScheduleHeader);
        }

        insert bSchedules;

        CS_Billing_Schedule__c bScheduleHeader = bSchedules[0];


        cscfga__Product_Configuration__c pc = [SELECT Id, Sales_Order__c
        FROM cscfga__Product_Configuration__c
        LIMIT 1][0];



        CS_Billing_Schedule_Item__c bschedule = new CS_Billing_Schedule_Item__c();
        bSchedule.Product_Configuration__c = pc.id;
        bSchedule.Status__c = 'Locked';
        bSchedule.Sales_Order__c = pc.Sales_Order__c;
        bSchedule.DFP_Actuals__c = 100;
        //bSchedule.Billing_Quantity__c = 10.0;
        bSchedule.Net_Rate__c = 100.0;
        bSchedule.Billing_Period_Start_Date__c = Date.Today().addDays(-10);
        bschedule.billing_schedule__c=bScheduleHeader.id;
        insert bSchedule;

        Map<String, Object> paramsObj = new Map<String, Object>();
        paramsObj.clear();
        paramsObj.put('ConfigId', pc.Id);
        paramsObj.put('Sales_Order_Id_0', pc.Sales_Order__c);
        paramsObj.put('Insertion_Quantity_0', 100);
        paramsObj.put('Start_Date_0', Date.Today().addDays(-1));
        paramsObj.put('End_Date_0', Date.today()+15);
        paramsObj.put('Rate_0', 100000);
        paramsObj.put('Price_0', 10000);

        Test.startTest();
        ValidateIFCController validateIFCController = new ValidateIFCController();
        String performActionResult = validateIFCController.performAction(JSON.serialize(paramsObj));
        Map<String, Object> resultJSONObject = (Map<String, Object>) JSON.deserializeUntyped(performActionResult);
        Test.stopTest();

        System.debug('****** resultJSONObject');
        System.debug(resultJSONObject);

        System.assertEquals((Boolean)resultJSONObject.get('isError'), true);
        System.assertEquals((String)resultJSONObject.get('errorMsg'), 'Billing period started. Start date cannot be modified.');
    }

    // Invalid test when start date in past
    @isTest
    public static void startDateInPastInvalidTest() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        //Account Creation.
        List<Account> Acc = TestDataSetupSO.createAccounts(1);

        //Contact Creation.
        List<Contact> con = TestDataSetupSO.createContacts(1,Acc);

        //Opportunity Creation.
        List<Opportunity> opp = TestDataSetupSO.createOpportunities(1,Acc,con);

        //SalesOrder Creation.
        List<csmso__Sales_Order__c> salesOrders = TestDataSetupSO.createSalesOrders(1,Acc,opp);

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1,prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1,salesorders);

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1,prodBaskets,prodDef);


        //Fulfilment Creation.
        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,salesorders,Acc);
        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            if(salesOrders.size()>0)
                pConfig.Sales_Order__c = salesOrders[0].id;
            pConfig.Billing_Schedule_Rule__c = bScheduleRule.id;
            pConfig.Revenue_Schedule_Rule__c = rScheduleRule.id;
            pConfig.Requires_Rescheduling__c= true;
            pConfig.cscfga__Configuration_Status__c ='Valid';
        }
        update prodConfigs;
        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,ProdConfigs);

        //List<Revenue_Recognition_Schedule__c> rSchedules = testDataSetupBilling.createRevenueSchedules(3,salesOrders,fulfilmentItem,prodConfigs);
        List<CS_Sales_Order_Schedule__c> salesOrderSchedules = new List<CS_Sales_Order_Schedule__c>();

        for(csmso__Sales_Order__c salesOrder:salesOrders){
            CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
            sos.sales_order__c = salesOrder.id;
            salesOrderSchedules.add(sOs);
        }

        insert salesOrderSchedules;

        List<CS_Billing_Schedule__c> bSchedules = new List<CS_Billing_Schedule__c>();

        for(CS_Sales_Order_Schedule__c sOrderSchedule:salesOrderSchedules){
            CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
            bScheduleHeader.CS_Sales_Order_Schedule__c = sOrderSchedule.id;
            bScheduleHeader.Under_IFC__c = true;
            bSchedules.add(bScheduleHeader);
        }

        insert bSchedules;

        CS_Billing_Schedule__c bScheduleHeader = bSchedules[0];


        cscfga__Product_Configuration__c pc = [SELECT Id, Sales_Order__c
        FROM cscfga__Product_Configuration__c
        LIMIT 1][0];

        CS_Billing_Schedule_Item__c bschedule = new CS_Billing_Schedule_Item__c();
        bSchedule.Product_Configuration__c = pc.id;
        bSchedule.Status__c = 'Locked';
        bSchedule.DFP_Actuals__c = 100;
        bSchedule.Sales_order__c = pc.Sales_Order__c;
        //bSchedule.Billing_Quantity__c = 10.0;
        bSchedule.Net_Rate__c = 100.0;
        bSchedule.Billing_Period_Start_Date__c = Date.Today().addDays(10);
        bschedule.billing_schedule__c=bScheduleHeader.id;
        insert bSchedule;

        Date dateToday = Date.Today()-10;
        Date dateFuture = Date.Today()+4;
        DateTime now = DateTime.now().addHours(6);
        Integer hours = now.hour(), minutes = now.minute(), seconds = now.second();

        Map<String, Object> paramsObj = new Map<String, Object>();
        paramsObj.clear();
        paramsObj.put('ConfigId', pc.Id);
        paramsObj.put('Insertion_Quantity_0', 100);
        paramsObj.put('Start_Date_0', Date.Today().addDays(-10));
        paramsObj.put('Price_0', 10000);
        paramsObj.put('Flight_Begin_Date_Time_Selected_0',  dateToday.year()+'-'+dateToday.month()+'-'+dateToday.day()+' '+hours+':'+minutes+':'+seconds+' GMT');
        paramsObj.put('Flight_End_Date_Time_Selected_0',  dateFuture.year()+'-'+dateFuture.month()+'-'+dateFuture.day()+' '+hours+':'+minutes+':'+seconds+' GMT');
        paramsObj.put('Rate_0', 12);
        paramsObj.put('Fulfilment_Item_Status_0', 'Inactive');
        paramsObj.put('Billing_Source_0', 'DFP Actuals');
        paramsObj.put('x3rd_Party_Verification_0', false);
        paramsObj.put('x3rd_Party_Tracking_0', false);

        Test.startTest();
        ValidateIFCController validateIFCController = new ValidateIFCController();
        String performActionResult = validateIFCController.performAction(JSON.serialize(paramsObj));
        Map<String, Object> resultJSONObject = (Map<String, Object>) JSON.deserializeUntyped(performActionResult);
        Test.stopTest();

        System.assertEquals((Boolean)resultJSONObject.get('isError'), true);
        //System.assertEquals((String)resultJSONObject.get('errorMsg'), 'Start date cannot be set in past');
        System.assertEquals((String)resultJSONObject.get('errorMsg'), 'Change on price affecting fields is not allowed if Line Start Date & Time has passed.');
        //System.assertEquals((String)resultJSONObject.get('errorMsg'), 'An error occured while validating In-Flight change schedules. Please contact your admin.');
    }

    // Invalid test when quantity lower than delivered billQuantitySum
    @isTest
    public static void quantityLowerThanDeliveredBillQuantityInvalidTest() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        //Account Creation.
        List<Account> Acc = TestDataSetupSO.createAccounts(1);

        //Contact Creation.
        List<Contact> con = TestDataSetupSO.createContacts(1,Acc);

        //Opportunity Creation.
        List<Opportunity> opp = TestDataSetupSO.createOpportunities(1,Acc,con);

        //SalesOrder Creation.
        List<csmso__Sales_Order__c> salesOrders = TestDataSetupSO.createSalesOrders(1,Acc,opp);

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1,prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1,salesorders);

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1,prodBaskets,prodDef);


        //Fulfilment Creation.
        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,salesorders,Acc);
        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            if(salesOrders.size()>0)
                pConfig.Sales_Order__c = salesOrders[0].id;
            pConfig.Billing_Schedule_Rule__c = bScheduleRule.id;
            pConfig.Revenue_Schedule_Rule__c = rScheduleRule.id;
            pConfig.Requires_Rescheduling__c= true;
            pConfig.Net_Rate__c = 100.0;
            pConfig.cscfga__Configuration_Status__c ='Valid';
        }
        update prodConfigs;
        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,ProdConfigs);

        //List<Revenue_Recognition_Schedule__c> rSchedules = testDataSetupBilling.createRevenueSchedules(3,salesOrders,fulfilmentItem,prodConfigs);
        List<CS_Sales_Order_Schedule__c> salesOrderSchedules = new List<CS_Sales_Order_Schedule__c>();

        for(csmso__Sales_Order__c salesOrder:salesOrders){
            CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
            sos.sales_order__c = salesOrder.id;
            salesOrderSchedules.add(sOs);
        }

        insert salesOrderSchedules;

        List<CS_Billing_Schedule__c> bSchedules = new List<CS_Billing_Schedule__c>();

        for(CS_Sales_Order_Schedule__c sOrderSchedule:salesOrderSchedules){
            CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
            bScheduleHeader.CS_Sales_Order_Schedule__c = sOrderSchedule.id;
            bScheduleHeader.Under_IFC__c = true;
            bSchedules.add(bScheduleHeader);
        }

        insert bSchedules;

        CS_Billing_Schedule__c bScheduleHeader = bSchedules[0];

        cscfga__Product_Configuration__c pc = [SELECT Id, Sales_Order__c
        FROM cscfga__Product_Configuration__c
        LIMIT 1][0];

        CS_Billing_Schedule_Item__c bschedule = new CS_Billing_Schedule_Item__c();
        bSchedule.Product_Configuration__c = pc.id;
        bSchedule.Status__c = 'Closed';
        bSchedule.DFP_Actuals__c = 100;
        bSchedule.Sales_order__c = pc.Sales_Order__c;
        bSchedule.Contracted_Quantity__c = 300;
        bSchedule.Billing_Date__c = Date.today()+8;
        //bSchedule.Billing_Quantity__c = 10.0;
        bSchedule.Net_Rate__c = 100.0;
        bSchedule.Billing_Period_Start_Date__c = Date.today();
        bSchedule.Billing_Period_End_Date__c = Date.Today().addDays(8);
        bschedule.billing_schedule__c=bScheduleHeader.id;
        insert bSchedule;

        Date dateToday = Date.Today();
        Date dateFuture = Date.Today()+7;
        DateTime now = DateTime.now().addHours(6);
        Integer hours = now.hour(), minutes = now.minute(), seconds = now.second();

        Map<String, Object> paramsObj = new Map<String, Object>();
        paramsObj.clear();
        paramsObj.put('ConfigId', pc.Id);
        paramsObj.put('Sales_Order_Id_0', pc.Sales_Order__c);
        paramsObj.put('Insertion_Quantity_0', 120);
        paramsObj.put('Start_Date_0', Date.today());
        paramsObj.put('End_Date_0', Date.today()+7);
        paramsObj.put('Rate_0', 100);
        paramsObj.put('Price_0', 100);
        paramsObj.put('Flight_Begin_Date_Time_Selected_0',  dateToday.year()+'-'+dateToday.month()+'-'+dateToday.day()+' '+hours+':'+minutes+':'+seconds+' GMT');
        paramsObj.put('Flight_End_Date_Time_Selected_0',  dateFuture.year()+'-'+dateFuture.month()+'-'+dateFuture.day()+' '+hours+':'+minutes+':'+seconds+' GMT');
        paramsObj.put('Fulfilment_Item_Status_0', 'Inactive');
        paramsObj.put('Billing_Source_0', 'DFP Actuals');
        paramsObj.put('x3rd_Party_Verification_0', false);
        paramsObj.put('x3rd_Party_Tracking_0', false);

        Test.startTest();
        ValidateIFCController validateIFCController = new ValidateIFCController();
        String performActionResult = validateIFCController.performAction(JSON.serialize(paramsObj));
        Map<String, Object> resultJSONObject = (Map<String, Object>) JSON.deserializeUntyped(performActionResult);
        Test.stopTest();

        //System.assertEquals((Boolean)resultJSONObject.get('isError'), true);
        //System.assertEquals((String)resultJSONObject.get('errorMsg'), 'Quantity cannot be lower than total quantity already delivered/billed.');
        //System.assertEquals((String)resultJSONObject.get('errorMsg'), 'An error occured while validating In-Flight change schedules. Please contact your admin.');
    }

    // Invalid test when change on price affecting fields has been done
    @isTest
    public static void changeOnPriceAffectingFieldsInvalidTest() {

        insert new CSSX__No_Triggers__c(cssx__Flag__c = true, setupownerid = Userinfo.getOrganizationId());

        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        //Account Creation.
        List<Account> Acc = TestDataSetupSO.createAccounts(1);

        //Contact Creation.
        List<Contact> con = TestDataSetupSO.createContacts(1,Acc);

        //Opportunity Creation.
        List<Opportunity> opp = TestDataSetupSO.createOpportunities(1,Acc,con);

        //SalesOrder Creation.
        List<csmso__Sales_Order__c> salesOrders = TestDataSetupSO.createSalesOrders(1,Acc,opp);

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1,prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1,salesorders);

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1,prodBaskets,prodDef);


        //Fulfilment Creation.
        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,salesorders,Acc);
        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            if(salesOrders.size()>0)
                pConfig.Sales_Order__c = salesOrders[0].id;
            pConfig.Billing_Schedule_Rule__c = bScheduleRule.id;
            pConfig.Revenue_Schedule_Rule__c = rScheduleRule.id;
            pConfig.Requires_Rescheduling__c= true;
            pConfig.cscfga__Configuration_Status__c ='Valid';
        }
        update prodConfigs;
        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,ProdConfigs);

        //List<Revenue_Recognition_Schedule__c> rSchedules = testDataSetupBilling.createRevenueSchedules(3,salesOrders,fulfilmentItem,prodConfigs);
        List<CS_Sales_Order_Schedule__c> salesOrderSchedules = new List<CS_Sales_Order_Schedule__c>();

        for(csmso__Sales_Order__c salesOrder:salesOrders){
            CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
            sos.sales_order__c = salesOrder.id;
            salesOrderSchedules.add(sOs);
        }

        insert salesOrderSchedules;

        List<CS_Billing_Schedule__c> bSchedules = new List<CS_Billing_Schedule__c>();

        for(CS_Sales_Order_Schedule__c sOrderSchedule:salesOrderSchedules){
            CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
            bScheduleHeader.CS_Sales_Order_Schedule__c = sOrderSchedule.id;
            bScheduleHeader.Under_IFC__c = true;
            bSchedules.add(bScheduleHeader);
        }

        insert bSchedules;

        CS_Billing_Schedule__c bScheduleHeader = bSchedules[0];


        cscfga__Product_Configuration__c pc = [SELECT Id, Sales_Order__c
        FROM cscfga__Product_Configuration__c
        LIMIT 1][0];

        CS_Billing_Schedule_Item__c bschedule = new CS_Billing_Schedule_Item__c();
        bSchedule.Product_Configuration__c = pc.id;
        bSchedule.Sales_order__c = pc.Sales_Order__c;
        bSchedule.Status__c = 'Locked';
        bSchedule.DFP_Actuals__c = 100;
        //bSchedule.Billing_Quantity__c = 10.0;
        //bSchedule.Net_Rate__c = 100.0;
        bSchedule.Billing_Period_Start_Date__c = Date.Today();
        bschedule.billing_schedule__c=bScheduleHeader.id;
        bSchedule.Net_Rate__c=12;
        insert bSchedule;

        Date dateToday = Date.Today()-10;
        Date dateFuture = Date.Today()+4;
        DateTime now = DateTime.now().addHours(6);
        Integer hours = now.hour(), minutes = now.minute(), seconds = now.second();

        Map<String, Object> paramsObj = new Map<String, Object>();
        paramsObj.clear();
        paramsObj.put('ConfigId', pc.Id);
        paramsObj.put('Insertion_Quantity_0', 100);
        paramsObj.put('Start_Date_0', Date.today());
        paramsObj.put('Price_0', 100);
        paramsObj.put('Flight_Begin_Date_Time_Selected_0',  dateToday.year()+'-'+dateToday.month()+'-'+dateToday.day()+' '+hours+':'+minutes+':'+seconds+' GMT');
        paramsObj.put('Flight_End_Date_Time_Selected_0',  dateFuture.year()+'-'+dateFuture.month()+'-'+dateFuture.day()+' '+hours+':'+minutes+':'+seconds+' GMT');
        paramsObj.put('Rate_0', 12);
        paramsObj.put('Fulfilment_Item_Status_0', 'Inactive');
        paramsObj.put('Billing_Source_0', 'DFP Actuals');
        paramsObj.put('x3rd_Party_Verification_0', false);
        paramsObj.put('x3rd_Party_Tracking_0', false);

        Test.startTest();
        ValidateIFCController validateIFCController = new ValidateIFCController();
        String performActionResult = validateIFCController.performAction(JSON.serialize(paramsObj));
        Map<String, Object> resultJSONObject = (Map<String, Object>) JSON.deserializeUntyped(performActionResult);
        Test.stopTest();

        System.assertEquals((Boolean)resultJSONObject.get('isError'), true);
        System.assertEquals((String)resultJSONObject.get('errorMsg'), 'Change on Billing Source is not allowed if Line Start Date & Time has passed.');
        //System.assertEquals((String)resultJSONObject.get('errorMsg'), 'An error occured while validating In-Flight change schedules. Please contact your admin.');
    }

}
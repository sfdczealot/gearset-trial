@IsTest
private class CancelArchiveActionInvokerTest {

    @IsTest static void test_method_one() {
        
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        CS_Custom_Settings__c csCustomSettings = new CS_Custom_Settings__c(Integration_Chunk_Size__c = 1, Integration_Delay_Between_Callouts__c = 0);
        upsert csCustomSettings;

        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        Account acc = TestDataSetupBasic.createAccount();
        acc.recordTypeId = recordTypeId;
        insert acc;

        Contact con = TestDataSetupBasic.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        insert opp;

        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        insert so;
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        insert prodBasket;

        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
        insert testFulfilment;

        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Ad_Type__c = 'Standard';
        prodConfig.Fulfilment_Item_Status__c = 'Draft';
        prodConfig.csmso__Flight_End__c = Date.Today().addDays(4);
        insert prodConfig;

        Map<Id, cscfga__Product_Configuration__c> configs = new Map<Id, cscfga__Product_Configuration__c>();
        configs.put(prodConfig.Id, prodConfig);

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
        testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
        insert testFulfilmentItem;

        csam__Integration_Endpoint__c custSetting = new csam__Integration_Endpoint__c();
        custSetting.Name = 'Ad Server Integration';
        custSetting.csam__Callout_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
        insert custSetting;

        csam__ObjectGraph_Callout_Handler__c testObjGrph = TestDataSetupTargetables.createObjGrph();
        testObjGrph.Name = 'Fulfilment Item Cancel';
        insert testObjGrph;

        csam__ObjectGraph_Callout_Handler__c testObjGrph_2 = TestDataSetupTargetables.createObjGrph();
        testObjGrph_2.Name = 'Fulfilment Item Availability Check';
        insert testObjGrph_2;

        csam__ObjectGraph_Callout_Handler__c testObjGrph_3 = TestDataSetupTargetables.createObjGrph();
        testObjGrph_3.Name = 'Fulfilment Availability Check';
        insert testObjGrph_3;

        csam__ObjectGraph_Callout_Handler__c testObjGrph_4 = TestDataSetupTargetables.createObjGrph();
        testObjGrph_4.Name = 'Fulfilment Item Archive';
        insert testObjGrph_4;

        CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
        sOs.Sales_Order__c = so.Id;
        insert sOs;

        //bsi
        CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
        bScheduleHeader.CS_Sales_Order_Schedule__c = sOs.Id;
        bScheduleHeader.Under_IFC__c = true;
        insert bScheduleHeader;

        CS_Billing_Schedule_Item__c bschedule = new CS_Billing_Schedule_Item__c();
        bschedule.Product_Configuration__c = prodConfig.Id;
        bschedule.Status__c = 'Open';
        bschedule.Sales_Order__c = prodConfig.Sales_Order__c;
        bschedule.DFP_Actuals__c = 100;
        bschedule.Net_Rate__c = 100.0;
        bschedule.Billing_Period_Start_Date__c = Date.today().addDays(-4);
        bschedule.Billing_Schedule__c = bScheduleHeader.Id;
        insert bschedule;

        //rsi
        CS_Revenue_Schedule__c rScheduleHeader = new CS_Revenue_Schedule__c();
        rScheduleHeader.CS_Sales_Order_Schedule__c = sOs.Id;
        insert rScheduleHeader;

        CS_Revenue_Schedule_Item__c rSchedule = new CS_Revenue_Schedule_Item__c();
        rSchedule.Sales_Order__c = prodConfig.Sales_Order__c;
        rSchedule.Product_Configuration__c = prodConfig.Id;
        rSchedule.Status__c = 'Open';
        rSchedule.Net_Rate__c = 100.0;
        rSchedule.Gross_Rate__c = 20;
        rSchedule.Rev_Rec_Period_Start_Date__c = Date.today().addDays(-4);
        rSchedule.Rev_Rec_Period_End_Date__c = Date.today().addDays(4);
        rSchedule.Revenue_Schedule__c = rScheduleHeader.Id;
        rSchedule.Rev_Rec_Quantity__c = 10;
        bschedule.Insertion_Unit_Type__c = 'CPM';
        insert rSchedule;

        Test.startTest();
        String parameters = JSON.serialize(testFulfilmentItem.Id);
        CancelArchiveActionInvoker caaiClass = new CancelArchiveActionInvoker();
        caaiClass.performAction(parameters);
        DigitalFulfilmentAdapterUtil.availabilityCheckPoll(testFulfilmentItem.Id);
        DigitalFulfilmentAdapterUtil.invokeAvailabilityCheck(testFulfilmentItem.Id);
        Test.stopTest();
    }

    @IsTest static void test_method_servedbydfp() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        CS_Custom_Settings__c csCustomSettings = new CS_Custom_Settings__c(Integration_Chunk_Size__c = 1, Integration_Delay_Between_Callouts__c = 0);
        upsert csCustomSettings;

        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        Account acc = TestDataSetupBasic.createAccount();
        acc.recordTypeId = recordTypeId;
        insert acc;

        Contact con = TestDataSetupBasic.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        insert opp;

        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        insert so;

        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        insert prodBasket;

        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
        insert testFulfilment;

        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Ad_Type__c = 'Standard';
        prodConfig.Fulfilment_Item_Status__c = 'Draft';
        prodConfig.Served_By__c = 'DFP';
        prodConfig.Insertion_Unit_Type_Display__c = 'CPD';
        prodConfig.csmso__Flight_End__c = Date.Today().addDays(4);
        insert prodConfig;

        Map<Id, cscfga__Product_Configuration__c> configs = new Map<Id, cscfga__Product_Configuration__c>();
        configs.put(prodConfig.Id, prodConfig);

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
        testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
        testFulfilmentItem.csdf__Availability_Check_Status__c = 'Completed';
        testFulfilmentItem.Served_By__c = 'DFP';
        insert testFulfilmentItem;

        csam__Integration_Endpoint__c custSetting = new csam__Integration_Endpoint__c();
        custSetting.Name = 'Ad Server Integration';
        custSetting.csam__Callout_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
        insert custSetting;

        csam__ObjectGraph_Callout_Handler__c testObjGrph = TestDataSetupTargetables.createObjGrph();
        testObjGrph.Name = 'Fulfilment Item Cancel';
        insert testObjGrph;

        csam__ObjectGraph_Callout_Handler__c testObjGrph_2 = TestDataSetupTargetables.createObjGrph();
        testObjGrph_2.Name = 'Fulfilment Item Availability Check';
        insert testObjGrph_2;

        csam__ObjectGraph_Callout_Handler__c testObjGrph_3 = TestDataSetupTargetables.createObjGrph();
        testObjGrph_3.Name = 'Fulfilment Availability Check';
        insert testObjGrph_3;

        csam__ObjectGraph_Callout_Handler__c testObjGrph_4 = TestDataSetupTargetables.createObjGrph();
        testObjGrph_4.Name = 'Fulfilment Item Archive';
        insert testObjGrph_4;

        Test.startTest();
        String parameters = JSON.serialize(testFulfilmentItem.Id);
        CancelArchiveActionInvoker caaiClass = new CancelArchiveActionInvoker();
        caaiClass.performAction(parameters);
        DigitalFulfilmentAdapterUtil.availabilityCheckPoll(testFulfilmentItem.Id);
        DigitalFulfilmentAdapterUtil.invokeAvailabilityCheck(testFulfilmentItem.Id);
        Test.stopTest();
    }
}
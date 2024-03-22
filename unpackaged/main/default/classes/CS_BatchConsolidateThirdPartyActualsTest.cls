/**
 * Created by jameshladek on 2/13/20.
 */
@IsTest
public with sharing class CS_BatchConsolidateThirdPartyActualsTest {

    @TestSetup static void setupData() {
        Worker__c worker = new Worker__c();
        worker.Batch_Jobs_Limit__c = 5;
        worker.Batch_Retry_Time__c = 15;
        insert worker;

        X3rd_Party_Ad_Server__c server = new X3rd_Party_Ad_Server__c();
        server.X3rd_Party_Ad_Server__c = 'Test Server';
        insert server;

        cscfga__Product_Configuration__c testConfig = TestDataSetupSO.createproductConfigAndDef('Test Data');
        testConfig.Flight_Begin__c = Date.today().addMonths(-1);
        testConfig.Flight_End__c = Date.today();
        testConfig.Insertion_Unit_Type__c = 'CPC';
        testConfig.Order_Line_ID__c = '523678245';
        testConfig.Billing_Source__c = '3rd Party Actuals';
        testConfig.X3rd_Party_Ad_Server__c = server.Id;
        update testConfig;

        CS_Sales_Order_Schedule__c schedule = new CS_Sales_Order_Schedule__c();
        insert schedule;

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c(); 
        insert salesOrderSchedule;

        CS_Billing_Schedule__c billingSchedule = new CS_Billing_Schedule__c();
        billingSchedule.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        insert billingSchedule;

        CS_Revenue_Schedule__c revenueSchedule = new CS_Revenue_Schedule__c();
        revenueSchedule.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        insert revenueSchedule;

        CS_Billing_Schedule_Item__c bsi = new CS_Billing_Schedule_Item__c();
        bsi.Billing_Schedule__c = billingSchedule.Id;
        bsi.Billing_Date__c = Date.today().addMonths(-1);
        bsi.Product_Configuration__c = testConfig.Id;
        insert bsi;

        CS_Revenue_Schedule_Item__c rsi = new CS_Revenue_Schedule_Item__c();
        rsi.Revenue_Schedule__c = revenueSchedule.Id;
        rsi.Rev_Rec_Date__c = Date.today().addMonths(-1);
        rsi.Product_Configuration__c = testConfig.Id;
        insert rsi;

        Third_Party_Monthly_Actual__c monthlyActual1 = new Third_Party_Monthly_Actual__c();
        monthlyActual1.Clicks__c = 10;
        monthlyActual1.Impressions__c = 5;
        monthlyActual1.Order_Line_Id__c = '523678245';
        monthlyActual1.Report_Date__c = Date.today().addMonths(-1);
        monthlyActual1.Local_Server_Name__c = 'Test Server';
        insert monthlyActual1;

        Third_Party_Monthly_Actual__c monthlyActual2 = new Third_Party_Monthly_Actual__c();
        monthlyActual2.Clicks__c = 20;
        monthlyActual2.Impressions__c = 10;
        monthlyActual2.Order_Line_Id__c = '523678245';
        monthlyActual2.Report_Date__c = Date.today().addMonths(-1);
        monthlyActual2.Local_Server_Name__c = 'Test Server';
        insert monthlyActual2;
    }

    @IsTest static void testPCCPC() {

        CS_BatchConsolidateThirdPartyActuals batch = new CS_BatchConsolidateThirdPartyActuals();
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
        CS_Revenue_Schedule_Item__c revenueScheduleItem = [SELECT Third_Party_Monthly_Actuals__c FROM CS_Revenue_Schedule_Item__c LIMIT 1];
        CS_Billing_Schedule_Item__c billingScheduleItem = [SELECT Third_Party_Monthly_Actuals__c FROM CS_Billing_Schedule_Item__c LIMIT 1];

        //System.assertEquals(30, revenueScheduleItem.Third_Party_Monthly_Actuals__c);
        //System.assertEquals(30, billingScheduleItem.Third_Party_Monthly_Actuals__c);
    }

    @IsTest static void testPCNonCPC() {
        cscfga__Product_Configuration__c pc = [
                SELECT Id, Insertion_Unit_Type__c, Flight_Begin__c, Flight_End__c, (SELECT Id, Third_Party_Monthly_Actuals__c FROM Billing_Schedule_Item__r), (SELECT Id, Third_Party_Monthly_Actuals__c FROM Revenue_Schedule_Item__r)
                FROM cscfga__Product_Configuration__c
                LIMIT 1
        ];
        pc.Insertion_Unit_Type__c = 'CPM';
        update pc;

        CS_BatchConsolidateThirdPartyActuals batch = new CS_BatchConsolidateThirdPartyActuals();
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        CS_Revenue_Schedule_Item__c revenueScheduleItem = [SELECT Third_Party_Monthly_Actuals__c FROM CS_Revenue_Schedule_Item__c LIMIT 1];
        CS_Billing_Schedule_Item__c billingScheduleItem = [SELECT Third_Party_Monthly_Actuals__c FROM CS_Billing_Schedule_Item__c LIMIT 1];

        //System.assertEquals(15, revenueScheduleItem.Third_Party_Monthly_Actuals__c);
        //System.assertEquals(15, billingScheduleItem.Third_Party_Monthly_Actuals__c);
    }

    @IsTest static void testScheduleCall() {
        Test.startTest();
        CS_BatchConsolidateThirdPartyActuals.scheduleIt();
        Test.stopTest();
    }

}
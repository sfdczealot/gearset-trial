/**
 * Created by sasa.marjancic on 14.1.2020..
 */
@isTest
public class CS_BatchDeleteReportDataTest {
    @testSetup
    private static void setup() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        CS_th_Worker.create();
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        insert salesOrder;

        CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
        sos.sales_order__c = salesOrder.id;
        insert sOs;

        CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
        bs.CS_Sales_Order_Schedule__c = sOs.id;
        bs.Under_IFC__c = false;
        insert bs;

        CS_Billing_Schedule_Item__c bsi = new CS_Billing_Schedule_Item__c();
        bsi.Sales_Order__c = salesOrder.Id;
        bsi.Billing_Period_Start_Date__c = Date.Today().addDays(-10);
        bsi.Billing_Period_End_Date__c = Date.Today().addDays(5);
        bsi.billing_schedule__c = bs.id;
        bsi.DFP_Order_Line_ID__c = '12345';
        insert bsi;

        Test.startTest();
    }

    @isTest
    private static void test_deleteDuplicates() {
        List<CS_DFP_Actuals_By_Hour_Report_Data__c> dfpActualsOld = new List<CS_DFP_Actuals_By_Hour_Report_Data__c>();
        List<CS_DFP_Actuals_By_Hour_Report_Data__c> dfpActuals = new List<CS_DFP_Actuals_By_Hour_Report_Data__c>();
        for(Integer i = 0; i < 1000; i++) {
            CS_DFP_Actuals_By_Hour_Report_Data__c actual = new CS_DFP_Actuals_By_Hour_Report_Data__c(
                Order_Line_Id__c = '12345',
                Report_Date__c = Date.today().addDays((i/100.00).intValue() - 10),
                Impressions__c = (i/10.00).intValue(),
                Hour__c = Math.mod(i, 24)
            );
            dfpActualsOld.add(actual);
        }
        insert dfpActualsOld;

        for(Integer i = 0; i < 240; i++) {
            CS_DFP_Actuals_By_Hour_Report_Data__c actual = new CS_DFP_Actuals_By_Hour_Report_Data__c(
                    Order_Line_Id__c = '12345',
                    Report_Date__c = Date.today().addDays((i/24.00).intValue() - 10),
                    Impressions__c = (i/10.00).intValue(),
                    Hour__c = Math.mod(i, 24)
            );
            dfpActuals.add(actual);
        }
        insert dfpActuals;

        System.assertEquals(1240, [Select Id from CS_DFP_Actuals_By_Hour_Report_Data__c].size());
        Test.startTest();

        CS_BatchDeleteReportData batchWorker = new CS_BatchDeleteReportData();
        batchWorker.execute();

        Test.stopTest();

        System.assertEquals(240, [Select Id from CS_DFP_Actuals_By_Hour_Report_Data__c].size());
    }
}
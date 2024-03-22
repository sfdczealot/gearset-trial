@isTest
public class CS_ActualizeLineInvokerTest {
    @IsTest
    public static void test_actualize() {
        insert new CSSX__No_Triggers__c(cssx__Flag__c = true, SetupOwnerId = UserInfo.getOrganizationId());

        Account acc = TestDataSetupTargetables.createAccount();
        insert acc;

        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;

        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'Booked';
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        salesOrder.Billing_Calendar__c = 'Standard';
        insert salesOrder;

        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;

        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();

        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Configuration_Status_Tmp__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.IO_Volume_Discount_Range_1__c = 10;
        prodConfig.Revenue_Schedule_Rule__c = rScheduleRule.Id;
        prodConfig.Billing_Schedule_Rule__c = bScheduleRule.Id;
        prodConfig.Insertion_Quantity__c = 100;
        prodConfig.Flight_Begin__c = Date.today().addMonths(-1);
        prodConfig.Flight_End__c = Date.today().addMonths(3);
        prodConfig.Billing_Source__c = 'DFP Actuals';
        insert prodConfig;

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.Id;
        insert salesOrderSchedule;

        CS_Billing_Schedule__c csBillingSchedule = CS_utl_Schedule.createBillingSchedule(salesOrder.Id, salesOrderSchedule, prodConfig);
        csBillingSchedule.Under_IFC__c = true;
        insert csBillingSchedule;

        CS_Revenue_Schedule__c csRevenueSchedule = CS_utl_Schedule.createRevenueSchedule(salesOrder.Id, salesOrderSchedule, prodConfig);
        csRevenueSchedule.Under_IFC__c = true;
        insert csRevenueSchedule;

        CS_Billing_Schedule_Item__c bScheduleItem = new CS_Billing_Schedule_Item__c();
        bScheduleItem.Product_Configuration__c = prodConfig.Id;
        bScheduleItem.Sales_Order__c = salesOrder.Id;
        bScheduleItem.Billing_Schedule__c = csBillingSchedule.Id;
        bScheduleItem.Billing_Period_End_Date__c = Date.today().addDays(30);
        bScheduleItem.DFP_Actuals__c = 80;
        bScheduleItem.Billing_Source__c = 'DFP Actuals';
        insert bScheduleItem;

        CS_Revenue_Schedule_Item__c revenueScheduleItem = new CS_Revenue_Schedule_Item__c();
        revenueScheduleItem.Product_Configuration__c = prodConfig.Id;
        revenueScheduleItem.Revenue_Schedule__c = csRevenueSchedule.Id;
        revenueScheduleItem.Sales_Order__c = salesOrder.Id;
        insert revenueScheduleItem;

        Bill_Run__c billRun = new Bill_Run__c(
                Billing_Date__c = Date.today().addDays(-1),
                Reference_Date__c = Date.today().addDays(1),
                Calendar_Type__c = 'Standard'
        );
        insert billRun;

        CS_Custom_Settings__c customSettings = CS_Custom_Settings__c.getInstance();
        customSettings.Schedule_Item_Map__c = 'ScheduleItemMap';
        upsert customSettings;

        Map<String, Object> params = new Map<String, Object>{
            'salesOrderId' => salesOrder.Id,
            'productConfigurationIds' => new List<Id>{prodConfig.Id}
        };

        CS_ActualizeLineInvoker invoker = new CS_ActualizeLineInvoker();
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(invoker.performAction(JSON.serialize(params)));

        //System.assertEquals(bScheduleItem.Overwrite_Quantity__c + 1, Decimal.valueOf((String)response.get(prodConfig.Id)));
    }
}
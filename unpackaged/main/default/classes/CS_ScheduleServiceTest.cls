/**
 * Created by tvrtko.matosevic on 21/02/2019.
 */

@IsTest
public class CS_ScheduleServiceTest {

    @IsTest
    public static void testIfCreateAndUpdateScheduleWorks() {
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
        salesOrder.From_Calculated__c = Date.today();
        salesOrder.To_Calculated__c = Date.today().addMonths(7);
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
        insert prodConfig;

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.Id;
        insert salesOrderSchedule;

        CS_Billing_Schedule__c csBillingSchedule = CS_utl_Schedule.createBillingSchedule(salesOrder.Id, salesOrderSchedule, prodConfig);
        csBillingSchedule.Pending_Forecast_Recalculation__c = true;
        insert csBillingSchedule;

        CS_Billing_Schedule__c insertedCsBillingSchedule = [SELECT Id, Pending_Forecast_Recalculation__c FROM CS_Billing_Schedule__c WHERE Id =: csBillingSchedule.Id];
        System.debug('insertedCsBillingSchedule  => ' + insertedCsBillingSchedule);

        CS_Revenue_Schedule__c csRevenueSchedule = CS_utl_Schedule.createRevenueSchedule(salesOrder.Id, salesOrderSchedule, prodConfig);
        csRevenueSchedule.Pending_Forecast_Recalculation__c = true;
        insert csRevenueSchedule;

        CS_Billing_Schedule_Item__c bScheduleItem = new CS_Billing_Schedule_Item__c();
        bScheduleItem.Product_Configuration__c = prodConfig.Id;
        bScheduleItem.Sales_Order__c = salesOrder.Id;
        bScheduleItem.Billing_Schedule__c = csBillingSchedule.Id;
        bScheduleItem.Billing_Period_End_Date__c = Date.today().addDays(30);
        insert bScheduleItem;

        CS_Revenue_Schedule_Item__c revenueScheduleItem = new CS_Revenue_Schedule_Item__c();
        revenueScheduleItem.Product_Configuration__c = prodConfig.Id;
        revenueScheduleItem.Sales_Order__c = salesOrder.Id;
        revenueScheduleItem.Revenue_Schedule__c = csRevenueSchedule.Id;
        revenueScheduleItem.Rev_Rec_Period_End_Date__c = Date.today().addDays(30);
        insert revenueScheduleItem;

        List<CS_Billing_Schedule_Item__c> bScheduleItems = new List<CS_Billing_Schedule_Item__c>();
        bScheduleItems.add(bScheduleItem);

        CS_Custom_Settings__c customSettings = CS_Custom_Settings__c.getInstance();
        customSettings.Schedule_Item_Map__c = 'ScheduleItemMap';
        customSettings.BillingBatchSize__c = 10;
        customSettings.Days__c = 180;
        upsert customSettings;

        Boolean scheduleService = CS_ScheduleService.generateSchedules(new Set<Id>{
                salesOrder.Id
        }, new Set<Id>{
                prodConfig.Id
        });
        System.assert(scheduleService);

        Boolean areSchedulesUpdated = CS_ScheduleService.updateSchedules(new Set<Id>{
                salesOrder.Id
        }, new Set<Id>{
                prodConfig.Id
        });
        //System.assert(areSchedulesUpdated);
    }

    @IsTest
    public static void testIfUpdateSchedules() {
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
        insert prodConfig;

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.Id;
        insert salesOrderSchedule;

        CS_Billing_Schedule__c csBillingSchedule = CS_utl_Schedule.createBillingSchedule(salesOrder.Id, salesOrderSchedule, prodConfig);
        csBillingSchedule.Pending_Forecast_Recalculation__c = true;
        insert csBillingSchedule;

        CS_Billing_Schedule__c insertedCsBillingSchedule = [SELECT Id, Pending_Forecast_Recalculation__c FROM CS_Billing_Schedule__c WHERE Id =: csBillingSchedule.Id];
        System.debug('insertedCsBillingSchedule  => ' + insertedCsBillingSchedule);

        CS_Revenue_Schedule__c csRevenueSchedule = CS_utl_Schedule.createRevenueSchedule(salesOrder.Id, salesOrderSchedule, prodConfig);
        csRevenueSchedule.Pending_Forecast_Recalculation__c = true;
        insert csRevenueSchedule;

        CS_Billing_Schedule_Item__c bScheduleItem = new CS_Billing_Schedule_Item__c();
        bScheduleItem.Product_Configuration__c = prodConfig.Id;
        bScheduleItem.Sales_Order__c = salesOrder.Id;
        bScheduleItem.Billing_Schedule__c = csBillingSchedule.Id;
        bScheduleItem.Billing_Period_End_Date__c = Date.today().addDays(30);
        insert bScheduleItem;

        CS_Revenue_Schedule_Item__c revenueScheduleItem = new CS_Revenue_Schedule_Item__c();
        revenueScheduleItem.Product_Configuration__c = prodConfig.Id;
        revenueScheduleItem.Sales_Order__c = salesOrder.Id;
        revenueScheduleItem.Revenue_Schedule__c = csRevenueSchedule.Id;
        revenueScheduleItem.Rev_Rec_Period_End_Date__c = Date.today().addDays(30);
        insert revenueScheduleItem;

        List<CS_Billing_Schedule_Item__c> bScheduleItems = new List<CS_Billing_Schedule_Item__c>();
        bScheduleItems.add(bScheduleItem);

        CS_Custom_Settings__c customSettings = CS_Custom_Settings__c.getInstance();
        customSettings.Schedule_Item_Map__c = 'ScheduleItemMap';
        upsert customSettings;

        Boolean areSchedulesUpdated = CS_ScheduleService.updateSchedules(new Set<Id>{
                salesOrder.Id
        }, new Set<Id>{
                prodConfig.Id
        });
        System.assert(areSchedulesUpdated);
    }

    @IsTest
    public static void testIfValidateSchedulesFails1() {
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

        String result = CS_ScheduleService.validateSchedules(new Set<Id>{
                salesOrder.Id
        }, new Set<Id>{
                prodConfig.Id
        });
        System.assertEquals('An error occured while validating In-Flight change schedules. Please contact your admin.', result);
    }

    @IsTest
    public static void testIfValidateSchedulesFails2() {
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
        prodConfig.Flight_Begin__c = Date.today().addMonths(-2);
        prodConfig.Flight_End__c = Date.today().addMonths(-1);
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
        bScheduleItem.Billing_Period_Start_Date__c = Date.today().addMonths(-2);
        bScheduleItem.Billing_Period_End_Date__c = Date.today();
        bScheduleItem.Status__c = CS_const_SalesOrder.ScheduleStatus_PendingClosure;
        insert bScheduleItem;

        CS_Revenue_Schedule_Item__c revenueScheduleItem = new CS_Revenue_Schedule_Item__c();
        revenueScheduleItem.Product_Configuration__c = prodConfig.Id;
        revenueScheduleItem.Revenue_Schedule__c = csRevenueSchedule.Id;
        revenueScheduleItem.Sales_Order__c = salesOrder.Id;
        revenueScheduleItem.Status__c = CS_const_SalesOrder.ScheduleStatus_PendingClosure;
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

        String result = CS_ScheduleService.validateSchedules(new Set<Id>{
                salesOrder.Id
        }, new Set<Id>{
                prodConfig.Id
        });
        System.assertEquals('An error occured while validating In-Flight change schedules. Please contact your admin.', result);
    }

    @IsTest
    public static void testIfGenerateSchedulesIsFailing() {
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
        salesOrder.From_Calculated__c = Date.today();
        salesOrder.To_Calculated__c = Date.today().addMonths(3);
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
        //prodConfig.Insertion_Quantity__c = 100;
        prodConfig.Flight_Begin__c = Date.today().addMonths(-1);
        prodConfig.Flight_End__c = Date.today().addMonths(3);
        insert prodConfig;

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.Id;
        insert salesOrderSchedule;

        CS_Billing_Schedule__c csBillingSchedule = CS_utl_Schedule.createBillingSchedule(salesOrder.Id, salesOrderSchedule, prodConfig);
        insert csBillingSchedule;

        CS_Revenue_Schedule__c csRevenueSchedule = CS_utl_Schedule.createRevenueSchedule(salesOrder.Id, salesOrderSchedule, prodConfig);
        insert csRevenueSchedule;

        CS_Billing_Schedule_Item__c bScheduleItem = new CS_Billing_Schedule_Item__c();
        bScheduleItem.Sales_Order__c = salesOrder.Id;
        bScheduleItem.Billing_Schedule__c = csBillingSchedule.Id;
        bScheduleItem.Billing_Period_End_Date__c = Date.today().addDays(30);
        insert bScheduleItem;

        List<CS_Billing_Schedule_Item__c> bScheduleItems = new List<CS_Billing_Schedule_Item__c>();
        bScheduleItems.add(bScheduleItem);

        Boolean isSuccess = CS_ScheduleService.generateSchedules(new Set<Id>{
                salesOrder.Id
        }, new Set<Id>{
                prodConfig.Id
        });
        System.assert(!isSuccess);
    }

    @IsTest
    public static void testIfUpdateScheduleWorks() {
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
        salesOrder.csmso__Status__c = CS_const_SalesOrder.Status_PendingBooking;
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
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
        insert prodConfig;

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.Id;
        insert salesOrderSchedule;

        CS_Billing_Schedule__c csBillingSchedule = CS_utl_Schedule.createBillingSchedule(salesOrder.Id, salesOrderSchedule, prodConfig);
        insert csBillingSchedule;

        CS_Revenue_Schedule__c csRevenueSchedule = CS_utl_Schedule.createRevenueSchedule(salesOrder.Id, salesOrderSchedule, prodConfig);
        insert csRevenueSchedule;

        CS_Billing_Schedule_Item__c bScheduleItem = new CS_Billing_Schedule_Item__c();
        bScheduleItem.Sales_Order__c = salesOrder.Id;
        bScheduleItem.Billing_Schedule__c = csBillingSchedule.Id;
        bScheduleItem.Billing_Period_End_Date__c = Date.today().addDays(30);
        bScheduleItem.Product_Configuration__c = prodConfig.Id;
        insert bScheduleItem;

        List<CS_Billing_Schedule_Item__c> bScheduleItems = new List<CS_Billing_Schedule_Item__c>();
        bScheduleItems.add(bScheduleItem);

        CS_Custom_Settings__c customSettings = CS_Custom_Settings__c.getInstance();
        customSettings.Schedule_Item_Map__c = 'ScheduleItemMap';
        customSettings.Days__c = 180;
        customSettings.BillingBatchSize__c = 10;
        upsert customSettings;

        CS_ScheduleService scheduleServiceForUpdate = new CS_ScheduleService(new Set<Id>{salesOrder.Id}, new Set<Id>{prodConfig.Id});
        scheduleServiceForUpdate.updateSchedules();
    }
}
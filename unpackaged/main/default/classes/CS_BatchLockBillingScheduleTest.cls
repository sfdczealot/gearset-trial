/**
 * @name CS_BatchLockBillingScheduleTest
 * @description Test for CS_BatchLockBillingSchedule class
 * @revision
 *
 */
@isTest
private class CS_BatchLockBillingScheduleTest {


    private void createTestData() {
        //Account Creation.    
        List<Account> acc = TestDataSetupSO.createAccounts(1);
       
        //Contact Creation.
        List<Contact> con = TestDataSetupSO.createContacts(1, acc);
       
        //Opportunity Creation.
        List<Opportunity> opp = TestDataSetupSO.createOpportunities(1, acc, con);

        csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc[0], opp[0]);

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.Id;
        salesOrderSchedule.CurrencyIsoCode = 'USD';
        insert salesOrderSchedule;

        CS_Billing_Schedule__c billingSchedule = new CS_Billing_Schedule__c();
        billingSchedule.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        billingSchedule.CurrencyIsoCode = 'USD';
        billingSchedule.Sales_Order__c = billingSchedule.Id;
        insert billingSchedule;
    }

    /**
     * Tests getQueryMethod with Bill Runs
     */
    @IsTest
    private static void test_getQueryString() {
        
        //Account Creation.    
        List<Account> acc = TestDataSetupSO.createAccounts(1);
       
        //Contact Creation.
        List<Contact> con = TestDataSetupSO.createContacts(1, acc);
       
        //Opportunity Creation.
        List<Opportunity> opp = TestDataSetupSO.createOpportunities(1, acc, con);

        csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc[0], opp[0]);

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.Id;
        salesOrderSchedule.CurrencyIsoCode = 'USD';
        insert salesOrderSchedule;

        CS_Billing_Schedule__c billingSchedule = new CS_Billing_Schedule__c();
        billingSchedule.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        billingSchedule.CurrencyIsoCode = 'USD';
        billingSchedule.Sales_Order__c = billingSchedule.Id;
        insert billingSchedule;
        
        
        String INITIAL_QUERY_TEMPLATE = 'SELECT Id FROM csmso__Sales_Order__c WHERE Id IN ' +
                                           '(SELECT Sales_Order__c FROM CS_Billing_Schedule_Item__c ' +
                                           'WHERE Status__c = {0} AND ({1}))';
        String QUERY_TEMPLATE = 'SELECT Id, Name, Status__c, Billing_Calendar__c, Billing_Date__c ' +
                                           'FROM CS_Billing_Schedule_Item__c ' +
                                           'WHERE Status__c = {0} AND ({1})';
        CS_th_Worker.create();
        
        List<CS_Billing_Schedule_Item__c> billingScheduleItems = new List<CS_Billing_Schedule_Item__c>();
        for(Integer i = 0; i < 5; i++) {
            billingScheduleItems.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Open,
                                 CS_const_BillingScheduleItem.BillingCalendar_Standard,
                                 Date.today().addDays(-10), false, false));
        }
        
        for(Integer i = 0; i < billingScheduleItems.size(); i++) {
            billingScheduleItems[i].Billing_Schedule__c = billingSchedule.id;
        }
        
        insert billingScheduleItems;
        
        CS_th_BillRun.create(CS_const_BillRun.Status_Scheduled, CS_const_BillRun.CalendarType_Standard, Date.today());

        Test.startTest();
        
        CS_BatchLockBillingSchedule batch = new CS_BatchLockBillingSchedule();
        batch.salesOrderScheduleBatches = new List<Sales_Order_Schedule_Batch__mdt>();
        String query = batch.getQueryString(QUERY_TEMPLATE,'');
        
        Test.stopTest();

        System.assert(String.isNotBlank(query));
    }

    /**
     * Tests getQueryMethod without Bill Runs
     */ 
    @IsTest
    private static void test_getQueryStringNoBillRun() {
        
        //Account Creation.    
        List<Account> acc = TestDataSetupSO.createAccounts(1);
       
        //Contact Creation.
        List<Contact> con = TestDataSetupSO.createContacts(1, acc);
       
        //Opportunity Creation.
        List<Opportunity> opp = TestDataSetupSO.createOpportunities(1, acc, con);

        csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc[0], opp[0]);

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.Id;
        salesOrderSchedule.CurrencyIsoCode = 'USD';
        insert salesOrderSchedule;

        CS_Billing_Schedule__c billingSchedule = new CS_Billing_Schedule__c();
        billingSchedule.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        billingSchedule.CurrencyIsoCode = 'USD';
        billingSchedule.Sales_Order__c = billingSchedule.Id;
        insert billingSchedule;
        
        String INITIAL_QUERY_TEMPLATE = 'SELECT Id FROM csmso__Sales_Order__c WHERE Id IN ' +
                                           '(SELECT Sales_Order__c FROM CS_Billing_Schedule_Item__c ' +
                                           'WHERE Status__c = {0} AND ({1}))';
        String QUERY_TEMPLATE = 'SELECT Id, Name, Status__c, Billing_Calendar__c, Billing_Date__c ' +
                                           'FROM CS_Billing_Schedule_Item__c ' +
                                           'WHERE Status__c = {0} AND ({1})';
        CS_th_Worker.create();
        
        List<CS_Billing_Schedule_Item__c> billingScheduleItems = new List<CS_Billing_Schedule_Item__c>();
        for(Integer i = 0; i < 5; i++) {
            billingScheduleItems.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Open,
                                 CS_const_BillingScheduleItem.BillingCalendar_Standard,
                                 Date.today().addDays(-10), false, false));
        }
        
        for(Integer i = 0; i < billingScheduleItems.size(); i++) {
            billingScheduleItems[i].Billing_Schedule__c = billingSchedule.id;
        }
        
        insert billingScheduleItems;

        Test.startTest();
        
        CS_BatchLockBillingSchedule batch = new CS_BatchLockBillingSchedule();
        batch.salesOrderScheduleBatches = new List<Sales_Order_Schedule_Batch__mdt>();
        String query = batch.getQueryString(QUERY_TEMPLATE,'');
        
        Test.stopTest();

        System.assert(String.isNotBlank(query));
        System.assert(!query.contains('Billing_Date__c <= '));
    }

    /**
     * Tests onStart method
     */ 
    @IsTest
    private static void test_onStart() {
        
        //Account Creation.    
        List<Account> acc = TestDataSetupSO.createAccounts(1);
       
        //Contact Creation.
        List<Contact> con = TestDataSetupSO.createContacts(1, acc);
       
        //Opportunity Creation.
        List<Opportunity> opp = TestDataSetupSO.createOpportunities(1, acc, con);

        csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc[0], opp[0]);

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.Id;
        salesOrderSchedule.CurrencyIsoCode = 'USD';
        insert salesOrderSchedule;

        CS_Billing_Schedule__c billingSchedule = new CS_Billing_Schedule__c();
        billingSchedule.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        billingSchedule.CurrencyIsoCode = 'USD';
        billingSchedule.Sales_Order__c = billingSchedule.Id;
        insert billingSchedule;
        CS_th_Worker.create();
        
        List<CS_Billing_Schedule_Item__c> billingScheduleItems = new List<CS_Billing_Schedule_Item__c>();
        for(Integer i = 0; i < 5; i++) {
            billingScheduleItems.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Open,
                                 CS_const_BillingScheduleItem.BillingCalendar_Standard,
                                 Date.today().addDays(-10), false, false));
        }
        
        for(Integer i = 0; i < billingScheduleItems.size(); i++) {
            billingScheduleItems[i].Billing_Schedule__c = billingSchedule.id;
        }
        
        insert billingScheduleItems;
        
        CS_th_BillRun.create(CS_const_BillRun.Status_Scheduled, CS_const_BillRun.CalendarType_Standard, Date.today());

        Test.startTest();
        
        CS_BatchLockBillingSchedule batch = new CS_BatchLockBillingSchedule();
        batch.salesOrderScheduleBatches = new List<Sales_Order_Schedule_Batch__mdt>();
        Database.QueryLocator query = batch.onStart();
        
        Test.stopTest();
    }

    /**
     * Tests onFinish method
     */     
    @IsTest
    private static void test_onFinish() {
        
        //Account Creation.    
        List<Account> acc = TestDataSetupSO.createAccounts(1);
       
        //Contact Creation.
        List<Contact> con = TestDataSetupSO.createContacts(1, acc);
       
        //Opportunity Creation.
        List<Opportunity> opp = TestDataSetupSO.createOpportunities(1, acc, con);

        csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc[0], opp[0]);

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.Id;
        salesOrderSchedule.CurrencyIsoCode = 'USD';
        insert salesOrderSchedule;

        CS_Billing_Schedule__c billingSchedule = new CS_Billing_Schedule__c();
        billingSchedule.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        billingSchedule.CurrencyIsoCode = 'USD';
        billingSchedule.Sales_Order__c = billingSchedule.Id;
        insert billingSchedule;
        
        CS_th_Worker.create();
        
        List<CS_Billing_Schedule_Item__c> billingScheduleItems = new List<CS_Billing_Schedule_Item__c>();
        for(Integer i = 0; i < 5; i++) {
            billingScheduleItems.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Open,
                                 CS_const_BillingScheduleItem.BillingCalendar_Standard,
                                 Date.today().addDays(-10), false, false));
        }
        
        for(Integer i = 0; i < billingScheduleItems.size(); i++) {
            billingScheduleItems[i].Billing_Schedule__c = billingSchedule.id;
        }
        
        insert billingScheduleItems;
        
        Bill_Run__c billRun = CS_th_BillRun.create(CS_const_BillRun.Status_Scheduled, CS_const_BillRun.CalendarType_Standard, Date.today());
        billRun.Reference_Date__c = Date.today().addDays(1);
        update billRun;

        Test.startTest();
        
        CS_BatchLockBillingSchedule batch = new CS_BatchLockBillingSchedule();
        batch.salesOrderScheduleBatches = new List<Sales_Order_Schedule_Batch__mdt>();
        batch.onFinish();
        
        Test.stopTest();

        List<Bill_Run__c> billRuns = [SELECT Id, Status__c FROM Bill_Run__c WHERE Status__c = :CS_const_BillRun.Status_LockingBillSchedules];
        System.assertEquals(1, billRuns.size());
    }
    
    /**
     * Tests doWork method
     */     
    @IsTest
    private static void test_doWork() {
        
        //Account Creation.    
        List<Account> acc = TestDataSetupSO.createAccounts(1);
       
        //Contact Creation.
        List<Contact> con = TestDataSetupSO.createContacts(1, acc);
       
        //Opportunity Creation.
        List<Opportunity> opp = TestDataSetupSO.createOpportunities(1, acc, con);

        csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc[0], opp[0]);

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.Id;
        salesOrderSchedule.CurrencyIsoCode = 'USD';
        insert salesOrderSchedule;

        CS_Billing_Schedule__c billingSchedule = new CS_Billing_Schedule__c();
        billingSchedule.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        billingSchedule.CurrencyIsoCode = 'USD';
        billingSchedule.Sales_Order__c = billingSchedule.Id;
        insert billingSchedule;
        
        CS_th_Worker.create();
        
        List<CS_Billing_Schedule_Item__c> billingScheduleItems = new List<CS_Billing_Schedule_Item__c>();
        for(Integer i = 0; i < 5; i++) {
            billingScheduleItems.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Open,
                                 CS_const_BillingScheduleItem.BillingCalendar_Standard,
                                 Date.today().addDays(-10), false, false));
        }
        
        for(Integer i = 0; i < billingScheduleItems.size(); i++) {
            billingScheduleItems[i].Billing_Schedule__c = billingSchedule.id;
        }
        
        insert billingScheduleItems;
        
        CS_th_BillRun.create(CS_const_BillRun.Status_Scheduled, CS_const_BillRun.CalendarType_Standard, Date.today());

        Test.startTest();
        
        CS_BatchLockBillingSchedule batch = new CS_BatchLockBillingSchedule();
        batch.salesOrderScheduleBatches = new List<Sales_Order_Schedule_Batch__mdt>();
        batch.doWork(billingScheduleItems);
        
        Test.stopTest();

        List<CS_Billing_Schedule_Item__c> billSchedules = [SELECT Id, Status__c FROM CS_Billing_Schedule_Item__c WHERE Status__c = :CS_const_BillingScheduleItem.Status_Locked];
        System.assertEquals(0, billSchedules.size());
    }
    
    /**
     * Tests execute method
     */     
    @IsTest
    private static void test_execute() {
        
        //Account Creation.    
        List<Account> acc = TestDataSetupSO.createAccounts(1);
       
        //Contact Creation.
        List<Contact> con = TestDataSetupSO.createContacts(1, acc);
       
        //Opportunity Creation.
        List<Opportunity> opp = TestDataSetupSO.createOpportunities(1, acc, con);

        csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc[0], opp[0]);

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.Id;
        salesOrderSchedule.CurrencyIsoCode = 'USD';
        insert salesOrderSchedule;

        CS_Billing_Schedule__c billingSchedule = new CS_Billing_Schedule__c();
        billingSchedule.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        billingSchedule.CurrencyIsoCode = 'USD';
        billingSchedule.Sales_Order__c = billingSchedule.Id;
        insert billingSchedule;
        
        CS_th_Worker.create();
        
        List<CS_Billing_Schedule_Item__c> billingScheduleItems = new List<CS_Billing_Schedule_Item__c>();
        for(Integer i = 0; i < 50; i++) {
            billingScheduleItems.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Open,
                                 CS_const_BillingScheduleItem.BillingCalendar_Standard,
                                 Date.today().addDays(-10), false, false));
            billingScheduleItems.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Open,
                                 CS_const_BillingScheduleItem.BillingCalendar_Standard,
                                 Date.today().addDays(10), false, false));
            billingScheduleItems.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Locked,
                                 CS_const_BillingScheduleItem.BillingCalendar_Standard,
                                 Date.today().addDays(-15), false, false));
            billingScheduleItems.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Open,
                                 CS_const_BillingScheduleItem.BillingCalendar_Standard,
                                 Date.today().addDays(-2), false, false));
            billingScheduleItems.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Open,
                                 CS_const_BillingScheduleItem.BillingCalendar_Broadcast,
                                 Date.today().addDays(-15), false, false));
        }
        
        for(Integer i = 0; i < billingScheduleItems.size(); i++) {
            billingScheduleItems[i].Billing_Schedule__c = billingSchedule.id;
        }
        
        insert billingScheduleItems;
        
        List<Bill_Run__c> billRuns = new List<Bill_Run__c>{
            CS_th_BillRun.create(CS_const_BillRun.Status_Scheduled, CS_const_BillRun.CalendarType_Standard, Date.today().addDays(-12), false),
            CS_th_BillRun.create(CS_const_BillRun.Status_Scheduled, CS_const_BillRun.CalendarType_Standard, Date.today().addDays(-5), false),
            CS_th_BillRun.create(CS_const_BillRun.Status_Scheduled, CS_const_BillRun.CalendarType_Standard, Date.today().addDays(15), false),
            CS_th_BillRun.create(CS_const_BillRun.Status_LockingBillSchedules, CS_const_BillRun.CalendarType_Standard, Date.today().addDays(-2), false),
            CS_th_BillRun.create(CS_const_BillRun.Status_LockingBillSchedules, CS_const_BillRun.CalendarType_Broadcast, Date.today().addDays(25), false)
        };
        insert billRuns;

        Test.startTest();
        
        CS_BatchLockBillingSchedule batch = new CS_BatchLockBillingSchedule();
        batch.salesOrderScheduleBatches = new List<Sales_Order_Schedule_Batch__mdt>();
        batch.execute();
        
        Test.stopTest();

        List<CS_Billing_Schedule_Item__c> billSchedules = [SELECT Id, Status__c FROM CS_Billing_Schedule_Item__c WHERE Status__c = :CS_const_BillingScheduleItem.Status_Locked];
        System.assertEquals(50, billSchedules.size());
        
        List<Bill_Run__c> billRunsLocked = [SELECT Id, Status__c FROM Bill_Run__c WHERE Status__c = :CS_const_BillRun.Status_LockingBillSchedules];
        System.assertEquals(4, billRunsLocked.size());
    }
}
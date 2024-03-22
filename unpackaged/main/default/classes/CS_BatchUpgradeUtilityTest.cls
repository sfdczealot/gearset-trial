@IsTest(SeeAllData=false)
private class CS_BatchUpgradeUtilityTest {
    private static List<Id> soIds;
    private static List<csmso__Sales_Order__c> salesOrders;

    private static void createTestData() {

        insert new CSSX__No_Triggers__c(cssx__Flag__c = true, SetupOwnerId = UserInfo.getOrganizationId());
        CS_utl_User.disableAllTriggers(UserInfo.getOrganizationId());
        CS_th_Worker.create();

        //Account Creation.
        List<Account> Acc = TestDataSetupSO.createAccounts(1);

        //Contact Creation.
        List<Contact> con = TestDataSetupSO.createContacts(1, Acc);

        //Opportunity Creation.
        List<Opportunity> opp = TestDataSetupSO.createOpportunities(1, Acc, con);

        //SalesOrder Creation.
        salesOrders = TestDataSetupSO.createSalesOrders(1, Acc, opp);
        soIds = new List<Id>();
        for (csmso__Sales_Order__c so : salesOrders) {
            soIds.add(so.Id);
        }

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef = TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, salesOrders);

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        //Fulfilment Creation.
        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1, salesOrders, Acc);
        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();

        List<Id> pcIds = new List<Id>();

        for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
            if (salesOrders.size() > 0) {
                pConfig.Sales_Order__c = salesOrders[0].Id;
            }
            pConfig.Billing_Schedule_Rule__c = bScheduleRule.Id;
            pConfig.Revenue_Schedule_Rule__c = rScheduleRule.Id;
            pConfig.Requires_Rescheduling__c = true;
            pConfig.cscfga__Configuration_Status__c = 'Valid';
            pcIds.add(pConfig.Id);
        }
        update prodConfigs;

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1, fulfilment, prodConfigs);
        fulfilmentItem[0].csdf__Status__c = 'Reserved';
        update fulfilmentItem;

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrders[0].Id;
        insert salesOrderSchedule;

        CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
        bScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        bScheduleHeader.Under_IFC__c = false;
        insert bScheduleHeader;

        CS_Billing_Schedule_Item__c bSchedule = new CS_Billing_Schedule_Item__c();
        bSchedule.Product_Configuration__c = prodConfigs[0].Id;
        bSchedule.Status__c = 'Open';
        bSchedule.Sales_Order__c = prodConfigs[0].Sales_Order__c;
        bSchedule.DFP_Actuals__c = 100;
        bSchedule.Net_Rate__c = 100.0;
        bSchedule.Gross_Rate__c = 10;
        bSchedule.Insertion_Unit_Type__c = '2';
        bSchedule.CurrencyIsoCode = 'EUR';
        bSchedule.Billing_Period_Start_Date__c = Date.today().addDays(-4);
        bSchedule.Billing_Period_End_Date__c = Date.today().addDays(4);
        bSchedule.Billing_Schedule__c = bScheduleHeader.Id;
        bSchedule.Booked_Quantity__c = 10;
        bSchedule.Booked_Gross_Amount__c = 10;
        bSchedule.Booked_Net_Amount__c = 10;
        insert bSchedule;

        //CS Revenue Schedule
        CS_Revenue_Schedule__c rScheduleHeader = new CS_Revenue_Schedule__c();
        rScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        insert rScheduleHeader;

        //CS Revenue Schedule Item
        CS_Revenue_Schedule_Item__c rSchedule = new CS_Revenue_Schedule_Item__c();
        rSchedule.Sales_Order__c = prodConfigs[0].Sales_Order__c;
        rSchedule.Product_Configuration__c = prodConfigs[0].Id;
        rSchedule.Status__c = 'Open';
        rSchedule.Net_Rate__c = 100.0;
        rSchedule.Gross_Rate__c = 10;
        rSchedule.CurrencyIsoCode = 'EUR';
        rSchedule.Insertion_Unit_Type__c = '2';
        rSchedule.Rev_Rec_Period_Start_Date__c = Date.today().addDays(-4);
        rSchedule.Rev_Rec_Period_End_Date__c = Date.today().addDays(4);
        rSchedule.Revenue_Schedule__c = rScheduleHeader.Id;
        rSchedule.Booked_Quantity__c = 10;
        rSchedule.Booked_Gross_Amount__c = 10;
        rSchedule.Booked_Net_Amount__c = 10;
        insert rSchedule;

        //prodConfigs = [SELECT Id, Insertion_Quantity__c FROM cscfga__Product_Configuration__c];
        salesOrders = [SELECT Id, name, csmso__Status__c FROM csmso__Sales_Order__c];
        List<CS_Billing_Schedule_Item__c> bScheduleList = [SELECT Id FROM CS_Billing_Schedule_Item__c];
        List<CS_Revenue_Schedule_Item__c> rScheduleList = [SELECT Id FROM CS_Revenue_Schedule_Item__c];
    }

    @IsTest
    static void testBatchUpgradeUtility() {
        createTestData();

        Test.startTest();

        CS_BatchUpgradeUtility batch = new CS_BatchUpgradeUtility(10);
        batch.doWork(salesOrders);

        Test.stopTest();
    }

    @IsTest
    static void testBatchUpgradeUtility2() {
        createTestData();

        Test.startTest();

        CS_BatchUpgradeUtility batch = new CS_BatchUpgradeUtility(soIds, 10);
        batch.doWork(salesOrders);

        Test.stopTest();
    }
}
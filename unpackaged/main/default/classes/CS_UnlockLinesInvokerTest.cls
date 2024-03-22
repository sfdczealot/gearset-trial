/**
 * Created by tvrtko.matosevic on 15/07/2019.
 */

@IsTest
private class CS_UnlockLinesInvokerTest {
    @IsTest
    static void testInvokeUnlockLinesInvoker() {

        Test.startTest();
        Account acc = TestDataSetupSO.createAccount();
        insert acc;

        Contact con = TestDataSetupSO.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;

        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_BOOKED;
        salesOrder.SO_Lines_Ad_Server_Items__c = 2;
        salesOrder.Reason_for_Retraction__c = 'Optimization request by Spotify';
        salesOrder.Last_Date_Retracted__c = Date.today();
        salesOrder.Last_Date_Booked__c = Date.today().addDays(-1);
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Advertiser_Final__c = acc.Id;
        insert salesOrder;

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);
        prodDef[0].Name = 'Digital DFP Spotify v1.6';
        update prodDef;

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDefs = TestDataSetupSO.createAttributeDefinitions(1, prodDef);
        attDefs[0].Name = 'Keyvalues and Audience JSON';
        update attDefs;

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
                salesOrder/*, salesOrder1*/
        });

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        List<cscfga__Attribute__c> attributes = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c attr = new cscfga__Attribute__c();
        attr.cscfga__Product_Configuration__c = prodConfigs[0].Id;
        attr.cscfga__Attribute_Definition__c = attDefs[0].Id;
        attr.Name = 'Flight Begin Date Time Selected';
        attr.cscfga__Value__c = String.valueOf(Datetime.now().addDays(30)) + ' America/New_York';
        attributes.add(attr);

        cscfga__Attribute__c attr2 = new cscfga__Attribute__c();
        attr2.cscfga__Product_Configuration__c = prodConfigs[0].Id;
        attr2.cscfga__Attribute_Definition__c = attDefs[0].Id;
        attr2.Name = 'Flight End Date Time Selected';
        attr2.cscfga__Value__c = String.valueOf(Datetime.now().addDays(70)) + ' America/New_York';
        attributes.add(attr2);
        insert attributes;

        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(salesOrder, acc);
        insert testFulfilment;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfigs[0], salesOrder, testFulfilment);
        insert testFulfilmentItem;

        /*
        prodConfigs[0].Fulfilment_Item__c = testFulfilmentItem.Id;
        update prodConfigs;
        */

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrder.id;
        insert salesOrderSchedule;

        //CS Biling Schedule
        CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
        bScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        bScheduleHeader.Under_IFC__c = false;
        bScheduleHeader.Product_Configuration__c = prodConfigs[0].Id;
        insert bScheduleHeader;

        //CS Revenue Schedule
        CS_Revenue_Schedule__c rScheduleHeader = new CS_Revenue_Schedule__c();
        rScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        rScheduleHeader.Under_IFC__c = false;
        rScheduleHeader.Product_Configuration__c = prodConfigs[0].Id;
        insert rScheduleHeader;

        //CS Biling Schedule Item
        CS_Billing_Schedule_Item__c billingScheduleItem = new CS_Billing_Schedule_Item__c();
        billingScheduleItem.Product_Configuration__c = prodConfigs[0].Id;
        billingScheduleItem.Status__c = 'Open';
        billingScheduleItem.Sales_Order__c = prodConfigs[0].Sales_Order__c;
        billingScheduleItem.DFP_Actuals__c = 100;
        billingScheduleItem.Net_Rate__c = 100.0;
        billingScheduleItem.DFP_Order_Line_ID__c = salesOrder.Id;
        billingScheduleItem.Billing_Date__c = Date.Today().addDays(-4);
        billingScheduleItem.Billing_Period_Start_Date__c = Date.today().addDays(-4);
        billingScheduleItem.Billing_Period_End_Date__c = Date.today().addDays(4);
        billingScheduleItem.Billing_Schedule__c = bScheduleHeader.Id;
        billingScheduleItem.DFP_Order_Line_ID__c = 'External ID Test 123';
        billingScheduleItem.X3rd_Party_Ad_Server__c = 'Test Server Name';
        insert billingScheduleItem;

        //CS Revenue Schedule Item
        CS_Revenue_Schedule_Item__c rSchedule = new CS_Revenue_Schedule_Item__c();
        rSchedule.Sales_Order__c = prodConfigs[0].Sales_Order__c;
        rSchedule.Product_Configuration__c = prodConfigs[0].Id;
        rSchedule.Status__c = 'Locked';
        rSchedule.Rev_Rec_Date__c = Date.Today().addDays(-4);
        rSchedule.Rev_Rec_Period_Start_Date__c = Date.today().addDays(-4);
        rSchedule.Rev_Rec_Period_End_Date__c = Date.today().addDays(4);
        rSchedule.Revenue_Schedule__c = rScheduleHeader.Id;
        insert rSchedule;

        Test.stopTest();

        CS_UnlockLinesInvoker csUnlockLinesInvoker = new CS_UnlockLinesInvoker();
        String result = csUnlockLinesInvoker.performAction(JSON.serialize(new List<Id> {prodConfigs[0].Id}));

        System.assert(!String.isEmpty(result));
    }
}
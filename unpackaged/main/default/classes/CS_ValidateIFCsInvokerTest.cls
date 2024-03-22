/**
 * Created by tvrtko.matosevic on 20/06/2019.
 */

@IsTest
private class CS_ValidateIFCsInvokerTest {

    @IsTest
    public static void validateValidateIFCsInvokerTest() {
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

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1,salesOrders);

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1,prodBaskets,prodDef);


        //Fulfilment Creation.
        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,salesOrders,Acc);
        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();

        for(cscfga__Product_Configuration__c pConfig: prodConfigs){
            if (salesOrders.size() > 0) {
                pConfig.Sales_Order__c = salesOrders[0].Id;
            }
            pConfig.Billing_Schedule_Rule__c = bScheduleRule.Id;
            pConfig.Revenue_Schedule_Rule__c = rScheduleRule.Id;
            pConfig.Requires_Rescheduling__c= true;
            pConfig.cscfga__Configuration_Status__c ='Valid';
        }
        update prodConfigs;

        //List<Revenue_Recognition_Schedule__c> rSchedules = testDataSetupBilling.createRevenueSchedules(3,salesOrders,fulfilmentItem,prodConfigs);
        List<CS_Sales_Order_Schedule__c> salesOrderSchedules = new List<CS_Sales_Order_Schedule__c>();

        for(csmso__Sales_Order__c salesOrder:salesOrders){
            CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
            sOs.Sales_Order__c = salesOrder.Id;
            salesOrderSchedules.add(sOs);
        }

        insert salesOrderSchedules;

        List<CS_Billing_Schedule__c> bSchedules = new List<CS_Billing_Schedule__c>();

        for(CS_Sales_Order_Schedule__c sOrderSchedule:salesOrderSchedules){
            CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
            bScheduleHeader.CS_Sales_Order_Schedule__c = sOrderSchedule.Id;
            bSchedules.add(bScheduleHeader);
        }

        insert bSchedules;

        CS_Billing_Schedule__c bScheduleHeader = bSchedules[0];


        cscfga__Product_Configuration__c pc = [SELECT Id, Sales_Order__c
        FROM cscfga__Product_Configuration__c
        LIMIT 1][0];

        CS_Billing_Schedule_Item__c bschedule = new CS_Billing_Schedule_Item__c();
        bschedule.Product_Configuration__c = pc.Id;
        bschedule.Status__c = 'Locked';
        bschedule.Sales_Order__c = pc.Sales_Order__c;
        bschedule.DFP_Actuals__c = 100;
        //bSchedule.Billing_Quantity__c = 10.0;
        bschedule.Net_Rate__c = 100.0;
        bschedule.Billing_Period_Start_Date__c = Date.today();
        bschedule.Billing_Schedule__c=bScheduleHeader.Id;
        insert bschedule;

        List<Object> paramsList = new List<Object>();
        Map<String, Object> paramsObj = new Map<String, Object>();
        paramsObj.put('ConfigId', pc.Id);
        paramsList.add(paramsObj);

        Map<String, Object> paramsObj1 = new Map<String, Object>();
        paramsObj1.put('Sales_Order_Id_0', pc.Sales_Order__c);
        paramsList.add(paramsObj1);

        Map<String, Object> paramsObj2 = new Map<String, Object>();
        paramsObj2.put('Insertion_Quantity_0', 1000);
        paramsList.add(paramsObj2);

        Map<String, Object> paramsObj3 = new Map<String, Object>();
        paramsObj3.put('Start_Date_0', Date.today());
        paramsList.add(paramsObj3);

        Map<String, Object> paramsObj4 = new Map<String, Object>();
        paramsObj4.put('End_Date_0', Date.today()+15);
        paramsList.add(paramsObj4);

        Map<String, Object> paramsObj5 = new Map<String, Object>();
        paramsObj5.put('Rate_0', 12);
        paramsList.add(paramsObj5);

        Map<String, Object> paramsObj6 = new Map<String, Object>();
        paramsObj6.put('Fulfilment_Item_Status_0', 'InProgress');
        paramsList.add(paramsObj6);

        Map<String, Object> finalParamObj = new Map<String,Object>();
        finalParamObj.put('data', paramsList);

        Test.startTest();
        CS_ValidateIFCsInvoker validateIFCInvoker = new CS_ValidateIFCsInvoker();
        String performActionResult = validateIFCInvoker.performAction(JSON.serialize(finalParamObj));
        Map<String, Object> resultJSONObject = (Map<String, Object>) JSON.deserializeUntyped(performActionResult);
        Test.stopTest();

        System.assertEquals((Boolean)resultJSONObject.get('isError'), true);
        System.assertNotEquals((String)resultJSONObject.get('errorMsg'), null);
    }
}
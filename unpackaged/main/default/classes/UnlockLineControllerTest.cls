/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class for UnlockLineController
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v0.1            aldo.topic@cloudsensesolutions.com
* 2018-12-05      Commented out Billing_Schedule__c legacy object. Class should be changed to use 
*                 new custom object (CS_Billing_Schedule__c and CS_Billing_Schedule_Item__c). Same
*                 for Revenue_Recognition_Schedule__c, should use (CS_Revenue_Schedule__c and 
*                 CS_Revenue_Schedule_Item__c).
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@isTest(seeAllData=false)
public class UnlockLineControllerTest {
    private static String productConfigId;
    private static List<csmso__Sales_Order__c> salesOrders;
    //private static List<Billing_Schedule__c> bSchedules = new List<Billing_Schedule__c>();

    private static void createTestData(){
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
        salesOrders = TestDataSetupSO.createSalesOrders(1,Acc,opp);
        
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
        fulfilmentItem[0].csdf__Status__c = 'Reserved';
        update fulfilmentItem;

        //List<Revenue_Recognition_Schedule__c> rSchedules = testDataSetupBilling.createRevenueSchedules(3,salesOrders,fulfilmentItem,prodConfigs);
        
        /*
        bSchedules = testDataSetupBilling.createBillingSchedules(3,salesOrders,fulfilmentItem,prodConfigs);
        for(Billing_Schedule__c billingSchedule : bSchedules) {
            if(billingSchedule.Status__c != 'Open') {
                billingSchedule.Status__c = 'Forecast';
            }
        }
        update bSchedules;
        */
        
        productConfigId = prodConfigs[0].Id;
    }
    
    @isTest 
    public static void unlockLineControllerInPastTest() {
        createTestData();
    
        // insert attributes
        List<cscfga__Attribute__c> salesOrderLinesAttrList = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c attributeStartDate = new cscfga__Attribute__c();
        attributeStartDate.Name = 'Flight Begin Date Time Selected';
        attributeStartDate.cscfga__Product_Configuration__c = productConfigId;
        attributeStartDate.cscfga__Value__c = String.valueOf(DateTime.now().addDays(-40));
        salesOrderLinesAttrList.add(attributeStartDate);
    
        cscfga__Attribute__c attributeEndDate = new cscfga__Attribute__c();
        attributeEndDate.Name = 'Flight End Date Time Selected';
        attributeEndDate.cscfga__Product_Configuration__c = productConfigId;
        attributeEndDate.cscfga__Value__c = String.valueOf(DateTime.now().addDays(-30));
        salesOrderLinesAttrList.add(attributeEndDate);
    
        insert salesOrderLinesAttrList;
    
        Test.startTest();
        UnlockLineController unlockLineController = new UnlockLineController();
        String performActionResult = (String) JSON.deserialize(unlockLineController.performAction(JSON.serialize(productConfigId)), String.class);
        Test.stopTest();

        System.assertEquals(performActionResult, 'Partially Locked');
    }
    
    @isTest 
    public static void unlockLineControllerInFutureTest() {
        createTestData();
    
        // insert attributes
        List<cscfga__Attribute__c> salesOrderLinesAttrList = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c attributeStartDate = new cscfga__Attribute__c();
        attributeStartDate.Name = 'Flight Begin Date Time Selected';
        attributeStartDate.cscfga__Product_Configuration__c = productConfigId;
        attributeStartDate.cscfga__Value__c = String.valueOf(DateTime.now().addDays(30));
        salesOrderLinesAttrList.add(attributeStartDate);
    
        cscfga__Attribute__c attributeEndDate = new cscfga__Attribute__c();
        attributeEndDate.Name = 'Flight End Date Time Selected';
        attributeEndDate.cscfga__Product_Configuration__c = productConfigId;
        attributeEndDate.cscfga__Value__c = String.valueOf(DateTime.now().addDays(40));
        salesOrderLinesAttrList.add(attributeEndDate);
    
        insert salesOrderLinesAttrList;
    
        Test.startTest();
        UnlockLineController unlockLineController = new UnlockLineController();
        String performActionResult = (String) JSON.deserialize(unlockLineController.performAction(JSON.serialize(productConfigId)), String.class);
        Test.stopTest();

    }
    
    @isTest 
    public static void unlockLineControlleHasLockedReadyPendingTest() {
        createTestData();
    
        // insert attributes
        List<cscfga__Attribute__c> salesOrderLinesAttrList = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c attributeStartDate = new cscfga__Attribute__c();
        attributeStartDate.Name = 'Flight Begin Date Time Selected';
        attributeStartDate.cscfga__Product_Configuration__c = productConfigId;
        attributeStartDate.cscfga__Value__c = String.valueOf(DateTime.now().addDays(30));
        salesOrderLinesAttrList.add(attributeStartDate);
    
        cscfga__Attribute__c attributeEndDate = new cscfga__Attribute__c();
        attributeEndDate.Name = 'Flight End Date Time Selected';
        attributeEndDate.cscfga__Product_Configuration__c = productConfigId;
        attributeEndDate.cscfga__Value__c = String.valueOf(DateTime.now().addDays(40));
        salesOrderLinesAttrList.add(attributeEndDate);
    
        insert salesOrderLinesAttrList;
        
        /*
        bSchedules[0].Status__c = 'Locked';
        update bSchedules;
        */
    
        Test.startTest();
        UnlockLineController unlockLineController = new UnlockLineController();
        String performActionResult = (String) JSON.deserialize(unlockLineController.performAction(JSON.serialize(productConfigId)), String.class);
        Test.stopTest();
    }
    
    @isTest 
    public static void unlockLineControllerAllMixedBillingSchTest() {
        createTestData();
    
        // insert attributes
        List<cscfga__Attribute__c> salesOrderLinesAttrList = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c attributeStartDate = new cscfga__Attribute__c();
        attributeStartDate.Name = 'Flight Begin Date Time Selected';
        attributeStartDate.cscfga__Product_Configuration__c = productConfigId;
        attributeStartDate.cscfga__Value__c = String.valueOf(DateTime.now().addDays(30));
        salesOrderLinesAttrList.add(attributeStartDate);
    
        cscfga__Attribute__c attributeEndDate = new cscfga__Attribute__c();
        attributeEndDate.Name = 'Flight End Date Time Selected';
        attributeEndDate.cscfga__Product_Configuration__c = productConfigId;
        attributeEndDate.cscfga__Value__c = String.valueOf(DateTime.now().addDays(40));
        salesOrderLinesAttrList.add(attributeEndDate);
        insert salesOrderLinesAttrList;

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrders[0].Id;
        insert salesOrderSchedule;

        CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
        bs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        insert bs;

        CS_Revenue_Schedule__c rs = new CS_Revenue_Schedule__c();
        rs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        insert rs;

        CS_Billing_Schedule_Item__c bsItem = new CS_Billing_Schedule_Item__c();
        bsItem.Sales_Order__c = salesOrders[0].Id;
        bsItem.Product_Configuration__c = productConfigId;
        bsItem.Billing_Schedule__c = bs.Id;
        bsItem.Status__c = 'Open';
        insert bsItem;

        CS_Billing_Schedule_Item__c bsItem2 = new CS_Billing_Schedule_Item__c();
        bsItem2.Sales_Order__c = salesOrders[0].Id;
        bsItem2.Product_Configuration__c = productConfigId;
        bsItem2.Billing_Schedule__c = bs.Id;
        bsItem2.Status__c = 'Closed';
        insert bsItem2;

        CS_Billing_Schedule_Item__c bsItem3 = new CS_Billing_Schedule_Item__c();
        bsItem3.Sales_Order__c = salesOrders[0].Id;
        bsItem3.Product_Configuration__c = productConfigId;
        bsItem3.Billing_Schedule__c = bs.Id;
        bsItem3.Status__c = 'Forecast';
        insert bsItem3;

        Test.startTest();
        UnlockLineController unlockLineController = new UnlockLineController();
        String performActionResult = (String) JSON.deserialize(unlockLineController.performAction(JSON.serialize(productConfigId)), String.class);
        Test.stopTest();

        //System.assertEquals(performActionResult, 'Partially Locked');
    }

    @isTest
    public static void unlockLineControllerAllReadyBillingSchTest() {
        createTestData();

        // insert attributes
        List<cscfga__Attribute__c> salesOrderLinesAttrList = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c attributeStartDate = new cscfga__Attribute__c();
        attributeStartDate.Name = 'Flight Begin Date Time Selected';
        attributeStartDate.cscfga__Product_Configuration__c = productConfigId;
        attributeStartDate.cscfga__Value__c = String.valueOf(DateTime.now().addDays(30));
        salesOrderLinesAttrList.add(attributeStartDate);

        cscfga__Attribute__c attributeEndDate = new cscfga__Attribute__c();
        attributeEndDate.Name = 'Flight End Date Time Selected';
        attributeEndDate.cscfga__Product_Configuration__c = productConfigId;
        attributeEndDate.cscfga__Value__c = String.valueOf(DateTime.now().addDays(40));
        salesOrderLinesAttrList.add(attributeEndDate);
        insert salesOrderLinesAttrList;

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrders[0].Id;
        insert salesOrderSchedule;

        CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
        bs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        insert bs;

        CS_Revenue_Schedule__c rs = new CS_Revenue_Schedule__c();
        rs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        insert rs;

        CS_Billing_Schedule_Item__c bsItem = new CS_Billing_Schedule_Item__c();
        bsItem.Sales_Order__c = salesOrders[0].Id;
        bsItem.Product_Configuration__c = productConfigId;
        bsItem.Billing_Schedule__c = bs.Id;
        bsItem.Status__c = 'Ready';
        insert bsItem;

        CS_Billing_Schedule_Item__c bsItem2 = new CS_Billing_Schedule_Item__c();
        bsItem2.Sales_Order__c = salesOrders[0].Id;
        bsItem2.Product_Configuration__c = productConfigId;
        bsItem2.Billing_Schedule__c = bs.Id;
        bsItem2.Status__c = 'Ready';
        insert bsItem2;

        Test.startTest();
        UnlockLineController unlockLineController = new UnlockLineController();
        String performActionResult = (String) JSON.deserialize(unlockLineController.performAction(JSON.serialize(productConfigId)), String.class);
        Test.stopTest();

        System.assertEquals(performActionResult, 'Partially Locked');
    }

    @isTest
    public static void unlockLineControllerAllReadyBillingSchWithTimeTest() {
        createTestData();

        // insert attributes
        List<cscfga__Attribute__c> salesOrderLinesAttrList = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c attributeStartDate = new cscfga__Attribute__c();
        attributeStartDate.Name = 'Flight Begin Date Time Selected';
        attributeStartDate.cscfga__Product_Configuration__c = productConfigId;
        attributeStartDate.cscfga__Value__c = String.valueOf(DateTime.now().addDays(30))+' America/New_York';
        salesOrderLinesAttrList.add(attributeStartDate);

        cscfga__Attribute__c attributeEndDate = new cscfga__Attribute__c();
        attributeEndDate.Name = 'Flight End Date Time Selected';
        attributeEndDate.cscfga__Product_Configuration__c = productConfigId;
        attributeEndDate.cscfga__Value__c = String.valueOf(DateTime.now().addDays(40))+' America/New_York';
        salesOrderLinesAttrList.add(attributeEndDate);
        insert salesOrderLinesAttrList;

        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.Sales_Order__c = salesOrders[0].Id;
        insert salesOrderSchedule;

        CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
        bs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        insert bs;

        CS_Revenue_Schedule__c rs = new CS_Revenue_Schedule__c();
        rs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
        insert rs;

        CS_Billing_Schedule_Item__c bsItem = new CS_Billing_Schedule_Item__c();
        bsItem.Sales_Order__c = salesOrders[0].Id;
        bsItem.Product_Configuration__c = productConfigId;
        bsItem.Billing_Schedule__c = bs.Id;
        bsItem.Status__c = 'Ready';
        insert bsItem;

        CS_Billing_Schedule_Item__c bsItem2 = new CS_Billing_Schedule_Item__c();
        bsItem2.Sales_Order__c = salesOrders[0].Id;
        bsItem2.Product_Configuration__c = productConfigId;
        bsItem2.Billing_Schedule__c = bs.Id;
        bsItem2.Status__c = 'Ready';
        insert bsItem2;

        Test.startTest();
        UnlockLineController unlockLineController = new UnlockLineController();
        String performActionResult = (String) JSON.deserialize(unlockLineController.performAction(JSON.serialize(productConfigId)), String.class);
        Test.stopTest();

        System.assertEquals(performActionResult, 'Partially Locked');
    }
}
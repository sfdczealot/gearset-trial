/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description : Test Class for CS_utl_ProductConfiguration
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author     : Kalyan Erraguntla <kalyan.erraguntla@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

@isTest
public class CS_utl_ProductConfigurationTest {
    /** 
     * Checks if Product Configuration requires billing schedule
     */	
	@isTest
    public static void test_isBillingScheduleRequired() {
    	Account acc = TestDataSetupTargetables.createAccount();
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;
        
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);        
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'Booked';
        salesOrder.Applicable_IO_Volume_Discount_Range__c =1;
    	salesOrder.Primary_Sales_Order__c = true;
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Advertiser_Final__c = acc.Id;
        insert salesOrder;
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;
        
        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket );
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.IO_Volume_Discount_Range_1__c = 10;
        prodConfig.Revenue_Schedule_Rule__c = rScheduleRule.id;
        insert prodConfig;
        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(salesOrder,acc);      
        insert testFulfilment;
        
        Test.startTest();
        system.assertequals(CS_utl_ProductConfiguration.isBillingScheduleRequired(prodConfig,null),false);
        system.assertequals(prodConfig.Sales_order__c,salesOrder.id);
        system.assertequals(prodConfig.Revenue_Schedule_Rule__c,rScheduleRule.id);
        Test.stopTest();
    }
    
    /**
     * Checks if Product Configuration requires revenue schedule
     */	
	@isTest
    public static void test_isRevenueScheduleRequired() {
    	Account acc = TestDataSetupTargetables.createAccount();
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;
        
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);        
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.Applicable_IO_Volume_Discount_Range__c =1;
    	salesOrder.Primary_Sales_Order__c = true;
    	salesOrder.csmso__Status__c = 'Draft';
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Advertiser_Final__c = acc.Id;
        insert salesOrder;
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;
        
        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket );
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.IO_Volume_Discount_Range_1__c = 10;
        prodConfig.Revenue_Schedule_Rule__c = rScheduleRule.id;
        prodConfig.Sales_Order__c = salesOrder.id;
        insert prodConfig;
        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(salesOrder,acc);      
        insert testFulfilment;
        
        Test.startTest();
        system.assertequals(CS_utl_ProductConfiguration.isRevenueScheduleRequired(prodConfig,null),true);
        system.assertequals(prodConfig.Sales_order__c,salesOrder.id);
        system.assertequals(prodConfig.Revenue_Schedule_Rule__c,rScheduleRule.id);
        Test.stopTest();
    }
    
    /**
     * Gets Billing and Revenues Schedule Items based on Product Configuration Ids
     */	
	@isTest
    public static void test_getBillingRevenueScheduleItems() {
    	Account acc = TestDataSetupTargetables.createAccount();
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;
        
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);        
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'Draft';
        salesOrder.Applicable_IO_Volume_Discount_Range__c =1;
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Advertiser_Final__c = acc.Id;
        insert salesOrder;
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket );
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.IO_Volume_Discount_Range_1__c = 10;
        insert prodConfig;
        
        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.sales_order__c = salesOrder.id;
        insert salesOrderSchedule;
        
        CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
        bs.CS_Sales_Order_Schedule__c = salesOrderSchedule.id;
        insert bs;
        
        CS_Revenue_Schedule__c rs = new CS_Revenue_Schedule__c();
        rs.CS_Sales_Order_Schedule__c = salesOrderSchedule.id;
        insert rs;
        
        CS_Billing_Schedule_item__c bsItem = new CS_Billing_Schedule_item__c();
        bsItem.Sales_Order__c = salesOrder.id;
        bsItem.Product_Configuration__c = prodConfig.id;
        bsItem.Billing_Schedule__c = bs.id;
        insert bsItem;
        
        CS_Revenue_Schedule_item__c rsItem = new CS_Revenue_Schedule_item__c();
        rsItem.Sales_Order__c = salesOrder.id;
        rsItem.Product_Configuration__c = prodConfig.id;
        rsItem.Revenue_Schedule__c = rs.id;
        insert rsItem;
        
        set<id> pcids = new set<id>();
        pcids.add(prodConfig.id);
        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(salesOrder,acc);      
        insert testFulfilment;
        
        Test.startTest();
        CS_utl_ProductConfiguration.getRevenueScheduleItems(pcids);
        system.assertequals(CS_utl_ProductConfiguration.getRevenueScheduleItems(pcids).size(),1);
        Test.stopTest();
    }
   
}
/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description : Test Class for CS_utl_Schedule
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author     : Kalyan Erraguntla <kalyan.erraguntla@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

@isTest
public class CS_utl_ScheduleTest {
    /** 
     * Checks if Schedule can be deleted
     */	
	@isTest
    public static void test_isDeletable() {
    	
    	CS_Billing_Schedule_Item__c bSchedule = new CS_Billing_Schedule_Item__c();
        CS_utl_Schedule utlSchedule = new CS_utl_Schedule();
        
        Test.startTest();
        system.assertequals(CS_utl_Schedule.isDeletable(bSchedule),false);
        Test.stopTest();
    }
    
     /** 
     * Create a Sales Order Schedule
     */	
	@isTest
    public static void test_createSalesOrderSchedule() {
    	
    	CS_Billing_Schedule_Item__c bSchedule = new CS_Billing_Schedule_Item__c();
        CS_utl_Schedule utlSchedule = new CS_utl_Schedule();
       
		Account acc = TestDataSetupTargetables.createAccount();
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c salesOrder = TestDataSetupTargetables.createSalesOrder(acc, opp);
        salesOrder.csmso__Opportunity__c = opp.id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'Booked';
        salesOrder.Applicable_IO_Volume_Discount_Range__c =1;
    	salesOrder.Primary_Sales_Order__c = true;
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Advertiser_Final__c = acc.Id;
        insert salesOrder;
        
        Test.startTest();
        system.assertequals(CS_utl_Schedule.createSalesOrderSchedule(salesOrder.id).Sales_Order__c,salesOrder.id);
        Test.stopTest();
    }
        
     /** 
     * Create a Billing and Revenue Schedule
     */	
	@isTest
    public static void test_createSchedule() {

    	CS_Billing_Schedule_Item__c bSchedule = new CS_Billing_Schedule_Item__c();
        CS_utl_Schedule utlSchedule = new CS_utl_Schedule();
       
		Account acc = TestDataSetupTargetables.createAccount();
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c salesOrder = TestDataSetupTargetables.createSalesOrder(acc, opp);
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
        
        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.sales_order__c = salesOrder.id;
        insert salesOrderSchedule;
        
        Test.startTest();
        CS_Billing_Schedule__c bs = CS_utl_Schedule.createBillingSchedule(salesOrder.id,salesOrderSchedule,prodConfig);
        CS_Revenue_Schedule__c rs = CS_utl_Schedule.createRevenueSchedule(salesOrder.id,salesOrderSchedule,prodConfig);
        
        system.assertequals(bs.Sales_Order__c,salesOrder.id);
        system.assertequals(bs.CS_Sales_Order_Schedule__r.id,salesOrderSchedule.id);
        system.assertequals(bs.Product_Configuration__c,prodConfig.Id);
        system.assertequals(rs.CS_Sales_Order_Schedule__r.id,salesOrderSchedule.id);
        system.assertequals(rs.Product_Configuration__c,prodConfig.Id);
        system.assertequals(rs.Sales_Order__c,salesOrder.id);
        system.assertequals(CS_utl_Schedule.billRuns.size(),0);
        Test.stopTest();
    }
   
}
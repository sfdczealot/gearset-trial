/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description : Test Class for CS_BillingSchedule
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author     : Kalyan Erraguntla <kalyan.erraguntla@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
public class CS_BillingScheduleTest {
    /**
     *  schedule mapping
     */	
	@isTest
    public static void test_getScheduleMapping() {
    	CS_Billing_Schedule_Item__c bSchedule = new CS_Billing_Schedule_Item__c();
    	
        Test.startTest();
        
        CS_BillingSchedule bs = new CS_BillingSchedule();
        system.assertequals( bs.getScheduleMapping().get('scheduledQuantity'),'Scheduled_Quantity__c');
        system.assertequals( bs.getScheduleMapping().get('flightBegin'),'Flight_Begin__c');
        system.assertequals( bs.getScheduleMapping().get('flightEnd'),'Flight_End__c');
        system.assertequals( bs.getScheduleMapping().get('productConfigId'),'Product_Configuration__c');
        
        Test.stopTest();
    }
    
    
    /**
     * start date for schedule
     */	
	@isTest
    public static void test_getScheduleStartDate() {
    	CS_Billing_Schedule_Item__c bSchedule = new CS_Billing_Schedule_Item__c();
    	
        Test.startTest();
        
        CS_BillingSchedule bs = new CS_BillingSchedule();
        system.assertequals( bs.getScheduleStartDate(bSchedule),null);
        Test.stopTest();
    }
    
    /**
     *  end date for schedule
     */	
	@isTest
    public static void test_getScheduleEndDate() {
    	CS_Billing_Schedule_Item__c bSchedule = new CS_Billing_Schedule_Item__c();
        
        Test.startTest();
        
        CS_BillingSchedule bs = new CS_BillingSchedule();
        system.assertequals( bs.getScheduleEndDate(bSchedule),null);
        
        Test.stopTest();
    }
    
}
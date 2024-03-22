/**
 * @name CS_utl_BroadcastCalendarTest
 * @description Test for CS_utl_BroadcastCalendar class
 * @revision
 *
 */
@isTest
public class CS_utl_BroadcastCalendarTest {
    /**
     * Tests isApplicable for Broadcast calendar outside of range
     */
	@isTest
    public static void test_isApplicableOutsideRange() {
    	Date startDate = Date.today().toStartOfMonth().addMonths(5);
    	Date endDate = Date.today().toStartOfMonth().addMonths(6);
    	Broadcast_Calendar__c bCalendar = CS_th_BroadcastCalendar.create(Date.today().toStartOfMonth().addDays(10), Date.today().toStartOfMonth().addDays(25), false);
    	
    	Test.startTest();
    	
    	System.assert(!CS_utl_BroadcastCalendar.isApplicable(bCalendar, startDate, endDate));
    	
    	Test.stopTest();
    }
    
    /**
     * Tests isApplicable for Broadcast calendar in rage
     */
	@isTest
    public static void test_isApplicableInRange() {
    	Date startDate = Date.today().toStartOfMonth().addDays(5);
    	Date endDate = Date.today().toStartOfMonth().addDays(20);
    	Broadcast_Calendar__c bCalendar = CS_th_BroadcastCalendar.create(Date.today().toStartOfMonth().addDays(10), Date.today().toStartOfMonth().addDays(25), false);
    	
    	Test.startTest();
    	
    	System.assert(CS_utl_BroadcastCalendar.isApplicable(bCalendar, startDate, endDate));
    	
    	Test.stopTest();
    }
}
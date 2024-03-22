/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description :  Broadcast Date Strategy class test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        Sasa Marjancic   <sasa.marjancic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
public class CS_BroadcastDateStrategyTest {
    /**
     * Get period for 1 month, no calendar
     */
	@isTest
    public static void test_getPeriods1MonthNoCalendar() {
    	Date startDate = Date.today().toStartOfMonth().addDays(5);
    	Date endDate = Date.today().toStartOfMonth().addDays(20);
    	CS_utl_BroadcastCalendar.init(startDate, endDate);
    	
    	CS_BroadcastDateStrategy strategy = (CS_BroadcastDateStrategy) CS_DateStrategyBase.instantiate('CS_BroadcastDateStrategy', startDate, endDate);
    	
    	Test.startTest();
    	Boolean exceptionThrown = false;
    	
    	try {
    		List<CS_DateStrategyBase.Period> periods = strategy.periods;
    	}
    	catch (CS_DateStrategyBase.DateStrategyException e) {
    		exceptionThrown = true;
    	}
    	
    	System.assert(exceptionThrown);
    	
    	Test.stopTest();
    }
    
    /**
     * Get period for 1 month
     */
	@isTest
    public static void test_getPeriods1Month() {
    	Date startDate = Date.today().toStartOfMonth().addDays(5);
    	Date endDate = Date.today().toStartOfMonth().addDays(20);
    	CS_utl_BroadcastCalendar.init(startDate, endDate);
    	List<Broadcast_Calendar__c> bCalendars = new List<Broadcast_Calendar__c> {
    		CS_th_BroadcastCalendar.create(Date.today().toStartOfMonth().addDays(10), Date.today().toStartOfMonth().addDays(25), false)
    	};
    	insert bCalendars;
    	
    	CS_BroadcastDateStrategy strategy = (CS_BroadcastDateStrategy) CS_DateStrategyBase.instantiate('CS_BroadcastDateStrategy', startDate, endDate);
    	
    	Test.startTest();
    	List<CS_DateStrategyBase.Period> periods = strategy.periods;
    	
    	System.assertEquals(1, periods.size());
    	System.assertEquals(startDate, periods.get(0).startDate);
    	System.assertEquals(endDate, periods.get(0).endDate);
    	System.assertEquals(bCalendars.get(0).End_Date__c, periods.get(0).periodDate);
    	System.assertEquals(startDate.daysBetween(endDate) + 1, periods.get(0).amount);
    	
    	Test.stopTest();
    }
    
    /**
     * Get period for 1 month, 2 lines
     */
	@isTest
    public static void test_getPeriods1Month2Lines() {
    	Date startDate = Date.today().toStartOfMonth().addDays(5);
    	Date endDate = Date.today().toStartOfMonth().addDays(20);
    	CS_utl_BroadcastCalendar.init(startDate, endDate);
    	List<Broadcast_Calendar__c> bCalendars = new List<Broadcast_Calendar__c> {
    		CS_th_BroadcastCalendar.create(Date.today().toStartOfMonth().addDays(10), Date.today().toStartOfMonth().addDays(25), false)
    	};
    	insert bCalendars;
    	
    	Test.startTest();
    	
    	CS_BroadcastDateStrategy strategy = (CS_BroadcastDateStrategy) CS_DateStrategyBase.instantiate('CS_BroadcastDateStrategy', startDate, endDate);
    	
    	List<CS_DateStrategyBase.Period> periods = strategy.periods;
    	
    	System.assertEquals(1, periods.size());
    	System.assertEquals(startDate, periods.get(0).startDate);
    	System.assertEquals(endDate, periods.get(0).endDate);
    	System.assertEquals(bCalendars.get(0).End_Date__c, periods.get(0).periodDate);
    	System.assertEquals(startDate.daysBetween(endDate) + 1, periods.get(0).amount);
    	
    	strategy = (CS_BroadcastDateStrategy) CS_DateStrategyBase.instantiate('CS_BroadcastDateStrategy', startDate, endDate);
    	periods = strategy.periods;
    	
    	System.assertEquals(1, periods.size());
    	System.assertEquals(startDate, periods.get(0).startDate);
    	System.assertEquals(endDate, periods.get(0).endDate);
    	System.assertEquals(bCalendars.get(0).End_Date__c, periods.get(0).periodDate);
    	System.assertEquals(startDate.daysBetween(endDate) + 1, periods.get(0).amount);
    	
    	Test.stopTest();
    }
    
    /**
     * Get period for 2 months
     */
	@isTest
    public static void test_getPeriods2Months() {
    	Date startDate = Date.today().toStartOfMonth().addDays(5);
    	Date endDate = Date.today().toStartOfMonth().addDays(45);
    	CS_utl_BroadcastCalendar.init(startDate, endDate);
    	List<Broadcast_Calendar__c> bCalendars = new List<Broadcast_Calendar__c> {
    		CS_th_BroadcastCalendar.create(Date.today().toStartOfMonth().addDays(10), Date.today().toStartOfMonth().addDays(25), false)
    	};
    	insert bCalendars;
    	
    	CS_BroadcastDateStrategy strategy = (CS_BroadcastDateStrategy) CS_DateStrategyBase.instantiate('CS_BroadcastDateStrategy', startDate, endDate);
    	
    	Test.startTest();
    	List<CS_DateStrategyBase.Period> periods = strategy.periods;
    	
    	System.assertEquals(1, periods.size());
    	System.assertEquals(startDate, periods.get(0).startDate);
    	System.assertEquals(endDate, periods.get(0).endDate);
    	System.assertEquals(bCalendars.get(0).End_Date__c, periods.get(0).periodDate);
    	System.assertEquals(startDate.daysBetween(endDate) + 1, periods.get(0).amount);
    	
    	Test.stopTest();
    }

    /**
     * Get period for 2 months and 2 broadcast calendars
     */
	@isTest
    public static void test_getPeriods2Months2Calendars() {
    	Date startDate = Date.today().toStartOfMonth().addDays(5);
    	Date endDate = Date.today().toStartOfMonth().addDays(45);
    	CS_utl_BroadcastCalendar.init(startDate, endDate);
    	List<Broadcast_Calendar__c> bCalendars = new List<Broadcast_Calendar__c> {
    		CS_th_BroadcastCalendar.create(Date.today().toStartOfMonth().addDays(10), Date.today().toStartOfMonth().addDays(25), false),
    		CS_th_BroadcastCalendar.create(Date.today().toStartOfMonth().addMonths(1).addDays(10), Date.today().toStartOfMonth().addMonths(1).addDays(25), false)
    	};
    	insert bCalendars;
    	
    	CS_BroadcastDateStrategy strategy = (CS_BroadcastDateStrategy) CS_DateStrategyBase.instantiate('CS_BroadcastDateStrategy', startDate, endDate);
    	
    	Test.startTest();
    	List<CS_DateStrategyBase.Period> periods = strategy.periods;
    	
    	System.assertEquals(2, periods.size());
    	System.assertEquals(startDate, periods.get(0).startDate);
    	System.assertEquals(bCalendars.get(0).End_Date__c, periods.get(0).endDate);
    	System.assertEquals(bCalendars.get(0).End_Date__c, periods.get(0).periodDate);
    	System.assertEquals(startDate.daysBetween(bCalendars.get(0).End_Date__c) + 1, periods.get(0).amount);
    	
    	System.assertEquals(bCalendars.get(1).Start_Date__c, periods.get(1).startDate);
    	System.assertEquals(endDate, periods.get(1).endDate);
    	System.assertEquals(bCalendars.get(1).End_Date__c, periods.get(1).periodDate);
    	System.assertEquals(bCalendars.get(1).Start_Date__c.daysBetween(endDate) + 1, periods.get(1).amount);
    	
    	Test.stopTest();
    }
}
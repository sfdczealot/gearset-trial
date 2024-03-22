/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description :  Standard Date Strategy class test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        Sasa Marjancic   <sasa.marjancic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
public class CS_StandardDateStrategyTest {
    /**
     * Get period for 1 month
     */
	@isTest
    public static void test_getPeriods1Month() {
    	Date startDate = Date.today().toStartOfMonth().addDays(5);
    	Date endDate = Date.today().toStartOfMonth().addDays(20);
    	Date periodDate = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
    	
    	CS_StandardDateStrategy strategy = (CS_StandardDateStrategy) CS_DateStrategyBase.instantiate('CS_StandardDateStrategy', startDate, endDate);
    	
    	Test.startTest();
    	List<CS_DateStrategyBase.Period> periods = strategy.periods;
    	
    	System.assertEquals(1, periods.size());
    	System.assertEquals(startDate, periods.get(0).startDate);
    	System.assertEquals(endDate, periods.get(0).endDate);
    	System.assertEquals(periodDate, periods.get(0).periodDate);
    	System.assertEquals(16, periods.get(0).amount);
    	
    	System.assertEquals(periods.get(0).amount, strategy.amount);
    	
    	Test.stopTest();
    }
    
    /**
     * Get period for 2 months
     */
	@isTest
    public static void test_getPeriods2Month() {
    	Date startDate = Date.today().toStartOfMonth().addDays(5);
    	Date endDate = Date.today().toStartOfMonth().addDays(45);
    	
    	CS_StandardDateStrategy strategy = (CS_StandardDateStrategy) CS_DateStrategyBase.instantiate('CS_StandardDateStrategy', startDate, endDate);
    	
    	Test.startTest();
    	List<CS_DateStrategyBase.Period> periods = strategy.periods;
    	
    	System.assertEquals(2, periods.size());
    	System.assertEquals(startDate, periods.get(0).startDate);
    	System.assertEquals(startDate.addMonths(1).toStartOfMonth().addDays(-1), periods.get(0).endDate);
    	System.assertEquals(startDate.addMonths(1).toStartOfMonth().addDays(-1), periods.get(0).periodDate);
    	System.assertEquals(startDate.daysBetween(periods.get(0).endDate) + 1, periods.get(0).amount);
    	
    	System.assertEquals(startDate.addMonths(1).toStartOfMonth(), periods.get(1).startDate);
    	System.assertEquals(endDate, periods.get(1).endDate);
    	System.assertEquals(startDate.addMonths(2).toStartOfMonth().addDays(-1), periods.get(1).periodDate);
    	System.assertEquals(periods.get(1).startDate.daysBetween(endDate) + 1, periods.get(1).amount);
    	
    	System.assertEquals(periods.get(0).amount + periods.get(1).amount, strategy.amount);
    	
    	Test.stopTest();
    }
    
    /**
     * Get period for 12 months
     */
	@isTest
    public static void test_getPeriods12Month() {
    	Date startDate = Date.today().toStartOfMonth().addDays(5);
    	Date endDate = Date.today().toStartOfMonth().addDays(340);
    	
    	CS_StandardDateStrategy strategy = (CS_StandardDateStrategy) CS_DateStrategyBase.instantiate('CS_StandardDateStrategy', startDate, endDate);
    	
    	Test.startTest();
    	List<CS_DateStrategyBase.Period> periods = strategy.periods;
    	
    	System.assertEquals(12, periods.size());
    	System.assertEquals(startDate, periods.get(0).startDate);
    	System.assertEquals(startDate.addMonths(1).toStartOfMonth().addDays(-1), periods.get(0).endDate);
    	System.assertEquals(startDate.addMonths(1).toStartOfMonth().addDays(-1), periods.get(0).periodDate);
    	System.assertEquals(startDate.daysBetween(periods.get(0).endDate) + 1, periods.get(0).amount);
    	
    	for(Integer i = 1 ; i < 11; i++) {
			System.assertEquals(startDate.addMonths(i).toStartOfMonth(), periods.get(i).startDate);
	    	System.assertEquals(startDate.addMonths(i + 1).toStartOfMonth().addDays(-1), periods.get(i).endDate);
	    	System.assertEquals(startDate.addMonths(i + 1).toStartOfMonth().addDays(-1), periods.get(i).periodDate);
	    	System.assertEquals(periods.get(i).startDate.daysBetween(periods.get(i).endDate) + 1, periods.get(i).amount);
    	}
    	
    	System.assertEquals(startDate.addMonths(11).toStartOfMonth(), periods.get(11).startDate);
    	System.assertEquals(endDate, periods.get(11).endDate);
    	System.assertEquals(startDate.addMonths(12).toStartOfMonth().addDays(-1), periods.get(11).periodDate);
    	System.assertEquals(periods.get(11).startDate.daysBetween(endDate) + 1, periods.get(11).amount);
    	
    	Test.stopTest();
    }
}
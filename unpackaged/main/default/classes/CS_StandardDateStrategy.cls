/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description :  Standard Date Strategy class
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        Sasa Marjancic   <sasa.marjancic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class CS_StandardDateStrategy extends CS_DateStrategyBase {
    /**
     * Returns a list of periods based on start and end date
     * @return          List<Period>
     */
	public override List<Period> getPeriods() {
		List<CS_DateStrategyBase.Period> periods = new List<CS_DateStrategyBase.Period>();
		Integer itemCount = startDate.monthsBetween(endDate) + 1;
		
		if (itemCount == 1) {
			periods.add(new CS_DateStrategyBase.Period(startDate, endDate, getLastDayOfMonth(endDate), true));
		}
		else {
			periods.add(new CS_DateStrategyBase.Period(startDate, getLastDayOfMonth(startDate), getLastDayOfMonth(startDate), false));
            for(Integer i = 1; i < itemCount - 1; i++) {
            	periods.add(new CS_DateStrategyBase.Period(startDate.addMonths(i).toStartOfMonth(), 
                                                           getLastDayOfMonth(startDate.addMonths(i)),
            											   getLastDayOfMonth(startDate.addMonths(i)), 
                                                           false));
            }
            periods.add(new CS_DateStrategyBase.Period(endDate.toStartOfMonth(), endDate, getLastDayOfMonth(endDate), true));
		}
		
		return periods;
	}
}
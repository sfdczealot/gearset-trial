/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description :  Date Strategy base class
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        Sasa Marjancic   <sasa.marjancic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public abstract class CS_DateStrategyBase {
	public static CS_DateStrategyBase instantiate(String className, Date startDate, Date endDate) {
		Type t = Type.forName(className);
		CS_DateStrategyBase instance = (CS_DateStrategyBase) t.newInstance();
		instance.init(startDate, endDate);

        return instance;
	}

	/**
	 * List of calculated periods based on strategy
	 */
	public List<Period> periods {
		get {
			if(periods == null) {
				periods = getPeriods();
			}

			return periods;
		}
		set;
	}

	/**
	 * Total amount for all periods
	 */
	public Integer amount {
		get {
			if(amount == null) {
				amount = getAmount();
			}

			return amount;
		}
		set;
	}

	/**
	 * Start Date for strategy
	 */
	public Date startDate {get; set;}

	/**
	 * End Date for strategy
	 */
	public Date endDate {get; set;}

    /**
     * Initializes strategy class
     * @param startDate Date
     * @param endDate   Date
     */
	public void init(Date startDate, Date endDate) {
		this.startDate = startDate;
		this.endDate = endDate;
	}

    /**
     * Returns last day of the month
     * @param inputDate Date
     * @return 			Date
     */
    @TestVisible
	protected Date getLastDayOfMonth(Date inputDate) {
		return inputDate.addMonths(1).toStartOfMonth().addDays(-1);
    }

    /**
     * Returns a list of periods based on start and end date
     * @param startDate Date
     * @param endDate   Date
     * @return          List<Period>
     */
    @TestVisible
	protected abstract List<Period> getPeriods();

	@TestVisible
	protected virtual Integer getAmount() {
		Integer amount = 0;
		for(Period period : periods) {
			amount += period.amount;
		}

		return amount;
	}

	/**
	 * Class used to define periods
	 */
    public class Period {
        public Date startDate {get; set;}
        public Date endDate {get; set;}
        public Date periodDate {get; set;}
        public Integer amount {get; set;}
        public Boolean isLastPeriod {get; set;}

        public Period(Date startDate, Date endDate, Date periodDate, Boolean isLastPeriod) {
            this.startDate = startDate;
            this.endDate = endDate;
            this.periodDate = periodDate;
            this.isLastPeriod = isLastPeriod;
            this.amount = startDate.daysBetween(endDate) + 1;
        }
    }

    public class DateStrategyException extends Exception {}
}
/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description :  Broadcast Date Strategy class
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        Sasa Marjancic   <sasa.marjancic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class CS_BroadcastDateStrategy extends CS_DateStrategyBase {
    /**
     * Returns a list of periods based on start and end date
     * @return          List<Period>
     */
	public override List<Period> getPeriods() {
		List<CS_DateStrategyBase.Period> periods = new List<CS_DateStrategyBase.Period>();
		List<Broadcast_Calendar__c> broadcastCalendars = new List<Broadcast_Calendar__c>();
		for(Broadcast_Calendar__c bc : CS_utl_BroadcastCalendar.getBroadcastCalendars(startDate, endDate)) {
			broadcastCalendars.add(bc.clone());
		} 
		
		if(!broadcastCalendars.isEmpty()) {
			Date periodDate = broadcastCalendars.get(broadcastCalendars.size() - 1).End_Date__c;
			broadcastCalendars.get(0).Start_Date__c = startDate;
			broadcastCalendars.get(broadcastCalendars.size() - 1).End_Date__c = endDate;
			
	        for(Broadcast_Calendar__c bCalendar : broadcastCalendars) {
	        	CS_DateStrategyBase.Period period = new CS_DateStrategyBase.Period(bCalendar.Start_Date__c, bCalendar.End_Date__c, bCalendar.End_Date__c, false);
	        	if(bCalendar.End_Date__c == endDate) {
	        		period.periodDate = periodDate;
	        		period.isLastPeriod = true;
	        	}
	        	periods.add(period);   
	        }
		}
		else {
			throw new CS_DateStrategyBase.DateStrategyException('No Broadcast Calendar found for the selected period.');
		}
        
        return periods;
	}
}
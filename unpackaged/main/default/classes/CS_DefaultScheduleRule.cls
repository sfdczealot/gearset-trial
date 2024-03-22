/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description :  Default Date Strategy class
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        Sasa Marjancic   <sasa.marjancic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class CS_DefaultScheduleRule extends CS_ScheduleRuleBase {
    /**
     * Returns a list of schedule lines based on date strategy and schedule information
     * @param startDate 	  	 Date
     * @param endDate 		  	 Date
     * @param contractedQuantity Decimal
     * @param cappedQuantity  	 Decimal
     * @param bookedQuantity  	 Decimal
     * @param flightBegin 	  	 Date
     * @param flightEnd   	  	 Date
     * @param configId		  	 Id
     * @param salesOrderId	  	 Id
     * @param price 		  	 Decimal
     * @param unitPrice 	  	 Decimal
     * @param dateStrategy	  	 String
     * @return 				  	 List<ScheduleLine>
     */
	public override List<ScheduleLine> getScheduleLines(Date startDate, Date endDate, Decimal contractedQuantity, Decimal cappedQuantity,
														Decimal bookedQuantity, Date flightBegin, Date flightEnd, Id configId, Id salesOrderId, Decimal price,
														Decimal unitPrice, String dateStrategy){
		List<CS_ScheduleRuleBase.ScheduleLine> scheduleLines = new List<CS_ScheduleRuleBase.ScheduleLine>();
				
		CS_DateStrategyBase strategy = CS_DateStrategyBase.instantiate(dateStrategy, startDate, endDate);
        Integer scheduleForecastQuantityTotalUpToLastPeriod = 0;
        Integer bookedQuantityTotalUpToLastPeriod = 0;
		for(CS_DateStrategyBase.Period period : strategy.periods) {
            Integer periodScheduleForecastQuantity = strategy.amount > 0 ? Integer.valueOf(Math.floor((period.amount * cappedQuantity) / strategy.amount)) 
                                                                         : 0;
            Integer periodBookedQuantity = strategy.amount > 0 ? Integer.valueOf(Math.floor((period.amount * bookedQuantity) / strategy.amount)) 
                                                               : 0;
            if (period.isLastPeriod) {
                periodScheduleForecastQuantity = Integer.valueOf(Math.floor(cappedQuantity)) - scheduleForecastQuantityTotalUpToLastPeriod;
                periodBookedQuantity = Integer.valueOf(Math.floor(bookedQuantity)) - bookedQuantityTotalUpToLastPeriod;
            }
            else {
                scheduleForecastQuantityTotalUpToLastPeriod += periodScheduleForecastQuantity;
                bookedQuantityTotalUpToLastPeriod += periodBookedQuantity;
            }

			ScheduleLine scheduleLine = new ScheduleLine(period.periodDate,
				                                         period.startDate,
				                                         period.endDate,
				                                         Integer.valueOf(contractedQuantity),
				                                         periodScheduleForecastQuantity,
				                                         periodScheduleForecastQuantity,
				                                         periodBookedQuantity,
				                                         flightBegin,
				                                         flightEnd,
				                                         configId,
				                                         salesOrderId,
				                                         price,
				                                         unitPrice,
				                                         0);
			scheduleLines.add(scheduleLine);
		}
		
		return scheduleLines;
    }
    
    /**
     * Sets Schedule object records based on ScheduleLine and SObject
     * @param line 				ScheduleLine
     * @param sObj 				SObject
     * @param schedulineLineMap Map<String, String> 
     * @return             
     */
	public override SObject setSObject(ScheduleLine line, SObject sObj, Map<String, String> schedulineLineMap) {
		Map<String, Object> untypedInstance = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(line));
		for(String objectProperty : schedulineLineMap.keySet()) {
			sObj.put(schedulineLineMap.get(objectProperty),
					 CS_utl_Sobject.getObjectValue(untypedInstance.get(objectProperty),
					 CS_utl_Sobject.getFieldType(sObj.getSObjectType(), schedulineLineMap.get(objectProperty))));
		}
		
		return sObj;		
	}
}
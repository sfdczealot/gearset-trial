/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description :  Class used to handle Billing Schedule operations
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        Sasa Marjancic   <sasa.marjancic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class CS_BillingSchedule extends CS_ScheduleBase {
	/**
	 * Returns start date for schedule
	 * @param  obj SObject
	 * @return 	   Date
	 */ 
	public override Date getScheduleStartDate(SObject obj) {
		return (Date) obj.get('Billing_Period_Start_Date__c');
	}
	
	/**
	 * Returns end date for schedule
	 * @param  obj SObject
	 * @return 	   Date
	 */ 
	public override Date getScheduleEndDate(SObject obj) {
		return (Date) obj.get('Billing_Period_End_Date__c');
	}

	/**
	 * Returns start date for schedule
	 * @param  obj SObject
	 * @return 	   Date
	 */ 	
	public override Billing_Schedule_Rule__c getScheduleRule(SObject obj) {
		return (Billing_Schedule_Rule__c) obj.getSObject('Billing_Schedule_Rule__r');
	}
	
	/**
	 * Returns a schedule mapping
	 * @return Map<String, String>
	 */
	public override Map<String, String> getScheduleMapping() {
		return new Map<String, String> {
			'scheduleDate' => 'Billing_Date__c',
			'startDate' => 'Billing_Period_Start_Date__c',
			'endDate' => 'Billing_Period_End_Date__c',
			'contractedQuantity' => 'Contracted_Quantity__c',
			'scheduledQuantity' => 'Scheduled_Quantity__c',
			'forecastQuantity' => 'Forecast_Quantity__c',
			'bookedQuantity' => 'Booked_Quantity__c',
			'flightBegin' => 'Flight_Begin__c',
			'flightEnd' => 'Flight_End__c',
			'productConfigId' => 'Product_Configuration__c',
			'salesOrderId' => 'Sales_Order__c',
			'totalPrice' => 'Total_Price__c',
			'unitPrice' => 'Net_Rate__c',
			'amount' => 'Billing_Amount__c'
		};
	}
}
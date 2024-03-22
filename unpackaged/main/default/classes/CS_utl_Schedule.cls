/**
 * @name CS_utl_Schedule
 * @description Utility class for Schedules
 * @revision
 *
 */
public class CS_utl_Schedule {
	/**
	 * Property to get and cache Active Bill Runs
	 */
	@TestVisible
	public static List<Bill_Run__c> billRuns {
		get {
			if(billRuns == null) {
				billRuns = [SELECT Id, Name, Billing_Date__c, Calendar_Type__c, Status__c, RecordType.Name, SObject_Type__c
							FROM Bill_Run__c
							WHERE Lock_Billing_Date__c >= TODAY AND Billing_Date__c <= TODAY];
			}
			
			return billRuns;
		}
		set;
	}

	public static Boolean isApplicable(Bill_Run__c billRun, String scheduleObject, cscfga__Product_Configuration__c config) {
		return billRun.SObject_Type__c == scheduleObject &&
			(billRun.SObject_Type__c == 'CS_Revenue_Schedule_Item__c' ||
			(billRun.SObject_Type__c == 'CS_Billing_Schedule_Item__c' && billRun.Calendar_Type__c == config.Sales_Order__r.Billing_Calendar__c));
	}
	
	/**
	 * Checks if Schedule can be deleted
	 * @param schedule SObject
	 * @return    	   Boolean
	 */
	@TestVisible
	public static Boolean isDeletable(SObject schedule) {
		Map<String, Object> fieldValues = schedule.getPopulatedFieldsAsMap();
		return String.isNotBlank(schedule.Id) 
               && (fieldValues.get('Is_Closed__c') == null 
                   || !((Boolean) fieldValues.get('Is_Closed__c')))
               && fieldValues.get('Status__c') != CS_const_SalesOrder.ScheduleStatus_Cancelled;
	}
	
	/**
	 * Checks if Schedule is billed
	 * @param schedule SObject
	 * @return    	   Boolean
	 */
	@TestVisible
	public static Boolean isBilled(SObject schedule) {
		Map<String, Object> fieldValues = schedule.getPopulatedFieldsAsMap();
		return String.isNotBlank(schedule.Id) && (fieldValues.get('Status__c') == CS_const_SalesOrder.ScheduleStatus_PendingClosure ||
				fieldValues.get('Status__c') == CS_const_SalesOrder.ScheduleStatus_Closed);
	}
	
	public static Boolean isAutoReconciled(SObject schedule) {
		Map<String, Object> fieldValues = schedule.getPopulatedFieldsAsMap();
		return isBilled(schedule) || fieldValues.get('Status__c') == CS_const_SalesOrder.ScheduleStatus_Ready || fieldValues.get('Status__c') == CS_const_SalesOrder.ScheduleStatus_Pending;
	}
	
	/**
	 * Create a Sales Order Schedule
	 * @param salesOrderId Id
	 * @return    		   CS_Sales_Order_Schedule__c
	 */
	@TestVisible
	public static CS_Sales_Order_Schedule__c createSalesOrderSchedule(Id salesOrderId) {
		return new CS_Sales_Order_Schedule__c(Sales_Order__c = salesOrderId);
	}
	
	/**
	 * Create a Billing Schedule
	 * @param salesOrderId 		   Id
	 * @param salesOrderSchedule   CS_Sales_Order_Schedule__c
	 * @param productConfiguration cscfga__Product_Configuration__c
	 * @return    		 		   CS_Billing_Schedule__c
	 */
	@TestVisible
	public static CS_Billing_Schedule__c createBillingSchedule(Id salesOrderId, CS_Sales_Order_Schedule__c salesOrderSchedule, cscfga__Product_Configuration__c productConfiguration) {
		return new CS_Billing_Schedule__c(Sales_Order__c = salesOrderId,
										  CS_Sales_Order_Schedule__c = salesOrderSchedule.Id,
										  CS_Sales_Order_Schedule__r = salesOrderSchedule,
										  Product_Configuration__c = productConfiguration.Id,
										  Product_Configuration__r = productConfiguration);
	}
	
	/**
	 * Create a Revenue Schedule
	 * @param salesOrderId 		   Id
	 * @param salesOrderSchedule   CS_Sales_Order_Schedule__c
	 * @param productConfiguration cscfga__Product_Configuration__c
	 * @return    		 		   CS_Revenue_Schedule__c
	 */
	@TestVisible
	public static CS_Revenue_Schedule__c createRevenueSchedule(Id salesOrderId, CS_Sales_Order_Schedule__c salesOrderSchedule, cscfga__Product_Configuration__c productConfiguration) {
		return new CS_Revenue_Schedule__c(Sales_Order__c = salesOrderId,
										  CS_Sales_Order_Schedule__c = salesOrderSchedule.Id,
										  CS_Sales_Order_Schedule__r = salesOrderSchedule,
										  Product_Configuration__c = productConfiguration.Id,
										  Product_Configuration__r = productConfiguration);
	}
}
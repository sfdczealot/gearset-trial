/**
 * @name CS_utl_ProductConfiguration
 * @description Utility methods for Product Configuration
 * @revision
 *
 */
public class CS_utl_ProductConfiguration {
	public static Boolean isReserved(cscfga__Product_Configuration__c config) {
		return isReserved(config.Reservation_Status__c);
	}

	public static Boolean isReserved(String reservationStatus){
		return String.isNotBlank(reservationStatus)
				&& (reservationStatus.equalsIgnoreCase(CS_Constants.RESERVATION_STATUS_RESERVED)
				|| reservationStatus.equalsIgnoreCase(CS_Constants.RESERVATION_STATUS_CHECK_LINE_ITEM_RESERVATION_STATUS));
	}

	/**
     * Checks if Product Configuration requires billing schedule
     * @param config cscfga__Product_Configuration__c
     * @param parent CS_Billing_Schedule__c
     * @return       Boolean
     */
	public static Boolean isBillingScheduleRequired(cscfga__Product_Configuration__c config, CS_Billing_Schedule__c parent) {
		return config.Billing_Schedule_Rule__c != null && !config.Do_Not_Create_Billing__c &&
				!CS_utl_SalesOrder.isInProgress(config.Sales_Order__r) &&
				config.Sales_Order__r.csmso__Status__c != CS_const_SalesOrder.Status_Killed &&
				(parent == null || parent.Under_IFC__c || CS_utl_SalesOrder.hasHeaderChanged(config.Sales_Order__r)) && !config.Sales_Order__r.Is_Programmatic__c;
	}

	/**
     * Checks if Product Configuration requires revenue schedule
     * @param config cscfga__Product_Configuration__c
     * @param parent CS_Revenue_Schedule__c
     * @return       Boolean
     */
	public static Boolean isRevenueScheduleRequired(cscfga__Product_Configuration__c config, CS_Revenue_Schedule__c parent) {
		return config.Revenue_Schedule_Rule__c != null && !config.Do_Not_Create_Rev_Rec__c &&
				config.Sales_Order__r.csmso__Status__c != CS_const_SalesOrder.Status_Killed &&
				(!CS_utl_SalesOrder.isInProgress(config.Sales_Order__r) ||
						(CS_utl_SalesOrder.isInProgress(config.Sales_Order__r) && config.Sales_Order__r.Primary_Sales_Order__c &&
								!CS_utl_SalesOrder.isRetracted(config.Sales_Order__r))) &&
				(parent == null || parent.Under_IFC__c || CS_utl_SalesOrder.hasHeaderChanged(config.Sales_Order__r));
	}

	/**
     * Gets Billing Schedule Items based on Product Configuration Ids
     * @param productConfigurationIds Set<Id>
     * @return           			  Map<Id, List<CS_Billing_Schedule_Item__c>>
     */
	public static Map<Id, List<CS_Billing_Schedule_Item__c>> getBillingScheduleItems(Set<Id> productConfigurationIds) {
		Map<Id, List<CS_Billing_Schedule_Item__c>> billingScheduleItemsByConfig = new Map<Id, List<CS_Billing_Schedule_Item__c>>();
		String queryString = CS_utl_Soql.buildQuery(Schema.CS_Billing_Schedule_Item__c.getSObjectType(),
				new Map<String, Set<Id>>{'Product_Configuration__c' => productConfigurationIds},
				CS_utl_Array.join(new List<String> { CS_utl_SObject.getFieldList(CS_Billing_Schedule__c.getSobjectType(),
						'Billing_Schedule__r.') },
						','),
				null,
				null,
				'Status__c != \'' + CS_const_SalesOrder.ScheduleStatus_Cancelled + '\'');

		for(CS_Billing_Schedule_Item__c billingScheduleItem : (List<CS_Billing_Schedule_Item__c>) Database.Query(queryString)) {
			if(!billingScheduleItemsByConfig.containsKey(billingScheduleItem.Product_Configuration__c)) {
				billingScheduleItemsByConfig.put(billingScheduleItem.Product_Configuration__c, new List<CS_Billing_Schedule_Item__c>());
			}

			billingScheduleItemsByConfig.get(billingScheduleItem.Product_Configuration__c).add(billingScheduleItem);
		}
		return billingScheduleItemsByConfig;
	}

	/**
     * Gets Revenue Schedule Items based on Product Configuration Ids
     * @param productConfigurationIds Set<Id>
     * @return           			  Map<Id, List<CS_Revenue_Schedule_Item__c>>
     */
	public static Map<Id, List<CS_Revenue_Schedule_Item__c>> getRevenueScheduleItems(Set<Id> productConfigurationIds) {
		Map<Id, List<CS_Revenue_Schedule_Item__c>> revenueScheduleItemsByConfig = new Map<Id, List<CS_Revenue_Schedule_Item__c>>();
		String queryString = CS_utl_Soql.buildQuery(Schema.CS_Revenue_Schedule_Item__c.getSObjectType(),
				new Map<String, Set<Id>>{'Product_Configuration__c' => productConfigurationIds},
				CS_utl_Array.join(new List<String> { CS_utl_SObject.getFieldList(CS_Revenue_Schedule__c.getSobjectType(),
						'Revenue_Schedule__r.') },
						','),
				null,
				null,
				'Status__c != \'' + CS_const_SalesOrder.ScheduleStatus_Cancelled + '\'');

		for(CS_Revenue_Schedule_Item__c revenueScheduleItem : (List<CS_Revenue_Schedule_Item__c>)Database.Query(queryString)) {
			if(!revenueScheduleItemsByConfig.containsKey(revenueScheduleItem.Product_Configuration__c)) {
				revenueScheduleItemsByConfig.put(revenueScheduleItem.Product_Configuration__c, new List<CS_Revenue_Schedule_Item__c>());
			}

			revenueScheduleItemsByConfig.get(revenueScheduleItem.Product_Configuration__c).add(revenueScheduleItem);
		}
		return revenueScheduleItemsByConfig;
	}
}
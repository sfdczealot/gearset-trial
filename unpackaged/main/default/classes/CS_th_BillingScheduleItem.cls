/**
 * @name CS_th_BillingScheduleItem
 * @description Factory class for CS_Billing_Schedule_Item__c object
 * @revision
 *
 */
@isTest
public class CS_th_BillingScheduleItem {
	/**
     * Create a Billing Schedule Item for test
     * @param  status String
     * @return        CS_Billing_Schedule_Item__c
     */
    public static CS_Billing_Schedule_Item__c create(String status) {
        return create(status, CS_const_BillingScheduleItem.BillingCalendar_Standard, Date.today());
    }

    /**
     * Create a Billing Schedule Item for test
     * @param  status 		   String
     * @param  billingCalendar String
     * @param  billingDate 	   Date
     * @return        		   CS_Billing_Schedule_Item__c
     */
    public static CS_Billing_Schedule_Item__c create(String status, String billingCalendar, Date billingDate) {
        return create(status, billingCalendar, billingDate, false, true);
    }
    
    /**
     * Create a Billing Schedule Item for test
     * @param  status 		   String
     * @param  billingCalendar String
     * @param  billingDate 	   Date
     * @param  insertRecord    Boolean
     * @return        		   CS_Billing_Schedule_Item__c
     */
    public static CS_Billing_Schedule_Item__c create(String status, String billingCalendar, Date billingDate, Boolean manualHold, Boolean insertRecord) {
        CS_Billing_Schedule_Item__c billingScheduleItem = new CS_Billing_Schedule_Item__c(Status__c = status,
								                                      Billing_Calendar__c = billingCalendar,
								                                      Billing_Date__c = billingDate, Manual_Hold__c = manualHold);
        if(insertRecord) {
            insert billingScheduleItem;
        }

        return billingScheduleItem;
    }
}
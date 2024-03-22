/**
 * @name CS_th_BillRun
 * @description Factory class for Bill_Run__c object
 * @revision
 *
 */
@isTest
public class CS_th_BillRun {
    /**
     * Create a Bill Run for test
     * @param  status String
     * @return        Bill_Run__c
     */
    public static Bill_Run__c create(String status) {
        return create(status, CS_const_BillRun.CalendarType_Standard, Date.today());
    }

    /**
     * Create a Bill Run for test
     * @param  status 		   String
     * @param  billingCalendar String
     * @param  billingDate 	   Date
     * @return        		   Bill_Run__c
     */
    public static Bill_Run__c create(String status, String calendarType, Date billingDate) {
        return create(status, calendarType, billingDate, true);
    }
    
    /**
     * Create a Bill Run for test
     * @param  status 		   String
     * @param  billingCalendar String
     * @param  billingDate 	   Date
     * @param  insertRecord    Boolean
     * @return        		   Bill_Run__c
     */
    public static Bill_Run__c create(String status, String calendarType, Date billingDate, Boolean insertRecord) {
        Bill_Run__c billRun = new Bill_Run__c(Status__c = status,
								              Calendar_Type__c = calendarType,
								              Billing_Date__c = billingDate);
        if(insertRecord) {
            insert billRun;
        }

        return billRun;
    }
}
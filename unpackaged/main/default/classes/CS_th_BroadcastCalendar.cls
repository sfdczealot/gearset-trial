/**
 * @name CS_th_BroadcastCalendar
 * @description Factory class for Broadcast_Calendar__c object
 * @revision
 *
 */
@isTest
public class CS_th_BroadcastCalendar {
    /**
     * Create a Broadcast_Calendar__c for test
     * @param  startDate Date
     * @param  endDate   Date
     * @return        	 Broadcast_Calendar__c
     */
    public static Broadcast_Calendar__c create(Date startDate, Date endDate) {
        return create(startDate, endDate, true);
    }
    
    /**
     * Create a Broadcast_Calendar__c for test
     * @param  startDate 	Date
     * @param  endDate   	Date
     * @param  insertRecord Boolean
     * @return        		Billing_Schedule__c
     */
    public static Broadcast_Calendar__c create(Date startDate, Date endDate, Boolean insertRecord) {
        Broadcast_Calendar__c bCalendar = new Broadcast_Calendar__c(Start_Date__c = startDate,
								                                    End_Date__c = endDate);
        if(insertRecord) {
            insert bCalendar;
        }

        return bCalendar;
    }
}
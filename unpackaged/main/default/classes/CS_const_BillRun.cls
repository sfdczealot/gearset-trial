/**
 * @name CS_const_BillRun
 * @description Constants for Bill_Run__c object
 */
public with sharing class CS_const_BillRun {
    /**
     * Picklist Values
     */
	public static final String Status_Scheduled = 'Scheduled';
	public static final String Status_LockingBillSchedules = 'Locking Bill Schedules';
	public static final String Status_AutoReconciliating = 'Auto-Reconciliating';
	public static final String Status_Complete = 'Complete';
	
	public static final String CalendarType_Standard = 'Standard';
	public static final String CalendarType_Broadcast = 'Broadcast';
}
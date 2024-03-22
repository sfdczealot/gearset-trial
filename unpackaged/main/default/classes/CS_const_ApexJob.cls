/**
 * @name CS_const_ApexJob
 * @description Constants for ApexJob object
 */
public with sharing class CS_const_ApexJob {
    /**
     * Picklist Values
     */
    public static final String JobType_BatchApex = 'BatchApex';
    public static final String JobType_ScheduledApex = 'ScheduledApex';
    public static final String JobType_Queueable = 'Queueable';
    
    public static final String Status_Queued = 'Queued';
    public static final String Status_Processing = 'Processing';
    public static final String Status_Preparing = 'Preparing';
    public static final String Status_Completed = 'Completed';
    public static final String Status_Failed = 'Failed';
    public static final String Status_Aborted = 'Aborted';
}
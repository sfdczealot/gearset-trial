/**
 * @name CS_th_Worker
 * @description Factory class for Worker custom settings
 * @revision
 *
 */
@isTest
public class CS_th_Worker {
    /**
     * Create a Worker custom setting
     * @return      Worker__c
     */
    public static Worker__c create() {
        return create(5, 2000, 10, null, null, null, null, true);
    }

    /**
     * Create a Worker custom setting
     * @param  batchJobsLimit   Integer
     * @param  batchSizeLimit   Integer
     * @param  batchRetryTime   Integer
     * @param  sendEmail        String
     * @param  sendEmailOnError String
     * @param  saveLog          String
     * @param  saveLogOnError   String
     * @param  insertRecord     Boolean
     * @return                  Worker__c
     */
    public static Worker__c create(Integer batchJobsLimit, Integer batchSizeLimit, Integer batchRetryTime, String sendEmail,
                                   String sendEmailOnError, String saveLog, String saveLogOnError, Boolean insertRecord) {
        Worker__c setting = new Worker__c(
            Batch_Jobs_Limit__c = batchJobsLimit,
            Batch_Size_Limit__c = batchSizeLimit,
            Batch_Retry_Time__c = batchRetryTime,
            Send_Email_On_Error__c = sendEmailOnError,
            Send_Email__c = sendEmail,
            Save_Log__c = saveLog,
            Save_Log_On_Error__c = saveLogOnError
        );
        
        if(insertRecord) {
            insert setting;
        }

        return setting;
    }
}
/**
 * @name CS_WorkerBase
 * @description Framework class for all async frameworks
 * @revision
 *
 */
public abstract class CS_WorkerBase {
    @TestVisible
    protected String processName;

    @TestVisible
    protected CS_LogWorker log;
    
    @TestVisible
    protected Boolean success;
    
    @TestVisible
    protected Worker__c settings;
    
    @TestVisible
    protected Object context;
    
    @TestVisible
    protected Boolean overrideLogging;
    
    /**
     * myDescription
     * @param paramName paramType
     * @return  returnType
     */
    public CS_WorkerBase(String processName) {
		init(processName);
    }

    /**
     * 
     * @param String processName
     */    
    protected virtual void init(String processName) {
        this.settings = Worker__c.getInstance();
        CS_LogWorker.setInstance(null);
        
        this.log = CS_LogWorker.getInstance();
        this.success = true;
        this.overrideLogging = false;
        this.processName = processName;	
    }
    
    /**
     * Saves the log to database using CS_LogWorker
     */
    @TestVisible
    protected virtual void saveLog() {
        if(!overrideLogging && (getIsActive(Worker__c.Save_Log__c) || (getIsActive(Worker__c.Save_Log_On_Error__c) && !this.success))) {
            this.log.save(this.processName, getJobType(), getJobId(), this.success, getMessage());
        }
    }

    /**
     * Sends email using CS_LogWorker
     */
    @TestVisible
    protected virtual void sendEmail() {
        if(!overrideLogging && (getIsActive(Worker__c.Send_Email__c) || (getIsActive(Worker__c.Send_Email_On_Error__c) && !this.success))) {
            log.sendEmail();
        }
    }
    
    /**
     * Checks if global setting is active
     */
    @TestVisible
    private Boolean getIsActive(Schema.SObjectField field) {
        return String.isNotBlank((String) this.settings.get(field)) && ((String) this.settings.get(field)).contains(getJobType());
    }
    
    /**
     * Stops current async job
     */
    public virtual void stopJob() {
        system.abortJob(getJobId());
    }
    
    /**
     * Get the message for log
     */
    public abstract String getMessage();
    
    /**
     * Gets the job type
     */
    public abstract String getJobType();
    
    /**
     * Gets the job id
     */
    public abstract Id getJobId();
}
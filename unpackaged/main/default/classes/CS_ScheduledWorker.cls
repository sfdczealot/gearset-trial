/**
 * @name CS_ScheduledWorker
 * @description Framework class for scheduled processes
 * @revision
 *
 */
public abstract class CS_ScheduledWorker extends CS_WorkerBase implements Schedulable {
	/**
	 * Class constructor
	 * @param processName String
	 * @return 			  CS_ScheduledWorker
	 */
	public CS_ScheduledWorker(String processName) {
		super(processName);
	}

	/**
	 * Execute method for queueable
	 * @param context SchedulableContext
	 */ 
    public void execute(SchedulableContext context) {
        try {
        	this.context = context;
            this.doWork();
        }
        catch (Exception e) {
        	log.addMessage(e);
        	this.success = false;
        }
        finally {
        	saveLog();
        	sendEmail();
        }
    }
    
	/**
	 * Get the message for log
	 */
	public virtual override String getMessage() {
		return null;
	}
	
	/**
	 * Gets the job type
	 */
	public virtual override String getJobType() {
		return CS_const_ApexJob.JobType_ScheduledApex;
	}
	
	/**
	 * Gets the job id
	 */
	public virtual override Id getJobId() {
		return ((SchedulableContext) context).getTriggerId();
	}
    
	/**
	 * Method that implements work that needs to be done
	 */
	@TestVisible
	protected abstract void doWork();
}
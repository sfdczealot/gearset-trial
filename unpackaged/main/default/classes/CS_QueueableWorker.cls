/**
 * @name CS_QueueableWorker
 * @description Framework class for queueable processes
 * @revision
 *
 */
public abstract class CS_QueueableWorker extends CS_WorkerBase implements Queueable {
    public Object params;
    
    @TestVisible
    protected CS_QueueableWorker nextWorker;
    
	/**
	 * Class constructor
	 * @param params 	  Object
	 * @param processName String
	 * @return 			  CS_QueueableWorker
	 */
	public CS_QueueableWorker(String processName, Object params) {
		super(processName);
		this.params = params;
	}
	
	/**
	 * Adds next worker to the list of execution
	 * @param next CS_QueueableWorker
	 */
    public void setNextWorker(CS_QueueableWorker next) {
        this.nextWorker = next;
    }

	/**
	 * Gets the last worker from the list of execution
	 */
	public CS_QueueableWorker getLastWorker() {
		if(this.nextWorker != null) return this.nextWorker.getLastWorker();
		return this;
	}

	/**
	 * Execute method for queueable
	 * @param context QueueableContext
	 */ 
    public void execute(QueueableContext context) {
    	this.log = CS_LogWorker.getInstance();
    	
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
        	
            if (this.nextWorker != null) {
                System.enqueueJob(this.nextWorker);
            }
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
		return CS_const_ApexJob.JobType_Queueable;
	}
	
	/**
	 * Gets the job id
	 */
	public virtual override Id getJobId() {
		return ((QueueableContext) context).getJobId();
	}
    
	/**
	 * Method that implements work that needs to be done
	 */
	@TestVisible
	protected abstract void doWork();
}
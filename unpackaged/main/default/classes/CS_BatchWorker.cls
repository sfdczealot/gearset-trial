/**
 * @name CS_BatchWorker 
 * @description Framework class for batch processes
 * @revision
 *
 */
public abstract class CS_BatchWorker extends CS_WorkerBase implements Schedulable, Database.Batchable<SObject>, Database.Stateful {
	public static Boolean isFinish = false;
	
	@TestVisible
	protected String defaultQuery = 'SELECT Id FROM AsyncApexJob WHERE Id = null';
	
    /**
     * Message format for the log
     */
    @TestVisible
    protected String message = 'Started at {0}, ended at {1}.' + 
                                'Total jobs started {2}. Total records affected {3}.';

    @TestVisible
    protected Integer batchSize;

    @TestVisible
    protected String queryString;

    @TestVisible
    protected DateTime jobStartTime;

    @TestVisible
    protected Datetime jobEndTime;

    @TestVisible
    protected Integer batchCount;
    
    @TestVisible
    protected Integer recordCount;
    
    @TestVisible
    protected Boolean delayExecution;

    /**
     * Starts batch execution
     * @return Id
     */
    public Id execute() {
        List<AsyncApexJob> apexJobs = [SELECT
                                            Id
                                       FROM
                                            AsyncApexJob
                                       WHERE
                                            JobType = :CS_const_ApexJob.JobType_BatchApex
                                       AND
                                            (Status = :CS_const_ApexJob.Status_Processing OR
                                             Status = :CS_const_ApexJob.Status_Preparing OR
                                             Status = :CS_const_ApexJob.Status_Queued)];
        if(apexJobs.size() < this.settings.Batch_Jobs_Limit__c && (!System.isBatch() || CS_BatchWorker.isFinish) &&
        	!System.isFuture() && !delayExecution) {
            return Database.executeBatch(this, batchSize);
        }
        else {
            Datetime dt = Datetime.now().addMinutes(this.settings.Batch_Retry_Time__c.intValue());
            String timeForScheduler = CS_utl_Cron.getCron(dt);
            return System.Schedule(processName + timeForScheduler, timeForScheduler, this);
        }
    }

    /**
     * Class constructor
     * @return CS_BatchWorker
     */
    public CS_BatchWorker(String processName) {
        this(processName, null);
    }
    
    /**
     * Class constructor
     * @return CS_BatchWorker
     */
    public CS_BatchWorker(String processName, Integer batchSize) {
        super(processName);
        init(processName, batchSize);
    }
    
    public virtual void init(String processName, Integer batchSize) {
    	super.init(processName);
    	this.batchCount = 0;
        this.recordCount = 0;
        this.queryString = this.defaultQuery;
        this.batchSize = batchSize != null ? batchSize : this.settings.Batch_Size_Limit__c.intValue();
        this.delayExecution = false;
    }

    /**
     * Start method for Batchable
     * @param  batchableContext Database.BatchableContext
     * @return                  Database.QueryLocator
     */
    public virtual Database.QueryLocator start(Database.BatchableContext batchableContext) {
        this.context = batchableContext;
        if (jobStartTime == null) {
            jobStartTime = DateTime.now();
        }

		try {
			return onStart();
		}
		catch (Exception e) {
            log.addMessage(e);
            this.success = false;
        	
        	return Database.getQueryLocator(this.defaultQuery);
		}
    }
    
    /**
     * Implements schedulable execute method
     * @param SC SchedulableContext
     */
    public virtual void execute(SchedulableContext SC) {
    	init(this.processName, this.batchSize);
        execute();
    }

	/**
     * Method execute on start of the batch
     * @return Database.QueryLocator
     */	
	@TestVisible
	protected virtual Database.QueryLocator onStart() {
		return Database.getQueryLocator(queryString);
	}
	
	/**
     * Method execute on finish of the batch
     * @return Database.QueryLocator
     */	
	@TestVisible
	protected virtual void onFinish() {

	}

    /**
     * Execute method for Batchable
     * @param  batchableContext Database.BatchableContext
     * @param  scope            List<SObject>
     */
    public virtual void execute(Database.BatchableContext batchableContext, List<SObject> scope) {
        CS_LogWorker.setInstance(this.log);
        
        try {
            batchCount++;
            doWork(scope);
        }

        catch (Exception e) {
            log.addMessage(e);
            this.success = false;
        }
    }

    /**
     * Finish method for Batchable
     * @param  batchableContext Database.BatchableContext
     */
    public virtual void finish(Database.BatchableContext batchableContext) {
    	CS_BatchWorker.isFinish = true;
    	CS_LogWorker.setInstance(this.log);
    	
        try {
    		onFinish();
        }

        catch (Exception e) {
            log.addMessage(e);
            this.success = false;
        }
        
        if(jobEndTime == null) {
            jobEndTime = DateTime.now();
        }
        
        saveLog();
        sendEmail();
    }
    
    /**
     * Get the message for log
     */
    public virtual override String getMessage() {
        return String.format(message, new List<String>{String.valueOf(jobStartTime), String.valueOf(jobEndTime),
                                                            String.valueOf(batchCount), String.valueOf(recordCount)});
    }
    
    /**
     * Gets the job type
     */
    public virtual override String getJobType() {
        return CS_const_ApexJob.JobType_BatchApex;
    }
    
    /**
     * Gets the job id
     */
    public virtual override Id getJobId() {
        return ((Database.BatchableContext) context).getJobId();
    }

    /**
     * Method that implements work that needs to be done
     */
    @TestVisible
    protected abstract void doWork(List<SObject> scope);
}
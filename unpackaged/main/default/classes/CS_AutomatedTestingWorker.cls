/**
 * @name CS_AutomatedTestingWorker
 * @description Class used to run tests automatically
 * @revision
 *
 */
public class CS_AutomatedTestingWorker extends CS_ScheduledWorker {
	@TestVisible
	private static Set<String> Completed_Statuses = new Set<String> {
			CS_const_ApexJob.Status_Aborted,
			CS_const_ApexJob.Status_Failed,
			CS_const_ApexJob.Status_Completed
	};

	private static final String ApexTestResult_Pass = 'Pass';

	@TestVisible
	private Id testJobId;

	/**
	 * Class constructor
	 * @return 	CS_AutomatedTestingWorker
	 */
	public CS_AutomatedTestingWorker() {
		this(null);
	}

	/**
	 * Class constructor
	 * @param  testJobId Id
	 * @return 		 	 CS_AutomatedTestingWorker
	 */
	public CS_AutomatedTestingWorker(Id testJobId) {
		super('CS_AutomatedTestingWorker');
		this.testJobId = testJobId;
		this.overrideLogging = true;
	}

	/**
	 * Method enqueues tests
	 */
	@TestVisible
	protected override void doWork() {
		stopJob();

		if(String.isBlank(this.testJobId)) {
			this.testJobId = enqueueTests();
		}

		if(getIsCompleted()) {
			getResults();
			this.overrideLogging = false;
			enqueueJob(Time.newInstance(4, 0, 0, 0));
		}
		else {
			enqueueJob(Datetime.now().addMinutes(60));
		}
	}

	/**
	 * Starts tests and returns job id for tracking
	 * @return Id
	 */
	@TestVisible
	private Id enqueueTests() {
		List<ApexClass> testClasses = [FIND '@isTest' IN ALL FIELDS RETURNING ApexClass(Id, Name)][0];
		List<ApexTestQueueItem> queueItems = new List<ApexTestQueueItem>();

		for(ApexClass testClass : testClasses) {
			queueItems.add(new ApexTestQueueItem(ApexClassId = testClass.Id));
		}

		insert queueItems;

		if(!queueItems.isEmpty()) {
			ApexTestQueueItem item = [SELECT
					Id, ParentJobId
			FROM
					ApexTestQueueItem
			WHERE
					Id = :queueItems.get(0).Id LIMIT 1];
			return item.ParentJobId;
		}

		return null;
	}

	/**
	 * Enqueues job at the specific time
	 * @param dt Datetime
	 */
	@TestVisible
	private void enqueueJob(Datetime dt) {
		String timeForScheduler = CS_utl_Cron.getCron(dt);
		System.Schedule(processName, timeForScheduler, new CS_AutomatedTestingWorker(this.testJobId));
	}

	/**
	 * Enqueues job at the specific time
	 * @param tm Time
	 */
	@TestVisible
	private void enqueueJob(Time tm) {
		String timeForScheduler = CS_utl_Cron.getCron(tm);
		System.Schedule(processName, timeForScheduler, new CS_AutomatedTestingWorker(this.testJobId));
	}

	/**
	 *
	 */
	@TestVisible
	private void getResults() {
		List<ApexTestResult> results = [SELECT
				Outcome, MethodName, Message, StackTrace, AsyncApexJobId,
				ApexClass.Name, ApexClass.Body, ApexClass.LengthWithoutComments,
				ApexClass.NamespacePrefix, ApexClass.Status, ApexLogId,
				ApexLog.DurationMilliseconds, ApexLog.Operation, ApexLog.Request,
				ApexLog.Status, ApexLog.Location, ApexLog.Application
		FROM
				ApexTestResult
		WHERE
				AsyncApexJobId = :this.testJobId];

		for(ApexTestResult jobTestResult : results) {
			if(jobTestResult.Outcome != ApexTestResult_Pass) {
				log.addMessage(jobTestResult.ApexClass.Name, jobTestResult.MethodName + ' - ' + jobTestResult.Message,
						jobTestResult.Outcome, CS_const_LogMessage.Type_Error, jobTestResult.StackTrace);
				this.success = false;
			}
			else {
				log.addMessage(jobTestResult.ApexClass.Name, jobTestResult.MethodName,
						jobTestResult.Outcome, CS_const_LogMessage.Type_Info, jobTestResult.StackTrace);
			}
		}
	}

	/**
	 * Checks all items in queue to see if the run has completed
	 */
	@TestVisible
	private Boolean getIsCompleted() {
		Boolean isCompleted = true;
		List<ApexTestQueueItem> items = [SELECT
				ApexClass.Name, Status, ExtendedStatus, ParentJobId
		FROM
				ApexTestQueueItem
		WHERE ParentJobId = :this.testJobId];
		for(ApexTestQueueItem item : items) {
			if(!Completed_Statuses.contains(item.Status)) {
				isCompleted = false;
				break;
			}
		}

		return isCompleted;
	}
}
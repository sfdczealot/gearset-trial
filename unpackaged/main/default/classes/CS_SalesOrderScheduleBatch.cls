/**
 * @name CS_SalesOrderScheduleBatch
 * @description Class that handles Sales Order Schedule updates
 * @revision
 *
 */
public abstract class CS_SalesOrderScheduleBatch extends CS_BatchWorker {
	@TestVisible
	protected CS_DMLWorker dml;
	
	@TestVisible
	private List<Sales_Order_Schedule_Batch__mdt> salesOrderScheduleBatches {
		get {
			if(salesOrderScheduleBatches == null) {
				salesOrderScheduleBatches = [SELECT Id, DeveloperName, Order__c
											FROM Sales_Order_Schedule_Batch__mdt
											ORDER BY Order__c ASC];
			}
			
			return salesOrderScheduleBatches;
		}
		set;
	}
	
	/**
	 * Class constructor
	 * @return CS_BillingScheduleBatch
	 */
	public CS_SalesOrderScheduleBatch(String processName) {
		this(processName, null);
	}
	
	/**
	 * Class constructor
	 * @return CS_BillingScheduleBatch
	 */
	public CS_SalesOrderScheduleBatch(String processName, Integer batchSize) {
		super(processName, batchSize);
		init(processName, batchSize);
	}
	
	public virtual override void init(String processName, Integer batchSize) {
		super.init(processName, batchSize);
		dml = new CS_DMLWorker();
	}
	
	/**
     * Method execute on finish of the batch
     * @return Database.QueryLocator
     */	
	@TestVisible
	protected virtual override void onFinish() {
		this.recordCount = dml.recordCount;
		startNextBatch(getNextBatchName());
	}

	/**
     * Method that gets the next batch name in chain
     * @return String
     */		
	@TestVisible
	private String getNextBatchName() {
		for(Integer i = 0; i < salesOrderScheduleBatches.size(); i++) {
			Sales_Order_Schedule_Batch__mdt sosb = salesOrderScheduleBatches.get(i);
			if(sosb.DeveloperName.equalsIgnoreCase(this.processName) && (i + 1 < salesOrderScheduleBatches.size())) {
				return salesOrderScheduleBatches.get(i + 1).DeveloperName;
			}
		}
		
		return null;
	}

	/**
     * Method that starts the next batch
     */		
	@TestVisible
	private Boolean startNextBatch(String batchName) {
		if(String.isNotBlank(batchName)) {
			Type t = Type.forName(batchName);
			CS_SalesOrderScheduleBatch batch = (CS_SalesOrderScheduleBatch) t.newInstance();
			batch.execute();
			return true;
		}
		
		return false;
	}

	/**
     * Method that escapes a string for query
     */		
	@TestVisible
	protected String escapeString(String value) {
		return '\'' + value + '\'';
	}
	
	public class BillRun {
		public String calendarType {get; set;}
		public String key {get; set;}
		public String recordType {get; set;}
		public Date billingDate {get; set;}
		public String queryString {get; set;}
		public Bill_Run__c billRun {get; set;}
		
		public BillRun(Bill_Run__c billRun) {
			this.calendarType = billRun.Calendar_Type__c;
			this.recordType = billRun.RecordType.Name;
			this.key = billRun.Calendar_Type__c + billRun.RecordType.Name;
			this.billingDate = billRun.Billing_Date__c;
			this.billRun = billRun;
			this.queryString = this.recordType == 'Billing' ? String.format('(Billing_Calendar__c = {0} AND Billing_Date__c <= {1})', new List<String>{escapeString(this.calendarType), String.valueOf(this.billingDate)}) : 
															  String.format('(Rev_Rec_Calendar__c = {0} AND Rev_Rec_Date__c <= {1})', new List<String>{escapeString(this.calendarType), String.valueOf(this.billingDate)});
		}
		
		/**
	     * Method that escapes a string for query
	     */		
		@TestVisible
		private String escapeString(String value) {
			return '\'' + value + '\'';
		}	
	}
	
	public class ScheduleItemQuery {
		public String scheduleType {get; set;}
		public String calendarField {get; set;}
		public String billRunType {get; set;}
		public String queryString {get; set;}
		public String whereClause {get; set;}
		
		public ScheduleItemQuery(String scheduleType, String calendarField, String billRunType, String queryString, String whereClause) {
			this.scheduleType = scheduleType;
			this.calendarField = calendarField;
			this.billRunType = billRunType;
			this.queryString = queryString;
			this.whereClause = whereClause;
		}
	}
}
/**
 * @name CS_BatchLockBillingSchedule
 * @description Class that handles Locking of Billing Schedule Items
 * @revision
 *
 */
public class CS_BatchLockBillingSchedule extends CS_SalesOrderScheduleBatch implements Schedulable {
	@TestVisible
	private static String INITIAL_QUERY_TEMPLATE = 'SELECT Id FROM csmso__Sales_Order__c WHERE Last_Date_Booked__c != null AND Id IN ' +
			   		   					   '(SELECT Sales_Order__c FROM CS_Sales_Order_Schedule__c WHERE ({0}))';
			   		   					   
	@TestVisible
	private Map<String, BillRun> calendarTypesMap {
		get {
			if(calendarTypesMap == null) {
				calendarTypesMap = new Map<String, BillRun>();
		
				for(Bill_Run__c billRun : this.billRuns) {
					BillRun br = new BillRun(billRun);
					if(!calendarTypesMap.containsKey(br.key)) {
						calendarTypesMap.put(br.Key, br);
					}
					
					if(calendarTypesMap.get(br.key).billingDate < billRun.Billing_Date__c) {
						calendarTypesMap.put(br.key, br);
					}	
				}
			}
			
			return calendarTypesMap;
		}
		set;
	}
	
	@TestVisible
	private List<Bill_Run__c> billRuns {
		get {
			if(billRuns == null) {
				billRuns = [SELECT Id, Name, Calendar_Type__c, Status__c, Billing_Date__c, RecordType.Name
							FROM Bill_Run__c
							WHERE Is_Lock_Billing_Date__c = true
							AND Status__c = :CS_const_BillRun.Status_Scheduled];
			}
			
			return billRuns;
		}
		set;
	}
	
	@TestVisible
	private Map<String, Map<Date, BillRun>> billRunsByDate {
		get {
			if(billRunsByDate == null) {
				billRunsByDate = new Map<String, Map<Date, BillRun>>();
		
				for(Bill_Run__c billRun : this.billRuns) {
					BillRun br = new BillRun(billRun);
					if(!billRunsByDate.containsKey(br.key)) {
						billRunsByDate.put(br.key, new Map<Date, BillRun>());
					}
					
					billRunsByDate.get(br.key).put(br.billingDate, br);
				}
			}
			
			return billRunsByDate;
		}
		set;		
	}
	
	public Map<String, ScheduleItemQuery> scheduleItemQueries = new Map<String, ScheduleItemQuery>{
		'CS_Billing_Schedule_Item__c' => new ScheduleItemQuery(
			'CS_Billing_Schedule_Item__c',
			'Billing_Calendar__c',
			'Billing',
			'SELECT Id, Name, Status__c, Billing_Calendar__c, Billing_Date__c FROM CS_Billing_Schedule_Item__c WHERE ({0}) AND Status__c = {1}',
			'(Billing_Calendar__c = {0} AND Billing_Date__c <= {1}) OR '
		),
		'CS_Revenue_Schedule_Item__c' => new ScheduleItemQuery(
			'CS_Revenue_Schedule_Item__c',
			'Rev_Rec_Calendar__c',
			'Revenue Recognition',
			'SELECT Id, Name, Status__c, Rev_Rec_Calendar__c, Rev_Rec_Date__c FROM CS_Revenue_Schedule_Item__c WHERE ({0}) AND Status__c = {1}',
			'(Rev_Rec_Calendar__c = {0} AND Rev_Rec_Date__c <= {1}) OR '
		)
	};
	
	/**
	 * Class constructor
	 * @return CS_BatchLockBillingSchedule
	 */
	public CS_BatchLockBillingSchedule() {
		super('CS_BatchLockBillingSchedule', 1);
	}

	/**
	 * Method that locks Billing Schedule Items
	 * @param  salesOrders List<SObject>
	 */
	public override void doWork(List<SObject> salesOrders) {
		if(!salesOrders.isEmpty()) {
			Map<Id, SObject> salesOrdersToProcess = new Map<Id, SObject>(salesOrders);
			for(ScheduleItemQuery itemQuery : this.scheduleItemQueries.values()) {		
				try {
					String itemQueryString = getQueryString(itemQuery.queryString, itemQuery.billRunType);
					if(String.isNotBlank(itemQueryString)) {
						itemQueryString +=  + ' AND Sales_Order__c IN (\'' + CS_utl_Array.join((List<String>) new List<Id>(salesOrdersToProcess.keySet()), '\',\'') + '\')';
						List<SObject> scheduleItems = Database.query(
							itemQueryString
						);
						
						for(SObject scheduleItem : scheduleItems) {
							Date calendarTypeDate = calendarTypesMap.get(String.valueOf(scheduleItem.get(itemQuery.calendarField)) + String.valueOf(itemQuery.billRunType)).billingDate;
							scheduleItem.put('Status__c', CS_const_SalesOrder.ScheduleStatus_Locked);
							scheduleItem.put('Bill_Run__c', billRunsByDate.get(String.valueOf(scheduleItem.get(itemQuery.calendarField)) + String.valueOf(itemQuery.billRunType)).get(calendarTypeDate).billRun.Id);
						}
					
						update scheduleItems;
					}
				}
				catch (Exception e) {
					for(Id salesOrderId : salesOrdersToProcess.keySet()) {
						log.addMessage(e, salesOrderId);
					}
					
					this.success = false;
				}
			}
		}
	}
	
	@TestVisible
	protected override Database.QueryLocator onStart() {
		this.queryString = getQueryString(INITIAL_QUERY_TEMPLATE, null);
		
		return super.onStart();
	}
	
	@TestVisible
	protected override void onFinish() {
		for(Bill_Run__c billRun : billRuns) {
			billRun.Status__c = CS_const_BillRun.Status_LockingBillSchedules;
		}
		
		update billRuns;
		
		super.onFinish();
	}
	
	@TestVisible
	private String getQueryString(String template, String billRunType) {
		String calendarQuery = '';
		for(BillRun billRun : calendarTypesMap.values()) {
			if(String.isBlank(billRunType) || billRun.recordType == billRunType) {
				calendarQuery += '(' + billRun.queryString + ') OR ';
			}
		}
		
		if(String.isNotBlank(calendarQuery)) {
			return String.format(template, new List<String>{calendarQuery.substring(0, calendarQuery.length() - ' OR '.length()), escapeString(CS_const_SalesOrder.ScheduleStatus_Open)});
		}

		return String.isBlank(billRunType) ? this.queryString : null;
	}
}
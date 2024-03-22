/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to manipulate actuals
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sasa Marjancic   <sasa.marjancic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            name@email.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text. 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public abstract class CS_ActualsService {
	
	public Set<Id> salesOrderIds {get; set;}
	
	public String sObjectType {get; set;}
	
	public Date executeDate {get; set;}
	
	public Map<String, Object> dateLimits {
		get {
			if(dateLimits == null) {
				dateLimits = new Map<String, Object>();
				List<CS_utl_Rollup.RollupDefinition> rollupDefinitions = CS_utl_Rollup.init(getDateDefinition());

				for(CS_utl_Rollup.RollupDefinition definition : rollupDefinitions) {
					for(SObject obj : scheduleItems) {
						definition.calculate(obj);
					}
				}
				for(CS_utl_Rollup.RollupDefinition definition : rollupDefinitions) {
					dateLimits.put(definition.toField, definition.getValue());
	            }
			}
			return dateLimits;
		}
		set;
	}
	
	public Set<String> orderLineItems {
		get {
			if(orderLineItems == null) {
				orderLineItems = new Set<String>();
				for(SObject obj : scheduleItems) {
					orderLineItems.add(getOrderLineId(obj));
				}
			}
			return orderLineItems;
		}
		set;
	}
	
	public List<SObject> scheduleItems {
		get {
			if(scheduleItems == null) {
				scheduleItems = Database.query(
					String.format(getQueryString(), new List<String> {
					CS_utl_Array.join((List<String>) new List<Id>(this.salesOrderIds), '\',\''),
					String.valueOf(executeDate.addDays(7)),
					String.valueOf(executeDate.addDays(-7))
				}));
			}
			return scheduleItems;
		}
		set;
	}
	
	public Map<String, List<SObject>> actualsDfp {
		get {
			if(actualsDfp == null) {
				actualsDfp = new Map<String, List<SObject>>();
				for(SObject actual : Database.query(String.format('SELECT Id, Clicks__c, Total_Impressions__c, Impressions__c, Order_Line_Id__c, Report_Date__c, CreatedDate, Hour__c FROM CS_DFP_Actuals_By_Hour_Report_Data__c ' + 
													'WHERE Impressions__c > 0 AND Report_Date__c >= {0} AND Report_Date__c <= {1} AND Order_Line_Id__c IN (\'\'{2}\'\') ORDER BY CreatedDate DESC', new List<String>{
													String.valueOf(((Date) dateLimits.get('StartDate')).addDays(-1)), String.valueOf(((Date) dateLimits.get('EndDate')).addDays(1)), CS_utl_Array.join((List<String>) new List<String>(orderLineItems), '\',\'')}))) {
					if(!actualsDfp.containsKey((String) actual.get('Order_Line_Id__c'))) {
						actualsDfp.put((String) actual.get('Order_Line_Id__c'), new List<SObject>());
					}
					actualsDfp.get((String) actual.get('Order_Line_Id__c')).add(actual);
				}
			}
			return actualsDfp;
		}
		set;
	}
	
	public Map<String, List<SObject>> actuals3rdParty {
		get {
			if(actuals3rdParty == null) {
				actuals3rdParty = new Map<String, List<SObject>>();
				for(SObject actual : Database.query(String.format('SELECT Id, Clicks__c, Total_Impressions__c, Impressions__c, Order_Line_Id__c, Creative_Id__c, Source__c, Report_Date__c, Local_Server_Name__c, CreatedDate, Time_Zone__c FROM Third_Party_Actual__c ' + 
													'WHERE Impressions__c > 0 AND Report_Date__c >= {0} AND Report_Date__c <= {1} AND Order_Line_Id__c IN (\'\'{2}\'\') ORDER BY CreatedDate DESC', new List<String>{
													String.valueOf(((Date) dateLimits.get('StartDate')).addDays(-1)), String.valueOf(((Date) dateLimits.get('EndDate')).addDays(1)), CS_utl_Array.join((List<String>) new List<String>(orderLineItems), '\',\'')}))) {
					if(!actuals3rdParty.containsKey((String) actual.get('Order_Line_Id__c'))) {
						actuals3rdParty.put((String) actual.get('Order_Line_Id__c'), new List<SObject>());
					}
					actuals3rdParty.get((String) actual.get('Order_Line_Id__c')).add(actual);
				}
			}
			return actuals3rdParty;
		}
		set;
	}

	public List<csdf__Custom_Report_Execution__c > reportExecution {
		get {
			if(reportExecution == null) {
				reportExecution = [SELECT Id, CreatedDate
									FROM csdf__Custom_Report_Execution__c
									WHERE csdf__Report_Status__c = 'Completed' 
									AND csdf__Custom_Report_Definition__r.csdf__Ad_Server__r.csdf__Network_Code__c = :CS_Custom_Settings__c.getInstance().Ad_Server_Network_Code__c
									ORDER by CreatedDate DESC];
			}
			return reportExecution;
		}
		set;
	}

	public Datetime dfpAsOfDate {
		get {
			if(dfpAsOfDate == null) {
				if(!reportExecution.isEmpty()) {
					dfpAsOfDate = Datetime.newInstanceGmt(reportExecution.get(0).CreatedDate.year(),
														  reportExecution.get(0).CreatedDate.month(),
														  reportExecution.get(0).CreatedDate.day(),
														  0, 0, 0);
					if(dfpAsOfDate.date() > executeDate) {
						dfpAsOfDate = Datetime.newInstanceGmt(executeDate.year(), executeDate.month(), executeDate.day(), 0, 0, 0);
					}
				}
			}
			return dfpAsOfDate;
		}
		set;
	}
	
	public String getOrderLineId(SObject scheduleItem) {
		String orderLineId = CS_utl_SObject.getFieldValue(scheduleItem, 'Id');
		return CS_utl_SObject.getFieldValue(scheduleItem, 'DFP_Order_Line_ID__c');
	}
	
	public CS_ActualsService(String sObjectType) {
		this.sObjectType = sObjectType;
	}


	public List<SObject> doCalculate(List<SObject> scheduleItems, Set<Id> salesOrderIds, Date executeDate) {
		this.scheduleItems = scheduleItems;
		return doCalculate(salesOrderIds, executeDate);
	}
	
	public List<SObject> doCalculate(Set<Id> salesOrderIds, Date executeDate) {
		this.executeDate = executeDate;
		this.salesOrderIds = salesOrderIds;
		
		Integer chunkSize = (Integer) CS_Custom_Settings__c.getInstance().Consolidation_Size__c;
		if(scheduleItems.size() <= chunkSize) {
			for(SObject scheduleItem : scheduleItems) {
				String orderLineItemId = getOrderLineId(scheduleItem);
				
				if(actualsDfp.containsKey(orderLineItemId)) {
					CS_ActualsBase.CS_DFPActuals actualsBase = new CS_ActualsBase.CS_DFPActuals(
						(Datetime) scheduleItem.get('Flight_Begin_GMT__c'), (Datetime) scheduleItem.get('Flight_End_GMT__c'), getStartDate(scheduleItem), getEndDate(scheduleItem),
						getDfpAsOfDate(scheduleItem), getLocalTimeZone(scheduleItem), getLocalServer(scheduleItem), dfpAsOfDate.date()
					);
					actualsBase.calculate(actualsDfp.get(orderLineItemId), (String) scheduleItem.get('Insertion_Unit_Type__c'));
						
					if(actualsBase.applicableLines > 0) {
						scheduleItem.put('DFP_Actuals__c', CS_utl_SObject.getDecimalValue('DFP_Actuals__c', scheduleItem) + actualsBase.quantity - CS_utl_SObject.getDecimalValue('DFP_Actuals_Delta__c', scheduleItem));
						scheduleItem.put('DFP_Actuals_Delta__c', actualsBase.rollingQuantity);
						scheduleItem.put('DFP_Actuals_as_of__c', actualsBase.getCalculatedToDate());
					}
				}
				
				if(actuals3rdParty.containsKey(orderLineItemId)) {
					CS_ActualsBase.CS_ThirdPartyActuals actualsBase = new CS_ActualsBase.CS_ThirdPartyActuals(
						(Datetime) scheduleItem.get('Flight_Begin_GMT__c'), (Datetime) scheduleItem.get('Flight_End_GMT__c'), getStartDate(scheduleItem), getEndDate(scheduleItem),
						getThirdPartyAsOfDate(scheduleItem), getLocalTimeZone(scheduleItem), getLocalServer(scheduleItem), executeDate
					);
					actualsBase.calculate(actuals3rdParty.get(orderLineItemId), (String) scheduleItem.get('Insertion_Unit_Type__c'));
						
					if(actualsBase.applicableLines > 0) {
						scheduleItem.put('X3rd_Party_Actuals__c', CS_utl_SObject.getDecimalValue('X3rd_Party_Actuals__c', scheduleItem) + actualsBase.quantity - CS_utl_SObject.getDecimalValue('X3rd_Party_Actuals_Delta__c', scheduleItem));
						scheduleItem.put('X3rd_Party_Actuals_Delta__c', actualsBase.rollingQuantity);
						scheduleItem.put('X3rd_Party_Actuals_as_of__c', actualsBase.getCalculatedToDate());
						scheduleItem.put('Source__c', actuals3rdParty.get(orderLineItemId).get(0).get('Source__c'));
					}
				}
			}

			update scheduleItems;
		}

		return scheduleItems;
	}
	
	public abstract List<CS_utl_Rollup.RollupDefinition> getDateDefinition();
	
	public abstract String getQueryString();
	
	public abstract Date getStartDate(SObject scheduleItem);
	
	public abstract Date getEndDate(SObject scheduleItem);
	
	public virtual Date getDfpAsOfDate(SObject scheduleItem) {
		return scheduleItem.get('DFP_Actuals_as_of__c') != null ? ((Datetime) scheduleItem.get('DFP_Actuals_as_of__c')).date() : null;
	}
	
	public virtual Date getThirdPartyAsOfDate(SObject scheduleItem) {
		return scheduleItem.get('X3rd_Party_Actuals_as_of__c') != null ? ((Datetime) scheduleItem.get('X3rd_Party_Actuals_as_of__c')).date() : null;
	}
	
	public virtual String getLocalTimeZone(SObject scheduleItem) {
		return CS_utl_SObject.getFieldValue(scheduleItem, 'Product_Configuration__r.Booking_Timezone__r.Name');
	}
	
	public virtual String getLocalServer(SObject scheduleItem) {
		return (String) scheduleItem.get('X3rd_Party_Ad_Server__c');
	}
	
	public class CS_BillingActualsService extends CS_ActualsService {
		public CS_BillingActualsService() {
			super('CS_Billing_Schedule_Item__c');
		}
		
		public override List<CS_utl_Rollup.RollupDefinition> getDateDefinition() {
			return new List<CS_utl_Rollup.RollupDefinition>{
		    	new CS_utl_Rollup.RollupDefinition('Billing_Period_Start_Date__c', 'StartDate', CS_utl_Rollup.Operation.MIN, null, null),
	    		new CS_utl_Rollup.RollupDefinition('Billing_Period_End_Date__c', 'EndDate', CS_utl_Rollup.Operation.MAX, null, null)
			};
		}
		
		
		public override String getQueryString() {
			return 'SELECT Id, X3rd_Party_Actuals__c, DFP_Order_Line_ID__c, DFP_Actuals__c, DFP_Actuals_as_of__c, DFP_Actuals_Delta__c, X3rd_Party_Ad_Server__c, X3rd_Party_Actuals_Delta__c, CreatedDate, ' +
				   'X3rd_Party_Actuals_as_of__c, Billing_Period_Start_Date__c, Billing_Period_End_Date__c, Billing_Schedule__r.Total_Closed_DFP_Actuals__c, Billing_Schedule__r.Total_Closed_X3rd_Party_Actuals__c, ' +
				   'Product_Configuration__r.Booking_Timezone__r.Name, Flight_Begin_GMT__c, Flight_End_GMT__c, Insertion_Unit_Type__c ' +
				   'FROM CS_Billing_Schedule_Item__c WHERE Status__c IN (\'\'Locked\'\',\'\'Open\'\',\'\'Pending\'\') AND Sales_Order__c IN (\'\'{0}\'\') ' + 
				   'AND ((Billing_Period_Start_Date__c <= {1} AND Billing_Period_End_Date__c >= {2})) AND Product_Configuration__r.Served_By__c = \'\'DFP\'\'';
		}
		
		public override Date getStartDate(SObject scheduleItem) {
			String orderLineId = CS_utl_SObject.getFieldValue(scheduleItem, 'Id');
			
			return (Date) scheduleItem.get('Billing_Period_Start_Date__c');
		}
		
		public override Date getEndDate(SObject scheduleItem) {
			String orderLineId = CS_utl_SObject.getFieldValue(scheduleItem, 'Id');
			
			return (Date) scheduleItem.get('Billing_Period_End_Date__c');
		}
	}
	
	public class CS_RevenueActualsService extends CS_ActualsService {
		public CS_RevenueActualsService() {
			super('CS_Revenue_Schedule_Item__c');
		}
		
		public override List<CS_utl_Rollup.RollupDefinition> getDateDefinition() {
			return new List<CS_utl_Rollup.RollupDefinition>{
		    	new CS_utl_Rollup.RollupDefinition('Rev_Rec_Period_Start_Date__c', 'StartDate', CS_utl_Rollup.Operation.MIN, null, null),
	    		new CS_utl_Rollup.RollupDefinition('Rev_Rec_Period_End_Date__c', 'EndDate', CS_utl_Rollup.Operation.MAX, null, null)
			};
		}
		
		public override String getQueryString() {
			return 'SELECT Id, X3rd_Party_Actuals__c, DFP_Order_Line_ID__c, DFP_Actuals__c, DFP_Actuals_as_of__c, DFP_Actuals_Delta__c, Rev_Rec_Period_End_Date__c, X3rd_Party_Ad_Server__c, X3rd_Party_Actuals_Delta__c, CreatedDate, ' + 
				   'X3rd_Party_Actuals_as_of__c, Rev_Rec_Period_Start_Date__c, Revenue_Schedule__r.Total_Closed_DFP_Actuals__c, Revenue_Schedule__r.Total_Closed_X3rd_Party_Actuals__c ,' +
				   'Product_Configuration__r.Booking_Timezone__r.Name, Flight_Begin_GMT__c, Flight_End_GMT__c, Insertion_Unit_Type__c ' + 
				   'FROM CS_Revenue_Schedule_Item__c WHERE Status__c IN (\'\'Locked\'\',\'\'Open\'\',\'\'Pending\'\') AND Sales_Order__c IN (\'\'{0}\'\') ' + 
				   'AND ((Rev_Rec_Period_Start_Date__c <= {1} AND Rev_Rec_Period_End_Date__c >= {2})) AND Product_Configuration__r.Served_By__c = \'\'DFP\'\'';
		}
		
		public override Date getStartDate(SObject scheduleItem) {
			String orderLineId = CS_utl_SObject.getFieldValue(scheduleItem, 'Id');
			
			return (Date) scheduleItem.get('Rev_Rec_Period_Start_Date__c');
		}
		
		public override Date getEndDate(SObject scheduleItem) {
			String orderLineId = CS_utl_SObject.getFieldValue(scheduleItem, 'Id');
			
			return (Date) scheduleItem.get('Rev_Rec_Period_End_Date__c');
		}
	}
}
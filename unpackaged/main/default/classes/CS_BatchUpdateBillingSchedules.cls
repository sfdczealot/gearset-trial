/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Batch process for updating the quantities on the billing schedules of product configs that have 
*                       schedules with requires recalculation =true and status = closed.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Kalyan Erraguntla     <kalyan.erraguntla@cloudsense.com>
* Date Created    : 25/09/2018
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Refactored to use new Batch Framework
* 
* @author         Aldo Topic            <aldo.topic@cloudsensesolutions.com>
* Date Refactored : 09/10/2018
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Refactored to use new CS_Billing_Schedule_Item__c object instead of old Billing_Schedule__c object
*                   and to use new constant class CS_const_BillingScheduleItem 
* 
* @author         Aldo Topic            <aldo.topic@cloudsensesolutions.com>
* Date Refactored : 11/10/2018
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* requires Refactoring - mostly commented now as new model uses roll up summaries and worjflows 
* to performa lot of these functions.
* 
* @author         Craig Steen            @Sasa - Please review this once the Service is complete -Tx!
* Date Refactored : 11/10/2018
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

global class CS_BatchUpdateBillingSchedules extends CS_SalesOrderScheduleBatch implements Schedulable {
    @TestVisible
    private static String QUERY_TEMPLATE =  'SELECT Id FROM csmso__Sales_Order__c ' +
                                            'WHERE Id IN (SELECT Sales_Order__c FROM CS_Sales_Order_Schedule__c ' +
                                            'WHERE Pending_Billing_Forecast_Recalculation__c > 0 OR Pending_Revenue_Forecast_Recalculation__c > 0)';
    
    global CS_BatchUpdateBillingSchedules() {
        super('CS_BatchUpdateBillingSchedules', 1);
        this.queryString = QUERY_TEMPLATE;
    }

    /**
     * Method that updates Billing Schedule Items
     * @param  salesOrders List<SObject>
     */
    public override void doWork(List<SObject> salesOrders) {
    	Set<Id> salesOrderIds = new Set<Id>();
    	
    	for(SObject salesOrder : salesOrders) {
    		salesOrderIds.add((Id) salesOrder.get('Id'));
    	}
    	   	
	    Boolean result = !salesOrderIds.isEmpty() ? CS_ScheduleService.updateSchedules(salesOrderIds, null) : true;
	    	
	    this.success = !this.success ? this.success : result;
    }
    
	@TestVisible
	protected override void onFinish() {
		List<Bill_Run__c> billRunToUpdate = new List<Bill_Run__c>();
		List<Bill_Run__c> allBillRuns = [SELECT Id, Status__c
										  FROM Bill_Run__c
										  WHERE Status__c = :CS_const_BillRun.Status_AutoReconciliating];
		Map<Id, Bill_Run__c> pendingBillRuns = new Map<Id, Bill_Run__c>(
											[SELECT Id, Status__c
											  FROM Bill_Run__c
											  WHERE Status__c = :CS_const_BillRun.Status_AutoReconciliating
											  AND Id IN (SELECT Bill_Run__c FROM CS_Billing_Schedule_Item__c WHERE Status__c != :CS_const_SalesOrder.ScheduleStatus_Closed)]);
		Map<Id, Bill_Run__c> pendingRevRuns = new Map<Id, Bill_Run__c>(
											[SELECT Id, Status__c
											  FROM Bill_Run__c
											  WHERE Status__c = :CS_const_BillRun.Status_AutoReconciliating
											  AND Id IN (SELECT Bill_Run__c FROM CS_Revenue_Schedule_Item__c WHERE Status__c != :CS_const_SalesOrder.ScheduleStatus_Closed)]);
		for(Bill_Run__c billRun : allBillRuns) {
			if(!pendingBillRuns.containsKey(billRun.Id) && !pendingRevRuns.containsKey(billRun.Id)) {
				billRun.Status__c = CS_const_BillRun.Status_Complete;
				billRunToUpdate.add(billRun);
			}
		}
		
		update billRunToUpdate;
		
		super.onFinish();
	}
}
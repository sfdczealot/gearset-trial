/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update handle logic After Primary SO changes
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sasa Marjancic   <sasa.marjancic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            sasa.marjancic@cloudsense.com
* 2018-10-22      Initial version
*
* @changes
* v2.0           aldo.topic@cloudsense.com
* 2020-03-09     When Primary Sales Order changes from true to false - remove/cancel BSI/RSI
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_PrimarySOChange extends CS_ProcessBase {
	@TestVisible
	Map<Id, csmso__Sales_Order__c> applicableObjects;

	@TestVisible
	Map<Id, csmso__Sales_Order__c> oldObjects;

	public CS_P_PrimarySOChange(Map<Id, csmso__Sales_Order__c> oldObjects) {
		super(CS_ProcessDefinition.PRIMARYSO_CHANGE, 'CS_P_PrimarySOChange');

		this.oldObjects = oldObjects;
		applicableObjects = new Map<Id, csmso__Sales_Order__c>();
	}

	public override void isRecordEligible(SObject obj) {
		csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
		csmso__Sales_Order__c oldSalesOrder = oldObjects != null ? (csmso__Sales_Order__c) oldObjects.get(newSalesOrder.Id) : null;

		if(oldSalesOrder != null && oldSalesOrder.Primary_Sales_Order__c == true && newSalesOrder.Primary_Sales_Order__c == false) {
			applicableObjects.put(newSalesOrder.Id, newSalesOrder);
		}

		this.runProcess = !applicableObjects.isEmpty() && !CS_ProcessExecution.wasProcessExecuted(CS_ProcessDefinition.PRIMARYSO_CHANGE);
	}

	public override void logic() {
		List<SObject> scheduleItemsToCancel = new List<SObject>();
		List<SObject> scheduleItemsToDelete = new List<SObject>();
		Map<Id, CS_Billing_Schedule_Item__c> soToBScheduleItem = new Map<Id, CS_Billing_Schedule_Item__c>();
		Map<Id, CS_Revenue_Schedule_Item__c> soToRScheduleItem = new Map<Id, CS_Revenue_Schedule_Item__c>();

		List<CS_Billing_Schedule_Item__c> bScheduleItems = [
			SELECT Id, Status__c, Billing_Schedule__c, Valid_for_Auto_Cancellation__c, Sales_Order__c
				FROM CS_Billing_Schedule_Item__c
				WHERE Sales_Order__c = :applicableObjects.keySet()
		];

		List<CS_Revenue_Schedule_Item__c> rScheduleItems = [
			SELECT Id, Status__c, Revenue_Schedule__c, Valid_for_Auto_Cancellation__c, Sales_Order__c
				FROM CS_Revenue_Schedule_Item__c
				WHERE Sales_Order__c = :applicableObjects.keySet()
		];

		for(CS_Billing_Schedule_Item__c bsi : bScheduleItems) {
			soToBScheduleItem.put(bsi.Sales_Order__c, bsi);
		}

		for(CS_Revenue_Schedule_Item__c rsi : rScheduleItems) {
			soToRScheduleItem.put(rsi.Sales_Order__c, rsi);
		}

		for(csmso__Sales_Order__c salesOrder : applicableObjects.values()) {
			if (salesOrder.Sold__c && soToBScheduleItem.get(salesOrder.Id) != null) {
				scheduleItemsToCancel.add(soToBScheduleItem.get(salesOrder.Id));
			}
			else if (soToRScheduleItem.get(salesOrder.Id) != null) {
				scheduleItemsToDelete.add(soToRScheduleItem.get(salesOrder.Id));
			}
		}

		if(!scheduleItemsToCancel.isEmpty()) {
			CS_ScheduleService.cancelScheduleItems(scheduleItemsToCancel);
		}

		if(!scheduleItemsToDelete.isEmpty()) {
			CS_ScheduleService.deleteScheduleItems(scheduleItemsToDelete);
		}
	}
}
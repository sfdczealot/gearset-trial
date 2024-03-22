/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to handle update when Fulfilment Item becomes Completed. Checks all FI from Fulfilment and
* if all are Completed it set Fulfilment to Completed.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            aldo.topic@cloudsense.com
* 2020-11-05      Initial version
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_FIToUpdateCompletedFulfilment extends CS_ProcessBase {
	@TestVisible
	Map<Id, csdf__Fulfilment_Item__c> applicableObjects;

	@TestVisible
	Map<Id, csdf__Fulfilment_Item__c> oldObjects;

	public CS_P_FIToUpdateCompletedFulfilment(Map<Id, csdf__Fulfilment_Item__c> oldObjects) {
		super(CS_ProcessDefinition.FULFILMENTITEM_UPDATECOMPLETEDFULFILMENT, 'CS_P_FIToUpdateCompletedFulfilment');

		applicableObjects = new Map<Id, csdf__Fulfilment_Item__c>();
		this.oldObjects = oldObjects;
	}

	public override void isRecordEligible(SObject obj) {
		csdf__Fulfilment_Item__c newFI = (csdf__Fulfilment_Item__c) obj;
		csdf__Fulfilment_Item__c oldFI = oldObjects != null ? (csdf__Fulfilment_Item__c) oldObjects.get(newFI.Id) : null;

		if (oldFI != null
				&& oldFI.csdf__Status__c != newFI.csdf__Status__c
				&& newFI.csdf__Status__c == CS_const_SalesOrder.FulfilmentItemStatus_Completed) {
			applicableObjects.put(newFI.Id, newFI);
		}

		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		Set<Id> fulfilmentIds = new Set<Id>();
		List<csdf__Fulfilment__c> fulfilmentsToUpdate = new List<csdf__Fulfilment__c>();

		for (csdf__Fulfilment_Item__c newFI : applicableObjects.values()) {
			fulfilmentIds.add(newFI.csdf__Fulfilment__c);
		}

		List<csdf__Fulfilment_Item__c> fulfilmentItemsNotCompleted = [
				SELECT 	Id,
						csdf__Fulfilment__c
				FROM csdf__Fulfilment_Item__c
				WHERE csdf__Status__c != :CS_const_SalesOrder.FulfilmentItemStatus_Completed
				AND csdf__Fulfilment__c IN :fulfilmentIds
		];

		for (csdf__Fulfilment_Item__c fulfilmentItemNotCompleted : fulfilmentItemsNotCompleted) {
			fulfilmentIds.remove(fulfilmentItemNotCompleted.csdf__Fulfilment__c);
		}

		for (Id fulfilmentId : fulfilmentIds) {
			fulfilmentsToUpdate.add(new csdf__Fulfilment__c(Id = fulfilmentId, csdf__Status__c = CS_const_SalesOrder.FulfilmentStatus_Completed));
		}

		if (!fulfilmentsToUpdate.isEmpty()) {
			 Set<csdf__Fulfilment__c> fulfilmentsToUpdateSet = new Set<csdf__Fulfilment__c>(fulfilmentsToUpdate);
         
                //to convert set back to list 
                List<csdf__Fulfilment__c> fulfilmentList = new List<csdf__Fulfilment__c>(fulfilmentsToUpdateSet);
			update fulfilmentList;
		}
	}
}
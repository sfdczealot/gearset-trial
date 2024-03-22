/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Updates field Primary SO on Opportunity when inserting first Opportunity on Sales Order
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ivan Ravnjak   <ivan.ravnjak@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0           ivan.ravnjak@cloudsense.com
* 2019-04-29     Initial version
*
* @changes
* v2.0           aldo.topic@cloudsense.com
* 2020-03-09     When primary sales order changes from false to true on sales order - set the
* 					primary so on opportunity if primary so on opp != so that is in the trigger
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_UpdatePrimarySO extends CS_ProcessBase {
	@TestVisible
	Map<Id, csmso__Sales_Order__c> applicableObjects;
	
	@TestVisible
	Map<Id, csmso__Sales_Order__c> oldObjects;

	public CS_P_UpdatePrimarySO(Map<Id, csmso__Sales_Order__c> oldObjects) {
		super(CS_ProcessDefinition.PRIMARYSO_UPDATE, 'CS_P_UpdatePrimarySO');

		this.oldObjects = oldObjects;
		applicableObjects = new Map<Id, csmso__Sales_Order__c>();
	}
 
	public override void isRecordEligible(SObject obj) {
		csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
		csmso__Sales_Order__c oldSalesOrder = oldObjects != null ? (csmso__Sales_Order__c) oldObjects.get(newSalesOrder.Id) : null;

		if((oldSalesOrder == null && newSalesOrder.Primary_Sales_Order__c == true) || (oldSalesOrder != null && oldSalesOrder.Primary_Sales_Order__c == false && newSalesOrder.Primary_Sales_Order__c == true)) {
			applicableObjects.put(newSalesOrder.Id, newSalesOrder);
		}
		if((oldSalesOrder == null && newSalesOrder.Primary_Sales_Order__c != null)  ||(newSalesOrder.SO_Start_Date_Manual__c != oldSalesOrder.SO_Start_Date_Manual__c)){
			applicableObjects.put(newSalesOrder.Id, newSalesOrder);
			system.debug('=====>' +applicableObjects);
		}
		this.runProcess = !applicableObjects.isEmpty() && !CS_ProcessExecution.wasProcessExecuted(CS_ProcessDefinition.PRIMARYSO_UPDATE);
	}

	public override void logic() {
		Map<Id, csmso__Sales_Order__c> salesOrdersByOpp = new Map<Id, csmso__Sales_Order__c>();
		Set<Id> soSet = new Set<Id>();
		for(csmso__Sales_Order__c salesOrder : applicableObjects.values()) {
			if(salesOrder.csmso__Opportunity__c != null) {
				salesOrdersByOpp.put(salesOrder.csmso__Opportunity__c, salesOrder);
				soSet.add(salesOrder.Id);
			}
		}

		Map<Id, Opportunity> opps = new Map<Id, Opportunity>([
			SELECT Id, Primary_Sales_Order__c,Order_date__c
				FROM Opportunity
				WHERE Id = :salesOrdersByOpp.keySet()
		]);

		List<Opportunity> oppToUpdate = new List<Opportunity>();
        List<Opportunity> oppDateUpdate = new List<Opportunity>();
		for(Id opportunityId : salesOrdersByOpp.keySet()) {
			csmso__Sales_Order__c salesOrder = salesOrdersByOpp.get(opportunityId);
			Opportunity currentOpp = opps.get(opportunityId);

			if(currentOpp.Primary_Sales_Order__c != salesOrder.Id) {
				currentOpp.Primary_Sales_Order__c = salesOrder.Id;
				oppToUpdate.add(currentOpp);
			}
            			if(currentOpp.Order_date__c != salesOrder.SO_Start_Date_Manual__c) {
				currentOpp.Order_date__c = salesOrder.SO_Start_Date_Manual__c;
				oppDateUpdate.add(currentOpp);
			}
		}
		if(!oppToUpdate.isEmpty()) {
			update oppToUpdate;
		}
        if(!oppDateUpdate.isEmpty()) {
			update oppDateUpdate;
			system.debug('====update=====' +oppDateUpdate);
		}

	//	CS_ScheduleService.generateSchedules(soSet, null);
	}
}
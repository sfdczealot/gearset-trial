/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to set primary sales order flag on first so created for an opportunity
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sasa Marjancic   <sasa.marjancic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            sasa.marjancic@cloudsense.com
* 2019-02-22      Initial version 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_SetPrimarySO extends CS_ProcessBase {      
	@TestVisible 
	List<csmso__Sales_Order__c> applicableObjects;

	public CS_P_SetPrimarySO() {
		super(CS_ProcessDefinition.SO_SETPRIMARY, 'CS_P_SetPrimarySO');

		applicableObjects = new List<csmso__Sales_Order__c>(); 
	}
 
	public override void isRecordEligible(SObject obj) {
		csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
		applicableObjects.add(newSalesOrder);

		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		Map<Id, csmso__Sales_Order__c> salesOrdersByOpp = new Map<Id, csmso__Sales_Order__c>();
		for(csmso__Sales_Order__c salesOrder : applicableObjects) {
			if(salesOrder.csmso__Opportunity__c != null) {
				salesOrdersByOpp.put(salesOrder.csmso__Opportunity__c, salesOrder);
			}
		}
		
		Map<Id, Opportunity> opps = new Map<Id, Opportunity>([SELECT Id, Primary_Sales_Order__c, 
																			(SELECT Id FROM csmso__Sales_Orders__r 
																			WHERE csmso__Status__c != :CS_const_SalesOrder.Status_Killed 
																			ORDER BY LastModifiedDate DESC)
													  		  FROM Opportunity
													  		  WHERE Id = :salesOrdersByOpp.keySet()]);
		for(Id opportunityId : salesOrdersByOpp.keySet()) {
			csmso__Sales_Order__c salesOrder = salesOrdersByOpp.get(opportunityId);
			if(opps.get(opportunityId).csmso__Sales_Orders__r.isEmpty()) {
				salesOrder.Primary_Sales_Order__c = true;
				//PROP-274 to ensure a sync happening before submit
				salesOrder.Synchronized_with_Opportunity__c = false;
			}
		}
	}
}
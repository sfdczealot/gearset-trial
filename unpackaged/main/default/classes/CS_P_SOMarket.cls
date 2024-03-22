/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update handle logic when Sales Order market is changed
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sasa Marjancic   <sasa.marjancic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            sasa.marjancic@cloudsense.com
* 2019-02-22      Initial version 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_SOMarket extends CS_ProcessBase {   
	@TestVisible 
	Map<Id, csmso__Sales_Order__c> applicableObjects;
	
	@TestVisible
	Map<Id, csmso__Sales_Order__c> oldObjects;

	public CS_P_SOMarket(Map<Id, csmso__Sales_Order__c> oldObjects) {
		super(CS_ProcessDefinition.SO_MARKETCHANGED, 'CS_P_SOMarket');
		
		this.oldObjects = oldObjects;
		applicableObjects = new Map<Id, csmso__Sales_Order__c>(); 
	}
 
	public override void isRecordEligible(SObject obj) {
		csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
		csmso__Sales_Order__c oldSalesOrder = (csmso__Sales_Order__c) oldObjects.get(newSalesOrder.Id);
		
		if(newSalesOrder.Market__c != oldSalesOrder.Market__c) {
			applicableObjects.put(newSalesOrder.Id, newSalesOrder);
		}

		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {	
		for(csmso__Sales_Order__c salesOrder : applicableObjects.values()) {
			salesOrder.Rate_Card__c = null;
		}
	}
}
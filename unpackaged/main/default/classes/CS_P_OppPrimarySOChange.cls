/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update handle logic when Primary SO changes
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sasa Marjancic   <sasa.marjancic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            sasa.marjancic@cloudsense.com
* 2018-10-22      Initial version
*
* @changes
* v2.0           aldo.topic@cloudsense.com
* 2020-03-09     If primary sales order new != primary sales order old, then remove primary sales
* 					order on old sales order
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_OppPrimarySOChange extends CS_ProcessBase {   
	@TestVisible 
	Map<Id, Opportunity> applicableObjects;
	
	@TestVisible
	Map<Id, Opportunity> oldObjects;

	public CS_P_OppPrimarySOChange(Map<Id, Opportunity> oldObjects) {
		super(CS_ProcessDefinition.OPPORTUNITY_PRIMARYSOCHANGE, 'CS_P_OppPrimarySOChange');
		
		this.oldObjects = oldObjects;
		applicableObjects = new Map<Id, Opportunity>(); 
	}
 
	public override void isRecordEligible(SObject obj) {
		Opportunity newOpp = (Opportunity) obj;
		Opportunity oldOpp = oldObjects != null ? (Opportunity) oldObjects.get(newOpp.Id) : null;
		
		if(newOpp.Primary_Sales_Order__c != oldOpp.Primary_Sales_Order__c) {
			applicableObjects.put(newOpp.Id, newOpp);
		}

		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		List<csmso__Sales_Order__c> salesOrders = [SELECT Id, Primary_Sales_Order__c, csmso__Opportunity__c
												   FROM csmso__Sales_Order__c
												   WHERE csmso__Opportunity__c = :applicableObjects.keySet()];
		Map<Id, List<csmso__Sales_Order__c>> salesOrdersByOpp = new Map<Id, List<csmso__Sales_Order__c>>();
		for(csmso__Sales_Order__c salesOrder : salesOrders) {
			if(!salesOrdersByOpp.containsKey(salesOrder.csmso__Opportunity__c)) {
				salesOrdersByOpp.put(salesOrder.csmso__Opportunity__c, new List<csmso__Sales_Order__c>());
			}
			salesOrdersByOpp.get(salesOrder.csmso__Opportunity__c).add(salesOrder);	
		}
		
		List<csmso__Sales_Order__c> salesOrderToUpdate = new List<csmso__Sales_Order__c>();
		for(Opportunity opp : applicableObjects.values()) {
			List<csmso__Sales_Order__c> soByOpp = new List<csmso__Sales_Order__c>();
			if(salesOrdersByOpp.get(opp.Id) != null) {
				soByOpp = salesOrdersByOpp.get(opp.Id);
			}
			for(csmso__Sales_Order__c so : soByOpp) {
				if(so.Primary_Sales_Order__c && so.Id != opp.Primary_Sales_Order__c) {
					so.Primary_Sales_Order__c = false;
					so.Synchronized_with_Opportunity__c = false;
					salesOrderToUpdate.add(so);
				}
			}
		}
		
		if(!salesOrderToUpdate.isEmpty()) {
			update salesOrderToUpdate;
		}
	}
}
/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update handle logic when Primary Salesperson changes
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            aldo.topic@cloudsense.com
* 2020-03-17      Initial version
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_OppPrimarySalespersonChange extends CS_ProcessBase {
	@TestVisible
	Map<Id, Opportunity> applicableObjects;

	@TestVisible
	Map<Id, Opportunity> oldObjects;

	public CS_P_OppPrimarySalespersonChange(Map<Id, Opportunity> oldObjects) {
		super(CS_ProcessDefinition.OPPORTUNITY_PRIMARYSALESPERSONCHANGE, 'CS_P_OppPrimarySalespersonChange');

		this.oldObjects = oldObjects;
		applicableObjects = new Map<Id, Opportunity>();
	}

	public override void isRecordEligible(SObject obj) {
		Opportunity newOpp = (Opportunity) obj;
		Opportunity oldOpp = oldObjects != null ? (Opportunity) oldObjects.get(newOpp.Id) : null;

		if (newOpp.Primary_Salesperson__c != null && newOpp.Primary_Salesperson__c != oldOpp.Primary_Salesperson__c) {
			applicableObjects.put(newOpp.Id, newOpp);
		}

		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		List<csmso__Sales_Order__c> applicableSalesOrders = [
				SELECT Id,
						Ad_Server_Sales_Person__c,
						csmso__Opportunity__r.Id
				FROM csmso__Sales_Order__c
				WHERE csmso__Opportunity__c IN :applicableObjects.keySet()
		];

		for (csmso__Sales_Order__c currSalesOrder : applicableSalesOrders) {
			Opportunity currOpp = applicableObjects.get(currSalesOrder.csmso__Opportunity__r.Id);
			currSalesOrder.Ad_Server_Sales_Person__c = currOpp.Primary_Salesperson__c;
		}

		if (!applicableSalesOrders.isEmpty()) {
			update applicableSalesOrders;
		}
	}
}
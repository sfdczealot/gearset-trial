/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update Opportunity status to Qualified when Primary SO changes to In Progress Status.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            aldo.topic@cloudsense.com
* 2020-10-13      Initial version
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_PrimarySOInProgressOppQualified extends CS_ProcessBase {
	@TestVisible
	Map<Id, csmso__Sales_Order__c> applicableObjects;

	@TestVisible
	Map<Id, csmso__Sales_Order__c> oldObjects;

	public CS_P_PrimarySOInProgressOppQualified(Map<Id, csmso__Sales_Order__c> oldObjects) {
		super(CS_ProcessDefinition.PRIMARYSO_INPROGRESS_OPP_QUALIFIED, 'CS_P_PrimarySOInProgressOppQualified');

		this.oldObjects = oldObjects;
		applicableObjects = new Map<Id, csmso__Sales_Order__c>();
	}

	public override void isRecordEligible(SObject obj) {
		csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
		csmso__Sales_Order__c oldSalesOrder = oldObjects != null ? (csmso__Sales_Order__c) oldObjects.get(newSalesOrder.Id) : null;

		if (oldSalesOrder != null
				&& newSalesOrder.Primary_Sales_Order__c == true
				&& oldSalesOrder.csmso__Status__c != newSalesOrder.csmso__Status__c
				&& newSalesOrder.csmso__Status__c == CS_const_SalesOrder.Status_InProgress) {
			applicableObjects.put(newSalesOrder.Id, newSalesOrder);
		}

		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		Set<Opportunity> opportunitiesToUpdateSet = new Set<Opportunity>();

		for (csmso__Sales_Order__c salesOrder : applicableObjects.values()) {
			Opportunity opportunity = new Opportunity(Id = salesOrder.csmso__Opportunity__c, StageName = 'Qualifying');
			opportunitiesToUpdateSet.add(opportunity);
		}

		if (!opportunitiesToUpdateSet.isEmpty()) {
			update new List<Opportunity>(opportunitiesToUpdateSet);
		}
	}
}
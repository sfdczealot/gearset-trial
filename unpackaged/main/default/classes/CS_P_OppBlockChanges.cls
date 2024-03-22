/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to block changes to Advertiser/Agency/Account on the opportunity if any of SO is in 
* NOT Allowed Statuses (notAllowedSOStatuses Set in class).
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author		  Aldo Topic   <aldo.topic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0			  aldo.topic@cloudsense.com
* 2019-06-10	  Initial version 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_OppBlockChanges extends CS_ProcessBase {

	@TestVisible 
	Map<Id, Opportunity> applicableObjects;

	@TestVisible
	Map<Id, Opportunity> oldOpps;

	private static final Set<String> notAllowedSOStatuses = 
			new Set<String>{'Pending Approvals',
							'Ready for Customer Approval', 'Pending Customer Approval', 'Pending Booking', 'Reserved', 
							'Booked', 'Pending Ad Ops Approval'};

	public CS_P_OppBlockChanges(Map<Id, Opportunity> oldOpps) {
		super(CS_ProcessDefinition.OPPORTUNITY_BLOCKCHANGES, 'CS_P_OppBlockChanges');

		applicableObjects = new Map<Id, Opportunity>();
		this.oldOpps = oldOpps;
	}

	public override void isRecordEligible(SObject obj) {  
		Opportunity newOpp = (Opportunity) obj;
		Opportunity oldOpp = null;
		if(oldOpps != null && oldOpps.get(newOpp.Id) != null){
			oldOpp = oldOpps.get(newOpp.Id);
		}
        
        System.debug('$$$'+oldOpp);
        System.debug('$$$'+newOpp);

		if(oldOpp != null && (oldOpp.AccountId != newOpp.AccountId || oldOpp.Media_Agency2__c != newOpp.Media_Agency2__c)) {
			applicableObjects.put(newOpp.Id, newOpp);
		} 

		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		if(!applicableObjects.isEmpty()) {

			List<csmso__Sales_Order__c> salesOrdersToBlock = 
			[
				SELECT	Id,
						Opportunity_Name__c,
						csmso__Opportunity__r.Id,
						csmso__Status__c
				FROM	csmso__Sales_Order__c 
				WHERE	csmso__Opportunity__r.Id IN :applicableObjects.keySet()
					AND csmso__Status__c IN :notAllowedSOStatuses
			];

			for(csmso__Sales_Order__c currSalesOrder : salesOrdersToBlock) {
				Opportunity currOpp = applicableObjects.get(currSalesOrder.csmso__Opportunity__r.Id);
				currOpp.addError('You can not change the Advertiser or Media Agency when a Sales Order is in an approval process. If you need to update this opportunity, recall your Sales Order.');
			}
		}
	}
}
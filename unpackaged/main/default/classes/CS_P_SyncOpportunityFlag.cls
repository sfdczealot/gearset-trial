/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update Synchronized_with_Opportunity__c flag on SO when Product Configuration changes.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            aldo.topic@cloudsense.com
* 2020-12-21      Initial version
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public with sharing class CS_P_SyncOpportunityFlag extends CS_ProcessBase {
	@TestVisible
	Map<Id, cscfga__Product_Configuration__c> applicableObjects;
public static Boolean isExecuted = false;
	public CS_P_SyncOpportunityFlag() {
		super(CS_ProcessDefinition.PC_SYNCOPPORTUNITYFLAG, 'CS_P_SyncOpportunityFlag');
		applicableObjects = new Map<Id, cscfga__Product_Configuration__c>();
       
	}

	public override void isRecordEligible(SObject obj) {
		cscfga__Product_Configuration__c newProductConfiguration = (cscfga__Product_Configuration__c) obj;
		applicableObjects.put(newProductConfiguration.Id, newProductConfiguration);
		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		Set<Id> salesOrderIds = new Set<Id>();
		for (cscfga__Product_Configuration__c productConfiguration : applicableObjects.values()) {
			salesOrderIds.add(productConfiguration.Sales_Order__c);
		}

		List<csmso__Sales_Order__c> salesOrdersToUpdate = [
				SELECT Id
				FROM csmso__Sales_Order__c
				WHERE Sold__c = FALSE
				AND (csmso__Status__c = 'In progress'
					OR csmso__Status__c = 'Rejected')
				AND Synchronized_with_Opportunity__c != FALSE
				AND Id IN :salesOrderIds
		];

		for (csmso__Sales_Order__c salesOrder : salesOrdersToUpdate) {
			salesOrder.Synchronized_with_Opportunity__c = false;
		}
      if(isexecuted==false)
            if (!salesOrdersToUpdate.isEmpty()) {
                update salesOrdersToUpdate;
              
            }
          isexecuted=true;
           	}
}
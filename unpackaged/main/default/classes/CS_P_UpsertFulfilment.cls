/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to upsert fulfilments
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sasa Marjancic   <sasa.marjancic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            sasa.marjancic@cloudsense.com
* 2018-10-22      Initial version 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_UpsertFulfilment extends CS_ProcessBase {   
	@TestVisible 
	Map<Id, csmso__Sales_Order__c> applicableObjects;
	
	@TestVisible
	Map<Id, csmso__Sales_Order__c> oldObjects;
	
	Map<String, String> SalesOrder_To_Fulfilment = new Map<String, String> {
		'Advertiser_Final__c' => 'csdf__Advertiser__c',
		'Agency_Final__c' => 'csdf__Agency__c',
		'Ad_Server_Trafficker__c' => 'csdf__Primary_Trafficker__c',
		'Ad_Server_Sales_Person__c' => 'csdf__Primary_Salesperson__c',
		'csmso__Purchase_Order_Number__c' => 'Purchase_Order_Number__c',
		'Migrated_Order_Type__c' => 'Migrated_Order_Type__c',
		'Migration_Source_Order_ID__c' => 'Migration_Source_Order_ID__c',
		'DFP_Team_Id__c' => 'DFP_Team_Id__c',
		'Ad_Server__c' => 'csdf__Ad_Server__c',
		'Proposal_Name__c' => 'csdf__Name__c',
		'Id' => 'Sales_Order__c',
		'Is_Programmatic__c' => 'csdf__Is_Programmatic__c',
        'Buyer__c' => 'csdf__Buyer__c',
		'CurrencyIsoCode' => 'CurrencyIsoCode',
		'Label_Code__c' => 'Labels__c'
		
	};

	Set<String> fieldsToUpdateOnlyOnce = new Set<String> {
			'Advertiser_Final__c',
			'Agency_Final__c'
	};

	public CS_P_UpsertFulfilment(Map<Id, csmso__Sales_Order__c> oldObjects) {
		super(CS_ProcessDefinition.SO_UPSERTFULFILMENT, 'CS_P_UpsertFulfilment');
		
		this.oldObjects = oldObjects;
		applicableObjects = new Map<Id, csmso__Sales_Order__c>();
	}
 
	public override void isRecordEligible(SObject obj) {
		csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
		csmso__Sales_Order__c oldSalesOrder = oldObjects != null ? (csmso__Sales_Order__c) oldObjects.get(newSalesOrder.Id) : null;

		if(oldSalesOrder == null) {
			applicableObjects.put(newSalesOrder.Id, newSalesOrder);
		}
		else {
			for(String fieldName : SalesOrder_To_Fulfilment.keySet()) {
				if(newSalesOrder.get(fieldName) != oldSalesOrder.get(fieldName)) {
					applicableObjects.put(newSalesOrder.Id, newSalesOrder);
					break;
				}
			}
		}

		this.runProcess = !applicableObjects.isEmpty() && !CS_ProcessExecution.wasProcessExecuted(CS_ProcessDefinition.SO_UPSERTFULFILMENT);
	}

	public override void logic() {
		Map<Id, csdf__Fulfilment__c> fulfilments = new Map<Id, csdf__Fulfilment__c>();
		for(csdf__Fulfilment__c f : [SELECT Id, Sales_Order__c, csdf__Ad_Server_Id__c
									 FROM csdf__Fulfilment__c
									 WHERE Sales_Order__c IN : applicableObjects.keySet()]) {
			fulfilments.put(f.Sales_Order__c, f);
		}
		
		List<csdf__Fulfilment__c> fulfimentToUpsert = new List<csdf__Fulfilment__c>();
		for(csmso__Sales_Order__c so : applicableObjects.values()) {
			csdf__Fulfilment__c fulfilment = fulfilments.containsKey(so.Id) ? fulfilments.get(so.Id) : (so.External_Order_Id__c != null ? null : new csdf__Fulfilment__c());
			
			if(fulfilment != null) {
				for(String fieldName : SalesOrder_To_Fulfilment.keySet()) {
					if(!fieldsToUpdateOnlyOnce.contains(fieldName) || String.isBlank(fulfilment.csdf__Ad_Server_Id__c)) {
						fulfilment.put(SalesOrder_To_Fulfilment.get(fieldName), so.get(fieldName));
					}
				}
				
				fulfilment.csdf__Name__c = String.isNotBlank(so.Proposal_Name__c) ? so.Proposal_Name__c : so.csmso__Advertiser__c + '_' + System.currentTimeMillis();
				
				fulfimentToUpsert.add(fulfilment);
			}
		}
		
        System.debug('##CS_P_UpsertFulfilment>fulfimentToUpsert>' + JSON.serializePretty(fulfimentToUpsert));
		upsert fulfimentToUpsert;
	}
}
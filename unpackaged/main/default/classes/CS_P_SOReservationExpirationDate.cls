/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update Reserve_Expiration_Date__c on Fulfilment Items and Product Configurations
* when Expiration_Date__c on SO changes.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            aldo.topic@cloudsense.com
* 2020-12-01      Initial version
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_SOReservationExpirationDate extends CS_ProcessBase {
	@TestVisible
	Map<Id, csmso__Sales_Order__c> applicableObjects;

	@TestVisible
	Map<Id, csmso__Sales_Order__c> oldObjects;

	public CS_P_SOReservationExpirationDate(Map<Id, csmso__Sales_Order__c> oldObjects) {
		super(CS_ProcessDefinition.SO_RESERVERVATION_EXPIRATION_DATE, 'CS_P_SOReservationExpirationDate');

		this.oldObjects = oldObjects;
		applicableObjects = new Map<Id, csmso__Sales_Order__c>();
	}

	public override void isRecordEligible(SObject obj) {
		csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
		csmso__Sales_Order__c oldSalesOrder = oldObjects != null ? (csmso__Sales_Order__c) oldObjects.get(newSalesOrder.Id) : null;

		if (oldSalesOrder != null
				&& oldSalesOrder.Expiration_Date__c != newSalesOrder.Expiration_Date__c) {
			applicableObjects.put(newSalesOrder.Id, newSalesOrder);
		}

		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		Map<Id, csmso__Sales_Order__c> idToSalesOrderMap = new Map<Id, csmso__Sales_Order__c>();
		Map<String, csmso__Sales_Order__c> soNameToSalesOrderMap = new Map<String, csmso__Sales_Order__c>();
		List<csdf__Fulfilment_Item__c> fulfilmentItemsToUpdate = new List<csdf__Fulfilment_Item__c>();
		List<cscfga__Product_Configuration__c> productConfigurationsToUpdate = new List<cscfga__Product_Configuration__c>();

		for (csmso__Sales_Order__c salesOrder : applicableObjects.values()) {
			soNameToSalesOrderMap.put(salesOrder.Name, salesOrder);
			idToSalesOrderMap.put(salesOrder.Id, salesOrder);
		}

		fulfilmentItemsToUpdate = [
				SELECT Id, Sales_Order__c, Reserve_Expiration_Date__c
				FROM csdf__Fulfilment_Item__c
				WHERE Sales_Order__c IN :soNameToSalesOrderMap.keySet()
		];

		productConfigurationsToUpdate = [
				SELECT Id, Sales_Order__c, Reserve_Expiration_Date__c
				FROM cscfga__Product_Configuration__c
				WHERE Sales_Order__c IN :idToSalesOrderMap.keySet()
		];

		for (csdf__Fulfilment_Item__c fulfilmentItem : fulfilmentItemsToUpdate) {
			fulfilmentItem.Reserve_Expiration_Date__c = soNameToSalesOrderMap.get(fulfilmentItem.Sales_Order__c).Expiration_Date__c;
		}

		for (cscfga__Product_Configuration__c productConfiguration : productConfigurationsToUpdate) {
			productConfiguration.Reserve_Expiration_Date__c = idToSalesOrderMap.get(productConfiguration.Sales_Order__c).Expiration_Date__c;
		}

		if (!fulfilmentItemsToUpdate.isEmpty()) {
			update fulfilmentItemsToUpdate;
		}

		if (!productConfigurationsToUpdate.isEmpty()) {
			update productConfigurationsToUpdate;
		}
	}
}
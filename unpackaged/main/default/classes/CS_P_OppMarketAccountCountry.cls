/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger to update Market on Opportunity from Account Country
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            name@email.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public class CS_P_OppMarketAccountCountry extends CS_ProcessBase {
	private static String COUNTRY_UNITED_STATES = 'United States';
	private static String PRODUCT_NODE_INTERNATIONAL = 'International';

	@TestVisible
	Map<Id, Opportunity> applicableObjects;

	@TestVisible
	Map<Id, Opportunity> oldObjects;

	public CS_P_OppMarketAccountCountry(Map<Id, Opportunity> oldObjects) {
		super(CS_ProcessDefinition.OPPORTUNITY_MARKETACCOUNTCOUNTRY, 'CS_P_OppMarketAccountCountry');

		this.oldObjects = oldObjects;
		applicableObjects = new Map<Id, Opportunity>();
	}

	public override void isRecordEligible(SObject obj) {
		Opportunity newOpp = (Opportunity) obj;
		Opportunity oldOpp = oldObjects != null ? (Opportunity) oldObjects.get(newOpp.Id) : null;

		if(oldOpp == null || (newOpp.Country__c != oldOpp.Country__c)) {
			applicableObjects.put(newOpp.Id, newOpp);
		}

		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		if (!applicableObjects.isEmpty()) {
			List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
			Map<String, csmso__Product_Node__c> productNodeNameToProductNode = new Map<String, csmso__Product_Node__c>();

			List<csmso__Product_Node__c> productNodes = [
					SELECT Id, Name
					FROM csmso__Product_Node__c
			];

			for (csmso__Product_Node__c productNode : productNodes) {
				productNodeNameToProductNode.put(productNode.Name, productNode);
			}

			for (Opportunity opportunity : applicableObjects.values()) {
				Opportunity opportunityToUpdate = new Opportunity(Id = opportunity.Id);
				if (productNodeNameToProductNode.get(PRODUCT_NODE_INTERNATIONAL) != null
						&& (String.isBlank(opportunity.Country__c)
							|| opportunity.Country__c == COUNTRY_UNITED_STATES)) {
					opportunityToUpdate.Market__c = productNodeNameToProductNode.get(PRODUCT_NODE_INTERNATIONAL).Id;
				} else if (productNodeNameToProductNode.get(opportunity.Country__c) != null) {
					opportunityToUpdate.Market__c = productNodeNameToProductNode.get(opportunity.Country__c).Id;
				}
				opportunitiesToUpdate.add(opportunityToUpdate);
			}

			update opportunitiesToUpdate;
		}
	}
}
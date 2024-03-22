/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger to update Opportunity Number Text on Opportunity from Opportunity Number
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            name@email.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public class CS_P_OppNumberText extends CS_ProcessBase {
	@TestVisible
	Map<Id, Opportunity> applicableObjects;

	public CS_P_OppNumberText() {
		super(CS_ProcessDefinition.OPPORTUNITY_MARKETACCOUNTCOUNTRY, 'CS_P_OppNumberText');
		applicableObjects = new Map<Id, Opportunity>();
	}

	public override void isRecordEligible(SObject obj) {
		Opportunity opportunity = (Opportunity) obj;
		applicableObjects.put(opportunity.Id, opportunity);

		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		if (!applicableObjects.isEmpty()) {
			List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

			for (Opportunity opportunity : applicableObjects.values()) {
				Opportunity opportunityToUpdate = new Opportunity(
						Id = opportunity.Id,
						Opportunity_Number_Text__c = opportunity.Opportunity_Number__c
				);
				opportunitiesToUpdate.add(opportunityToUpdate);
			}

			update opportunitiesToUpdate;
		}
	}
}
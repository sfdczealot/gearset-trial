/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update Agreement Status on Opportunity when Customer Approval is Approved/Rejected.
* Agreement Status when Approved => Signed via IO Link
* 						Rejected => Declined
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            aldo.topic@cloudsense.com
* 2020-10-13      Initial version
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_CustomerApprovalStatusChanged extends CS_ProcessBase {
	@TestVisible
	Map<Id, CSCAP__Customer_Approval__c> applicableObjects;

	@TestVisible
	Map<Id, CSCAP__Customer_Approval__c> oldObjects;

	public CS_P_CustomerApprovalStatusChanged(Map<Id, CSCAP__Customer_Approval__c> oldObjects) {
		super(CS_ProcessDefinition.CUSTOMERAPPROVAL_STATUSCHANGED, 'CS_P_CustomerApprovalStatusChanged');

		this.oldObjects = oldObjects;
		applicableObjects = new Map<Id, CSCAP__Customer_Approval__c>();
	}

	public override void isRecordEligible(SObject obj) {
		CSCAP__Customer_Approval__c newCustomerApproval = (CSCAP__Customer_Approval__c) obj;
		CSCAP__Customer_Approval__c oldCustomerApproval = oldObjects != null ? (CSCAP__Customer_Approval__c) oldObjects.get(newCustomerApproval.Id) : null;

		if (oldCustomerApproval != null
				&& (oldCustomerApproval.CSCAP__Approved_By_Customer__c != newCustomerApproval.CSCAP__Approved_By_Customer__c
					|| oldCustomerApproval.CSCAP__Rejected_By_Customer__c != newCustomerApproval.CSCAP__Rejected_By_Customer__c)) {
			applicableObjects.put(newCustomerApproval.Id, newCustomerApproval);
		}

		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		Set<Id> opportunityIds = new Set<Id>();
		Set<Opportunity> opportunitiesToUpdateSet = new Set<Opportunity>();

		for (CSCAP__Customer_Approval__c customerApproval : applicableObjects.values()) {
			opportunityIds.add(customerApproval.CSCAP__Opportunity__c);
		}

		Map<Id, Opportunity> opportunitiesByIds = new Map<Id, Opportunity>([
				SELECT 	Id,
						Agreement_Status__c,
						Agreement_Status_Date__c
				FROM Opportunity
				WHERE Id = :opportunityIds
		]);

		for (CSCAP__Customer_Approval__c customerApproval : applicableObjects.values()) {
			String agreementStatus;
			Datetime agreementStatusDate;

			if (customerApproval.CSCAP__Approved_By_Customer__c) {
				agreementStatus = 'Signed via Client IO Link';
				agreementStatusDate = Datetime.now();
			} else if(customerApproval.CSCAP__Rejected_By_Customer__c) {
				agreementStatus = 'Cancelled / Declined';
				agreementStatusDate = Datetime.now();
			}
			else {
				agreementStatus = opportunitiesByIds.get(customerApproval.CSCAP__Opportunity__c).Agreement_Status__c;
				agreementStatusDate = opportunitiesByIds.get(customerApproval.CSCAP__Opportunity__c).Agreement_Status_Date__c;
			}

			Opportunity opportunity = new Opportunity(
					Id = customerApproval.CSCAP__Opportunity__c,
					Agreement_Status__c = agreementStatus,
					Agreement_Status_Date__c = agreementStatusDate
			);
			opportunitiesToUpdateSet.add(opportunity);
		}

		if (!opportunitiesToUpdateSet.isEmpty()) {
			update new List<Opportunity>(opportunitiesToUpdateSet);
		}
	}
}
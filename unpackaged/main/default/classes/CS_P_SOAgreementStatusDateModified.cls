/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Update Sales Order after Opportunity has been sent out for signature
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sasa Marjancic
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_SOAgreementStatusDateModified extends CS_ProcessBase {

    @TestVisible
    Map<Id, Opportunity> applicableObjects;

    @TestVisible
    Map<Id, Opportunity> oldOpps;

    private List<csmso__Sales_Order__c> salesOrderToUpdate{get;set;}

    public CS_P_SOAgreementStatusDateModified(Map<Id, Opportunity> oldOpps) {
        super(CS_ProcessDefinition.SO_AGREEMENTSTATUSDATEUPDATED, 'CS_P_SOAgreementStatusDateModified');

        applicableObjects = new Map<Id, Opportunity>();
        this.oldOpps = oldOpps;
    }

    public override void isRecordEligible(SObject obj) {
        Opportunity newOpp = (Opportunity) obj;
        Opportunity oldOpp = oldOpps.get(newOpp.Id);

        if(oldOpp.Agreement_Status_Date__c != newOpp.Agreement_Status_Date__c && newOpp.SO_for_Customer_Approval__c != null && newOpp.Agreement_Status_Date__c != null) {
            applicableObjects.put(newOpp.Id, newOpp);
        }

        this.runProcess = !applicableObjects.isEmpty();
    }

    public override void logic() {
        if (!applicableObjects.isEmpty()) {
            CSPOFA.Events.emit('update', applicableObjects.keySet());
        }
    }
}
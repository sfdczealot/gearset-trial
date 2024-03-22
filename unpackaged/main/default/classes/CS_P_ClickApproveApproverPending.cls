/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update Agreement Status on Opportunity when ClickApprover Approver is inserted with
* status of Pending
* Agreement Status updated to  => Out For Signature
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Petar Mikic   <petar.mikic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            petar.mikic@cloudsense.com
* 2020-11-05      Initial version
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_ClickApproveApproverPending extends CS_ProcessBase {
    @TestVisible
    List<CSCAP__ClickApprove_Approver__c> applicableObjects;

    public CS_P_ClickApproveApproverPending() {
        super(CS_ProcessDefinition.CLICKAPPROVEAPPROVER_PENDING, 'CS_P_ClickApproveApproverPending');
        applicableObjects = new List<CSCAP__ClickApprove_Approver__c>();
    }

    public override void isRecordEligible(SObject obj) {
        CSCAP__ClickApprove_Approver__c newClickApproveApprover = (CSCAP__ClickApprove_Approver__c) obj;
        applicableObjects.add(newClickApproveApprover);

        this.runProcess = !applicableObjects.isEmpty();
    }

    public override void logic() {
        Map<Id, CSCAP__ClickApprove_Approver__c> approverByCustomerApprovalId = new Map<Id, CSCAP__ClickApprove_Approver__c>();

        for (CSCAP__ClickApprove_Approver__c clickApproveApprover : applicableObjects) {
            if (clickApproveApprover.CSCAP__Customer_Approval__c != null) {
                approverByCustomerApprovalId.put(clickApproveApprover.CSCAP__Customer_Approval__c, clickApproveApprover);
            }
        }

        Map<Id, CSCAP__Customer_Approval__c> customerApprovalMap = new Map<Id, CSCAP__Customer_Approval__c>([
                SELECT
                        Id, CSCAP__Opportunity__c
                FROM
                        CSCAP__Customer_Approval__c
                WHERE Id IN:approverByCustomerApprovalId.keySet()
        ]);

        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for (Id caId : customerApprovalMap.keySet()) {
            if (approverByCustomerApprovalId.get(caId).CSCAP__Approver_Approval_Status__c == 'Pending') {
                oppsToUpdate.add(new Opportunity(
                        Id = customerApprovalMap.get(caId).CSCAP__Opportunity__c,
                        Agreement_Status__c = 'Out For Signature',
                        Agreement_Status_Date__c = Datetime.now()
                ));
            }
        }

        update oppsToUpdate;
    }
}
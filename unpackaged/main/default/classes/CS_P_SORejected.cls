/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update handle logic when Sales Order is rejected
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sasa Marjancic   <sasa.marjancic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            sasa.marjancic@cloudsense.com
* 2019-02-22      Initial version 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_SORejected extends CS_ProcessBase {   
    @TestVisible 
    Map<Id, csmso__Sales_Order__c> applicableObjects;
    
    @TestVisible
    Map<Id, csmso__Sales_Order__c> oldObjects;

    public CS_P_SORejected(Map<Id, csmso__Sales_Order__c> oldObjects) {
        super(CS_ProcessDefinition.SO_REJECTED, 'CS_P_SORejected');
        
        this.oldObjects = oldObjects;
        applicableObjects = new Map<Id, csmso__Sales_Order__c>(); 
    }
 
    public override void isRecordEligible(SObject obj) {
        csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
        
        if( (newSalesOrder.csmso__Status__c == CS_const_SalesOrder.Status_Reserved || (newSalesOrder.csmso__Status__c == CS_const_SalesOrder.Status_PendingBooking && newSalesOrder.In_Retraction__c)) &&
            (newSalesOrder.Legal_Approval__c == CS_const_SalesOrder.ApprovalStatus_Rejected || newSalesOrder.Compliance_Approval__c == CS_const_SalesOrder.ApprovalStatus_Rejected ||
            newSalesOrder.Countersign_IO_Approval__c == CS_const_SalesOrder.ApprovalStatus_Rejected)) {
            applicableObjects.put(newSalesOrder.Id, newSalesOrder);
        }
        if( (newSalesOrder.csmso__Status__c == CS_const_SalesOrder.Status_PendingLegalApproval || newSalesOrder.csmso__Status__c == CS_const_SalesOrder.Status_PendingCountersignIOApproval
                || newSalesOrder.csmso__Status__c == CS_const_SalesOrder.Status_PendingComplianceApproval) &&
                (newSalesOrder.Legal_Approval__c == CS_const_SalesOrder.ApprovalStatus_Rejected || newSalesOrder.Compliance_Approval__c == CS_const_SalesOrder.ApprovalStatus_Rejected ||
                        newSalesOrder.Countersign_IO_Approval__c == CS_const_SalesOrder.ApprovalStatus_Rejected)) {
            applicableObjects.put(newSalesOrder.Id, newSalesOrder);
        }

        this.runProcess = !applicableObjects.isEmpty();
    }

    public override void logic() {  
        for(csmso__Sales_Order__c salesOrder : applicableObjects.values()) {
            salesOrder.csmso__Status__c = CS_const_SalesOrder.Status_Rejected;
            if(!String.isBlank(salesOrder.Comments__c)) {
                salesOrder.Rejection_Count__c = salesOrder.Rejection_Count__c + 1;
            }
        }
    }
}
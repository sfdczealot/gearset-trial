/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update handle logic when Sales Order is ready to be booked
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sasa Marjancic   <sasa.marjancic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            sasa.marjancic@cloudsense.com
* 2019-02-22      Initial version
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_SOReadyToBook extends CS_ProcessBase {   
    @TestVisible 
    Map<Id, csmso__Sales_Order__c> applicableObjects;
    
    @TestVisible
    Map<Id, csmso__Sales_Order__c> oldObjects;

    public CS_P_SOReadyToBook(Map<Id, csmso__Sales_Order__c> oldObjects) {
        super(CS_ProcessDefinition.SO_READYTOBOOK, 'CS_P_SOReadyToBook');
        
        this.oldObjects = oldObjects;
        applicableObjects = new Map<Id, csmso__Sales_Order__c>(); 
    }
 
    public override void isRecordEligible(SObject obj) {
        csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
        csmso__Sales_Order__c oldSalesOrder = (csmso__Sales_Order__c) oldObjects.get(newSalesOrder.Id);
        
        if(newSalesOrder.csmso__Status__c == CS_const_SalesOrder.Status_Reserved && newSalesOrder.Legal_Check__c == CS_const_SalesOrder.ApprovalStatus_Approved
           && newSalesOrder.Compliance_Check__c == CS_const_SalesOrder.ApprovalStatus_Approved && newSalesOrder.Counter_Sign_IO__c == CS_const_SalesOrder.ApprovalStatus_Approved) {
            applicableObjects.put(newSalesOrder.Id, newSalesOrder);
        }

        this.runProcess = !applicableObjects.isEmpty();
    }

    public override void logic() {
        for(csmso__Sales_Order__c salesOrder : applicableObjects.values()) {
            salesOrder.csmso__Status__c = CS_const_SalesOrder.Status_Booked;
        }
    }
}
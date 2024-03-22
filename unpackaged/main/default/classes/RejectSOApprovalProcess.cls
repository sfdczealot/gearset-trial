public class RejectSOApprovalProcess extends CS_ProcessBase {
    
    @TestVisible 
    Map<Id, csmso__Sales_Order__c> applicableObjects;
    
    
    public RejectSOApprovalProcess(Map<Id, csmso__Sales_Order__c> newObjects) {
        super(CS_ProcessDefinition.FULFILMENTITEM_UPDATECOMPLETEDFULFILMENT, 'SO_REJECTED');
        applicableObjects = new Map<Id, csmso__Sales_Order__c>(); 
    }
    public override void isRecordEligible(SObject obj) {
        csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
        
        if( newSalesOrder.csmso__Status__c == 'Rejected') {
            applicableObjects.put(newSalesOrder.Id, newSalesOrder);
        }
        
        this.runProcess = !applicableObjects.isEmpty();
    }
    public override void logic() {   
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.status='Pending' and ProcessInstance.TargetObjectId in :applicableObjects.keySet()
        ];
        
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem workItem : workItems){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);
           
            req.setAction('Removed');
            req.setComments('Inventory released');
            requests.add(req);
        }
        Approval.ProcessResult[] processResults = Approval.process(requests);
        
    }
}
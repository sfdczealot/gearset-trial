/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update time SO spent in specific Approval Type.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            aldo.topic@cloudsense.com
* 2019-06-07      Initial version
*
* v2.0            aldo.topic@cloudsense.com
* 2020-02-28
*                 Using Approval Type to determine where to put Pending Approval Time
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_SOApprovalCheckCalculateTime extends CS_ProcessBase {
    @TestVisible
    Map<Id, csmso__Sales_Order__c> applicableObjects;

    @TestVisible
    Map<Id, csmso__Sales_Order__c> oldObjects;

    private static final Set<String> APPLICABLE_SO_STATUSES = new Set<String> {
            CS_const_SalesOrder.Status_PendingApprovals,
            CS_const_SalesOrder.Status_PendingCustomerApproval,
            CS_const_SalesOrder.Status_PendingLegalApproval,
            CS_const_SalesOrder.Status_PendingCountersignIOApproval,
            CS_const_SalesOrder.Status_PendingComplianceApproval
    };

    public CS_P_SOApprovalCheckCalculateTime(Map<Id, csmso__Sales_Order__c> oldObjects) {
        super(CS_ProcessDefinition.SO_APPROVALCHECKCALCULATETIME, 'CS_P_SOApprovalCheckCalculateTime');

        this.oldObjects = oldObjects;
        applicableObjects = new Map<Id, csmso__Sales_Order__c>();
    }

    public override void isRecordEligible(SObject obj) {
        csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
        csmso__Sales_Order__c oldSalesOrder = (csmso__Sales_Order__c) oldObjects.get(newSalesOrder.Id);

        if(oldSalesOrder.csmso__Status__c != newSalesOrder.csmso__Status__c
                && (APPLICABLE_SO_STATUSES.contains(oldSalesOrder.csmso__Status__c)
                    || APPLICABLE_SO_STATUSES.contains(oldSalesOrder.csmso__Status__c))) {
            applicableObjects.put(newSalesOrder.Id, newSalesOrder);
        }

        this.runProcess = !applicableObjects.isEmpty();
    }

    public override void logic() {
        if(applicableObjects.values() != null) {
            Map<String, String> approvalProcessToTimeField = new Map<String, String>();
            Map<Id, List<ProcessInstance>> salesOrderToProcessInstances = new Map<Id, List<ProcessInstance>>();

            List<Approval_Type__mdt> approvalTypesList = [
                SELECT Id, Approval_Process__c, Pending_Approval_Time__c
                    FROM Approval_Type__mdt
                    WHERE Pending_Approval_Time__c != ''
            ];

            for (Approval_Type__mdt currApprovalType : approvalTypesList) {
                approvalProcessToTimeField.put(currApprovalType.Approval_Process__c, currApprovalType.Pending_Approval_Time__c);
            }

            List<ProcessInstance> processInstanceList = [
                SELECT Id, TargetObjectId, ElapsedTimeInMinutes,ElapsedTimeInHours, ProcessDefinition.DeveloperName
                    FROM ProcessInstance
                    WHERE TargetObjectId IN :applicableObjects.values()
            ];

            for(ProcessInstance processInstance : processInstanceList) {
                if(salesOrderToProcessInstances.get(processInstance.TargetObjectId) == null) {
                    salesOrderToProcessInstances.put(processInstance.TargetObjectId, new List<ProcessInstance>());
                }
                salesOrderToProcessInstances.get(processInstance.TargetObjectId).add(processInstance);
            }

            for (csmso__Sales_Order__c salesOrder : applicableObjects.values()) {
                Map<String, Decimal> approvalStepTimeMap = new Map<String, Decimal>();

                if(salesOrderToProcessInstances.containsKey(salesOrder.Id)) {
                    for (ProcessInstance processInstance : salesOrderToProcessInstances.get(salesOrder.Id)) {
                        if (approvalStepTimeMap.get(processInstance.ProcessDefinition.DeveloperName) == null) {
                            approvalStepTimeMap.put(processInstance.ProcessDefinition.DeveloperName, 0);
                        }
                        Decimal totalTime = approvalStepTimeMap.get(processInstance.ProcessDefinition.DeveloperName) + processInstance.ElapsedTimeInHours;
                        approvalStepTimeMap.put(processInstance.ProcessDefinition.DeveloperName, totalTime);
                    }

                    for (String approvalProcess : approvalProcessToTimeField.keySet()) {
                        if (approvalStepTimeMap.get(approvalProcess) != null) {
                            salesOrder.put(approvalProcessToTimeField.get(approvalProcess), approvalStepTimeMap.get(approvalProcess));
                        }
                    }
                }
            }
        }
    }
}
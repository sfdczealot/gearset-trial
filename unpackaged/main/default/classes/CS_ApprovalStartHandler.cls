/**
 * Created by jameshladek on 3/20/20.
 */

global with sharing class CS_ApprovalStartHandler extends CS_StepHandlerBase {
    global CS_ApprovalStartHandler() {
        this.action = 'Approval Start';
    }

    global override CSPOFA__Orchestration_Step__c doWork(Object params) {
        Map<String, Object> paramsType = (Map<String, Object>) params;

        if(!isInApproval((Id) paramsType.get('salesOrderId'))) {
            CS_ApprovalService.submitForApprovals((Id) paramsType.get('salesOrderId'));
        }

        CSPOFA__Orchestration_Step__c step = (CSPOFA__Orchestration_Step__c) paramsType.get('step');
        setStepProgress(step, 'Sales Order submitted for approval');

        return step;
    }

    public Boolean isInApproval(Id salesOrderId) {
        List<ProcessInstance> processInstances = [SELECT Id FROM ProcessInstance
                                                    WHERE (Status = 'Submitted' OR Status = 'Pending') AND TargetObjectId = :salesOrderId];
        return !processInstances.isEmpty();
    }
}
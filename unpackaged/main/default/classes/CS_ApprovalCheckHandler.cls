/**
 * Created by jameshladek on 3/20/20.
 */

global with sharing class CS_ApprovalCheckHandler extends CS_StepHandlerBase {
    global CS_ApprovalCheckHandler() {
        this.action = 'Approval Check';
    }

    global override CSPOFA__Orchestration_Step__c doWork(Object params) {
            Map<String, Object> paramsType = (Map<String, Object>) params;

            csmso__Sales_Order__c salesOrder = CS_utl_SalesOrder.getSalesOrder((Id) paramsType.get('salesOrderId'));
            CS_ApprovalService csApproval = new CS_ApprovalService();

            salesOrder = csApproval.checkApprovals(salesOrder);
            update salesOrder;

            CSPOFA__Orchestration_Step__c step = (CSPOFA__Orchestration_Step__c) paramsType.get('step');
            setStepProgress(step, 'Sales Order checked for approval.');

            return step;
    }
}
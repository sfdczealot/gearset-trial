/**
 * Created by jameshladek on 3/19/20.
 */

global with sharing class CS_SnapshotHandler extends CS_StepHandlerBase {
    global CS_SnapshotHandler() {
        this.action = 'Snapshot Create';
    }

    private Map<Id, cscfga__Product_Configuration__c> getProductConfigurations(Id soId){
        return new Map<Id, cscfga__Product_Configuration__c>([SELECT Id FROM cscfga__Product_Configuration__c WHERE Sales_Order__c = :soId]);
    }

    global override CSPOFA__Orchestration_Step__c doWork(Object params) {
        Map<String, Object> paramsType = (Map<String, Object>) params;

        CSPOFA__Orchestration_Step__c step = (CSPOFA__Orchestration_Step__c) paramsType.get('step');
        String snapshotType = step.Name;
        Id salesOrderId = (Id) paramsType.get('salesOrderId');
        if(snapshotType == 'Book Snapshot') {
            CS_RetractionService.generateScreenshot(salesOrderId, getProductConfigurations(salesOrderId), CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);
        }
        else if(snapshotType == 'Submit Snapshot') {
            CS_RetractionService.generateScreenshot(salesOrderId, getProductConfigurations(salesOrderId), CS_const_SalesOrder.FILE_NAME_PROPOSAL_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_PROPOSAL_SCREENSHOT);
        }

        return setStepProgress(step, 'Waiting For Feedback', 'Waiting for ' + step.Name, (Id) paramsType.get('salesOrderId'));
    }
}
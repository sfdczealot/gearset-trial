global class CS_FulfilmentUpsertHandler extends CS_StepHandlerBase {
    global CS_FulfilmentUpsertHandler() {
        this.action = 'CS_FulfilmentUpsertHandler';
    }

    global override CSPOFA__Orchestration_Step__c doWork(Object params) {
        Map<String, Object> paramsType = (Map<String, Object>) params;

        CS_FulfilmentService.removeInvalidFulfilmentItems((Id) paramsType.get('salesOrderId'));
        CSPOFA__Orchestration_Step__c step = (CSPOFA__Orchestration_Step__c) paramsType.get('step');

        CS_FulfilmentUpsertWorker worker = new CS_FulfilmentUpsertWorker();
        List<csdf__Fulfilment_Item__c> fulfilmentItems = worker.createFulfilmentItems(paramsType);
        if (fulfilmentItems != null) {
            setStepProgress(step, 'Fulfilment Items created.');
        }
        else {
            setStepProgress(step, 'Waiting For Feedback', 'Creating Fulfilment Items.', (Id) paramsType.get('salesOrderId'));
        }

        return step;
    }
}
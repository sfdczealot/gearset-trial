/**
 * Created by jameshladek on 3/10/20.
 */

global class CS_BillingHandler extends CS_StepHandlerBase {
    global CS_BillingHandler() {
        this.action = 'Billing Handler';
    }

    global override CSPOFA__Orchestration_Step__c doWork(Object params) {
        Map<String, Object> paramsType = (Map<String, Object>) params;

        CSPOFA__Orchestration_Step__c step = (CSPOFA__Orchestration_Step__c) paramsType.get('step');
        CS_BillingHandlerWorker worker = new CS_BillingHandlerWorker(params);
        System.enqueueJob(worker);

        return setStepProgress(step, 'Waiting For Feedback', 'Waiting for ' + step.Name, (Id) paramsType.get('salesOrderId'));
    }

    public class CS_BillingHandlerWorker extends CS_QueueableWorker {
        public CS_BillingHandlerWorker(Object params) {
            super('CS_BillingHandlerWorker', params);
        }

        public override void doWork() {
            Map<String, Object> paramsType = (Map<String, Object>) this.params;

            CS_ScheduleService.generateSchedules(new Set<Id>{(Id) paramsType.get('salesOrderId')}, null);
        }
    }
}
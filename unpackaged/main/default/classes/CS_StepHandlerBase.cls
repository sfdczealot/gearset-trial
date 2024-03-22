/**
 * Created by sasa.marjancic on 6.5.2020..
 */

global abstract class CS_StepHandlerBase implements CSPOFA.ExecutionHandler, CSPOFA.Contextual {
    public static final String ValidationReasonVariable = 'ValidationReason';

    public static final String ValidationReason_StartDate = 'Start Date is in the Past';
    public static final String ValidationReason_BookedSo = 'SO already Booked';

    protected CSPOFA.OrchestrationContext context;

    global void setContext(CSPOFA.OrchestrationContext context) {
        this.context = context;
    }

    public String action {get; set;}

    global List<SObject> process(List<SObject> data) {
        List<CSPOFA__Orchestration_Step__c> steps = (List<CSPOFA__Orchestration_Step__c>) data;
        List<SObject> results = new List<SObject>();
        for (CSPOFA__Orchestration_Step__c step : steps) {
            try {
                results.add(doWork(new Map<String, Object>{
                        'salesOrderId' => (Id) step.Sales_Order__c,
                        'action' => String.isNotBlank(this.action) ? this.action : step.Orchestration_Process_Name__c,
                        'step' => step
                }));
            }
            catch(Exception e) {
                setStepProgress(step, step.CSPOFA__Execute_Count__c > 4 ? 'Error' : step.CSPOFA__Status__c, e.getMessage());
            }
        }

        return results;
    }

    protected CSPOFA__Orchestration_Step__c setStepProgress(CSPOFA__Orchestration_Step__c step, String message) {
        return this.setStepProgress(step, 'Complete', message, null);
    }

    protected CSPOFA__Orchestration_Step__c setStepProgress(CSPOFA__Orchestration_Step__c step, String status, String message) {
        return this.setStepProgress(step, status, message, null);
    }

    protected CSPOFA__Orchestration_Step__c setStepProgress(CSPOFA__Orchestration_Step__c step, String status, String message, Id externalId) {
        step.CSPOFA__Status__c = status;
        step.CSPOFA__Message__c = message;
        step.CSPOFA__Completed_Date__c = status == 'Complete' ? Date.today() : null;
        step.CSPOFA__Execute_Count__c = step.CSPOFA__Execute_Count__c != null ? step.CSPOFA__Execute_Count__c + 1 : 1;
        step.CSPOFA__External_Id__c = externalId;
        return step;
    }

    global abstract CSPOFA__Orchestration_Step__c doWork(Object params);
}
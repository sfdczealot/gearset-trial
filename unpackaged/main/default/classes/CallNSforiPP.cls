global class CallNSforiPP  implements CSPOFA.ExecutionHandler,CSPOFA.Calloutable{
    private List<Object> calloutResults;
    global CallNSforiPP() {
    }
    public Boolean performCallouts(List<SObject> data) {
        List<CSPOFA__Orchestration_Step__c> stepList = (List<CSPOFA__Orchestration_Step__c>)data;
        System.debug('@@@SOID'+stepList);
        Boolean calloutsPerformed = false;
        String salesOrderId = stepList[0].Sales_Order__c;
        System.debug('@@@SOID'+salesOrderId);
      csmso__Sales_Order__c salesorder = [select id,Product_Subsidiary__c from csmso__Sales_Order__c
                                          where id =: salesOrderId];
         System.debug('###SO'+salesorder);
        if(salesorder.Product_Subsidiary__c == 'iPP'){
            BillingScheduleUpdate.callNetsuite(salesOrderId);
        }
        calloutsPerformed=true;
        return calloutsPerformed;
    }
    global List<SObject> process(List<SObject> data) {
        List<sObject> result = new List<sObject>();
        
        List<CSPOFA__Orchestration_Step__c> stepList =
            (List<CSPOFA__Orchestration_Step__c>)data;
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            step.CSPOFA__Status__c = 'Complete';
            step.CSPOFA__Completed_Date__c = Date.today();
            step.CSPOFA__Message__c = 'Custom step succeeded';
            result.add(step);
        }
        
        return result;
    }
}
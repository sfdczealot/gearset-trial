global class DeveloperListingHandler  implements CSPOFA.ExecutionHandler,CSPOFA.Calloutable{
    private List<Object> calloutResults;

    public Boolean performCallouts(List<SObject> data) {
        List<CSPOFA__Orchestration_Step__c> stepList = (List<CSPOFA__Orchestration_Step__c>)data;
        
        Boolean calloutsPerformed = false;
        system.debug(stepList);
        if(stepList[0].Orchestration_Process_Name__c == 'check Availability'){
            DeveloperListingInventoriesCheck.checkAvails(stepList[0].Sales_Order__c);
        }
        if(stepList[0].Orchestration_Process_Name__c == 'Reserve Inventory'){
            DeveloperListingInventoriesCheck.reserveInventory(stepList[0].Sales_Order__c);
        }
        if(stepList[0].Orchestration_Process_Name__c == 'inventory release'){
            DeveloperListingInventoriesCheck.ReleaseInventory(stepList[0].Sales_Order__c);
        }
        if(stepList[0].Orchestration_Process_Name__c == 'Status Push to GAM'){
            DeveloperListingInventoriesCheck.bookInventory(stepList[0].Sales_Order__c);
        }
        if(stepList[0].Orchestration_Process_Name__c == 'Push to GAM'){
            DeveloperListingInventoriesCheck.bookRetractedInventory(stepList[0].Sales_Order__c);
        }
        calloutsPerformed=true;
        
        return calloutsPerformed;
        }


    global DeveloperListingHandler() {
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
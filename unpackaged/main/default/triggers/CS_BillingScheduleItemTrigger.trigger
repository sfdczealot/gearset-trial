trigger CS_BillingScheduleItemTrigger on CS_Billing_Schedule_Item__c (before insert, before update) {
    if(CS_utl_user.isTriggerActiveForMe()) {
            
        CS_ProcessDispatcher dispatcher = new CS_ProcessDispatcher();
        
        if(Trigger.isBefore) {
            if(Trigger.isUpdate) {
                dispatcher.addProcesses(new List<CS_ProcessBase> {
					new CS_P_BillingScheduleItemCalc()
                });
            }
            
            if(Trigger.isInsert) {
            	dispatcher.addProcesses(new List<CS_ProcessBase> {
                    new CS_P_BillingScheduleItemCalc()
                });
            }
        }
        
        dispatcher.dispatch();
    }    
}
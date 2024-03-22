trigger CS_RevenueScheduleItemTrigger on CS_Revenue_Schedule_Item__c (before insert, before update, after update) {
    if(CS_utl_user.isTriggerActiveForMe()) {
            
        CS_ProcessDispatcher dispatcher = new CS_ProcessDispatcher();
        
        if(Trigger.isBefore) {
            if(Trigger.isUpdate) {
                dispatcher.addProcesses(new List<CS_ProcessBase> {
					new CS_P_RevenueScheduleItemCalc()
                });
            }
            
            if(Trigger.isInsert) {
            	dispatcher.addProcesses(new List<CS_ProcessBase> {
                    new CS_P_RevenueScheduleItemCalc()
                });
            }
        }

        if(Trigger.isAfter) {
            if(Trigger.isUpdate) {
                dispatcher.addProcesses(new List<CS_ProcessBase> {
                    new CS_P_UpdateOpenQuantityRevenue(Trigger.oldMap)
                });
            }   
        }
        
        dispatcher.dispatch();
    }    
}
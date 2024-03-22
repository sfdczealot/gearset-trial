trigger CS_FulfilmentItemTrigger on csdf__Fulfilment_Item__c (
    after insert,
    after undelete,
    after update,
    before insert,
    before update) {
    
    // Check the Custom settings to see if we are running triggers
    if (!CS_TriggerHandler.GetTriggersEnabled())
        return;
    
    if(CS_utl_user.isTriggerActiveForMe()) {
        CS_TriggerHandler.execute(new CS_FulfilmentItemDelegate());

        CS_ProcessDispatcher dispatcher = new CS_ProcessDispatcher();

        if (Trigger.isAfter) {
            if (Trigger.isUpdate) {
                dispatcher.addProcesses(new List<CS_ProcessBase>{
                        new CS_P_FIToUpdateCompletedFulfilment(Trigger.oldMap)
                });
            }
        }

        dispatcher.dispatch();
    }
}
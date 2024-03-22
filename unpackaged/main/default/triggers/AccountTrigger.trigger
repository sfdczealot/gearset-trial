trigger AccountTrigger on Account (before update, before insert, after insert, after update) {

    // Check the Custom settings to see if we are running triggers
    if (!CS_TriggerHandler.GetTriggersEnabled() || CS_utl_user.isDeactivatedForDataMigration)
        return;

    // DISPATCHER TRIGGER PATTERN
    if(CS_utl_user.isTriggerActiveForMe()) {
        CS_ProcessDispatcher dispatcher = new CS_ProcessDispatcher();

        if (Trigger.isBefore) {
            if (Trigger.isUpdate) {
                dispatcher.addProcesses(new List<CS_ProcessBase>{
                    new CS_P_AccountStatus(Trigger.oldMap)
                });
            }

            dispatcher.dispatch();
        }
    }
}
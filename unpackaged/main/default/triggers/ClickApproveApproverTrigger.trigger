/**
 * Created by petarmikic on 5/11/20.
 */

trigger ClickApproveApproverTrigger on CSCAP__ClickApprove_Approver__c (after insert) {
    if (!CS_TriggerHandler.GetTriggersEnabled() || CS_utl_User.isDeactivatedForDataMigration) {
        return;
    }

    if(CS_utl_User.isTriggerActiveForMe()) {
        if (Trigger.isAfter && Trigger.isInsert ) {

            CS_ProcessDispatcher dispatcher = new CS_ProcessDispatcher();

                dispatcher.addProcesses(new List<CS_ProcessBase>{
                        new CS_P_ClickApproveApproverPending()
                });


            dispatcher.dispatch();
        }
    }
}
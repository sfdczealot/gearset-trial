/**
*─────────────────────────────────────────────────────────────────────────────────────────────────┐
*Trigger on the Custom Report Execution object
*──────────────────────────────────────────────────────────────────────────────────────────────────
*@author    Osvaldo Parra   <osvaldo.parrarascon@cloudsense.com>
*──────────────────────────────────────────────────────────────────────────────────────────────────
*@changes
*─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
trigger CS_CustomReportExecutionTrigger on csdf__Custom_Report_Execution__c (
    after delete,
    after insert,
    after undelete,
    after update,
    before delete,
    before insert,
    before update) {
    
    // Check the Custom settings to see if we are running triggers
    if (!CS_TriggerHandler.GetTriggersEnabled())
        return;
    
    if(CS_utl_user.isTriggerActiveForMe()) {         
        CS_ProcessDispatcher dispatcher = new CS_ProcessDispatcher();

        if(Trigger.isBefore) {
            if(Trigger.isInsert) {

            }

            if(Trigger.isUpdate) {

            }
        }

        if(Trigger.isAfter) {
            if(Trigger.isInsert) {

            }

            if(Trigger.isUpdate) {
                dispatcher.addProcesses(new List<CS_ProcessBase> {
                    new CS_P_CustomReportStatusFilter(Trigger.oldMap)
                });
            }
        }
        dispatcher.dispatch();
    }
    
}
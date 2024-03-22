trigger CS_ProductConfigurationTrigger on cscfga__Product_Configuration__c (
        after delete,
        after insert,
        after undelete,
        after update,
        before delete,
        before insert,
        before update) {
            
    // Check the Custom settings to see if we are running triggers
    if (!CS_TriggerHandler.GetTriggersEnabled()) {
        return;
    }

    if (CS_utl_User.isTriggerActiveForMe()) {
        CS_ProcessDispatcher dispatcher = new CS_ProcessDispatcher();

        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                dispatcher.addProcesses(new List<CS_ProcessBase>{
                    new CS_P_OfferTriggerMonitor(false),
                    new CS_P_StatusUpdate(null)                    
                    //new CS_P_UnLinkFulfilmentItemOnClone()
                });
            }
            if (Trigger.isUpdate) {
                dispatcher.addProcesses(new List<CS_ProcessBase>{
                    new CS_P_StatusUpdate(Trigger.oldMap),
                    new CS_P_PCCurrencyIsoCodeUpdate(Trigger.oldMap),
                    new updateSOApprovalCheckbox(Trigger.newMap, Trigger.oldMap)
                    //new CS_P_UnLinkFulfilmentItemOnClone()
                });
            }
            if (Trigger.isDelete) {
                dispatcher.addProcesses(new List<CS_ProcessBase>{
                    new CS_P_OnConfigRemove(),
                      new updateSOApprovalCheckbox( Trigger.oldMap,null)
                });
            }
        }

        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                dispatcher.addProcesses(new List<CS_ProcessBase>{
                    new SOLIUpdate(trigger.new),
                    new CS_P_SyncOpportunityFlag()
                    //new CS_P_LinkFulfilmentItem(null)
                });
            }

            if (Trigger.isUpdate) {
                dispatcher.addProcesses(new List<CS_ProcessBase>{
                    //new CS_P_LinkFulfilmentItem(Trigger.oldMap),
                    new CS_P_SOLIRollup(false),
                    new SOLIUpdate(trigger.new),
                    new CS_P_SyncOpportunityFlag()
                });
                CS_P_SyncOpportunityFlag.isExecuted=true;
            }

            if (Trigger.isDelete) {
                dispatcher.addProcesses(new List<CS_ProcessBase>{
                    new CS_P_SOLIRollup(true),
                    new SOLIUpdate(trigger.old),
                    new CS_P_SyncOpportunityFlag()
                });
            }
        }

        dispatcher.dispatch();
    }
}
trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete) {
    // Check the Custom settings to see if we are running triggers
    if (!CS_TriggerHandler.GetTriggersEnabled() || CS_utl_User.isDeactivatedForDataMigration) {
        return;
    }
public Boolean isExecutedAfterUpdate = false;
    public Boolean isExecutedBeforeUpdate = false;
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)) {

        CS_ProcessDispatcher dispatcher = new CS_ProcessDispatcher();
        if (Trigger.isUpdate) {
            if(!isExecutedAfterUpdate){
            dispatcher.addProcesses(new List<CS_ProcessBase>{
                    new CS_P_adAgencyChange(Trigger.oldMap),
                    new CS_P_OpportunityNameChange(Trigger.oldMap),
                    new CS_P_SOAgreementStatusDateModified(Trigger.oldMap),
                    new CS_P_OppPrimarySOChange(Trigger.oldMap),
                    new CS_P_OppPaymentTermsChange(Trigger.oldMap),
                    new CS_P_OppBookingContactChange(Trigger.oldMap),
                    new CS_P_OppPrimaryTraffickerChange(Trigger.oldMap),
                    new CS_P_OppPrimarySalespersonChange(Trigger.oldMap),
                    new CS_P_OppMarketAccountCountry(Trigger.oldMap)
            });
               
            }
             isExecutedAfterUpdate= true;
        }

        if (Trigger.isInsert) {
            dispatcher.addProcesses(new List<CS_ProcessBase>{
                    new CS_P_OppMarketAccountCountry(Trigger.oldMap),
                    new CS_P_OppNumberText()
            });
        }

        dispatcher.dispatch();
    }

    // Fetch Legal Approval Status from Master Budget Plan
    if (Trigger.isBefore) {

        CS_ProcessDispatcher dispatcher = new CS_ProcessDispatcher();

        if (Trigger.isInsert) {
            dispatcher.addProcesses(new List<CS_ProcessBase>{
                    new CS_P_OppBlockChanges(Trigger.oldMap)
            });
             if(!RestrictOppAccountToChange.isExecuted){
                dispatcher.addProcesses(new List<CS_ProcessBase>{
                        new RestrictOppAccountToChange(null,Trigger.newMap)
                        });
                RestrictOppAccountToChange.isExecuted = true;
            }
        }
        if ( Trigger.isUpdate) {
            if(!isExecutedBeforeUpdate){
            if(!RestrictOppAccountToChange.isExecuted){
                dispatcher.addProcesses(new List<CS_ProcessBase>{
                    new CS_P_OppBlockChanges(Trigger.oldMap),
                        new RestrictOppAccountToChange(Trigger.oldMap,Trigger.newMap)
                        });
               
            }
                 RestrictOppAccountToChange.isExecuted = true;
        }
           isExecutedBeforeUpdate=true;
        }
         
        dispatcher.dispatch();
    }
}
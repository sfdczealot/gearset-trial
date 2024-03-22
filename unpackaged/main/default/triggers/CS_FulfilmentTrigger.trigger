trigger CS_FulfilmentTrigger on csdf__Fulfilment__c (
    after insert,
    after undelete,
    after update,
    before insert,
    before update) {
    
    // Check the Custom settings to see if we are running triggers
    if (!CS_TriggerHandler.GetTriggersEnabled())
        return;
    
    if(CS_utl_user.isTriggerActiveForMe()) {
        if(Trigger.isAfter && Trigger.IsUpdate){
          FulfilmentApprovalStatus.ExtensionApprovalStatus(trigger.NewMap,trigger.OldMap);       
        }
        
    }
}
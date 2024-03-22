// Test Class: Test_PGEntitlementPromoTriggerHandler
trigger PGEntitlementPromoTrigger on Entitlement_Promotion__c (before insert,after insert,
                                                               before update,after update,
                                                               before delete,after delete,
                                                               after undelete) {
    boolean isEnabled = true;
    //Check trigger execute
    Trigger_Execute__c TE = Trigger_Execute__c.getValues('PGEntitlementPromoTrigger');
    isEnabled = TE.Enable_del__c;
    if(isEnabled)
    {
        TriggerDispatcher.run(new PGEntitlementPromoTriggerHandler(), 'PGEntitlementPromoTrigger');
    }
}
trigger PGPaymentTrigger on Payment__c (before insert, before update) {
    
    boolean isEnabled = true;
    
    //Check trigger execute
    Trigger_Execute__c TE = Trigger_Execute__c.getValues('PGPaymentTrigger');
    isEnabled = TE.Enable_del__c;
    
    if(isEnabled) {
        TriggerDispatcher.run(new PGPaymentTriggerHandler(), 'PGPaymentTrigger');
    }
}
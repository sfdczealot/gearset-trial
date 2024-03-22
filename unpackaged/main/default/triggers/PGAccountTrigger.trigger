trigger PGAccountTrigger on Account (after insert, after update, before insert, before update) {
    
    boolean isEnabled = true; 
     
    //Check trigger execute
    
    Trigger_Execute__c TE = Trigger_Execute__c.getValues('PGAccountTrigger');
    isEnabled = TE.Enable_del__c;
    
    if(isEnabled)
    {
        TriggerDispatcher.run(new PGAccountTriggerHandler(), 'PGAccountTrigger');
    }
}
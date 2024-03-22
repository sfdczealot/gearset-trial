trigger PGLSDUpdateTrigger on LSD_Update__c (after insert,after update, before insert, before update, before delete) {
  boolean isEnabled = true;   
    //Check trigger execute
    Trigger_Execute__c TE = Trigger_Execute__c.getValues('PGLSDUpdateTrigger');
    isEnabled = TE.Enable_del__c;
    if(isEnabled)
    {
        TriggerDispatcher.run(new LSDUpdateTriggerHandler(), 'PGLSDUpdateTrigger');
    }
}
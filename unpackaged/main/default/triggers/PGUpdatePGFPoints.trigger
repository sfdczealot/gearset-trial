trigger PGUpdatePGFPoints on Update_PGF_Reward_Points__e (after insert) {
   boolean isEnabled = true;
    
    //Check trigger execute
    Trigger_Execute__c TE = Trigger_Execute__c.getValues('PGUpdatePGFPoints');
    isEnabled = TE.Enable_del__c;
    
    if(isEnabled)
    {
        TriggerDispatcher.run(new PGUpdatePGFPointsController(), 'PGUpdatePGFPoints');
    }
    
}
trigger PGAgentRewardTrigger on Agent_Reward__c (after insert,after update, before insert, before update, before delete) {
    
     boolean isEnabled = true;
    
    //Check trigger execute
    Trigger_Execute__c TE = Trigger_Execute__c.getValues('PGAgentRewardTrigger');
    isEnabled = TE.Enable_del__c;
    
    if(isEnabled)
    {
        TriggerDispatcher.run(new AgentRewardTriggerHandler(), 'PGAgentRewardTrigger');
    }    
}
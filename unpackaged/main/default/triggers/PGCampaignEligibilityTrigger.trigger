trigger PGCampaignEligibilityTrigger on Campaign_Eligibility__c (after insert, after update, before insert,
                                                                 before update,before delete,after delete,
                                                                 after undelete) 
{ 
    
    boolean isEnabled = true;
    
    //Check trigger execute
    Trigger_Execute__c TE = Trigger_Execute__c.getValues('PGCampaignEligibilityTrigger');
    isEnabled = TE.Enable_del__c;
    if(isEnabled)
    {
        TriggerDispatcher.run(new PGCampEligibilityTriggerHandler(), 'PGCampaignEligibilityTrigger');
    }
}
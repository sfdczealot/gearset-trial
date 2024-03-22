trigger PGOpportunityTrigger on Opportunity (after insert,after update, before insert, before update, before delete) {
    
    TriggerDispatcher.run(new opportunityTriggerHandler(), 'PGOpportunityTrigger'); 
    
}
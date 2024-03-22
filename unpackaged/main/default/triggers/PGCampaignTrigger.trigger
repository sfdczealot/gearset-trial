/*
 * TestClass : PGCampaignTrigger_Test
 */
trigger PGCampaignTrigger on Campaign (before insert,before update,after insert,after update) {
  
    TriggerDispatcher.run(new PGCampaignTriggerHandler(),'PGCampaignTrigger');
}
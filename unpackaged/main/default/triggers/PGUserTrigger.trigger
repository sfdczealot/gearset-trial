trigger PGUserTrigger on User (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    
    TriggerDispatcher.run(new PGUserTriggerHandler(), 'UserTrigger');
    
}
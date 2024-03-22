/*
 * TestClass : trigger_contact_Test
 */
trigger trigger_contact on Contact(before insert,before update,before delete,after insert,after update,after delete,after undelete){

    TriggerDispatcher.run(new trigger_contactHandler(), 'trigger_contact');

}
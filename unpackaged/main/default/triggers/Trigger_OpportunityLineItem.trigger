trigger Trigger_OpportunityLineItem on OpportunityLineItem ( before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    
    TriggerDispatcher.run(new oppLineItemTriggerHandler(), 'Trigger_OpportunityLineItem'); 
     
}
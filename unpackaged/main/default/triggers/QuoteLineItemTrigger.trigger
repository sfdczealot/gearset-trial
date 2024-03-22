trigger QuoteLineItemTrigger on QuoteLineItem ( before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    //PGAUTO-1125 START
   /*boolean isTrackerEnabled = true ;
    
        Trigger_Execute__c TE = Trigger_Execute__c.getValues('QuoteLineItemTrigger');
        isTrackerEnabled = TE.Enable_del__c;
     
    if (isTrackerEnabled) {
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            QuoteLineItemTriggerHelper.prepopulateQliFields(trigger.New);
        }else if(Trigger.isAfter && Trigger.isInsert){ 
            QuoteLineItemTriggerHelper.summarizeLineItem(trigger.New);
            QuoteLineItemTriggerHelper.oliSynicngFields(Trigger.new, Trigger.oldMap,true);
        }else if(Trigger.isAfter && Trigger.isUpdate){
            QuoteLineItemTriggerHelper.summarizeLineItem(trigger.New);
            QuoteLineItemTriggerHelper.oliSynicngFields(Trigger.new, Trigger.oldMap,false);
            QuoteLineItemTriggerHelper.trackHistory(Trigger.new, Trigger.oldMap);
        }else if(Trigger.isAfter && Trigger.isdelete){
            QuoteLineItemTriggerHelper.summarizeLineItem(trigger.old);
            QuoteLineItemTriggerHelper.DeletedQLI(Trigger.old);
        }
        
	}*/
    //PGAUTO-1125 END
    boolean isTrackerEnabled = true ;
    Trigger_Execute__c TE = Trigger_Execute__c.getValues('QuoteLineItemTrigger');
    isTrackerEnabled = TE.Enable_del__c;
    if(isTrackerEnabled || Test.isRunningTest()){
        TriggerDispatcher.run(new QuoteLineItemTriggerHandler(), 'QuoteLineItemTrigger'); 
    }
    
    
    
}
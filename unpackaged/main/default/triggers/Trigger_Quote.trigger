trigger Trigger_Quote on Quote (Before Insert,Before Update,After Insert,After Update,After Delete) {
    Boolean isEnabled = true;
    Boolean isTrackEnabled = true;
    
    Trigger_Execute__c tE = Trigger_Execute__c.getValues('Trigger_Quote');
    if(tE != null){
        isEnabled = tE.Enable_del__c;
    	isTrackEnabled = tE.IsTrackingEnable__c;
    }else{
        isEnabled=true;
    }
    
    
    
        
    if(isEnabled){
    	TriggerDispatcher.run(new PGQuoteTriggerHandler(),'Trigger_Quote');
    }
}
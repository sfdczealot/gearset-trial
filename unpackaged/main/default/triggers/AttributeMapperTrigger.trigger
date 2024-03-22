trigger AttributeMapperTrigger on Attribute_Mapper__c (before insert, before update) {
    
    // Check the Custom settings to see if we are running triggers
    if (!CS_TriggerHandler.GetTriggersEnabled())
        return;

    
    if(Trigger.isBefore) {
        if  (Trigger.isInsert) {
            AttributeMappingEngine.handleBeforeInsert(trigger.new); 
        
        }
         if  (Trigger.isUpdate) {
            AttributeMappingEngine.handleBeforeUpdate(trigger.new); 
        
        }  
    } 
  }
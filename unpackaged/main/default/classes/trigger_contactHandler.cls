public class trigger_contactHandler implements PGTriggerInterface {
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public void beforeInsert(List<sObject> newList) {       
        
        Map<String,Id> SubsNameIdMap = PGOpportunityTriggerHandler.SubsidiaryNameIdMap();
        
        Map<Id,String> OwnerSubsNameIdMap = PGOpportunityTriggerHandler.UserIdSubsIdMap();
        
        List<Contact> contactList = (List<Contact>)newList;
        
        for(Contact con : contactList){
            
            if(SubsNameIdMap!=null && SubsNameIdMap.size()>0 && OwnerSubsNameIdMap!=null && OwnerSubsNameIdMap.size()>0){
                con.subsidiary__c = SubsNameIdMap.get(OwnerSubsNameIdMap.get(con.ownerId));
            }
        }
    }
    
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        
    }
    
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        
    }
    
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {         
    }
    
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {         
    }
}
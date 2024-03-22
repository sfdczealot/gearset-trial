public class opportunityTriggerHandler implements PGTriggerInterface  {
    
    List<Opportunity> listOpp = new List<Opportunity>();
    List<Opportunity> oldListOpp = new List<Opportunity>();
    Map<Id,Opportunity> triggerOldMap = new Map<Id,Opportunity>();
    Map<Id,Opportunity> triggerNewMap = new Map<Id,Opportunity>();
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public void beforeInsert(List<sObject> newList) {       
        for(Sobject oppObj : newList){
            Opportunity opp = (Opportunity)oppObj;
            listOpp.add(opp);
        }
        opportunityTriggerHelper.befIns(listOpp);
        listOpp.clear();
    }
    
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        for(Sobject oppObj : newList){
            Opportunity opp = (Opportunity)oppObj;
            listOpp.add(opp);            
        }
        
        for(Sobject oppObj : newMap.values()){
            Opportunity opp = (Opportunity)oppObj;
            triggerNewMap.put(opp.Id,opp);                  
        }
        
        opportunityTriggerHelper.createQuote(listOpp,triggerNewMap);
        opportunityTriggerHelper.createAccountInIPP(listOpp);
        listOpp.clear();
        triggerNewMap.clear();
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        for(Sobject oppObj : newList){
            Opportunity opp = (Opportunity)oppObj;
            listOpp.add(opp);            
        }
        
        for(Sobject oppObj : newMap.values()){
            Opportunity opp = (Opportunity)oppObj;
            triggerNewMap.put(opp.Id,opp);                  
        }
        
        for(Sobject oppObjMapInstance : oldMap.values()){
            Opportunity opp2 = (Opportunity)oppObjMapInstance;
            triggerOldMap.put(opp2.Id,opp2);                  
        }
        
        opportunityTriggerHelper.befUpdate(listOpp,triggerNewMap,triggerOldMap);
        listOpp.clear();
        triggerNewMap.clear();
        triggerOldMap.clear();
    }
    
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        for(Sobject oppObj : newList){
            Opportunity opp = (Opportunity)oppObj;
            listOpp.add(opp);            
        }
        for(Sobject oppObj : oldList){
            Opportunity opp = (Opportunity)oppObj;
            oldListOpp.add(opp);            
        }
        for(Sobject oppObj : newMap.values()){
            Opportunity opp = (Opportunity)oppObj;
            triggerNewMap.put(opp.Id,opp);                  
        }
        for(Sobject oppObjMapInstance : oldMap.values()){
            Opportunity opp2 = (Opportunity)oppObjMapInstance;
            triggerOldMap.put(opp2.Id,opp2);                  
        }
        opportunityTriggerHelper.aftUpdate(listOpp,oldListOpp,triggerNewMap,triggerOldMap);
        opportunityTriggerHelper.RenewalOpptyPublishEvent(triggerNewMap,triggerOldMap);
        opportunityTriggerHelper.primeCreditPublishEvent(triggerNewMap,triggerOldMap);
        listOpp.clear();
        oldListOpp.clear();
        triggerNewMap.clear();
        triggerOldMap.clear();
        
    }
    
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {   
        
        for(Sobject oppObj : oldList){
            Opportunity opp = (Opportunity)oppObj;
            listOpp.add(opp);            
        }
        
        opportunityTriggerHelper.validateDeletion(listOpp);
        listOpp.clear();
    }
    
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {         
    }
    
}
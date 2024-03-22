public class AddressTriggerHandler implements PGTriggerInterface{
    List<Address__c> listAR;
    List<Address__c> oldListAR ;
    Map<Id,Address__c> triggerOldMap;
    Map<Id,Address__c> triggerNewMap;
    
    public AddressTriggerHandler() {  
        listAR = new  List<Address__c>();
        oldListAR = new List<Address__c>();
        triggerOldMap = new Map<Id,Address__c>();
        triggerNewMap = new Map<Id,Address__c>();
    }
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
   
    
    public void beforeInsert(List<sObject> newList) {
        
        addressActiveCheck(newList,null,null);
    }
    
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
    }
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        
        addressActiveCheck(newList,newMap,oldMap);
    }
    
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        
    }
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) { 
        
    }
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {         
    }
    public static void addressActiveCheck(List<sObject> newList, Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        
        Set<id> AdId = new Set<id>();
        for(sObject arobj: newList){
            Address__c Addr = (Address__c)arobj;
            AdId.add(Addr.Id);
        }
        Map<Id,List<Opportunity>> AROppMap = new  Map<Id,List<Opportunity>>();
        List<Address__c> ArList = [Select id,Name,isActive__c,(Select Id,Name,IsClosed From Opportunities__r Where IsClosed=false) From Address__c Where id IN:AdId];
        for(Address__c ar: ArList){
            AROppMap.put(ar.Id,ar.Opportunities__r);
            
        }
        
        for(sObject arobj:newList){
            Address__c Addr = (Address__c)arobj;
            if(newMap != null && oldMap != null){
                Address__c oldAd = (Address__c)oldMap.get(Addr.Id);
                Address__c newAd = (Address__c)newMap.get(Addr.Id);
                System.debug('Opportunity Size ###'+AROppMap.get(Addr.Id).size());
                if(oldAd.isActive__c != newAd.isActive__c && Addr.isActive__c==false && AROppMap.get(Addr.Id).size()>0 ){
                    Addr.isActive__c.addError(System.label.Address_Activation);
                }
            }
            else
            {
                if(Addr.isActive__c==false && Addr.Opportunities__r.size()>0){
                    Addr.isActive__c.addError(System.label.Address_Activation);
                }
            }
        }
    } 
    
}
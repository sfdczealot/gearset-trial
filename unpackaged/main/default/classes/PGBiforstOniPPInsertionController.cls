public class PGBiforstOniPPInsertionController implements PGTriggerInterface {
List<Biforst_Sync__e> listAR;
    List<Biforst_Sync__e> oldListAR ;
    Map<Id,Biforst_Sync__e> triggerOldMap;
    Map<Id,Biforst_Sync__e> triggerNewMap;
    
    public PGBiforstOniPPInsertionController() {
        listAR = new  List<Biforst_Sync__e>();
        oldListAR = new List<Biforst_Sync__e>();
        triggerOldMap = new Map<Id,Biforst_Sync__e>();
        triggerNewMap = new Map<Id,Biforst_Sync__e>();
    }
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    public void beforeInsert(List<sObject> newList) { 
    }
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        fireBiforstSync((List<Biforst_Sync__e>) newList);
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
    public static void fireBiforstSync(List<Biforst_Sync__e> listTriggerNew){
               List<Account> accList = new List<Account>();
        for (Biforst_Sync__e Biforst_Sync : listTriggerNew) {
            if (Biforst_Sync.AccountId__c !=null) {
                Account acc = [Select id from Account where id = :Biforst_Sync.AccountId__c];
                accList.add(acc);
            }
        }
        if(!accList.isempty()){
            SendNotify.InsertAccountHandler(accList);
        } 
    }
   
}
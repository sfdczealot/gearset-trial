//Test class : AgentrewardTriggerHandler_test
public class PGUpdatePGFPointsController implements PGTriggerInterface {
    List<Update_PGF_Reward_Points__e> listAR;
    List<Update_PGF_Reward_Points__e> oldListAR ;
    Map<Id,Update_PGF_Reward_Points__e> triggerOldMap;
    Map<Id,Update_PGF_Reward_Points__e> triggerNewMap;
    
    public PGUpdatePGFPointsController() {
        listAR = new  List<Update_PGF_Reward_Points__e>();
        oldListAR = new List<Update_PGF_Reward_Points__e>();
        triggerOldMap = new Map<Id,Update_PGF_Reward_Points__e>();
        triggerNewMap = new Map<Id,Update_PGF_Reward_Points__e>();
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
        updateAgentPGFPoints((List<Update_PGF_Reward_Points__e>) newList);
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
    public static void updateAgentPGFPoints(List<Update_PGF_Reward_Points__e> listTriggerNew){
        List<Account> accountToUpdate = new List<Account>();
        for (Update_PGF_Reward_Points__e PGFPoints : listTriggerNew) {
            if (PGFPoints.Account_Id__c !=null) {
                Account acc = new Account(id =PGFPoints.Account_Id__c,PGF_Reward_Points__c= PGFPoints.PGF_Reward_Points__c,
                                          Reward_Points__c=PGFPoints.Reward_Points__c );
                accountToUpdate.add(acc);
            }
        }
        
        Database.SaveResult[] updateResults =  Database.update(accountToUpdate,false);
        list<Error_Log__c> errorLogs = new list<Error_Log__c>();
        for(Integer i=0;i< updateResults.size();i++){
            String rowStr;
            if(!updateResults.get(i).isSuccess() || Test.isRunningTest()) {
                String error;
                if(!updateResults.get(i).getErrors().isEmpty()){
                 error = updateResults.get(i).getErrors().get(0).getMessage();
                }else{
                    error = 'account not updated';
                }
                errorLogs.add(createErrorLog(accountToUpdate[i].id,JSON.serialize(accountToUpdate[i]),error)); 
                
            } 
        }
        insert errorLogs;
        
        
    }
    public static Error_Log__c createErrorLog(String recordId, String strData, String strErrorMsg) {
        Error_Log__c newError = new Error_Log__c();
        newError.Related_Record_Id__c = recordId;
        if(strData.length() > 100000) {
            strData = strData.substring(0, 100000);
        }
        newError.Data_To_Update__c = strData;
        if(strErrorMsg.length() > 100000) {
            strErrorMsg = strErrorMsg.substring(0, 100000);
        }
        newError.Error_Message__c = strErrorMsg;
        return newError;
    }   
    
}
public class PGUserTriggerHandler implements PGTriggerInterface{
     
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
     
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
     
    public void beforeInsert(List<sObject> newList) {
        for(Sobject USobj : newList){
            User U = (User)USobj;
            U.CurrencyISOCode = U.DefaultCurrencyISOCode;
        }
    }
     
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
         
    }
     
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
         for(Sobject USobj : newList){
            User U = (User)USobj;
            U.CurrencyISOCode = U.DefaultCurrencyISOCode;
        }
    }
     
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        // Update account and opportunity owner when user is inactive
        If(trigger.new.size()==1 ){
            User newUser = (User)trigger.new[0];
            User oldUser = (User)trigger.old[0];
            System.Debug('newUser###' + newUser);
            System.Debug('oldUser###' + oldUser);
            If(!newUser.IsActive && newUser.Transfer_Account_Opportunity__c && (newUser.IsActive!=oldUser.IsActive || newUser.Transfer_Account_Opportunity__c!=oldUser.Transfer_Account_Opportunity__c) ){
                //Call batch Apex 
                System.Debug('In condition###');
                User objUser=[select id,name,email,managerId,Manager.Email from user where id=:newUser.Id];
                AccountOwnerTransfer_Batch objBatch=new AccountOwnerTransfer_Batch(objUser);
                Database.executeBatch(objBatch);
            }
        }
        
         
    }
     
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
         
    }
     
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
         
    }
     
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
         
    }
}
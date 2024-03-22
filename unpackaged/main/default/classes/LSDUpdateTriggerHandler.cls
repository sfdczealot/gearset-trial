public class LSDUpdateTriggerHandler implements PGTriggerInterface {
    
    List<LSD_Update__c> listAR;
    List<LSD_Update__c> oldListAR ;
    Map<Id,LSD_Update__c> triggerOldMap;
    Map<Id,LSD_Update__c> triggerNewMap;
    
    public LSDUpdateTriggerHandler() {
        listAR = new  List<LSD_Update__c>();
        oldListAR = new List<LSD_Update__c>();
        triggerOldMap = new   Map<Id,LSD_Update__c>();
        triggerNewMap = new  Map<Id,LSD_Update__c>();
    }
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    public void beforeInsert(List<sObject> newList) { 
        validateApprovalCap((List<LSD_Update__c>) newList);
        
    }
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        
        
    }
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        publishLSDResult((List<LSD_Update__c>) newList, (Map<Id,LSD_Update__c>) oldMap);
    }
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        
    }
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) { 
        
    }
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {         
    }
    /**
*  Method used to validate that only 1 request is made at a time
*  @name validateApprovalCap
*  @param List<LSD_Update__c>, Map<Id,LSD_Update__c>
*  @return void
*/
     private static void validateApprovalCap(List<LSD_Update__c> listTriggerNew) {
        Map<Id,Id> accountMap = new map<Id,Id>(); // LSD to Account
        Map<Id,Integer> countLSD = new map<Id,Integer>();
        for(LSD_Update__c each : listTriggerNew) {
            accountMap.put(each.id,each.Account__c);
        }
        for(LSD_Update__c each : [SELECT Id,Approval_Status__c,Account__c FROM LSD_Update__c WHERE Approval_Status__c ='Submit for approval' and account__C IN : accountMap.values()]){
            if(!countLSD.containskey(each.Account__c))
                countLSD.put(each.Account__c,1); 
            else{
                Integer temp = countLSD.get(each.Account__c)+1;
                countLSD.put(each.Account__c,temp);  
            }
        }
        
        for(LSD_Update__c each : listTriggerNew) {
            if(each.Approval_Status__c =='Submit for approval' && countLSD.containskey(each.Account__c) && countLSD.get(each.Account__c) > 0) {
                each.addError(label.LSD_Update_ERROR_MESSAGE);
            }
        }
        
    }
    
    /**
*  Method used to publish Loyalty Start Date based on Approvals
*  @name publishLSDResult
*  @param List<LSD_Update__c>>
*  @return void
*/
    
     private static void publishLSDResult(List<LSD_Update__c> listTriggerNew, Map<Id,LSD_Update__c> oldMap) {
        String failedDML;
        String AccountId;
        List<Agent_LSD_Update_notification__e> agentLSDUpdate = new List<Agent_LSD_Update_notification__e>();
        Map<Id,boolean> accountUpdateResult = new map<id,boolean>();
        Map<Id,String> accounterrorResult = new map<id,String>();
        
        Map<Id,account> accountMap = new map<id,account>();
        Set<id> accIds = new Set<Id>();
         list<account> toUpdateAccount = new list<account>();
        for(LSD_Update__c each : listTriggerNew) {
            if(each.Approval_Status__c != oldMap.get(each.Id).Approval_Status__c) {
                accIds.add(each.account__c);
                
            }
        }
        
        if(accIds.isEmpty()) {
            return;
        }
        for(Account acc :[Select id,Loyalty_Start_Date__c,country__c,AgentNet_ID__c from account where ID IN : accIds]){
            accountMap.put(acc.id,acc); 
        }
        
        for(LSD_Update__c each : listTriggerNew) {
            if(each.Approval_Status__c != oldMap.get(each.Id).Approval_Status__c) {
                
                if(each.Approval_Status__c == 'Approved' && accountMap.containskey(each.account__c)){
                    accountMap.get(each.account__c).Loyalty_Start_Date__c = each.Loyalty_Start_Date__c;
                    toUpdateAccount.add(accountMap.get(each.account__c));
                }            
            }
        }
        Database.SaveResult[] updateResults = Database.update(toUpdateAccount,false);
         for(Integer i=0;i< updateResults.size();i++){
            
            if(updateResults.get(i).isSuccess()) {
                Id accId = updateResults.get(i).getId();
                agentLSDUpdate.add(new Agent_LSD_Update_notification__e(Account_Id__c = accId,Country__c=accountMap.get(accId).country__c,Loyalty_Start_Date__c =accountMap.get(accId).Loyalty_Start_Date__c ,AgentNet_ID__c=accountMap.get(accId).AgentNet_ID__c, Message__c = 'Loyalty Start Date has been updated'));
                 accountUpdateResult.put(accId,true);   
               } else {
                Database.Error error = updateResults.get(i).getErrors().get(0);
                failedDML = error.getMessage();
                AccountId = toUpdateAccount[i].id; //failed record from the list
                accounterrorResult.put(AccountId,failedDML);
                accountUpdateResult.put(AccountId,false);
             }
        }
         for(LSD_Update__c each : listTriggerNew) {
             if(accountUpdateResult.containskey(each.account__c) && accountUpdateResult.get(each.account__c)){
                  each.LSD_Update_Date__c = System.now();
                 
             }else if(accounterrorResult.containskey(each.account__c)){
                 each.error__c = accounterrorResult.get(each.account__c);
             }
        }
        EventBus.publish(agentLSDUpdate);
    }   
}
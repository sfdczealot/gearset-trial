public class BatchToUpdateAccountLSD implements Database.Batchable<sObject>{
    
    public database.QueryLocator start(database.BatchableContext BC){
        String query;
        query = 'select Id,Loyalty_Start_Date__c,(select Account__c  from Loyalty_Start_Dates__r ORDER by Loyalty_Start_Date__c desc) from Account';  
        return Database.getQueryLocator(query);
    }
    public void execute(database.BatchableContext BC,list<Account> scope){
       
        set<Id> accIds = new set<Id>();
        list<Account> accList2Update = new List<Account>();
        Map<String,DateTime> accIdVsLSDDate = new Map<String,DateTime>();
        for(Account acc : scope)
        {
            if(!acc.Loyalty_Start_Dates__r.IsEmpty())
            {
                accIds.add(acc.id);
            }  
        }

        for(LSD_Update__c lsd : [select Id,Loyalty_Start_Date__c,Account__r.Loyalty_Start_Date__c,Account__c,
                                 LastModifiedById,Approval_Status__c from LSD_Update__c where Account__c In : accIds 
                                 AND LastModifiedById =: System.Label.Batch_To_Update_LSD_User_ID.split(';') 
                                 AND Approval_Status__c = 'Approved' ORDER by Loyalty_Start_Date__c desc limit 1])
        {
            if(!accIdVsLSDDate.containskey(lsd.Account__c)) 
            {
                accIdVsLSDDate.put(lsd.Account__c,lsd.Loyalty_Start_Date__c);
            }
        }
        
        for(Account accObj:[SELECT ID,Loyalty_Start_Date__c FROM Account Where id In:accIdVsLSDDate.keyset()]){
            accObj.Loyalty_Start_Date__c = Date.valueof(accIdVsLSDDate.get(accObj.id));
            accList2Update.add(accObj);
        }
        
        if(!accList2Update.isEmpty()){
            Update accList2Update;
        }
        
    }
    public void finish(database.BatchableContext BC){
        
    }
    
}
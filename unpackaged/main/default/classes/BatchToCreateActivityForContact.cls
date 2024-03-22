//BatchToCreateActivityForContact_Test
public class BatchToCreateActivityForContact implements Database.Batchable<sObject>{
	
    public Database.QueryLocator start(Database.BatchableContext BC)  {
        
        String statusAct = 'Verified';
        String typeAct = 'Birthday verification';
        return Database.getQueryLocator('select id,Account.Birthdate_Verified__c,(Select id,Status__c,Type__c from Activities__r where Status__c =: statusAct AND Type__c =: typeAct ) from Contact where Account.Birthdate_Verified__c = true');
    }   
    
    public void execute(Database.BatchableContext BC, List<Contact> conList) {
        list<Activity__c> actListToInsert = new list<Activity__c>();
        for(Contact con: conList){
            if(con.Activities__r.isEmpty()){
                Activity__c act = new Activity__c();
                act.Type__c = 'Birthday verification';
                act.Status__c = 'Verified';
                act.Description__c = 'Updated from Script';
                act.Contact__c = con.id;
                actListToInsert.add(act);
            }
        }
        if(!actListToInsert.isEmpty())
            insert actListToInsert;
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}
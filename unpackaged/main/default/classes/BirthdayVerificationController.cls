/*
* TestClass : BirthdayVerificationController_Test
*/
public class BirthdayVerificationController {
    
    @AuraEnabled
    public static void createActivityRecord(String acId){
        
        Account ac = [Select Id,Name,personContactid from Account where Id = : acId];
        
        Activity__c act = new Activity__c();
        act.Contact__c = ac.personContactid;
        act.Status__c = 'Verified';
        act.Description__c = 'Birthday verification done on '+String.valueOf(system.today());
        act.Type__c = 'Birthday verification';
        
        Insert act;
        
    }
    @AuraEnabled
    public static Account getAccount(String recordId){
        
        return [Select Id,Name,PersonBirthdate from Account where Id = : recordId];
    }
}
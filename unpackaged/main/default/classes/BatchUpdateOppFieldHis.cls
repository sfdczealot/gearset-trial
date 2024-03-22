/*
 * TestClass : BatchUpdateOppFieldHis_Test
 */
global class BatchUpdateOppFieldHis implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'Select id,MC_Sync__c,ispersonAccount,Account.IspersonAccount,Account.name,Account.recordType.DeveloperName from Contact where (ispersonAccount = true AND Account.status__c IN (\'Active\',\'Downgraded\',\'Trial\')) OR Account.recordType.DeveloperName = \'B2B_Account\'';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> contactList) {
        
        List<Contact> contactListToUpdate = new List<Contact>();
        for(Contact eachContact : contactList){
            
            Contact con = new Contact(id = eachContact.id);
            con.MC_Sync__c = true;
            contactListToUpdate.add(con);
        }
        if(contactListToUpdate.size()>0)
            Database.update(contactListToUpdate, false) ;
            
    }
    public void finish(Database.BatchableContext BC){
        
    }
}
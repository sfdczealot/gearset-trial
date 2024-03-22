global class BatchToUpdateEcommField  implements Database.batchable<Sobject> {
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String s='';
        if(test.isRunningTest()){
            s='SELECT Id, csb2c__E_Commerce_Customer_Id__c,Agentkey__c  FROM Account where recordType.name=\'Agent\' and csb2c__E_Commerce_Customer_Id__c=null and country__c=\'Singapore\'';
        }
        else 
            s= Label.PG_LABEL_BatchToUpdateEcommFieldQuery;
        System.debug(s);
        return Database.getQueryLocator(s);
        
    }
    global void execute(Database.BatchableContext bc, List<Account> accList )
        
    {
        System.debug('@@@'+ accList);
        
        for(Account acc : accList) {        
            // Update the Account Name 
            acc.csb2c__E_Commerce_Customer_Id__c = acc.Agentkey__c ;
        }
        try{
            update accList;
            //System.debug(accList);
             
            
        } catch(Exception e) {
            System.debug(e);
        }
        
    }    
    global void finish(Database.BatchableContext bc)
    {
        
    }     
    
}
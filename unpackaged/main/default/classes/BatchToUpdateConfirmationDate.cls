public class BatchToUpdateConfirmationDate implements DataBase.Batchable<Sobject>{
    
    public DataBase.QueryLocator start(DataBase.BatchableContext Bc){
        
        
        String trialStr = 'Trial';
        String pendingStr = 'Pending';
        String query = 'select id,CreatedDate,Confirmation_Date__c, (select CreatedDate, Id, OldValue, NewValue, AccountId from Histories where Field= \'Status__c\' ) from Account where RecordType.DeveloperName= \'Agent\' AND  Confirmation_Date__c = null order by createdDate desc';
        return DataBase.getQueryLocator(query);
    }
    
    public void execute(DataBase.BatchableContext Bc,List<Account> accList){
        for(Account ac : accList){
            ac.Confirmation_Date__c = ac.CreatedDate;
            for(AccountHistory ah : ac.Histories){
                if(ah.OldValue == 'Pending' && ah.NewValue == 'Trial'){
                    ac.Confirmation_Date__c = ah.CreatedDate;     
                }    
                                
            }
        }
        update accList;
    }
    public void finish(DataBase.BatchableContext Bc){
        
    }
}
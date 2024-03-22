public class PGUpdateRecordTypeText implements DataBase.Batchable<Sobject>{

    public DataBase.QueryLocator start(DataBase.BatchableContext Bc){
        
        return DataBase.getQueryLocator('Select Id,RecordType.Name,Record_Type_Text__c from Account');
    }
    
    public void execute(DataBase.BatchableContext Bc,List<Account> accList){
        list<Account> accToUpdate = new list<Account>();
        for(Account ac : accList){
            if(ac.RecordType.Name != ac.Record_Type_Text__c){
                ac.Record_Type_Text__c = ac.RecordType.Name; 
                accToUpdate.add(ac);
            }
        }
        if(!accToUpdate.isEmpty()){
            DataBase.update(accToUpdate,false);
        }
        
    }
    
    public void finish(DataBase.BatchableContext Bc){
        
    }
}
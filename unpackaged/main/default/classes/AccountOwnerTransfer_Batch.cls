Public class AccountOwnerTransfer_Batch implements Database.Batchable<sObject>, Database.Stateful {
    public User objUser;
    public string accountHeader = 'Id,Agentkey,Response \n';
    public string finalAccStr = accountHeader ;
    
    public AccountOwnerTransfer_Batch(User objUser){
        this.objUser=objUser;
    }
    Public Database.querylocator start(Database.BatchableContext BC) {
        String query='select id,OwnerId,agentkey__c from Account Where OwnerId=\''+objUser.Id+'\'';
        return Database.getQueryLocator(query);
    }
    Public void execute(Database.BatchableContext BC, List<Account> accountList) {
        
        for(Account eachacc :accountList){
            eachacc.ownerId=objUser.ManagerId;
        }
        
        Database.SaveResult[] srAccList=Database.update(accountList, false);
        
        for(Integer i=0; i < srAccList.size(); i++){
            if(srAccList.size()>0){
                if (srAccList.get(i).isSuccess()){
                    Id recID=srAccList.get(i).getId();
                    finalAccStr = finalAccStr+ recID+ ','+ accountList.get(i).agentkey__c+ ','+ 'Success'+ '\n';
                }else{
                    String allerrors;
                    Id recID=accountList.get(i).Id;
                    for(Database.Error err : srAccList.get(i).getErrors()) {
                        allerrors=allerrors+';'+err.getMessage().replace(',', '_');
                    }
                    finalAccStr = finalAccStr+ recID+ ','+ accountList.get(i).agentkey__c+ ','+ allerrors+ '\n';
                }
            }
        }
        
        
    }
    Public void finish(Database.BatchableContext BC) { 
         OpportunityOwnerTransfer_Batch objBatch=new OpportunityOwnerTransfer_Batch(objUser,finalAccStr);
         Database.executeBatch(objBatch);
    }
}
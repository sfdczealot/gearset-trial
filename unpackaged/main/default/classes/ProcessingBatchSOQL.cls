/*
 * TestClass : ProcessingBatchSOQL_Test
 */
public class ProcessingBatchSOQL implements DataBase.Batchable<sObject>, Database.Stateful { 
	
    public map<Id,String> ceQueryMap;
    public list<Id> ceIdList;
    public string currentQuery;
    public list<sObject> sObjectForSingleCE;
    public ProcessingBatchSOQL(map<Id,String> ceQueryMap,list<Id> ceIdList){
        sObjectForSingleCE = new list<sObject>();
        this.ceIdList = ceIdList;
        this.ceQueryMap = ceQueryMap;
        if(ceIdList != null && !ceIdList.isEmpty()){
            currentQuery = ceQueryMap.get(ceIdList[0]);
        }
        if(string.isBlank(currentQuery)){
            return;
        }
        
    }
    public Database.QueryLocator start(DataBase.BatchableContext Bc){
        
        return Database.getQueryLocator(currentQuery);
    }
    
    public void execute(DataBase.BatchableContext Bc,List<sObject> scope ){
        
        sObjectForSingleCE.addAll(scope);
    }
	
	public void finish(DataBase.BatchableContext bc){
        if(ceIdList != null && !ceIdList.isEmpty()){
            if(!sObjectForSingleCE.isEmpty()){
            	Database.executeBatch(new CMOperationsBatch(ceIdList[0],sObjectForSingleCE),8000);    
            }
            
            ceIdList.remove(0);
            if(ceIdList != null && !ceIdList.isEmpty()){
                Database.executeBatch(new ProcessingBatchSOQL(ceQueryMap,ceIdList),2000);
            }
        }
    }    
}
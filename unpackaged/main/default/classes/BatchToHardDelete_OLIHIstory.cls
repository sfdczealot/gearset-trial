global class BatchToHardDelete_OLIHIstory implements Database.Batchable<sObject>
{   
    global BatchToHardDelete_OLIHIstory()
    {
           //constuctor  
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        if(Test.isRunningTest()){
            return Database.getQueryLocator([Select id from OLI_Field_History__c ]); 
        }else
        
        return Database.getQueryLocator([Select id from OLI_Field_History__c  where calendar_year(CreatedDate) =: Integer.ValueOf(System.Label.OLI_HISTORY_DELETE_YEAR) AND calendar_month(CreatedDate) =: Integer.ValueOf(System.Label.OLI_HISTORY_DELETE_MONTH)] );
    } 
    
    global void execute(Database.BatchableContext BC, list<sObject> scope)
    {     
      System.debug('## deleting '+scope.size()+' OLI_Field_History__c records' +scope[0].Id);   
 
       
            delete scope;   
            Database.emptyRecycleBin(scope);  
    }
        
    global void finish(Database.BatchableContext BC) 
    {                 
        //no post processing
       
     }
}
//Batch Class to purge data
global class PurgeDataBatch implements Database.Batchable<Id>, Database.Stateful 
{
    Map<Purge_Batch_Job__c, Date> objAPINamePurgeMap = new Map<Purge_Batch_Job__c, Date>();
    List<Id> recordIds = new List<Id>();
    Integer queryLimit;
    
    /*Start method */
    global Iterable<Id> start(Database.BatchableContext BC)
    {
        // Read all of the items to be purged form Custom Settings    
        for(Purge_Batch_Job__c batchJob : Purge_Batch_Job__c.getAll().values())
        {
            if(batchJob.Number_of_Days_To_Purge__c != null)
            {
                Decimal noOfDays = batchJob.Number_of_Days_To_Purge__c;
                Date reqDate = Date.today().addDays( - Integer.valueOf(noOfDays));

                objAPINamePurgeMap.put(batchJob, reqDate);
            }
        }
        for(Purge_Batch_Job__c objName : objAPINamePurgeMap.keyset()){
        	queryLimit = Limits.getLimitQueryRows() - Limits.getQueryRows();
            Date reqDateTme = objAPINamePurgeMap.get(objName);
            String additionalFilter = String.isNotBlank(objName.Additional_Filter__c) ? ' And ' + objName.Additional_Filter__c : '';

            recordIds.addAll(new Map<Id, SObject>(
                Database.Query(
                    'Select Id From ' + objName.Object_API_Name__c + ' Where ' + objName.Date_Filter__c + ' <=: reqDateTme ' + additionalFilter + ' Limit ' + queryLimit            
                )
            ).keySet());
        }
        return recordIds;
    }
    
    /*Execute method */
    global void execute(Database.BatchableContext bc, List<String> scope){
        Map<Schema.SObjectType, List<SObject>> sObjectsToBeDeleted = new Map<Schema.SObjectType, List<SObject>>();
        for(Id idToDelete : scope){
        	if(!sObjectsToBeDeleted.containsKey(idToDelete.getSObjectType())) {
        		sObjectsToBeDeleted.put(idToDelete.getSObjectType(), new List<SObject>());
        	}
        	
            sObject s = (idToDelete).getSObjectType().newSobject(idToDelete);
            sObjectsToBeDeleted.get(idToDelete.getSObjectType()).add(s);
        }
        
        for(Schema.SObjectType objType : sObjectsToBeDeleted.keySet()) {
            Database.delete(sObjectsToBeDeleted.get(objType));
        }
    }
    
    /*Finish method */
    global void finish(Database.BatchableContext bc){
       if(queryLimit == 0) {
       		PurgeDataBatch batchJob = new PurgeDataBatch();
       		Database.executeBatch(batchJob, 1000);
       }
    }
}
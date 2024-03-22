/******************************************************************************************************
Batch Class ========>  SO_ExpirationTaskCreation_Batch 
Agenda  ========> Create a Task 1,3 and 6 month before the SO gets expired and assign to the queue "CST"  
Test Class =====> SO_ExpirationTaskCreation_BatchTest  
Modfication Log : DeveloperName 				Date			Change
	  			  Nallabolu Naveen			04-02-2022		Changed the logic: Fetch all SO's whose SO is ending in next 185 days
															and segragating all the SO's Based on the sapn from today
															upserting Task's only the SO's EndDate span falls under 1,3 and 6 months
********************************************************************************************************/

Global class SO_ExpirationTaskCreation_Batch implements Database.Batchable<sObject>,system.Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC){        
        Date endDate180 = system.today().addDays(185);
        string query = 'select id,Name,Aggregated_Status__c,Product_Configuration__r.cscfga__Product_Family__c,csdf__Fulfilment__c,csdf__Fulfilment__r.Sales_Order__r.Name,csdf__Fulfilment__r.Sales_Order__r.SO_End_Date__c from csdf__Fulfilment_Item__c where Aggregated_Status__c != \'Completed\' and Aggregated_Status__c != \'Paused Inventory Released\' and Aggregated_Status__c != \'Delivering\'  and Product_Configuration__r.cscfga__Product_Family__c in (\'Ad Served\', \'Standard Products\',\'Developer Listings\',\'Database Marketing\') and csdf__Fulfilment__r.Sales_Order__r.Status_Read_Only__c != \'Killed\' and csdf__Fulfilment__r.Sales_Order__r.Sold__c = true and csdf__Fulfilment__r.Sales_Order__r.SO_End_Date__c <=: endDate180';
        system.debug('query==>' +query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<csdf__Fulfilment_Item__c> scope){
        
        System.debug('scope*** '+scope);
        System.debug('scope*** '+scope.size());
        List<Task> taskToBeCreated = new List<Task>();
        Map<String,String> SoIdMap = new  Map<String,String> ();
        String sub='';        
        String queue = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'CST' LIMIT 1].Id;
        Set<Id> SoIds = new Set<Id>();
        for(csdf__Fulfilment_Item__c fli : scope){
            SoIds.add(fli.csdf__Fulfilment__r.Sales_Order__c);
        }
        Map<String, Task> SoToTaskMap = new Map<String, Task>();
        Date taskCreatedDate = System.today().addDays(-10);
        for(Task tsk : [Select Id, Subject, Type, Status, Priority, ActivityDate, WhatId from Task where WhatId =:SoIds and createdDate >=:taskCreatedDate]){
            SoToTaskMap.put(tsk.WhatId, tsk);
        }
        
        for(csdf__Fulfilment_Item__c FI:scope){
                        
            if(FI.csdf__Fulfilment__r.Sales_Order__r.SO_End_Date__c != null){
                if(FI.csdf__Fulfilment__r.Sales_Order__r.SO_End_Date__c <= system.today().addDays(25)){
                    sub='Not Valid';
                }else if(FI.csdf__Fulfilment__r.Sales_Order__r.SO_End_Date__c > system.today().addDays(25) && FI.csdf__Fulfilment__r.Sales_Order__r.SO_End_Date__c <= system.today().addDays(35)){
                     sub='1';
                }else if(FI.csdf__Fulfilment__r.Sales_Order__r.SO_End_Date__c > system.today().addDays(35) && FI.csdf__Fulfilment__r.Sales_Order__r.SO_End_Date__c <= system.today().addDays(85)){
                     sub='Not Valid';
                }else if(FI.csdf__Fulfilment__r.Sales_Order__r.SO_End_Date__c > system.today().addDays(85) && FI.csdf__Fulfilment__r.Sales_Order__r.SO_End_Date__c <= system.today().addDays(95)){
                     sub='3';
                }else if(FI.csdf__Fulfilment__r.Sales_Order__r.SO_End_Date__c > system.today().addDays(95) && FI.csdf__Fulfilment__r.Sales_Order__r.SO_End_Date__c <= system.today().addDays(175)){
                     sub='Not Valid';
                }else if(FI.csdf__Fulfilment__r.Sales_Order__r.SO_End_Date__c > system.today().addDays(175) && FI.csdf__Fulfilment__r.Sales_Order__r.SO_End_Date__c <= system.today().addDays(185)){
                     sub='6';
                }
                if(String.isNotBlank(sub) && sub != 'Not Valid')
                    SoIdMap.put(FI.csdf__Fulfilment__r.Sales_Order__c,sub);
            }
        }
        for(String SO:SoIdMap.keySet()){
            if(!SoToTaskMap.containskey(SO) || (SoToTaskMap.containskey(SO) && SoToTaskMap.get(SO).Status != 'Completed')){
                Task tsk = new Task();
                if(SoToTaskMap.containskey(SO))
                    tsk.Id = SoToTaskMap.get(SO).Id;
                tsk.Subject = 'Sales order expiring in '+ SoIdMap.get(SO)+' month';
                tsk.ActivityDate= date.today().addDays(5);
                if(!SoToTaskMap.containskey(SO)){
                    tsk.Type = 'Outbound Call';
                    tsk.Status = 'Open';
                    tsk.Priority = 'Normal';
                    system.debug('soid==>' +So);        
                    tsk.WhatId = SO;        
                    tsk.OwnerId = queue;
                }
                taskToBeCreated.add(tsk);  
            }
        }
        try{
            upsert taskToBeCreated;
            system.debug('tasks to Upserted' +taskToBeCreated);
        }Catch(Exception exc){
            system.debug('==>' +exc.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC){} 
    
    global void execute(SchedulableContext sc) {
        
        Database.executeBatch(new SO_ExpirationTaskCreation_Batch());
    }
}
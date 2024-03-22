public class TaskEmailTemplateController {
    public Id taskId {get;set;}
    public Id objId {get;set;}
    public String taskURL {get;set;}
    public String objectType;
    public String queueType {get;set;}
    public String fulfilmentLink {get;set;}
       public String fulfilmentItemLink {get;set;}
    public csmso__Sales_Order__c salesOrder {get;set;}
    public csdf__Fulfilment_Item__c fulfilmentItem {get;set;}
    public Task oTask {get;set;}
    
    
    public String getObjectType(){
        list<task> taskList =[SELECT Id, WhatId, OwnerId, CreatedBy.Name FROM Task WHERE Id =:taskId];
          oTask = taskList[0];
          objId = oTask.whatId;
          taskURL =  URL.getSalesforceBaseUrl().toExternalForm()+'/'+oTask.Id;
        TaskEmail();
         return objId.getSObjectType().getDescribe().getName();
    }
    public void TaskEmail(){
   
        objId = taskId;
       list<task> taskList =[SELECT Id, WhatId, OwnerId, Subject, CreatedBy.Name FROM Task WHERE Id =:taskId];
        if(!taskList.isEmpty()){
             oTask = taskList[0];
      
        objId = oTask.whatId;
        group gp = [SELECT Id, DeveloperName FROM Group WHERE Type ='Queue' and Id =: oTask.OwnerId];
        objectType = objId.getSObjectType().getDescribe().getName();
        queueType= gp.DeveloperName;
        if(objectType == 'csmso__Sales_Order__c'){
            salesOrder = [SELECT Id, csmso__Advertiser__c, csmso__Status__c, Name, Advertiser_Final__r.name
                          FROM csmso__Sales_Order__c WHERE Id =: oTask.whatId];
        }
        if(objectType == 'csdf__Fulfilment_Item__c'){
            fulfilmentItem = [SELECT Id, name,  Briefs_Cret__c, csdf__Fulfilment_Item_Link__c,csdf__Name__c,
                              csdf__Fulfilment__r.Sales_Order__r.Name,csdf__Fulfilment__c,
                               csdf__Fulfilment__r.Sales_Order__r.csmso__Status__c,
                              csdf__Fulfilment__r.Sales_Order__r.Advertiser_Final__r.name
                            
                          FROM csdf__Fulfilment_Item__c WHERE Id =: oTask.whatId];
           fulfilmentItemLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+oTask.whatId;
            fulfilmentLink= URL.getSalesforceBaseUrl().toExternalForm()+'/'+fulfilmentItem.csdf__Fulfilment__c;
        }
    } 
    }
    
}
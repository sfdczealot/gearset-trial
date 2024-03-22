public with sharing class runRewardCalculatorController {
    @AuraEnabled(cacheable=true)
    public static LightningResponse  checkCurrenttBatch(String country) {
        list<AsyncApexJob> processingBatch = new  list<AsyncApexJob>();
        list<AsyncApexJob> completedBatch = new  list<AsyncApexJob>();    
        Map<Id,document> docList = new Map<Id,document>();
        wrapper wp = new wrapper();
        
        list<AsyncApexJob> processingAsyncJob  = [Select id ,status ,ApexClass.name from AsyncApexJob where ApexClass.name ='BatchToComputeTotalSpending' and status = 'Processing'];
        
        if(!processingAsyncJob.isempty()){
            wp.processingBatch = true;
        }else {
            wp.processingBatch = false;
        }
        
        System.debug(wp);
        List<Folder> folder = [SELECT Id, Name FROM Folder WHERE Name = 'BatchToComputeTotalSpending_BulkResult'];
        for(document doc :[SELECT Id, FolderId, Type, Body,CreatedById,CreatedBy.name, CreatedDate FROM Document where type='csv' and FolderId = :folder[0].Id]){
            docList.put(doc.id,doc);
           
        }
        
        System.debug('docList-->>'+ docList);
        Blob csvFileBody;
        
        string csvAsString;
        String[] csvFileLines;
        list<wrapperCSV> recordsCSVList = new  list<wrapperCSV>();
        
        Integer i =1;
        for(Id docId : docList.keyset()){
            csvAsString = docList.get(docId).body.toString();
            csvFileLines = csvAsString.split('\n'); 
            wrapperCSV recordsCSV = new  wrapperCSV();
            recordsCSV.SNO = i ;
            recordsCSV.country = 'Singapore';
            recordsCSV.numOfAgents = csvFileLines.size() -1;
            recordsCSV.LastRunBy = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/User/' + docList.get(docId).CreatedById + '/view';
            recordsCSV.LastRunDate = docList.get(docId).CreatedDate;  
            recordsCSV.CSV=  URL.getSalesforceBaseUrl().toExternalForm() + '/' +  docId;
            recordsCSV.docId = docId;
            recordsCSV.LastRunByName=docList.get(docId).CreatedBy.name;
            i++;
            
            recordsCSVList.add(recordsCSV); 
            System.debug('recordsCSV-->>'+ recordsCSV);
            
        }
        try {
            wp.completedAsynchJob.addall(recordsCSVList);
            String wpResponse = JSON.serialize(wp);
            
            return new LightningResponse(true, 'Success', wpResponse);
            
        } catch (Exception ex) {
            return new LightningResponse(false, ex.getMessage(), '');
        }
    }
    @AuraEnabled
    public static LightningResponse  runBatch(String country) {
        
        try {
            String status;
            list<AsyncApexJob> processingAsyncJob  = [Select id ,status ,ApexClass.name from AsyncApexJob where ApexClass.name ='BatchToComputeTotalSpending' and status = 'Processing'];
            if(!processingAsyncJob.isempty()){
                status = 'Rewards calculation already running. Please wait for existing run to complete';
            }else {
                
               Id batchId= DataBase.executeBatch(new BatchToComputeTotalSpending(country,true), 200);
               status =  'Reward Calculation Started!!!!';
            }
            return new LightningResponse(true, status ,'');   
        } catch (Exception ex) {
            
            return new LightningResponse(false, ex.getMessage(), '');
        } 
        
    }
    public class wrapperCSV{
        @AuraEnabled
        public  Integer SNo;
        @AuraEnabled
        public String Country;
        @AuraEnabled
        public Integer numOfAgents;
        @AuraEnabled
        public String LastRunBy;
        @AuraEnabled
        public DateTime LastRunDate;
        @AuraEnabled
        public String CSV;
        @AuraEnabled
        public Id docId;
        @AuraEnabled
        public String LastRunByName;
    }
    public class wrapper{
        @AuraEnabled
        public  Boolean processingBatch;
        @AuraEnabled
        public list<wrapperCSV> completedAsynchJob = new list<wrapperCSV>();
    }
    
    
}
/**
 * @name CS_BatchDeleteReportData
 * @description Class that deletes duplicate report data
 * @revision
 *
 */
public without sharing class CS_BatchDeleteReportData extends CS_BatchWorker implements Schedulable {
    public CS_BatchDeleteReportData() {
        super('CS_BatchDeleteReportData', 1);
    }
    
    protected override Database.QueryLocator onStart() {
        this.queryString = 'SELECT Id, Name, DFP_Order_Line_ID__c, Status__c ' +
                           'FROM CS_Billing_Schedule_Item__c ' +
                           'WHERE Billing_Period_Start_Date__c != null ' +
                                 'AND Billing_Period_End_Date__c != null ' +
                                 'AND Billing_Period_Start_Date__c <= TODAY AND Billing_Period_End_Date__c >= TODAY';
        return super.onStart();
    }

    public override void doWork(List<SObject> scheduleItems) {
        CS_LogWorker log = CS_LogWorker.getInstance();
        try {
            if (scheduleItems.size() != 1) {
                throw new CS_BatchDeleteReportDataException();
            }
            
            List<Id> dataToDelete = new List<Id>();
            Set<String> uniqueKeysSet = new Set<String>();
            for(CS_DFP_Actuals_By_Hour_Report_Data__c reportData : [SELECT Id, Hour__c, Report_Date__c, Order_Line_Id__c
                                                                    FROM CS_DFP_Actuals_By_Hour_Report_Data__c
                                                                    WHERE Order_Line_Id__c != null
                                                                          AND CreatedDate != null 
                                                                          AND Order_Line_Id__c = :String.valueOf(scheduleItems[0].get('DFP_Order_Line_ID__c'))
                                                                    ORDER BY CreatedDate DESC
                                                                    LIMIT :Limits.getLimitQueryRows()]) {
                String key = String.format('{0}|{1}|{2}', 
                                           new List<String>{ String.valueOf(reportData.Order_Line_Id__c),
                                                             String.valueOf(reportData.Report_Date__c),
                                                             String.valueOf(reportData.Hour__c) });
                if(uniqueKeysSet.contains(key)) {
                    dataToDelete.add(reportData.Id);
                }
                else {
                    uniqueKeysSet.add(key);
                }
            }
            
            enqueueDeleteDataBatch(dataToDelete);
        }
        catch (Exception e) {
            log.addMessage(e);
            log.save(this.processName, getJobType(), getJobId(), false);
        }
    }
    
    private void enqueueDeleteDataBatch(List<Id> dataToDelete) {
        Integer chunkSize = Limits.getLimitDmlRows();
        CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();
        Integer addedRecords = 0;
        List<Id> currentRecordsChunk = new List<Id>();
        for(Id recordToDeleteId : dataToDelete) {
            if (currentRecordsChunk.size() < chunkSize) {
                currentRecordsChunk.add(recordToDeleteId);
                addedRecords++;
            }
            if (currentRecordsChunk.size() >= chunkSize 
                || dataToDelete.size() == addedRecords) {
                        
                dispatcher.addWorker(new CS_BatchDeleteReportDataWorker(new Map<String, Object> { 'recordsToDelete' => currentRecordsChunk }));
                currentRecordsChunk = new List<Id>();
            }
        }
        dispatcher.dispatch();
    }

    public without sharing class CS_BatchDeleteReportDataWorker extends CS_QueueableWorker {
        public CS_BatchDeleteReportDataWorker(Object params) {
            super('CS_BatchDeleteReportDataWorker', params);
        }

        public override void doWork() {
            CS_LogWorker log = CS_LogWorker.getInstance();
            try {
                Map<String, Object> paramsType = (Map<String, Object>)this.params;
                List<Id> recordsToDelete = (List<Id>)paramsType.get('recordsToDelete');
                delete [SELECT Id
                        FROM CS_DFP_Actuals_By_Hour_Report_Data__c
                        WHERE Id != null
                              AND Id in :recordsToDelete
                        LIMIT :recordsToDelete.size()];
            }
            catch (Exception e) {
                log.addMessage(e);
                log.save(this.processName, getJobType(), getJobId(), false);
            }
        }
    }

    public class CS_BatchDeleteReportDataException extends Exception { }
}
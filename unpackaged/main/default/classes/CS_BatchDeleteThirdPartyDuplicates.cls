/**
*─────────────────────────────────────────────────────────────────────────────────────────────────┐
* batch class deletes any third party actual duplicates based on report date and order line item id
* takes in a list of custom report ids passed on by CS_P_CustomReportStatusFilter
*──────────────────────────────────────────────────────────────────────────────────────────────────
*@author    Osvaldo Parra   <osvaldo.parrarascon@cloudsense.com>
*──────────────────────────────────────────────────────────────────────────────────────────────────
*@changes
*─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_BatchDeleteThirdPartyDuplicates extends CS_BatchWorker{
     
    public Static final String BATCH_NAME = 'ThirdPartyActualBatch';
    public Static final String SEPARATOR_ARRAY = '\',\'';
    
    public CS_BatchDeleteThirdPartyDuplicates(List<String> customReportList) {
        super(BATCH_NAME);
                     
        this.queryString = 'SELECT Id, Name, Order_Line_Id__c, Report_Date__c' +
        ' FROM Third_Party_Actual__c' +
        ' WHERE Custom_Report_Execution__r.Id IN (\'' + CS_utl_Array.join(customReportList, SEPARATOR_ARRAY) + '\') '+
        ' ORDER BY CreatedDate ASC';
    }
     
    /**
    * Implements schedulable execute method
    * @param SC SchedulableContext
    */
    public override void execute(SchedulableContext SC) {
        execute();
    }
     
    public override void doWork(List<SObject> SOjbectThirdPartyActualList) {
        Set<Date> reportDates = new Set<Date>();
        Set<String> orderLineIds = new Set<String>();
        
        List<Third_Party_Actual__c> thirdPartyActualList = new List<Third_Party_Actual__c>();
         
        if(!SOjbectThirdPartyActualList.isEmpty()){
             
             for(sObject currentObj : SOjbectThirdPartyActualList){
                 reportDates.add((Date)currentObj.get('Report_Date__c'));
                 orderLineIds.add((String)currentObj.get('Order_Line_Id__c'));
             }
             
             thirdPartyActualList = 
             [
                 SELECT Id, Report_Date__c, Order_Line_Id__c
                 FROM   Third_Party_Actual__c
                 WHERE  Report_Date__c IN :reportDates 
                 AND    Order_Line_Id__c IN :OrderLineIds
                 ORDER BY CreatedDate ASC
             ];
             
             Map<String, Third_Party_Actual__c> checkForDuplicateMap = new Map<String, Third_Party_Actual__c>();
             Set<Third_Party_Actual__c> duplicatesToDeleteSet = new Set<Third_Party_Actual__c>();
             
             for(Third_Party_Actual__c currentActual : thirdPartyActualList){
                 
                 String keyString = String.valueOf(currentActual.Order_Line_Id__c) + '--' + String.valueOf(currentActual.Report_Date__c);
                 
                 if(checkForDuplicateMap.get(keyString) != null){
                     duplicatesToDeleteSet.add(checkForDuplicateMap.get(keyString));
                     checkForDuplicateMap.put(keyString, currentActual);
                 } else {
                     checkForDuplicateMap.put(keyString, currentActual);
                 }
             }
             
             List<Third_Party_Actual__c> duplicatesToDelete = new List<Third_Party_Actual__c>();
             duplicatesToDelete.addAll(duplicatesToDeleteSet);
             
             DELETE duplicatesToDelete;
         }

    }
}
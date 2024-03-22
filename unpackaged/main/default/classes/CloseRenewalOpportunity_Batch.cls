/*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Batch job to 
History

<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
global class CloseRenewalOpportunity_Batch implements Database.Batchable<sObject>{
    global date todayDate = date.today();
    string query ;
    boolean isExpired = false;
    global CloseRenewalOpportunity_Batch(){
        this.query = 'SELECT id,Recordtypeid,Approval_Status__c,byAuto__c,Account.Subscription_End_Date__c, StageName, Loss_Reason__c,closeDate FROM Opportunity WHERE (StageName = \'new\' or StageName = \'Proposal\') and Order_Type_Clone__c = \'Contract - Renewal\'' ;
        system.debug(query);
    }
    global System.Iterable<sObject> start(Database.BatchableContext jobId) {
        return Database.getQueryLocator(query);
    }
    
    global Void execute(Database.BatchableContext jobId, List<sObject> recordList) {
        List<Opportunity> ToUpdateOpp = new List<Opportunity>();
        Map<String,String> MapOppRT = new Map<String,String>();
        System.debug(recordList);
        for (RecordType rt : [SELECT Id,Name FROM RecordType WHERE SObjectType='Opportunity']){
            MapOppRT.put(rt.Name,rt.Id);
        } 
        for(sObject obj : recordList) {
            Opportunity Opp = (Opportunity)obj;
            if (Opp.recordtypeid == mapOppRT.get('B2C') && todayDate >= Opp.CloseDate){
               System.debug(Opp.iD + ' Closed Lost');
                Opp.StageName = 'Closed Lost';
                Opp.Loss_Reason__c = 'Expired Offer';
                Opp.byAuto__c = true;
                ToUpdateOpp.add(Opp);
            }      
        }
        if(toUpdateOpp.size()>0){
            system.debug('Update');
            Update toUpdateOpp;
        }
    }
    global Void finish(Database.BatchableContext jobId) {
    }
}
global class ClosedRenewal_UpdateCloseDate implements Database.Batchable<sObject>{
    global date todayDate = date.today();
    string query ;
    boolean isExpired = false;
    
    global ClosedRenewal_UpdateCloseDate(){
        this.query = 'SELECT id,Recordtypeid,Approval_Status__c,byAuto__c,Account.Subscription_End_Date__c, StageName, Loss_Reason__c,closeDate FROM Opportunity WHERE (StageName = \'New\' or StageName = \'Proposal\') and (Order_Type_Clone__c = \'Contract - Renewal\' OR Opportunity_Type__c = \'B2C - Renewal\')' ;
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
            system.debug('update_date:'+ Opp.Account.Subscription_End_Date__c.addDays(1));
            system.debug('update_date:'+ Opp.CloseDate);
            system.debug('update_date:'+ Opp.recordtypeid);
            system.debug('update_date:'+ mapOppRT.get('B2C'));
            if (Opp.recordtypeid == mapOppRT.get('B2C') && Opp.Account.Subscription_End_Date__c.addDays(1) == Opp.CloseDate){
                Date dateField = Opp.Account.Subscription_End_Date__c;
                dateField = dateField.addMonths(1);
                Integer numberOfDays = Date.daysInMonth(dateField.year(), dateField.month());
                Date lastDayOfMonth = Date.newInstance(dateField.year(), dateField.month(), numberOfDays);
                Opp.CloseDate = lastDayOfMonth;
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
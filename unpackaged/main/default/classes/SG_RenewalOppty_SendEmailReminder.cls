//TEST CLASS: SG_RenewalOppty_SendEmailReminder_Test
global class SG_RenewalOppty_SendEmailReminder implements Database.Batchable<sObject>,Schedulable {
    public void execute(SchedulableContext sc){  
        DataBase.executeBatch(new SG_RenewalOppty_SendEmailReminder(), 200);  
    }
    
    public Database.QueryLocator start(Database.BatchableContext bC){
        string query='select Id,Payment_Next_Reminder_Date__c,SG_Payment_Link_Expiry__c ,Guruland_Link_Created_Date__c from Quote where Status =\'Pending Online Payment\' and Quote_Type__c=\'B2C - Renewal\' and country__c=\'Singapore\'and Agent_Accepted_Time__c=null and Guruland_Link_Created_Date__c!=null and IsSyncing = true and recordtype.name = \'B2C\' and SG_Payment_Link_Expiry__c >  Today  ';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bC, List<quote> recordList) {
        DateTime dT = System.now(); 
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day()); // Converts dateTime into Date field
        List<Quote> toUpdateQuote = new List<Quote>();
        for(Quote quo :recordList ){
            if(quo.Payment_Next_Reminder_Date__c == null){
                
                DateTime guruDt = quo.Guruland_Link_Created_Date__c;
                Date guruDtDate = date.newinstance(guruDt.year(), guruDt.month(), guruDt.day());  // Converts dateTime into Date field
                
                if(myDate == guruDtDate.adddays(3)){
                    quo.Payment_Next_Reminder_Date__c  = quo.Guruland_Link_Created_Date__c.adddays(3);  
                }
            }else{
                DateTime reminderDt = quo.Payment_Next_Reminder_Date__c;
                Date reminderDtmyDate = date.newinstance(reminderDt.year(), reminderDt.month(), reminderDt.day());  // Converts dateTime into Date field
                if(myDate == reminderDtmyDate.adddays(3)){
                    //   if(DATEVALUE(System.today()) == DATEVALUE(quo.Payment_Next_Reminder_Date__c.adddays(3))){
                    quo.Payment_Next_Reminder_Date__c=  quo.Payment_Next_Reminder_Date__c.adddays(3);
                }      
            }
            toUpdateQuote.add(quo);
        }
        System.debug(toUpdateQuote);
        if(!toUpdateQuote.isempty()){
            update toUpdateQuote;
        }
    }
    
    public void finish(Database.BatchableContext bC) {
        
    }
}
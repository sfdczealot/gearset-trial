global class DailyBatchToActivateCampaign implements DataBase.Batchable<Sobject>, Schedulable, Database.Stateful{
    
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(this, 100);
    }
    
    public Map<String,List<Id>> mapOfStartTimeVsCamId = new Map<String,List<Id>>();
    public Map<String,List<Id>> mapOfEndTimeVsCamId = new Map<String,List<Id>>();
    public List<Id> listOfCmpIds = new List<Id>();
    
    global DataBase.QueryLocator start(DataBase.BatchableContext Bc){
        return Database.getQueryLocator('Select id,StartDate, Campaign_Start_DateTime__c, EndDate, Campaign_End_DateTime__c,Country__c From Campaign where ((Campaign_Start_DateTime__c !=null AND Campaign_Start_DateTime__c = today) OR (Campaign_End_DateTime__c !=null AND Campaign_End_DateTime__c  = today )) AND (NOT recordtype.name LIKE \'%B2B%\')');
    }
    
    global void execute(DataBase.BatchableContext Bc,List<Campaign> campList) {
        Map<Id,Campaign> toUpdateCamps = new Map<Id,Campaign>();
        for(Campaign cam : campList) {
            if(
                cam.Campaign_Start_DateTime__c!=null && 
                cam.Campaign_Start_DateTime__c.date() == System.today() && 
                cam.Campaign_Start_DateTime__c > system.now()
            ) {
                String startTime = String.valueOf(cam.Campaign_Start_DateTime__c);
                if(!mapOfStartTimeVsCamId.containsKey(startTime)) {
                    mapOfStartTimeVsCamId.put(startTime,new List<Id>());
                }
                mapOfStartTimeVsCamId.get(startTime).add(cam.Id);
                
            } else if(cam.Campaign_Start_DateTime__c!=null && cam.Campaign_Start_DateTime__c.date() == System.today()) {
                if(!toUpdateCamps.containsKey(cam.Id)) {
                    toUpdateCamps.put(cam.Id,cam);   
                }
                toUpdateCamps.get(cam.Id).IsActive = true;
                listOfCmpIds.add(cam.Id);
            }
            
            if(
                cam.Campaign_End_DateTime__c!=null && 
                cam.Campaign_End_DateTime__c.date() == System.today() && 
                cam.Campaign_End_DateTime__c > system.now()
            ) {
                
                String endTime = String.valueOf(cam.Campaign_End_DateTime__c);
                if(!mapOfEndTimeVsCamId.containsKey(endTime)) {
                    mapOfEndTimeVsCamId.put(endTime,new List<Id>());
                }
                mapOfEndTimeVsCamId.get(endTime).add(cam.Id);
                
            } else if(cam.Campaign_End_DateTime__c!=null && cam.Campaign_End_DateTime__c.date() == System.today()) {
                if(!toUpdateCamps.containsKey(cam.Id)) {
                    toUpdateCamps.put(cam.Id,cam);   
                }
                toUpdateCamps.get(cam.Id).IsActive = false;
            }
        }
        
        if(!toUpdateCamps.isEmpty()) {
            update toUpdateCamps.values();
        }
    }
    
    global void finish(DataBase.BatchableContext Bc){
        
        if(!mapOfStartTimeVsCamId.isEmpty())
        {
            for(String startTime : mapOfStartTimeVsCamId.keyset()){
                
                DateTime strTime = DateTime.valueOf(startTime);
                String cronExpression = '' + strTime.second() + ' ' + strTime.minute() + ' ' + strTime.hour() + ' ' + strTime.day() + ' ' + strTime.month() + ' ? ' + strTime.year();
                if(!Test.isRunningTest())
                    System.schedule('Job Submitted At ' + String.valueOf(Datetime.now()) + ' for Campaign ' + mapOfStartTimeVsCamId.get(startTime)[0] + ' at ' + startTime ,cronExpression, new SchedulerToActivateCamp(mapOfStartTimeVsCamId.get(startTime),'Active'));
            }
        }
        
        if(!mapOfEndTimeVsCamId.isEmpty())
        {
            for(String endTime : mapOfEndTimeVsCamId.keyset()){
                
                DateTime strTime = DateTime.valueOf(endTime);
                String cronExpression = '' + strTime.second() + ' ' + strTime.minute() + ' ' + strTime.hour() + ' ' + strTime.day() + ' ' + strTime.month() + ' ? ' + strTime.year();
                if(!Test.isRunningTest())
                    System.schedule('Job Submitted At ' + String.valueOf(Datetime.now()) + ' for Campaign ' + mapOfEndTimeVsCamId.get(endTime)[0]  + ' at ' + endTime ,cronExpression, new SchedulerToActivateCamp(mapOfEndTimeVsCamId.get(endTime),'InActive'));
            }
        }
        
        if(!listOfCmpIds.isEmpty())
        {
            SchedulerToActivateCamp.RunCRE(listOfCmpIds);
        }
        
    }
    
}
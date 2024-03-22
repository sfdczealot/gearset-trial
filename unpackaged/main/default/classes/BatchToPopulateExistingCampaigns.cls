public class BatchToPopulateExistingCampaigns implements Database.Batchable<Sobject>{
    
    public Database.QueryLocator start(Database.BatchableContext Bc){
        return Database.getQueryLocator('Select id,StartDate,Campaign_Start_DateTime__c,EndDate,Campaign_End_DateTime__c From Campaign where (StartDate!=null OR EndDate!=null)  AND (NOT recordtype.name LIKE \'%B2B%\')');
    }
    
    public void execute(Database.BatchableContext Bc,List<Campaign> campList){
        
        Map<Id,Campaign> updateCampaign = new Map<Id,Campaign>();
        for(Campaign cam : campList){
            
            if(cam.StartDate!=null )
            {
                Date strDate = cam.StartDate;
                Datetime startTime = Datetime.newInstance(strDate.year(), strDate.month(), strDate.day(), 00, 00, 00);
               
                if(!updateCampaign.containsKey(cam.Id))
                    updateCampaign.put(cam.Id,cam);
                
                updateCampaign.get(cam.Id).Campaign_Start_DateTime__c = startTime;
            }
            
            if(cam.EndDate!=null ){
                Date enDate = cam.EndDate;
                Datetime endTime = Datetime.newInstance(enDate.year(), enDate.month(), enDate.day(), 23, 59, 00);
                
                if(!updateCampaign.containsKey(cam.Id))
                    updateCampaign.put(cam.Id,cam);
                
                updateCampaign.get(cam.Id).Campaign_End_DateTime__c = endTime;
            }
            
        }
        
        if(!updateCampaign.isEmpty())
        update updateCampaign.values();
    }
    
    public void finish(Database.BatchableContext Bc){
        
    }
}
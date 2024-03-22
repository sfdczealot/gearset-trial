public class PGBatchToActivateCampaign implements DataBase.Batchable<Sobject>,Schedulable{

    public void execute(SchedulableContext ctx) {
        Database.executeBatch(this, 100);
    }
    
    public DataBase.QueryLocator start(DataBase.BatchableContext Bc){
    	return Database.getQueryLocator('Select id,StartDate, IsActive,EndDate From Campaign where StartDate = today OR EndDate = Yesterday');
    }
    
    public void execute(DataBase.BatchableContext Bc,List<Campaign> campList){
        for(Campaign cam : campList){
            if(cam.StartDate == System.today()){
                cam.isActive = true;
            }else if(cam.EndDate == System.today().addDays(-1)){
                cam.isActive = false;
            }
        }
        
        Update campList;
    }
    
    public void finish(DataBase.BatchableContext Bc){
    
    }
}
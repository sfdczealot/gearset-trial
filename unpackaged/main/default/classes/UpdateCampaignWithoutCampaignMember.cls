public class UpdateCampaignWithoutCampaignMember implements DataBase.Batchable<Sobject>{
    
   
    public DataBase.QueryLocator start(DataBase.BatchableContext bc){
        
        string query = 'SELECT Id, EndDate,IsActive FROM Campaign where IsActive=true AND EndDate<TODAY';
        return DataBase.getQueryLocator(query);
        
    }
    
    public void execute(DataBase.BatchableContext bc,List<Campaign> CampaignList){
        
        for(Campaign cam : CampaignList){
            cam.IsActive = false;
        }
        
        update CampaignList;
        
    }
    
    public void finish(DataBase.BatchableContext bc){
        
    }
}
/*
* TestClass : BatchToUpdateCampaignMemberStatus_Test
*/
public class BatchToUpdateCampaignMemberStatus implements DataBase.Batchable<Sobject>,Schedulable {
    
    public void execute(SchedulableContext sc){
        
        DataBase.executeBatch(new BatchToUpdateCampaignMemberStatus(), 200);
        
    }
    
    public DataBase.QueryLocator start(DataBase.BatchableContext bc){
        
        string query = 'SELECT Id, CampaignId,Campaign.EndDate,Campaign.IsActive, Status FROM CampaignMember where Campaign.IsActive=true AND Campaign.EndDate<TODAY order by CampaignId ';
        return DataBase.getQueryLocator(query);
        
    }
    
    public void execute(DataBase.BatchableContext bc,List<CampaignMember> CampaignMemberList){
        
        Map<Id,Campaign> mapOfIdVSCampaign = new Map<Id,Campaign>();
        
        for(CampaignMember cmp: CampaignMemberList){
            Campaign cm = new Campaign();
            cm.Id = cmp.CampaignId;
            cm.IsActive = false;
            mapOfIdVSCampaign.put(cm.Id,cm);
            cmp.Status = 'Expired';
        }
        
        update mapOfIdVSCampaign.values();
        update CampaignMemberList;
        
    }
    
    public void finish(DataBase.BatchableContext bc){
        
        Database.executeBatch(new UpdateCampaignWithoutCampaignMember(),2000);
        
    }
}
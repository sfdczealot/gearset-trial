global class SchedulerToActivateCamp implements System.Schedulable {
    
    public List<Id> listOfCmpIds;
    public String active;
    
    global SchedulerToActivateCamp(List<Id> listOfCampaignIds, String actv ){
        listOfCmpIds = new List<Id>();
        listOfCmpIds = listOfCampaignIds;
        active = actv;        
    }
    
    global void execute(System.SchedulableContext context) {
        
        List<Campaign> toUpdateCampaigns = new List<Campaign>();
        if(listOfCmpIds!=null){
            for(Id campaignId : listOfCmpIds){
                Campaign cmp = new Campaign();
                cmp.Id = campaignId;
                if(active == 'Active'){
                    
                    cmp.IsActive = true;
                }
                else if(active == 'InActive'){
                    
                    cmp.IsActive = false;
                }
                toUpdateCampaigns.add(cmp);
            }
        }
        
        if(toUpdateCampaigns!=null)
            update toUpdateCampaigns;
        
        if(active == 'Active')
            RunCRE(listOfCmpIds);
        
        // To remove jobs from scheduled job list
        system.abortJob(context.getTriggerId());
        
    }
    
    public static void RunCRE(List<Id> listOfCmpIds){
        List<String> campaignIds=new List<string>();
        list<Id> ceIdList = new list<Id>();
        map<Id,String> ceQueryMap = new map<Id,String>();
        //to Fetch All SOQL Metadata
        map<string,string> nameVsQuery = new map<string,string>();
        for(Dynamic_SOQL__mdt meta : [Select SOQL_Query__c,Name__c from  Dynamic_SOQL__mdt]){
            nameVsQuery.put(meta.Name__c,meta.SOQL_Query__c);
        }
        List<Campaign_ELigibility__C> ceList =[select id,Campaign__r.RecordType.name,campaign__c,Run_Frequency__c,
                                               Next_run_scheduled__c,Criteria_Type__c,
                                               Rule_Name_Extension__c from campaign_eligibility__c 
                                               where Status__c='Active' 
                                               and campaign__r.IsActive=true
                                               and campaign__r.Id =:listOfCmpIds];
                                              
        
        for(Campaign_ELigibility__C ce:ceList)   {
            
            if(ce.Criteria_Type__c == 'SOQL' || ce.Criteria_Type__c == 'Custom Metadata'){
                if(String.isNotBlank(String.valueOf(ce.get('Rule_Name_Extension__c')))
                   && String.isNotBlank(String.valueOf(ce.get('Criteria_Type__c')))){
                       
                       if(ce.Criteria_Type__c == 'SOQL'){
                           ceIdList.add(ce.Id);
                           ceQueryMap.put((Id)ce.get('id'),String.valueOf(ce.get('Rule_Name_Extension__c')));
                       }else if(ce.Criteria_Type__c == 'Custom Metadata'){
                           if(nameVsQuery.containsKey(ce.Rule_Name_Extension__c) && String.isNotBlank(nameVsQuery.get(ce.Rule_Name_Extension__c))){
                               ceIdList.add(ce.Id);
                               ceQueryMap.put((Id)ce.get('id'),String.valueOf(nameVsQuery.get(ce.Rule_Name_Extension__c)));
                           }
                           
                       }
                       
                   }
                
            }else{
                campaignIds.add(ce.Campaign__c);
            }
        }  
        
        if(campaignIds.size() > 0){
            PreprocessorRuleEngine.startPreProcessing('Campaign Eligibility',null,campaignIds);
        }
        if(!ceIdList.isEmpty()){
            Database.executeBatch(new ProcessingBatchSOQL(ceQueryMap,ceIdList),2000);
        }
    }
}
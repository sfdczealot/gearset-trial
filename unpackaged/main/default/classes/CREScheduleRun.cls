//this class will execute only for where run frequency is set to hourly
public class CREScheduleRun implements System.Schedulable{
    
    public void execute(System.SchedulableContext context) {
        //Map<String,List<String>> campaignIdRecordTypeMap = new  Map<String,List<String>>();
        list<Id> ceIdList = new list<Id>();
    	map<Id,String> ceQueryMap = new map<Id,String>();
        
        List<String> campaignIds=new List<string>();
        //to Fetch All SOQL Metadata
        map<string,string> nameVsQuery = new map<string,string>();
        for(Dynamic_SOQL__mdt meta : [Select SOQL_Query__c,Name__c from  Dynamic_SOQL__mdt]){
            nameVsQuery.put(meta.Name__c,meta.SOQL_Query__c);
        }
        List<Campaign_ELigibility__C> ceList =[select id,Campaign__r.RecordType.name,campaign__c,Run_Frequency__c,
                                               Next_run_scheduled__c,Criteria_Type__c,
                                               Rule_Name_Extension__c from campaign_eligibility__c 
                                               where Next_run_scheduled__c <=: system.Now() 
                                               and Next_run_scheduled__c >=: system.Now().addMinutes(-59) and Status__c='Active' 
                                               and campaign__r.IsActive=true and Run_Frequency__c='Hourly'];
        
        for(Campaign_ELigibility__C ce:ceList)   {
            
           if((ce.Next_run_scheduled__c.format('HH')=='21' && ce.Next_run_scheduled__c.format('MM')== '00') || 
              (ce.Next_run_scheduled__c.format('HH')=='20' && ce.Next_run_scheduled__c.format('MM')!= '00')){
                ce.Next_run_scheduled__c=ce.Next_run_scheduled__c.addHours(12);
            }
            else{
                ce.Next_run_scheduled__c=ce.Next_run_scheduled__c.addHours(1);
            }
            
            /////
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
        update ceList;
        if(campaignIds.size() > 0){
            PreprocessorRuleEngine.startPreProcessing('Campaign Eligibility',null,campaignIds);
        }
        if(!ceIdList.isEmpty()){
            Database.executeBatch(new ProcessingBatchSOQL(ceQueryMap,ceIdList),2000);
        }    
       
    }
}
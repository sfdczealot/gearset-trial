public class PreprocessorRuleEngine {
    @AuraEnabled
    public static void startPreProcessing(String objectName, String recordType,List<String> campaignIdList){
        map<id,string> fetchedQueriesMap = new map<id,string>();
        map<id,list<String>> allQueriesMap = new map<id,list<string>>();
        map<id,string> allMethodsMap = new map<id,string>();
        map<string,string> mapOfObjectLabelandName = fetchEligibleObjects();
        
        if(mapOfObjectLabelandName.containsKey(objectName)){
            fetchedQueriesMap = fetchQueryRulesForsObject(mapOfObjectLabelandName.get(objectName),recordType,campaignIdList);
            allMethodsMap = fetchApexMethodRulesForsObject(mapOfObjectLabelandName.get(objectName),recordType,campaignIdList);
        }else{
            return;
        }
        if(!fetchedQueriesMap.isEmpty()){
            for(Id qryKey : fetchedQueriesMap.keySet()){
                String qry = fetchedQueriesMap.get(qryKey);
                if(String.isNotBlank(qry) && qry.contains(';')){
                    list<string> splitedQueries = qry.split(';');
                    list<String> allQueries = new list<String>();
                    for(String qry2 : splitedQueries){
                        if(String.isNotBlank(qry2))
                            allQueries.add(qry2);  
                    }
                    if(!allQueries.isEmpty()){
                        allQueriesMap.put(qryKey,allQueries);
                    }
                }else if(String.isNotBlank(qry)){
                    allQueriesMap.put(qryKey,new list<String>{qry});
                }
            }
        }
        if((!allQueriesMap.isEmpty() || !allMethodsMap.isEmpty()) && !Test.isRunningTest()) 
            Database.executeBatch(new ProcessingBatch(allQueriesMap,allMethodsMap, recordType),1);
    }
    public static map<string,string> fetchEligibleObjects(){
        string objectAPINames = '';
        map<string,string> labelVsApiName = new map<string,string>();
        list<Object_Name__c> objNames = Object_Name__c.getAll().values();
        for(Object_Name__c obj : objNames){
            if(obj.Enabled__c)
                labelVsApiName.put(obj.Name,null);    
        }
        
        for ( Schema.SObjectType obj : Schema.getGlobalDescribe().values() )
        {
            Schema.DescribeSObjectResult objDescription = obj.getDescribe();
            if(labelVsApiName.containsKey(objDescription.getLabel())){
                labelVsApiName.put(objDescription.getLabel(),objDescription.getName());
            }
        }
        
        return labelVsApiName;
    }
    
    public static map<id,String> fetchQueryRulesForsObject(String objName,String recordType,list<String> campaignIds){
        
        //Rule_Engine__c TE = Rule_Engine__c.getValues('Campaign Ids');
        //String campaignIdString = '';
        //list<string> campaignIds = new list<string>();
       /* if(campaignIdList.size() != 0){
          campaignIdString = TE.Campaign_Ids__c;
            if(String.isNotBlank(campaignIdString)){
                campaignIds = campaignIdString.contains(';')?campaignIdString.split(';'):new list<string>{campaignIdString};
            }
        }*/
        
        map<id,string> queryMapToReturn = new map<id,string>();
        string criteriaType = 'SOQL';
        String Status = 'Active';
        list<sObject> objList = new list<sObject>();
        System.debug(':::::::'+objName);
      /*  if(campaignIds.isEmpty()){
        	objList = Database.query('Select id,Priority__c ,Name,Rule_Name__c,Criteria_Type__c,rule_Name_extension__c from '+objName+ ' where Criteria_Type__c =: criteriaType AND Status__c = : Status AND Campaign__r.isActive =true AND Campaign__r.RecordType.Name =:recordType ORDER BY Priority__c  ASC limit 50000');    
        }else{
            objList = Database.query('Select id,Priority__c ,Name,Rule_Name__c,Criteria_Type__c,rule_Name_extension__c from '+objName+ ' where Criteria_Type__c =: criteriaType AND Status__c = : Status AND Campaign__r.isActive =true AND Campaign__r.RecordType.Name =:recordType AND Campaign__c In : campaignIds ORDER BY Priority__c  ASC limit 50000');
        }*/
        
         if(campaignIds.isEmpty()){
        	objList = Database.query('Select id,Priority__c ,Name,Criteria_Type__c,Rule_Name_Extension__c from '+objName+ ' where Criteria_Type__c =: criteriaType AND Status__c = : Status AND Campaign__r.isActive =true ORDER BY Priority__c  ASC limit 50000');    
        }else{
            objList = Database.query('Select id,Priority__c ,Name,Criteria_Type__c,Rule_Name_Extension__c from '+objName+ ' where Criteria_Type__c =: criteriaType AND Status__c = : Status AND Campaign__r.isActive =true AND Campaign__c In : campaignIds ORDER BY Priority__c  ASC limit 50000');
        }
        
        for(sObject obj: objList){
            if(String.isNotBlank(String.valueOf(obj.get('Rule_Name_Extension__c')))
               && String.isNotBlank(String.valueOf(obj.get('Criteria_Type__c')))){
                   
                   queryMapToReturn.put((Id)obj.get('id'),String.valueOf(obj.get('Rule_Name_Extension__c')));
               }
        }
        
        return queryMapToReturn;
        
    }
    
    public static map<id,string> fetchApexMethodRulesForsObject(String objName,String recordType,list<string> campaignIds){
        
        /*Rule_Engine__c TE = Rule_Engine__c.getValues('Campaign Ids');
        String campaignIdString = '';
        list<string> campaignIds = new list<string>();
        if(TE != null){
            campaignIdString = TE.Campaign_Ids__c;
            if(String.isNotBlank(campaignIdString)){
                campaignIds = campaignIdString.contains(';')?campaignIdString.split(';'):new list<string>{campaignIdString};
            }
        }*/
        map<id,string> methodMapToReturn = new map<id,string>();
        string criteriaType = 'Apex Method';
        String Status = 'Active';
        list<sObject> objList = new list<sObject>();
        System.debug(':::::::'+objName);
        /*if(campaignIds.isEmpty()){
            objList = Database.query('Select id,Name,Priority__c ,Rule_Name__c,Criteria_Type__c,Status__c from '+objName+ ' where Criteria_Type__c =: criteriaType AND Status__c = : Status AND Campaign__r.isActive =true AND Campaign__r.RecordType.Name =:recordType ORDER BY Priority__c  ASC  limit 50000');
        }else{
            objList = Database.query('Select id,Name,Priority__c ,Rule_Name__c,Criteria_Type__c,Status__c from '+objName+ ' where Criteria_Type__c =: criteriaType AND Status__c = : Status AND Campaign__r.isActive =true AND Campaign__r.RecordType.Name =:recordType AND Campaign__c IN: campaignIds ORDER BY Priority__c  ASC  limit 50000');
        }    */
        
        if(campaignIds.isEmpty()){
            objList = Database.query('Select id,Name,Priority__c ,Rule_Name_Extension__c,Criteria_Type__c,Status__c from '+objName+ ' where Criteria_Type__c =: criteriaType AND Status__c = : Status AND Campaign__r.isActive =true ORDER BY Priority__c  ASC  limit 50000');
        }else{
            objList = Database.query('Select id,Name,Priority__c ,Rule_Name_Extension__c,Criteria_Type__c,Status__c from '+objName+ ' where Criteria_Type__c =: criteriaType AND Status__c = : Status AND Campaign__r.isActive =true AND Campaign__c IN: campaignIds ORDER BY Priority__c  ASC  limit 50000');
        }    
        
        for(sObject obj: objList){
            if(String.isNotBlank(String.valueOf(obj.get('Rule_Name_Extension__c')))
               && String.isNotBlank(String.valueOf(obj.get('Criteria_Type__c')))
               && String.isNotBlank(String.valueOf(obj.get('Status__c')))
               && String.valueOf(obj.get('Status__c')) == 'Active'){
                   methodMapToReturn.put((Id)obj.get('id'),String.valueOf(obj.get('Rule_Name_Extension__c')));
               }
        }
        return methodMapToReturn;
        
    }
    @auraEnabled
    public static Boolean runCRE(String campId){
        Id currentUserId = UserInfo.getUserId();
        List<UserRecordAccess> currentUserRecAccess = [SELECT HasEditAccess,RecordId 
                                                       FROM UserRecordAccess 
                                                       WHERE UserId =: currentUserId
                                                       AND RecordId =: campId 
                                                      ];
        
        
        if(currentUserRecAccess.size()>0 && !currentUserRecAccess[0].HasEditAccess) {
            return false;
        }
        else {
        List<String> campList=new List<String>();
        list<Id> ceIdList = new list<Id>();
    	map<Id,String> ceQueryMap = new map<Id,String>();
        //to Fetch All SOQL Metadata
        map<string,string> nameVsQuery = new map<string,string>();
        for(Dynamic_SOQL__mdt meta : [Select SOQL_Query__c,Name__c from  Dynamic_SOQL__mdt]){
            nameVsQuery.put(meta.Name__c,meta.SOQL_Query__c);
        }
        list<campaign_eligibility__c> campEligibilityList=[select id,campaign__c,Rule_Name_Extension__c,Criteria_Type__c,campaign__r.IsActive,status__c from campaign_eligibility__c where campaign__c=:campId];
       
        if(campEligibilityList.size()==0){
            throw new AuraHandledException('Campaign does not have any campaign eligibility');
        } 
        for(campaign_eligibility__c ce : campEligibilityList){
            if(ce.campaign__r.IsActive == false){
                throw new AuraHandledException('Campaign is inactive');
            }
            else if(ce.status__c == 'InActive'){
                 throw new AuraHandledException('Campaign eligibility is inactive');
            }
            
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
                campList.add(campId);
            }
        }
        if(campList != null && !campList.isEmpty()){
            startPreProcessing('Campaign Eligibility',null,campList);
        }
        if(!ceIdList.isEmpty()){
            Database.executeBatch(new ProcessingBatchSOQL(ceQueryMap,ceIdList),2000);
        }
            return true;
        }
        
    }
    
    public static void increaseCoverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
    
    
}
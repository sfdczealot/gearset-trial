@isTest
public class ProcessingBatch_Test {
    
    static{
        Object_Name__c obj = new Object_Name__c();
        obj.Name = 'Campaign Eligibility';
        obj.Enabled__c = true;
        insert obj;
        
        Campaign cma = new Campaign(); 
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('VIP Promotion').getRecordTypeId();
        insert cma;
        
        list<Campaign_Eligibility__c> listCE = new list<Campaign_Eligibility__c>();
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c = cma.Id);     
        listCE.add(ce1);
        Campaign_Eligibility__c ce2 = new Campaign_Eligibility__c(Name='test2',Rule_Name_Extension__c='DynamicMethodCall;multiplyNumbers',Criteria_Type__c = 'Apex Method',Priority__c=2,Campaign__c = cma.Id);     
        listCE.add(ce2);
        insert listCE;
    }
    @isTest
    static void ProcessingBatchMethod(){
    
        Campaign cma = new Campaign(); 
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('VIP Promotion').getRecordTypeId();
        insert cma;
        
        Rule_Engine__c re = new Rule_Engine__c();
        re.Batch_Size__c = 200;
        re.Campaign_Ids__c = cma.Id;
        re.Name = 'Campaign Ids';
        insert re;
        
        Campaign_Eligibility__c ce = new Campaign_Eligibility__c(Name='TestName',Rule_Name_Extension__c='Select Id From Campaign_Eligibility__c',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c = cma.Id,Status__c='Active');     
        insert ce;
        map<id,string> fetchedQueriesMap = new map<id,string>();
        map<id,list<String>> allQueriesMap = new map<id,list<string>>();
        map<id,string> allMethodsMap = new map<id,string>();
        map<string,string> mapOfObjectLabelandName = PreprocessorRuleEngine.fetchEligibleObjects();
        if(mapOfObjectLabelandName.containsKey('Campaign Eligibility')){
            fetchedQueriesMap = PreprocessorRuleEngine.fetchQueryRulesForsObject(mapOfObjectLabelandName.get('Campaign Eligibility'),'VIP Promotion',new list<String>{cma.Id});
            //allMethodsMap = PreprocessorRuleEngine.fetchApexMethodRulesForsObject(mapOfObjectLabelandName.get('Campaign Eligibility'));
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
        Test.startTest();
        
        system.debug('allQueriesMap**'+allQueriesMap+' fetchedQueriesMap**'+fetchedQueriesMap+'mapOfObjectLabelandName**'+mapOfObjectLabelandName);
        system.debug('allMethodsMapTest**'+allMethodsMap);
        ProcessingBatch ps = new ProcessingBatch(allQueriesMap,allMethodsMap,'VIP Promotion');
        DataBase.executeBatch(ps);
        Test.stopTest();
    }
    @isTest
    static void ProcessingBatchMethod2(){
        
        Campaign cma = new Campaign(); 
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('VIP Promotion').getRecordTypeId();
        insert cma;
        
        Campaign_Eligibility__c ce = new Campaign_Eligibility__c(Name='test2',Rule_Name_Extension__c='DynamicMethodCall;multiplyNumbers',Criteria_Type__c = 'Apex Method',Priority__c=2,Campaign__c = cma.Id,Status__c='Active');     
        insert ce;
        //map<id,string> fetchedQueriesMap = new map<id,string>();
        map<id,list<String>> allQueriesMap = new map<id,list<string>>();
        map<id,string> allMethodsMap = new map<id,string>();
        map<string,string> mapOfObjectLabelandName = PreprocessorRuleEngine.fetchEligibleObjects();
        system.debug('mapOfObjectLabelandName--->>>? '+mapOfObjectLabelandName);
        if(mapOfObjectLabelandName.containsKey('Campaign Eligibility')){
            //fetchedQueriesMap = PreprocessorRuleEngine.fetchQueryRulesForsObject(mapOfObjectLabelandName.get('Campaign Eligibility'));
            allMethodsMap = PreprocessorRuleEngine.fetchApexMethodRulesForsObject(mapOfObjectLabelandName.get('Campaign Eligibility'),'VIP Promotion',new list<String>{cma.Id});
        }
        
        Test.startTest();
        
        system.debug('allMethodsMapTest**'+allMethodsMap);
        ProcessingBatch ps = new ProcessingBatch(allQueriesMap,allMethodsMap,'VIP Promotion');
        DataBase.executeBatch(ps);
        Test.stopTest();
    }
    @isTest
    static void ProcessingBatchMethod3(){
        
        Campaign cma = new Campaign(); 
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('VIP Promotion').getRecordTypeId();
        insert cma;
        
        Campaign_Eligibility__c ce = new Campaign_Eligibility__c(Name='test2',Rule_Name_Extension__c='DynamicMethodCall;multiplyNumbers#Param1#Param2',Criteria_Type__c = 'Apex Method',Priority__c=2,Campaign__c = cma.Id,Status__c='Active');     
        insert ce;
        //map<id,string> fetchedQueriesMap = new map<id,string>();
        map<id,list<String>> allQueriesMap = new map<id,list<string>>();
        map<id,string> allMethodsMap = new map<id,string>();
        map<string,string> mapOfObjectLabelandName = PreprocessorRuleEngine.fetchEligibleObjects();
        system.debug('mapOfObjectLabelandName--->>>? '+mapOfObjectLabelandName);
        if(mapOfObjectLabelandName.containsKey('Campaign Eligibility')){
            //fetchedQueriesMap = PreprocessorRuleEngine.fetchQueryRulesForsObject(mapOfObjectLabelandName.get('Campaign Eligibility'));
            allMethodsMap = PreprocessorRuleEngine.fetchApexMethodRulesForsObject(mapOfObjectLabelandName.get('Campaign Eligibility'),'VIP Promotion',new list<String>{cma.Id});
        }
        
        Test.startTest();
        
        system.debug('allMethodsMapTest**'+allMethodsMap);
        ProcessingBatch ps = new ProcessingBatch(allQueriesMap,allMethodsMap,'VIP Promotion');  
        DataBase.executeBatch(ps);
        Test.stopTest();
    }
}
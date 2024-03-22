public class AgentRecommendation_cc {
    
    public class responseWrapper{
        @auraEnabled public list<EssentialWrapper> essentialList;
        @auraEnabled public list<String> essentialLabels;
    }
    public class EssentialWrapper{
        
        @auraEnabled public String Name;	
        @auraEnabled public String validity;
        @auraEnabled public map<String,object> essentials;
        @auraEnabled public boolean isRecommended;
        @auraEnabled public Decimal price;
        @auraEnabled public Decimal perDay;
    }
    @auraEnabled
    public static responseWrapper getRecommendedPkg(String recID){
        responseWrapper rw = new responseWrapper();
        String packageName;
        list<EssentialWrapper> essentialList = new list<EssentialWrapper>();
        Opportunity opp = [select id,Account.agentNet_ID__c from Opportunity where id =: recID];
        List<cspmb__Price_Item__c> commercialProdList = [Select id,name, Essential_JSON__c , cspmb__One_Off_Charge__c 
                                                         , cspmb__Contract_Term__c 
                                                         from cspmb__Price_Item__c 
                                                         where Bundle_Only__c =false and
                                                         cspmb__Currency_Code__c ='SGD' and
                                                         cspmb__is_active__c  =true and
                                                         cspmb__Product_Definition_Name__c  ='B2C subscription' and 
                                                         Effective_Today__c =true order by cspmb__Price_Item_Code__c	];
        
        //system.debug(essentialMap);
        String agentID= opp.Account.agentNet_ID__c ;
        String RootEndpoint;
        String apiKey;
        Map<string,string> reqHeaders = new Map<string,string>();
        HTTPResponse response;
        if(runningInASandbox()){
            RootEndpoint = label.PG_LABEL_agent_packageAPI_SB+'/'+agentID;
            apiKey=label.PG_LABEL_agent_packageAPIKey_SB;
        } else{
            RootEndpoint = label.PG_LABEL_agent_packageAPI+'/'+agentID;
            apiKey=label.PG_LABEL_agent_packageAPIKey;
        }
        
        reqHeaders.put('x-api-key',apiKey);
        reqHeaders.put('X-Market', 'SG');
        List<String> labels=new List<String>();
                if(!test.isRunningTest())
        response = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,'','GET',false,false,null,null);
        else{
            response = new HTTPResponse();
            response.setStatusCode(200);
              response.setBody('{"agentId": "10341895", "recommend": {"action": "remain", "score": 0.0, '+
                               +'"package": {"name": "BUSINESS", "concurrentListingProvided": 120.0, '+
                               +'"commercialListingEnabled": "true", "adCreditsProvided": 37000.0}}, "reasons": '+
                               +'[{"factor": "ad_credits_consumed", "recommended": false}, '+
                               +'{"factor": "avg_monthly_concurrent_listings", "recommended": true}, '+
                               +'{"factor": "commercial_listings_posted", "recommended": false}], "usedLastYear": '+
                               +'{"adCreditsConsumed": 31959.0, "commercialListingsPosted": 12.0, '+
                               +'"avgMonthlyConcurrentListings": 4.0}, '+
                               +'"currentPackage": {"name": "BUSINESS", "concurrentListingProvided": 120.0, "commercialListingEnabled": "true", "subscriptionStartDate": "2021-04-02", "adCreditsProvided": 37000.0, "subscriptionEndDate": "2022-04-01"}, "validity": {"days_before_subscription_end_date": 15, "isValid": true, "reason": "Agent_id"}}');
        
        }
        if(response.getStatusCode() == 200) { 
            String resBody=response.getBody();
            map<String, object> responseJson = (map<String, object>)JSON.deserializeUntyped(resBody);
            map<String, object> recommended = (map<String, object>)responseJson.get('recommend');
            map<String, object> packageMap = (map<String, object>)recommended.get('package');
            packageName = (String) packageMap.get('name');
            system.debug(packageName);
            

           
            for(cspmb__Price_Item__c cp : commercialProdList){
                
                EssentialWrapper ew = new EssentialWrapper();
                if(packageName == cp.name){
                    ew.isRecommended = true;
                } else
                    ew.isRecommended = false;
                map<String, object> essentialJson = (map<String, object>)JSON.deserializeUntyped(cp.Essential_JSON__c);
                map<String, object> ess = (map<String, object>)essentialJson.get('Essentials');

                system.debug(ess);
                for(string k : ess.keySet()){
                    system.debug('*'+k+'*');
                }
                ew.essentials=ess;
                ew.name=cp.name;
               /* ew.Concurrent_Listings=(String)essentialJson.get('Concurrent Listings');
                ew.Floor_Plans=(String)essentialJson.get('Floor Plans/mnth');
                ew.Ad_Credits=(String)essentialJson.get('Ad Credits');
                ew.Commercial_Listing=(String)essentialJson.get('Commercial Listing');
                ew.Agent_Profile=(String)essentialJson.get('Agent Profile');*/
                ew.price= cp.cspmb__One_Off_Charge__c ;
                ew.validity=cp.cspmb__Contract_Term__c+' mths';
                ew.perDay = (cp.cspmb__One_Off_Charge__c/365).setScale(2,System.RoundingMode.CEILING); 
                essentialList.add(ew);
                
                rw.essentialList= essentialList;
                rw.essentialLabels = labels;
                system.debug(ew);
            }
        }
        else{
            map<String, object> responseJson = (map<String, object>)JSON.deserializeUntyped(response.getBody());
            
            throw new AuraHandledException ((String)responseJson.get('message'));
        }
        
       /* for(String label : essentialList[0].essentials.keySet())
        labels.add(label);*/
        
         //rw.essentialList=essentialList;
        //rw.
        system.debug(essentialList);
        return rw;        
    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}
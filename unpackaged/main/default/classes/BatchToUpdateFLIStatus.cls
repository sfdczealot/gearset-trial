global class BatchToUpdateFLIStatus implements Database.Batchable<sObject>, Database.allowscallouts {
    global String country;
    global BatchToUpdateFLIStatus(String country){
        this.country = country;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        
         return Database.getQueryLocator('Select id,Flight_Beginning_Line_Item__c,csdf__Status__c,Listing_ID__c,Served_By__c,csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c from csdf__Fulfilment_Item__c where Flight_Beginning_Line_Item__c= today and (csdf__Status__c = \'ready\' OR csdf__Status__c = \'active\') and Listing_ID__c != null and Served_By__c = \'developer listings\' and csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c =: country');
        //return Database.getQueryLocator('Select id,Flight_Beginning_Line_Item__c,csdf__Status__c,Listing_ID__c,Served_By__c,csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c from csdf__Fulfilment_Item__c where Flight_Beginning_Line_Item__c>= today and (csdf__Status__c = \'ready\' OR csdf__Status__c = \'reserved\') and Listing_ID__c != null and Served_By__c = \'developer listings\' and csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c =: country');
    }   
    global void execute(Database.BatchableContext BC, List<csdf__Fulfilment_Item__c> scope) {
        Set<String> listingids = new Set<String>();
        Map<String,csdf__Fulfilment_Item__c> listingFLIMap = new  Map<String,csdf__Fulfilment_Item__c>();
        String RootEndpoint;
        String region;
        String locale;
        if(this.country == 'Indonesia'){
            RootEndpoint = label.PG_LABEL_Listing_Search_ID_Endpoint;
            region = 'id';  
            locale='id';
        } else if(this.country == 'Malaysia'){
            RootEndpoint = label.PG_LABEL_Listing_Search_MY_Endpoint;
            region = 'my'; 
            locale='en';
        }else if(this.country == 'Thailand'){
            RootEndpoint = label.PG_LABEL_Listing_Search_TH_Endpoint;
            region = 'th';  
            locale='en';
        }
        String token =  DeveloperListingInventoriesCheck.getToken(country);
        
        for(csdf__Fulfilment_Item__c FLI : scope){
            listingFLIMap.put(FLI.Listing_ID__c.replaceAll(',',''),FLI);
            listingids.add(FLI.Listing_ID__c.replaceAll(',',''));
            
        }
        Map<string,string> reqHeaders = new Map<string,string>();
        reqHeaders.put('Authorization', 'Bearer '+token);
        
        RootEndpoint += '/v1/listings?region='+region+'&locale='+locale+'&limit=100&page=1';
        
        for(String listingid : listingids) {
            RootEndpoint += '&listing_id='+listingid; 
        } 
        RootEndpoint += '&featured_listing_limit=1&premium_project_listing_limit=1';
        
        HTTPResponse res;
        if(test.isRunningTest()){
            String resString = '{ "help": "https://data.gov.sg/api/3/action/help_show?name=datastore_search","accessToken":"dguejsh279309393","listings":[{"isPremiumProjectListing":"true" }], "success": true, "result": { "resource_id": "a41ce851-728e-4d65-8dc5-e0515a01ff31", "fields": [ { "type": "int4", "id": "_id" }, { "type": "text", "id": "salesperson_name" }, { "type": "text", "id": "registration_no" }, { "type": "text", "id": "registration_start_date" }, { "type": "text", "id": "registration_end_date" }, { "type": "text", "id": "estate_agent_name" }, { "type": "text", "id": "estate_agent_license_no" }, { "type": "int8", "id": "_full_count" }, { "type": "float4", "id": "rank" } ], "q": "CEACHECK1","records": [ { "registration_end_date": "2019-12-31", "estate_agent_license_no": "AGENCYCEA1", "salesperson_name": "UNIT TEST CEA CHECK", "registration_no": "CEACHECK1", "rank": 0.0573088, "_full_count": "1", "registration_start_date": "2013-11-27", "estate_agent_name": "UNIT TEST AGENCY", "_id": 29498 } ], "_links": { "start": "/api/action/datastore_search?q=R017154B&resource_id=a41ce851-728e-4d65-8dc5-e0515a01ff31", "next": "/api/action/datastore_search?q=R017154B&offset=100&resource_id=a41ce851-728e-4d65-8dc5-e0515a01ff31" }, "total": 1 }}';
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(resString);
        }else{
            res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,null,'GET',false,false,null,null);
        }
        String resBody=res.getBody();
        resBody = resBody.replaceAll('\n','').replaceAll('\r','');
        map<String, object> responseJson = (map<String, object>)system.JSON.deserializeUntyped(resBody);
        List<Object> listingList = ( List<Object>)responseJson.get('listings');
        Map<integer,Object> premiumMap= new Map<integer,Object>();
        for(Object obj : listingList){
            map<String, object> singleListing =  (map<String, object> )obj;
            premiumMap.put((integer)singleListing.get('id'),singleListing.get('isPremiumProjectListing'));
        }
        
        for(Integer listingID : premiumMap.keySet()){
            if(listingFLIMap.containsKey(listingID+'')){
                if((boolean)premiumMap.get(listingID)==true){
                    listingFLIMap.get(listingID+'').csdf__status__c ='Delivering';
                }
            }
        }
        update listingFLIMap.values();
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    /* public static void execute(SchedulableContext SC) {
        BatchToUpdateFLIStatus obj = new BatchToUpdateFLIStatus('Indonesia');
        BatchToUpdateFLIStatus Malaysia_batch = new BatchToUpdateFLIStatus('Malaysia');
        BatchToUpdateFLIStatus Thailand_batch = new BatchToUpdateFLIStatus('Thailand');
       
        Database.executeBatch(obj);
        Database.executeBatch(Malaysia_batch);
        Database.executeBatch(Thailand_batch);
           
        
       
       
    }*/
}
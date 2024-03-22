public class callCEAEndpointClass {
    
    public static boolean ALLOW_EXCEPTION = true;
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    @AuraEnabled
    public static void  verifyCEADetails(String agentID,String oppId,String quoteNum){
        sendCEACallout(agentID, oppId, quoteNum, true);
    }
    public static boolean sendCEACallout(String agentID, String oppId, String quoteNum, boolean isUpdateRequired) {
        Boolean isSuccess = false;
        String responseMsg = 'verifyCEADetails method called';
        list<Quote> listQuote = [SELECT Id, Is_Agent_license_verified__c FROM Quote WHERE Quote_Number__c =: quotenum];
        if(listQuote.isEmpty()) {
            if(ALLOW_EXCEPTION) {
                throw new AuraHandledException(label.ADD_ERROR_UNDETECTED);
            } else {
                return false;
            }
        }
        Quote existingQuote = listQuote[0];
        Map<string,string> reqHeaders = new Map<string,string>();
        HTTPResponse response;
        string authToken;  
        boolean isEnabled = true;
        if(!Test.isRunningTest()) {
            Trigger_Execute__c TE = Trigger_Execute__c.getValues('checkCEA');
            isEnabled = TE.Enable_del__c;
        }
        
        if(isEnabled && !label.PG_LABEL_SkipCEAForOppty.contains(agentID) && !label.AGENT_BYPASS_CEA_CHECK.contains(agentID)) {
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.CEAAuthToken');
            DateTime cachedDate = (DateTime)orgPart.get('CEAauthTokenDate');
            String cachedToken = (String)orgPart.get('CEAauthToken');
            decimal decMinutes;
            if(cachedDate!=null){
                decMinutes = ((System.now().getTime())/1000/60) - ((cachedDate.getTime())/1000/60);
            }
            if(cachedToken == null || (decMinutes== null || decMinutes >= 45)){    
                authTOken=getAuth();
                if(authToken==null){
                    if(ALLOW_EXCEPTION) {
                        throw new AuraHandledException('<b>CEA Check</b><p>&nbsp;</p>Unable to retrieve Auth Token.. Please try after some time');
                    } else {
                        return false;
                    }
                }
            } else {
                authToken = cachedToken;
            }
            String RootEndpoint;
            if(String.isNotBlank(authToken)){
                if(runningInASandbox()){
                    RootEndpoint = label.PG_LABEL_CEAURL_SB+agentID;
                } else{
                    RootEndpoint = label.PG_LABEL_CEAURL+agentID;
                }
                reqHeaders.put('accept','*/*');
                reqHeaders.put('Authorization', 'Bearer '+authToken);
                if(Test.isRunningTest()) {
                    Http http = new Http();       
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(RootEndpoint);
                    req.setMethod('GET');
                    for(String headerKey : reqHeaders.keySet()){ 
                        req.setHeader(headerKey, reqHeaders.get(headerKey));
                    }
                    response = http.send(req);
                } else{
                    response = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,'','GET',false,false,null,null);
                }
                map<String, object> responseCEA = (map<String, object>)JSON.deserializeUntyped(response.getBody());
                responseMsg = String.valueOf(response.getStatusCode());
                if(responseCEA.containsKey('message') && responseCEA.get('message')!=null) {
                    responseMsg = responseMsg + ': ' + (String)responseCEA.get('message');
                } else {
                    responseMsg = responseMsg + ': ' + response.getStatus();
                }
                if(response.getStatusCode() == 200) {
                    if(responseCEA.containsKey('valid')){
                        if(!(Boolean)responseCEA.get('valid')) { 
                            if(ALLOW_EXCEPTION) {
                                throw new AuraHandledException('<b>CEA Check</b><p>&nbsp;</p>'+(String)responseCEA.get('message'));
                            } else {
                                return false;
                            }
                        }
                        else if((Boolean)responseCEA.get('valid')){
                            responseMsg = String.valueOf(response.getStatusCode()) + ': CEA verified Successfully';
                            isSuccess = true;
                            existingQuote.Is_Agent_license_verified__c = true;
                        }
                    }
                } else if(response.getStatusCode()==401) {
                    if(responseCEA.containsKey('name')){
                        if((String)responseCEA.get('name') == 'expired_jwt_token') {
                            getAuth();
                            verifyCEADetails(agentID,oppId,quoteNum);
                        } else {
                            if(ALLOW_EXCEPTION) {
                                throw new AuraHandledException('<b>CEA Check</b><p>&nbsp;</p> ERROR: '+(String)responseCEA.get('name') +' Message: '+(String)responseCEA.get('message'));
                            } else {
                                return false;
                            }
                        }
                    } else {   
                        if(ALLOW_EXCEPTION) {
                            throw new AuraHandledException('<b>CEA Check</b><p>&nbsp;</p> ERROR: '+(String)responseCEA.get('name') +' Message: '+(String)responseCEA.get('message'));
                        } else {
                            return false;
                        }
                    }
                }
                else {
                    if(ALLOW_EXCEPTION) {
                        throw new AuraHandledException('<b>CEA Check</b><p>&nbsp;</p> ERROR: '+(String)responseCEA.get('name') +' Message: '+(String)responseCEA.get('message'));   
                    } else {
                        return false;
                    }
                }
            }
        } else {
             responseMsg ='CEA check is skipped for Quote';
            OpportunityQuoteAPIStinger.createFeeditem(oppid,'<b>CEA Check</b><p>&nbsp;</p>CEA check is skipped for Quote '+quoteNum);
        }
        if(responseMsg.length()>255) {  
            responseMsg = responseMsg.substring(0,255);
        }
        existingQuote.CEA_Action_Message__c = responseMsg;
        if(isUpdateRequired) {
            update existingQuote;
        }
        return isSuccess;  
    }
    public static String getAuth(){
        Map<string,string> reqHeaders = new Map<string,string>();
        HTTPResponse res;
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.CEAAuthToken');
        String RootEndpoint;
        if(runningInASandbox()){
            RootEndpoint = label.PG_LABEL_CEAAuthURL;
        }
        else{
            RootEndpoint = label.PG_LABEL_CEAAuthURL;
        }
        reqHeaders.put('accept','*/*');
        reqHeaders.put('X-CLIENTID', label.PG_LABEL_CEAAuthClientId);
        reqHeaders.put('X-CLIENTSECRET',label.PG_LABEL_CEAAuthClientSecret);
        reqHeaders.put('Content-Type', 'application/x-www-form-urlencoded');
        String request = 'grant_type=client_credentials&scope=singapore&default_role=USER';
        
        if(Test.isRunningTest()) {
            String resString = '{ "help": "https://data.gov.sg/api/3/action/help_show?name=datastore_search","accessToken":"dguejsh279309393", "success": true, "result": { "resource_id": "a41ce851-728e-4d65-8dc5-e0515a01ff31", "fields": [ { "type": "int4", "id": "_id" }, { "type": "text", "id": "salesperson_name" }, { "type": "text", "id": "registration_no" }, { "type": "text", "id": "registration_start_date" }, { "type": "text", "id": "registration_end_date" }, { "type": "text", "id": "estate_agent_name" }, { "type": "text", "id": "estate_agent_license_no" }, { "type": "int8", "id": "_full_count" }, { "type": "float4", "id": "rank" } ], "q": "CEACHECK1", "records": [ { "registration_end_date": "2019-12-31", "estate_agent_license_no": "AGENCYCEA1", "salesperson_name": "UNIT TEST CEA CHECK", "registration_no": "CEACHECK1", "rank": 0.0573088, "_full_count": "1", "registration_start_date": "2013-11-27", "estate_agent_name": "UNIT TEST AGENCY", "_id": 29498 } ], "_links": { "start": "/api/action/datastore_search?q=R017154B&resource_id=a41ce851-728e-4d65-8dc5-e0515a01ff31", "next": "/api/action/datastore_search?q=R017154B&offset=100&resource_id=a41ce851-728e-4d65-8dc5-e0515a01ff31" }, "total": 1 }}';
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(resString);
        } else{
            res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,request,'GET',true,false,null,null);
        }
        if(res.getStatusCode() == 200)
        {
            String resBody=res.getBody();
            map<String, object> responseJson = (map<String, object>)JSON.deserializeUntyped(resBody);
            String token=(String) responseJSON.get('accessToken');
            orgPart.put('CEAauthToken',token );
            orgPart.put('CEAauthTokenDate', system.now());
            return (String) responseJSON.get('accessToken');
        }
        else
            return null;
    }
    
}
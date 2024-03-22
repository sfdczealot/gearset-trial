/*******************************************************************
 *	Author:         Suraj Bisht
 *  Class Name:     OliFieldHistoryDetailsCls
 *  Description:    Class to get oliHistoryRecord 
 * 	Test Class:     OliFieldHistoryDetailsCls_Test
 ******************************************************************/
public with sharing class OliFieldHistoryDetailsCls {
/*******************************************************************
 *	Author:         Suraj Bisht
 *  Description:    Method to initiate the callout to get the oliFieldHistoryRecords
 ******************************************************************/
   @AuraEnabled(continuation=true cacheable=true)
   public static Object  getHistoryDetails(String opportunityId){
        // Creating continuation object with a 40s timeout
        Continuation con = new Continuation(40);
        con.continuationMethod='processResponse';
        //adding request to continuation instance
        con.addHttpRequest(getRequest(opportunityId));
        return con;
    }
    
/*******************************************************************
 *	Author:         Suraj Bisht
 *  Description:    Method returning the request object
******************************************************************/
    private static HttpRequest getRequest(String opportunityId){
        String rootEndpoint;
        String rootEndpointKey;
        Map<string,string> reqHeaders = new Map<string,string>();
        if (SendNotify.runningInASandbox()) {
            rootEndpoint = label.PG_LABEL_Agent_Fulfilment_Endpoint_SB; 
            rootEndpointKey = label.PG_LABEL_sendNotifyKey_SB;
        }
        else{
            rootEndpoint = label.PG_LABEL_Agent_Fulfilment_Endpoint;
            rootEndpointKey = label.PG_LABEL_sendNotifyKey; 
        }    
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Cache-Control', 'no-cache');
        req.setEndpoint(rootEndpoint);
        req.setHeader('x-api-key', rootEndpointKey);
        req.setBody(JSON.serialize(new RequestCls(opportunityId)));
        return req;
    }
    
/*******************************************************************
 *	Author:         Suraj Bisht
 *  Description:    callback method processing the callout response
******************************************************************/
    @AuraEnabled(cacheable=true)
    public static Object processResponse(List<String> labels) {
        ResponseCls response =new ResponseCls();
        // response of 1st request
        HttpResponse res = Continuation.getResponse(labels[0]);
        Integer statusCode = res.getStatusCode();
        if(statusCode == 200 ){
            response.isSuccess=true;
            response.oliHistoryRecords=(list<Object>)JSON.deserializeUntyped(res.getBody());
        }
        // Handling continutation-specific error
        else if(statusCode >= 2000) {
            response.errorMessage='Continuation Error:  '+statusCode + ' - ' + res.getBody();
        } 
        else{
            response.errorMessage='HTTP Request Error:  '+statusCode + ' - ' + res.getBody();
        }
        return response;
    }
/*******************************************************************
 *	Author:         Suraj Bisht
 *  Description:    Class defining the callout request 
******************************************************************/
    class RequestCls { 
        String method='oliFieldHistoryGet';
        String payload;
        String region;  
        RequestCls(String oppId){
            this.payload=oppId;
        }
    }
/*******************************************************************
 *	Author:         Suraj Bisht
 *  Description:    Class defining the callout response 
******************************************************************/
    public class ResponseCls{
        @AuraEnabled public list<Object> oliHistoryRecords;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public Boolean isSuccess=false;
    }
}
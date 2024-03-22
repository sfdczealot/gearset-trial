/*
 * TestClass : GenericClassForCallout_Test
 */ 
public class GenricClassForCallout {
    
    public static HttpResponse GenericbasicAuthCallout(map<string,string> headerParameters,string Endpoint,String requestJson,String methodName, Boolean sendReqBody,Boolean setAsBlob, Blob blobData, Integer timeout){
        
        HttpResponse res;
        Http http = new Http();       
        HttpRequest req=getCalloutRequest(headerParameters,endpoint,requestJson,methodName,sendReqBody,setAsBlob,blobData,timeout);
        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
            }
        }catch(Exception exp){
            system.debug('Exception is :::::::'+exp.getMessage());
        }
        return res;   
    }
    public static HttpRequest getCalloutRequest(map<string,string> headerParameters,string endpoint,String requestJson,String methodName, Boolean sendReqBody,Boolean setAsBlob, Blob blobData, Integer timeout){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(methodName);
        if(timeout != null){
           req.setTimeout(timeout);  
        }
        if(!headerParameters.containsKey('User-Agent')){
            headerParameters.put('User-Agent', 'salesforce/apex');
        }  
        //iterate and set all headers
        for(String headerKey : headerParameters.keySet()){
            req.setHeader(headerKey, headerParameters.get(headerKey));
        }
        //sendReqBody will be false if reqBody is not needed
        if(sendReqBody && setAsBlob){
			req.setBodyasBlob(blobData);            
        }else if(sendReqBody){
            req.setBody(requestJson);
        }
        return req;
    }
    public static Boolean runningInASandbox() {
        
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        
    }
}
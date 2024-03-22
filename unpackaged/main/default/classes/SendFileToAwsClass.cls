//Helper class for BatchToUpdPermUrlMarkEmailHis
//TEST CLASS : trigger_MarketingEmailHis_Test
public class SendFileToAwsClass {
    //This method is used to save the file in AWS and return URL of saved file
    public Static String getPermUrlAWS(String markEmailId,Blob data){
        map<string,string> reqHeaders = new map<string,string>();
        String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        
        String filename = markEmailId+'.html';
        
        AWS_Credential__c awscred=AWS_Credential__c.getValues('AwsCredential');
        String key =awscred.Key__c ;
        String secret =awscred.Secret__c ;
        String bucketname =awscred.BucketName__c ;
        String host =awscred.Host__c ; 
        String folder =awscred.Folder__c; //'/sandbox/'
        
        String endpoint='https://' + bucketname + '.' + host+ folder+filename;
        
        reqHeaders.put('Host', bucketname + '.' + host);
        reqHeaders.put('Content-Length', String.valueOf(data.size()));
        reqHeaders.put('Content-Encoding', 'base64');
        reqHeaders.put('Content-type','text/plain' );//'text/plain''text/csv'
        reqHeaders.put('Connection', 'keep-alive');
        reqHeaders.put('Date', formattedDateString);
        reqHeaders.put('ACL', 'bucket-owner-full-control');
        
        String stringToSign = 'PUT\n\ntext/plain\n'+formattedDateString +'\n/'+bucketname+folder+filename;
        String encodedStringToSign = EncodingUtil.urlEncode(stringToSign, 'UTF-8');
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
        String signed = EncodingUtil.base64Encode(mac);
        String authHeader = 'AWS' + ' ' + key + ':' + signed;
        
        reqHeaders.put('Authorization',authHeader);
        String decoded = EncodingUtil.urlDecode(encodedStringToSign , 'UTF-8');
        
        
        Http http = new Http();
        HTTPResponse res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,endpoint,'','PUT',true,true,data,null);
        
        if(!Test.isRunningTest() && res.getStatusCode() == 200){
            return endpoint;
        }else{
            return null;
        }
    }
    //This method is used to get the HTML file from the url
    public static String getContentFromUrl(String Url){
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Url);
        req.setMethod('GET');
        Http httpParam = new Http();
        HttpResponse res = httpParam.send(req);
        if(res.getStatusCode() == 200){
            return res.getBody();
        }else{
            return null;
        }
        
    }
}
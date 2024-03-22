/*******************************************************************
*   Author      : Suraj Bisht
*   Class Name  : AccountActionsCalloutHelper
*   Description : To define common method to be used in AccountActionsCtlr
*   Test Class  : AccountActionsCtlr_Test
******************************************************************/
public with sharing class AccountActionsCalloutHelper {
    private static Boolean isSandbox;
    public static map<String,String> mapOfCountryNameVsRegion=new map<String,String>{
        'malaysia'=>'my',
        'singapore'=>'sg',
        'thailand'=>'th',
        'indonesia'=>'in'
    };
    public static map<String,String> mapOfCountryNameVsMobileCode=new map<String,String>{
        'malaysia'=>'60',
        'singapore'=>'65',
        'thailand'=>'66',
        'indonesia'=>'62'
    };
/*******************************************************************
*   Author  : Suraj Bisht
*   Param 1 : set<string> agentIds -  agentsIds to be included in api
*   Param 2 : string country -  agent country
*   Param 3 : Boolean enable2FA - true if enabling 2FA else false
*   Return  : String - 2FA json request body 
*   Description: To get the 2FA api request body
******************************************************************/
    public static String getUpdate2FAApiRequestBody(set<string> agentIds,string country,Boolean enable2FA){
        TwoFARequestCls obj2FARequest=new TwoFARequestCls(new list<string>(agentIds),mapOfCountryNameVsRegion.get(country),enable2FA);
        return JSON.serialize(obj2FARequest);
    }

/*******************************************************************
*   Author      : Suraj Bisht
*   Return      : String rootEndpoint - api endpoint url  
*   Description : Returning 2FA api endpoint url based on environment
******************************************************************/
    public static String get2FAApiEndpoint(){
        String rootEndpoint;
        if(runningInASandbox()){
            rootEndpoint = Label.Update_2FA_API_STAGING_ENDPOINT_URL;
        }
        else{   
            rootEndpoint = Label.Update_2FA_API_PRODUCTION_ENDPOINT_URL;
        }
        return rootEndpoint;
    }
/*******************************************************************
*   Author  : Suraj Bisht
*   Return  : String api endpoint based on environment
*   Description: Returning messenger api endpoint url based on environment
******************************************************************/
    public static String getsendSMSApiEndpoint(){
        String rootEndpoint;
        if(runningInASandbox()){
            rootEndpoint = Label.Send_SMS_Staging_Api_Endpoint+'?access_token='+Label.Api_Static_Token;
        }
        else{   
            rootEndpoint = Label.Send_SMS_Api_Endpoint+'?access_token='+Label.Api_Static_Token;
        }
        return rootEndpoint;
    }

/*******************************************************************
*   Author      : Suraj Bisht
*   Return      : String rootEndpoint - api endpoint url  
*   Description : Returning audit detail api endpoint url based on environment
******************************************************************/
    public static String getAuthorDetailsApiEndpoint(){
        String rootEndpoint;
        if(runningInASandbox()){
            rootEndpoint =Label.Audit_Log_Author_Staging_Api_Endpoint;
        }
        else{   
            rootEndpoint = Label.Audit_Log_Author_Api_Endpoint;
        }
        return rootEndpoint;
    }
/*******************************************************************
*   Author      : Suraj Bisht
*   Return      : String rootEndpoint - api endpoint url  
*   Description : Returning section codes api endpoint url based on environment
******************************************************************/
    public static String getSectionCodeApiEndpoint(String countryCode){
        String rootEndpoint;
        if(runningInASandbox()){
            rootEndpoint =  Label.Audit_Log_Staging_Api_Endpoint+'/'+countryCode.tolowerCase()+'/sectionCode?limit=100&order=description';
        }
        else{   
            rootEndpoint =  Label.Audit_Log_Api_Endpoint+'/'+countryCode.tolowerCase()+'/sectionCode?limit=100&order=description';
        }
        return rootEndpoint;
    }
/*******************************************************************
*   Author      : Suraj Bisht
*   Return      : String rootEndpoint - api endpoint url  
*   Description : Returning action codes api endpoint url based on environment
******************************************************************/
    public static String getActionCodeApiEndpoint(String countryCode,String sectionCode){
        String rootEndpoint;
        if(runningInASandbox()){
            rootEndpoint = Label.Audit_Log_Staging_Api_Endpoint+'/'+countryCode.tolowerCase()+'/'+sectionCode+'/actionCode?limit=100&order=description';
        }
        else{   
            rootEndpoint = Label.Audit_Log_Api_Endpoint+'/'+countryCode.tolowerCase()+'/'+sectionCode+'/actionCode?limit=100&order=description';
        }
        return rootEndpoint;
    }
/*******************************************************************
*   Author      : Suraj Bisht
*   Return      : String rootEndpoint - api endpoint url  
*   Description : Returning audit log api endpoint url based on environment
******************************************************************/
    public static String getAuditLogApiEndpoint(string countryCode){
        String rootEndpoint;
        if(string.isNotBlank(countryCode)){
            if(runningInASandbox()){
                rootEndpoint = Label.Audit_Log_Staging_Api_Endpoint+'/'+countryCode.tolowerCase()+'/auditing';
            }
            else{   
                rootEndpoint = Label.Audit_Log_Api_Endpoint+'/'+countryCode.tolowerCase()+'/auditing';
            }
        }
        return rootEndpoint;
    }
/*******************************************************************
*   Author      : Suraj Bisht
*   Return      : Boolean - true if sandbox else false  
*   Description : Return true if code running in sandbox env
******************************************************************/
    public static Boolean runningInASandbox(){
        if(isSandbox == null){
            isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        }
        return isSandbox;
    }
    public static void setEditByHeaderDetails(map<string,string> reqHeaders,string agentNetId,Decimal webUserId){
        if(webUserId != null  ){
            reqHeaders.put('X-Logger-Edited-By',String.valueOf(webUserId));
        }
        if(String.isNotBlank(agentNetId)){
            reqHeaders.put('X-Logger-Edited-For',agentNetId);
        }
        //To avoid exception from test class in Auth.SessionManagement.getCurrentSession()
        if(!Test.isRunningTest()){
            reqHeaders.put('X-Logger-Edited-From',Auth.SessionManagement.getCurrentSession().get('SourceIp'));
        }  
    }
/*******************************************************************
*   Author      : Suraj Bisht
*   Class Name  : TwoFARequestCls
*   Description : To define 2FA request body
******************************************************************/
    class TwoFARequestCls{
        list<String> userIds;
        String region;
        Integer enable;
        Boolean syncSalesforce=false;
        public TwoFARequestCls(list<String> userIds,string region,boolean enable2FA){
            this.userIds=userIds;
            this.region=region;
            this.enable=enable2FA?1:0;
        }
    }
}
/*******************************************************************
*   Author      : Suraj Bisht
*   Class Name  : AccountActionsCtlr
*   Description : Controller class of update2FACmp
*   Test Class  : AccountActionsCtlr_Test
******************************************************************/
public with sharing class AccountActionsCtlr {
    private static FINAL ID USER_ID=UserInfo.getUserId();
    private static FINAL STRING TWOFA_ENABLED='Enabled';
    private static FINAL STRING TWOFA_DISABLED='Disabled';
    private static FINAL STRING SYSTEM_ADMIN_PROFILE='System Administrator';
    private static FINAL STRING PROPERTY_GURU_SENDER_NAME='Property Guru';
    private static FINAL STRING DDPROPERTY_SENDER_NAME='DD Property';
    static list<Error_Log__c> errorLogs=new list<Error_Log__c >();    
/*******************************************************************
*   Author  : Suraj Bisht
*   Param 1 : Boolean enable2FA - true if enabling 2FA else false
*   Param 2 : String agentId - agent record Id 
*   Return  : ResponseCls object 
*   Description: To intitate the 2FA callout 
******************************************************************/
    @AuraEnabled(continuation=true )
    public static Object updateAgent2FAInAgentNet(Boolean enable2FA,String agentId){
        ResponseCls response=new ResponseCls();
        list<Account> agentRecord=Database.query('select id,AgentNet_ID__c,Name,Country__c from Account where Id=:agentId');
        Boolean agentRecordEditAccess=[SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE  RecordId =:agentId and UserId=:USER_ID].HasEditAccess;
        if(agentRecord != null && !agentRecord.isEmpty()){
            String userQuery='select id,Webuser_ID__c,Profile.Name from user where Id=:USER_ID limit 1';
            Boolean thRegionProfile=FeatureManagement.checkPermission('TH_Region');
            Boolean myRegionProfile=FeatureManagement.checkPermission('MY_Region');
            Boolean sgRegionProfile=FeatureManagement.checkPermission('SG_Region');
            
            list<User> objUser=Database.query(String.escapeSingleQuotes(userQuery));
            if(String.isBlank(agentRecord[0].Country__c) || String.isBlank(agentRecord[0].AgentNet_ID__c)){
                response.errorMessage=Label.Update_2FA_Insuffient_Data_Error_Message;
                return response;
            }
            else if( objUser[0].Profile.Name != SYSTEM_ADMIN_PROFILE && !Test.isRunningTest()){
                if(!agentRecordEditAccess || ( agentRecord[0].Country__c == Label.THAILAND_REGION && !thRegionProfile ) || ( !(sgRegionProfile || myRegionProfile)  && (agentRecord[0].Country__c == Label.MALAYSIA_REGION || agentRecord[0].Country__c == Label.SINGAPORE_REGION ))){
                    response.errorMessage=(agentRecordEditAccess)?Label.Update_2FA_Region_Error_Message:Label.Update_2FA_Insufficient_Edit_Access_Error_Message;
                    return response;
                }   
            }
            String token = DeveloperListingInventoriesCheck.getToken(agentRecord[0].Country__c.tolowerCase());
            //Got access token 
            if(String.isNotBlank(token)){
                map<string,string> reqHeaders = new map<string,string>();
                reqHeaders.put('Authorization', 'Bearer '+token);
                AccountActionsCalloutHelper.setEditByHeaderDetails(reqHeaders,agentRecord[0].AgentNet_ID__c,objUser[0].Webuser_ID__c);
                reqHeaders.put('Content-Type','application/json');
                HttpRequest request=GenricClassForCallout.getCalloutRequest(reqHeaders,AccountActionsCalloutHelper.get2FAApiEndpoint(),AccountActionsCalloutHelper.getUpdate2FAApiRequestBody(new set<string>{agentRecord[0].AgentNet_ID__c},agentRecord[0].Country__c.tolowerCase(),enable2FA),'POST',true,false,null,null);
                return getContinuationInstance(new list<HttpRequest>{request},'process2FAResponse');
            }
            //Error handling if access token is blank
            else{
                response.isSuccess=false;
                response.errorMessage='Error while retrieving the access token';
            }    
        }
        //Error handling if agentRecord list is empty
        else{
            response.isSuccess=false;
            response.errorMessage='Error: Unable to find the agent record';
        }
        return response;
    }
/*******************************************************************
*   Author  : Suraj Bisht
*   Param 1 : Boolean country - agent country 
*   Return  : ResponseCls object 
*   Description: To get section codes from agent platform
******************************************************************/
    @AuraEnabled(cacheable=true)
    public static ResponseCls getSectionList(String country){
        ResponseCls response= new ResponseCls();
        if(AccountActionsCalloutHelper.mapOfCountryNameVsRegion.containsKey(country.tolowerCase())){
            String countryCode=AccountActionsCalloutHelper.mapOfCountryNameVsRegion.get(country.tolowerCase());
            map<string,string> reqHeaders = new map<string,string>();
            reqHeaders.put('Authorization', Label.Api_Static_Token);
            HttpRequest sectionApiRequest=GenricClassForCallout.getCalloutRequest(reqHeaders,AccountActionsCalloutHelper.getSectionCodeApiEndpoint(countryCode),'','GET',false,false,null,null);
            HttpResponse sectionApiResponse=new Http().send(sectionApiRequest);   
            if(sectionApiResponse.getStatusCode() == 200){
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(sectionApiResponse.getBody());
                list<Object> sectionList=(list<Object>)responseMap.get('sectionCodes');
                if(sectionList != null && !sectionList.isEmpty() ){
                    response.isSuccess=true;
                    response.data=sectionList;
                }
                else{
                    response.errorMessage='Error while fetching section list : Empty section list in response \n Response Body:'+sectionApiResponse.getBody();
                }
            }
            // Error while fetching the response.
            else{
                response.errorMessage='Error while fetching section list : Response Not 200 \n Response Body: '+sectionApiResponse.getBody();
            }
        }
        else{
            response.errorMessage='Error : Only SG/MY/TH/IN regions are supported for this feature.';
        }
        return response;
    }
/*******************************************************************
*   Author  : Suraj Bisht
*   Param 1 : Boolean country - agent country 
*   Param 2 : String sectionCode - selected section code
*   Return  : ResponseCls object 
*   Description: To get action codes of the selected section code from agent platform
******************************************************************/
    @AuraEnabled(cacheable=true)
    public static ResponseCls getActionCodeList(String country,String sectionCode){
        ResponseCls response= new ResponseCls();
        if(AccountActionsCalloutHelper.mapOfCountryNameVsRegion.containsKey(country.tolowerCase())){
            String countryCode=AccountActionsCalloutHelper.mapOfCountryNameVsRegion.get(country.tolowerCase());
            map<string,string> reqHeaders = new map<string,string>();
            reqHeaders.put('Authorization', Label.Api_Static_Token);
            HttpRequest actionCodeApiRequest=GenricClassForCallout.getCalloutRequest(reqHeaders,AccountActionsCalloutHelper.getActionCodeApiEndpoint(countryCode,sectionCode),'','GET',false,false,null,null);
            HttpResponse actionCodeApiResponse=new Http().send(actionCodeApiRequest);   
            if(actionCodeApiResponse.getStatusCode() == 200){
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(actionCodeApiResponse.getBody());
                list<Object> actionList=(list<Object>)responseMap.get('actionCodes');
                if(actionList != null && !actionList.isEmpty() ){
                    response.isSuccess=true;
                    response.data=actionList;
                }
                else{
                    response.errorMessage='Error while fetching action code list : Empty action code list in response \n Response Body: '+actionCodeApiResponse.getBody();
                }
            }
            // Error while fetching the response.
            else{
                response.errorMessage='Error while fetching action code list : Response Not 200 \n Response Body: '+actionCodeApiResponse.getBody();
            }
        }
        else{
            response.errorMessage='Error : Only SG/MY/TH/IN regions are supported for this feature.';
        }
        return response;
    }
    public static Task logSMSResponse(HttpResponse sendSmsApiResponse,Account agentAccount,String smsBody){
        Task objTask=new Task(ActivityDate=System.today(),Type='SMS Log',WhatId=agentAccount.Id,WhoId=agentAccount.PersonContactId,Description='To:'+agentAccount.PersonMobilePhone+'\nSent By:'+UserInfo.getName()+'\nTime:'+System.now());
        String messageId,subject,errorMessage,status,errorCode,requestId,error;
        Boolean logMessageText=String.isNotBlank(smsBody)?true:false;
        if(sendSmsApiResponse.getStatusCode() == 201){
            try{
                objTask.Subject=(String.isBlank(smsBody))?'Reset Password SMS Sent':'SMS Sent';
                objTask.Status='Completed';
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(sendSmsApiResponse.getBody());
                messageId=(String)responseMap.get('id');
                status=(String)responseMap.get('status');
                objTask.Description+='\nMessage Id:'+messageId+'\nStatus:'+status;
            }
            catch(Exception e){
                objTask.Description+='\nMessage Id:'+messageId+'\nStatus:'+status;
                addErrorLog(e,agentAccount.Id,null);
            }
        }   
        else if (sendSmsApiResponse.getStatusCode() == 400 || sendSmsApiResponse.getStatusCode() == 422){
            try{
                objTask.Subject=(String.isBlank(smsBody))?'Failed To Send Reset Password SMS':'Failed To Send SMS';
                objTask.Status='Cancelled';
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(sendSmsApiResponse.getBody());
                errorMessage=String.valueOf(responseMap.get('description'));
                errorCode=String.valueOf(responseMap.get('errorCode'));
                status=String.valueOf(responseMap.get('status'));
                requestId=String.valueOf(responseMap.get('requestId'));
                objTask.Description+='\nStatus:'+status+'\nStatus Code:'+sendSmsApiResponse.getStatusCode()+'\nError:'+errorCode+'\nError Message: '+errorMessage+'\nRequest Id:'+requestId;
            }
            catch(Exception e){
                objTask.Description+='\nStatus:'+status+'\nStatus Code:'+sendSmsApiResponse.getStatusCode()+'\nError:'+errorCode+'\nError Message: '+errorMessage+'\nRequest Id:'+requestId;
                addErrorLog(e,agentAccount.Id,null);
            }
        }        
        else if(sendSmsApiResponse.getStatusCode() == 503){
            objTask.Status='Cancelled';
            objTask.Subject=(String.isBlank(smsBody))?'Failed To Send Reset Password SMS':'Failed To Send SMS';
            objTask.Description+='\nError Message: Service Temporarily Unavailable';
        }         
        else{
            try{
                objTask.Status='Cancelled';
                objTask.Subject=(String.isBlank(smsBody))?'Failed To Send Reset Password SMS':'Failed To Send SMS';
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(sendSmsApiResponse.getBody());
                errorMessage=String.valueOf(responseMap.get('message'));
                error=String.valueOf(responseMap.get('error'));
                objTask.Description+='\nStatus Code:'+sendSmsApiResponse.getStatusCode()+'\nError:'+error+'\nError Message:'+errorMessage;
            }
            catch(Exception e){
                objTask.Description+='\nStatus Code:'+sendSmsApiResponse.getStatusCode()+'\nError:'+error+'\nError Message:'+errorMessage;
            }
        }
        if(logMessageText){
            objTask.Description+='\nSMS Body:\n'+smsBody;
        }
        return objTask;
    }
    public static void addErrorLog(Exception e,Id recordId,String customErrorMessage){
        Error_Log__c errorLog;
        if(e == null && String.isNotBlank(customErrorMessage)){
            errorLog=new Error_Log__c(Error_Message__c=customErrorMessage,Related_Record_Id__c=recordId,Status__c='Open');
        }
        else if(e != null && String.isBlank(customErrorMessage)){
            errorLog=new Error_Log__c(Error_Message__c='Error Message: '+e.getMessage()+'\nStack Trace: '+e.getStackTraceString(),Related_Record_Id__c=recordId,Status__c='Open');
        }
        errorLogs.add(errorLog);
    }
    public static void createErrorLog(){
        if(errorLogs != null && !errorLogs.isEmpty()){
            insert errorLogs;
        }
    }
    public static HttpResponse sendSMSCallout(Account agentAccount,map<String,String> argumentsMap,map<String,String> smsTemplateParams){
        HttpResponse smsResponse;
        try{
            map<String,String> reqHeaders=new map<string,String>();
            reqHeaders.put('Content-Type','application/json');
            String senderName=(agentAccount.Country__c == Label.SINGAPORE_REGION || agentAccount.Country__c == Label.MALAYSIA_REGION)?PROPERTY_GURU_SENDER_NAME:DDPROPERTY_SENDER_NAME;
            String fromName=(agentAccount.Country__c == Label.SINGAPORE_REGION || agentAccount.Country__c == Label.MALAYSIA_REGION)?'PropGuru':'DDprop';
            String smsBody=argumentsMap.containsKey('smsBody')?argumentsMap.get('smsBody'):null;
            String clientAppName=argumentsMap.get('clientAppName');
            String categoryName=argumentsMap.get('categoryName');
            String mobileNumberWithCountryCode=argumentsMap.get('recipientMobileNumber');
            map<String,Object> requestMap= new map<String,Object>();
            requestMap.put('clientName',clientAppName);
            requestMap.put('clientAppName',clientAppName);
            requestMap.put('marketplace',AccountActionsCalloutHelper.mapOfCountryNameVsRegion.get(agentAccount.Country__c.tolowerCase()).toUpperCase());
            requestMap.put('channel','SMS');
            requestMap.put('categoryName',categoryName);
            map<string,Object> fromMap=new map<String,Object>{'sms'=>fromName};
            map<string,Object> reciepientMap=new map<String,Object>{'sms'=>mobileNumberWithCountryCode};
            requestMap.put('from',fromMap);
            requestMap.put('recipients',reciepientMap);
            //Use template
            if(smsTemplateParams != null && !smsTemplateParams.isEmpty()){
                //Reset Password Sms Params
                requestMap.put('params',smsTemplateParams);
            }
            else if(String.isNotBlank(smsBody)){
                requestMap.put('body',smsBody);
            }
            String reqJSON=JSON.serialize(requestMap);
            HttpRequest smsRequest=GenricClassForCallout.getCalloutRequest(reqHeaders,AccountActionsCalloutHelper.getsendSMSApiEndpoint(),reqJSON,'POST',true,false,null,null);
            smsResponse=new Http().send(smsRequest);
        }   
        catch(Exception e){
            addErrorLog(e,agentAccount.Id,null);
        } 
        return smsResponse;
    }
    @AuraEnabled
    public static ResponseCls sendSMS(String message,list<String> mobileNumbers,String country){
        ResponseCls objResponse=new ResponseCls();
        list<Task> listOfTaskToInsert=new list<Task>();
        set<Id> setOfInsertedTaskIds=new set<Id>();
        map<String,List<Account>> mapOfMobileNumberVsAgents;
        Boolean asyncProcess=false;
        try{
            if(mobileNumbers != null && !mobileNumbers.isEmpty()){
                mapOfMobileNumberVsAgents=getAgentAccounts(mobileNumbers,country);
                //Agent exists with the entered mobile number
                if(mapOfMobileNumberVsAgents != null && !mapOfMobileNumberVsAgents.isEmpty()){
                    Integer numberOfEnteredMobileNumbers=mapOfMobileNumberVsAgents.size();
                    if(numberOfEnteredMobileNumbers > 10) asyncProcess=true;
                    else{
                        for(String agentMobileNumber:mapOfMobileNumberVsAgents.keyset()){
                            list<Account> allAgentAccountWithSameMobileNumber=mapOfMobileNumberVsAgents.get(agentMobileNumber);
                            Account agentAccount=allAgentAccountWithSameMobileNumber[0];
                            HttpResponse response;
                            
                            // call send sms api 
                            if(!asyncProcess){
                                String mobileCountryCode=AccountActionsCalloutHelper.mapOfCountryNameVsMobileCode.get(country.tolowerCase());
                                response=sendSMSCallout(agentAccount,new map<String,String>{'smsBody'=>message,'clientAppName'=>Label.SF_SEND_SMS_CLIENT_APP_NAME,'categoryName'=>Label.Send_Sales_SMS_Category,'recipientMobileNumber'=>mobileCountryCode+agentAccount.PersonMobilePhone},null);
                            }
                            //Create task record on agent record
                            if(!asyncProcess && response != null){
                                //All agents records linked to entered mobile numbers
                                for(Account agentAccountObj:allAgentAccountWithSameMobileNumber){
                                    Task logTaskRecord=logSMSResponse(response,agentAccountObj,message);
                                    listOfTaskToInsert.add(logTaskRecord);
                                }
                            }
                        }
                    }
                    if(!listOfTaskToInsert.isEmpty()){
                        Database.saveResult[] saveResult=Database.insert(listOfTaskToInsert,false);
                        for ( Integer i=0; i< listOfTaskToInsert.size();i++){ 
                            if(!saveResult[i].isSuccess()){
                                String errorMessage='Send SMS Error:Failed To Create Task Record.\nDetails:'+listOfTaskToInsert[i].Description+'\nException Message:'+saveResult[i].getErrors()[0].getMessage();
                                addErrorLog(null,listOfTaskToInsert[i].whatId,errorMessage);
                            }
                            else setOfInsertedTaskIds.add(listOfTaskToInsert[i].Id);
                        }
                    }
                    objResponse.isSuccess=true;
                }
                //No agent found with this number
                else{
                    objResponse.errorMessage='Error: No agent found with the entered mobile number.';
                }
            }
        }
        catch(Exception e){
            objResponse.errorMessage='Error: '+e.getMessage()+'\n Stack Trace:'+e.getStackTraceString();
        }
        createErrorLog();
        if(mapOfMobileNumberVsAgents != null && !mapOfMobileNumberVsAgents.isEmpty() && asyncProcess){
            Database.executeBatch(new SendBulkSmsBatchCls(mapOfMobileNumberVsAgents.keyset(),message,country),50);
        }
        return objResponse;
    }
    @AuraEnabled
    public static map<String,List<Account>> getAgentAccounts(list<string> agentMobileNumbers,String country){
        set<String> mobileNumbers=new set<String>(agentMobileNumbers);
        mobileNumbers.remove('');
        map<String,List<Account>> mapOfAgentNumberVsListOfAccounts=new map<String,List<Account>>();
        String query='select id,Name,AgentNet_ID__c,AgentKey__c,PersonContactId,PersonMobilePhone,PersonEmail,Mobile_Country__c,Country__c from Account where PersonMobilePhone IN:mobileNumbers and  Country__c=:country and RecordType.DeveloperName=\'Agent\' ';
        if(country == Label.MALAYSIA_REGION || country == Label.SINGAPORE_REGION){
            query+=' and CEA_Salesperson_Number__c != null';
        }
        list<Account> agentAccounts=Database.query(query);
        if(agentAccounts != null && !agentAccounts.isEmpty()){
            for(Account objAccount:agentAccounts){
                if(!mapOfAgentNumberVsListOfAccounts.containsKey(objAccount.PersonMobilePhone)){
                    mapOfAgentNumberVsListOfAccounts.put(objAccount.PersonMobilePhone,new List<Account>());
                }
                mapOfAgentNumberVsListOfAccounts.get(objAccount.PersonMobilePhone).add(objAccount);
            }
        }        
        return mapOfAgentNumberVsListOfAccounts;
    }
/*******************************************************************
*   Author      : Suraj Bisht
*   Param 1     : Boolean enable2FA - true if enabling 2FA else false
*   Param 2     : String agentId - agent record Id 
*   Return      : ResponseCls object 
*   Description : To update 2FA status in salesforce, method called once callout is success
******************************************************************/
    @AuraEnabled
    public static void updateAgent2FAInSF(Boolean enable2FA,String agentId){
        String twoFAStatusToUpdate=(enable2FA)?TWOFA_ENABLED:TWOFA_DISABLED;
        Account objAccount=new Account(Id=agentId,X2FA__c=twoFAStatusToUpdate);
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, new list<Account>{objAccount});
        update securityDecision.getRecords();
    }
/*******************************************************************
*   Author      : Suraj Bisht
*   Param 1     : map<String,String> mapOfSelectedFieldNameVsValue
*   Return      : ResponseCls object 
*   Description : To get audit logs from auditing service
******************************************************************/
    @AuraEnabled
    public static ResponseCls getAdminAuditLogs(map<String,String> mapOfSelectedFieldNameVsValue){
        ResponseCls response=new ResponseCls();
        String agentCountry=mapOfSelectedFieldNameVsValue.get('agentCountry');
        if(mapOfSelectedFieldNameVsValue.containsKey('agentCountry') && AccountActionsCalloutHelper.mapOfCountryNameVsRegion.containsKey(agentCountry.tolowerCase())){

            //Get agent user api id to reset password 
            map<string,string> reqHeaders = new map<string,string>();
            reqHeaders.put('Authorization',Label.View_Audit_Log_Api_Token);
            HttpRequest auditLogRequest=GenricClassForCallout.getCalloutRequest(reqHeaders,getFinalAuditLogEndpoint(mapOfSelectedFieldNameVsValue),'','GET',false,false,null,null);
            HttpResponse auditLogResponse=new Http().send(auditLogRequest);   
            if(auditLogResponse?.getStatusCode() == 200){
                response.isSuccess=true;
                response.data=auditLogResponse.getBody();
                getActionAndSectionLabelFromApi(response,agentCountry,auditLogResponse.getBody());
            }
            //Handling status != 200
            else{
                response.errorMessage='Error while retrieving audit data '+auditLogResponse?.getBody();
            }
        }
        else{
            response.errorMessage='';
        }
        return response;
    }
/*******************************************************************
*   Author      : Suraj Bisht
*   Param 1     : ResponseCls response
*   Param 2     : String country 
*   Param 3     : String auditResponseBody
*   Return      : void
*   Description : To get action and section lables based on audit logs response.
******************************************************************/
    private static void getActionAndSectionLabelFromApi(ResponseCls response,String country,String auditResponseBody){
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(auditResponseBody);
        list<Object> auditLogs=(list<Object>)responseMap.get('audits');
        if(auditLogs != null && !auditLogs.isEmpty()){
            set<String> sectionCodes=new set<String>();
            for(Object logObj:auditLogs){
                map<String,Object> mapOfLogObject=(map<String,Object>)logObj;
                String sectionCode=(String)mapOfLogObject.get('sectionCode');
                sectionCodes.add(sectionCode);
            }
            // Get section code and action code label present in response
            if(!sectionCodes.isEmpty()){
                map<Integer,List<Object>> mapOfSectionCodeIdVsListOfActionCodesLabel=new map<Integer,List<Object>>();
                for(String sectionCode:sectionCodes){
                    ResponseCls actionCodeApiResponse=getActionCodeList(country,sectionCode);
                    if(actionCodeApiResponse.isSuccess ){
                        list<Object> actionCodeList=(list<Object>)actionCodeApiResponse?.data;
                        if(actionCodeList != null){
                            for(Object actionCodeObj:actionCodeList){
                                Map<String,Object> mapOfActionCodes=(map<String,Object>)actionCodeObj;
                                map<String,String> actionCodesMap=new map<String,String>{'actionCode'=>(String)mapOfActionCodes.get('code'),'actionLabel'=>(String)mapOfActionCodes.get('description')};
                                Integer sectionCodeId=(Integer)mapOfActionCodes.get('sectionCodeId');
                                if(!mapOfSectionCodeIdVsListOfActionCodesLabel.containsKey(sectionCodeId)){
                                    mapOfSectionCodeIdVsListOfActionCodesLabel.put(sectionCodeId,new list<Object>());
                                }
                                mapOfSectionCodeIdVsListOfActionCodesLabel.get(sectionCodeId).add(actionCodesMap);
                            }
                        }
                    }
                    else{
                        response.isSuccess=false;
                        response.errorMessage=actionCodeApiResponse.errorMessage;
                    }
                }
                if(!mapOfSectionCodeIdVsListOfActionCodesLabel.isEmpty()){
                    response.sectionData=mapOfSectionCodeIdVsListOfActionCodesLabel;
                }
            }
        }
    }

/*******************************************************************
*   Author      : Suraj Bisht
*   Param 1     : map<String,String> mapOfSelectedFieldNameVsValue
*   Return      : String final endpoint after adding params based on user inputs
*   Description : To get final endpoint based on user inputs
******************************************************************/
    private static String getFinalAuditLogEndpoint(map<String,String> mapOfSelectedFieldNameVsValue){
        String agentId=mapOfSelectedFieldNameVsValue.get('agentNetId');
        String auditLogType=mapOfSelectedFieldNameVsValue.get('logType');
        String listingId=mapOfSelectedFieldNameVsValue.get('listingId');
        String endpoint=AccountActionsCalloutHelper.getAuditLogApiEndpoint(AccountActionsCalloutHelper.mapOfCountryNameVsRegion.get(mapOfSelectedFieldNameVsValue.get('agentCountry').tolowerCase()))+'?limit=20&page='+mapOfSelectedFieldNameVsValue.get('pageNumber')+'&startDate='+mapOfSelectedFieldNameVsValue.get('fromDate')+'&endDate='+mapOfSelectedFieldNameVsValue.get('endDate');
        if(String.isNotBlank(listingId)){
            endpoint+='&objectId='+listingId;
        }
        String userId=(auditLogType == 'showActionOnAgent')?'targetUserId':((auditLogType == 'both')?'agentId':'userId');
        endpoint+='&'+userId+'='+agentId+'&order=time,desc';
        if(String.isNotBlank(mapOfSelectedFieldNameVsValue.get('section'))){
            endpoint+='&sectionCode='+mapOfSelectedFieldNameVsValue.get('section');  
            if(String.isNotBlank(mapOfSelectedFieldNameVsValue.get('action'))){
                endpoint+='&actionCode='+mapOfSelectedFieldNameVsValue.get('action');
            }
        }
        return endpoint;
    }

/*******************************************************************
*   Author      : Suraj Bisht
*   Param 1     : String userId - agent Id 
*   Param 2     : String country - agent region
*   Return      : ResponseCls object 
*   Description : To get author details 
******************************************************************/
    @AuraEnabled
    public static ResponseCls getAuthorDetails(String userId,String country){
        ResponseCls response=new ResponseCls();
        String token = DeveloperListingInventoriesCheck.getToken(country.tolowerCase());
        if(token != null && AccountActionsCalloutHelper.mapOfCountryNameVsRegion.containsKey(country.tolowerCase()) && AccountActionsCalloutHelper.mapOfCountryNameVsRegion.containsKey(country.tolowerCase())){
            //Get agent user api id to reset password 
            map<string,string> reqHeaders = new map<string,string>();
            reqHeaders.put('Authorization','Bearer '+token);
            String endpoint=AccountActionsCalloutHelper.getAuthorDetailsApiEndpoint()+userId+'/person?region='+AccountActionsCalloutHelper.mapOfCountryNameVsRegion.get(country.tolowerCase());
            HttpRequest authorDetailApiRequest=GenricClassForCallout.getCalloutRequest(reqHeaders,endpoint,'','GET',false,false,null,null);
            HttpResponse authorDetailApiResponse=new Http().send(authorDetailApiRequest);   
            if(authorDetailApiResponse?.getStatusCode() == 200){
                response.isSuccess=true;
                response.data=authorDetailApiResponse.getBody();
            }
            //Handling status != 200
            else{
                response.errorMessage='Error while retrieving author details '+authorDetailApiResponse?.getBody();
            }
        }
        else{
            response.errorMessage='Error while retrieving the access token';
        }
        return response;
    }
/*******************************************************************
*   Author      : Suraj Bisht
*   Param 1     : list<HttpRequest> requests - continuation requests
*   Param 2     : String callbackMethodName -  continuation callback method name to be called 
*   Return      : Continuation con 
*   Description : To get continuation object by passing the request and callback method name
******************************************************************/
    private static Continuation getContinuationInstance(list<HttpRequest> requests,String callbackMethodName){
        // Creating continuation object with a 40s timeout
        Continuation con = new Continuation(60);
        con.continuationMethod=callbackMethodName;
        //adding request to continuation instance
        for(HttpRequest objRequest:requests){
            con.addHttpRequest(objRequest);
        }
        return con;
    }
/*******************************************************************
*   Author      : Suraj Bisht
*   Param 1     : List<String> labels - continuation request labels
*   Return      : ResponseCls response
*   Description : update 2FA api callback method 
******************************************************************/
    @AuraEnabled
    public static Object process2FAResponse(List<String> labels) {
        ResponseCls response =new ResponseCls();
        // response of 1st request
        HttpResponse res = Continuation.getResponse(labels[0]);
        Integer statusCode = res.getStatusCode();
        if(statusCode == 200 ){
            response.isSuccess=true;
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
*   Author      : Suraj Bisht
*   Class Name  : ResponseCls
*   Description : To define response parameters
******************************************************************/
    public class ResponseCls{ 
        @AuraEnabled public Boolean isSuccess=false;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public Object data; 
        @AuraEnabled public Object sectionData; 
    }
}
/*******************************************************************
*   Author: Suraj Bisht
*   Class Name: AccountActionsCtlr_Test
*   Description: Test Class of AccountActionsCtlr
******************************************************************/
@isTest(seeAllData=false)
public with sharing class AccountActionsCtlr_Test {
    private static final String FIRST_NAME='TestAgent';
    private static final String LAST_NAME='Account';
    private static final String TEST_USER_PROFILE_NAME='Standard User';
    private static final String ACTION_CODE_API_JSON_RESPONSE='{ "page": 1, "limit": 10, "actionCodes": [ { "sectionCodeId": 86, "id": 663, "countryCode": "th", "code": "ENABLE_AUTO_RANKED_SPOTLI", "description": "ENABLE_AUTO_RANKED_SPOTLI", "descriptionId": null, "descriptionTh": "ENABLE_AUTO_RANKED_SPOTLI", "sortOrder": null }, { "sectionCodeId": 86, "id": 652, "countryCode": "th", "code": "API_ACTIVATION_LIMIT", "description": "API_ACTIVATION_LIMIT", "descriptionId": null, "descriptionTh": "API_ACTIVATION_LIMIT", "sortOrder": null }, { "sectionCodeId": 86, "id": 653, "countryCode": "th", "code": "API_UPDATE", "description": "API_UPDATE", "descriptionId": null, "descriptionTh": "API_UPDATE", "sortOrder": null }, { "sectionCodeId": 86, "id": 664, "countryCode": "th", "code": "ENABLE_AUTO_TURBO", "description": "ENABLE_AUTO_TURBO", "descriptionId": null, "descriptionTh": "ENABLE_AUTO_TURBO", "sortOrder": null }, { "sectionCodeId": 86, "id": 655, "countryCode": "th", "code": "CHANGE_FINAL_SCORE", "description": "CHANGE_FINAL_SCORE", "descriptionId": null, "descriptionTh": "CHANGE_FINAL_SCORE", "sortOrder": null }, { "sectionCodeId": 86, "id": 662, "countryCode": "th", "code": "DISABLE_AUTO_TURBO", "description": "DISABLE_AUTO_TURBO", "descriptionId": null, "descriptionTh": "DISABLE_AUTO_TURBO", "sortOrder": null }, { "sectionCodeId": 86, "id": 658, "countryCode": "th", "code": "CREATE_RANKED_SPOTLIGHT", "description": "CREATE_RANKED_SPOTLIGHT", "descriptionId": null, "descriptionTh": "CREATE_RANKED_SPOTLIGHT", "sortOrder": null }, { "sectionCodeId": 86, "id": 665, "countryCode": "th", "code": "EXCEPTION", "description": "EXCEPTION", "descriptionId": null, "descriptionTh": "EXCEPTION", "sortOrder": null }, { "sectionCodeId": 86, "id": 660, "countryCode": "th", "code": "DEV_UNIT_LISTING_REFRESH", "description": "DEV_UNIT_LISTING_REFRESH", "descriptionId": null, "descriptionTh": "DEV_UNIT_LISTING_REFRESH", "sortOrder": null }, { "sectionCodeId": 86, "id": 661, "countryCode": "th", "code": "DISABLE_AUTO_RANKED_SPOTL", "description": "DISABLE_AUTO_RANKED_SPOTL", "descriptionId": null, "descriptionTh": "DISABLE_AUTO_RANKED_SPOTL", "sortOrder": null } ] }';
    private static final String SECTION_CODE_API_JSON_RESPONSE='{ "page": 1, "limit": 10, "sectionCodes": [ { "id": 76, "countryCode": "th", "code": "CONDO_FEATURED_AGENT", "description": "CONDO_FEATURED_AGENT", "descriptionId": null, "descriptionTh": "CONDO_FEATURED_AGENT", "sortOrder": null }, { "id": 65, "countryCode": "th", "code": "ADMIN_BILLING", "description": "ADMIN_BILLING", "descriptionId": null, "descriptionTh": "ADMIN_BILLING", "sortOrder": null }, { "id": 66, "countryCode": "th", "code": "ADMIN_BUNDLES", "description": "ADMIN_BUNDLES", "descriptionId": null, "descriptionTh": "ADMIN_BUNDLES", "sortOrder": null }, { "id": 67, "countryCode": "th", "code": "ADMIN_PRODUCTS", "description": "ADMIN_PRODUCTS", "descriptionId": null, "descriptionTh": "ADMIN_PRODUCTS", "sortOrder": null }, { "id": 75, "countryCode": "th", "code": "COMM_DT_FEATURED_AGENT", "description": "COMM_DT_FEATURED_AGENT", "descriptionId": null, "descriptionTh": "COMM_DT_FEATURED_AGENT", "sortOrder": null }, { "id": 70, "countryCode": "th", "code": "BILLING", "description": "BILLING", "descriptionId": null, "descriptionTh": "BILLING", "sortOrder": null }, { "id": 71, "countryCode": "th", "code": "BOOKING", "description": "BOOKING", "descriptionId": null, "descriptionTh": "BOOKING", "sortOrder": null }, { "id": 72, "countryCode": "th", "code": "BOOST_LISTING", "description": "BOOST_LISTING", "descriptionId": null, "descriptionTh": "BOOST_LISTING", "sortOrder": null }, { "id": 73, "countryCode": "th", "code": "CDFA", "description": "CDFA", "descriptionId": null, "descriptionTh": "CDFA", "sortOrder": null }, { "id": 74, "countryCode": "th", "code": "COMM_BLDG_FEATURED_AGENT", "description": "COMM_BLDG_FEATURED_AGENT", "descriptionId": null, "descriptionTh": "COMM_BLDG_FEATURED_AGENT", "sortOrder": null } ] }';
    private static final String MOCK_RESPONSE_JSON='[ { "userId": 1061827, "isSuccess": false, "country": "malaysia", "reason": "User does not exists" }, { "userId": 219962, "isSuccess": true, "country": "malaysia" } ]';
    private static final String VIEW_AUDIT_LOGS_JSON_RESPONSE='{ "total": 0, "page": 1, "limit": 20, "audits": [{ "id": 3080194044, "sectionCode": "LISTINGS", "actionCode": "CHANGE_STATUS", "userId": 68924, "targetUserId": 11209266, "objectId": 33808917, "oldValue": "ACT", "newValue": "EXP", "ipAddress": "127.0.0.1", "date": "2022-11-18", "time": "2022-11-18T01:08:22.000Z" }] }';
    private static final String AUTHOR_DETAILS_JSON_RESPONSE='[total:1,{ "id": 3080194044, "sectionCode": "LISTINGS", "actionCode": "CHANGE_STATUS", "userId": 68924, "targetUserId": 11209266, "objectId": 33808917, "oldValue": "ACT", "newValue": "EXP", "ipAddress": "127.0.0.1", "date": "2022-11-18", "time": "2022-11-18T01:08:22.000Z" }]';
    private static final String SEND_SMS_JSON_RESPONSE='{ "id": "33062cee-2613-42c0-adb7-c1a7125a62bc", "errorCode": "MSG_SRV_206", "description": "SMS sent", "status": "SUCCESS" }';
    private static final String SEND_SMS_NEGATIVE_RESPONSE_JSON='{ "requestId": "33062cee-2613-42c0-adb7-c1a7125a62bc", "errorCode": "MSG_SRV_206", "description": "Recipient is not whitelisted", "status": "FAILURE" }';
    private static final String CONTINUATION_REQ1_LABEL='Continuation-1';
    private static final String COUNTRY='Malaysia';
    private static final String SECTION_CODE='LISTINGS';
    private static final String ACTION_CODE='ACTIVATION';
    private static final String DISABLED_2FA_STATUS='Disabled';
    private static final String ENABLED_2FA_STATUS='Enabled';
    private static final String MY_AGENTNET_ID='4321123';
    private static final String AGENT_MOBILE_NUMBER='3423422';
    private static final String CEA_SALESPERSON_NUMBER='4242342';
    private static final String SMS_BODY='Test SMS Body';
    private static final String TASK_CANCELLED_STATUS='Cancelled';
    private static final String TASK_COMPLETED_STATUS='Completed';
    private static final String TEST_USER_NAME=FIRST_NAME+'.'+LAST_NAME+'@'+UserInfo.getOrganizationId()+'.com';
    private static final Id AGENTRECORDTYPEID =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agent').getRecordTypeId();
    @testSetup
    static void setup(){
        Profile p=[select id from Profile where Name=:TEST_USER_PROFILE_NAME];
        
        //Standard Profile User
        User standardUser=PGTestDataFactory_v2.createUser(p.Id,FIRST_NAME,LAST_NAME);
        insert standardUser;
        
        //creating Trigger_Execute__c record
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        
        list<Account> listOfAccountToInsert=new list<Account>();
        //Agent record to be used in negative scenario
        Account objAccount=PGTestDataFactory_v2.constructAgentAccount(FIRST_NAME,LAST_NAME,AGENTRECORDTYPEID);
        objAccount.OwnerId=standardUser.Id;
        listOfAccountToInsert.add(objAccount);
        
        //Agent record to be used in positive scenario 
        for(Integer i=0;i<20;i++){
            Account objAccount1=PGTestDataFactory_v2.constructAgentAccount(FIRST_NAME,LAST_NAME,AGENTRECORDTYPEID);
            objAccount1.PersonMobilePhone=AGENT_MOBILE_NUMBER+i;
            objAccount1.CEA_Salesperson_Number__c=CEA_SALESPERSON_NUMBER+i;
            objAccount1.OwnerId=standardUser.Id;
            objAccount1.Country__c=COUNTRY;
            objAccount1.AgentNet_ID__c=MY_AGENTNET_ID+i;
            objAccount1.X2FA__c=DISABLED_2FA_STATUS;
            listOfAccountToInsert.add(objAccount1);
        }
        //Agent record insertion
        insert listOfAccountToInsert;
    }
/*******************************************************************
*   Author: Suraj Bisht
*   Method Name: updateAccountStatusPositive
*   Description: Positive test scenario test method
******************************************************************/
    @isTest
    static void updateAccountStatusPositive(){
        User objUser= [select id from User where UserName=:TEST_USER_NAME ];
        Account agentAccount=[select id,AgentNet_ID__c from Account where AgentNet_ID__c != null and Country__c != null and RecordTypeId=:AGENTRECORDTYPEID limit 1];
        
        System.runAs(objUser){
            Test.startTest();
            Continuation objCont=(Continuation)AccountActionsCtlr.updateAgent2FAInAgentNet(true,agentAccount.Id);
            Map<String, HttpRequest> requests = objCont.getRequests();
            // Set the mock response for the continuation  
            HttpResponse response = new HttpResponse();
            response.setBody(MOCK_RESPONSE_JSON);  
            response.setStatusCode(200); 
            Test.setContinuationResponse(CONTINUATION_REQ1_LABEL, response);
            // Invoke callback method
            AccountActionsCtlr.ResponseCls responseObj = (AccountActionsCtlr.ResponseCls)AccountActionsCtlr.process2FAResponse(new list<String>(requests.keyset()));
            Test.stopTest();
            System.assert(responseObj.isSuccess,'Response object contains no error');
        }
    }
/*******************************************************************
*   Author: Suraj Bisht
*   Method Name: updateAccountStatus_Negative
*   Description: Negative test scenario of updateAccountStatus method
******************************************************************/
    @isTest
    static void updateAccountStatusNegative(){
        User objUser= [select id from User where UserName=:TEST_USER_NAME ];
        Account agentAccount=[select id,AgentNet_ID__c from Account where RecordTypeId=:AGENTRECORDTYPEID and (AgentNet_ID__c = null OR Country__c= null) limit 1];
        
        System.runAs(objUser){
            Test.startTest();
            AccountActionsCtlr.ResponseCls response=(AccountActionsCtlr.ResponseCls)AccountActionsCtlr.updateAgent2FAInAgentNet(true,agentAccount.Id);
            Test.stopTest();
            System.assert(!response.isSuccess,'Response object contains error');
        }
    }
/*******************************************************************
*   Author: Suraj Bisht
*   Method Name: updateAgent2FAInSFPositive
*   Description: Positive test scenario of updateAgent2FAInSF method
******************************************************************/
    @isTest
    static void updateAgent2FAInSFPositive(){
        User objUser= [select id from User where UserName=:TEST_USER_NAME ];
        Account agentAccount=[select id,AgentNet_ID__c,X2FA__c from Account where RecordTypeId=:AGENTRECORDTYPEID and AgentNet_ID__c != null AND Country__c != null limit 1];
        String current2FAStatus=agentAccount.X2FA__c;
        System.runAs(objUser){
            Test.startTest();
            AccountActionsCtlr.updateAgent2FAInSF(true,agentAccount.Id);
            Test.stopTest();
            agentAccount=[select id,AgentNet_ID__c,X2FA__c from Account where RecordTypeId=:AGENTRECORDTYPEID and AgentNet_ID__c != null AND Country__c != null limit 1];
            System.assert(current2FAStatus != agentAccount.X2FA__c,' Agent 2FA status updated successfully.');
        }
    }
/*******************************************************************
*   Author: Suraj Bisht
*   Method Name: getAdminAuditLogsPositive
*   Description: Positive test scenario of getAdminAuditLogs method
******************************************************************/
    @isTest 
    static void getAdminAuditLogsPositive(){
        User objUser= [select id from User where UserName=:TEST_USER_NAME ];
        Account agentAccount=[select id,AgentNet_ID__c from Account where AgentNet_ID__c != null and Country__c != null and RecordTypeId=:AGENTRECORDTYPEID limit 1];
        
        System.runAs(objUser){
            Test.startTest();
            // Set the mock response 
            Test.setMock(HttpCalloutMock.class, new MockResponseCls());
            AccountActionsCtlr.ResponseCls sectionResponseObj=AccountActionsCtlr.getSectionList(Label.THAILAND_REGION);
            map<String,String> mapOfSelectedFieldNameVsValue=new map<String,String>{'agentNetId'=>agentAccount.Id,'fromDate'=>'2022-10-01','endDate'=>'2023-01-01','agentCountry'=>Label.THAILAND_REGION,'section'=>'AD_CREDIT','action'=>'ACTIVATION','listingId'=>'12121'};
                AccountActionsCtlr.ResponseCls responseObj=AccountActionsCtlr.getAdminAuditLogs(mapOfSelectedFieldNameVsValue);
            Test.stopTest();
            System.assert(responseObj != null && responseObj.isSuccess,'Assert to verify response');
        }
    }
/*******************************************************************
*   Author: Suraj Bisht
*   Method Name: getAuthorDetailsPositive
*   Description: Positive test scenario of getAuthorDetails method
******************************************************************/
    @isTest 
    static void getAuthorDetailsPositive(){
        User objUser= [select id from User where UserName=:TEST_USER_NAME ];
        Account agentAccount=[select id,AgentNet_ID__c from Account where AgentNet_ID__c != null and Country__c != null and RecordTypeId=:AGENTRECORDTYPEID limit 1];
        
        System.runAs(objUser){
            Test.startTest();
            // Set the mock response 
            Test.setMock(HttpCalloutMock.class, new MockResponseCls());
            AccountActionsCtlr.ResponseCls responseObj=AccountActionsCtlr.getAuthorDetails('12312',Label.MALAYSIA_REGION);
            Test.stopTest();
            System.assert(responseObj != null && responseObj.isSuccess,'Assert to verify response');
        }
    }
/*******************************************************************
*   Author: Suraj Bisht
*   Method Name: sendSMSPositive
*   Description: Positive test scenario of sendSMS method
******************************************************************/
    @isTest 
    static void sendSMSPositive(){
        User objUser= [select id from User where UserName=:TEST_USER_NAME ];
        Account agentAccount=[select id,AgentNet_ID__c,PersonMobilePhone from Account where AgentNet_ID__c != null and PersonMobilePhone != null and Country__c != null and RecordTypeId=:AGENTRECORDTYPEID limit 1];
        
        System.runAs(objUser){
            Test.startTest();
            // Set the mock response 
            Test.setMock(HttpCalloutMock.class, new MockResponseCls());
            AccountActionsCtlr.ResponseCls responseObj=AccountActionsCtlr.sendSMS(SMS_BODY,new list<String>{agentAccount.PersonMobilePhone},Label.MALAYSIA_REGION);
            Test.stopTest();
            System.assert(responseObj != null && responseObj.isSuccess,'Assert to verify response');
        }
    }
/*******************************************************************
*   Author: Suraj Bisht
*   Method Name: sendBulkSMSPositive
*   Description: Positive test scenario of sendSMS bulk scenario method
******************************************************************/
    @isTest 
    static void sendBulkSMSPositive(){
        User objUser= [select id from User where UserName=:TEST_USER_NAME ];
        list<String> agentNumbers=new list<String>();
        list<Account> agentAccounts=[select id,AgentNet_ID__c,PersonMobilePhone from Account where AgentNet_ID__c != null and PersonMobilePhone != null and Country__c != null and RecordTypeId=:AGENTRECORDTYPEID limit 20];
        for(Account agentAccount:agentAccounts){
            agentNumbers.add(agentAccount.PersonMobilePhone);
        }
        System.runAs(objUser){
            list<Task> smsLogs=[select id from Task where WhatId in:agentNumbers and Status=:TASK_COMPLETED_STATUS ];
            System.assert(smsLogs.isEmpty(),'Assert to verify no sms log is present before code execution');
            Test.startTest();
            // Set the mock response 
            Test.setMock(HttpCalloutMock.class, new MockResponseCls());
            AccountActionsCtlr.ResponseCls responseObj=AccountActionsCtlr.sendSMS(SMS_BODY,agentNumbers,Label.MALAYSIA_REGION);
            Test.stopTest(); 
            smsLogs=[select id from Task where WhatId in:agentAccounts and Status=:TASK_COMPLETED_STATUS ];
            System.assert(!smsLogs.isEmpty(),'Assert to verify no sms log is present before code execution');
            System.assert(responseObj != null && responseObj.isSuccess,'Assert to verify response');
        }
    }
/*******************************************************************
*   Author: Suraj Bisht
*   Method Name: sendSMSPositive
*   Description: Negative test scenario of sendSMS method
******************************************************************/
    @isTest 
    static void sendSMSNegative(){
        User objUser= [select id from User where UserName=:TEST_USER_NAME ];
        Account agentAccount=[select id,AgentNet_ID__c,PersonMobilePhone from Account where AgentNet_ID__c != null and PersonMobilePhone != null and Country__c != null and RecordTypeId=:AGENTRECORDTYPEID limit 1];
        
        System.runAs(objUser){
            list<Task> objTask=[select id from Task where WhatId=:agentAccount.Id and Status=:TASK_CANCELLED_STATUS limit 1];
            System.assert(objTask.isEmpty(),'Assert to verify no cancelled task exists before code execution');
            Test.startTest();
            // Set the mock response 
            Test.setMock(HttpCalloutMock.class, new NegativeMockResponseCls());
            AccountActionsCtlr.ResponseCls responseObj=AccountActionsCtlr.sendSMS(SMS_BODY,new list<String>{agentAccount.PersonMobilePhone},Label.MALAYSIA_REGION);
            Test.stopTest();
            objTask=[select id from Task where WhatId=:agentAccount.Id and Status=:TASK_CANCELLED_STATUS limit 1];
            System.assert(!objTask.isEmpty(),'Assert to verify cancelled task exists after code execution');
        }
    }
/*******************************************************************
*   Author: Suraj Bisht
*   Class Name: MockResponseCls
*   Description: Mock response class
******************************************************************/
    private class MockResponseCls implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            // View audit log endpoint call
            if ( req.getEndpoint().startsWithIgnoreCase( AccountActionsCalloutHelper.getAuditLogApiEndpoint('my')) || req.getEndpoint().startsWithIgnoreCase( AccountActionsCalloutHelper.getAuditLogApiEndpoint('sg')) || req.getEndpoint().startsWithIgnoreCase( AccountActionsCalloutHelper.getAuditLogApiEndpoint('th'))){
                res.setBody(VIEW_AUDIT_LOGS_JSON_RESPONSE);
            }
            //Action code api response
             else if(req.getEndpoint() == AccountActionsCalloutHelper.getActionCodeApiEndpoint('my',SECTION_CODE) || req.getEndpoint() == AccountActionsCalloutHelper.getActionCodeApiEndpoint('sg',SECTION_CODE) || req.getEndpoint() == AccountActionsCalloutHelper.getActionCodeApiEndpoint('th',SECTION_CODE)){
                res.setBody(ACTION_CODE_API_JSON_RESPONSE);
            }
            //Section code api response
            else if (req.getEndpoint() == AccountActionsCalloutHelper.getSectionCodeApiEndpoint('my') || req.getEndpoint() == AccountActionsCalloutHelper.getSectionCodeApiEndpoint('sg') || req.getEndpoint() == AccountActionsCalloutHelper.getSectionCodeApiEndpoint('th')){
                res.setBody(SECTION_CODE_API_JSON_RESPONSE);
            }
            else if(req.getEndpoint().startsWithIgnoreCase(AccountActionsCalloutHelper.getAuthorDetailsApiEndpoint()) && (req.getEndpoint().endsWithIgnoreCase('/person?region=my')  ||req.getEndpoint().endsWithIgnoreCase('/person?region=sg') ||req.getEndpoint().endsWithIgnoreCase('/person?region=th'))){
                res.setBody(AUTHOR_DETAILS_JSON_RESPONSE);
            }
            else if(req.getEndpoint() == AccountActionsCalloutHelper.getsendSMSApiEndpoint()){
                res.setBody(SEND_SMS_JSON_RESPONSE);
                res.setStatusCode(201);
            }
            return res;
        }
    }
/*******************************************************************
*   Author: Suraj Bisht
*   Class Name: NegativeMockResponseCls
*   Description: Mock class for negative response
******************************************************************/
    private class NegativeMockResponseCls implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(400);
            if(req.getEndpoint() == AccountActionsCalloutHelper.getsendSMSApiEndpoint()){
                res.setBody(SEND_SMS_NEGATIVE_RESPONSE_JSON);
            }
            return res;
        }
    }
}
/*******************************************************************
 *	Author:         Suraj Bisht
 *  Class Name:     OliFieldHistoryDetailsCls_Test
 *  Description:    Test class of OliFieldHistoryDetailsCls
 ******************************************************************/
@isTest(seeAllData=false)
public with sharing class OliFieldHistoryDetailsCls_Test {
    private static final String MOCK_RESPONSE_JSON='[ { "Id": "a1M9D000001IvVbUAK", "Opportunity__c": "0062r000002kwVSAAY", "CreatedById": "0057F000005TAluQAG", "CreatedDate": "2021-03-16T13:13:22.000Z", "CurrencyIsoCode": "SGD", "Field_Name__c": "Actual Start Date", "IsDeleted": "false", "LastModifiedById": "0057F000005TAluQAG", "LastModifiedDate": "2021-03-16T13:13:22.000Z", "LineId__c": "00k2r000003Du6HAAS", "Name": "OLI-2660536", "New_Value__c": "2020-06-29 00:00:00", "Old_Value__c": "2020-07-05 00:00:00", "SystemModstamp": "2021-03-16T13:13:22.000Z", "Type__c": "UPDATE", "User__c": "0057F000005TAluQAG" }]';
    private static final String FIRST_NAME='UserFirstName';
    private static final String LAST_NAME='UserLastName';
    private static final String TEST_USER_PROFILE_NAME='Standard User';
    private static final String CONTINUATION_REQ1_LABEL='Continuation-1';
    private static final String DUMMY_OPP_ID='a1M9D0';
    private static final String TEST_USER_NAME=FIRST_NAME+'.'+LAST_NAME+'@'+UserInfo.getOrganizationId()+'.com';
    @testSetup
    static void setup(){
        Profile p=[select id from Profile where Name=:TEST_USER_PROFILE_NAME];

        //Standard Profile User
        User standardUser=PGTestDataFactory_v2.createUser(p.Id,FIRST_NAME,LAST_NAME);
        insert standardUser;
    }
/*******************************************************************
 *	Author:         Suraj Bisht
 *  Method Name:    getHistoryDetailsPositiveTestMethod
 *  Description:    Covering getHistoryDetails method positive scenario
 ******************************************************************/
    @IsTest
    static void getHistoryDetailsPositiveTestMethod(){
        User objUser= [select id from User where UserName=:TEST_USER_NAME ];
        Test.startTest();
        System.runAs(objUser){
            //Passing dummy opportunity id as using mock response in test class.
            Continuation objCont =(Continuation)OliFieldHistoryDetailsCls.getHistoryDetails(DUMMY_OPP_ID);
            Map<String, HttpRequest> requests = objCont.getRequests();
            // Set the mock response for the continuation  
            HttpResponse response = new HttpResponse();
            response.setBody(MOCK_RESPONSE_JSON);  
            response.setStatusCode(200); 
            Test.setContinuationResponse(CONTINUATION_REQ1_LABEL, response);
            // Invoke callback method
            OliFieldHistoryDetailsCls.ResponseCls result = (OliFieldHistoryDetailsCls.ResponseCls)OliFieldHistoryDetailsCls.processResponse(new list<String>(requests.keyset()));
            System.assertNotEquals(result,null,'Result is not null');
            System.assert(!result.oliHistoryRecords.isEmpty(),'OliHistoryRecords is not empty');
            System.assertEquals(result.isSuccess,true,'No exception in result');
        }
        Test.stopTest();
    }
}
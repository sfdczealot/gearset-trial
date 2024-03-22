/*
* Created by : Yuni 
* Company    : Viseo Asia PTE LTD
* created Date : 27/07/2018
*/
@isTest
public class AgentAPI_Test {
    
    static testMethod void runTest() {
        Test.StartTest();
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        String resp = '';
        String accRectype2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account b = new Account();
        b.RecordTypeId = accRectype2;
        b.Name = 'Unit Test Agency';
        b.Customer_Type__c = 'Agency';
        b.Agency_Id__c = '1234';
        b.CEA_License__c='test122';
        b.Test_Account__c = true;
        insert b;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni';
        a.FirstName = 'aaaa';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.salutation = 'Mr.';
        a.personEmail = 'aaa@ayahoo.com';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test State';
        a.Test_Account__c = true;
        a.Current_Subscription_Code__c = 'abc';
        a.Agency_Name__c = 'Hhh';
        a.AgentNet_ID__c = '2334';
        a.iPP_REA_ID__c = '1234';
        a.Account_Rule_Code__c = 'dddfdf';
        a.Subscription_End_Date__c =system.today().addMonths(-10);
        a.agency__c = b.id;
        a.CEA_Salesperson_Number__c='A878964A';
        a.PersonBirthdate=system.today();
        a.Mobile_Country__c='60'; 
        insert a;
        string testMonth = '';
        testMonth = (a.Subscription_End_Date__c.month()<10?testmonth = '0'+a.Subscription_End_Date__c.month():string.valueof(a.Subscription_End_Date__c.month()));
        string testDate = a.Subscription_End_Date__c.year() +'-'+ testMonth +'-'+ (a.Subscription_End_Date__c.day()>9?string.valueOf(a.Subscription_End_Date__c.day()):('0'+a.Subscription_End_Date__c.day()));
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/agent';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        req.addParameter('id', a.id);
        RestContext.request = req;
        RestContext.response= res;
        AgentAPI.getAccount();
        resp = res.responseBody.toString();
        system.debug('First Actual Response : ' + resp);
        //system.assertEquals('{"Website":null,"Subscription_Start_Date":"'+ testDate+ '","Subscription_End_Date":"'+ testDate +'","Status":null,"Salutation":"Mr.","Phone":null,"PersonTitle":null,"PersonMobilePhone":null,"PersonMailingStreet":"test","PersonMailingPostalCode":"8373","PersonMailingCity":"test","PersonEmail":"aaa@ayahoo.com","PersonBirthdate":null,"Netsuite_ID":null,"Mobile_Country":null,"Loyalty_Start_Date":null,"LastName":"TestYuni","Industry":null,"Id":"' + a.id + '","Guruland_Created_Date":null,"FirstName":"aaaa","Fax":null,"Customer_Type":"Agent","Current_Subscription":"Advance","Country":"Singapore","CEA_Salesperson_Number":null,"CEA_license":null,"BillingState":"test State","AgentNet_ID":"2334","REA_Id":"1234","AgentKey":null,"Agency_name":"Hhh","Agency_id":"1234","Account_Rule_Code":"dddfdf","Account_Rule":null}', resp, 'Expected and Actual response from GET method did not match');
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        req2.requestURI = '/services/apexrest/agent';  //Request URL
        req2.httpMethod = 'GET';//HTTP Request Type
        req2.addParameter('Id', 'abcd');
        RestContext.request = req2;
        RestContext.response= res2;
        
        AgentAPI.getAccount();
        resp = res2.responseBody.toString();
        system.debug('Second Actual Response : ' + resp);
        system.assertEquals('Agent requested by Guruland does not exist in Salesforce.', resp, 'Expected and Actual response from GET method did not match');
        
        String jsonStr = 
            '{' + 
            '"FirstName": "testYuni", ' + 
            '"LastName": "lastName", ' +
            '"PersonTitle": "Ms", ' + 
            '"PersonBirthdate": "' + system.now().addDays(-360).format('yyyy-MM-dd') +'", ' +
            '"PersonMobilePhone": "123456789", ' + 
            '"PersonEmail": "test@mail.com", ' +
            '"PersonMailingStreet": "abc", ' + 
            '"PersonMailingCity": "abc", ' +
            '"BillingCountry": "test", ' +
            '"BillingState": "Singapore", ' +
            '"PersonMailingPostalCode": "123", ' + 
            '"Local_Language_Data":{"LocalLanguage_Title":"TitleLocal","LocalLanguage_Last_Name":"LastLocal","LocalLanguage_First_Name":"firstLocal","LocalLanguage_Billing_Street":null},'+
            '"Agency_id": "Agency_id",' +
            '"Salutation": "Mr.",' +
            '"Country": "Singapore",' +
            '"AgentNet_Id": "000333",' +
            '"Account_Rule_Code": "aaaa",' +
            '"Subscription_End_Date": "' + system.now().addDays(-360).format('yyyy-MM-dd') +'", ' +
            '"Agency_Name": "aaaaa"' +
            '}';
        req.requestURI = '/services/apexrest/agent';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonStr);
        RestContext.request = req;
        RestContext.response= res;
        AgentAPI.upsertAgent();
        list<Account> existingAccWithId = new List<Account>([select id from account where PersonEmail='aaa@ayahoo.com' and Country__c='Singapore' and agentnet_id__c = '2334' LIMIT 1 ]);
        Id testAgentId = existingAccWithId[0].Id;
        
        resp = res.responseBody.toString();
        system.debug('Third Actual Response : ' + resp);
        //system.assertEquals('{"Website":null,"Subscription_Start_Date":null,"Subscription_End_Date":"' + system.now().addDays(-360).format('yyyy-MM-dd') +'","Status":null,"Salutation":"Mr.","Phone":null,"PersonTitle":"Ms","PersonMobilePhone":"123456789","PersonMailingStreet":"abc","PersonMailingPostalCode":"123","Local_Language_Data":{"LocalLanguage_Title":"TitleLocal","LocalLanguage_Last_Name":"LastLocal","LocalLanguage_First_Name":"firstLocal","LocalLanguage_Billing_Street":null},"PersonMailingCity":"abc","PersonEmail":"test@mail.com","PersonBirthdate":"' + system.now().addDays(-360).format('yyyy-MM-dd') +'","Netsuite_ID":null,"Mobile_Country":null,"Loyalty_Start_Date":null,"LastName":"lastName","Industry":null,"Id":null,"Guruland_Created_Date":null,"FirstName":"testYuni","Fax":null,"Customer_Type":null,"Current_Subscription":null,"Country":"Singapore","CEA_Salesperson_Number":null,"CEA_license":null,"BillingState":"State","AgentNet_ID":"000333","AgentNet_Error":null,"AgentKey":null,"Agency_name":"aaaaa","Agency_id":"Agency_id","Account_Rule_Code":"aaaa","Account_Rule":null}', resp, 'Expected and Actual response from GET method did not match');
        
        String jsonStr2 = 
            '{' + 
            '"FirstName": "testYuni", ' + 
            '"LastName": "lastName", ' +
            '"PersonTitle": "Ms", ' + 
            '"PersonBirthdate": "' + system.now().addDays(-360).format('yyyy-MM-dd') +'", ' +
            '"Phone": "123456789", ' + 
            '"PersonEmail": "test@mail.com", ' +
            '"PersonMailingStreet": "abc", ' + 
            '"PersonMailingCity": "abc", ' +
            '"BillingCountry": "test", ' + 
            '"PersonMailingPostalCode": "123", ' + 
            '"BillingState": "test", ' + 
            '"Agency_id": "Agency_id",' +
            '"Country": "Singapore",' +
            '"Salutation": "Mr.",' +
            '"AgentNet_Id": "2334",' +
            '"Account_Rule_Code": "aaaa",' +
            '"Subscription_End_Date": "'  + system.now().addDays(-360).format('yyyy-MM-dd') +'", ' +
            '"Agency_Name": "aaaaa"' +
            
            '}';
        req2.requestURI = '/services/apexrest/agent';  //Request URL
        req2.httpMethod = 'POST';//HTTP Request Type
        req2.requestBody = Blob.valueof(jsonStr2);
        RestContext.request = req2;
        RestContext.response= res2;
        AgentAPI.upsertAgent();
        resp = res2.responseBody.toString();
        system.debug('Fourth Actual Response : ' + resp);
        system.assertEquals('One or many of these required field are missing : FirstName, LastName, PersonTitle, PersonBirthdate, Phone, PersonEmail, Country, and one of (Agency_id or Agency_Name)', resp, 'Expected and Actual response from GET method did not match');
        
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();    
        String jsonStr3 = 
            '{' + 
            '"FirstName": "testYuni", ' + 
            '"LastName": "lastName", ' +
            '"PersonTitle": "Ms", ' + 
            '"PersonBirthdate": "' + system.now().addDays(-360).format('yyyy-MM-dd') +'", ' +
            '"PersonMobilePhone": "123456789", ' + 
            '"PersonEmail": "test@mail.com", ' +
            '"PersonMailingStreet": "abc", ' + 
            '"PersonMailingCity": "abc", ' +
            '"BillingCountry": "test", ' + 
            '"PersonMailingPostalCode": "123", ' + 
            '"BillingState": "test", ' + 
            '"Agency_id": "Agency_id",' +
            '"Salutation": "Mr.",' +
            '"Country": "Singapore",' +
            '"AgentNet_Id": "000333",' +
            '"Account_Rule_Code": "aaaa",' +
            '"Subscription_End_Date": "' + system.now().addDays(-360).format('yyyy-MM-dd') +'", ' +
            '"Agency_Name": "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo"' +
            '}';
        req3.requestURI = '/services/apexrest/agent';  //Request URL
        req3.httpMethod = 'POST';//HTTP Request Type
        req3.requestBody = Blob.valueof(jsonStr3);
        RestContext.request = req3;
        RestContext.response= res3;
        AgentAPI.upsertAgent();
        resp = res3.responseBody.toString();
        system.debug('Fifth Actual Response : ' + resp);
        //system.assertEquals('Upsert failed. First exception on row 0 with id '+testAgentId+'; first error: STRING_TOO_LONG, Agency Name: data value too large: Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo (max length=60): [Agency_Name__c]', resp, 'Expected and Actual response from GET method did not match');
        
        RestRequest req4 = new RestRequest(); 
        RestResponse res4 = new RestResponse();    
        String jsonStr4 = 
            '{' + 
            '"Id": "'+ a.Id +  '",' +
            '"FirstName": "testYuni", ' + 
            '"LastName": "lastName", ' +
            '"PersonTitle": "Mssss", ' + 
            '"PersonBirthdate": "' + system.now().addDays(-360).format('yyyy-MM-dd') +'", ' +
            '"Phone": "123456789", ' + 
            '"PersonEmail": "test@mail.com", ' +
            '"PersonMailingStreet": "abc", ' + 
            '"PersonMailingCity": "abc", ' +
            '"BillingCountry": "test", ' + 
            '"PersonMailingPostalCode": "123", ' + 
            '"BillingState": "test", ' + 
            '"Agency_id": "1234",' +
            '"Country": "Sngapore",' +
            '"Salutation": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.",' +
            '"Account_Rule_Code": "aaaa",' +
            '"Subscription_End_Date": "'  + system.now().addDays(-360).format('yyyy-MM-dd') +'", ' +
            '"Guruland_Created_Date": "'  + system.now()+'", ' +
            '"Agency_Name": "aaaaa"' + 
            '}';
        req4.requestURI = '/services/apexrest/agent';  //Request URL
        req4.httpMethod = 'POST';//HTTP Request Type
        req4.requestBody = Blob.valueof(jsonStr4);
        RestContext.request = req4;
        RestContext.response= res4;
        AgentAPI.upsertAgent();
        resp = res4.responseBody.toString();
        system.debug('Sixth Actual Response : ' + resp);
        system.assertEquals('One or many of these required field are missing : FirstName, LastName, PersonTitle, PersonBirthdate, Phone, PersonEmail, Country, and one of (Agency_id or Agency_Name)', resp, 'Expected and Actual response from GET method did not match');
        
        AgentAPI.Guruland gl = new AgentAPI.Guruland(); 
        Test.stopTest();
    }
}
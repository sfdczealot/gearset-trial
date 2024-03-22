/*
* Created by : Yuni
* Company    : Viseo Asia PTE LTD
* created Date : 27/07/2018
*/
@isTest
public class AgencyAPI_Test {
    static testMethod void runTest() {
        Test.StartTest();
        
PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        string resp = '';
        String accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.Name = 'Unit Test Agency';
        a.Customer_Type__c = 'Agency';
        a.CEA_License__c = 'test';
        insert a;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/agency';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        req.addParameter('id', a.id);
        RestContext.request = req;
        RestContext.response= res;
        
        AgencyAPI.getAccount();
        resp = res.responseBody.toString();
        system.debug('First Actual Response : ' + resp);
        //system.assertEquals('{"Id":"' + a.Id + '","Country":"Singapore","CEA_Salesperson_Number":null,"CEA_License":null,"Agency_Name":"Unit Test Agency","Agency_Id":null}', resp, 'Expected and Actual response from GET method did not match');
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        req2.requestURI = '/services/apexrest/agency';  //Request URL
        req2.httpMethod = 'GET';//HTTP Request Type
        req2.addParameter('id', 'abcd');
        RestContext.request = req2;
        RestContext.response= res2;
        
        AgencyAPI.getAccount();
        resp = res2.responseBody.toString();
        system.debug('Second Actual Response : ' + resp);
        system.assertEquals('Agency requested by Guruland does not exist in Salesforce.', resp, 'Expected and Actual response from GET method did not match');
        
        String jsonStr = 
            '{' + 
            '"id": "' + a.id + '", ' + 
            '"Agency_Id": "Agency_Id"' +
            '}';
        system.debug('JSON String 1 : ' + jsonStr);
        req.requestURI = '/services/apexrest/agency';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonStr);
        RestContext.request = req;
        RestContext.response= res;
        
        AgencyAPI.updateAgency();
        resp = res.responseBody.toString();
        system.debug('Third Actual Response : ' + resp);
        //system.assertEquals('{"Id":"' + a.id + '","Country":"Singapore","CEA_Salesperson_Number":null,"CEA_License":null,"Agency_Name":"Unit Test Agency","Agency_Id":"Agency_Id"}', resp, 'Expected and Actual response from GET method did not match');
        
        String jsonStr2 = 
            '{' + 
            '"id":'+1234 +','  + 
            '"Agency_Id": "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut"' +
            '}';
        system.debug('JSON String 2 : ' + jsonStr2);
        req2.requestURI = '/services/apexrest/agency';  //Request URL
        req2.httpMethod = 'POST';//HTTP Request Type
        req2.requestBody = Blob.valueof(jsonStr2);
        RestContext.request = req2;
        RestContext.response= res2;
        
        resp = res2.responseBody.toString();
        AgencyAPI.updateAgency();
        system.debug('Fourth Actual Response : ' + resp);
        system.assertEquals('Agency requested by Guruland does not exist in Salesforce.', resp, 'Expected and Actual response from GET method did not match');
        
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        String jsonStr3 = 
            '{' + 
            '"id": "' + a.id + '", ' + 
            '"Agency_Id": "Lorem ipsum dolor sit amet, consectetuer adipis cing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut"' +
            '}';
        system.debug('JSON String 3 : ' + jsonStr3);
        req3.requestURI = '/services/apexrest/agency';  //Request URL
        req3.httpMethod = 'POST';//HTTP Request Type
        req3.requestBody = Blob.valueof(jsonStr3);
        RestContext.request = req3;
        RestContext.response= res3;
        
        AgencyAPI.updateAgency();              
        resp = res3.responseBody.toString();
        system.debug('Fifth Actual Response : ' + resp);
        system.assertEquals('Update failed. First exception on row 0 with id ' + a.id + '; first error: STRING_TOO_LONG, Agency Id: data value too large: Lorem ipsum dolor sit amet, consectetuer adipis cing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nu... (max length=40): [Agency_Id__c]', resp, 'Expected and Actual response from GET method did not match');
        
        Test.stopTest();
    }
}
@isTest
public class PGAccountSync_Test {
    private static final String FAKE_RESPONSE_JSON = '{' +
            '	"type": "OpptySync",' +
            '	"record": {' +
            '		"status": "Closed Won",' +
            '		"RecordSplit": {' +
            '			"EntryList": [{' +
            '				"Employee": "catherine=propertyguru.com.sg@example.com",' +
            '				"Contribution": 100.00,' +
            '				"Amount": 81931.20' +
            '			}]' +
            '		},' +
            '		"optynumber_ns": "2630945",' +
            '		"optylineitem": null,' +
            '		"OMCApprovalDate": null,' +
            '		"NewRecord": {' +
            '			"UserEmail": "catherine=propertyguru.com.sg@example.com",' +
            '			"TotalDiscAmt": 44116.80,' +
            '			"SyncToAN": "T",' +
            '			"SubId": "1",' +
            '			"StageName": "Closed Won",' +
            '			"SendToSF": "F",' +
            '			"Remarks": "Invoice to be split according to the following: \r\n1) HSBC Institutional Trust Services (Singapore) Limited as trustee of Ascendas REIT for $69,320.81\r\n\r\n2) Ascendas Land (S) Pte Ltd for $12,610.39",' +
            '			"RelatedSO": null,' +
            '			"RecordTypeId": "0127F0000005401QAA",' +
            '			"PONo": null,' +
            '			"PaymentTermId": 2,' +
            '			"OrderDate": "2018-11-29",' +
            '			"OptyNumber": null,' +
            '			"Memo": null,' +
            '			"line": {' +
            '				"EntryList": [{' +
            '					"UnitPrice": 45.00,' +
            '					"TaxCode": "5",' +
            '					"StartDate": "2018-12-04",' +
            '					"SNO": 12.00,' +
            '					"SFLineId": "00k7F00000zVnHvQAK",' +
            '					"RemDisc": 1638.00,' +
            '					"Quantity": 104.00,' +
            '					"ItmAmt": 1638.00,' +
            '					"ItemId": "8331",' +
            '					"GSTVatRate": 0.00,' +
            '					"GrossAmt": 3042.00,' +
            '					"EndDate": "2019-12-02",' +
            '					"DiscRateNumber": 0.3500000000,' +
            '					"DiscRate": 35.00,' +
            '					"DiscItemId": null,' +
            '					"Descr": "- For Rent\r\n- Prime District ( D14, D20, D22, D25, D27)\r\n- Charged 20% SOV, per week, per district\r\n- Week starts from every Tuesday to following Monday\r\nCampaign:\r\nD22: 40% SOV for 47 weeks (4 Dec 18 - 2 Dec 19)",' +
            '					"Comp": false' +
            '				}, {' +
            '					"UnitPrice": 21.00,' +
            '					"TaxCode": "5",' +
            '					"StartDate": "2018-12-04",' +
            '					"SNO": 13.00,' +
            '					"SFLineId": "00k7F00000zVnWDQA0",' +
            '					"RemDisc": 764.40,' +
            '					"Quantity": 104.00,' +
            '					"ItmAmt": 764.40,' +
            '					"ItemId": "8350",' +
            '					"GSTVatRate": 0.00,' +
            '					"GrossAmt": 1419.60,' +
            '					"EndDate": "2019-12-02",' +
            '					"DiscRateNumber": 0.3500000000,' +
            '					"DiscRate": 35.00,' +
            '					"DiscItemId": null,' +
            '					"Descr": "- For Rent\r\n- Non-Prime District ( all district except Prime - D14, D20, D22, D25, D27)\r\n- Charged 20% SOV, per week, per district\r\n- Week starts from every Tuesday to following Monday\r\nCampaign:\r\nD16: 40% SOV for 52 weeks (4 Dec 18 - 2 Dec 19)",' +
            '					"Comp": false' +
            '				}, {' +
            '					"UnitPrice": 194.00,' +
            '					"TaxCode": "5",' +
            '					"StartDate": "2018-12-10",' +
            '					"SNO": 11.00,' +
            '					"SFLineId": "00k7F00000zVG1SQAW",' +
            '					"RemDisc": 18129.30,' +
            '					"Quantity": 267.00,' +
            '					"ItmAmt": 18129.30,' +
            '					"ItemId": "10599",' +
            '					"GSTVatRate": 0.00,' +
            '					"GrossAmt": 33668.70,' +
            '					"EndDate": "2019-12-09",' +
            '					"DiscRateNumber": 0.3500000000,' +
            '					"DiscRate": 35.00,' +
            '					"DiscItemId": null,' +
            '					"Descr": "- Charged per Listing",' +
            '					"Comp": false' +
            '				}]' +
            '			},' +
            '			"Id": "0067F00000HhGmCQAV",' +
            '			"CurrencyIsoCode": "SGD",' +
            '			"ContactId": "6010490",' +
            '			"att": {' +
            '				"EntryList": [{' +
            '					"name": "Ascendas 2019 renewal contract (signed).pdf"' +
            '				}]' +
            '			},' +
            '			"AccountId": "6010390"' +
            '		},' +
            '		"action": "OptyRec"' +
            '	}' +
            '}';
	static testMethod void runTest() {
    	Test.setMock(HttpCalloutMock.class, new Mock());
        Test.StartTest();
        
        String accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        PGTestDataFactory_v2.initSetupData();
        a.Name = 'TestYuni';
        a.Customer_Type__c = 'Agency';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.CEA_License__c = 'CEATEst';
        insert a;
       contact c = new contact(accountid=a.id,firstname='test',lastname='test',email='test@testcse.com');
        insert c;
        /*
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/agency';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        //String JsonMsg=JSON.serialize(reqst);
        //req.requestBody = Blob.valueof(JsonMsg);
        req.addParameter('Id', a.id);
        RestContext.request = req;
        RestContext.response= res;
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        req2.requestURI = '/services/apexrest/agency';  //Request URL
        req2.httpMethod = 'POST';//HTTP Request Type
        req2.addParameter('Id', 'abcd');
        RestContext.request = req2;
        RestContext.response= res2;
        
        String jsonStr = 
            '{' + 
            '"Id": "' + a.id + '", ' + 
            '"Agency_Id": "Agency_Id"' +
            '}';
        system.debug('ABCD' + jsonStr);
        req.requestURI = '/services/apexrest/agency';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonStr);
        RestContext.request = req;
        RestContext.response= res;
        
        String jsonStr2 = 
            '{' + 
            '"id":'+1234 +','  + 
            '"Agency_Id": "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut"' +
            '}';
        system.debug('ABCD' + jsonStr2);
        req2.requestURI = '/services/apexrest/agency';  //Request URL
        req2.httpMethod = 'POST';//HTTP Request Type
        req2.requestBody = Blob.valueof(jsonStr2);
        RestContext.request = req2;
        RestContext.response= res2;
               
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        String jsonStr3 = 
            '{' + 
             '"Id": "' + a.id + '", ' + 
            '"Agency_Id": "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut"' +
            '}';
        system.debug('ABCD' + jsonStr3);
        req3.requestURI = '/services/apexrest/agency';  //Request URL
        req3.httpMethod = 'POST';//HTTP Request Type
        req3.requestBody = Blob.valueof(jsonStr3);
        RestContext.request = req3;
        RestContext.response= res3;*/
        list<id> AccIDB2B = new list<id>();
        AccIDB2B.add(a.Id);
        map<id,Account> OldMapAcc = new map<id,Account> ();
        OldMapAcc.put(a.id,a);
        list<Account> AccIDB2B2 = new list<Account>();
        AccIDB2B2.add(a);
        PGAccountSync.updateSFAccount(AccIDB2B,'123123123');
        PGAccountSync.isFirstRun();
        PGAccountSync.afterInsertB2B(AccIDB2B);
        PGAccountSync.insertAccountNS(AccIDB2B2);
        PGAccountSync.updateAccountNS(AccIDB2B2,OldMapAcc);
              
        Test.stopTest();
	}
    
    
    private class Mock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            // You could assert the request content here

            HTTPResponse res = new HTTPResponse();
            res.setBody(FAKE_RESPONSE_JSON);
            res.setStatusCode(200);
            return res;
        }
    }
}
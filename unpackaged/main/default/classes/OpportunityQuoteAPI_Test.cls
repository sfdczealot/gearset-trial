/*
* Created by : Yuni
* Company    : Viseo Asia PTE LTD
* created Date : 31/07/2018
*/
@isTest
public class OpportunityQuoteAPI_Test {
    static testMethod void runTest() {
        
        QliToOliFieldMapping__c objcustomsetting = new QliToOliFieldMapping__c();
        objcustomsetting.Name='Start_Date__c';
        objcustomsetting.OliField__c='Start_Date__c';
        insert objcustomsetting;
                PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        
        User runUsser = [Select id, Webuser_ID__c From User where id =: UserInfo.getUserId()];
        
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();       
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();       
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni';
        a.salutation = 'Mr.';
        a.FirstName = 'abc';
        a.Status__c='Active';
        
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = '12121assas@yahoo.com';
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        
        a.PersonBirthdate = system.today();
        insert a;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'New';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.From_Button__c = true;
        opp.Payment_Time__c = system.now();
        //opp.Agent_Accepted_Time__c = system.now();
        opp.Last_Outbound_Sync__c = system.now();
        opp.Outbound_Sync_Error__c = 'test';
        opp.Guruland_Quote_Link__c = '';
        opp.Subsidiary__c = PGTestDataFactory.createSubsidiary().Id;
        opp.Allowed_Payment_Type__c = 'All';
        opp.Count_of_Referral_Agent_Promotion__c = 1;
        opp.CurrencyIsoCode = 'SGD';
        opp.recordtypeid=oppRectype;
        insert opp;
        
        opp.NetSuite_Sales_Order__c = '1212';
        update opp;   
        
        
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc');
        insert prod;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.id;
        oli.Product2Id = prod.id;
        oli.PricebookEntryId = pbe.id;
        oli.Quantity = 3;
        oli.UnitPrice =3;
        oli.SNo__c = 1.00;
        oli.GST_VAT_Rate__c = 7;
        insert oli;
        
        map<string, Country_Attribute__mdt> countryAtt = EligibilityHandler.getCountryAttribute();
        
        Test.StartTest();
        string oppStage = OpportunityQuoteAPI.getOpportunityStage(opp.id);
        // system.assertEquals('Proposal', oppStage, 'Invalid Stage');
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new OpportunityQuoteCalloutMock());
        // This causes a fake response to be sent from the class that implements HttpCalloutMock.
        HttpResponse response = OpportunityQuoteAPI.sendtoGurulandAct(Opp.id);
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        system.assertEquals('application/json', contentType);
        String actualValue = response.getBody();
        system.debug(response.getBody());
        String expectedValue = '{"id":5799,"region":"sg","agent_id":43770,"invoice_id":"PGSO-19005761","currency":"sgd","total":1.07,"order_info":"{\'webuserId\':\'43770\',\'tranTotal\':\'1.07\',\'tranTax\':\'0.07\',\'tranDisc\':\'0.00\',\'tranAmount\':\'1.07\',\'salesRep\':{\'name\':\'Admin Viseo\',\'email\':\'whisnu-satriya.wardhana@viseo.com\',\'contactNo\':\'6546373\'},\'region\':\'sg\',\'referenceNo\':\'PGSO-19005761\',\'email\':\'viseo1.viseo1.deepti.malik09@gmail.com\',\'customerName\':\'Deepti Malik\',\'createdDate\':\'2019-01-30 14:15:29\',\'billaddress\':\'sadas asdas Singapore\', \'items\': [{\'startDate\':\'2019-01-30\',\'itemTax\':\'0.07\',\'itemQuantity\':\'1.00\',\'itemPrice\':\'1.00\',\'itemName\':\'PGSG Bundle Ad Credit (1 Credit)\',\'itemDisc\':\'0.00\',\'itemDescription\':\'Bundle Ad Credit (1 Credit)\',\'itemAmount\':\'1.07\',\'endDate\':\'2020-01-29\'}]}","payment_method":"all","os":"","browser":"","ip_address":"","timestamp":null,"accepted_datetime":null,"created":"2019-01-30 14:16:24","modified":"2019-01-30 14:16:27","status":"open","hash":"U2FsdGVkX19nQSBmR5EtTUjzol6QF8uZkdfMRCO79eCG0orLlEcV/uvSDU+RsNcX","expiry":"2019-01-30 14:16:24","hash_base64":"VTJGc2RHVmtYMTluUVNCbVI1RXRUVWp6b2w2UUY4dVprZGZNUkNPNzllQ0cwb3JMbEVjVi91dlNEVStSc05jWA=="}';
        system.assertEquals(expectedValue, actualValue, 'Invalid HTTP Response body');
        system.assertEquals(200, response.getStatusCode(), 'Invalid Status Code');
        
        OpportunityQuoteAPI.updateOpportunityLink(opp.id, 'Hash64', false);
        OpportunityQuoteAPI.createFeeditem(opp.id,'Test');
        
        Test.stopTest();
        Opportunity oppAssert = [select Id, Name, Guruland_quote_link__c, Country__c from Opportunity where Id=:opp.Id];
        system.assertEquals(countryAtt.get(oppAssert.Country__c).Payment_Link__c+'Hash64', oppAssert.Guruland_Quote_Link__c, 'Invalid Guruland Quote Link.');
    } 
}
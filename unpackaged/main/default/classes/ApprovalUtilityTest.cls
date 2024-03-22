@isTest
public class ApprovalUtilityTest {
    
    private static final String FAKE_RESPONSE_JSON = '{' +
        '  "type": "OpptySync",' +
        '  "record": {' +
        '    "status": "Closed Won",' +
        '    "RecordSplit": {' +
        '      "EntryList": [{' +
        '        "Employee": "catherine=propertyguru.com.sg@example.com",' +
        '        "Contribution": 100.00,' +
        '        "Amount": 81931.20' +
        '      }]' +
        '    },' +
        '    "optynumber_ns": "2630945",' +
        '    "optylineitem": null,' +
        '    "OMCApprovalDate": null,' +
        '    "NewRecord": {' +
        '      "AutoActivation": "T",' +
        '      "UserEmail": "catherine=propertyguru.com.sg@example.com",' +
        '      "TotalDiscAmt": 44116.80,' +
        '      "SyncToAN": "T",' +
        '      "SubId": "1",' +
        '      "StageName": "Closed Won",' +
        '      "SendToSF": "F",' +
        '      "Remarks": "Invoice to be split according to the following: \r\n1) HSBC Institutional Trust Services (Singapore) Limited as trustee of Ascendas REIT for $69,320.81\r\n\r\n2) Ascendas Land (S) Pte Ltd for $12,610.39",' +
        '      "RelatedSO": null,' +
        '      "RecordTypeId": "0127F0000005401QAA",' +
        '      "PONo": null,' +
        '      "PaymentTermId": 2,' +
        '      "OrderDate": "2018-11-29",' +
        '      "OptyNumber": null,' +
        '      "Memo": null,' +
        '      "line": {' +
        '        "EntryList": [{' +
        '          "UnitPrice": 45.00,' +
        '          "TaxCode": "5",' +
        '          "StartDate": "2018-12-04",' +
        '          "SNO": 12.00,' +
        '          "SFLineId": "00k7F00000zVnHvQAK",' +
        '          "RemDisc": 1638.00,' +
        '          "Quantity": 104.00,' +
        '          "ItmAmt": 1638.00,' +
        '          "ItemId": "8331",' +
        '          "GSTVatRate": 0.00,' +
        '          "GrossAmt": 3042.00,' +
        '          "EndDate": "2019-12-02",' +
        '          "DiscRateNumber": 0.3500000000,' +
        '          "DiscRate": 35.00,' +
        '          "DiscItemId": null,' +
        '          "Descr": "- For Rent\r\n- Prime District ( D14, D20, D22, D25, D27)\r\n- Charged 20% SOV, per week, per district\r\n- Week starts from every Tuesday to following Monday\r\nCampaign:\r\nD22: 40% SOV for 47 weeks (4 Dec 18 - 2 Dec 19)",' +
        '          "Comp": false,' +
        '          "AutoActivation": "T"' +
        '        }, {' +
        '          "UnitPrice": 21.00,' +
        '          "TaxCode": "5",' +
        '          "StartDate": "2018-12-04",' +
        '          "SNO": 13.00,' +
        '          "SFLineId": "00k7F00000zVnWDQA0",' +
        '          "RemDisc": 764.40,' +
        '          "Quantity": 104.00,' +
        '          "ItmAmt": 764.40,' +
        '          "ItemId": "8350",' +
        '          "GSTVatRate": 0.00,' +
        '          "GrossAmt": 1419.60,' +
        '          "EndDate": "2019-12-02",' +
        '          "DiscRateNumber": 0.3500000000,' +
        '          "DiscRate": 35.00,' +
        '          "DiscItemId": null,' +
        '          "Descr": "- For Rent\r\n- Non-Prime District ( all district except Prime - D14, D20, D22, D25, D27)\r\n- Charged 20% SOV, per week, per district\r\n- Week starts from every Tuesday to following Monday\r\nCampaign:\r\nD16: 40% SOV for 52 weeks (4 Dec 18 - 2 Dec 19)",' +
        '          "Comp": false,' +
        '          "AutoActivation": "T"' +
        '        }, {' +
        '          "UnitPrice": 194.00,' +
        '          "TaxCode": "5",' +
        '          "StartDate": "2018-12-10",' +
        '          "SNO": 11.00,' +
        '          "SFLineId": "00k7F00000zVG1SQAW",' +
        '          "RemDisc": 18129.30,' +
        '          "Quantity": 267.00,' +
        '          "ItmAmt": 18129.30,' +
        '          "ItemId": "10599",' +
        '          "GSTVatRate": 0.00,' +
        '          "GrossAmt": 33668.70,' +
        '          "EndDate": "2019-12-09",' +
        '          "DiscRateNumber": 0.3500000000,' +
        '          "DiscRate": 35.00,' +
        '          "DiscItemId": null,' +
        '          "Descr": "- Charged per Listing",' +
        '          "Comp": false,' +
        '          "AutoActivation": "T"' +
        '        }]' +
        '      },' +
        '      "Id": "0067F00000HhGmCQAV",' +
        '      "CurrencyIsoCode": "SGD",' +
        '      "ContactId": "6010490",' +
        '      "att": {' +
        '        "EntryList": [{' +
        '          "name": "Ascendas 2019 renewal contract (signed).pdf"' +
        '        }]' +
        '      },' +
        '      "AccountId": "6010390"' +
        '    },' +
        '    "action": "OptyRec"' +
        '  }' +
        '}';
    @TestSetup
    static void TestData() {
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        PGTestDataFactory_v2.initSetupData();  
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGOpportunityTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        Trigger_Execute__c customsetting2=new Trigger_Execute__c();
        customsetting2.Name='Trigger_OpportunitySplit';
        customsetting2.Enable_del__c=true;
        insert customsetting2;
        
        Test.startTest();
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'PGAccount';
        a.salutation = 'Mr.';
        a.FirstName = 'abc';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.Subscription_End_Date__c = Date.newInstance(2021, 12, 9);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = 'test@test.com';
        a.Country__c = 'Singapore';
        a.Status__c = 'Active';
        a.Approval_Status__c = 'Approved';
        a.CEA_Salesperson_Number__c = 'C546376K';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        a.VIP_Campaign__c = 'Test';
        insert a;
        string accRectype1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account a1 = new Account();
        a1.RecordTypeId = accRectype1;
        a1.Name = 'PGAccount1';
        a1.Account_Rule_Code__c = 'test2';
        a1.AgentNet_ID__c = '1223';
        // a1.PersonEmail = 'test2@test.com';
        a1.Status__c='Active';
        a1.CurrencyIsoCode = 'SGD';
        
        a1.Subscription_Start_Date__c = system.today().addMonths(-9);
        a1.Subscription_End_Date__c = Date.newInstance(2021, 12, 9);
        
        a1.CEA_License__c = 'Test1';
        a1.Customer_Type__c = 'Agency';
        a1.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = 'D534265G';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a1;
        
        
        
        Subsidiary__c sub = new Subsidiary__c();
        sub.Country__c = 'malaysia';
        sub.Name = 'Sub test';
        sub.Tax_Label__c = 'Open';
        sub.CurrencyIsoCode = 'SGD' ; 
        insert sub; 
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4; 
        opp.Total_Spending__c = 100;
        opp.Payment_Time__c = system.now();
        opp.Payment_Type__c='Offline';
        opp.AccountId = a.id;
        opp.Agent_Accepted_Time__c = system.now();
        opp.Subsidiary__c = PGTestDataFactory.createSubsidiary().Id;
        
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.StageName = 'Prospecting';
        opp.Order_Type_Clone__c = 'Contract - Make Good';
        insert opp;
        
        
        Quote qu = new Quote();
        qu.name = 'TestQuote';
        qu.CreatedDate__c = system.today();
        qu.OpportunityId = opp.Id;
        qu.Status = 'Proposal';
        insert qu;
        test.stopTest();
        }
    }
    @isTest
    public static void testMethodOne(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        Opportunity opp = [select id,Name from opportunity where Name = 'Test Opp'];
        Test.startTest();
        ApprovalUtility.beforeApprovalValidation(opp.Id,'Opportunity');
        Test.stopTest();
    }
    @isTest
    public static void testMethodOne1(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        
        Test.startTest();
        Account acc = [select id,Name from Account where LastName = 'PGAccount'];
        Opportunity opp = [select id,Name from opportunity where Name = 'Test Opp'];
        
        Profile prof = [select id from profile where name LIKE '%System Administrator%' limit 1];
        
        ApprovalUtility.runApproval(opp.id, 'testComment','testComment','Opportunity');
        ApprovalUtility.runApproval(acc.Id, 'testComment','testComment','Account');
        ApprovalUtility.beforeApprovalValidation(opp.Id,'Opportunity');
        ApprovalUtility.increaseCoverage();
        Test.stopTest();
    }
    @isTest
    public static void testMethodTwo(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        
     //   UserRole r = new UserRole (DeveloperName = 'SG_Commandos_Sales_Rep', Name = 'SG Commandos Sales Rep' );
        
      /*  User u = new User(
            ProfileId = [SELECT Id FROM Profile  limit 1].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r.Id
        );
        */
            
            Test.startTest();
            Opportunity opp = [select id,Name from opportunity where Name = 'Test Opp'];
            //Opportunity opp1 = [select id,Name from opportunity where Name = 'Test Opp1'];
            Account acc = [select id,Name from Account where LastName = 'PGAccount'];
            Quote qu = [select Id,Name from Quote where Name = 'TestQuote'];
            Account acc1 = [select id,Name from Account where Name = 'PGAccount1'];
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('testComment');
            req.setObjectId(opp.Id);
            //Approval.ProcessResult result = Approval.process(req);
            
         UserRole r = new UserRole (DeveloperName = 'SG_Commandos_Sales_Rep', Name = 'SG Commandos Sales Rep' );
        
       User u = new User(
            ProfileId = [SELECT Id FROM Profile  limit 1].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r.Id
        );
        insert u;
            
            
            
            //opp1.Payment_Type__c='Offline';
            //update opp1;
            opp.Payment_Type__c='Offline';
            update opp;
            ApprovalUtility.beforeApprovalValidation(opp.Id,'Opportunity');
            
            ApprovalUtility.runApproval(opp.Id, 'testComment','testComment','Opportunity');
            
            ApprovalUtility.runApproval(acc1.Id, 'testComment','testComment','Account');
            
            ApprovalUtility.runApproval(acc.Id, 'testComment','testComment','Account');
            ApprovalUtility.beforeApprovalValidation(opp.Id,'Opportunity');
            ApprovalUtility.runApproval(opp.Id, 'testComment','testComment','Opportunity');
            ApprovalUtility.runApproval(qu.Id,'testComment','testComment','Quote');
            ApprovalUtility.displayVIPCampaignName(acc.Id);
            ApprovalUtility.fetchVIPCampaign();
            
            
            
            Test.stopTest(); 
            
            
            
            
        
        
        
        
        
    }
    @isTest
    public static void testMethodThree(){
        // Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        Account acc = [select id,Name from Account where LastName = 'PGAccount'];
        ApprovalUtility.runApproval(acc.Id, 'testComment','testComment','Account');
        
        Opportunity opp = [select id,Name,AccountId from opportunity where Name = 'Test Opp'];
        ApprovalUtility.runApproval(null, null,null,null);
        ApprovalUtility.beforeApprovalValidation(opp.Id,'Opportunity');
        
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
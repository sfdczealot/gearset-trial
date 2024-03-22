@isTest
public class PGOpportunityTriggerHandler_Test {
    
    
    @isTest
    static void killSOTest(){
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
    Account testAccount = TestDataSetupSO.createB2BAcc();

        testAccount.Phone = '2345';
    insert testAccount;
    //Contact testContact = TestDataSetupSO.createContact(testAccount);

    Opportunity testOpportunity = TestDataSetupSO.createOpportunity(testAccount, null);
    testOpportunity.Subsidiary_Type__c = 'iPP';    
    insert testOpportunity;
    csmso__Sales_Order__c testSO = TestDataSetupSO.createSalesOrder(testAccount, testOpportunity);
    insert testSO;
        test.startTest();
        testOpportunity.stageName='Closed lost';
        testOpportunity.Loss_Reason__c='others';
        testOpportunity.Loss_Reason_Detail__c='qwerty';
        update testOpportunity;
        //opportunityTriggerHelper.codeCoverage();
        test.stoptest();
    }
       
    static testMethod void testContactTrigger() {
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.Name = 'Unit Test Agency';
        a.Customer_Type__c = 'Developer';

        a.Phone = '2345';
        insert a;
        
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.email = 'b2b@unittest.com';
        c.Title = 'Mr.';
        c.LastName = 'Unit Test Last Name';
        c.FirstName = 'Unit Test First Name';
        insert c;
    } 
    
    /*
Below section is for testing oppty sync from SF to NS
*/
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
   
    static testMethod void testOpportunitySyncProjectX() {
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
                PGTestDataFactory_v2.CreateTriggerExecuteCS('Trigger_OpportunitySplit',true);

        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        boolean firstRun = true;
        integer ctrRun = 1;
        DmlException e;
        User runUsser = [Select id, Webuser_ID__c From User where id =: UserInfo.getUserId()];
        runUsser.Webuser_ID__c = 1;
        update runUsser;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'PGAccount';
        a.salutation = 'Mr.';
        a.FirstName = 'abc';
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
        a.PersonEmail = 'test@test.com';
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = 'C458654K';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        a.Mobile_Country__c = '65';

        a.Phone = '2345';
        insert a;
        
        Account testAccount = TestDataSetupSO.createB2BAcc();

        testAccount.Phone = '2345';    
        insert testAccount;
        Contact testContact = TestDataSetupSO.createContact(testAccount);
        insert testContact;

        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = testAccount.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Payment_Time__c = system.now();
        opp.Agent_Accepted_Time__c = system.now();
        opp.Subsidiary__c = PGTestDataFactory.createSubsidiary().Id;
        opp.OMC_Approved_Date__c = system.now();
        insert opp;
        
        opp.Approval_Status__c = 'OMC Approval Approved';
        opp.StageName = 'Closed Won';
        
//        update opp;
        
        list < Product2 > prod = new list < Product2 > ();
        prod.add(new product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = '1.00', Product_Function__c = 'post'));
        prod.add(new product2(Name = 'Test Prod2', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = '1.12', Product_Function__c = 'aa'));
        insert prod;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id = StdpricebookId, product2id = prod[0].id, unitprice = 100.0, isActive = true,CurrencyIsoCode = 'SGD');
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id = StdpricebookId, product2id = prod[1].id, unitprice = 100.0, isActive = true,CurrencyIsoCode = 'SGD');
        insert pbe2;
        
        list < OpportunityLineItem > oli = new list < OpportunityLineItem > ();
        oli.add(new opportunityLineItem(OpportunityId = opp.id, Product2Id = prod[0].id, PricebookEntryId = pbe.id, Quantity = 3, UnitPrice = 3, SNo__c = 1.00, GST_VAT_Rate__c = 7, PO__c = true, Start_Date__c = system.today(),Amount_Despite_VIP__c=2.3, End_Date__c = system.today().addDays(30)));
        oli.add(new opportunityLineItem(OpportunityId = opp.id, Product2Id = prod[1].id, PricebookEntryId = pbe.id, Quantity = 3, UnitPrice = 3, SNo__c = 1.11, GST_VAT_Rate__c = 7, PO__c = true, Start_Date__c = system.today(),Amount_Despite_VIP__c=2.7, End_Date__c = system.today().addDays(30)));
        
        insert oli;
        
        Attachment attach = new Attachment();
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = opp.id;
        insert attach;
        
        Contentversion cv = new Contentversion();
        cv.Title = 'ABC';
        cv.PathOnClient = 'test';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = opp.id;
        cdl.ShareType = 'I';
        insert cdl;
        
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.setMock(HttpCalloutMock.class, new MockFail());
        Test.StartTest();
        PGOpportunityTriggerHandler.isFirstRun();
        firstRun = false;
        PGOpportunityTriggerHandler.RunCtr();
        list <id> OptyIDNewSync = new list <id> ();
        OptyIDNewSync.add(opp.id);
        PGOpportunityTriggerHandler.addItemToNSQueueManager(OptyIDNewSync);
        PGOpportunityTriggerHandler.afterInsertClosedOpty(OptyIDNewSync);
        PGOpportunityTriggerHandler.isFirstRun(); 
        PGOpportunityTriggerHandler.RunCtr();
        //PGOpportunityTriggerHandler.increaseCoverage();
        Test.stopTest();
        }
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
    
    private class MockFail implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            // You could assert the request content here
            
            HTTPResponse res = new HTTPResponse();
            res.setBody(FAKE_RESPONSE_JSON);
            res.setStatusCode(400);
            return res;
        }
    }
    
    static testMethod void OMCRejectReasonTest(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
                PGTestDataFactory_v2.CreateTriggerExecuteCS('Trigger_OpportunitySplit',true);

        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'J548623K';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        a.Mobile_Country__c = '65';
        insert a;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.Record_Eligibility__c='AT_PGOpportunityTrigger';
        insert opp;
        Map<id,Opportunity> oppMap=NEW  Map<id,Opportunity>();
        oppMap.put(opp.id,opp);
        Opportunity OPP2=NEW opportunity(id=opp.id,
                                         Agent_Accepted_Time__c=system.today(),
                                         Payment_Type__c='Online',
                                         Payment_Amount__c=121);
        
        opportunityList.add(opp2);
        update opp2;
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(opp.id);
        // Approval.ProcessResult result = Approval.process(app);
        
        Test.StartTest();
        //Call your class method
        PGOpportunityTriggerHandler.updateOMCRejectedReason(opportunityList,oppMap);
        Test.StopTest();
        }
    }
    @istest
    public static void deleteopp(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
        
        Trigger_Execute__c PGTriggerOpp =new Trigger_Execute__c();
        PGTriggerOpp.Name='PGOpportunityTrigger';
        PGTriggerOpp.Enable_del__c=true;
        insert PGTriggerOpp;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Integration Profile' LIMIT 1];
        user u = new user(LastName = 'test',
                          FirstName='integration',
                          Alias = 'jliv',
                          Email = 'test.integration@asdf.com',
                          Username = 'test.integration@asdf.com',
                          ProfileId = profileId.id,
                          EmailEncodingKey='UTF-8',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          TimeZoneSidKey='America/Los_Angeles'
                         );
        insert u;
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        string oppRectype_B2B = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'T458765P';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        a.Mobile_Country__c = '65';
        insert a;
        
        system.runAS(u){
            test.startTest();
            User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
            runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
            update runningUser;
            
            Subsidiary__c sb = new Subsidiary__c();
            sb.Name = 'PropertyGuru Pte Ltd';
            sb.NS_Subsidiary_Internal_ID__c = '1';
            sb.CurrencyIsoCode = 'SGD';
            sb.Tax_Label__c = 'taxLabel';
            sb.Country__c = 'Singapore';
            sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
            insert sb;
            
            List<Opportunity> opportunityList = new List<Opportunity>();
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Prospecting';//'Closed Won';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(30);
            opp.Subsidiary__c = sb.id;
            opp.Total_Spending__c = 100;
            opp.RecordTypeId = oppRectype;
            opp.PG_Tenure__c = 1;
            opp.OMC_Approved_Date__c = system.today();
            opp.Order_Type_Clone__c = 'Contract - Renewal';
            // opportunityList.add(opp);
            insert opp;
            test.stopTest();
            Opportunity opp1 = new opportunity();
            opp1.Name = 'Test Opp';
            opp1.StageName = 'Closed Won';//'Prospecting';
            opp1.AccountId = a.id;
            opp1.CloseDate = system.today().AddDays(30);
            opp1.Subsidiary__c = sb.id;
            opp.Total_Spending__c = 100;
            opp1.RecordTypeId = oppRectype;//oppRectype_B2B;
            opp1.PG_Tenure__c = 1;
            opp1.Order_Type_Clone__c = 'Contract - Renewal';
            insert opp1;
      //      test.stopTest();
 /*           opportunityList.add(opp1);
            try{
                insert opportunityList;
            }catch(Exception exp){}
 */   //        test.startTest();
            
            system.debug('userinfo.id_test'+UserInfo.getProfileId());
/*            try{
                delete opportunityList; 
            }
            catch(Exception e){
                
            }   
 */           
            PGOpportunityTriggerHandler.updateAccountnextSubsDate(opp,opp1);
           // PGOpportunityTriggerHandler.validateDelete(opportunityList);

 //           test.stopTest();
        }
        }
    }
    @isTest
    public static void changeCampaignMemberStatus1(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
                PGTestDataFactory_v2.CreateTriggerExecuteCS('Trigger_OpportunitySplit',true);

        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        
        Trigger_Execute__c tE2 = new Trigger_Execute__c();
        tE2.Name = 'QuoteLineItemTrigger';
        insert tE2;
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
         Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampaignEligibilityTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
        
        Trigger_Execute__c TEEntPromo = new Trigger_Execute__c();
        TEEntPromo.Name = 'PGEntitlementPromoTrigger';
        TEEntPromo.Enable_del__c = true;
        insert TEEntPromo;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'E458965D';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        a.Mobile_Country__c = '65';
        insert a;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
         Test.startTest();
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Pending Online Payment';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.CurrencyIsoCode = 'SGD';
        opp.count_of_subscription_item_new__c = 1;
        opp.IsClone__c = 'abc';
        insert opp;
        
        opportunityList.add(opp);
        Test.stopTest();
        List<Quote> quoteList = new List<Quote>();
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.Quote_Type__c = 'B2C - Standard';
        qu.PriceBook2Id = standardPB.Id;
        qu.ContactId = [select Id,PersonContactId from Account where Id =: a.Id].PersonContactId;
        insert qu;
        quoteList.add(qu);
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.EndDate = system.today().addDays(-2);
        insert cma;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        Trigger_Execute__c TECM = new Trigger_Execute__c();
        TECM.Name = 'PGCampMemberTrigger';
        TECM.Enable_del__c = true;
        insert TECM;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = con.Id;
        cmp.Status = 'Responded';
        cmp.CampaignId = cma.Id;
        insert cmp;
        
        String modeId = [SELECT Id, DeveloperName FROM CampaignInfluenceModel where DeveloperName = 'primaryModel'].Id;
        CampaignInfluence cmi = new CampaignInfluence();
        cmi.CampaignId = cma.Id;
        cmi.OpportunityId = opp.Id;
        cmi.ModelId = modeId;
        insert cmi;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;
        
        Promo_Mechanic__c prm = new Promo_Mechanic__c();
        prm.Name = 'TestName';
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Usage__c = 1;
        prm.Discount_Reason__c = 'VIP (Spending)';
        insert prm;
        
        Promo_Mechanic__c prm1 = new Promo_Mechanic__c();
        prm1.Name = 'TestName1';
        prm1.Eligible_Product__c = prod.Id;
        prm1.Campaign_Eligibility__c = ce1.Id;
        prm1.Usage__c = 1;
        prm1.Discount_Reason__c = 'VIP (Spending)';
        insert prm1;
        
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Promo_Mechanic_Id__c = prm.Id;
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        oli.UnitPrice = 2;
        insert oli;
        listOppLine.add(oli);
        
      /*  opportunityLineItem oli2 = new opportunityLineItem();
        oli2.Product2Id = prod2.Id;
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Promo_Mechanic_Id__c = prm1.Id;
        oli2.Amount_Despite_VIP__c = 2.3;
        oli2.Pro_Rate_Amount__c = 2;
        oli2.UnitPrice = 2;
        insert oli2;
        
        List<quoteLineItem> listQuoLine = new List<quoteLineItem>();
        quoteLineItem qli = new quoteLineItem();
        qli.Product2Id = prod.Id;
        qli.OpportunityLineItemId = oli.Id;
        qli.PricebookEntryId = pbe2.Id;
        qli.Amount_Despite_VIP__c = 1.3;
        qli.Pro_Rate_Amount__c = 2;
        qli.Promo_Mechanic_Id__c = prm.Id;
        qli.UnitPrice = 2;
        qli.QuoteId = qu.Id;
        qli.Quantity = 2;
        insert qli;
        listQuoLine.add(qli);
        
        quoteLineItem qli2 = new quoteLineItem();
        qli2.Product2Id = prod2.Id;
        qli2.OpportunityLineItemId = oli2.Id;
        qli2.PricebookEntryId = pbe2.Id;
        qli2.Amount_Despite_VIP__c = 2.3;
        qli2.Pro_Rate_Amount__c = 2;
        qli2.QuoteId = qu.Id;
        qli2.UnitPrice = 2;
        qli2.Quantity = 2;
        qli2.Promo_Mechanic_Id__c = prm1.Id;
        insert qli2;*/
        
        Map<Id,Quote> newMap = new Map<Id,Quote>();
        newMap.put(qu.Id,qu);
        Map<Id,Quote> oldMap = new Map<Id,Quote>();
        oldMap.put(qu.Id,qu);
        
        Map<Id,Opportunity> oppOldMap = new Map<Id,Opportunity>();
        oppOldMap.put(opp.Id,opp);
        
        
        
        Trigger_Execute__c TEQLI = new Trigger_Execute__c();
        TEQLI.Name = 'QuoteLineItemTrigger';
        TEQLI.Enable_del__c = true;
        insert TEQLI;
        oppOldMap.get(opp.Id).StageName = 'Proposal';
        opportunityList[0].Approval_Status__c = 'OMC Approval Approved';
        update opportunityList[0];
//        Test.startTest();
        PGOpportunityTriggerHandler.changeCampaignMemberStatus(opportunityList, oppOldMap);
        oldMap.get(qu.Id).Status = 'Proposal';
        
        PGOpportunityTriggerHandler.changeCampaignMemberStatus(opportunityList, oppOldMap);
        opportunityList[0].Approval_Status__c = 'OMC Approval Approved';
        opportunityList[0].StageName = 'OMC Approval Submitted';
        PGOpportunityTriggerHandler.changeCMStatusForQuote(new List<Id>{qu.Id});
        PGOpportunityTriggerHandler.resetField(opportunityList);
 //       Test.stopTest();
        }
    }
    @istest
    public static void checkOwnerTest(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
                PGTestDataFactory_v2.CreateTriggerExecuteCS('Trigger_OpportunitySplit',true);

        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        Map<Id,opportunity> newopp = new Map<Id,opportunity>();
        Map<Id,opportunity> oldopp = new Map<Id,opportunity>();
        
        user senior =[select id from user where userrole.name ='SG - NBT & Commando Sales Head' and isactive=true limit 1];
        user junior =[select id from user where userrole.name ='SG - Commandos Team Lead (Team1)' and isactive=true  limit 1];
        
        Opportunity opp = null;
        Account a = new Account();
        Account acc_b2c  = null, acc_b2c_null = new Account();
        // Avoid mixed DML
        //User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        
        //System.runAs (thisUser) {
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            acc_b2c = PGTestDataFactory_v2.createB2CAccount('test@test.com','1232134', thisUser, sb);
            //standard PB
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            
            opp = PGTestDataFactory_v2.createB2CSubscriptionOpty(acc_b2c,thisUser,sb,standardPB, 'B2C - Upgrade');
            
            opportunity o=[select id,ownerid,recordtypeId from opportunity where id =: opp.id];
            o.ownerid=junior.id;
            update o;
            oldopp.put(opp.id,opp);
            
            newopp.put(o.id,o);
            // a = PGTestDataFactory_v2.createB2CAccount('test1@test.com','123', thisUser, sb);
            
        
        
        System.runAs (senior) {
            test.startTest();
            
            PGOpportunityTriggerHandler.checkOwnerUpdate(newopp, oldopp);
            
            test.stopTest();    
        }
        }
    }
    
    @isTest
    static void runTestMethod6(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
                PGTestDataFactory_v2.CreateTriggerExecuteCS('Trigger_OpportunitySplit',true);

        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'QuoteLineItemTrigger';
        insert TE;
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='Trigger_Quote';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsettingPG = new Trigger_Execute__c();
        customsettingPG.Name='OppTrigger';
        customsettingPG.Enable_del__c=true;
        insert customsettingPG;
        
        Trigger_Execute__c oppTrigger = new Trigger_Execute__c();
        oppTrigger.Name='PGOpportunityTrigger';
        oppTrigger.Enable_del__c=true;
        insert oppTrigger;

		        
        PGTestDataFactory_v2.initSetupData();
        
        String resp = '';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'gtest', Email='giantest@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='GianTest', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='giantest@testorg.com', Subsidiary__c='PropertyGuru Pte Ltd'
                         );
        
        insert u;
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni';
        a.salutation = 'Mr.';
        a.FirstName = 'abc';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '83739';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = '12121assas@yahoo.com';
        a.Country__c = 'Singapore';
        a.Status__c = 'Active';
        a.Customer_Type__c = 'agent';
        a.PersonMobilePhone = '988883914';
        a.Mobile_Country__c = '66';
        a.CEA_Salesperson_Number__c = 'E658912L';
        a.PersonBirthdate = system.today();
        insert a;
        
       /* Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.ownerid = u.id;
        opp.Agent_Accepted_Time__c = system.now();
        opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
        opp.Subsidiary__c = sb.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.Payment_Type__c = 'Offline';
        insert opp;
        opp.Payment_Time__c = system.now();
        opp.Approval_Status__c = 'OMC Approval Approved';
        opp.StageName = 'Pending OMC Approval';
        opp.Submit_to_OMC_Manually__c  = false;
        opp.Billing_Street_new__c = 'TestStreet';
        opp.Billing_Country_new__c = 'Thailand';  
        opp.Billing_City_new__c = 'TestCity';
        update opp;
        //opportunityTriggerHelper.codeCoverage();
        
        */
            }
    }
    
    @isTest
    public static void changeCampaignMemberStatus3(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
                PGTestDataFactory_v2.CreateTriggerExecuteCS('Trigger_OpportunitySplit',true);

        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampMemberTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TECE = new Trigger_Execute__c();
        TECE.Name = 'PGCampaignEligibilityTrigger';
        TECE.Enable_del__c = true;
        insert TECE;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
        
        Trigger_Execute__c TEEntPromo = new Trigger_Execute__c();
        TEEntPromo.Name = 'PGEntitlementPromoTrigger';
        TEEntPromo.Enable_del__c = true;
        insert TEEntPromo;
        
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
       //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'S854652D';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        a.Mobile_Country__c = '65';
        insert a;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        Test.startTest();
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;
        Test.stopTest();
        opportunityList.add(opp);
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.EndDate = system.today().addDays(-2);
        insert cma;
        
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = con.Id;
        cmp.Status = 'Responded';
        cmp.CampaignId = cma.Id;
        insert cmp;
        
        Loyalty__c objLoyal=new Loyalty__c();
        objLoyal.Name='Test Loyal';
        objLoyal.PG_Tenure__c = 0;
        objLoyal.Campaign__c = cma.Id;
        objLoyal.Discount_Percentage__c = 10;
        insert objLoyal;
        
        String modeId = [SELECT Id, DeveloperName FROM CampaignInfluenceModel where DeveloperName = 'primaryModel'].Id;
        CampaignInfluence cmi = new CampaignInfluence();
        cmi.CampaignId = cma.Id;
        cmi.OpportunityId = opp.Id;
        cmi.ModelId = modeId;
        insert cmi;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;
        
        Promo_Mechanic__c prm = new Promo_Mechanic__c();
        prm.Name = 'TestName';
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Usage__c = 1;
        insert prm;
        
        Promo_Mechanic__c prm1 = new Promo_Mechanic__c();
        prm1.Name = 'TestName1';
        prm1.Eligible_Product__c = prod.Id;
        prm1.Campaign_Eligibility__c = ce1.Id;
        prm1.Usage__c = 1;
        insert prm1;
        
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Promo_Mechanic_Id__c = prm.Id;
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        oli.Discount_Reason__c = 'Loyalty Discount';
        oli.UnitPrice = 2;
        oli.Order_Type__c = 'Upgrade Outside Renewal Window';
        insert oli;
        listOppLine.add(oli);
        
        opportunityLineItem oli2 = new opportunityLineItem();
        oli2.Product2Id = prod2.Id;
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Promo_Mechanic_Id__c = prm1.Id;
        oli2.Amount_Despite_VIP__c = 2.3;
        oli2.Pro_Rate_Amount__c = 2;
        oli2.UnitPrice = 2;
        insert oli2;
            
        Payment_Term__c paymentTerm = new Payment_Term__c();
        paymentTerm.Name = 'Immediate';
        paymentTerm.NS_Payment_Term_ID__c = 12345;
        insert paymentTerm;    
        
        Map<Id,Opportunity> newMap = new Map<Id,Opportunity>();
        newMap.put(opp.Id,opp);
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
        oldMap.put(opp.Id,opp);
        
//        Test.startTest();
        //opportunityList[0].Approval_Status__c = 'OMC Approval Approved';
        //opportunityList[0].stageName = 'Closed Won';
        PGOpportunityTriggerHandler.isFirstTime = true;
        Update opportunityList;
        
        PGOpportunityTriggerHandler.changeCampaignMemberStatus(opportunityList, oldMap);
        oldMap.get(opp.Id).stageName = 'Proposal';
        PGOpportunityTriggerHandler.updatePgTenureBonus(opportunityList,oldMap);
        PGOpportunityTriggerHandler.changeCampaignMemberStatus(opportunityList, oldMap);
        PGOpportunityTriggerHandler.createCampaignInfluenceRecords(opportunityList,oldMap);
        PGOpportunityTriggerHandler.insertHandler(opportunityList);    
        
        id runningUser1 = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1].id;
        //Task Creation
        Task taskObj = new Task();
        taskObj.Subject = 'Followup VIP Package';
        taskObj.OwnerId = runningUser1;
        taskobj.WhatId = opp.Id;
        taskObj.Status = 'Open';

        PGOpportunityTriggerHandler.closeTaskStatus(opportunityList,oldMap);
        CampaignInfluence cmi1 = new CampaignInfluence();
        cmi1.CampaignId = cma.Id;
        cmi1.OpportunityId = opp.Id;
        cmi1.ModelId = modeId;
        //insert cmi;
        system.enqueueJob(new createCampaignInfluenceClass(new list<Campaigninfluence>{cmi1}));
//        Test.stopTest();
        }
    }
    
    @istest
    public static void deleteopp2(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Integration Profile' LIMIT 1];
        user u = new user(LastName = 'test',
                          FirstName='integration',
                          Alias = 'jliv',
                          Email = 'test.integration@asdf.com',
                          Username = 'test.integration@asdf.com',
                          ProfileId = profileId.id,
                          EmailEncodingKey='UTF-8',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          TimeZoneSidKey='America/Los_Angeles'
                         );
        insert u;
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        string oppRectype_B2B = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'H245631I';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        a.Mobile_Country__c = '65';
        insert a;
        
        system.runAS(u){
            User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
            runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
            update runningUser;
            
            Subsidiary__c sb = new Subsidiary__c();
            sb.Name = 'PropertyGuru Pte Ltd';
            sb.NS_Subsidiary_Internal_ID__c = '1';
            sb.CurrencyIsoCode = 'SGD';
            sb.Tax_Label__c = 'taxLabel';
            sb.Country__c = 'Singapore';
            sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
            insert sb;
            
            List<Opportunity> opportunityList = new List<Opportunity>();
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Closed Won';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(30);
            opp.Subsidiary__c = sb.id;
            opp.Total_Spending__c = 100;
            opp.RecordTypeId = oppRectype;
            opp.PG_Tenure__c = 1;
            opp.OMC_Approved_Date__c = system.today();
            opp.Order_Type_Clone__c = 'Contract - Upgrade';
            // opportunityList.add(opp);
            
            Opportunity opp1 = new opportunity();
            opp1.Name = 'Test Opp';
            opp1.StageName = 'Prospecting';
            opp1.AccountId = a.id;
            opp1.CloseDate = system.today().AddDays(30);
            opp1.Subsidiary__c = sb.id;
            opp.Total_Spending__c = 100;
            opp1.RecordTypeId = oppRectype_B2B;
            opp1.PG_Tenure__c = 1;
            opp1.Order_Type_Clone__c = 'Contract - Upgrade';
            //opp1.Approval_Status__c ='Product Owner Approved';
            
            opportunityList.add(opp1);
            try{
                insert opportunityList;
            }catch(Exception exp){}
            test.startTest();
            
            system.debug('userinfo.id_test'+UserInfo.getProfileId());
            try{
                delete opportunityList; 
            }
            catch(Exception e){
                
            }   
            
            PGOpportunityTriggerHandler.updateAccountnextSubsDate(opp,opp1);
            test.stopTest();
        }
        }
    }
   
     @isTest
    public static void changeCampaignMemberStatus4(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        
                PGTestDataFactory_v2.CreateTriggerExecuteCS('Trigger_OpportunitySplit',true);

        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampMemberTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TECE = new Trigger_Execute__c();
        TECE.Name = 'PGCampaignEligibilityTrigger';
        TECE.Enable_del__c = true;
        insert TECE;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
        
        Trigger_Execute__c TEEntPromo = new Trigger_Execute__c();
        TEEntPromo.Name = 'PGEntitlementPromoTrigger';
        TEEntPromo.Enable_del__c = true;
        insert TEEntPromo;
        
         PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
       //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'F785462R';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        a.Mobile_Country__c = '65';
        insert a;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        Test.startTest();
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;
        Test.stopTest();
        opportunityList.add(opp);
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.EndDate = system.today().addDays(-2);
        insert cma;
        
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = con.Id;
        cmp.Status = 'Responded';
        cmp.CampaignId = cma.Id;
        insert cmp;
        
        String modeId = [SELECT Id, DeveloperName FROM CampaignInfluenceModel where DeveloperName = 'primaryModel'].Id;
        CampaignInfluence cmi = new CampaignInfluence();
        cmi.CampaignId = cma.Id;
        cmi.OpportunityId = opp.Id;
        cmi.ModelId = modeId;
        insert cmi;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;
        
        Promo_Mechanic__c prm = new Promo_Mechanic__c();
        prm.Name = 'TestName';
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Usage__c = 1;
        insert prm;
        
        Promo_Mechanic__c prm1 = new Promo_Mechanic__c();
        prm1.Name = 'TestName1';
        prm1.Eligible_Product__c = prod.Id;
        prm1.Campaign_Eligibility__c = ce1.Id;
        prm1.Usage__c = 1;
        insert prm1;
        
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Promo_Mechanic_Id__c = prm.Id;
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        oli.UnitPrice = 2;
        insert oli;
        listOppLine.add(oli);
        
        opportunityLineItem oli2 = new opportunityLineItem();
        oli2.Product2Id = prod2.Id;
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Promo_Mechanic_Id__c = prm1.Id;
        oli2.Amount_Despite_VIP__c = 2.3;
        oli2.Pro_Rate_Amount__c = 2;
        oli2.UnitPrice = 2;
        insert oli2;
        
        Map<Id,Opportunity> newMap = new Map<Id,Opportunity>();
        newMap.put(opp.Id,opp);
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
        oldMap.put(opp.Id,opp);
        List<Id> optyIds = new List<Id>();
        optyIds.add(opp.Id);
        
 //       Test.startTest();
        opportunityList[0].Approval_Status__c = 'OMC Approval Approved';
        opportunityList[0].stageName = 'Closed Won';
        PGOpportunityTriggerHandler.isFirstTime = true;
        Update opportunityList;
        
        PGOpportunityTriggerHandler.changeCampaignMemberStatus(opportunityList, oldMap);
        oldMap.get(opp.Id).stageName = 'Proposal';
        PGOpportunityTriggerHandler.updatePgTenureBonus(opportunityList,oldMap);
        PGOpportunityTriggerHandler.changeCampaignMemberStatus(opportunityList, oldMap);
        PGOpportunityTriggerHandler.createCampaignInfluenceRecords(opportunityList,oldMap);
        PGOpportunityTriggerHandler.UpdateSONS(opportunityList,oldMap);
        PGOpportunityTriggerHandler.afterInsertClosedOpty(optyIds);
        PGOpportunityTriggerHandler.runningInASandbox();
        
        id runningUser1 = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1].id;
        //Task Creation
        Task taskObj = new Task();
        taskObj.Subject = 'Followup VIP Package';
        taskObj.OwnerId = runningUser1;
        taskobj.WhatId = opp.Id;
        taskObj.Status = 'Open';

        PGOpportunityTriggerHandler.closeTaskStatus(opportunityList,oldMap);
        CampaignInfluence cmi1 = new CampaignInfluence();
        cmi1.CampaignId = cma.Id;
        cmi1.OpportunityId = opp.Id;
        cmi1.ModelId = modeId;  
        //insert cmi;
        system.enqueueJob(new createCampaignInfluenceClass(new list<Campaigninfluence>{cmi1}));
//        Test.stopTest();
        }   
    }
   
}
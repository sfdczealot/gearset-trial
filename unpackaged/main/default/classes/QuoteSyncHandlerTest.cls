@isTest
public class QuoteSyncHandlerTest {
    
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
         PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        Subsidiary__c sb1 = PGTestDataFactory.createSubsidiary();
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
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = 'test@test.com';
        a.Country__c = 'Singapore';
        a.Status__c = 'Active';
        a.Subsidiary__c = sb1.id;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;

        QliToOliFieldMapping__c objcustomsetting=new QliToOliFieldMapping__c();
        objcustomsetting.Name='Start_Date__c';
        objcustomsetting.OliField__c='Start_Date__c';
        insert objcustomsetting;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(-30);
        opp.Subsidiary__c = sb1.id;
        opp.PG_Tenure__c = 4;
        //opp.Stinger__c = true;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = false;
        opp.Is_Current_Subscription__c = true;
        opp.RecordTypeId =oppRectype;
        opp.Opportunity_Type__c ='B2C - Standard';
        opp.Include_Subscription_Ext__c = false;
        
        insert opp;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb1.id,  IsActive = true, CurrencyIsoCode = 'SGD');
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
        
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        insert oli;
        try{
            QuoteSyncHandler.syncQuoteToOpp(new list<id>{opp.id});
        }catch(exception e){}
        
        
        
    }
    @isTest
    public static void testMethodOne10(){
        
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        list<Opportunity> oppList = [select id,Name,stinger__c from opportunity where Name = 'Test Opp'];
        List<OpportunityLineItem> oliList = [select Id,opportunity.Name,OpportunityId from OpportunityLineItem where opportunity.Name='Test Opp'];
        System.debug('>>>>>>'+oliList);
        Map<Id,Id> OpportunityIdVsQuoteId = new Map<Id,Id>();
        for(Quote qu : [select Id,OpportunityId,Opportunity.Name from Quote where Opportunity.Name='Test Opp']){
            OpportunityIdVsQuoteId.put(qu.OpportunityId,qu.Id);
        }
        system.debug('::::::::'+oppList);
        if(oppList != null && !oppList.isEmpty()){
            list<Opportunity> oppList2 = QuoteSyncHandler.queryOpportunities(new list<id>{oppList[0].id});
            system.debug(':::::::::oppList2'+oppList2);
            //QuoteSyncHandler.createQuote(oppList2);
            QuoteSyncHandler.quoteData(oppList2,true);
            QuoteSyncHandler.queryOpportunities(new list<id>{oppList2[0].id});
            QuoteSyncHandler.updateQuoteCustomFields(new list<id>{oppList2[0].id});
            QuoteSyncHandler.sync(new set<id>{oppList2[0].id});
        }
        DataBase.executeBatch(new SychQuoteOppBatchClass(OpportunityIdVsQuoteId));
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
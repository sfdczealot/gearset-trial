@isTest
public class QuoteSyncHandler_Test_v2 {
    
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
    
    static testMethod void mainTest(){
                PGTestDataFactory_v2.CreateTriggerExecuteCS('Trigger_OpportunitySplit',true);

        Opportunity opp = null;
        Account acc_b2c  = null;
		// Avoid mixed DML
		User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
		System.runAs (thisUser) {
			// Call method to insert test records
			PGTestDataFactory_v2.initSetupData();
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            acc_b2c = PGTestDataFactory_v2.createB2CAccount('test@test.com','1232134', thisUser, sb);
            
            //standard PB
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            //Subscription Class
            Product_Class__c productClass = PGTestDataFactory_v2.createProductClass('Subscription',sb);
            
            //item
            list<Product2> listProd = new list<Product2>();
            Product2 prod = PGTestDataFactory_v2.CreateProduct('Test Prod', 'B2C Only', 'Subscription', 'abc', productClass, taxcode);
            listProd.add(prod);
            Product2 prod2 = PGTestDataFactory_v2.CreateProduct('Test Prod2', 'B2C Only', 'Subscription', 'abc', productClass, taxcode);
            listProd.add(prod2);
            insert listProd;
            
            //sg pbe
            Id StdpricebookId = Test.getStandardPricebookId();
            list<PricebookEntry> listPBE = new list<PricebookEntry>();
            PricebookEntry pbe = PGTestDataFactory_v2.CreatePBE(StdpricebookId, prod, 100.0, sb,false);
            PricebookEntry pbe2 = PGTestDataFactory_v2.CreatePBE(standardPB.Id, prod, 100.0, sb,true);

            opp = PGTestDataFactory_v2.createB2CSubscriptionOpty(acc_b2c,thisUser,sb,standardPB, 'B2C - Standard');
			OpportunityLineItem oppLine = PGTestDataFactory_v2.CreateOppLineItem(opp,pbe2,prod);
            
            opp.stinger__c = true;
            opp.OMC_Approved_Date__c = system.today();
            opp.StageName = 'Closed Won';
            opp.Approval_Status__c = 'OMC Approval Approved';
            opp.Count_of_subscription_item_new__c = 1;
            update opp;
            
		}

        Test.setMock(HttpCalloutMock.class, new Mock());
		Test.startTest();
        list<Opportunity> oppList = [select id,Name,stinger__c from opportunity where Name = 'Test Opp'];
        system.debug('oppList QuoteSyncHandler:' + oppList);
        List<OpportunityLineItem> oliList = [select Id,opportunity.Name,OpportunityId from OpportunityLineItem where opportunity.Name='Test Opp'];
        system.debug('oliList QuoteSyncHandler:' + oliList);
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
            for(OpportunityLineItem oppLineItem :[select id from opportunitylineitem where opportunity.id = :oppList2[0].id]){
            	QuoteSyncHandler.sync(new set<id>{oppLineItem.id});
            }
            
            QuoteSyncHandler.syncQuoteToOpp(new list<id>{oppList2[0].id});
        }
        
		Test.stopTest();
        //assert
        
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
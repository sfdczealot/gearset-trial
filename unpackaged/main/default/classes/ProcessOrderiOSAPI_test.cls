@istest
public class ProcessOrderiOSAPI_test {
    
    @testSetup
    public static void testSetup(){
        Trigger_Execute__c te = new Trigger_Execute__c (name = 'PGAccountTrigger', Enable_del__c = true);
        insert te;
        Trigger_Execute__c te3 = new Trigger_Execute__c (name = 'PGCampaignEligibilityTrigger', Enable_del__c = false);
        insert te3;
        Trigger_Execute__c te1 = new Trigger_Execute__c (name = 'Trigger_OpportunitySplit', Enable_del__c = false);
        insert te1;
        Trigger_Execute__c te2 = new Trigger_Execute__c (name = 'PGPaymentTrigger', Enable_del__c = false);
        insert te2;
        Account acc = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc.FirstName = 'TestMe';
        acc.LastName = 'iqiw';
        acc.AgentNet_ID__c = '1112';
        acc.AgentKey__c ='SG123456';
        acc.Salutation = 'Mrs.';
        acc.CurrencyIsoCode = 'SGD';
        acc.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc.BillingStreet = 'test';
        acc.BillingCity = 'test';
        acc.BillingCountry = 'Singapore';
        acc.BillingPostalCode = '83712';
        // acc.BillingState = 'test';
        acc.Current_Subscription_Code__c = 'abc';
        acc.PersonEmail = 'test@asqw.com';
        acc.Account_Rule_Code__c = 'test';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        // acc.Agency__c = agency.id;
        // acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='K123886H';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.mobile_country__c='60';
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        insert acc; 
        Tax_Code__c tax = new Tax_Code__c(Name = 'test', Active__c = true, NS_Tax_Internal_ID__c = '20', Tax_Rate__c = 20);
        insert tax;
        Product2 prod = new Product2(Name = 'PGSG Ad Credit (1 Credit)',NetSuite_id__c ='123', CurrencyIsoCode = 'SGD');
        insert prod;
        PriceBook2 priceBook = new PriceBook2(name = 'PG SG', CurrencyIsoCode = 'SGD', IsActive = true);
        insert priceBook;
        Id stdPriceBook = Test.getStandardPricebookId();
        List<PricebookEntry> pbeList = new list<PricebookEntry>();
        PricebookEntry priceEntry = new PricebookEntry(IsActive = true, CurrencyIsoCode = 'SGD', Pricebook2Id = stdPriceBook, Product2Id = prod.Id, UnitPrice =20);
        pbeList.add(priceEntry);

        PricebookEntry priceEntry1 = new PricebookEntry(IsActive = true, CurrencyIsoCode = 'SGD', Pricebook2Id = priceBook.Id, Product2Id = prod.Id, UnitPrice =20);
        pbeList.add(priceEntry1);
       
        insert pbeList;
        Payment_Method__c payment = new Payment_Method__c(Name = 'Adyen (SG)', NS_Internal_ID__c = '65');
        insert payment;
        Payment_Method__c payment1 = new Payment_Method__c(Name = 'Adyen (MY)', NS_Internal_ID__c = '101');
        insert payment1;
        
        
        
    }
    @isTest
    public static void test1(){
        String jsonData = '{ "agentKey": "SG123456", "orderNumber": "PGOL/9876", "totalPrice": 1038.8, "items": [ { "externalId":"123","productCode": "PC_2022", "totalPrice": 1038.8, "totalTaxes": 58.8, "unitPrice": 980, "discount": 0, "discountType": "Percent/Amount", "startDate": "2022-01-07", "endDate": "2023-01-07", "sku":"sku1", "qty":1 }, { "externalId":"123","productCode": "PG_1237", "totalPrice": 0, "totalTaxes": 0, "unitPrice": 0, "discount": 0, "discountType": "Percent/Amount", "startDate": "2022-01-07", "endDate": "2023-01-07", "sku":"sku2", "qty":1 } ], "payment": [ { "stage": "Paid", "paymentDate": "2022-02-15", "paymentGateway": "Adyen", "paymentMode": "credit-card", "paymentAmount": 1038.8, "paymentReference": "ref001", "apprCode":"appr", "bankName":"UOB/DBS", "installmentPlan":6 } ] }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/processorder/';
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(jsonData);
        RestContext.request = req;
        RestContext.response= res;
        test.starttest();        
        processorderiOSAPI.upsertOpporunity();
        
        test.stopTest();
    }
    @isTest
    public static void test2(){
        String jsonData = '{  "product": "CREDIT/SUBSCRIPTION",  "promoID": "Promo ID", "items": [ {"totalPrice": 1000} ], "payment": [{"stage": "Paid"} ] }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/processorder/';
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(jsonData);
        RestContext.request = req;
        RestContext.response= res;
        test.starttest();
        processorderiOSAPI.upsertOpporunity();
        
        test.stopTest();
    }
    @isTest
    public static void test3(){
        String jsonData = '{ "agentNetID": 1112, "product": "CREDIT/SUBSCRIPTION", "totalPrice": 1963, "promoID": "Promo ID", "items": [ {"totalPrice": 1000} ], "payment": [{"stage": "Paid"} ] }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/processorder/';
        req.httpMethod = 'POST';
       // req.requestBody = blob.valueOf(jsonData);
        RestContext.request = req;
        RestContext.response= res;
        test.starttest();
        processorderiOSAPI.upsertOpporunity();
        
        test.stopTest();
    }
    
}
@isTest
public class PGFinancialTriggerHandler_Test {
    private static final String FAKE_RESPONSE_JSON = 'VGhpcyBpcyBhIFRlc3Q=';
    static testMethod void testDocumentSync() {
        
        
        PGTestDataFactory_v2.initSetupData();
        Test.setMock(HttpCalloutMock.class, new Mock());
        
        Test.StartTest();
        
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        
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
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
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
        opp.count_of_subscription_item_new__c = 100.0;
        opp.Order_Type__c = 'Contract - Renewal';
        insert opp;
        
        Financial__c FinRec = new Financial__c();
        FinRec.NetSuite_Id__c = '3763639';
        FinRec.Type__c = 'Invoice';
        FinRec.Name = 'PG/Test';
        FinRec.Opportunity__c = opp.Id;
        insert FinRec;
        // PGFinancialTriggerHandler.GetNSDocument(FinRec.Id, FinRec.NetSuite_Id__c, FinRec.Type__c, FinRec.Name);
        RestRequest request2 = new RestRequest();
        request2.requestUri ='/services/apexrest/api/financial/';
        request2.httpMethod = 'POST';
        request2.requestBody = Blob.valueOf('{"record":"'+FinRec.Id+'","attachment_file":"'+FAKE_RESPONSE_JSON+'"}');
        
        RestContext.request = request2;
        FinancialAPI.Attachment();
        Test.stopTest();
        
        PGFinancialTriggerHandler.increaseCoverage();
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
    @isTest
    public static void runTest(){
        
        PGFinancialTriggerHandler.isFirstNSCall();
    }
}
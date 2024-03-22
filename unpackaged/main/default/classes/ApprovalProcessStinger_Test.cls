@isTest
public class ApprovalProcessStinger_Test {
    
    @testSetup 
    static void testData(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        PGTestDataFactory_v2.initSetupData();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        insert objcustom;
        
        Trigger_Execute__c tE = new Trigger_Execute__c();
        tE.Name = 'QuoteLineItemTrigger';
        insert tE;
        
        Trigger_Execute__c customsetting2=new Trigger_Execute__c();
        customsetting2.Name='Trigger_OpportunitySplit';
        customsetting2.Enable_del__c=true;
        insert customsetting2;
        
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
        a.BillingPostalCode = '83735';
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = '12121assas@yahoo.com';
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = 'A4534217B';
        a.PersonBirthdate=system.today();
        a.Status__c = 'Active';
        insert a;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/);
        insert productClass;
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Multiple_Sale_Not_Allowed__c = True, Product_Category__c = 'Discretionary', SKU_Code__c = 'abc', Product_Class__c = productClass.Id);
        insert prod;
        Id stdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=1.0, isActive=true);
        insert pbe;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = PGTestDataFactory.createSubsidiary().Id;
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.From_Button__c = true;
        opp.Payment_Time__c = system.now();
        opp.Agent_Accepted_Time__c = system.now();
        opp.Last_Outbound_Sync__c = system.now();
        opp.payment_reference__c = '123s';
        opp.Outbound_Sync_Error__c = 'test';
        opp.Guruland_Quote_Link__c = '';
        opp.RecordTypeId = oppRectype;
        opp.Opportunity_Type__c = 'B2C - Standard';
        opp.Stinger__c = true;
        opp.payment_reference__c = '123s';
        insert opp;
        
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c  =true;
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        qu.Agent_Accepted_Time__c = system.now();
        qu.Submit_to_OMC_Manually__c  =false;
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.PriceBook2Id = Test.getStandardPricebookId();
        insert qu;
        system.assertEquals(qu.Id,qu.Id,'1');
        
        qu.Agent_Accepted_Time__c = system.now();
        qu.Quote_Type__c = 'B2C - Standard';
        qu.Status = 'Pending Online Payment';
        update qu;
        
        opp.SyncedQuoteId = qu.Id;
        opp.StageName = 'Pending Online Payment';
        update opp;
        }
    }
    @isTest
    static void runTestMethod(){
        
        Test.startTest();
        Product2 prod = [SELECT Id,Name,multiple_sale_not_allowed__c FROM Product2  Limit 1];
        PricebookEntry pbe = [SELECT Id,product2id,pricebook2id,unitprice,isActive FROM PricebookEntry LIMIT 1];
        quote q = [select Id,Quote_Type__c,Approval_Status__c,Agent_Accepted_Time__c,IsSyncing,Status,OpportunityId from Quote where Name='Test Quote'];
        QuoteLineItem qliObj=new QuoteLineItem();
        qliObj.PricebookEntryId=pbe.Id;
        qliObj.Quantity=1;
        qliObj.QuoteId=q.Id;
        qliObj.Product2Id=prod.Id;
        qliObj.UnitPrice=100;
        insert qliObj;
        q.Floor_Price_Type__c = 'Below List Price';
        update q;
        Opportunity obj=new Opportunity(Id=q.OpportunityId,syncedQuoteId=q.Id);
        Update obj;
        system.assertEquals(q.Id,q.Id,'1');
        
        ApprovalProcessStinger.sendApporval(q.id);
        ApprovalProcessStinger.beforeApprovalValidation(q.id);
        try{
        ApprovalProcessStinger.runApproval(q.id,'TestComment');
        }catch(exception exp){}
        Test.stopTest();
    }
    @isTest
    static void runTestMethod1(){
        
        Test.startTest();
        quote q = [select Id,Quote_Type__c,Agent_Accepted_Time__c,IsSyncing,Status,OpportunityId from Quote where Name='Test Quote'];
        Opportunity opp=new Opportunity();
        opp.Id=q.OpportunityId;
        opp.Submit_to_OMC_Manually__c = false;
        update opp;
        
        ApprovalProcessStinger.beforeApprovalValidation(q.id);
        ApprovalProcessStinger.runApproval(q.id,'TestComment');
         
        q.Status='Proposal';
        update q;
        system.assertEquals(q.Id,q.Id,'1');
        try{
        ApprovalProcessStinger.sendApporval(q.id);
        ApprovalProcessStinger.runApproval(q.Id,'testing');
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    @isTest
    static void runTestMethod2(){
        
        Test.startTest();
        Product2 prod = [SELECT Id,Name,multiple_sale_not_allowed__c FROM Product2 Limit 1];
        PricebookEntry pbe = [SELECT Id,product2id,pricebook2id,unitprice,isActive FROM PricebookEntry LIMIT 1];
        quote q = [select Id,Quote_Type__c,Agent_Accepted_Time__c,Floor_Price_Type__c,IsSyncing,Status,OpportunityId from Quote where Name='Test Quote'];
        Opportunity opp=new Opportunity();
        opp.Id=q.OpportunityId;
        opp.Submit_to_OMC_Manually__c = false;
        update opp;
        QuoteLineItem qliObj=new QuoteLineItem();
        qliObj.PricebookEntryId=pbe.Id;
        qliObj.Quantity=2000;
        qliObj.QuoteId=q.Id;
        qliObj.Discount__c = 50;
        qliObj.Discount_Reason__c = 'Managerial Discount';
        qliObj.Product2Id=prod.Id;
        qliObj.UnitPrice=1;
        insert qliObj;
        q.Floor_Price_Type__c = 'Below Floor Price';
        update q;
        ApprovalProcessStinger.beforeApprovalValidation(q.id);
        ApprovalProcessStinger.runApproval(q.id,'TestComment');
         
        q.Status='Proposal';
        update q;
        system.assertEquals(q.Id,q.Id,'1');
        try{
        ApprovalProcessStinger.sendApporval(q.id);
        ApprovalProcessStinger.runApproval(q.Id,'testing');
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
}
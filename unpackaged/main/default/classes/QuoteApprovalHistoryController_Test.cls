@isTest
public class QuoteApprovalHistoryController_Test {
    @isTest
    static void runTesMethod(){
        
        Subsidiary__c sb = new Subsidiary__c(); 
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User umgr = new User(Alias = 'mstandt', Email='pgpg@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
                             LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,Subsidiary__c = 'PropertyGuru Pte Ltd',
                             TimeZoneSidKey='America/Los_Angeles', UserName='pgpg@testorg.com');
        insert umgr ;
        
        User u = new User(Alias = 'standt', Email='standarduserpgpg@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, Sales_Head__c =umgr.id , Subsidiary__c = 'PropertyGuru Pte Ltd',
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserpgpg@testorg.com', managerid=umgr.id );
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        PGTestDataFactory_v2.initSetupData();
        
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        Trigger_Execute__c objcustom1 =new Trigger_Execute__c();
        objcustom1.Name='QuoteLineItemTrigger';
        objcustom1.Enable_del__c=true;
        insert objcustom1;
        
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        insert objcustom;
        
        Trigger_Execute__c oppCS=new Trigger_Execute__c();
        oppCS.Name='PGOpportunityTrigger';
        oppCS.Enable_del__c=true;
        insert oppCS;
        
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/);
        insert productClass;
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Discretionary', SKU_Code__c = 'abc', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        insert prod;
        Id stdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, CurrencyIsoCode = 'SGD');
        insert pbe;  
        
     /*    Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
        insert prod;
        
        
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;*/
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        //a.Customer_Type__c = 'Agency';
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
        a.CEA_Salesperson_Number__c = 'H545123K';
        a.PersonBirthdate = system.today();
        insert a;
        system.runAs(u) {
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Proposal';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(30);
            opp.Subsidiary__c = sb.id;
            opp.Total_Spending__c = 100;
            opp.RecordTypeId = oppRectype;
            opp.PG_Tenure__c = 1;
            opp.Stinger__c = true;
            opp.Opportunity_Type__c = 'B2C - Standard';
            opp.Order_Type_Clone__c = 'Contract - Renewal';
            opp.Agent_Accepted_Time__c = system.now();
            opp.OwnerId = u.Id;
            insert opp;
            
            opportunityLineItem oliObj=new opportunityLineItem();
            oliObj.PricebookEntryId=pbe.Id;
            oliObj.Quantity=1;
            oliObj.OpportunityId=opp.Id;
            oliObj.Product2Id=prod.Id;
            insert oliObj;
            
            Quote objQuote=new Quote();
            objQuote.OpportunityId=opp.Id;
            objQuote.CreatedDate__c=system.today();
            objQuote.name='test';
            objQuote.Status='Proposal';
            objQuote.Quote_Type__c = 'B2C - Standard';
            objQuote.Agent_Accepted_Time__c = system.now();
            objQuote.User_Sales_Head__c = u.Id;
            insert objQuote;
            system.assertEquals(objquote.Id,objquote.Id,'1');
            
            QuoteLineItem qliObj=new QuoteLineItem();
            qliObj.PricebookEntryId=pbe.Id;
            qliObj.UnitPrice=100;
            qliObj.Quantity=1;
            qliObj.QuoteId=objQuote.Id;
            qliObj.Product2Id=prod.Id;
            qliObj.Discount_Reason__c='Managerial Discount';
            qliObj.Discount__c = 40;
            //qliObj.dis
            insert qliObj;
            //system.debug(''+);
            objQuote.Total_Mgr_Disc_of_Discretionary_Percen__c=40;
            update objQuote;
            
         
            
          //  ProcessInstance pI = new ProcessInstance();
          //  pI.CreatedDate = system.today();
          //  StepsAndWorkitems sAndw = new StepsAndWorkitems();
           
            list<Approval.ProcessWorkitemRequest> listOfprocessReq = new list<Approval.ProcessWorkitemRequest>();
            Approval.ProcessWorkitemRequest processReq = new Approval.ProcessWorkitemRequest();
            processReq.setAction('Removed');
            processReq.setComments('Submitting request for approval automatically using Trigger');
            processReq.setWorkitemId(objQuote.id);
            listOfprocessReq.add(processReq);
           
            Test.startTest();
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval automatically using Trigger');
            req1.setObjectId(objQuote.id);
            //req1.setSubmitterId(newOpp.OwnerId);
            
            Approval.ProcessResult result = Approval.process(req1);
            
            
            QuoteApprovalHistoryController.getApprovalHistory(objQuote.Id);
            QuoteApprovalHistoryController.recallApprovalProcess(objQuote.Id, 'rejectComment');
           Test.stopTest();
        }
        
    }
    @isTest
    static void runTesMethod1(){
        
        Subsidiary__c sb = new Subsidiary__c(); 
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User umgr = new User(Alias = 'mstandt', Email='pgpg@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
                             LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,Subsidiary__c = 'PropertyGuru Pte Ltd',
                             TimeZoneSidKey='America/Los_Angeles', UserName='pgpg@testorg.com');
        insert umgr ;
        
        User u = new User(Alias = 'standt', Email='standarduserpgpg@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, Sales_Head__c =umgr.id , Subsidiary__c = 'PropertyGuru Pte Ltd', 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserpgpg@testorg.com', managerid=umgr.id);
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        Trigger_Execute__c objcustom1 =new Trigger_Execute__c();
        objcustom1.Name='QuoteLineItemTrigger';
        objcustom1.Enable_del__c=true;
        insert objcustom1;
        
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        insert objcustom;
        
        Trigger_Execute__c oppCS=new Trigger_Execute__c();
        oppCS.Name='PGOpportunityTrigger';
        oppCS.Enable_del__c=true;
        insert oppCS;
        
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/); 
        insert productClass;
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Discretionary', SKU_Code__c = 'abc', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        insert prod;
        Id stdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, CurrencyIsoCode = 'SGD');
        insert pbe;
        system.runAs(u) {
            PGTestDataFactory_v2.initSetupData();
            Account a = new Account();
            a.RecordTypeId = accRectype;
            a.FirstName = 'IsYuni';
            a.LastName = 'TestYuni';
            a.AgentNet_ID__c = 'AgentNet_ID__c test';
            a.Salutation = 'Mrs.';
            //a.Customer_Type__c = 'Agency';
            a.CurrencyIsoCode = 'SGD';
            a.Subscription_Start_Date__c = system.today().addMonths(-10);
            a.BillingStreet = 'test';
            a.BillingCity = 'test';
            a.BillingCountry = 'Singapore';
            a.BillingPostalCode = '8373';
            // a.BillingState = 'test';
            a.Current_Subscription_Code__c = 'abc';
            a.PersonEmail = 'test@yuni.com';
            a.Account_Rule_Code__c = 'test';
            a.Previous_Account_Rule__c = 'test';
            a.Status__c = 'Active';
            a.Country__c = 'Singapore';
            a.Subscription_End_Date__c = system.today().addMonths(-9);
            a.Loyalty_Start_Date__c = system.today().addMonths(-1);
            a.Is_Qualify_Agent_Referral_Program__c = true;
            a.CEA_Salesperson_Number__c = 'A475892L';
            a.PersonBirthdate =system.today();
            a.Expiry_Date_Time__c = system.today().AddDays(-1);
            insert a;
            
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Proposal';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(30);
            opp.Subsidiary__c = sb.id;
            opp.Total_Spending__c = 100;
            opp.RecordTypeId = oppRectype;
            opp.PG_Tenure__c = 1;
            opp.Stinger__c = true;
            opp.Opportunity_Type__c = 'B2C - Standard';
            opp.Order_Type_Clone__c = 'Contract - Renewal';
            opp.Agent_Accepted_Time__c = system.now();
            opp.OwnerId = u.Id;
           // opp.Pricebook2Id = pbe.id;
            insert opp;
            
            opportunityLineItem oliObj=new opportunityLineItem();
            oliObj.PricebookEntryId=pbe.Id;
            oliObj.Quantity=1;
            oliObj.OpportunityId=opp.Id;
            oliObj.Product2Id=prod.Id;
            
            insert oliObj;
            
            Quote objQuote=new Quote();
            objQuote.OpportunityId=opp.Id;
            objQuote.CreatedDate__c=system.today();
            objQuote.name='test';
            objQuote.Status='Proposal';
            objQuote.Quote_Type__c = 'B2C - Standard';
            objQuote.Agent_Accepted_Time__c = system.now();
            objQuote.User_Sales_Head__c = u.Id;
            insert objQuote;
            system.assertEquals(objquote.Id,objquote.Id,'1');
            
            QuoteLineItem qliObj=new QuoteLineItem();
            qliObj.PricebookEntryId=pbe.Id;
            qliObj.UnitPrice=100;
            qliObj.Quantity=1;
            qliObj.QuoteId=objQuote.Id;
            qliObj.Product2Id=prod.Id;
            qliObj.Discount_Reason__c='Managerial Discount';
            qliObj.Discount__c = 40;
            //qliObj.dis
            insert qliObj;
            //system.debug(''+);
            objQuote.Total_Mgr_Disc_of_Discretionary_Percen__c=40;
            update objQuote;
            Test.startTest();
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval automatically using Trigger');
            req1.setObjectId(objQuote.id);
            //req1.setSubmitterId(newOpp.OwnerId);
            
            Approval.ProcessResult result = Approval.process(req1);
            
            
            QuoteApprovalHistoryController.getApprovalHistory(objQuote.Id);
            QuoteApprovalHistoryController.approveAndRejectApprovalProcess(objQuote.Id,'Reject','rejectComment');
            QuoteApprovalHistoryController.getUserProfile();
        Test.stopTest();
        }
        
    } 
}
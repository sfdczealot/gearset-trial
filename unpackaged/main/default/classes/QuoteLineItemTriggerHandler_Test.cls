@isTest
public class QuoteLineItemTriggerHandler_Test {
      
    public static testmethod void unitTest(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='QuoteLineItemTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c PGTrigger =new Trigger_Execute__c();
        PGTrigger.Name='PGOpportunityTrigger';
        PGTrigger.Enable_del__c=true;
        insert PGTrigger;
        
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
        
        Trigger_Execute__c QuoteTrigger =new Trigger_Execute__c();
        QuoteTrigger.Name='Trigger_Quote';
        QuoteTrigger.Enable_del__c=true;
        insert QuoteTrigger;
        
        /*QliToOliFieldMapping__c objcustomsetting=new QliToOliFieldMapping__c();
        objcustomsetting.Name='Start_Date__c';
        objcustomsetting.OliField__c='Start_Date__c';
        insert objcustomsetting;*/
        
         id subId = PGTestDataFactory.createSubsidiary().Id;
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Singapore';
            agency.Subsidiary__c = subId;
            listAccount1.add(agency);
            
            Media__c newMedia = new Media__c();
            newMedia.Account__c = listAccount1[0].id;
            newMedia.CurrencyIsoCode = 'SGD';
            newMedia.IsActive__c = True;
            insert newMedia;
            
            Blob bodyblob = Blob.valueOf('PG Agency default');
            Contentversion cv = new contentversion(title ='PG Agency default',PathOnClient ='PG Agency default.jpg',versiondata = bodyblob,origin ='H');
            insert cv;
            
            ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conVersion.ContentDocumentId;
            cdl.LinkedEntityId = newMedia.id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers'; 
            insert cdl;
            insert listAccount1;
            
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni';
        
        //a.Customer_Type__c = 'Agency';
        a.CurrencyIsoCode = 'SGD';
        a.AgentNet_ID__c = 'TestPurposeIdXX';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.account_rule_code__c = 'Standard';
        a.personemail = 'asd131sfaa@yaho.com';
        a.salutation = 'Mr.';
        a.Agency__c = agency.Id;
        a.firstname = 'aaaa';
        a.Country__c = 'Singapore';
        a.Status__c = 'Active';
        a.CEA_Salesperson_Number__c = 'W567653H';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = subId;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.PG_Tenure__c = 4;
        opp.Opportunity_Type__c='B2C - Standard';
        //opp.Stinger__c=true;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = true;
        opp.CurrencyIsoCode = 'SGD';
            
        Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =opp.RecordTypeId,
                                                                      Destination_Recordtype_Id__c =opp.RecordTypeId,active__c=true);
        insert sd1;
        insert opp;
            
        Id StdpricebookId = Test.getStandardPricebookId();
        
        Tax_Code__c objtax=new Tax_Code__c();
        objtax.Country__c='Singapore';
        objtax.Name='tst tax';
        objtax.Tax_Rate__c=2;
        insert objtax;
        
        Product_Class__c prodClass = New Product_Class__c(Name='Subscription',  CurrencyIsoCode='SGD');
        insert prodClass;

        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test',  Product_Type__c='PG',Description='DummyText'
                                     ,Is_Bundle__c=true,Product_Class__c = prodClass.id);
        insert prod; 
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe;
        
        Floor_Price__c fp = new Floor_Price__c();
        fp.Min_Quantity__c = 0;
        fp.Max_Quantity__c = 20;
        fp.Product__c = prod.Id;
        fp.Price__c = 65;
        fp.List_Price__c = 68;
        insert fp;
        
        Quote objquote=new Quote();
        objquote.Name='test';
        objquote.Pricebook2Id=StdpricebookId;
        objquote.OpportunityId=opp.Id;
        objquote.CreatedDate__c=system.today();
        objquote.Floor_Price_Type__c = 'Below List Price with Discount';
        insert objquote;
        
        opp.SyncedQuoteId=objquote.Id;
        update opp;
        OpportunityLineItem oli=new OpportunityLineItem();
        oli.OpportunityId=opp.Id;
        oli.PricebookEntryId=pbe.Id;
        //insert oli;
      //  set<Id> setOfQliId = new set<Id>();
        QuoteLineItem Qli=new QuoteLineItem();
        Qli.Product2Id=prod.id;
        Qli.QuoteId=objquote.id;
        Qli.PriceBookEntryID=pbe.id;
        Qli.Quantity=4; 
        Qli.UnitPrice =100;
        Qli.Discount__c=10;
        Qli.Product_Category__c = 'Subscription';
        Qli.Discount_Amount__c = 10;
        Qli.Discount_Reason__c = 'Managerial Discount';
   
        test.startTest();
        insert Qli;
            system.debug('Qli.product category'+Qli.Product_Category__c);
        QuoteLineItem Qli1=[select id,Discount__c,opportunityLineItemId,Quote.IsSyncing from QuoteLineItem where Id=:Qli.ID];
        system.debug('==Qli1=='+Qli1);
        Qli.Discount_Amount__c = 0;
        Qli1.Discount__c=15;
        update Qli1;
        delete Qli;
            
       // QuoteLineItemTriggerHelper.QliToOliSyncOnInsert(setOfQliId);
        test.stopTest();
        }
    }
    public static testmethod void unitTest1(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='QuoteLineItemTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c PGTrigger =new Trigger_Execute__c();
        PGTrigger.Name='PGOpportunityTrigger';
        PGTrigger.Enable_del__c=true;
        insert PGTrigger;
        
        Trigger_Execute__c QuoteTrigger =new Trigger_Execute__c();
        QuoteTrigger.Name='Trigger_Quote';
        QuoteTrigger.Enable_del__c=true;
        insert QuoteTrigger;
        
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
        
        /*QliToOliFieldMapping__c objcustomsetting=new QliToOliFieldMapping__c();
        objcustomsetting.Name='Start_Date__c';
        objcustomsetting.OliField__c='Start_Date__c';
        insert objcustomsetting;*/
        
         id subId = PGTestDataFactory.createSubsidiary().Id;
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Singapore';
            agency.Subsidiary__c = subId;
            listAccount1.add(agency);
            
            Media__c newMedia = new Media__c();
            newMedia.Account__c = listAccount1[0].id;
            newMedia.CurrencyIsoCode = 'SGD';
            newMedia.IsActive__c = True;
            insert newMedia;
            
            Blob bodyblob = Blob.valueOf('PG Agency default');
            Contentversion cv = new contentversion(title ='PG Agency default',PathOnClient ='PG Agency default.jpg',versiondata = bodyblob,origin ='H');
            insert cv;
            
            ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conVersion.ContentDocumentId;
            cdl.LinkedEntityId = newMedia.id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers'; 
            insert cdl;
            insert listAccount1;
            
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni';
        a.Agency__c = agency.Id;
        //a.Customer_Type__c = 'Agency';
        a.CurrencyIsoCode = 'SGD';
        a.AgentNet_ID__c = 'TestPurposeIdXX';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.account_rule_code__c = 'Standard';
        a.personemail = 'asd131sfaa@yaho.com';
        a.salutation = 'Mr.';
        a.firstname = 'aaaa';
        a.Country__c = 'Singapore';
        a.Status__c = 'Active';
        a.CEA_Salesperson_Number__c = 'W567653H';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = subId;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.PG_Tenure__c = 4;
        opp.Opportunity_Type__c='B2C - Standard';
        //opp.Stinger__c=true;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = true;
        opp.CurrencyIsoCode = 'SGD';
            
        Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =opp.RecordTypeId,
                                                                      Destination_Recordtype_Id__c =opp.RecordTypeId,active__c=true);
        insert sd1;
        insert opp;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        Tax_Code__c objtax=new Tax_Code__c();
        objtax.Country__c='Singapore';
        objtax.Name='tst tax';
        objtax.Tax_Rate__c=2;
        insert objtax;
        
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only',Multiple_Sale_Not_Allowed__c = true, Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Is_Bundle__c= true, CurrencyIsoCode = 'SGD',Tax_code__c=objtax.Id);
        insert prod; 
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe;
        
        Floor_Price__c fp = new Floor_Price__c();
        fp.Min_Quantity__c = 0;
        fp.Max_Quantity__c = 20;
        fp.Product__c = prod.Id;
        fp.Price__c = 35;
        fp.List_Price__c = 68;
        insert fp;
        
        Quote objquote=new Quote();
        objquote.Name='test';
        objquote.Pricebook2Id=StdpricebookId;
        objquote.OpportunityId=opp.Id;
        objquote.CreatedDate__c=system.today();
        insert objquote;
        
        opp.SyncedQuoteId=objquote.Id;
        update opp;
        OpportunityLineItem oli=new OpportunityLineItem();
        oli.OpportunityId=opp.Id;
        oli.PricebookEntryId=pbe.Id;
        //insert oli;
        
        QuoteLineItem Qli=new QuoteLineItem();
        Qli.Product2Id=prod.id;
        Qli.QuoteId=objquote.id;
        Qli.PriceBookEntryID=pbe.id;
        Qli.Quantity=4; 
        Qli.UnitPrice =50;
        Qli.Discount__c=10;
        Qli.Product_Category__c = 'Subscription';
        Qli.Discount_Amount__c = 20;
        test.startTest();
        insert Qli;
        QuoteLineItem Qli1=[select id,Discount__c,opportunityLineItemId,Quote.IsSyncing from QuoteLineItem where Id=:Qli.ID];
       // PGQuoteOpportunityHelper.increaseCoverage();
        Qli.Discount_Amount__c = 0;
        test.stopTest();
        }
    }
    public static testmethod void unitTest2(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='QuoteLineItemTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c PGTrigger =new Trigger_Execute__c();
        PGTrigger.Name='PGOpportunityTrigger';
        PGTrigger.Enable_del__c=true;
        insert PGTrigger;
        
        Trigger_Execute__c QuoteTrigger =new Trigger_Execute__c();
        QuoteTrigger.Name='Trigger_Quote';
        QuoteTrigger.Enable_del__c=true;
        insert QuoteTrigger;
        
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
        
        /*QliToOliFieldMapping__c objcustomsetting=new QliToOliFieldMapping__c();
        objcustomsetting.Name='Amount_Despite_VIP__c';
        objcustomsetting.OliField__c='Amount_Despite_VIP__c';
        insert objcustomsetting;*/
        
         id subId = PGTestDataFactory.createSubsidiary().Id;
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Singapore';
            agency.Subsidiary__c = subId;
            listAccount1.add(agency);
            
            Media__c newMedia = new Media__c();
            newMedia.Account__c = listAccount1[0].id;
            newMedia.CurrencyIsoCode = 'SGD';
            newMedia.IsActive__c = True;
            insert newMedia;
            
            Blob bodyblob = Blob.valueOf('PG Agency default');
            Contentversion cv = new contentversion(title ='PG Agency default',PathOnClient ='PG Agency default.jpg',versiondata = bodyblob,origin ='H');
            insert cv;
            
            ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conVersion.ContentDocumentId;
            cdl.LinkedEntityId = newMedia.id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers'; 
            insert cdl;
            insert listAccount1;
            
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni';
        a.Agency__c = agency.Id;
        //a.Customer_Type__c = 'Agency';
        a.CurrencyIsoCode = 'SGD';
        a.AgentNet_ID__c = 'TestPurposeIdXX';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.account_rule_code__c = 'Standard';
        a.personemail = 'asd131sfaa@yaho.com';
        a.salutation = 'Mr.';
        a.firstname = 'aaaa';
        a.Country__c = 'Singapore';
        a.Status__c = 'Active';
        a.CEA_Salesperson_Number__c = 'W567653H';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = subId;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.PG_Tenure__c = 4;
        opp.Opportunity_Type__c='B2C - Standard';
        //opp.Stinger__c=true;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = true;
        opp.CurrencyIsoCode = 'SGD';
            
        Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =opp.RecordTypeId,
                                                                      Destination_Recordtype_Id__c =opp.RecordTypeId,active__c=true);
        insert sd1;
        insert opp;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        Tax_Code__c objtax=new Tax_Code__c();
        objtax.Country__c='Singapore';
        objtax.Name='tst tax';
        objtax.Tax_Rate__c=2;
        insert objtax;
        
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only',Multiple_Sale_Not_Allowed__c = true, Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Is_Bundle__c= true, CurrencyIsoCode = 'SGD',Tax_code__c=objtax.Id);
        insert prod; 
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe;
        
        Floor_Price__c fp = new Floor_Price__c();
        fp.Min_Quantity__c = 0;
        fp.Max_Quantity__c = 20;
        fp.Product__c = prod.Id;
        fp.Price__c = 65;
        fp.Price2__c = 55;
        fp.List_Price__c = 68;
        insert fp;
        
        Quote objquote=new Quote();
        objquote.Name='test';
        objquote.Pricebook2Id=StdpricebookId;
        objquote.OpportunityId=opp.Id;
        objquote.CreatedDate__c=system.today();
        insert objquote;
        
        opp.SyncedQuoteId=objquote.Id;
        update opp;
        OpportunityLineItem oli=new OpportunityLineItem();
        oli.OpportunityId=opp.Id;
        oli.PricebookEntryId=pbe.Id;
        //insert oli;
        
        QuoteLineItem Qli=new QuoteLineItem();
        Qli.Product2Id=prod.id;
        Qli.QuoteId=objquote.id;
        Qli.PriceBookEntryID=pbe.id;
        Qli.Quantity=4; 
        Qli.UnitPrice =50;
        Qli.Discount__c=10;
        Qli.Product_Category__c = 'Subscription';
        Qli.Discount_Amount__c = 20;
        test.startTest();
        insert Qli;
        Qli.Discount__c = 0;
        update Qli;
        QuoteLineItem Qli1=[select id,Discount__c,opportunityLineItemId,Quote.IsSyncing from QuoteLineItem where Id=:Qli.ID];
       // PGQuoteOpportunityHelper.increaseCoverage();
        Qli.Discount_Amount__c = 0;
        test.stopTest();
        }
    }
    public static testmethod void unitTest3(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='QuoteLineItemTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c PGTrigger =new Trigger_Execute__c();
        PGTrigger.Name='PGOpportunityTrigger';
        PGTrigger.Enable_del__c=true;
        insert PGTrigger;
        
        Trigger_Execute__c QuoteTrigger =new Trigger_Execute__c();
        QuoteTrigger.Name='Trigger_Quote';
        QuoteTrigger.Enable_del__c=true;
        insert QuoteTrigger;
        
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
        
        /*QliToOliFieldMapping__c objcustomsetting=new QliToOliFieldMapping__c();
        objcustomsetting.Name='Amount_Despite_VIP__c';
        objcustomsetting.OliField__c='Amount_Despite_VIP__c';
        insert objcustomsetting;*/
        
         id subId = PGTestDataFactory.createSubsidiary().Id;
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Singapore';
            agency.Subsidiary__c = subId;
            listAccount1.add(agency);
            
            Media__c newMedia = new Media__c();
            newMedia.Account__c = listAccount1[0].id;
            newMedia.CurrencyIsoCode = 'SGD';
            newMedia.IsActive__c = True;
            insert newMedia;
            
            Blob bodyblob = Blob.valueOf('PG Agency default');
            Contentversion cv = new contentversion(title ='PG Agency default',PathOnClient ='PG Agency default.jpg',versiondata = bodyblob,origin ='H');
            insert cv;
            
            ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conVersion.ContentDocumentId;
            cdl.LinkedEntityId = newMedia.id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers'; 
            insert cdl;
            insert listAccount1;
            
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni';
        a.Agency__c = agency.Id;
        //a.Customer_Type__c = 'Agency';
        a.CurrencyIsoCode = 'SGD';
        a.AgentNet_ID__c = 'TestPurposeIdXX';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.account_rule_code__c = 'Standard';
        a.personemail = 'asd131sfaa@yaho.com';
        a.salutation = 'Mr.';
        a.firstname = 'aaaa';
        a.Country__c = 'Singapore';
        a.Status__c = 'Active';
        a.CEA_Salesperson_Number__c = 'W567653H';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        a.Subsidiary__c = subId;
        insert a;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = subId;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.PG_Tenure__c = 4;
        opp.Opportunity_Type__c='B2C - Standard';
        //opp.Stinger__c=true;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = true;
        opp.CurrencyIsoCode = 'SGD';
        
        Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =opp.RecordTypeId,
                                                                      Destination_Recordtype_Id__c =opp.RecordTypeId,active__c=true);
        insert sd1;
        insert opp;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        Tax_Code__c objtax=new Tax_Code__c();
        objtax.Country__c='Singapore';
        objtax.Name='tst tax';
        objtax.Tax_Rate__c=2;
        insert objtax;
        
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only',Multiple_Sale_Not_Allowed__c = true, Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Is_Bundle__c= true, CurrencyIsoCode = 'SGD',Tax_code__c=objtax.Id);
        insert prod; 
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe;
        
        Floor_Price__c fp = new Floor_Price__c();
        fp.Min_Quantity__c = 0;
        fp.Max_Quantity__c = 20;
        fp.Product__c = prod.Id;
        fp.Price__c = 65;
        fp.Price2__c = 35;
        fp.List_Price__c = 68;
        insert fp;
        
        Quote objquote=new Quote();
        objquote.Name='test';
        objquote.Pricebook2Id=StdpricebookId;
        objquote.OpportunityId=opp.Id;
        objquote.CreatedDate__c=system.today();
        insert objquote;
        
        opp.SyncedQuoteId=objquote.Id;
        update opp;
        OpportunityLineItem oli=new OpportunityLineItem();
        oli.OpportunityId=opp.Id;
        oli.PricebookEntryId=pbe.Id;
        //insert oli;
        
        QuoteLineItem Qli=new QuoteLineItem();
        Qli.Product2Id=prod.id;
        Qli.QuoteId=objquote.id;
        Qli.PriceBookEntryID=pbe.id;
        Qli.Quantity=4; 
        Qli.UnitPrice =50;
        Qli.Discount__c=10;
        Qli.Product_Category__c = 'Subscription';
        Qli.Discount_Amount__c = 20;
        test.startTest();
        insert Qli;
        Qli.Discount__c = 0;
        update Qli;
        QuoteLineItem Qli1=[select id,Discount__c,opportunityLineItemId,Quote.IsSyncing from QuoteLineItem where Id=:Qli.ID];
       // PGQuoteOpportunityHelper.increaseCoverage();
        Qli.Discount_Amount__c = 0;
        test.stopTest();
        }
    }
}
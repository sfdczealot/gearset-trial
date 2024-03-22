@isTest
private class TestOppLineItemTrigger{

    static testMethod void triggerMethods() {

        Subsidiary__c sub = new Subsidiary__c();
        sub.Name = 'PropertyGuru Pte Ltd';
        sub.NS_Subsidiary_Internal_ID__c = 'NSID123';
        sub.Tax_Label__c = 'SGD';
        sub.Logo_url__c = 'www.google.com';
        insert sub;

        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User admUser = new User();
        admUser.LastName = 'Test User';
        admUser.Email = 'TestAdmUser@test.com';
        admUser.Username = 'TestAdmUser@test.com.testclass';
        admUser.ProfileId = prof.Id;
        admUser.Alias = 'TestU';
        admUser.LocaleSidKey='en_US';
        admUser.TimeZoneSidKey='America/Los_Angeles';
        admUser.LanguageLocaleKey='en_US';
        admUser.emailencodingkey='UTF-8';
        admUser.Subsidiary__c = sub.Name;
        insert admUser;

        System.runAs(admUser){
            PGTestDataFactory_v2.initSetupData();
            Account Acc = new Account();
            Acc.Name = 'New Test Account';
            insert Acc;

            Contact cont = new Contact();
            Cont.LastName = 'Test Contact';
            Cont.AccountId = acc.Id;
            Cont.Email = 'TestContact54553@test.com';
            insert cont;

            //product1
            Product2 p = new Product2();
            p.Name = 'Test Product';
            p.Description = 'Test desc';
            p.Product_Type__c = 'PG';
            p.subsidiary__c = sub.Id;
            p.IsActive = true;
            p.Is_Bundle__c = true;
            insert p;

            //standard price book entry for p1
            PricebookEntry pbe1 = new PricebookEntry();
            pbe1.Pricebook2Id = Test.getStandardPricebookId();
            pbe1.IsActive = true;
            pbe1.Product2Id = p.Id;
            pbe1.UseStandardPrice = false;
            pbe1.CurrencyISOCode = 'SGD';
            pbe1.UnitPrice = 100;
            insert pbe1;

            //product2
            Product2 p2 = new Product2();
            p2.Name = 'Test Product';
            p2.Description = 'Test desc';
            p2.Product_Type__c = 'PG';
            p2.subsidiary__c = sub.Id;
            p2.IsActive = true;
            insert p2;

            //standard pricebook entry for p2
            PricebookEntry pbe12 = new PricebookEntry();
            pbe12.Pricebook2Id = Test.getStandardPricebookId();
            pbe12.IsActive = true;
            pbe12.Product2Id = p2.Id;
            pbe12.UseStandardPrice = false;
            pbe12.CurrencyISOCode = 'SGD';
            pbe12.UnitPrice = 100;
            insert pbe12;

            //custom pricebook
            PriceBook2 pb = new PriceBook2();
            pb.Name = 'Custom PB';
            pb.Subsidiary__c = sub.Id;
            pb.IsActive = true;
            insert pb;

            //custom pricebook entry for p1
            PricebookEntry pbe = new PricebookEntry();
            pbe.Pricebook2Id = pb.Id;
            pbe.IsActive = true;
            pbe.Product2Id = p.Id;
            pbe.UseStandardPrice = false;
            pbe.CurrencyISOCode = 'SGD';
            pbe.UnitPrice = 100;
            insert pbe;

            //custom pricebook entry for p2
            PricebookEntry pbe2 = new PricebookEntry();
            pbe2.Pricebook2Id = pb.Id;
            pbe2.IsActive = true;
            pbe2.Product2Id = p2.Id;
            pbe2.UseStandardPrice = false;
            pbe2.CurrencyISOCode = 'SGD';
            pbe2.UnitPrice = 100;
            insert pbe2;

            //Opportunity
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp';
            opp.AccountId = acc.Id;
            opp.StageName = 'Prospecting';
            opp.CloseDate = System.Today()+10;
            opp.OwnerId = admUser.Id;
            opp.subsidiary__c = sub.Id;
            opp.Pricebook2Id = pb.Id;
            insert opp;

            //opp line item with pbe 1
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.opportunityId = opp.Id;
            oli.PriceBookEntryId = pbe.Id;
            //oli.Rev_Terms_in_months__c = 3;
            //oli.Sno__c = 1.00;
            oli.Quantity = 1;
            oli.TotalPrice = 100;
            oli.Start_Date__c = System.today();
            oli.End_Date__c = System.today()+1;
            insert oli;

            update oli;

            //opp line itme with pbe2
            OpportunityLineItem oli2 = new OpportunityLineItem();
            oli2.opportunityId = opp.Id;
            oli2.PriceBookEntryId = pbe2.Id;
            //oli2.Rev_Terms_in_months__c = 3;
            //oli2.Sno__c = 2.00;
            oli2.Quantity = 1;
            oli2.TotalPrice = 100;
            oli2.Start_Date__c = System.today()+10;
            oli2.End_Date__c = System.today()+11;
            insert oli2;

            Item_Bundle__c IB = new Item_Bundle__c();
            IB.Parent_Product__c = p.Id;
            IB.Child_Product__c = p2.Id;
            IB.Qty__c = 1;
            insert IB;

            delete oli;
        }

    }


    static testMethod void triggerMethodsSelfServe() {

        Subsidiary__c sub = new Subsidiary__c();
        sub.Name = 'PropertyGuru Pte Ltd';
        sub.NS_Subsidiary_Internal_ID__c = 'NSID123';
        sub.Tax_Label__c = 'SGD';
        sub.Logo_url__c = 'www.google.com';
        insert sub;

        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User admUser = new User();
        admUser.LastName = 'Test User';
        admUser.Email = 'TestAdmUser@test.com';
        admUser.Username = 'TestAdmUser@test.com.testclass';
        admUser.ProfileId = prof.Id;
        admUser.Alias = 'TestU';
        admUser.LocaleSidKey='en_US';
        admUser.TimeZoneSidKey='America/Los_Angeles';
        admUser.LanguageLocaleKey='en_US';
        admUser.emailencodingkey='UTF-8';
        admUser.Subsidiary__c = sub.Name;
        insert admUser;

        System.runAs(admUser){
            PGTestDataFactory_v2.initSetupData();
            Account Acc = new Account();
            Acc.Name = 'New Test Account';
            Acc.AgentNet_ID__c = '3992229';
            insert Acc;

            Contact cont = new Contact();
            Cont.LastName = 'Test Contact';
            Cont.AccountId = acc.Id;
            Cont.Email = 'TestContact54553@test.com';
            insert cont;

            //product1
            Product2 p = new Product2();
            p.Name = 'Test Product';
            p.Description = 'Test desc';
            p.Product_Type__c = 'PG';
            p.subsidiary__c = sub.Id;
            p.IsActive = true;
            p.Is_Bundle__c = true;
            insert p;

            //standard price book entry for p1
            PricebookEntry pbe1 = new PricebookEntry();
            pbe1.Pricebook2Id = Test.getStandardPricebookId();
            pbe1.IsActive = true;
            pbe1.Product2Id = p.Id;
            pbe1.UseStandardPrice = false;
            pbe1.CurrencyISOCode = 'SGD';
            pbe1.UnitPrice = 100;
            insert pbe1;

            //product2
            Product2 p2 = new Product2();
            p2.Name = 'Test Product';
            p2.Description = 'Test desc';
            p2.Product_Type__c = 'PG';
            p2.subsidiary__c = sub.Id;
            p2.IsActive = true;
            insert p2;

            //standard pricebook entry for p2
            PricebookEntry pbe12 = new PricebookEntry();
            pbe12.Pricebook2Id = Test.getStandardPricebookId();
            pbe12.IsActive = true;
            pbe12.Product2Id = p2.Id;
            pbe12.UseStandardPrice = false;
            pbe12.CurrencyISOCode = 'SGD';
            pbe12.UnitPrice = 100;
            insert pbe12;

            //custom pricebook
            PriceBook2 pb = new PriceBook2();
            pb.Name = 'Custom PB';
            pb.Subsidiary__c = sub.Id;
            pb.IsActive = true;
            insert pb;

            //custom pricebook entry for p1
            PricebookEntry pbe = new PricebookEntry();
            pbe.Pricebook2Id = pb.Id;
            pbe.IsActive = true;
            pbe.Product2Id = p.Id;
            pbe.UseStandardPrice = false;
            pbe.CurrencyISOCode = 'SGD';
            pbe.UnitPrice = 100;
            insert pbe;

            //custom pricebook entry for p2
            PricebookEntry pbe2 = new PricebookEntry();
            pbe2.Pricebook2Id = pb.Id;
            pbe2.IsActive = true;
            pbe2.Product2Id = p2.Id;
            pbe2.UseStandardPrice = false;
            pbe2.CurrencyISOCode = 'SGD';
            pbe2.UnitPrice = 100;
            insert pbe2;

            //Opportunity
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp';
            opp.AccountId = acc.Id;
            opp.StageName = 'Prospecting';
            opp.CloseDate = System.Today()+10;
            opp.OwnerId = admUser.Id;
            opp.subsidiary__c = sub.Id;
            opp.Pricebook2Id = pb.Id;
            opp.RecordTypeId = RecordTypeSelector.getRecordTypeId('Opportunity', 'B2C Self-Serve');
            opp.BasketId__c = '2299188282';
            insert opp;

            //opp line item with pbe 1
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.opportunityId = opp.Id;
            oli.PriceBookEntryId = pbe.Id;
            //oli.Rev_Terms_in_months__c = 3;
            //oli.Sno__c = 1.00;
            oli.Quantity = 1;
            oli.TotalPrice = 100;
            oli.Start_Date__c = System.today();
            oli.End_Date__c = System.today()+1;
            oli.Record_Type__c = 'B2C Self Serve';
            insert oli;

            update oli;

            //opp line itme with pbe2
            OpportunityLineItem oli2 = new OpportunityLineItem();
            oli2.opportunityId = opp.Id;
            oli2.PriceBookEntryId = pbe2.Id;
            //oli2.Rev_Terms_in_months__c = 3;
            //oli2.Sno__c = 2.00;
            oli2.Quantity = 1;
            oli2.TotalPrice = 100;
            oli2.Start_Date__c = System.today()+10;
            oli2.End_Date__c = System.today()+11;
            insert oli2;

            Item_Bundle__c IB = new Item_Bundle__c();
            IB.Parent_Product__c = p.Id;
            IB.Child_Product__c = p2.Id;
            IB.Qty__c = 1;
            insert IB;
        }

    }

    static testMethod void triggerMethodsB2C() {

        Subsidiary__c sub = new Subsidiary__c();
        sub.Name = 'PropertyGuru Pte Ltd';
        sub.NS_Subsidiary_Internal_ID__c = 'NSID123';
        sub.Tax_Label__c = 'SGD';
        sub.Logo_url__c = 'www.google.com';
        insert sub;

        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User admUser = new User();
        admUser.LastName = 'Test User';
        admUser.Email = 'TestAdmUser@test.com';
        admUser.Username = 'TestAdmUser@test.com.testclass';
        admUser.ProfileId = prof.Id;
        admUser.Alias = 'TestU';
        admUser.LocaleSidKey='en_US';
        admUser.TimeZoneSidKey='America/Los_Angeles';
        admUser.LanguageLocaleKey='en_US';
        admUser.emailencodingkey='UTF-8';
        admUser.Subsidiary__c = sub.Name;
        insert admUser;

        System.runAs(admUser){
            PGTestDataFactory_v2.initSetupData();
            Account Acc = new Account();
            Acc.Name = 'New Test Account';
            Acc.AgentNet_ID__c = '3992229';
            Acc.Status__c = 'Active';
            insert Acc;

            Contact cont = new Contact();
            Cont.LastName = 'Test Contact';
            Cont.AccountId = acc.Id;
            Cont.Email = 'TestContact54553@test.com';
            insert cont;

            //product1
            Product2 p = new Product2();
            p.Name = 'Test Product';
            p.Description = 'Test desc';
            p.Product_Type__c = 'PG';
            p.subsidiary__c = sub.Id;
            p.IsActive = true;
            p.Is_Bundle__c = true;
            insert p;

            //standard price book entry for p1
            PricebookEntry pbe1 = new PricebookEntry();
            pbe1.Pricebook2Id = Test.getStandardPricebookId();
            pbe1.IsActive = true;
            pbe1.Product2Id = p.Id;
            pbe1.UseStandardPrice = false;
            pbe1.CurrencyISOCode = 'SGD';
            pbe1.UnitPrice = 100;
            insert pbe1;

            //product2
            Product2 p2 = new Product2();
            p2.Name = 'Test Product';
            p2.Description = 'Test desc';
            p2.Product_Type__c = 'PG';
            p2.subsidiary__c = sub.Id;
            p2.IsActive = true;
            p2.Product_Category__c = 'Subscription';
            insert p2;

            //standard pricebook entry for p2
            PricebookEntry pbe12 = new PricebookEntry();
            pbe12.Pricebook2Id = Test.getStandardPricebookId();
            pbe12.IsActive = true;
            pbe12.Product2Id = p2.Id;
            pbe12.UseStandardPrice = false;
            pbe12.CurrencyISOCode = 'SGD';
            pbe12.UnitPrice = 100;
            insert pbe12;

            //custom pricebook
            PriceBook2 pb = new PriceBook2();
            pb.Name = 'Custom PB';
            pb.Subsidiary__c = sub.Id;
            pb.IsActive = true;
            insert pb;

            //custom pricebook entry for p1
            PricebookEntry pbe = new PricebookEntry();
            pbe.Pricebook2Id = pb.Id;
            pbe.IsActive = true;
            pbe.Product2Id = p.Id;
            pbe.UseStandardPrice = false;
            pbe.CurrencyISOCode = 'SGD';
            pbe.UnitPrice = 100;
            insert pbe;

            //custom pricebook entry for p2
            PricebookEntry pbe2 = new PricebookEntry();
            pbe2.Pricebook2Id = pb.Id;
            pbe2.IsActive = true;
            pbe2.Product2Id = p2.Id;
            pbe2.UseStandardPrice = false;
            pbe2.CurrencyISOCode = 'SGD';
            pbe2.UnitPrice = 100;
            insert pbe2;

            //Opportunity
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp';
            opp.AccountId = acc.Id;
            opp.StageName = 'Prospecting';
            opp.CloseDate = System.Today()+10;
            opp.OwnerId = admUser.Id;
            opp.subsidiary__c = sub.Id;
            opp.Pricebook2Id = pb.Id;
            opp.RecordTypeId = RecordTypeSelector.getRecordTypeId('Opportunity', 'B2C');
            opp.BasketId__c = '2299188282';
            opp.Opportunity_Type__c = 'B2C - Standard';
            insert opp;

            //opp line item with pbe 1
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.opportunityId = opp.Id;
            oli.PriceBookEntryId = pbe.Id;
            //oli.Rev_Terms_in_months__c = 3;
            //oli.Sno__c = 1.00;
            oli.Quantity = 1;
            oli.TotalPrice = 100;
            oli.Start_Date__c = System.today();
            oli.End_Date__c = System.today()+1;
            insert oli;

            update oli;

            //opp line itme with pbe2
            OpportunityLineItem oli2 = new OpportunityLineItem();
            oli2.opportunityId = opp.Id;
            oli2.PriceBookEntryId = pbe2.Id;
            //oli2.Rev_Terms_in_months__c = 3;
            //oli2.Sno__c = 2.00;
            oli2.Quantity = 1;
            oli2.TotalPrice = 100;
            oli2.Start_Date__c = System.today()+10;
            oli2.End_Date__c = System.today()+11;
            insert oli2;

            Item_Bundle__c IB = new Item_Bundle__c();
            IB.Parent_Product__c = p.Id;
            IB.Child_Product__c = p2.Id;
            IB.Qty__c = 1;
            insert IB;
        }

    }
}
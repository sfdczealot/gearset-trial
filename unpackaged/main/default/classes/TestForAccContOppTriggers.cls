@isTest
private class TestForAccContOppTriggers{

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
               
            Account Acc = new Account();
          PGTestDataFactory_v2.initSetupData();
            Acc.Name = 'New Test Account';
            insert Acc;       
            
            Contact cont = new Contact();
            Cont.LastName = 'Test Contact';
            Cont.AccountId = acc.Id;
            insert cont;    
            
            Product2 p = new Product2();
            p.Name = 'Test Product';
            p.Description = 'Test desc';
            p.Product_Type__c = 'PG';
            p.subsidiary__c = sub.Id;
            p.IsActive = true;
            insert p;                        
            
            PricebookEntry pbe = new PricebookEntry();
            pbe.Pricebook2Id = Test.getStandardPricebookId();
            pbe.IsActive = true;
            pbe.Product2Id = p.Id;
            pbe.UseStandardPrice = false;
            pbe.CurrencyISOCode = 'SGD';
            pbe.UnitPrice = 100;                                                       
            insert pbe;
            
            PriceBook2 pb = new PriceBook2();
            pb.Name = 'Custom PB';
            pb.Subsidiary__c = sub.Id;
            pb.IsActive = true;            
            insert pb;
                       
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp';
            opp.AccountId = acc.Id;
            opp.StageName = 'Prospecting';
            opp.CloseDate = System.Today()+10;
            insert opp;                                                                     
        }
    }
}
@isTest
private class TestPBECreationSchedulable{

    static testMethod void scheduleMethods() {
    
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
            //removing adding of account in this test class
            /*
            Account Acc = new Account();
            Acc.Name = 'New Test Account';
            insert Acc;       
            
            Contact cont = new Contact();
            Cont.LastName = 'Test Contact';
            Cont.AccountId = acc.Id;
            insert cont;  */  
            
            //product1
            Product2 p = new Product2();
            p.Name = 'Test Product';
            p.Description = 'Test desc';
            p.Product_Type__c = 'PG';
            p.subsidiary__c = sub.Id;
            p.IsActive = true;
            p.Is_Bundle__c = true;
            insert p;               
            
            // Instantiate the Pricebook2 record first, setting the Id
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            
            // Run an update DML on the Pricebook2 record
            // This is the weird workaround that enables IsStandard to become true
            // on the PricebookEntry record
            standardPricebook.Subsidiary__c = sub.Id;
            update standardPricebook;    
            
            //custom pricebook
            PriceBook2 pb = new PriceBook2();
            pb.Name = 'Custom PB';
            pb.Subsidiary__c = sub.Id;
            pb.IsActive = true;            
            insert pb;                  
            
            //standard price book entry for p1
            PricebookEntry pbe1 = new PricebookEntry();
            pbe1.Pricebook2Id = standardPricebook.Id;
            pbe1.IsActive = true;
            pbe1.Product2Id = p.Id;
            pbe1.UseStandardPrice = false;
            pbe1.CurrencyISOCode = 'SGD';
            pbe1.UnitPrice = 100;                                                                 
            insert pbe1; 
            
            System.debug('is standard---->'+pbe1.Pricebook2.IsStandard);
            
            List<PricebookEntry> pbeNew = [SELECT Id,Pricebook2Id,Product2Id,IsActive,CurrencyISOCode,Pricebook2.IsStandard,UnitPrice FROM PricebookEntry where Pricebook2.IsStandard = TRUE AND (CreatedDate >:Datetime.now().addMinutes(-15) OR LastModifiedDate >:Datetime.now().addMinutes(-15))];
            System.debug('-----'+pbeNew);
            
            System.debug('standard pbId -----'+Test.getStandardPricebookId());                               
            
            Test.startTest();
            
              // Because this is a test, job executes
              // immediately after Test.stopTest().
              String CRON_EXP = '0 0 0 15 3 ? 2022';
              
              // Schedule the test job
              String jobId = System.schedule('Test my class',
                                CRON_EXP, 
                                new PBECreationSchedulable());
        
              // Get the information from the CronTrigger API object
              CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                 NextFireTime
                 FROM CronTrigger WHERE id = :jobId];
        
              // Verify the expressions are the same
              System.assertEquals(CRON_EXP, 
                 ct.CronExpression);
        
              // Verify the job has not run
              System.assertEquals(0, ct.TimesTriggered);
        
              // Verify the next time the job will run
              System.assertEquals('2022-03-15 00:00:00', 
                 String.valueOf(ct.NextFireTime));
        
              Test.stopTest();                                               
                                            
        }
        
    }
}
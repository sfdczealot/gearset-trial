@isTest
private class TestContractController{

    private static final String FAKE_RESPONSE_JSON = '{' +
        												'status:ok' +
        												'}';
    static testMethod void MethodHideChild() {
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='QuoteLineItemTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
    	PGTestDataFactory_v2.initSetupData();
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
            Acc.Name = 'New Test Account';
            insert Acc;       
            
            Contact cont = new Contact();
            Cont.LastName = 'Test Contact';
            Cont.AccountId = acc.Id;
            Cont.phone = '2342342';
            Cont.Email = 'test@cont.com';
            Cont.Fax = 'fax@test.com';
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
            
            System.debug('standard pbId -----'+Test.getStandardPricebookId());                                                        
             
            //Opportunity                     
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp';
            opp.AccountId = acc.Id;
            opp.StageName = 'Prospecting'; 
            opp.CloseDate = System.Today()+10;
            opp.OwnerId = admUser.Id;
            opp.subsidiary__c = sub.Id;
            opp.Pricebook2Id = pb.Id;
            opp.Re_print_Contract__c = true;
            opp.Billing_Contact__c = cont.Id;
            insert opp;    
            
            System.debug('opp subs Id -----'+opp.Subsidiary__c);
            System.debug('opp owner Id -----'+opp.OwnerId);
            System.debug('opp pbId -----'+opp.Pricebook2Id);
            
            system.debug('opp.pricebook2Id!!!!'+opp.pricebook2Id+'pbEntry.Pricebook2Id !!!'+pbe.Pricebook2Id);
                        
            //opp line item with pbe 1
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.opportunityId = opp.Id;
            oli.PriceBookEntryId = pbe.Id;
            oli.Quantity = 1;
            oli.TotalPrice = 100;
            //oli.Rev_Terms_in_months__c = 3;
            //oli.Sno__c = 1.00;
            oli.Start_Date__c = System.today();
            oli.End_Date__c = System.today()+1;
            insert oli;      
            
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
            
            System.debug('is standard---->'+pbe1.Pricebook2.IsStandard);                                    
            System.debug('standard pbId -----'+Test.getStandardPricebookId());                               
            
            Test.setMock(HttpCalloutMock.class, new Mock());
        	Test.startTest();
            
            ApexPages.CurrentPage().getParameters().put('Id',opp.Id);
            ContractController CC = new ContractController();
            CC.createQuote();
            CC.updateOppRePrintFalse();
        
            Test.stopTest();                                               
                                            
        }
        
    }
    
    static testMethod void MethodDisplayChild() {
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='QuoteLineItemTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
    

        PGTestDataFactory_v2.initSetupData();
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
            Acc.Name = 'New Test Account';
            insert Acc;       
            
            Contact cont = new Contact();
            Cont.LastName = 'Test Contact';
            Cont.AccountId = acc.Id;
            Cont.phone = '2342342';
            Cont.Email = 'test@cont.com';
            Cont.Fax = 'fax@test.com';
            insert cont;    
            
            //product1
            Product2 p = new Product2();
            p.Name = 'Test Product';
            p.Description = 'Test desc';
            p.Product_Type__c = 'PG';
            p.subsidiary__c = sub.Id;
            p.IsActive = true;
            p.Is_Bundle__c = true;
            p.Display_Child_Products_on_Transactions__c = true;
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
             
            //Opportunity                     
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp';
            opp.AccountId = acc.Id;
            opp.StageName = 'Prospecting';
            opp.CloseDate = System.Today()+10;
            opp.OwnerId = admUser.Id;
            opp.subsidiary__c = sub.Id;
            opp.Pricebook2Id = pb.Id;
            opp.Re_print_Contract__c = true;
            opp.Billing_Contact__c = cont.Id;
            insert opp;    
            
            System.debug('opp subs Id -----'+opp.Subsidiary__c);
            System.debug('opp owner Id -----'+opp.OwnerId);
            System.debug('opp pbId -----'+opp.Pricebook2Id);
            
            system.debug('opp.pricebook2Id!!!!'+opp.pricebook2Id+'pbEntry.Pricebook2Id !!!'+pbe.Pricebook2Id);
                        
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
                        
            Test.setMock(HttpCalloutMock.class, new Mock());
        	Test.startTest();
            
            ApexPages.CurrentPage().getParameters().put('Id',opp.Id);
            ContractController CC = new ContractController();
            //CC.createQuote();
            CC.updateOppRePrintFalse();
        
            Test.stopTest();                                               
                                            
        }
        
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
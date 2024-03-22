@isTest
public class PostRulesExecutionObserverTest {
    @isTest
    static void testObserver () {
        User thisUser = [SELECT Id,Subsidiary__c,profile.name FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' and id=: userinfo.getUserId() LIMIT 1];
        System.runAs (thisUser) {
              Trigger_Execute__c te = new Trigger_Execute__c (name = 'PGAccountTrigger', Enable_del__c = true);
            insert te;
            Trigger_Execute__c te3 = new Trigger_Execute__c (name = 'PGCampaignEligibilityTrigger', Enable_del__c = false);
            insert te3;
            Trigger_Execute__c te1 = new Trigger_Execute__c (name = 'Trigger_OpportunitySplit', Enable_del__c = false);
            insert te1;
            Trigger_Execute__c te2 = new Trigger_Execute__c (name = 'PGPaymentTrigger', Enable_del__c = false);
            insert te2;
            

                 Trigger_Execute__c te5 = new Trigger_Execute__c (name = 'PGPromoMechanicTrigger', Enable_del__c = false);
            insert te5;
            Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Self-Serve').getRecordTypeId();
            Campaign cma = new Campaign();
            cma.Name = 'TestNameCampaign';
            cma.Country__c = 'Singapore';
            cma.IsActive = true;
                       cma.CurrencyIsoCode='SGD';
            insert cma;
            system.debug(cma);
            Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(CurrencyIsoCode='SGD',Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
            insert ce1;
            Promo_Mechanic__c prm = new Promo_Mechanic__c();
            prm.Name = 'TestName';
            prm.CurrencyIsoCode='SGD';
            //   prm.Eligible_Product__c = prod.Id;
            // prm.Campaign_Eligibility__c = ce1.Id;
            prm.Usage__c = 1;
            system.debug(prm);
            insert prm;
            
            List<Id> basketIds = new List<Id>();
            Map<String, Object> basketMap = new Map<String, Object>();
          
            Account acc = new Account();
            PGTestDataFactory_v2.initSetupData();
            acc.FirstName = 'TestMe';
            acc.LastName = 'iqiw';
            acc.AgentNet_ID__c = 'AgentNet_ID__c test';
            acc.Salutation = 'Mrs.';
            acc.CurrencyIsoCode = 'MYR';
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
            //Campaign cam =PGTestDataFactory_v2.CreateCampaign(system.today()+1);
            Campaign cam = new Campaign();
            cam.Name = 'Test Campaign';
            cam.IsActive = true;
            cam.Country__c = 'Malaysia';
            cam.CurrencyIsoCode = 'MYR';
            cam.EndDate = system.today()+1;
            insert cam;
            
            list<opportunity> oppList = new List<Opportunity>();
            String b2bRecordType =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Self-Serve').getRecordTypeId();
            Opportunity opp = new Opportunity(AccountId = acc.id, Name = 'Opp test',
                                              CloseDate = System.today() +10, StageName = 'New',CampaignId = cam.id,recordtypeid=devRecordTypeId);
            oppList.add(opp);
            Opportunity opp2 = new Opportunity(AccountId = acc.id, Name = 'Opp test1',
                                               CloseDate = System.today() +10, StageName = 'New',BasketId__c ='1223',recordtypeid=devRecordTypeId);
            
            oppList.add(opp2);
            insert oppList;
            
            
            cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Name = 'test basket', cscfga__Total_Price__c = 100, 
                                                                             Payment_Amount__c = 2, Appr_Code__c = '2', Payment_Date__c = system.today(),
                                                                             Payment_Reference__c = 'PayPal', Payment_Gateway__c = 'Adyen', 
                                                                             Payment_Mode__c = 'PayPal', EcomReference__c  = 'test',
                                                                             Marketing_Automation_Identifier__c = cam.Id,promotion_ids__c=prm.id);
            cscfga__Product_Basket__c basket2 = new cscfga__Product_Basket__c(Name = 'test basket', cscfga__Total_Price__c = 100, 
                                                                              Payment_Amount__c = 2, Appr_Code__c = '2', Payment_Date__c = system.today(),
                                                                              Payment_Reference__c = 'Paypal', Payment_Gateway__c = 'Adyen', 
                                                                              Payment_Mode__c = 'PayPal', EcomReference__c  = 'test',promotion_ids__c=prm.id
                                                                             );
            cscfga__Product_Basket__c basket3 = new cscfga__Product_Basket__c(Name = 'test basket', cscfga__Total_Price__c = 100, 
                                                                              Payment_Amount__c = 2, Appr_Code__c = '2', Payment_Date__c = system.today(),
                                                                              Payment_Reference__c = 'Paypal', Payment_Gateway__c = 'Adyen', 
                                                                              Payment_Mode__c = 'PayPal', EcomReference__c  = 'test'
                                                                             );
            
            insert basket;
            insert basket2;
            // insert basket3;
            
            csb2c__Inbound_Ecommerce_Order_Request__c orderReq = new csb2c__Inbound_Ecommerce_Order_Request__c(Name = 'test', csb2c__Account__c = acc.Id, csb2c__Product_Basket__c = basket.Id, csb2c__API_Basket_ID__c = String.valueOf(basket.Id), csb2c__E_Commerce_Customer_Id__c = '123');
            insert orderReq;
            csb2c__Inbound_Ecommerce_Order_Request__c orderReq2 = new csb2c__Inbound_Ecommerce_Order_Request__c(Name = 'test', csb2c__Account__c = acc.Id, csb2c__Product_Basket__c = basket2.Id, csb2c__API_Basket_ID__c = String.valueOf(basket2.Id), csb2c__E_Commerce_Customer_Id__c = '12223');
            insert orderReq2;
            // csb2c__Inbound_Ecommerce_Order_Request__c orderReq3 = new csb2c__Inbound_Ecommerce_Order_Request__c(Name = 'test', csb2c__Account__c = acc.Id, csb2c__Product_Basket__c = basket3.Id, csb2c__API_Basket_ID__c = '1223' , csb2c__E_Commerce_Customer_Id__c = '12223');
            // insert orderReq3;
            cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(name = 'Ad Credits', cscfga__Quantity__c = 2, Start_Date__c = system.today(), cscfga__Unit_Price__c = 20, End_Date__c = system.today()+3, cscfga__Product_Family__c = 'Ad Credits', cscfga__Product_Basket__c = basket.Id);
            insert pc;
            cscfga__Product_Configuration__c pc2 = new cscfga__Product_Configuration__c(name = 'Ad Credits', cscfga__Quantity__c = 2, Start_Date__c = system.today(), cscfga__Unit_Price__c = 20, End_Date__c = system.today()+3, cscfga__Product_Family__c = 'Ad Credits', cscfga__Product_Basket__c = basket2.Id);
            insert pc2;
            // cscfga__Product_Configuration__c pc3 = new cscfga__Product_Configuration__c(name = 'Ad Credits', cscfga__Quantity__c = 2, Start_Date__c = system.today(), cscfga__Unit_Price__c = 20, End_Date__c = system.today()+3, cscfga__Product_Family__c = 'Ad Credits', cscfga__Product_Basket__c = basket3.Id);
            //insert pc3;
            Tax_Code__c tax = new Tax_Code__c(Name = 'test', Active__c = true, NS_Tax_Internal_ID__c = '20', Tax_Rate__c = 20);
            insert tax;
            
            cspmb__Price_Item__c  priceItem = new cspmb__Price_Item__c (name = 'test', Tax_Code__c = tax.Id,Product_Category__c  = 'Awards',
                                                                        Rev_Rec_Forecast_Rules__c='2',
                                                                        Create_Revenue_based_on__c='-1',
                                                                        Revenue_Recognition_Rules__c='2');
            insert priceItem;
            list<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
            cscfga__Attribute__c attr1 = new cscfga__Attribute__c (name = 'Offering', cscfga__Is_Line_Item__c = true, cscfga__Value__c = string.valueOf(priceItem.Id), cscfga__Price__c = 10, cscfga__List_Price__c = 20, cscfga__Product_Configuration__c = pc.Id);
            
            attList.add(attr1);
            cscfga__Attribute__c attr2 = new cscfga__Attribute__c (name = 'Included Units', cscfga__Value__c = '20', cscfga__Price__c = 5, cscfga__List_Price__c = 10, cscfga__Product_Configuration__c = pc.Id);
            attList.add(attr2);
            cscfga__Attribute__c attr3 = new cscfga__Attribute__c (name = 'Offering', cscfga__Is_Line_Item__c = true, cscfga__Value__c = string.valueOf(priceItem.Id), cscfga__Price__c = 10, cscfga__List_Price__c = 20, cscfga__Product_Configuration__c = pc2.Id);
            attList.add(attr3);
            cscfga__Attribute__c attr4 = new cscfga__Attribute__c (name = 'Included Units', cscfga__Value__c = '20', cscfga__Price__c = 5, cscfga__List_Price__c = 10, cscfga__Product_Configuration__c = pc2.Id);
            attList.add(attr4);
            // cscfga__Attribute__c attr5 = new cscfga__Attribute__c (name = 'Offering', cscfga__Is_Line_Item__c = true, cscfga__Value__c = string.valueOf(priceItem.Id), cscfga__Price__c = 10, cscfga__List_Price__c = 20, cscfga__Product_Configuration__c = pc3.Id);
            //   attList.add(attr5);
            // cscfga__Attribute__c attr6 = new cscfga__Attribute__c (name = 'Included Units', cscfga__Value__c = '20', cscfga__Price__c = 5, cscfga__List_Price__c = 10, cscfga__Product_Configuration__c = pc3.Id);
            //attList.add(attr6);
            insert attList;
            Product2 prod = new Product2(Name = 'PGSG Ad Credit (1 Credit)', CurrencyIsoCode = 'SGD');
            insert prod;
            Product2 pm = new Product2(Name = 'PGSG Prime Credit', CurrencyIsoCode = 'SGD');
            insert pm;
            Product2 prod1 = new Product2(Name = 'Rounding Adjustment', CurrencyIsoCode = 'SGD');
            insert prod1;
            
            PriceBook2 priceBook = new PriceBook2(name = 'PG SG', CurrencyIsoCode = 'SGD', IsActive = true);
            insert priceBook;
            Id stdPriceBook = Test.getStandardPricebookId();
            List<PricebookEntry> pbeList = new list<PricebookEntry>();
            PricebookEntry priceEntry = new PricebookEntry(IsActive = true, CurrencyIsoCode = 'SGD', Pricebook2Id = stdPriceBook, Product2Id = prod.Id, UnitPrice =20);
            pbeList.add(priceEntry);
            PricebookEntry priceEntry4 = new PricebookEntry(IsActive = true, CurrencyIsoCode = 'SGD', Pricebook2Id = stdPriceBook, Product2Id = pm.Id, UnitPrice =20);
            pbeList.add(priceEntry4);
            PricebookEntry priceEntry3 = new PricebookEntry(IsActive = true, CurrencyIsoCode = 'SGD', Pricebook2Id = stdPriceBook, Product2Id = prod1.Id, UnitPrice =20);
            pbeList.add(priceEntry3);
            PricebookEntry priceEntry1 = new PricebookEntry(IsActive = true, CurrencyIsoCode = 'SGD', Pricebook2Id = priceBook.Id, Product2Id = prod.Id, UnitPrice =20);
            pbeList.add(priceEntry1);
            PricebookEntry priceEntry2 = new PricebookEntry(IsActive = true, CurrencyIsoCode = 'SGD', Pricebook2Id = priceBook.Id, Product2Id = prod1.Id, UnitPrice =20);
            pbeList.add(priceEntry2);
            PricebookEntry priceEntry5 = new PricebookEntry(IsActive = true, CurrencyIsoCode = 'SGD', Pricebook2Id = priceBook.id, Product2Id = pm.Id, UnitPrice =20);
            pbeList.add(priceEntry5);
            insert pbeList;
            Payment_Method__c payment = new Payment_Method__c(Name = 'Adyen (SG)', NS_Internal_ID__c = '65');
            insert payment;
            Payment_Method__c payment1 = new Payment_Method__c(Name = 'Adyen (MY)', NS_Internal_ID__c = '101');
            insert payment1;
            test.startTest(); 
            csb2c.ProductBasketObservable obs = new csb2c.ProductBasketObservable('Test Name', new List<Id>());
            PostRulesExecutionObserver preo = new PostRulesExecutionObserver();
            preo.execute(obs, null);
            
            //CreateOppObserver updateJob = new CreateOppObserver(basketMap);
            basketIds.add(basket.Id);
            
            basketMap.put('basketIds', basketIds);
            
            CreateOppObserver_new updateJob = new CreateOppObserver_new(basketMap);
            updateJob.doWork();
            basketIds = new List<Id>();
            
            basketIds.add(basket2.Id);
            basketMap.put('basketIds', basketIds);
            
            CreateOppObserver_new updateJob1 = new CreateOppObserver_new(basketMap);
            updateJob1.doWork();
           
            test.stopTest();
        }
    }
}
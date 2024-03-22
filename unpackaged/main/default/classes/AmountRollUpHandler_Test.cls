@isTest
public class AmountRollUpHandler_Test {
    
    @isTest
    static void Method1(){ 
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            
            Trigger_Execute__c TE1 = new Trigger_Execute__c();
            TE1.Name = 'PGAccountTrigger';
            TE1.Enable_del__c = true;
            insert TE1;
            
            Trigger_Execute__c TE2 = new Trigger_Execute__c();
            TE2.Name = 'Trigger_OpportunitySplit';
            TE2.Enable_del__c = true;
            insert TE2;
            
            string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
            
            Set<Id> accset = New Set<Id>();
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
            a.Current_Subscription_Code__c = 'abc';
            a.Current_Subscription_Spending_Amount__c = 50;
            a.Pro_Rate_Amount__c =10;
            a.PersonEmail = 'test@yuni.com';
            a.Account_Rule_Code__c = 'test';
            a.Previous_Account_Rule__c = 'test';
            a.AgentKey__c = 'UT91919';
            a.Status__c = 'Active';
            a.Country__c = 'Singapore';
            a.Mobile_Country__c = '65';
            a.PersonBirthdate = date.newInstance(1970, 1, 1);
            a.Subscription_End_Date__c = system.today().addMonths(-9);
            a.Loyalty_Start_Date__c = system.today().addMonths(-1);
            a.Is_Qualify_Agent_Referral_Program__c = true;
            a.CEA_Salesperson_Number__c = 'G123456H';
            a.PersonBirthdate=system.today();
            insert a;
            accset.add(a.id);
            
            Map<Id, Opportunity> mapUpdateOppTest = New Map<Id, Opportunity>();
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'New';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(30);
            //opp.Subsidiary__c = sb.id;
            opp.Total_Spending__c = 100;
            opp.RecordTypeId = oppRectype;
            opp.PG_Tenure__c = 1;
            opp.Order_Type_Clone__c = 'Contract - Renewal';
            opp.Summary_Of_Subscription_Item_new__c = 10.00;
            opp.OMC_Submitted_Time__c = system.today();
            opp.CurrencyIsoCode = 'SGD';
            opp.Approval_Status__c = 'OMC Approval Approved';
            opp.Opportunity_Type__c='B2C - Upgrade';
            opp.Pro_Rate__c=7;
            opp.OMC_Approved_Date__c= system.today();
            opp.Is_Current_Subscription__c = true;
            opp.Include_Subscription_Ext__c= true;
            //opp.Include_Subscription__c=;
            insert opp;
            opp.OMC_Approved_Date__c= system.today().adddays(10);
            update opp;
            mapUpdateOppTest.put(opp.id,opp);
            
            
            Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book',  IsActive = true, CurrencyIsoCode = 'SGD');
            insert standardPB;
            
            Product_Class__c prodClass = New Product_Class__c(Name='Discretionary',	CurrencyIsoCode='SGD');
            insert prodClass;
            
            Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test',  Product_Type__c='PG',Description='DummyText'
                                         ,Is_Bundle__c=true,Product_Class__c = prodClass.id);
            insert prod;
            prod.Product_Category__c = 'Discretionary';
            update prod;
            
            
            Id StdpricebookId = Test.getStandardPricebookId();
            PricebookEntry pbe2 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id ,unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
            insert pbe2;
            
            List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
            opportunityLineItem oli = new opportunityLineItem();
            oli.Product2Id = prod.Id;
            oli.OpportunityId = opp.Id;
            oli.PricebookEntryId = pbe2.Id;
            oli.Quantity = 500;
            oli.Start_Date__c= system.today();
            oli.End_Date__c =system.today().adddays(1);
            oli.UnitPrice = 10000;
            oli.Product_Category__c = 'Subscription';
            oli.Push_to_NetSuite__c = true;
            oli.Complimentary__c = false;
            oli.Discount_Reason__c ='First-Timer Discount';
            oli.Amount_Despite_VIP__c = 10;
            //oli.Product_Duration__c = 210;
            //oli.Parent_Id__c ='demoparentid';
            insert oli;
            listOppLine.add(oli);
            system.debug('checkoli'+ [Select id,name ,AccountId,(select id from  opportunityLineItems) from opportunity]);
            
            List<Error_Log__c> listOfErr = new List<Error_Log__c>();
            Error_Log__c ErrLog =  new Error_Log__c();
            ErrLog.Related_Record_Id__c='TestRecordId';
            ErrLog.Data_To_Update__c = 'abcdefg';
            ErrLog.Error_Message__c='vvvvqqqq';
            ErrLog.CurrencyIsoCode='SGD';
            insert ErrLog;
            listOfErr.add(ErrLog);
            
            AmountRollUpHandler.fetchLatestOppty(accset,true);
            AmountRollUpHandler.populateClosedWonFields(a.id,null);
            AmountRollUpHandler.calcualteRollUp(opp);
            AmountRollUpHandler.populateIncludeSubscription(opp,a.id,opp.id, mapUpdateOppTest );
            AmountRollUpHandler.calculateCSSAmount(opp,a);
            AmountRollUpHandler.createErrorLog( 'TestRecordId','abcdefg','vvvvqqqq');
            new AmountRollUpBatch().execute(null);
        }
    }
    @isTest
    static void Method2(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c TE1 = new Trigger_Execute__c();
            TE1.Name = 'PGAccountTrigger';
            TE1.Enable_del__c = true;
            insert TE1;
            
            Trigger_Execute__c TE2 = new Trigger_Execute__c();
            TE2.Name = 'Trigger_OpportunitySplit';
            TE2.Enable_del__c = true;
            insert TE2;
            
            string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
          /*  id subId = PGTestDataFactory.createSubsidiary().Id;
            Account ag = new Account();
            ag.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            ag.Name = 'AgencyName';
            ag.Customer_Type__c = 'Agency';
            ag.CEA_License__c = 'CEALC';
            ag.Agency_Id__c = '52451';
            ag.Subsidiary__c = subId;
            ag.Country__c = 'Singapore';
            insert ag;*/
            
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
            
            Set<Id> accset = New Set<Id>();
            Account a = new Account();
            a.RecordTypeId = accRectype;
            a.FirstName = 'IsYuni';
            a.LastName = 'TestYuni';
            a.Agency__c = agency.Id;
            a.AgentNet_ID__c = 'AgentNet_ID__c test';
            a.Salutation = 'Mrs.';
            a.CurrencyIsoCode = 'SGD';
            a.Subscription_Start_Date__c = system.today().addMonths(-10);
            a.BillingStreet = 'test';
            a.BillingCity = 'test';
            a.Mobile_Country__c = '65';
            a.BillingCountry = 'Singapore';
            a.BillingPostalCode = '8373';
            a.Current_Subscription_Code__c = 'abc';
            a.Current_Subscription_Spending_Amount__c = 50;
            a.Pro_Rate_Amount__c = 10;
            a.PersonEmail = 'test@yuni.com';
            a.Account_Rule_Code__c = 'test';
            a.Previous_Account_Rule__c = 'test';
            a.AgentKey__c = 'UT91919';
            a.Status__c = 'Active';
            a.Country__c = 'Singapore';
            a.PersonBirthdate = date.newInstance(1970, 1, 1);
            a.Subscription_End_Date__c = system.today().addMonths(-9);
            a.Loyalty_Start_Date__c = system.today().addMonths(-1);
            a.Is_Qualify_Agent_Referral_Program__c = true;
            a.CEA_Salesperson_Number__c = 'G1234567H';
            a.PersonBirthdate=system.today();
            insert a;
            a.Pro_Rate_Amount__c = null;
            update a;
            accset.add(a.id);
            
            Account a1 = new Account();
            a1.RecordTypeId = accRectype;
            a1.Agency_Name__c =	'PropNex Realty';
            a1.PersonMobilePhone = '7777755555';
            a1.Account_Rule_Code__c='TRIAL';
            a1.FirstName = 'IsYuni';
            a1.LastName = 'TestYuni';
            a1.AgentNet_ID__c = '666513';
            a1.Salutation = 'Mrs.';
            a1.CurrencyIsoCode = 'SGD';
            a1.Subscription_Start_Date__c = system.today().addMonths(-10);
            a1.BillingStreet = 'test';
            a1.BillingCity = 'test';
            a1.BillingCountry = 'Singapore';
            a1.Mobile_Country__c = '65';
            a1.BillingPostalCode = '8373';
            a1.Current_Subscription_Code__c = 'abc';
            a1.Current_Subscription_Spending_Amount__c = 50;
            a1.Pro_Rate_Amount__c = 10;
            a1.PersonEmail = 'test@yuni123.com';
            a1.Account_Rule_Code__c = 'test';
            a1.Previous_Account_Rule__c = 'test';
            a1.AgentKey__c = 'UT91919';
            a1.Status__c = 'Active';
            a1.Country__c = 'Singapore';
            a1.PersonBirthdate = date.newInstance(1970, 1, 1);
            a1.Subscription_End_Date__c = system.today().addMonths(-9);
            a1.Loyalty_Start_Date__c = system.today().addMonths(-1);
            a1.Is_Qualify_Agent_Referral_Program__c = true;
            a1.CEA_Salesperson_Number__c = 'G0234567H';
            a1.PersonBirthdate=system.today();
            insert a1;
            a1.Account_Rule_Code__c='TRIAL';
            update a1;
            
            Map<Id, Opportunity> mapUpdateOppTest = New Map<Id, Opportunity>();
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Proposal';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().Addmonths(-12);
            //opp.Subsidiary__c = sb.id;
            opp.Total_Spending__c = 100;
            opp.RecordTypeId = oppRectype;
            opp.PG_Tenure__c = 1;
            opp.Order_Type_Clone__c = 'Contract - Renewal';
            opp.Summary_Of_Subscription_Item_new__c = 10.00;
            opp.OMC_Submitted_Time__c = system.today();
            opp.Approval_Status__c = 'OMC Approval Approved';
            opp.Opportunity_Type__c='B2C - Renewal';
            opp.Pro_Rate__c=7;
            opp.CurrencyIsoCode = 'SGD';
            opp.OMC_Approved_Date__c= system.today();
            opp.Is_Current_Subscription__c = true;
            opp.Include_Subscription_Ext__c= true;
            //opp.Include_Subscription__c=;
            insert opp;
            
            opp.Is_Current_Subscription__c = true;
            opp.ByAuto__c = true;
            opp.Months_Included__c=true;
            update opp;
            
            mapUpdateOppTest.put(opp.id,opp);
            
            Test.startTest();
            
            Opportunity opp1 = new opportunity();
            opp1.Name = 'Test Opp1';
            opp1.StageName = 'Proposal';
            opp1.AccountId = a.id;
            opp1.CloseDate = system.today().Addmonths(12);
            //opp.Subsidiary__c = sb.id;
            opp1.Total_Spending__c = 100;
            opp1.RecordTypeId = oppRectype;
            opp1.PG_Tenure__c = 1;
            //opp1.Order_Type_Clone__c = 'Contract - Renewal';
            opp1.Summary_Of_Subscription_Item_new__c = 10.00;
            opp1.OMC_Submitted_Time__c = system.today();
            opp1.Approval_Status__c = 'OMC Approval Approved';
            opp1.Opportunity_Type__c='B2C - Renewal';
            opp1.CurrencyIsoCode = 'SGD';
            opp1.Pro_Rate__c=7;
            opp1.OMC_Approved_Date__c= system.today();
            opp1.Is_Current_Subscription__c = true;
            opp1.Months_Included__c = true;
            opp1.Include_Subscription_Ext__c= true;
            //opp.Include_Subscription__c=;
            insert opp1;
            system.debug('oppMonths_Included__c'+opp1.Exclude_from_Spending_at__c);
            
            opp1.StageName = 'Closed Won';
            update opp1;
            
            Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book',  IsActive = true, CurrencyIsoCode = 'SGD');
            insert standardPB;
            
            Product_Class__c prodClass = New Product_Class__c(Name='Subscription',	CurrencyIsoCode='SGD');
            insert prodClass;
            
            Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test',  Product_Type__c='PG',Description='DummyText'
                                         ,Is_Bundle__c=true,Product_Class__c = prodClass.id);
            insert prod;
            prod.Product_Category__c = 'Subscription';
            update prod;
            
            
            Id StdpricebookId = Test.getStandardPricebookId();
            PricebookEntry pbe2 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id ,unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
            insert pbe2;
            
            List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
            opportunityLineItem oli = new opportunityLineItem();
            oli.Product2Id = prod.Id;
            oli.OpportunityId = opp.Id;
            oli.PricebookEntryId = pbe2.Id;
            oli.Quantity = 500;
            oli.Start_Date__c= system.today().adddays(10);
            oli.UnitPrice = 10000;
            oli.Product_Category__c = 'Subscription';
            oli.Complimentary__c = true;
            oli.Discount_Reason__c ='VIP (Relationship)';
            oli.Amount_Despite_VIP__c = 10;
            oli.End_Date__c =system.today().adddays(210);
            insert oli;
            oli.Complimentary__c = true;
            oli.Push_to_NetSuite__c = true;
            update oli;
            listOppLine.add(oli);
            
            
            opportunityLineItem oli1 = new opportunityLineItem();
            oli1.Product2Id = prod.Id;
            oli1.OpportunityId = opp.Id;
            oli1.PricebookEntryId = pbe2.Id;
            oli1.Quantity = 500;
            oli1.Start_Date__c= system.today().adddays(10);
            //oli.End_Date__c =system.today().adddays(1);
            oli1.UnitPrice = 10000;
            oli1.Product_Category__c = 'Subscription';
            oli1.Complimentary__c = true;
            oli1.Discount_Reason__c ='VIP (Relationship)';
            oli1.Amount_Despite_VIP__c = 10;
            oli1.End_Date__c =system.today().adddays(210);
            //oli.Product_Duration__c = 210;
            //oli.Parent_Id__c ='demoparentid';
            insert oli1;
            AmountRollUpHandler.fetchLatestOppty(accset,false);
            AmountRollUpHandler.calcualteRollUp(opp);
            AmountRollUpHandler.populateIncludeSubscription(opp, a.id, opp.id, mapUpdateOppTest);
            AmountRollUpHandler.calculateCSSAmount(opp,a);
            AmountRollUpHandler.populateConvertedSSFields(Opp.id);
            Test.stopTest();
        }
    }
    
    @isTest
    static void Method3(){
        User user = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(user){
            Trigger_Execute__c TE2 = new Trigger_Execute__c();
            TE2.Name = 'Trigger_OpportunitySplit';
            TE2.Enable_del__c = true;
            insert TE2;
            
            Opportunity opp = null;
            Account acc_b2c  = null;
            // Avoid mixed DML
            User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
            System.runAs (thisUser) {
                // Call method to insert test records
                PGTestDataFactory_v2.initSetupData();
                //data setup
                system.debug('DML TestDataFactory');
                Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
                Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
                acc_b2c = PGTestDataFactory_v2.createB2CAccount('test@test.com','1232134', thisUser, sb);
                
                //standard PB
                Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
                //Subscription Class
                Product_Class__c productClass = PGTestDataFactory_v2.createProductClass('Subscription',sb);
                
                //item
                list<Product2> listProd = new list<Product2>();
                Product2 prod = PGTestDataFactory_v2.CreateProduct('Test Prod', 'B2C Only', 'Subscription', 'abc', productClass, taxcode);
                listProd.add(prod);
                Product2 prod2 = PGTestDataFactory_v2.CreateProduct('Test Prod2', 'B2C Only', 'Subscription', 'abc', productClass, taxcode);
                listProd.add(prod2);
                insert listProd;
                
                //sg pbe
                Id StdpricebookId = Test.getStandardPricebookId();
                list<PricebookEntry> listPBE = new list<PricebookEntry>();
                PricebookEntry pbe = PGTestDataFactory_v2.CreatePBE(StdpricebookId, prod, 100.0, sb,false);
                PricebookEntry pbe2 = PGTestDataFactory_v2.CreatePBE(standardPB.Id, prod, 100.0, sb,true);
                
                opp = PGTestDataFactory_v2.createB2CSubscriptionOpty(acc_b2c,thisUser,sb,standardPB, 'B2C - Upgrade');
                OpportunityLineItem oppLine = PGTestDataFactory_v2.CreateOppLineItem(opp,pbe2,prod);
                
                opp.OMC_Approved_Date__c = system.today();
                opp.StageName = 'Closed Won';
                opp.Approval_Status__c = 'OMC Approval Approved';
                opp.Count_of_subscription_item_new__c = 1;
                opp.Summary_Of_Subscription_Item_new__c = 300;
                update opp;
                
            }
            
            Test.startTest();
            new AmountRollUpBatch().execute(null);
            Test.stopTest();
        }
    }
    
    @isTest
    static void Method4(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c TE1 = new Trigger_Execute__c();
            TE1.Name = 'PGAccountTrigger';
            TE1.Enable_del__c = true;
            insert TE1;
            
            Trigger_Execute__c TE2 = new Trigger_Execute__c();
            TE2.Name = 'Trigger_OpportunitySplit';
            TE2.Enable_del__c = true;
            insert TE2;
            
            string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Self-Serve').getRecordTypeId();
            
            Test.startTest();
            Set<Id> accset = New Set<Id>();
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
            a.Mobile_Country__c = '65';
            a.BillingPostalCode = '8373';
            a.Current_Subscription_Code__c = 'abc';
            a.Current_Subscription_Spending_Amount__c = 50;
            a.Pro_Rate_Amount__c =10;
            a.PersonEmail = 'test@yuni.com';
            a.Account_Rule_Code__c = 'test';
            a.Previous_Account_Rule__c = 'test';
            a.AgentKey__c = 'UT91919';
            a.Status__c = 'Active';
            a.Country__c = 'Singapore';
            a.PersonBirthdate = date.newInstance(1970, 1, 1);
            a.Subscription_End_Date__c = system.today().addMonths(-9);
            a.Loyalty_Start_Date__c = system.today().addMonths(-1);
            a.Is_Qualify_Agent_Referral_Program__c = true;
            a.CEA_Salesperson_Number__c = 'G1234567H';
            a.PersonBirthdate=system.today();
            insert a;
            accset.add(a.id);
            
            Map<Id, Opportunity> mapUpdateOppTest = New Map<Id, Opportunity>();
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Converted';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(30);
            //opp.Subsidiary__c = sb.id;
            opp.Total_Spending__c = 100;
            opp.RecordTypeId = oppRectype;
            opp.PG_Tenure__c = 1;
            opp.CurrencyIsoCode = 'SGD';
            opp.Order_Type_Clone__c = 'Contract - Renewal';
            opp.Summary_Of_Subscription_Item_new__c = 10.00;
            opp.OMC_Submitted_Time__c = system.today();
            opp.Approval_Status__c = 'OMC Approval Approved';
            opp.Opportunity_Type__c='B2C - Renewal';
            opp.Pro_Rate__c=7;
            opp.OMC_Approved_Date__c= system.today();
            opp.Is_Current_Subscription__c = true;
            opp.Include_Subscription_Ext__c= true;
            //opp.Include_Subscription__c=;
            insert opp;
            opp.OMC_Approved_Date__c= system.today().adddays(10);
            update opp;
            mapUpdateOppTest.put(opp.id,opp);
            system.debug('check'+ [Select id,name ,(select id,name from opportunities) from Account]);
            
            
            Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book',  IsActive = true, CurrencyIsoCode = 'SGD');
            insert standardPB;
            
            Product_Class__c prodClass = New Product_Class__c(Name='Subscription',	CurrencyIsoCode='SGD');
            insert prodClass;
            
            Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test',  Product_Type__c='PG',Description='DummyText'
                                         ,Is_Bundle__c=true,Product_Class__c = prodClass.id);
            insert prod;
            prod.Product_Category__c = 'Subscription';
            update prod;
            
            
            Id StdpricebookId = Test.getStandardPricebookId();
            PricebookEntry pbe2 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id ,unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
            insert pbe2;
            
            
            List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
            opportunityLineItem oli = new opportunityLineItem();
            oli.Product2Id = prod.Id;
            oli.OpportunityId = opp.Id;
            oli.PricebookEntryId = pbe2.Id;
            oli.Quantity = 500;
            oli.Start_Date__c= system.today();
            oli.End_Date__c =system.today().adddays(1);
            oli.UnitPrice = 10000;
            oli.Product_Category__c = 'Subscription';
            oli.Complimentary__c = false;
            oli.Push_to_NetSuite__c = true;
            oli.Discount_Reason__c ='First-Timer Discount';
            oli.Amount_Despite_VIP__c = 10;
            //oli.Product_Duration__c = 210;
            //oli.Parent_Id__c ='demoparentid';
            insert oli;
            listOppLine.add(oli);
            system.debug('checkoli'+ [Select id,name ,AccountId,(select id from  opportunityLineItems) from opportunity]);
            
            List<Error_Log__c> listOfErr = new List<Error_Log__c>();
            Error_Log__c ErrLog =  new Error_Log__c();
            ErrLog.Related_Record_Id__c='TestRecordId';
            ErrLog.Data_To_Update__c = 'abcdefg';
            ErrLog.Error_Message__c='vvvvqqqq';
            ErrLog.CurrencyIsoCode='SGD';
            insert ErrLog;
            listOfErr.add(ErrLog);
            
            AmountRollUpHandler.populateConvertedSSFields(opp.Id);
            new AmountRollUpBatch().execute(null);
            Test.stopTest();
        }
    }
    
    @isTest
    static void Method5(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c TE1 = new Trigger_Execute__c();
            TE1.Name = 'PGAccountTrigger';
            TE1.Enable_del__c = true;
            insert TE1;
            
            Trigger_Execute__c TE2 = new Trigger_Execute__c();
            TE2.Name = 'Trigger_OpportunitySplit';
            TE2.Enable_del__c = true;
            insert TE2;
            
            string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
            
            
            Set<Id> accset = New Set<Id>();
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
            a.Current_Subscription_Code__c = 'abc';
            a.Current_Subscription_Spending_Amount__c = 50;
            a.Pro_Rate_Amount__c =10;
            a.PersonEmail = 'test1@yuni.com';
            a.Account_Rule_Code__c = 'test1';
            a.Previous_Account_Rule__c = 'test2';
            a.AgentKey__c = 'UT91919';
            a.Mobile_Country__c = '65';
            a.Status__c = 'Active';
            a.Country__c = 'Singapore';
            a.PersonBirthdate = date.newInstance(1970, 1, 1);
            a.Subscription_End_Date__c = system.today().addMonths(-9);
            a.Loyalty_Start_Date__c = system.today().addMonths(-1);
            a.Is_Qualify_Agent_Referral_Program__c = true;
            a.CEA_Salesperson_Number__c = 'G1234567H';
            // a.PersonBirthdate=system.today();
            insert a;
            accset.add(a.id);
            
            
            
            Map<Id, Opportunity> mapUpdateOppTest = New Map<Id, Opportunity>();
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Closed Won';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(10);
            //opp.Subsidiary__c = sb.id;
            opp.Total_Spending__c = 100;
            opp.RecordTypeId = oppRectype;
            opp.PG_Tenure__c = 1;
            opp.Order_Type_Clone__c = 'Contract - Renewal';
            opp.Summary_Of_Subscription_Item_new__c = 10.00;
            opp.OMC_Submitted_Time__c = system.today();
            opp.Approval_Status__c = 'OMC Approval Approved';
            opp.Opportunity_Type__c='B2C - Upgrade';
            opp.CurrencyIsoCode = 'SGD';
            opp.Pro_Rate__c=7;
            opp.OMC_Approved_Date__c= system.today();
            opp.Is_Current_Subscription__c = true;
            opp.Include_Subscription_Ext__c= true;
            // opp.Product_Category__c ='Subscription';
            // opp.Push_to_NetSuite__c = true;
            //opp.IsWon = true;
            //opp.Include_Subscription__c=;
            insert opp;
            opp.OMC_Approved_Date__c= system.today().adddays(30);
            update opp;
            mapUpdateOppTest.put(opp.id,opp);
            
            Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book',  IsActive = true, CurrencyIsoCode = 'SGD');
            insert standardPB;
            
            Product_Class__c prodClass = New Product_Class__c(Name='Subscription',	CurrencyIsoCode='SGD');
            insert prodClass;
            
            Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test',  Product_Type__c='PG',Description='DummyText'
                                         ,Is_Bundle__c=true,Product_Class__c = prodClass.id);
            insert prod;
            prod.Product_Category__c = 'Subscription';
            update prod;
            
            
            Id StdpricebookId = Test.getStandardPricebookId();
            PricebookEntry pbe2 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id ,unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
            insert pbe2;
            
            List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
            opportunityLineItem oli = new opportunityLineItem();
            oli.Product2Id = prod.Id;
            oli.OpportunityId = opp.Id;
            oli.PricebookEntryId = pbe2.Id;
            oli.Quantity = 500;
            oli.Start_Date__c= system.today();
            oli.End_Date__c =system.today().adddays(1);
            oli.UnitPrice = 10000;
            oli.Product_Category__c = 'Subscription';
            oli.Complimentary__c = false;
            oli.Discount_Reason__c ='VIP (Spending)';
            oli.Amount_Despite_VIP__c = 10;
            oli.Push_to_NetSuite__c = true;
            //oli.Product_Duration__c = 210;
            //oli.Parent_Id__c ='demoparentid';
            insert oli;
            listOppLine.add(oli);
           
            
            List<Error_Log__c> listOfErr = new List<Error_Log__c>();
            Error_Log__c ErrLog =  new Error_Log__c();
            ErrLog.Related_Record_Id__c='TestRecordId1';
            ErrLog.Data_To_Update__c = 'abcdefgh';
            ErrLog.Error_Message__c='vvvvqqqqr';
            ErrLog.CurrencyIsoCode='SGD';
            insert ErrLog;
            listOfErr.add(ErrLog);
            
            List<Error_Log__c> listOfErr1 = new List<Error_Log__c>();
            Error_Log__c ErrLog1 =  new Error_Log__c();
            ErrLog1.Related_Record_Id__c='TestRecordId12';
            ErrLog1.Data_To_Update__c = 'abcdefghi';
            ErrLog1.Error_Message__c='vvvvqqqqrs';
            ErrLog1.CurrencyIsoCode='SGD';
            insert ErrLog1;
            listOfErr1.add(ErrLog1);
            
            Test.startTest();  
            AmountRollUpHandler.fetchLatestOppty(accset,true);
            AmountRollUpHandler.populateClosedWonFields(a.id,opp.id);  
            // AmountRollUpHandler.calcualteRollUp(opp);
            //  AmountRollUpHandler.populateIncludeSubscription(opp,a.id,opp.id, mapUpdateOppTest );
            // AmountRollUpHandler.calculateCSSAmount(opp,a);
            AmountRollUpHandler.createErrorLog( 'TestRecordId1','abcdefgh','vvvvqqqqr');
            AmountRollUpHandler.createErrorLog( 'TestRecordId12','abcdefghi','vvvvqqqqrs');
            new AmountRollUpBatch().execute(null);
            Test.stopTest();
        }
    }
}
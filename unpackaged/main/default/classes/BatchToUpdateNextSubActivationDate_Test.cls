@isTest
public class BatchToUpdateNextSubActivationDate_Test {
    @isTest
    public static void UpdateNextSAD(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c customsetting=new Trigger_Execute__c();
            customsetting.Name='PGAccountTrigger';
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
            
            PGTestDataFactory_v2.initSetupData();    
            string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            Account a = new Account();
            a.RecordTypeId = accRectype;
            a.LastName = 'PGAccount';
            a.salutation = 'Mr.';
            a.FirstName = 'abc';
            a.CurrencyIsoCode = 'SGD';
            a.Subscription_Start_Date__c = system.today().addMonths(-10);
            a.BillingStreet = 'test';
            a.BillingCity = 'test';
            a.BillingCountry = 'Singapore';
            a.BillingPostalCode = '8373';
            //a.BillingState = 'test';
            a.Current_Subscription_Code__c = 'abc';
            a.Account_Rule_Code__c = 'test';
            a.AgentNet_ID__c = '123';
            a.PersonEmail = 'test@test.com';
            a.Country__c = 'Singapore';
            a.Status__c = 'Active';
            a.Next_Subscription_Activation_Date__c=System.todAY()-9;
            a.CEA_Salesperson_Number__c = 'S215463K';
            a.PersonBirthdate = system.today();
            a.Subsidiary__c = subId;
            insert a;
            
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'New';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(30);
            //opp.Subsidiary__c = sb.id;
            opp.Total_Spending__c = 100;
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
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
            
            
            
            
            Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =opp.RecordTypeId,
                                                                      Destination_Recordtype_Id__c =opp.RecordTypeId,active__c=true);
            insert sd1;
            insert opp;
            
            Product_Class__c productClass = new Product_Class__c(Name = 'Subscription', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/);
            insert productClass;
            
            Id StdpricebookId = Test.getStandardPricebookId();
            List<Product2> prodList=new List<Product2>();
            
            Product2 prod = new Product2(Name = 'Test Prod', IsActive = true,
                                         Segment__c = 'B2C Only', Product_Category__c = 'Subscription',
                                         SKU_Code__c = 'abc', Is_Bundle__c= true, CurrencyIsoCode = 'SGD',
                                         Product_class__c=productclass.id);
            prodList.add(prod);
            
            insert ProdList;
            
            //     system.debug('***prod  '+ProdList);
            List<PricebookEntry> pbeList = new List<PricebookEntry>();
            
            PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, 
                                                    isActive=true, CurrencyIsoCode = 'SGD');
            pbeList.add(pbe);
            
            insert pbeList;
            
            List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
            opportunityLineItem oli = new opportunityLineItem();
            oli.Product2Id = prod.Id;
            oli.OpportunityId = opp.Id;
            oli.PricebookEntryId = pbe.Id;
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
            
            listOppLine.add(oli);
            insert listOppLine;
            
            //insert oliList;
            Test.startTest();
            opp.Approval_Status__c='OMC Approval Approved';
            opp.OMC_Approved_Date__c=system.today();
            opp.Count_of_Subscription_Item_new__c=2;
            opp.StageName='Closed Won';
            update opp;
            //  list<OpportunityLineItem> o=[select id, SNO__c, Actual_Start_date__c from OpportunityLineItem where Actual_Start_date__c != null 
            //                        AND SNO__c != null AND Product2.Product_Category__c='Subscription' Order By SNO__c ASC];
            // system.debug('**********'+o);
            BatchToUpdateNextSubActivationDate obj = new BatchToUpdateNextSubActivationDate();
            DataBase.executeBatch(obj);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void UpdateNextSAD1(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c customsetting=new Trigger_Execute__c();
            customsetting.Name='PGAccountTrigger';
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
            
            PGTestDataFactory_v2.initSetupData();    
            string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            Account a = new Account();
            a.RecordTypeId = accRectype;
            a.LastName = 'PGAccount';
            a.salutation = 'Mr.';
            a.FirstName = 'abc';
            a.CurrencyIsoCode = 'SGD';
            a.Subscription_Start_Date__c = system.today().addMonths(-10);
            a.BillingStreet = 'test';
            a.BillingCity = 'test';
            a.BillingCountry = 'Singapore';
            a.BillingPostalCode = '8373';
            //a.BillingState = 'test';
            a.Current_Subscription_Code__c = 'abc';
            a.Account_Rule_Code__c = 'test';
            a.AgentNet_ID__c = '123';
            a.PersonEmail = 'test@test.com';
            a.Country__c = 'Singapore';
            a.Status__c = 'Active';
            a.Next_Subscription_Activation_Date__c=System.todAY()-9;
            a.CEA_Salesperson_Number__c = 'S215463K';
            a.PersonBirthdate = system.today();
            a.Subsidiary__c = subId;
            insert a;
            
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'New';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(30);
            //opp.Subsidiary__c = sb.id;
            opp.Total_Spending__c = 100;
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
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
            
            
            
            
            Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =opp.RecordTypeId,
                                                                      Destination_Recordtype_Id__c =opp.RecordTypeId,active__c=true);
            insert sd1;
            insert opp;
            
            Product_Class__c productClass = new Product_Class__c(Name = 'Subscription', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/);
            insert productClass;
            
            Id StdpricebookId = Test.getStandardPricebookId();
            List<Product2> prodList=new List<Product2>();
            
            Product2 prod = new Product2(Name = 'Test Prod', IsActive = true,
                                         Segment__c = 'B2C Only', Product_Category__c = 'Subscription',
                                         SKU_Code__c = 'abc', Is_Bundle__c= true, CurrencyIsoCode = 'SGD',
                                         Product_class__c=productclass.id);
            prodList.add(prod);
            
            insert ProdList;
            
            //     system.debug('***prod  '+ProdList);
            List<PricebookEntry> pbeList = new List<PricebookEntry>();
            
            PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, 
                                                    isActive=true, CurrencyIsoCode = 'SGD');
            pbeList.add(pbe);
            
            insert pbeList;
            
            List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
            opportunityLineItem oli = new opportunityLineItem();
            oli.Product2Id = prod.Id;
            oli.OpportunityId = opp.Id;
            oli.PricebookEntryId = pbe.Id;
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
            
            listOppLine.add(oli);
            insert listOppLine;
            
            Test.startTest();
            opp.Approval_Status__c='OMC Approval Approved';
            opp.OMC_Approved_Date__c=system.today()+5;
            opp.Count_of_Subscription_Item_new__c=2;
            opp.StageName='Closed Won';
            update opp;
            BatchToUpdateNextSubActivationDate obj = new BatchToUpdateNextSubActivationDate();
            DataBase.executeBatch(obj);
            Test.stopTest();
        }
    }
    
    @isTest
    static void UpdateNextSAD2(){
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
            opp.Is_Current_Subscription__c = true;
            opp.Include_Subscription_Ext__c= true;
            //opp.Include_Subscription__c=;
            insert opp;
            mapUpdateOppTest.put(opp.id,opp);
            
            Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book',  IsActive = true, CurrencyIsoCode = 'SGD');
            insert standardPB;
            
            Product_Class__c prodClass = New Product_Class__c(Name='Subscription',  CurrencyIsoCode='SGD');
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
            
            Test.startTest();   
            BatchToUpdateNextSubActivationDate obj = new BatchToUpdateNextSubActivationDate();
            DataBase.executeBatch(obj);
            Test.stopTest();
        }
    }
    
    @isTest
    static void UpdateNextSAD3(){
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
            opp.CloseDate = system.today();
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
            opp.Is_Current_Subscription__c = true;
            opp.Include_Subscription_Ext__c= true;
            //opp.Include_Subscription__c=;
            insert opp;
            mapUpdateOppTest.put(opp.id,opp);
            
            Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book',  IsActive = true, CurrencyIsoCode = 'SGD');
            insert standardPB;
            
            Product_Class__c prodClass = New Product_Class__c(Name='Subscription',  CurrencyIsoCode='SGD');
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
            oli.Start_Date__c= system.today().AddDays(30);
            oli.End_Date__c =system.today().adddays(60);
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
            
            Test.startTest();   
            BatchToUpdateNextSubActivationDate obj = new BatchToUpdateNextSubActivationDate();
            DataBase.executeBatch(obj);
            Test.stopTest();
        }
    }  
}
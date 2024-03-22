@isTest
public class createOpportunitiesAPI_Test {
    @isTest
    public static void oppTestMethod(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c PGTrigger =new Trigger_Execute__c();
            PGTrigger.Name='PGAccountTrigger';
            PGTrigger.Enable_del__c=true;
            insert PGTrigger;
           
            
            Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
            PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
            PGTriggerOppSplit.Enable_del__c=true;
            insert PGTriggerOppSplit;
            
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            User u = new User(Alias = 'gtest', Email='giantest@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='GianTest', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='giantest@testorg.com', Subsidiary__c='PropertyGuru Pte Ltd'
                             );
            
            insert u;
            //id subId = PGTestDataFactory.createSubsidiary().Id;
            subsidiary__c sb = new Subsidiary__c();
            sb.Name = thisuser.Subsidiary__c;
            sb.NS_Subsidiary_Internal_ID__c = '1';
            sb.CurrencyIsoCode = 'SGD';
            sb.Tax_Label__c = 'taxLabel';
            sb.Country__c = 'Singapore';
            sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
            insert sb;
           
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Singapore';
            agency.Subsidiary__c = sb.id;
            listAccount1.add(agency);
            
            Tax_Code__c taxcode = new Tax_Code__c();
            taxcode.Name = 'SG - 7% GST';
            taxcode.Tax_Rate__c =  7;
            taxcode.Country__c = 'Singapore';
            insert taxcode;
            
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
            //a.BillingState = 'test';
            a.Current_Subscription_Code__c = 'abc';
            a.Account_Rule_Code__c = 'test';
            a.AgentNet_ID__c = '123';
            a.PersonEmail = '12121assas@yahoo.com';
            a.Country__c = 'Singapore';
            a.Status__c = 'Active';
            a.CEA_Salesperson_Number__c = 'E458652L';
            a.PersonBirthdate = system.today();
            a.Subsidiary__c = sb.id;
            a.Agency__c = agency.id;
            a.External_Field__c = 'Check';
            a.Test_Account__c = False;
            a.NetSuite_Id__c = null;
            a.Mobile_Country__c = '65';
            insert a;
           
            Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
            insert productClass;
            list<Product2>  prodList = new  list<Product2>();  
            Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
            insert prod;
            prodList.add(prod); 
            
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Proposal';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(30);
            opp.PG_Tenure__c = 4;
            opp.Total_Spending__c = 100;
            opp.ownerid = u.id;
            //opp.Agent_Accepted_Time__c = system.now();
            opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
            opp.Subsidiary__c = sb.id;
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
            opp.Payment_Type__c = 'Offline';
            
            Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =opp.RecordTypeId,
                                                                      Destination_Recordtype_Id__c =opp.RecordTypeId,active__c=true);
            insert sd1;
            //insert opp;
            opp.Payment_Time__c = system.now();
            opp.Approval_Status__c = 'OMC Approval Approved';
            opp.StageName = 'Pending OMC Approval';
            opp.Submit_to_OMC_Manually__c  = false;
            opp.Billing_Street_new__c = 'TestStreet';
            opp.Billing_Country_new__c = 'TestCoutry';
            opp.Billing_City_new__c = 'TestCity';
            //update opp;
            
            Field_Mapping__c fieldMap = new Field_Mapping__c();
            fieldMap.CurrencyIsoCode = 'SGD';
            fieldMap.isActive__c = True; 
            fieldMap.Search_Data__c = sd1.id;
            fieldMap.Instance_Name__c = 'Both';
            fieldMap.Label__c = 'Accountid';    
            fieldMap.from__c = 'Opportunity_Type__c';
            fieldMap.To__c = 'Opportunity_Type__c';
            fieldMap.Sequennce__c = 40;
            fieldMap.Related_List_Label__c = 'Account';
            fieldMap.related_Object_API__c = 'Account';
            fieldMap.DataType__c = 'Picklist'; 
            fieldMap.recordCreation__c = True;
            insert fieldMap;
           
            Test.startTest();
            RestRequest req2 = new RestRequest(); 
            RestResponse res2 = new RestResponse();
            req2.requestURI = '/services/apexrest/api/createOpportunitiesAndQuotes/*';  //Request URL
            req2.httpMethod = 'post';//HTTP Request Type
            RestContext.request = req2;
            string JSONMsg1 = '{"StartDate":"2022-06-30","sObjName":"Opportunity","sendResponse":[{"value":"test","label":"Name"},{"value":"New","label":"StageName"},{"value":"B2C - Standard","label":"Opportunity_Type__c"},{"value":"2022-06-17","label":"CloseDate"}],"prodList":["Test"],"objectId":"'+ opp.id +'","isOverlapping":null,"email":"damini.sinha@algoworks.com","desrecordtype":"'+ opp.RecordTypeId +'","accountId":"'+ a.id +'"}';
            req2.requestBody = blob.valueOf(JSONMsg1);
            RestContext.response= res2;
            
            createOpportunitiesAPI.createOpportunities();
            Test.stopTest();
        }
    }
    
    @isTest
    public static void oppTestMethod1(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c PGTrigger =new Trigger_Execute__c();
            PGTrigger.Name='PGAccountTrigger';
            PGTrigger.Enable_del__c=true;
            insert PGTrigger;
            /* Trigger_Execute__c PGTriggerOpp =new Trigger_Execute__c();
PGTriggerOpp.Name='PGOpportunityTrigger';
PGTriggerOpp.Enable_del__c=true;
insert PGTriggerOpp;*/
            
            Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
            PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
            PGTriggerOppSplit.Enable_del__c=true;
            insert PGTriggerOppSplit;
            
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            User u = new User(Alias = 'gtest', Email='giantest@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='GianTest', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='giantest@testorg.com', Subsidiary__c='PropertyGuru Pte Ltd'
                             );
            
            insert u;
            //id subId = PGTestDataFactory.createSubsidiary().Id;
            subsidiary__c sb = new Subsidiary__c();
            sb.Name = thisuser.Subsidiary__c;
            sb.NS_Subsidiary_Internal_ID__c = '1';
            sb.CurrencyIsoCode = 'SGD';
            sb.Tax_Label__c = 'taxLabel';
            sb.Country__c = 'Singapore';
            sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
            insert sb;
            /*Subsidiary__c sb = new Subsidiary__c();
sb.Name = 'PropertyGuru Pte Ltd';
sb.NS_Subsidiary_Internal_ID__c = '1';
sb.CurrencyIsoCode = 'MYR';
sb.Tax_Label__c = 'taxLabel';
sb.Country__c = 'Malaysia';
sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
insert sb;*/
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Singapore';
            agency.Subsidiary__c = sb.id;
            listAccount1.add(agency);
            
            Tax_Code__c taxcode = new Tax_Code__c();
            taxcode.Name = 'SG - 7% GST';
            taxcode.Tax_Rate__c =  7;
            taxcode.Country__c = 'Singapore';
            insert taxcode;
            
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
            //a.BillingState = 'test';
            a.Current_Subscription_Code__c = 'abc';
            a.Account_Rule_Code__c = 'test';
            a.AgentNet_ID__c = '123';
            a.PersonEmail = '12121assas@yahoo.com';
            a.Country__c = 'Singapore';
            a.Status__c = 'Active';
            a.CEA_Salesperson_Number__c = 'E458652L';
            a.PersonBirthdate = system.today();
            a.Subsidiary__c = sb.id;
            a.Agency__c = agency.id;
            a.Test_Account__c = True;
            a.External_Field__c = 'Check';
            a.Mobile_Country__c = '65';
            insert a;
            
            Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
            insert productClass;
            list<Product2>  prodList = new  list<Product2>();  
            Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
            insert prod;
            prodList.add(prod); 
            
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Proposal';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(30);
            opp.PG_Tenure__c = 4;
            opp.Total_Spending__c = 100;
            opp.ownerid = u.id;
            //opp.Agent_Accepted_Time__c = system.now();
            opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
            opp.Subsidiary__c = sb.id;
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
            opp.Payment_Type__c = 'Offline';
            
            Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =opp.RecordTypeId,
                                                                      Destination_Recordtype_Id__c =opp.RecordTypeId,active__c=true);
            insert sd1;
            //insert opp;
            opp.Payment_Time__c = system.now();
            opp.Approval_Status__c = 'OMC Approval Approved';
            opp.StageName = 'Pending OMC Approval';
            opp.Submit_to_OMC_Manually__c  = false;
            opp.Billing_Street_new__c = 'TestStreet';
            opp.Billing_Country_new__c = 'TestCoutry';
            opp.Billing_City_new__c = 'TestCity';
            //update opp;
            
            Field_Mapping__c fieldMap = new Field_Mapping__c();
            fieldMap.CurrencyIsoCode = 'SGD';
            fieldMap.isActive__c = True; 
            fieldMap.Search_Data__c = sd1.id;
            fieldMap.Instance_Name__c = 'Both';
            fieldMap.Label__c = 'Accountid';    
            fieldMap.from__c = 'Opportunity_Type__c';
            fieldMap.To__c = 'Opportunity_Type__c';
            fieldMap.Sequennce__c = 40;
            fieldMap.Related_List_Label__c = 'Account';
            fieldMap.related_Object_API__c = 'Account';
            fieldMap.DataType__c = 'Picklist'; 
            fieldMap.recordCreation__c = True;
            insert fieldMap;
            
            Field_Mapping__c fieldMap1 = new Field_Mapping__c();
            fieldMap1.CurrencyIsoCode = 'SGD';
            fieldMap1.isActive__c = True; 
            fieldMap1.Search_Data__c = sd1.id;
            fieldMap1.Instance_Name__c = 'Both';
            fieldMap1.Label__c = 'Close Date';    
            fieldMap1.from__c = 'CloseDate';
            fieldMap1.To__c = 'Opportunity_Type__c';
            fieldMap1.Sequennce__c = 50;
            fieldMap1.Related_List_Label__c = 'Account';
            fieldMap1.related_Object_API__c = 'Account';
            fieldMap1.DataType__c = 'Date'; 
            fieldMap1.recordCreation__c = True;
            insert fieldMap1;
            
            
            Test.startTest();
            RestRequest req2 = new RestRequest(); 
            RestResponse res2 = new RestResponse();
            req2.requestURI = '/services/apexrest/api/createOpportunitiesAndQuotes/*';  //Request URL
            req2.httpMethod = 'post';//HTTP Request Type
            RestContext.request = req2;
            string JSONMsg1 = '{"StartDate":"2022-06-30","sObjName":"Opportunity","sendResponse":[{"value":"test","label":"Name"},{"value":"New","label":"StageName"},{"value":"B2C - Standard","label":"Opportunity_Type__c"},{"value":"2022-06-17","label":"CloseDate"}],"prodList":["Test"],"objectId":"'+ opp.id +'","isOverlapping":null,"email":"damini.sinha@algoworks.com","desrecordtype":"'+ opp.RecordTypeId +'","accountId":"'+ a.id +'"}';
            req2.requestBody = blob.valueOf(JSONMsg1);
            RestContext.response= res2;
            
            createOpportunitiesAPI.createOpportunities();
            Test.stopTest();
        }
    }
    
    @isTest
    public static void oppTestMethod2(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c PGTrigger =new Trigger_Execute__c();
            PGTrigger.Name='PGAccountTrigger';
            PGTrigger.Enable_del__c=true;
            insert PGTrigger;
           
            
            Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
            PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
            PGTriggerOppSplit.Enable_del__c=true;
            insert PGTriggerOppSplit;
            
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            User u = new User(Alias = 'gtest', Email='giantest@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='GianTest', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='giantest@testorg.com', Subsidiary__c='PropertyGuru Pte Ltd'
                             );
            
            insert u;
            //id subId = PGTestDataFactory.createSubsidiary().Id;
            subsidiary__c sb = new Subsidiary__c();
            sb.Name = thisuser.Subsidiary__c;
            sb.NS_Subsidiary_Internal_ID__c = '1';
            sb.CurrencyIsoCode = 'SGD';
            sb.Tax_Label__c = 'taxLabel';
            sb.Country__c = 'Singapore';
            sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
            insert sb;
           
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Singapore';
            agency.Subsidiary__c = sb.id;
            listAccount1.add(agency);
            
            Tax_Code__c taxcode = new Tax_Code__c();
            taxcode.Name = 'SG - 7% GST';
            taxcode.Tax_Rate__c =  7;
            taxcode.Country__c = 'Singapore';
            insert taxcode;
            
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
            //a.BillingState = 'test';
            a.Current_Subscription_Code__c = 'abc';
            a.Account_Rule_Code__c = 'test';
            a.AgentNet_ID__c = null;
            a.PersonEmail = '12121assas@yahoo.com';
            a.Country__c = 'Singapore';
            a.Status__c = 'Active';
            a.CEA_Salesperson_Number__c = 'E458652L';
            a.PersonBirthdate = system.today();
            a.Subsidiary__c = sb.id;
            a.Agency__c = agency.id;
            a.Mobile_Country__c = '65';
            a.External_Field__c = 'check';
            insert a;
            
            Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
            insert productClass;
            list<Product2>  prodList = new  list<Product2>();  
            Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
            insert prod;
            prodList.add(prod); 
            
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Proposal';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(30);
            opp.PG_Tenure__c = 4;
            opp.Total_Spending__c = 100;
            opp.ownerid = u.id;
            //opp.Agent_Accepted_Time__c = system.now();
            opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
            opp.Subsidiary__c = sb.id;
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
            opp.Payment_Type__c = 'Offline';
            
            Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =opp.RecordTypeId,
                                                                      Destination_Recordtype_Id__c =opp.RecordTypeId,active__c=true);
            insert sd1;
            //insert opp;
            opp.Payment_Time__c = system.now();
            opp.Approval_Status__c = 'OMC Approval Approved';
            opp.StageName = 'Pending OMC Approval';
            opp.Submit_to_OMC_Manually__c  = false;
            opp.Billing_Street_new__c = 'TestStreet';
            opp.Billing_Country_new__c = 'TestCoutry';
            opp.Billing_City_new__c = 'TestCity';
            //update opp;
            
            Field_Mapping__c fieldMap = new Field_Mapping__c();
            fieldMap.CurrencyIsoCode = 'SGD';
            fieldMap.isActive__c = True; 
            fieldMap.Search_Data__c = sd1.id;
            fieldMap.Instance_Name__c = 'Both';
            fieldMap.Label__c = 'Accountid';    
            fieldMap.from__c = 'Opportunity_Type__c';
            fieldMap.To__c = 'Opportunity_Type__c';
            fieldMap.Sequennce__c = 40;
            fieldMap.Related_List_Label__c = 'Account';
            fieldMap.related_Object_API__c = 'Account';
            fieldMap.DataType__c = 'Picklist'; 
            fieldMap.recordCreation__c = True;
            insert fieldMap;
            
              Search_and_tag_admin__c sd2 = new Search_and_tag_admin__c(Destination_Object_API__c ='Account',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Account',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =accRectype,
                                                                      Destination_Recordtype_Id__c =accRectype,active__c=true);
            insert sd2;
            
            
            list<Field_Mapping__c> fieldMaplist  = new list<Field_Mapping__c>();
            
            Field_Mapping__c fieldMapAcc = new Field_Mapping__c();
            fieldMapAcc.CurrencyIsoCode = 'SGD';
            fieldMapAcc.isActive__c = True; 
            fieldMapAcc.Search_Data__c = sd2.id;
            fieldMapAcc.Instance_Name__c = 'Both';
            fieldMapAcc.Label__c = 'Salutation';    
            fieldMapAcc.from__c = 'Salutation';
            fieldMapAcc.To__c = 'Salutation';
            fieldMapAcc.Sequennce__c = 20;
            fieldMapAcc.DataType__c = 'Text'; 
            fieldMapAcc.recordCreation__c = True;
            fieldMaplist.add(fieldMapAcc);
            
            
            Field_Mapping__c fieldMapAcc1 = new Field_Mapping__c();
            fieldMapAcc1.CurrencyIsoCode = 'MYR';
            fieldMapAcc1.isActive__c = True; 
            fieldMapAcc1.Search_Data__c = sd2.id;
            fieldMapAcc1.Instance_Name__c = 'both';
            fieldMapAcc1.Label__c = 'Phone';    
            fieldMapAcc1.from__c = 'PersonMobilePhone';
            fieldMapAcc1.To__c = 'PersonMobilePhone';
            fieldMapAcc1.Sequennce__c = 40; 
            fieldMapAcc1.DataType__c = 'text';
            fieldMapAcc1.recordCreation__c = True;
            fieldMaplist.add(fieldMapAcc1);
            
            Field_Mapping__c fieldMapAcc2 = new Field_Mapping__c();
            fieldMapAcc2.CurrencyIsoCode = 'MYR';
            fieldMapAcc2.isActive__c = True; 
            fieldMapAcc2.Search_Data__c = sd2.id;
            fieldMapAcc2.Instance_Name__c = 'Both';
            fieldMapAcc2.Label__c = 'Country';    
            fieldMapAcc2.from__c = 'Country__c';
            fieldMapAcc2.To__c = 'Country__c';
            fieldMapAcc2.Sequennce__c = 30;
            fieldMapAcc2.DataType__c = 'Text'; 
            fieldMapAcc2.recordCreation__c = True;
            
            fieldMaplist.add(fieldMapAcc2);
            
            Field_Mapping__c fieldMapAcc3 = new Field_Mapping__c();
            fieldMapAcc3.CurrencyIsoCode = 'MYR';
            fieldMapAcc3.isActive__c = True; 
            fieldMapAcc3.Search_Data__c = sd2.id;
            fieldMapAcc3.Instance_Name__c = 'iPP';
            fieldMapAcc3.Label__c = 'function';    
            fieldMapAcc3.from__c = 'function__pc';
            fieldMapAcc3.To__c = 'function__pc';
            fieldMapAcc3.Sequennce__c = 20;
            fieldMapAcc3.DataType__c = 'Text'; 
            fieldMapAcc3.recordCreation__c = True;
            
            fieldMaplist.add(fieldMapAcc3);
            
            Field_Mapping__c fieldMapAcc4 = new Field_Mapping__c();
            fieldMapAcc4.CurrencyIsoCode = 'MYR';
            fieldMapAcc4.isActive__c = True; 
            fieldMapAcc4.Search_Data__c = sd2.id;
            fieldMapAcc4.Instance_Name__c = 'Both';
            fieldMapAcc4.Label__c = 'Birthdate';    
            fieldMapAcc4.from__c = 'PersonBirthdate';
            fieldMapAcc4.To__c = 'PersonBirthdate';
            fieldMapAcc4.Sequennce__c = 20;
            fieldMapAcc4.DataType__c = 'Date'; 
            fieldMapAcc4.recordCreation__c = True;
            
            fieldMaplist.add(fieldMapAcc4);
            
            Field_Mapping__c fieldMapAcc5 = new Field_Mapping__c();
            fieldMapAcc5.CurrencyIsoCode = 'MYR';
            fieldMapAcc5.isActive__c = True; 
            fieldMapAcc5.Search_Data__c = sd2.id;
            fieldMapAcc5.Instance_Name__c = 'Both';
            fieldMapAcc5.Label__c = 'First Name';    
            fieldMapAcc5.from__c = 'FirstName';
            fieldMapAcc5.To__c = 'FirstName';
            fieldMapAcc5.Sequennce__c = 20;
            fieldMapAcc5.DataType__c = 'Text'; 
            fieldMapAcc5.recordCreation__c = True;
            
            
            fieldMaplist.add(fieldMapAcc5);
            
            Field_Mapping__c fieldMapAcc6 = new Field_Mapping__c();
            fieldMapAcc6.CurrencyIsoCode = 'MYR';
            fieldMapAcc6.isActive__c = True; 
            fieldMapAcc6.Search_Data__c = sd2.id;
            fieldMapAcc6.Instance_Name__c = 'Both';
            fieldMapAcc6.Label__c = 'Last Name';    
            fieldMapAcc6.from__c = 'LastName';
            fieldMapAcc6.To__c = 'LastName';
            fieldMapAcc6.Sequennce__c = 20;
            fieldMapAcc6.DataType__c = 'Text'; 
            fieldMapAcc6.recordCreation__c = True;
            
            
            fieldMaplist.add(fieldMapAcc6);
            
            
            Field_Mapping__c fieldMapAcc7 = new Field_Mapping__c();
            fieldMapAcc7.CurrencyIsoCode = 'MYR';
            fieldMapAcc7.isActive__c = True; 
            fieldMapAcc7.Search_Data__c = sd2.id;
            fieldMapAcc7.Instance_Name__c = 'iPP';
            fieldMapAcc7.Label__c = 'Position Type';    
            fieldMapAcc7.from__c = 'Position_Type__pc';
            fieldMapAcc7.To__c = 'Position_Type__pc';
            fieldMapAcc7.Sequennce__c = 20;
            fieldMapAcc7.DataType__c = 'Text'; 
            fieldMapAcc7.recordCreation__c = True;
            
            
            fieldMaplist.add(fieldMapAcc7);
            
            Field_Mapping__c fieldMapAcc8 = new Field_Mapping__c();
            fieldMapAcc8.CurrencyIsoCode = 'MYR';
            fieldMapAcc8.isActive__c = True; 
            fieldMapAcc8.Search_Data__c = sd2.id;
            fieldMapAcc8.Instance_Name__c = 'iPP';
            fieldMapAcc8.Label__c = 'Email';    
            fieldMapAcc8.from__c = 'PersonEmail';
            fieldMapAcc8.To__c = 'PersonEmail';
            fieldMapAcc8.Sequennce__c = 20;
            fieldMapAcc8.DataType__c = 'Text'; 
            fieldMapAcc8.recordCreation__c = True;
            
            
            fieldMaplist.add(fieldMapAcc8);
             Field_Mapping__c fieldMapAcc9 = new Field_Mapping__c();
            fieldMapAcc9.CurrencyIsoCode = 'MYR';
            fieldMapAcc9.isActive__c = True; 
            fieldMapAcc9.Search_Data__c = sd2.id;
            fieldMapAcc9.Instance_Name__c = 'Both';
            fieldMapAcc9.Label__c = 'Overlap_Agent';    
            fieldMapAcc9.from__c = 'Overlap_Agent__c';
            fieldMapAcc9.To__c = 'Overlap_Agent__c';
            fieldMapAcc9.Sequennce__c = 20;
            fieldMapAcc9.DataType__c = 'CheckBox'; 
            fieldMapAcc9.recordCreation__c = True;
            
            
            fieldMaplist.add(fieldMapAcc9);
           
             Field_Mapping__c fieldMapAcc10 = new Field_Mapping__c();
            fieldMapAcc10.CurrencyIsoCode = 'MYR';
            fieldMapAcc10.isActive__c = True; 
            fieldMapAcc10.Search_Data__c = sd2.id;
            fieldMapAcc10.Instance_Name__c = 'Both';
            fieldMapAcc10.Label__c = 'Brickz_Agent';    
            fieldMapAcc10.from__c = 'Brickz_Agent__c';
            fieldMapAcc10.To__c = 'Brickz_Agent__c';
            fieldMapAcc10.Sequennce__c = 20;
            fieldMapAcc10.DataType__c = 'CheckBox'; 
            fieldMapAcc10.recordCreation__c = True;
            
            
            fieldMaplist.add(fieldMapAcc10);
           
            
            insert fieldMaplist;
          
         
            Test.startTest();
            RestRequest req2 = new RestRequest(); 
            RestResponse res2 = new RestResponse();
            req2.requestURI = '/services/apexrest/api/createOpportunitiesAndQuotes/*';  //Request URL
            req2.httpMethod = 'post';//HTTP Request Type
            RestContext.request = req2;
            string JSONMsg1 = '{"StartDate":"2022-06-30","sObjName":"Account","sendResponse":[{"value":"test","label":"FirstName"},{"value":true,"label":"Brickz_Agent__c"},{"value":true,"label":"Overlap_Agent__c"},{"value":"test@testclass.com","label":"PersonEmail"},{"value":"test","label":"Position_Type__pc"},{"value":"2022-06-17","label":"PersonBirthdate"}],"prodList":["Test"],"objectId":"'+ opp.id +'","isOverlapping":true,"email":"damini.sinha@algoworks.com","desrecordtype":"'+ a.RecordTypeId +'","accountId":"'+ a.id +'"}';
            req2.requestBody = blob.valueOf(JSONMsg1);
            RestContext.response= res2;
            
            createOpportunitiesAPI.createOpportunities();
            Test.stopTest();
        }
    }
    
    @isTest
    public static void oppTestMethod3(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c PGTrigger =new Trigger_Execute__c();
            PGTrigger.Name='PGAccountTrigger';
            PGTrigger.Enable_del__c=true;
            insert PGTrigger;
            /* Trigger_Execute__c PGTriggerOpp =new Trigger_Execute__c();
PGTriggerOpp.Name='PGOpportunityTrigger';
PGTriggerOpp.Enable_del__c=true;
insert PGTriggerOpp;*/
            
            Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
            PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
            PGTriggerOppSplit.Enable_del__c=true;
            insert PGTriggerOppSplit;
            
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            User u = new User(Alias = 'gtest', Email='giantest@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='GianTest', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='giantest@testorg.com', Subsidiary__c='PropertyGuru Pte Ltd'
                             );
            
            insert u;
            //id subId = PGTestDataFactory.createSubsidiary().Id;
            subsidiary__c sb = new Subsidiary__c();
            sb.Name = thisuser.Subsidiary__c;
            sb.NS_Subsidiary_Internal_ID__c = '1';
            sb.CurrencyIsoCode = 'SGD';
            sb.Tax_Label__c = 'taxLabel';
            sb.Country__c = 'Singapore';
            sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
            insert sb;
            /*Subsidiary__c sb = new Subsidiary__c();
sb.Name = 'PropertyGuru Pte Ltd';
sb.NS_Subsidiary_Internal_ID__c = '1';
sb.CurrencyIsoCode = 'MYR';
sb.Tax_Label__c = 'taxLabel';
sb.Country__c = 'Malaysia';
sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
insert sb;*/
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Singapore';
            agency.Subsidiary__c = sb.id;
            listAccount1.add(agency);
            
            Tax_Code__c taxcode = new Tax_Code__c();
            taxcode.Name = 'SG - 7% GST';
            taxcode.Tax_Rate__c =  7;
            taxcode.Country__c = 'Singapore';
            insert taxcode;
            
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
            //a.BillingState = 'test';
            a.Current_Subscription_Code__c = 'abc';
            a.Account_Rule_Code__c = 'test';
            a.AgentNet_ID__c = '123';
            a.PersonEmail = '12121assas@yahoo.com';
            a.Country__c = 'Singapore';
            a.Status__c = 'Active';
            a.CEA_Salesperson_Number__c = 'E458652L';
            a.PersonBirthdate = system.today();
            a.Subsidiary__c = sb.id;
            a.Agency__c = agency.id;
            a.External_Field__c = null;
            a.Mobile_Country__c = '65';

            insert a;
            
            Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
            insert productClass;
            list<Product2>  prodList = new  list<Product2>();  
            Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
            insert prod;
            prodList.add(prod); 
            
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Proposal';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(30);
            opp.PG_Tenure__c = 4;
            opp.Total_Spending__c = 100;
            opp.ownerid = u.id;
            //opp.Agent_Accepted_Time__c = system.now();
            opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
            opp.Subsidiary__c = sb.id;
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
            opp.Payment_Type__c = 'Offline';
            
            Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =opp.RecordTypeId,
                                                                      Destination_Recordtype_Id__c =opp.RecordTypeId,active__c=true);
            insert sd1;
            //insert opp;
            opp.Payment_Time__c = system.now();
            opp.Approval_Status__c = 'OMC Approval Approved';
            opp.StageName = 'Pending OMC Approval';
            opp.Submit_to_OMC_Manually__c  = false;
            opp.Billing_Street_new__c = 'TestStreet';
            opp.Billing_Country_new__c = 'TestCoutry';
            opp.Billing_City_new__c = 'TestCity';
            //update opp;
            
            Field_Mapping__c fieldMap = new Field_Mapping__c();
            fieldMap.CurrencyIsoCode = 'SGD';
            fieldMap.isActive__c = True; 
            fieldMap.Search_Data__c = sd1.id;
            fieldMap.Instance_Name__c = 'Both';
            fieldMap.Label__c = 'Accountid';    
            fieldMap.from__c = 'Opportunity_Type__c';
            fieldMap.To__c = 'Opportunity_Type__c';
            fieldMap.Sequennce__c = 40;
            fieldMap.Related_List_Label__c = 'Account';
            fieldMap.related_Object_API__c = 'Account';
            fieldMap.DataType__c = 'Picklist'; 
            fieldMap.recordCreation__c = True;
            insert fieldMap;
            
            Field_Mapping__c fieldMap1 = new Field_Mapping__c();
            fieldMap1.CurrencyIsoCode = 'SGD';
            fieldMap1.isActive__c = True; 
            fieldMap1.Search_Data__c = sd1.id;
            fieldMap1.Instance_Name__c = 'Both';
            fieldMap1.Label__c = 'Close Date';    
            fieldMap1.from__c = 'CloseDate';
            fieldMap1.To__c = 'Opportunity_Type__c';
            fieldMap1.Sequennce__c = 50;
            fieldMap1.Related_List_Label__c = 'Account';
            fieldMap1.related_Object_API__c = 'Account';
            fieldMap1.DataType__c = 'Date'; 
            fieldMap1.recordCreation__c = True;
            insert fieldMap1;
            
              Search_and_tag_admin__c sd2 = new Search_and_tag_admin__c(Destination_Object_API__c ='Account',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Account',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =accRectype,
                                                                      Destination_Recordtype_Id__c =accRectype,active__c=true);
            insert sd2;
            
            
            list<Field_Mapping__c> fieldMaplist  = new list<Field_Mapping__c>();
            
            Field_Mapping__c fieldMapAcc = new Field_Mapping__c();
            fieldMapAcc.CurrencyIsoCode = 'SGD';
            fieldMapAcc.isActive__c = True; 
            fieldMapAcc.Search_Data__c = sd2.id;
            fieldMapAcc.Instance_Name__c = 'Both';
            fieldMapAcc.Label__c = 'Salutation';    
            fieldMapAcc.from__c = 'Salutation';
            fieldMapAcc.To__c = 'Salutation';
            fieldMapAcc.Sequennce__c = 20;
            fieldMapAcc.DataType__c = 'Text'; 
            fieldMapAcc.recordCreation__c = True;
            fieldMaplist.add(fieldMapAcc);
            
            
            Field_Mapping__c fieldMapAcc1 = new Field_Mapping__c();
            fieldMapAcc1.CurrencyIsoCode = 'MYR';
            fieldMapAcc1.isActive__c = True; 
            fieldMapAcc1.Search_Data__c = sd2.id;
            fieldMapAcc1.Instance_Name__c = 'both';
            fieldMapAcc1.Label__c = 'Phone';    
            fieldMapAcc1.from__c = 'PersonMobilePhone';
            fieldMapAcc1.To__c = 'PersonMobilePhone';
            fieldMapAcc1.Sequennce__c = 40; 
            fieldMapAcc1.DataType__c = 'text';
            fieldMapAcc1.recordCreation__c = True;
            fieldMaplist.add(fieldMapAcc1);
            
            Field_Mapping__c fieldMapAcc2 = new Field_Mapping__c();
            fieldMapAcc2.CurrencyIsoCode = 'MYR';
            fieldMapAcc2.isActive__c = True; 
            fieldMapAcc2.Search_Data__c = sd2.id;
            fieldMapAcc2.Instance_Name__c = 'Both';
            fieldMapAcc2.Label__c = 'Country';    
            fieldMapAcc2.from__c = 'Country__c';
            fieldMapAcc2.To__c = 'Country__c';
            fieldMapAcc2.Sequennce__c = 30;
            fieldMapAcc2.DataType__c = 'Text'; 
            fieldMapAcc2.recordCreation__c = True;
            
            fieldMaplist.add(fieldMapAcc2);
            
            Field_Mapping__c fieldMapAcc3 = new Field_Mapping__c();
            fieldMapAcc3.CurrencyIsoCode = 'MYR';
            fieldMapAcc3.isActive__c = True; 
            fieldMapAcc3.Search_Data__c = sd2.id;
            fieldMapAcc3.Instance_Name__c = 'iPP';
            fieldMapAcc3.Label__c = 'function';    
            fieldMapAcc3.from__c = 'function__pc';
            fieldMapAcc3.To__c = 'function__pc';
            fieldMapAcc3.Sequennce__c = 20;
            fieldMapAcc3.DataType__c = 'Text'; 
            fieldMapAcc3.recordCreation__c = True;
            
            fieldMaplist.add(fieldMapAcc3);
            
            Field_Mapping__c fieldMapAcc4 = new Field_Mapping__c();
            fieldMapAcc4.CurrencyIsoCode = 'MYR';
            fieldMapAcc4.isActive__c = True; 
            fieldMapAcc4.Search_Data__c = sd2.id;
            fieldMapAcc4.Instance_Name__c = 'Both';
            fieldMapAcc4.Label__c = 'Birthdate';    
            fieldMapAcc4.from__c = 'PersonBirthdate';
            fieldMapAcc4.To__c = 'PersonBirthdate';
            fieldMapAcc4.Sequennce__c = 20;
            fieldMapAcc4.DataType__c = 'Date'; 
            fieldMapAcc4.recordCreation__c = True;
            
            fieldMaplist.add(fieldMapAcc4);
            
            Field_Mapping__c fieldMapAcc5 = new Field_Mapping__c();
            fieldMapAcc5.CurrencyIsoCode = 'MYR';
            fieldMapAcc5.isActive__c = True; 
            fieldMapAcc5.Search_Data__c = sd2.id;
            fieldMapAcc5.Instance_Name__c = 'Both';
            fieldMapAcc5.Label__c = 'First Name';    
            fieldMapAcc5.from__c = 'FirstName';
            fieldMapAcc5.To__c = 'FirstName';
            fieldMapAcc5.Sequennce__c = 20;
            fieldMapAcc5.DataType__c = 'Text'; 
            fieldMapAcc5.recordCreation__c = True;
            
            
            fieldMaplist.add(fieldMapAcc5);
            
            Field_Mapping__c fieldMapAcc6 = new Field_Mapping__c();
            fieldMapAcc6.CurrencyIsoCode = 'MYR';
            fieldMapAcc6.isActive__c = True; 
            fieldMapAcc6.Search_Data__c = sd2.id;
            fieldMapAcc6.Instance_Name__c = 'Both';
            fieldMapAcc6.Label__c = 'Last Name';    
            fieldMapAcc6.from__c = 'LastName';
            fieldMapAcc6.To__c = 'LastName';
            fieldMapAcc6.Sequennce__c = 20;
            fieldMapAcc6.DataType__c = 'Text'; 
            fieldMapAcc6.recordCreation__c = True;
            
            
            fieldMaplist.add(fieldMapAcc6);
            
            
            Field_Mapping__c fieldMapAcc7 = new Field_Mapping__c();
            fieldMapAcc7.CurrencyIsoCode = 'MYR';
            fieldMapAcc7.isActive__c = True; 
            fieldMapAcc7.Search_Data__c = sd2.id;
            fieldMapAcc7.Instance_Name__c = 'iPP';
            fieldMapAcc7.Label__c = 'Position Type';    
            fieldMapAcc7.from__c = 'Position_Type__pc';
            fieldMapAcc7.To__c = 'Position_Type__pc';
            fieldMapAcc7.Sequennce__c = 20;
            fieldMapAcc7.DataType__c = 'Text'; 
            fieldMapAcc7.recordCreation__c = True;
            
            
            fieldMaplist.add(fieldMapAcc7);
            
            Field_Mapping__c fieldMapAcc8 = new Field_Mapping__c();
            fieldMapAcc8.CurrencyIsoCode = 'MYR';
            fieldMapAcc8.isActive__c = True; 
            fieldMapAcc8.Search_Data__c = sd2.id;
            fieldMapAcc8.Instance_Name__c = 'iPP';
            fieldMapAcc8.Label__c = 'Email';    
            fieldMapAcc8.from__c = 'PersonEmail';
            fieldMapAcc8.To__c = 'PersonEmail';
            fieldMapAcc8.Sequennce__c = 20;
            fieldMapAcc8.DataType__c = 'Text'; 
            fieldMapAcc8.recordCreation__c = True;
            
            
            fieldMaplist.add(fieldMapAcc8);
            
            insert fieldMaplist;
          
            
            
            Test.startTest();
            RestRequest req2 = new RestRequest(); 
            RestResponse res2 = new RestResponse();
            req2.requestURI = '/services/apexrest/api/createOpportunitiesAndQuotes/*';  //Request URL
            req2.httpMethod = 'post';//HTTP Request Type
            RestContext.request = req2;
            string JSONMsg1 = '{"StartDate":"2022-06-30","sObjName":"Account","sendResponse":[{"value":"test","label":"Name"},{"value":"New","label":"StageName"},{"value":"B2C - Standard","label":"Opportunity_Type__c"},{"value":"2022-06-17","label":"CloseDate"}],"prodList":["Test"],"objectId":"'+ opp.id +'","isOverlapping":false,"email":"damini.sinha@algoworks.com","desrecordtype":"'+ a.RecordTypeId +'","accountId":"'+ a.id +'"}';
            req2.requestBody = blob.valueOf(JSONMsg1);
            RestContext.response= res2;
            
            createOpportunitiesAPI.createOpportunities();
            Test.stopTest();
        }
    }
    @isTest
    public static void oppTestMethod4(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c PGTrigger =new Trigger_Execute__c();
            PGTrigger.Name='PGAccountTrigger';
            PGTrigger.Enable_del__c=true;
            insert PGTrigger;
            
            Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
            PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
            PGTriggerOppSplit.Enable_del__c=true;
            insert PGTriggerOppSplit;
            
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            User u = new User(Alias = 'gtest', Email='damini.sinha@algoworks.com',
                              EmailEncodingKey='UTF-8', LastName='GianTest', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='giantest@testorg.com', Subsidiary__c='PropertyGuru Pte Ltd'
                             );
            
            insert u;
            //id subId = PGTestDataFactory.createSubsidiary().Id;
            subsidiary__c sb = new Subsidiary__c();
            sb.Name = thisuser.Subsidiary__c;
            sb.NS_Subsidiary_Internal_ID__c = '1';
            sb.CurrencyIsoCode = 'SGD';
            sb.Tax_Label__c = 'taxLabel';
            sb.Country__c = 'Singapore';
            sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
            insert sb;
            
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Singapore';
            agency.Subsidiary__c = sb.id;
            listAccount1.add(agency);
            
            Tax_Code__c taxcode = new Tax_Code__c();
            taxcode.Name = 'SG - 7% GST';
            taxcode.Tax_Rate__c =  7;
            taxcode.Country__c = 'Singapore';
            insert taxcode;
            
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
            //a.BillingState = 'test';
            a.Current_Subscription_Code__c = 'abc';
            a.Account_Rule_Code__c = 'test';
            a.AgentNet_ID__c = '123';
            a.PersonEmail = '12121assas@yahoo.com';
            a.Country__c = 'Singapore';
            a.Status__c = 'Active';
            a.CEA_Salesperson_Number__c = 'E458652L';
            a.PersonBirthdate = system.today();
            a.Mobile_Country__c = '65';
            a.Subsidiary__c = sb.id;
            a.Agency__c = agency.id;
            a.External_Field__c = null;
            insert a;
            
            Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
            insert productClass;
            list<Product2>  prodList = new  list<Product2>();  
            Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
            insert prod;
            prodList.add(prod); 
            
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Proposal';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(30);
            opp.PG_Tenure__c = 4;
            opp.Total_Spending__c = 100;
            opp.ownerid = u.id;
            //opp.Agent_Accepted_Time__c = system.now();
            opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
            opp.Subsidiary__c = sb.id;
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
            opp.Payment_Type__c = 'Offline';
            
            Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =opp.RecordTypeId,
                                                                      Destination_Recordtype_Id__c =opp.RecordTypeId,active__c=true);
            insert sd1;
            //insert opp;
            opp.Payment_Time__c = system.now();
            opp.Approval_Status__c = 'OMC Approval Approved';
            opp.StageName = 'Pending OMC Approval';
            opp.Submit_to_OMC_Manually__c  = false;
            opp.Billing_Street_new__c = 'TestStreet';
            opp.Billing_Country_new__c = 'TestCoutry';
            opp.Billing_City_new__c = 'TestCity';
            //update opp;
           
            Test.startTest();
            RestRequest req2 = new RestRequest(); 
            RestResponse res2 = new RestResponse();
            req2.requestURI = '/services/apexrest/api/createOpportunitiesAndQuotes/*';  //Request URL
            req2.httpMethod = 'post';//HTTP Request Type
            RestContext.request = req2;
            string JSONMsg1 = '{"StartDate":"2022-06-30","sObjName":"Opportunity","sendResponse":[{"value":"test","label":"Name"},{"value":"New","label":"StageName"},{"value":"B2C - Standard","label":"Opportunity_Type__c"},{"value":"2022-06-17","label":"CloseDate"}],"prodList":["Test"],"objectId":"'+ opp.id +'","isOverlapping":null,"email":"damini.sinha@algoworks.com","desrecordtype":"'+ a.RecordTypeId +'","accountId":null}';
            req2.requestBody = blob.valueOf(JSONMsg1);
            RestContext.response= res2;
            
            createOpportunitiesAPI.createOpportunities();
            Test.stopTest();
        }
    }
    
    @isTest
    public static void oppTestMethod5(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c PGTrigger =new Trigger_Execute__c();
            PGTrigger.Name='PGAccountTrigger';
            PGTrigger.Enable_del__c=true;
            insert PGTrigger;
            
            Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
            PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
            PGTriggerOppSplit.Enable_del__c=true;
            insert PGTriggerOppSplit;
            
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            User u = new User(Alias = 'gtest', Email='damini.sinha@algoworks.com',
                              EmailEncodingKey='UTF-8', LastName='GianTest', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='giantest@testorg.com', Subsidiary__c='PropertyGuru Pte Ltd'
                             );
            
            insert u;
            //id subId = PGTestDataFactory.createSubsidiary().Id;
            subsidiary__c sb = new Subsidiary__c();
            sb.Name = thisuser.Subsidiary__c;
            sb.NS_Subsidiary_Internal_ID__c = '1';
            sb.CurrencyIsoCode = 'SGD';
            sb.Tax_Label__c = 'taxLabel';
            sb.Country__c = 'Singapore';
            sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
            insert sb;
            
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Singapore';
            agency.Subsidiary__c = sb.id;
            listAccount1.add(agency);
            
            Tax_Code__c taxcode = new Tax_Code__c();
            taxcode.Name = 'SG - 7% GST';
            taxcode.Tax_Rate__c =  7;
            taxcode.Country__c = 'Singapore';
            insert taxcode;
            
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
            
            string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
            Account a = new Account();
            a.RecordTypeId = accRectype;
            a.LastName = 'TestYuni1';
            a.salutation = 'Mr.';
            a.FirstName = 'abd';
            a.CurrencyIsoCode = 'SGD';
            a.Subscription_Start_Date__c = system.today().addMonths(-10);
            a.BillingStreet = 'test1';
            a.BillingCity = 'test1';
            a.BillingCountry = 'Singapore';
            a.BillingPostalCode = '83735';
            //a.BillingState = 'test';
            a.Current_Subscription_Code__c = 'abd';
            a.Account_Rule_Code__c = 'test1';
            a.AgentNet_ID__c = '12';
            a.PersonEmail = '12assas@yahoo.com';
            a.Country__c = 'Singapore';
            a.Status__c = 'Active';
            a.CEA_Salesperson_Number__c = 'E458682L';
            a.PersonBirthdate = system.today();
            a.Mobile_Country__c = '65';
            a.Subsidiary__c = sb.id;
            a.Agency__c = agency.id;
            a.External_Field__c = 'Check';
            a.Test_Account__c = False;
            a.NetSuite_Id__c = 'test';
            insert a;
            
            Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
            insert productClass;
            list<Product2>  prodList = new  list<Product2>();  
            Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
            insert prod;
            prodList.add(prod); 
            
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Proposal';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(30);
            opp.PG_Tenure__c = 4;
            opp.Total_Spending__c = 100;
            opp.ownerid = u.id;
            //opp.Agent_Accepted_Time__c = system.now();
            opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
            opp.Subsidiary__c = sb.id;
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
            opp.Payment_Type__c = 'Offline';
            
            Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =opp.RecordTypeId,
                                                                      Destination_Recordtype_Id__c =opp.RecordTypeId,active__c=true);
            insert sd1;
            //insert opp;
            opp.Payment_Time__c = system.now();
            opp.Approval_Status__c = 'OMC Approval Approved';
            opp.StageName = 'Pending OMC Approval';
            opp.Submit_to_OMC_Manually__c  = false;
            opp.Billing_Street_new__c = 'TestStreet';
            opp.Billing_Country_new__c = 'TestCoutry';
            opp.Billing_City_new__c = 'TestCity';
            //update opp;
           
            Test.startTest();
            RestRequest req2 = new RestRequest(); 
            RestResponse res2 = new RestResponse();
            req2.requestURI = '/services/apexrest/api/createOpportunitiesAndQuotes/*';  //Request URL
            req2.httpMethod = 'post';//HTTP Request Type
            RestContext.request = req2;
            string JSONMsg1 = '{"StartDate":"2022-06-30","sObjName":"Opportunity","sendResponse":[{"value":"test","label":"Name"},{"value":"New","label":"StageName"},{"value":"B2C - Standard","label":"Opportunity_Type__c"},{"value":"2022-06-17","label":"CloseDate"}],"prodList":["Test"],"objectId":"'+ opp.id +'","isOverlapping":null,"email":"damini.sinha@algoworks.com","desrecordtype":"'+ a.RecordTypeId +'","accountId":"'+ a.id +'"}';
            req2.requestBody = blob.valueOf(JSONMsg1);
            RestContext.response= res2;
            
            createOpportunitiesAPI.createOpportunities();
            Test.stopTest();
        }
    }
}
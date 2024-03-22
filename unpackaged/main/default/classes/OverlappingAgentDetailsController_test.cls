@isTest
public class OverlappingAgentDetailsController_test {
    @isTest
    public static void showRecordDetails(){
           String oppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='syncorg@m.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',country ='Malaysia', 
            LocaleSidKey='en_US', ProfileId = p.Id, Subsidiary__c ='PropertyGuru International (Malaysia) Sdn Bhd',
            TimeZoneSidKey='America/Los_Angeles', UserName='syncorg@m.com');
      insert u;
        System.runAs(u){
        
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='QuoteLineItemTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        Trigger_Execute__c QuoteTrigger =new Trigger_Execute__c();
        QuoteTrigger.Name='Trigger_Quote';
        QuoteTrigger.Enable_del__c=true;
        insert QuoteTrigger;
            
        
        subsidiary__c sb = new Subsidiary__c();
        sb.Name = u.Subsidiary__c;
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Malaysia';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();  
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Malaysia';
        insert taxcode;
        
       // id subId = PGTestDataFactory.createSubsidiary().Id;
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Malaysia';
            agency.Subsidiary__c = sb.Id;
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
        a.BillingCountry = 'Malaysia';
        a.BillingPostalCode = '83173';
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.account_rule_code__c = 'Standard';
        a.personemail = 'asd131sfaa@yaho.com';
        a.salutation = 'Mr.';
        a.firstname = 'aaaa';
        a.Country__c = 'Malaysia';
        a.Status__c = 'Active';
        a.NetSuite_Id__c = '6777';
        a.CEA_Salesperson_Number__c = 'W567653H';
        a.External_field__c = '867685777';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        
        insert a;
       
            
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.PG_Tenure__c = 4;
        opp.Opportunity_Type__c='B2C - Standard';
        //opp.Stinger__c=true;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = true;
        opp.CurrencyIsoCode = 'MYR';
            
            insert opp;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.Id,  IsActive = true, CurrencyIsoCode = 'MYR');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'MYR');
        insert productClass;
        
        list<String> prodskucode = new list<String>();
        list<String> listChildProdWithSeqNo = new list<String>();
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'MYR',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
        insert prod;
        listChildProdWithSeqNo.add(prod.id);
        prodskucode.add(prod.SKU_Code__c);  
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'MYR',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        Map<Id,PricebookEntry> mapOfProductWithPbe = new Map<Id,PricebookEntry>();
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'MYR', useStandardPrice = false);
        insert pbe1;
        mapOfProductWithPbe.put(pbe1.id,pbe1);
        list<PricebookEntry> childPriceBookEntry = new list<PricebookEntry>();
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'MYR', useStandardPrice = false);
        insert pbe2;
        childPriceBookEntry.add(pbe2);
        
        string sbName = system.label.MY_SUBSIDIARY_NAME;
        system.debug('sbName@@'+sbName);
        //Subsidiary__c sb = [select id,Name from Subsidiary__c where Name =:string.(valueOf(system.label.MY_SUBSIDIARY_NAME))];
        
         Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =oppRecType,
                                                                      Destination_Recordtype_Id__c =oppRecType,active__c=true);
        insert sd1;
              list<Field_Mapping__c> fieldMaplist = new list<Field_Mapping__c>();
            
           Field_Mapping__c fieldMap = new Field_Mapping__c();
            fieldMap.CurrencyIsoCode = 'SGD';
            fieldMap.isActive__c = True; 
            fieldMap.Search_Data__c = sd1.id;
            fieldMap.Instance_Name__c = 'Both';
            fieldMap.Label__c = 'Opportunity Type';    
            fieldMap.from__c = 'Opportunity_Type__c';
            fieldMap.To__c = 'Opportunity_Type__c';
            fieldMap.Sequennce__c = 20;
            fieldMap.DataType__c = 'Picklist'; 
            fieldMap.Agent_Display__c = True;
            fieldMaplist.add(fieldMap);
            
            
        Field_Mapping__c fieldMap1 = new Field_Mapping__c();
        fieldMap1.CurrencyIsoCode = 'SGD';
        fieldMap1.isActive__c = True; 
        fieldMap1.Search_Data__c = sd1.id;
        fieldMap1.Instance_Name__c = 'both';
        fieldMap1.Label__c = 'Name';    
        fieldMap1.from__c = 'Name';
        fieldMap1.To__c = 'Name';
        fieldMap1.Sequennce__c = 40; 
        fieldMap1.DataType__c = 'text';
        fieldMap1.Agent_Display__c = True;
           fieldMaplist.add(fieldMap1);
            
         Field_Mapping__c fieldMap2 = new Field_Mapping__c();
            fieldMap2.CurrencyIsoCode = 'SGD';
            fieldMap2.isActive__c = True; 
            fieldMap2.Search_Data__c = sd1.id;
            fieldMap2.Instance_Name__c = 'Both';
            fieldMap2.Label__c = 'Account';    
            fieldMap2.from__c = 'AccountId';
            fieldMap2.To__c = 'AccountId';
            fieldMap2.Sequennce__c = 30;
            fieldMap2.related_Object_API__c = 'Account';
            fieldMap2.DataType__c = 'Text'; 
            fieldMap2.Agent_Display__c = True;
            
            fieldMaplist.add(fieldMap2);
            
             Field_Mapping__c fieldMap3 = new Field_Mapping__c();
            fieldMap3.CurrencyIsoCode = 'SGD';
            fieldMap3.isActive__c = True; 
            fieldMap3.Search_Data__c = sd1.id;
            fieldMap3.Instance_Name__c = 'iPP';
            fieldMap3.Label__c = 'Priority';    
            fieldMap3.from__c = 'Priority__c';
            fieldMap3.To__c = 'Priority__c';
            fieldMap3.Sequennce__c = 20;
            fieldMap3.DataType__c = 'Text'; 
            fieldMap3.Agent_Display__c = True;
            
            fieldMaplist.add(fieldMap3);
            
             Field_Mapping__c fieldMap4 = new Field_Mapping__c();
            fieldMap4.CurrencyIsoCode = 'SGD';
            fieldMap4.isActive__c = True; 
            fieldMap4.Search_Data__c = sd1.id;
            fieldMap4.Instance_Name__c = 'Both';
            fieldMap4.Label__c = 'Close Date';    
            fieldMap4.from__c = 'CloseDate';
            fieldMap4.To__c = 'CloseDate';
            fieldMap4.Sequennce__c = 20;
            fieldMap4.DataType__c = 'Date'; 
            fieldMap4.Agent_Display__c = True;
            
            fieldMaplist.add(fieldMap4);
            
             Field_Mapping__c fieldMap5 = new Field_Mapping__c();
            fieldMap5.CurrencyIsoCode = 'SGD';
            fieldMap5.isActive__c = True; 
            fieldMap5.Search_Data__c = sd1.id;
            fieldMap5.Instance_Name__c = 'Both';
            fieldMap5.Label__c = 'Stage Name';    
            fieldMap5.from__c = 'StageName';
            fieldMap5.To__c = 'StageName';
            fieldMap5.Sequennce__c = 20;
            fieldMap5.DataType__c = 'Text'; 
            fieldMap5.Agent_Display__c = True;
            
        
             fieldMaplist.add(fieldMap5);
   
             Search_and_tag_admin__c sd2 = new Search_and_tag_admin__c(Destination_Object_API__c ='Account',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Account',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =accRectype,
                                                                      Destination_Recordtype_Id__c =accRectype,active__c=true);
        insert sd2;
             
          
             
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
            fieldMapAcc.Agent_Display__c = True;
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
            fieldMapAcc2.Agent_Display__c = True;
            
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
            fieldMapAcc3.Agent_Display__c = True;
            
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
            fieldMapAcc4.Agent_Display__c = True;
            
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
            fieldMapAcc5.Agent_Display__c = True;
            
        
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
            fieldMapAcc6.Agent_Display__c = True;
            
        
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
            fieldMapAcc7.Agent_Display__c = True;
            
        
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
            fieldMapAcc8.Agent_Display__c = True;
            
        
             fieldMaplist.add(fieldMapAcc8);
        
       
        
       insert fieldMaplist;
        Item_Bundle__c bundle = new Item_Bundle__c();
        bundle.Qty__c = 3;
        bundle.Parent_Product__c = pbe1.Product2Id;
        bundle.Child_Product__c = pbe1.Product2Id;
        bundle.SNo__c = 1.02;
        insert bundle;
          
        Test.startTest();
            
       
        OverlappingAgentDetailsApexController.fetchRecords(a.id);  
        OverlappingAgentDetailsApexController.fetchRecords(opp.id);  
 
        
        
        Test.stopTest();
     }
    }
}
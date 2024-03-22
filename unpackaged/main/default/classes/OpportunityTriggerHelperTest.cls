@isTest
public class OpportunityTriggerHelperTest {
        
    @isTest
    public static void changeCampaignMemberStatus(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
/*            
        Trigger_Execute__c t =new Trigger_Execute__c();
        t.Name='PGCampMemberTrigger';
        t.Enable_del__c=true;
        insert t;
            
        Trigger_Execute__c e =new Trigger_Execute__c();
        e.Name='PGCampaignEligibilityTrigger';
        e.Enable_del__c=true;
        insert e;
 */ /*           
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
 */           
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
 //          Test.startTest(); 
            Subsidiary__c sb1 = new Subsidiary__c();
            sb1.Name = 'IProperty.com Malaysia Sdn Bhd';
            sb1.NS_Subsidiary_Internal_ID__c = '2';
            sb1.CurrencyIsoCode = 'MYR';
            sb1.Tax_Label__c = 'taxLabel';
            sb1.Country__c = 'Malaysia';
            sb1.Subsidiary_Code__c = 'iPP';
           // sb1.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
          //  insert sb1;
       
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
            
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
       //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'A212312B';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
             a.mobile_country__c='60';
        insert a;
            
       /* Account a1 = new Account();
        a1.RecordTypeId = b2baccRectype;
        a1.Name = 'Acc PgToiPP';
        a1.Customer_Type__c = 'Developer';
        a1.Email__c = 'test@gmail.com';
        a1.Mobile__c = '2345';
        a1.Phone = '2345';
        a1.Country__c = 'Malaysia';
        a1.B2B_ipp_REA__c = null;
        a1.B2B_external_Field__c = null;    
        insert a1; */  
            
        Account acc = new Account();
        acc.RecordTypeId = b2baccRectype;
        acc.Name = 'Acc PgToiPP-02';
        acc.Customer_Type__c = 'Developer';

        acc.Phone = '993250';
        acc.Country__c = 'Thailand';
        acc.B2B_ipp_REA__c = null;
        acc.B2B_external_Field__c = null;    
        insert acc;       
         
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'PGSG Prime Credit', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
   
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Pending Online payment';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.Order_Type_Clone__c   = 'Contract - Renewal';
        opp.Opportunity_Type__c='B2C - Renewal';
        insert opp;
            
            Opportunity opp1 = new opportunity();
            opp1.Name = 'Oppo PgToiPP';
            opp1.StageName = 'Prospecting';
            opp1.AccountId = acc.id;
            opp1.CloseDate = system.today().AddDays(30);
            opp1.RecordTypeId = b2boppRectype;
            opp1.Subsidiary_Type__c = 'iPP';
            opp1.Product_Category__c = 'Awards';
            opp1.Subsidiary__c = sb1.Id;
            insert opp1;
                   
        
        opportunityList.add(opp);
            
        Search_and_tag_admin__c sd2 = new Search_and_tag_admin__c(Destination_Object_API__c ='Account',Client__c='Demo',ClientID__c='Demo',
                                                                      Source_Object_API__c ='Account',UserName__c='Demo',password__c='Demo',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='Demo.com',Source_RecordTypeID__c =b2baccRectype,
                                                                      Destination_Recordtype_Id__c =b2baccRectype,active__c=true);
        insert sd2;
            
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.EndDate = system.today().addDays(-2);
        insert cma;
/*        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
         
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = con.Id;
        cmp.Status = 'Responded';
        cmp.CampaignId = cma.Id;
        insert cmp;
 */     
        Test.startTest();
        String modeId = [SELECT Id, DeveloperName FROM CampaignInfluenceModel where DeveloperName = 'primaryModel'].Id;
        CampaignInfluence cmi = new CampaignInfluence();
        cmi.CampaignId = cma.Id;
        cmi.OpportunityId = opp.Id;
        cmi.ModelId = modeId;
        insert cmi;
 /*       
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;
        
        Promo_Mechanic__c prm = new Promo_Mechanic__c();
        prm.Name = 'TestName';
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Usage__c = 1;
        insert prm;
        
        Promo_Mechanic__c prm1 = new Promo_Mechanic__c();
        prm1.Name = 'TestName1';
        prm1.Eligible_Product__c = prod.Id;
        prm1.Campaign_Eligibility__c = ce1.Id;
        prm1.Usage__c = 1;
        insert prm1;
        
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Promo_Mechanic_Id__c = prm.Id;
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        oli.UnitPrice = 2;
        insert oli;
        listOppLine.add(oli);
        
        opportunityLineItem oli2 = new opportunityLineItem();
        oli2.Product2Id = prod2.Id;
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Promo_Mechanic_Id__c = prm1.Id;
        oli2.Amount_Despite_VIP__c = 2.3;
        oli2.Pro_Rate_Amount__c = 2;
        oli2.UnitPrice = 2;
        insert oli2;
*/        
           
        Map<Id,Opportunity> newMap = new Map<Id,Opportunity>();
        newMap.put(opp.Id,opp);
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
        oldMap.put(opp.Id,opp);
        
       // Test.startTest();
        opportunityList[0].Approval_Status__c = 'OMC Approval Approved';
        opportunityList[0].stageName = 'Closed Won';
        PGOpportunityTriggerHandler.isFirstTime = true;
        Update opportunityList;
        
        PGOpportunityTriggerHandler.changeCampaignMemberStatus(opportunityList, oldMap);
        oldMap.get(opp.Id).stageName = 'Proposal';
        PGOpportunityTriggerHandler.updatePgTenureBonus(opportunityList,oldMap);
        PGOpportunityTriggerHandler.changeCampaignMemberStatus(opportunityList, oldMap);
        PGOpportunityTriggerHandler.createCampaignInfluenceRecords(opportunityList,oldMap);
       // opportunityTriggerHelper.createOpportunityiPP(opportunityList);
        
        id runningUser1 = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1].id;
        //Task Creation
        Task taskObj = new Task();
        taskObj.Subject = 'Followup VIP Package';
        taskObj.OwnerId = runningUser1;
        taskobj.WhatId = opp.Id;
        taskObj.Status = 'Open';

        PGOpportunityTriggerHandler.closeTaskStatus(opportunityList,oldMap);
        CampaignInfluence cmi1 = new CampaignInfluence();
        cmi1.CampaignId = cma.Id;
        cmi1.OpportunityId = opp.Id;
        cmi1.ModelId = modeId;
        //insert cmi;
        system.enqueueJob(new createCampaignInfluenceClass(new list<Campaigninfluence>{cmi1}));
        Test.stopTest();
        }
    
    }
    
       
    @istest
    public static void deleteopp(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c t =new Trigger_Execute__c();
        t.Name='PGCampMemberTrigger';
        t.Enable_del__c=true;
        insert t;
        
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Integration Profile' LIMIT 1];
        user u = new user(LastName = 'test',
                          FirstName='integration',
                          Alias = 'jliv',
                          Email = 'test.integration@asdf.com',
                          Username = 'test.integration@asdf.com',
                          ProfileId = profileId.id,
                          EmailEncodingKey='UTF-8',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          TimeZoneSidKey='America/Los_Angeles'
                         );
        insert u;
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        string oppRectype_B2B = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
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
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'A212312B';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
            a.mobile_country__c='60';
        insert a;
        
        system.runAS(u){
            User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
            runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
            update runningUser;
            
            Subsidiary__c sb = new Subsidiary__c();
            sb.Name = 'PropertyGuru Pte Ltd';
            sb.NS_Subsidiary_Internal_ID__c = '1';
            sb.CurrencyIsoCode = 'SGD';
            sb.Tax_Label__c = 'taxLabel';
            sb.Country__c = 'Singapore';
            sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
            insert sb;
            
            List<Opportunity> opportunityList = new List<Opportunity>();
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Closed Won';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(30);
            opp.Subsidiary__c = sb.id;
            opp.Total_Spending__c = 100;
            opp.RecordTypeId = oppRectype;
            opp.PG_Tenure__c = 1;
            opp.OMC_Approved_Date__c = system.today();
            opp.Order_Type_Clone__c   = 'Contract - Renewal';
            // opportunityList.add(opp);
            
            Opportunity opp1 = new opportunity();
            opp1.Name = 'Test Opp';
            opp1.StageName = 'Prospecting';
            opp1.AccountId = a.id;
            opp1.CloseDate = system.today().AddDays(30);
            opp1.Subsidiary__c = sb.id;
            opp.Total_Spending__c = 100;
            opp1.RecordTypeId = oppRectype_B2B;
            opp1.PG_Tenure__c = 1;
            opp1.Order_Type_Clone__c   = 'Contract - Renewal';
            
          //  opportunityList.add(opp1);
            try{
                insert opportunityList;
            }catch(Exception exp){}
            test.startTest();
            
            system.debug('userinfo.id_test'+UserInfo.getProfileId());
            try{
                delete opportunityList; 
            }
            catch(Exception e){
                
            }   
            
            PGOpportunityTriggerHandler.updateAccountnextSubsDate(opp,opp1);
        	
            test.stopTest();
        }
        }
    }
    
    @isTest
    public static void changeCampaignMemberStatus1(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Malaysia' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
            
        Trigger_Execute__c t =new Trigger_Execute__c();
        t.Name='PGCampMemberTrigger';
        t.Enable_del__c=true;
        insert t;
        Trigger_Execute__c e =new Trigger_Execute__c();
        e.Name='PGCampaignEligibilityTrigger';
        e.Enable_del__c=true;
        insert e;
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGOpportunityTrigger';
        TE.Enable_del__c = true;
        insert TE;
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru International (Malaysia) Sdn Bhd';
        update runningUser;
        
         PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru International (Malaysia) Sdn Bhd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'MYR';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Malaysia';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'MY - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Malaysia';
        insert taxcode;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYunii';
        a.LastName = 'TestYunii';
        a.AgentNet_ID__c = 'AgentNet_ID__c test1';
        a.Salutation = 'Mrs.';
        a.CurrencyIsoCode = 'MYR';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'testt';
        a.BillingCity = 'testt';
        a.BillingCountry = 'Malaysia';
        a.BillingPostalCode = '83735';
       //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abd';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'testt';
        a.Previous_Account_Rule__c = 'testt';
        a.Status__c = 'Active';
        a.Country__c = 'Malaysia';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'A242312B';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        a.Subsidiary__c = sb.id;
             a.mobile_country__c='60';
       // a.Subsidiary_Type__c = 'MPD';
        insert a;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'MYR');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'MYR');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'MYR',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'MYR',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'MYR', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'MYR', useStandardPrice = false);
        insert pbe2;
         
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.Order_Type_Clone__c   = 'Contract - Renewal';
            opp.opportunity_type__c='B2C - Renewal';
        insert opp;
        
        opportunityList.add(opp);
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Malaysia';
        cma.IsActive = true;
        cma.EndDate = system.today().addDays(-2);
        cma.CurrencyIsoCode = 'MYR';
        insert cma;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = con.Id;
        cmp.Status = 'Responded';
        cmp.CampaignId = cma.Id;
        insert cmp;
        Test.startTest();
        String modeId = [SELECT Id, DeveloperName FROM CampaignInfluenceModel where DeveloperName = 'primaryModel'].Id;
        CampaignInfluence cmi = new CampaignInfluence();
        cmi.CampaignId = cma.Id;
        cmi.OpportunityId = opp.Id;
        cmi.ModelId = modeId;
        insert cmi;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;
        
        Promo_Mechanic__c prm = new Promo_Mechanic__c();
        prm.Name = 'TestName';
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Usage__c = 1;
        insert prm;
        
        Promo_Mechanic__c prm1 = new Promo_Mechanic__c();
        prm1.Name = 'TestName1';
        prm1.Eligible_Product__c = prod.Id;
        prm1.Campaign_Eligibility__c = ce1.Id;
        prm1.Usage__c = 1;
        insert prm1;
        
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Promo_Mechanic_Id__c = prm.Id;
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        oli.UnitPrice = 2;
        insert oli;
        listOppLine.add(oli);
        
        opportunityLineItem oli2 = new opportunityLineItem();
        oli2.Product2Id = prod2.Id;
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Promo_Mechanic_Id__c = prm1.Id;
        oli2.Amount_Despite_VIP__c = 2.3;
        oli2.Pro_Rate_Amount__c = 2;
        oli2.UnitPrice = 2;
        insert oli2;
            
            Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =opp.RecordTypeId,
                                                                      Destination_Recordtype_Id__c =opp.RecordTypeId,active__c=true);
            insert sd1;
        
        Map<Id,Opportunity> newMap = new Map<Id,Opportunity>();
        newMap.put(opp.Id,opp);
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
        oldMap.put(opp.Id,opp);
        
      //  Test.startTest();
        opportunityList[0].Approval_Status__c = 'OMC Approval Approved';
        opportunityList[0].stageName = 'Closed Won';
        PGOpportunityTriggerHandler.isFirstTime = true;
        Update opportunityList;
        
        PGOpportunityTriggerHandler.changeCampaignMemberStatus(opportunityList, oldMap);
        oldMap.get(opp.Id).stageName = 'Proposal';
        PGOpportunityTriggerHandler.updatePgTenureBonus(opportunityList,oldMap);
        PGOpportunityTriggerHandler.changeCampaignMemberStatus(opportunityList, oldMap);
        PGOpportunityTriggerHandler.createCampaignInfluenceRecords(opportunityList,oldMap);
        //opportunityTriggerHelper.createOpportunityiPP(opportunityList);
        
        id runningUser1 = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1].id;
        //Task Creation
        Task taskObj = new Task();
        taskObj.Subject = 'Followup VIP Package';
        taskObj.OwnerId = runningUser1;
        taskobj.WhatId = opp.Id;
        taskObj.Status = 'Open';

        PGOpportunityTriggerHandler.closeTaskStatus(opportunityList,oldMap);
        CampaignInfluence cmi1 = new CampaignInfluence();
        cmi1.CampaignId = cma.Id;
        cmi1.OpportunityId = opp.Id;
        cmi1.ModelId = modeId;
        //insert cmi;
        system.enqueueJob(new createCampaignInfluenceClass(new list<Campaigninfluence>{cmi1}));
        Test.stopTest();
        }
    
    }
       @isTest
    public static void test(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
            
        Trigger_Execute__c t =new Trigger_Execute__c();
        t.Name='PGCampMemberTrigger';
        t.Enable_del__c=true;
        insert t;
            
        Trigger_Execute__c e =new Trigger_Execute__c();
        e.Name='PGCampaignEligibilityTrigger';
        e.Enable_del__c=true;
        insert e;
            
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
            
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
       
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
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
       //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'A212312B';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
             a.mobile_country__c='60';
        insert a;
         
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'PGSG Prime Credit', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
   
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.Order_Type_Clone__c   = 'Contract - Renewal';
        opp.Opportunity_Type__c='B2C - Renewal';
        insert opp;
        
        opportunityList.add(opp);
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.EndDate = system.today().addDays(-2);
        insert cma;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
              
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
      
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        oli.UnitPrice = 2;
        insert oli;
        listOppLine.add(oli);
        
        opportunityLineItem oli2 = new opportunityLineItem();
        oli2.Product2Id = prod2.Id;
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbe2.Id;
      
        oli2.Amount_Despite_VIP__c = 2.3;
        oli2.Pro_Rate_Amount__c = 2;
        oli2.UnitPrice = 2;
        insert oli2;
        
        Map<Id,Opportunity> newMap = new Map<Id,Opportunity>();
        newMap.put(opp.Id,opp);
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
        oldMap.put(opp.Id,opp);
        
        Test.startTest();
            
        opportunityList[0].Approval_Status__c = 'OMC Approval Approved';
        opportunityList[0].stageName = 'Closed Won';
        PGOpportunityTriggerHandler.isFirstTime = true;
        Update opportunityList;
        
       
        Test.stopTest();
        }
    
    }
    
    
    @isTest
    public static void unitTest(){
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'gtest', Email='giantest@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='GianTest', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='giantest@testorg.com', Subsidiary__c='PropertyGuru International (Malaysia) Sdn Bhd'
                         );
        
        insert u;
      //  User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE isActive = true and profile.name = 'System Administrator' and Subsidiary__c='iProperty MY' LIMIT 1];
        System.runAs(u){
            
            Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
            PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
            PGTriggerOppSplit.Enable_del__c=true;
            insert PGTriggerOppSplit;
            
            Trigger_Execute__c customsetting=new Trigger_Execute__c();
            customsetting.Name='PGAccountTrigger';
            customsetting.Enable_del__c=true;
            insert customsetting;
            
            Subsidiary__c sb = new Subsidiary__c();
            sb.Name = 'iProperty.com Malaysia Sdn Bhd';
            sb.NS_Subsidiary_Internal_ID__c = '1';
            sb.CurrencyIsoCode = 'MYR';
            sb.Tax_Label__c = 'taxLabel';
            sb.Country__c = 'Malaysia';
            sb.Subsidiary_Code__c = 'iPP';
            sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
            insert sb;
            
            Subsidiary__c sb1 = new Subsidiary__c();
            sb1.Name = 'PropertyGuru International (Malaysia) Sdn Bhd';
            sb1.NS_Subsidiary_Internal_ID__c = '2';
            sb1.CurrencyIsoCode = 'MYR';
            sb1.Tax_Label__c = 'taxLabel';
            sb1.Country__c = 'Malaysia';
            sb1.Subsidiary_Code__c = 'iPP';
            sb1.Logo_url__c='https://google.com';
            insert sb1;
            
            string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
            string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
            
            Account acc = new Account();
            acc.RecordTypeId = b2baccRectype;
            acc.Name = 'Acc PgToiPP-02';
            acc.Customer_Type__c = 'Developer';
            acc.Phone = '993250';
            acc.Country__c = 'Malaysia';
            acc.B2B_ipp_REA__c = null;
            acc.B2B_external_Field__c = null;    
            insert acc; 
            
            Opportunity opp1 = new opportunity();
            opp1.Name = 'Oppo PgToiPP';
            opp1.StageName = 'Prospecting';
            opp1.AccountId = acc.id;
            opp1.CloseDate = system.today().AddDays(30);
            opp1.RecordTypeId = b2boppRectype;
            opp1.Subsidiary_Type__c = 'Property Guru';
            opp1.Product_Category__c = 'Awards';
            opp1.Subsidiary__c = sb1.Id;
            insert opp1;
            
        }
    }
       
    
}
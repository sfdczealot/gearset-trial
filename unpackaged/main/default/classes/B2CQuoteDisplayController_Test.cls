@isTest
public class B2CQuoteDisplayController_Test {
    
    
    @isTest
    public static void runTest(){ 
       // User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
      //  runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
     //   update runningUser;
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
         PGTestDataFactory_v2.initSetupData();
        Subsidiary__c sb = new Subsidiary__c(); 
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
         PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true); 
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        Trigger_Execute__c objcustom1 =new Trigger_Execute__c();
        objcustom1.Name='QuoteLineItemTrigger';
        objcustom1.Enable_del__c=true;
        insert objcustom1;
            
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGOpportunityTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
            
        Trigger_Execute__c TE=new Trigger_Execute__c();
        TE.Name='Trigger_OpportunitySplit';
        TE.Enable_del__c=true;
        insert TE;
        
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        insert objcustom;
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/);
        insert productClass;
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        insert prod;
        Id stdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true);
        insert pbe;
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        //a.Customer_Type__c = 'Agency';
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
        a.CEA_Salesperson_Number__c = 'D548569L';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        a.Mobile_Country__c = '62';
        insert a;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Opportunity_Type__c = 'B2C - Upgrade';
        insert opp;
        
        Quote objQuote=new Quote();
        objQuote.OpportunityId=opp.Id;
        objQuote.CreatedDate__c=system.today();
        objQuote.name='test';
        objQuote.Status='Proposal';
        objQuote.Quote_Type__c='B2C - Upgrade';
        objQuote.Account_Email__c='Test@test.com';
        objQuote.Subsidiary__c = sb.id;
        objQuote.Celigo_Account__c = a.id;
        insert objQuote;
        
        Test.startTest();
        
            try{
                B2CQuoteDisplayController.resendPaymentEmailMethod(objQuote.Id,objQuote.Account_Email__c);

        Test.stopTest();
            }
            catch(Exception exp){
            
        }
            //B2CQuoteDisplayController.createRenewalQuoteMethod(opp.Id, 'oppName');
            B2CQuoteDisplayController.getProfileName();
            B2CQuoteDisplayController.invalidQuoteValidation('Invalid',objQuote.Id);
            //B2CQuoteDisplayController.changeQuoteStatus(objQuote.Id, 'Invalid',opp.Id,'Expired Offer','Inactive');
            B2CQuoteDisplayController.checkQuoteStatusExpiredAndInvalid(objQuote.Id,opp.Id);
            B2CQuoteDisplayController.createQuoteMethod(objQuote.Id);
            B2CQuoteDisplayController.getPickListValue('Quote','Loss_Reason__c');
            B2CQuoteDisplayController.cloneQuote(objQuote.Id,null);
            //B2CQuoteDisplayController.changeIsSyncingQuote(objQuote); 
            B2CQuoteDisplayController.getQutoes(opp.Id);
            B2CQuoteDisplayController.changeIsSyncingQuote(objQuote);  
            B2CQuoteDisplayController.changeQuoteStatus(objQuote.Id, 'Invalid',opp.Id,'','');
            B2CQuoteDisplayController.getDependentMap('Loss_Reason__c','Lost_Sub_Reason__c');
            B2CQuoteDisplayController.decimalToBinary(50);
            B2CQuoteDisplayController.getUserInfoAndOppRecord(opp.Id);
            B2CQuoteDisplayController.increasecoverage();
    } 
  }
  
  @isTest
  public static void runTest1(){ 
       // User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
      //  runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
     //   update runningUser;
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
         PGTestDataFactory_v2.initSetupData();
        Subsidiary__c sb = new Subsidiary__c(); 
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
         PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true); 
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        Trigger_Execute__c objcustom1 =new Trigger_Execute__c();
        objcustom1.Name='QuoteLineItemTrigger';
        objcustom1.Enable_del__c=true;
        insert objcustom1;
            
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGOpportunityTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
            
        Trigger_Execute__c TE=new Trigger_Execute__c();
        TE.Name='Trigger_OpportunitySplit';
        TE.Enable_del__c=true;
        insert TE;
        
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        insert objcustom;
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/);
        insert productClass;
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        insert prod;
        Id stdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true);
        insert pbe;
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        //a.Customer_Type__c = 'Agency';
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
        a.CEA_Salesperson_Number__c = 'D548569L';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        a.Mobile_Country__c = '62';
        insert a;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Opportunity_Type__c = 'B2C - Renewal';
        insert opp;
        
        Quote objQuote=new Quote();
        objQuote.OpportunityId=opp.Id;
        objQuote.CreatedDate__c=system.today();
        objQuote.name='test';
        objQuote.Status='Proposal';
        objQuote.Quote_Type__c='B2C - Upgrade';
        objQuote.Account_Email__c='Test@test.com';
        objQuote.Subsidiary__c = sb.id;
        objQuote.Celigo_Account__c = a.id;
        insert objQuote;
        
        Test.startTest();
        
            try{
                B2CQuoteDisplayController.createRenewalQuoteMethod(opp.Id,'testPG');

        Test.stopTest();
            }
            catch(Exception exp){
            
        }
            
    } 
  }
  
  @isTest
  public static void runTest2(){ 
       // User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
      //  runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
     //   update runningUser;
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
         PGTestDataFactory_v2.initSetupData();
        Subsidiary__c sb = new Subsidiary__c(); 
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
         PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true); 
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        Trigger_Execute__c objcustom1 =new Trigger_Execute__c();
        objcustom1.Name='QuoteLineItemTrigger';
        objcustom1.Enable_del__c=true;
        insert objcustom1;
            
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGOpportunityTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
            
        Trigger_Execute__c TE=new Trigger_Execute__c();
        TE.Name='Trigger_OpportunitySplit';
        TE.Enable_del__c=true;
        insert TE;
        
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        insert objcustom;
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/);
        insert productClass;
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        insert prod;
        Id stdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true);
        insert pbe;
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        //a.Customer_Type__c = 'Agency';
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
        a.CEA_Salesperson_Number__c = 'D548569L';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        a.Mobile_Country__c = '62';
        insert a;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Opportunity_Type__c = 'B2C - Renewal';
        insert opp;
        
        Quote objQuote=new Quote();
        objQuote.OpportunityId=opp.Id;
        objQuote.CreatedDate__c=system.today();
        objQuote.name='test';
        objQuote.Status='Pending Online Payment';
        objQuote.Quote_Type__c='B2C - Upgrade';
        objQuote.Account_Email__c='Test@test.com';
        objQuote.Subsidiary__c = sb.id;
        objQuote.Celigo_Account__c = a.id;
        insert objQuote;
        
        Test.startTest();
        
            try{
                B2CQuoteDisplayController.invalidQuoteValidation('Invalid',objQuote.Id);

        Test.stopTest();
            }
            catch(Exception exp){
            
        }
            
    } 
  }
  
  @isTest
  public static void runTest3(){ 
       // User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
      //  runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
     //   update runningUser;
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
         PGTestDataFactory_v2.initSetupData();
        Subsidiary__c sb = new Subsidiary__c(); 
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
         PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true); 
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        Trigger_Execute__c objcustom1 =new Trigger_Execute__c();
        objcustom1.Name='QuoteLineItemTrigger';
        objcustom1.Enable_del__c=true;
        insert objcustom1;
            
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGOpportunityTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
            
        Trigger_Execute__c TE=new Trigger_Execute__c();
        TE.Name='Trigger_OpportunitySplit';
        TE.Enable_del__c=true;
        insert TE;
        
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        insert objcustom;
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/);
        insert productClass;
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        insert prod;
        Id stdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true);
        insert pbe;
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        //a.Customer_Type__c = 'Agency';
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
        a.CEA_Salesperson_Number__c = 'D548569L';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        a.Mobile_Country__c = '62';
        insert a;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Opportunity_Type__c = 'B2C - Renewal';
        insert opp;
        
        Quote objQuote=new Quote();
        objQuote.OpportunityId=opp.Id;
        objQuote.CreatedDate__c=system.today();
        objQuote.name='test';
        objQuote.Status='Pending OMC Approval';
        objQuote.Quote_Type__c='B2C - Upgrade';
        objQuote.Account_Email__c='Test@test.com';
        objQuote.Subsidiary__c = sb.id;
        objQuote.Celigo_Account__c = a.id;
        insert objQuote;
        
        Test.startTest();
        
            try{
                B2CQuoteDisplayController.invalidQuoteValidation('Invalid',objQuote.Id);

        Test.stopTest();
            }
            catch(Exception exp){
            
        }
            
    } 
  }
  
}
@isTest
public class OpportunityProductRegStinger_Test {
    
   public final static string skuCodeOfACProd = System.Label.PRODUCT_SKUCODE_AD_CREDIT;

   @testSetup static void setup() {
       User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
       
        PGTestDataFactory_v2.initSetupData();
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        insert objcustom;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampMemberTrigger';
        TE.Enable_del__c = true;
        insert TE;
            
        Trigger_Execute__c TE1 = new Trigger_Execute__c();
        TE1.Name = 'Trigger_OpportunitySplit';
        TE1.Enable_del__c = true;
        insert TE1;
        
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
        //a.Customer_Type__c = 'Agency';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'Advance';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'A5473687B';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        a.Mobile_Country__c = '65';
        insert a;
       
        Account acc0 = new Account();
        acc0.RecordTypeId = accRectype;
        acc0.FirstName = 'IsYuni';
        acc0.LastName = 'TestYuni';
        acc0.AgentNet_ID__c = '79853232';
        acc0.Salutation = 'Mrs.';
        //a.Customer_Type__c = 'Agency';
        acc0.CurrencyIsoCode = 'SGD';
        //acc0.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc0.BillingStreet = 'test';
        acc0.BillingCity = 'test';
        acc0.BillingCountry = 'Singapore';
        acc0.BillingPostalCode = '8376';
        // a.BillingState = 'test';
        acc0.Current_Subscription_Code__c = 'abc';
        acc0.PersonEmail = 'test1@yuni.com';
        acc0.Account_Rule_Code__c = 'Advance';
        acc0.Previous_Account_Rule__c = 'test';
        acc0.Status__c = 'Expired';
        acc0.Country__c = 'Singapore';
        acc0.PersonMobilePhone = '12340567';
        acc0.Mobile_Country__c ='60';
        //acc0.Subscription_End_Date__c = system.today().addMonths(-9);
        acc0.Loyalty_Start_Date__c = system.today().addMonths(-1);
        acc0.Is_Qualify_Agent_Referral_Program__c = true;
        acc0.CEA_Salesperson_Number__c = 'F242345H';
        acc0.PersonBirthdate = Date.newInstance(1996, 12, 21);
        acc0.Mobile_Country__c = '65';
        insert acc0;
        
        Account acc1 = new Account();
        acc1.RecordTypeId = accRectype;
        acc1.FirstName = 'IsYuni';
        acc1.LastName = 'TestYuni';
        acc1.AgentNet_ID__c = 'AgentNet_ID__c';
        acc1.Salutation = 'Mrs.';
        //a.Customer_Type__c = 'Agency';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8376';
        // a.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test11@yuni.com';
        acc1.Account_Rule_Code__c = 'TRIAL';
        acc1.Previous_Account_Rule__c = 'test';
        acc1.Status__c = 'Downgraded';
        acc1.Country__c = 'Singapore';
        acc1.PersonMobilePhone = '12349567';
        acc1.Mobile_Country__c ='65';
        acc1.Subscription_End_Date__c = system.today().addMonths(-9);
        acc1.Loyalty_Start_Date__c = system.today().addMonths(-1);
        acc1.Is_Qualify_Agent_Referral_Program__c = true;
        acc1.CEA_Salesperson_Number__c = 'U7656765K';
        acc1.PersonBirthdate = Date.newInstance(1996, 12, 21);
        acc1.Mobile_Country__c = '65';
        insert acc1;
        
        /*Account acc2 = new Account();
        acc2.RecordTypeId = accRectype;
        acc2.FirstName = 'IsYuni';
        acc2.LastName = 'TestYuni';
        acc2.AgentNet_ID__c = '67890';
        acc2.Salutation = 'Mrs.';
        //a.Customer_Type__c = 'Agency';
        acc2.CurrencyIsoCode = 'MYR';
        acc2.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc2.BillingStreet = 'test';
        acc2.BillingCity = 'test';
        acc2.BillingCountry = 'Malaysia';
        acc2.BillingPostalCode = '83786';
        acc2.Current_Subscription_Code__c = 'abc';
        acc2.PersonEmail = 'test12@yuni.com';
        acc2.Account_Rule_Code__c = 'TRIAL';
        acc2.Previous_Account_Rule__c = 'test';
        acc2.Status__c = 'Suspended';
        acc2.Country__c = 'Malaysia';
        acc2.PersonMobilePhone = '123495687';
        acc2.Mobile_Country__c ='64';
        acc2.Subscription_End_Date__c = system.today().addMonths(-9);
        acc2.Loyalty_Start_Date__c = system.today().addMonths(-1);
        acc2.Is_Qualify_Agent_Referral_Program__c = true;
        acc2.CEA_Salesperson_Number__c = 'P353456H';
        acc2.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert acc2;  
       
       Account acc3 = new Account();
        acc3.RecordTypeId = accRectype;
        acc3.FirstName = 'IsYuniTH';
        acc3.LastName = 'TestYuniTH';
        acc3.AgentNet_ID__c = '09765';
        acc3.Salutation = 'Mrs.';
        //a.Customer_Type__c = 'Agency';
        acc3.CurrencyIsoCode = 'THB';
        acc3.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc3.BillingStreet = 'test';
        acc3.BillingCity = 'test';
        acc3.BillingCountry = 'Thailand';
        acc3.BillingPostalCode = '83786';
        acc3.Current_Subscription_Code__c = 'abc';
        acc3.PersonEmail = 'test12@yuni.com';
        acc3.Account_Rule_Code__c = 'PPL3';
        acc3.Previous_Account_Rule__c = 'test';
        acc3.Status__c = 'Suspended';
        acc3.Country__c = 'Thailand';
        acc3.PersonMobilePhone = '123495687';
        acc3.Mobile_Country__c ='64';
        acc3.Subscription_End_Date__c = system.today().addMonths(-9);
        acc3.Loyalty_Start_Date__c = system.today().addMonths(-1);
        acc3.Is_Qualify_Agent_Referral_Program__c = true;
        acc3.CEA_Salesperson_Number__c = 'U546348O';
        acc3.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert acc3;*/
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/);
        insert productClass;
        
        list<Product2> listProd = new list<Product2>();
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        listProd.add(prod);
        
        Product2 prod2 = new Product2(Name = 'Test Prod2', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = skuCodeOfACProd, Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        listProd.add(prod2);
        
        Product2 prod3 = new Product2(Name = 'Test Prod3', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc3', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        listProd.add(prod3);
        
        Product2 prod4 = new Product2(Name = 'Test ala carte Prod4', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Discretionary', SKU_Code__c = 'abc4', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        listProd.add(prod4);
        
        Product2 prod5 = new Product2(Name = 'Test ala carte Prod5', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Discretionary', SKU_Code__c = 'abc5', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        listProd.add(prod5);
        
        insert listProd;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        list<PricebookEntry> listPBE = new list<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true);
        insert pbe;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, CurrencyIsoCode = 'SGD', UseStandardPrice = false);
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='Trigger_Quote';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
       
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;
       
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.Quote_Type__c = 'B2C - Standard';
        qu.PriceBook2Id = StdpricebookId;
        insert qu;
       
        opp.SyncedQuoteId = qu.Id;
        update opp;
       
       Trigger_Execute__c customsetting=new Trigger_Execute__c();
       customsetting.Name='QuoteLineItemTrigger';
       customsetting.Enable_del__c=true;
       insert customsetting;
       
        QuoteLineItem qli = new QuoteLineItem();
        qli.Product2Id = prod2.Id;
        qli.QuoteId = qu.Id;
        qli.Quantity =1;
        qli.PricebookEntryId = pbe2.Id;
        qli.Amount_Despite_VIP__c = 1.3;
        qli.Pro_Rate_Amount__c = 2;
        qli.Discount_Reason__c = 'Loyalty Discount';
        qli.UnitPrice = 2;
        qli.Discount__c = 0.5;
        qli.PricebookEntryId = pbe.Id;
        qli.SNo__c = 1.08;
        insert qli; 
        
        Item_Bundle__c bundle = new Item_Bundle__c();
        bundle.Qty__c = 3;
        bundle.Parent_Product__c = prod.id;
        bundle.Child_Product__c = prod2.Id;
        insert bundle;
        
        string campaignPromoRectype = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Marketing Promo').getRecordTypeId();
        
        Campaign c = new campaign();
        c.RecordTypeId = campaignPromoRectype;
        c.Name = 'test campaign';
        c.Country__c = 'Singapore';
        c.IsActive = true;
        c.StartDate = system.today().addDays(-2);
        c.Campaign_Start_DateTime__c = system.today().addDays(-2);
        c.EndDate = system.today().addDays(2);
        c.Campaign_End_DateTime__c = system.today().addDays(2);
        insert c;
        
        Campaign renewal_c = new campaign();
        renewal_c.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Renewal Promotion').getRecordTypeId();
        renewal_c.Name = 'test renewal campaign';
        renewal_c.Country__c = 'Singapore';
        renewal_c.IsActive = true;
        insert renewal_c;
        
        /*list<Promotion_Discount_Value__c> listRenewalPDV = new list<Promotion_Discount_Value__c>();
Promotion_Discount_Value__c pdv1 = new Promotion_Discount_Value__c();
pdv1.Campaign__c = renewal_c.id;
pdv1.Unit_Price__c = 10;
pdv1.Quantity__c = 10;
pdv1.Product_Reference__c = prod2.id;
pdv1.Product__c = prod5.id;
pdv1.Qty__c = 3;
pdv1.RecordTypeId = Schema.SObjectType.Promotion_Discount_Value__c.getRecordTypeInfosByName().get('Renewal Promotion').getRecordTypeId();
listRenewalPDV.add(pdv1);

Promotion_Discount_Value__c pdv2 = new Promotion_Discount_Value__c();
pdv2.Campaign__c = renewal_c.id;
pdv2.Unit_Price__c = 10;
pdv2.Quantity__c = 10;
pdv2.Product_Reference__c = prod3.id;
pdv2.Product__c = prod5.id;
pdv2.Qty__c = 32;
pdv2.RecordTypeId = Schema.SObjectType.Promotion_Discount_Value__c.getRecordTypeInfosByName().get('Renewal Promotion').getRecordTypeId();
listRenewalPDV.add(pdv2);

insert listRenewalPDV;
*/
        
        Account acc = [Select id, name, PersonContactId from account where lastName =: a.LastName  LIMIT 1];
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = c.id;
        cm.ContactId = acc.PersonContactId;
        insert cm;
        
        /* VIP__c vip = new VIP__c();
vip.Name = 'vip test';
vip.Min_Spending__c = 100;
vip.Max_Spending__c = 1000;
vip.Product__c = prod.id;
vip.Campaign__c = c.id;
insert vip;*/
        
        Loyalty__c loy = new Loyalty__c();
        loy.Name = 'test loyalty';
        loy.PG_Tenure__c = 2;
        loy.Discount_Percentage__c = 10;
        loy.Campaign__c = c.id;
        insert loy;
        
        /* list<Tier_Pricing__c> listTP = new list<Tier_Pricing__c>();
Tier_Pricing__c tp = new Tier_Pricing__c();
tp.Campaign__c = c.id;
tp.Name = 'test tier pricing';
tp.Product_Reference__c = prod.id;
tp.Min_Quantity__c= 3;
tp.Discount_Amount__c = 200;
tp.Discount_Percentage__c = 10;
tp.Unit_Price__c= 200;
listTP.add(tp);

Tier_Pricing__c tp2 = new Tier_Pricing__c();
tp2.Campaign__c = c.id;
tp2.Name = 'test tier pricing';
tp2.Product_Reference__c = prod.id;
tp2.Min_Quantity__c= 3;
tp2.Discount_Amount__c = 200;
tp2.Unit_Price__c= 200;
listTP.add(tp2);

Tier_Pricing__c tp3 = new Tier_Pricing__c();
tp3.Campaign__c = c.id;
tp3.Name = 'test tier pricing';
tp3.Product_Reference__c = prod.id;
tp3.Min_Quantity__c= 3;
tp3.Unit_Price__c= 200;
listTP.add(tp3);
insert listTP;*/
        
        /*list<Promotion_Discount_Value__c> listPDV = new list<Promotion_Discount_Value__c>();
Promotion_Discount_Value__c cdv = new Promotion_Discount_Value__c();
cdv.Campaign__c = c.id;
cdv.Discount_Amount__c = 100;
cdv.Discount_Percentage__c = 10;
cdv.Unit_Price__c = 10;
cdv.Quantity__c = 10;
cdv.Max_Quantity__c = 100;
cdv.Qty__c = null;
cdv.RecordTypeId = Schema.SObjectType.Promotion_Discount_Value__c.getRecordTypeInfosByName().get('Marketing Promotion').getRecordTypeId();
listPDV.add(cdv);

Promotion_Discount_Value__c cdv1 = new Promotion_Discount_Value__c();
cdv1.Campaign__c = c.id;
cdv1.Discount_Amount__c = 100;
cdv1.Unit_Price__c = 10;
cdv1.Quantity__c = 10;
cdv1.Max_Quantity__c = 100;
cdv1.Qty__c = null;
cdv1.RecordTypeId = Schema.SObjectType.Promotion_Discount_Value__c.getRecordTypeInfosByName().get('Marketing Promotion').getRecordTypeId();
listPDV.add(cdv1);

Promotion_Discount_Value__c cdv1a = new Promotion_Discount_Value__c();
cdv1a.Campaign__c = c.id;
cdv1a.Unit_Price__c = 10;
cdv1a.Quantity__c = 10;
cdv1a.Max_Quantity__c = 100;
cdv1a.Qty__c=null;
cdv1a.RecordTypeId = Schema.SObjectType.Promotion_Discount_Value__c.getRecordTypeInfosByName().get('Marketing Promotion').getRecordTypeId();
listPDV.add(cdv1a);
insert listPDV;
*/
        
        list<Upgrade_Package_Lookup__c> listUPL = new list<Upgrade_Package_Lookup__c>();
        Upgrade_Package_Lookup__c upl = new Upgrade_Package_Lookup__c();
        upl.Country__c = sb.Country__c;
        upl.Name = 'test';
        upl.Level__c = 1;
        upl.Upgrade_SKU__c = 'abc';
        upl.Renewal_SKU__c = 'test';
        listUPL.add(upl);
        
        Upgrade_Package_Lookup__c upl2 = new Upgrade_Package_Lookup__c();
        upl2.Country__c = sb.Country__c;
        upl2.Name = 'test2';
        upl2.Level__c = 2;
        upl2.Upgrade_SKU__c = 'abc2';
        upl2.Renewal_SKU__c = 'abc2';
        upl2.Renewal_Type__c = 'Renewal Downgrade';
        listUPL.add(upl2);
        
        Upgrade_Package_Lookup__c upl3 = new Upgrade_Package_Lookup__c();
        upl3.Country__c = sb.Country__c;
        upl3.Name = 'test3';
        upl3.Level__c = 3;
        upl3.Upgrade_SKU__c = 'abc3';
        upl3.Renewal_SKU__c = 'abc3';
        upl3.Renewal_Type__c = 'Renewal Upgrade';
        listUPL.add(upl3);
        insert listUPL;
        
        Upgrade_Package_Mapping__c UPM = new Upgrade_Package_Mapping__c();
        UPM.Name = 'abc';
        UPM.Destination_Rule_Code__c = 'abc';
        UPM.Origin_Rule_Code__c = 'Test';
        UPM.Quantity__c = 1;
        UPM.SKU_Code__c = 'abc';
        UPM.Unit_Price__c = 1.00;
        UPM.Country__c = 'Singapore';
        UPM.PC_SKU_Code__c = 'cba';
        UPM.PC_Quantity__c = 3.14;
        insert UPM;
        }
    }
    static testMethod void testMethod1() {
        
        Trigger_Execute__c TEBillingAPI = new Trigger_Execute__c();
        TEBillingAPI.Name = 'BillingAPI';
        TEBillingAPI.Enable_del__c = true;
        insert TEBillingAPI;
        
        OpportunityProductRegistrationStinger_cc.OppLineItemTmp oplt = new OpportunityProductRegistrationStinger_cc.OppLineItemTmp();
        system.assertEquals(null, oplt.ChildCategory, 'Invalid ChildCategory.');
        oplt.Product2Id = 'test';
        oplt.Line_Description2 = 'test';
        oplt.UnitPrice = 2;
        oplt.Product_Type = 'type'; 
        oplt.Quantity=4;
        oplt.Complimentary=true;
        oplt.Parent='test';
        oplt.DiscountReason ='test';
        
        test.startTest();
        OpportunityProductRegistrationStinger_cc.DiscountInfo discinf = new OpportunityProductRegistrationStinger_cc.DiscountInfo();
        system.assertEquals(null, discinf.BonusProductName, 'Invalid BonusProductName');
        discinf.DiscountAmount = 200;
        discinf.DiscountUnitPrice = 200;
        discinf.BonusProduct = '2';
        discinf.BonusProductName = 'test';
        discinf.BonusQty = 7;
        discinf.ProductType = 'test';
        discinf.ProductDescription = 'test';
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc',CustItem_Duration_Unit__c = 'Weeks');
        //Product2 prod = [Select Id,Name,isActive,SKU_Code__c from Product2 Where Name ='Test Prod']
        Pricebook2 pb = [Select id,Name,Subsidiary__c,Description,CurrencyIsoCode,IsActive From Pricebook2 LIMIT 1];
        system.debug('CurrencyIsoCode' +pb.CurrencyIsoCode);
        //system.debug('CurrencyIsoCode' +prod.SKU_Code__c);
        PricebookEntry pbe2 = [Select id, Name,Product2.SKU_Code__c, Product2Id,CurrencyIsoCode, Pricebook2Id, UnitPrice, Product2.Description, Product2.Product_Type__c, Product2.Tax_Code__c, Product2.Tax_Code__r.Tax_Rate__c,Product2.Income_Account_Name__c,Product2.Product_Category__c,isActive from PricebookEntry where Product2.Name = 'Test Prod' LIMIT 1];
        system.debug('CurrencyIsoCode' +pbe2.CurrencyIsoCode);
        PricebookEntry pbe = [Select id, Name,Product2.SKU_Code__c, Product2Id,CurrencyIsoCode, Pricebook2Id, UnitPrice, Product2.Description, Product2.Product_Type__c, Product2.Tax_Code__c, Product2.Tax_Code__r.Tax_Rate__c,Product2.Income_Account_Name__c,Product2.Product_Category__c,isActive from PricebookEntry where Product2.Name = 'Test Prod' LIMIT 1];
        List<PricebookEntry> lstpbe=new List<PricebookEntry>();
        lstpbe.add(pbe2);
        String lstpbeStr = Json.serialize(lstpbe);
        discinf.PricebookEntryId = pbe2.id;
        
        Opportunity opp1 = [Select Id, Name from Opportunity Where Name = 'Test Opp'];
        
        Account acc2 = [Select id, name, Account_Rule_Code__c, Current_Subscription_Code__c,Previous_Account_Rule__c,Status__c, Subscription_Start_Date__c,Country__c,Mobile_Country__c From Account where Mobile_Country__c = '65'  LIMIT 1];
        Account acc3 = [Select id, name, Account_Rule_Code__c, Current_Subscription_Code__c, Subscription_Start_Date__c,Previous_Account_Rule__c,Status__c,Country__c,Mobile_Country__c From Account  WHERE Country__c = 'Singapore' AND Account_Rule_Code__c = 'TRIAL' AND Status__c = 'Downgraded' AND Mobile_Country__c = '65'];        
        Account acc = [Select id, name, Account_Rule_Code__c, Current_Subscription_Code__c, Subscription_Start_Date__c,Previous_Account_Rule__c,Status__c,Country__c,Mobile_Country__c From Account  WHERE Country__c = 'Singapore' AND Account_Rule_Code__c = 'Advance' AND Mobile_Country__c = '65' LIMIT 1];
        system.debug('account rule code' +acc2);
        Upgrade_Package_Lookup__c upl = new Upgrade_Package_Lookup__c(name=acc3.Previous_Account_Rule__c+' - sg',country__c='Singapore',level__c=3,Upgrade_SKU__c='abc',Renewal_SKU__c='abc');
        insert upl;
        
        Upgrade_Package_Mapping__c UPM = new Upgrade_Package_Mapping__c();
        UPM.Name = acc.Account_Rule_Code__c;
        UPM.Destination_Rule_Code__c = 'Premium';
        UPM.Origin_Rule_Code__c = acc.Account_Rule_Code__c;
        UPM.Quantity__c = 1;
        UPM.Origin_Prod_SKU__c = prod.SKU_Code__c;
        UPM.PC_Quantity__c = 2;
        UPM.PC_SKU_Code__c = prod.SKU_Code__c;
        UPM.SKU_Code__c = prod.SKU_Code__c;
        UPM.Unit_Price__c = 1.00;
        UPM.Country__c = acc.Country__c;
        insert UPM;
        //system.assertEquals('IsYuni TestYuni', upgradeTmpInstance.agentObj.Name, 'Invalid Agent Name');
        
        
        Campaign camp = [Select id, Name From Campaign LIMIT 1];
        Date tdy = system.today();
        String tdystr = string.valueOf(tdy.year()) + '-' + string.valueOf(tdy.month()) + '-' + string.valueOf(tdy.day());
        String accStr = Json.serialize(acc2);
        String pbe2Str = Json.serialize(pbe2);
        string oppName = 'Upgrade '+acc2.Account_Rule_Code__c+' to ' + pbe2.Name+'.';
        system.debug('oppName' +oppName);
        //Opportunity oppSaveUpgrade = [select Id, Name from Opportunity where Name = :oppName];
   
        //system.debug('opp' +oppSaveUpgrade);
        //system.assertEquals(oppSaveUpgrade.Id, upgradeResult, 'Invalid Upgrade Result.');
        OpportunityProductRegistrationStinger_cc.getAccRecord(acc2.Id);
        OpportunityProductRegistrationStinger_cc.getLoyaltyDiscInfo(4, 'Singapore');
        List<OpportunityProductRegistrationStinger_cc.OppLineItemTmp> lsttemp=new List<OpportunityProductRegistrationStinger_cc.OppLineItemTmp>();
        OpportunityProductRegistrationStinger_cc.oppLineItemTmpAssignment(pbe2, lsttemp, 1, 'TEST', true);
        OpportunityProductRegistrationStinger_cc.DiscountInfo obj=new OpportunityProductRegistrationStinger_cc.DiscountInfo();
        obj.ProductReference='dummy';
        obj.Operator='df';
        obj.Quantity=2;
        obj.MinQuantity=2;
        obj.MaxQuantity=4;
        obj.BonusPrice=123;
        obj.TaxCode='dsd';
        obj.TaxRate=22;
        obj.Denomination=23;
        obj.AccountName='tstes';
        obj.renewalType='se';
        OpportunityProductRegistrationStinger_cc.getUpgradeMapping(accStr, lstpbeStr);
        try{
           string upgradeResult = OpportunityProductRegistrationStinger_cc.saveUpgrade(accStr, pbe2Str, camp.Id, 10.0, 'Others', tdystr, 1, 2,UPM, null,0,0,1000,null,0,0,1000);
            OpportunityProductRegistrationStinger_cc.getOrderType(system.today().addmonths(-10), system.today(), '');   
            OpportunityProductRegistrationStinger_cc.getProductDurationvalue(accStr);
            OpportunityProductRegistrationStinger_cc.getUpgradeMapBonusItem(pb,UPM,lsttemp,prod.Id);

        }catch(Exception e){
         }
        Test.setMock(HttpCalloutMock.class, new MockClassBillingAPI());

        try{
        Map<String,String> mapOfOppIdVsInternalId = new Map<String,String>();
        String jsonData = OpportunityProductRegistrationStinger_cc.constructUpgrade(acc3.id);
        //OpportunityProductRegistrationStinger_cc.getChild(pb.Id, prod.Id);
        OpportunityProductRegistrationStinger_cc.getConsumedAdCredit(accStr,null,null,null,'PC_2022');
        OpportunityProductRegistrationStinger_cc.getConsumedAdCredit(accStr,null,opp1.Id,mapOfOppIdVsInternalId,'PC_2022');
        OpportunityProductRegistrationStinger_cc.getSubscriptionProduct(acc3,'SGD',pb.Id,'Singapore',lstpbe,'Renewal_SKU__c');
        }Catch(exception e){}
        OpportunityProductRegistrationStinger_cc.getUpgradeProductList(acc3,15);
        test.stopTest();
    }
    @isTest
    public static void testgetProductDurationvalue(){
        Test.startTest();
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Thailand' and isActive = true and profile.name = 'TH B2C Sales User' Limit 1];
        System.debug('thisUser'+thisUser);
        System.runAs (thisUser) {
        //Account acc2 = [Select id, name, Account_Rule_Code__c, Current_Subscription_Code__c,Previous_Account_Rule__c,Status__c, Subscription_Start_Date__c,Country__c From Account  WHERE Country__c = 'Thailand' LIMIT 1];
      //  Account acc = [Select id, name, Account_Rule_Code__c, Current_Subscription_Code__c,Status__c, Previous_Account_Rule__c,Subscription_Start_Date__c,Country__c,Mobile_Country__c From Account LIMIT 1];
       //   Account acc = [Select id, name, Account_Rule_Code__c, Current_Subscription_Code__c, Subscription_Start_Date__c,Previous_Account_Rule__c,Status__c,Country__c,Mobile_Country__c From Account  WHERE Country__c = 'Singapore' AND Account_Rule_Code__c = 'Advance' AND Mobile_Country__c = '65'];

       // PGTestDataFactory_v2.initSetupData();
     /*   Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        insert objcustom;*/
        
/*        Trigger_Execute__c TE1 = new Trigger_Execute__c();
        TE1.Name = 'Trigger_OpportunitySplit';
        TE1.Enable_del__c = true;
        insert TE1;*/
        
  /*      Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;*/
        
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
            
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGOpportunityTrigger';
        TE.Enable_del__c = true;
        insert TE;
            
        Trigger_Execute__c TE2 = new Trigger_Execute__c();
        TE2.Name = 'BillingAPI';
        TE2.Enable_del__c = false;
        insert TE2;
            
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'AllProperty Media Co., Ltd. (Head Office)';
        sb.NS_Subsidiary_Internal_ID__c = '2';
        sb.CurrencyIsoCode = 'THB';
        sb.Tax_Label__c = 'taxLabel1';
        sb.Country__c = 'Thailand';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
       // subsidiary__c sb =[select id from subsidiary__c];
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            
         
        Account acc = new Account();
        acc.RecordTypeId = accRectype;
        acc.FirstName = 'IsYuni';
        acc.LastName = 'TestYuni';
        acc.AgentNet_ID__c = 'AgentNet_ID__c test1';
        acc.Salutation = 'Mrs.';
        //acc.Customer_Type__c = 'Agency';
        acc.CurrencyIsoCode = 'THB';
        acc.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc.BillingStreet = 'test';
        acc.BillingCity = 'test';
        acc.BillingCountry = 'Thailand';
        acc.BillingPostalCode = '83735';
        // acc.BillingState = 'test';
        acc.Current_Subscription_Code__c = 'abc';
        acc.PersonEmail = 'test0@yuni.com';
        acc.Account_Rule_Code__c = 'Advance';
        acc.Previous_Account_Rule__c = 'test';
        acc.Status__c = 'Active';
        acc.Country__c = 'Thailand';
        acc.Subscription_End_Date__c = system.today().addMonths(-9);
        acc.Loyalty_Start_Date__c = system.today().addMonths(-1);
        acc.Is_Qualify_Agent_Referral_Program__c = true;
        acc.CEA_Salesperson_Number__c = 'A5473087B';
        acc.PersonBirthdate = Date.newInstance(1996, 12, 21);
        acc.Mobile_Country__c = '62';
        acc.PersonMobilePhone = '5412632879';
        acc.Next_Subscription_Activation_Date__c = system.today().addDays(-1);
        insert acc;
            
    /*    Account acc3 = new Account();
        acc3.RecordTypeId = accRectype;
        acc3.FirstName = 'IsYuniTH';
        acc3.LastName = 'TestYuniTH';
        acc3.AgentNet_ID__c = '09765';
        acc3.Salutation = 'Mrs.';
        //a.Customer_Type__c = 'Agency';
        acc3.CurrencyIsoCode = 'THB';
        acc3.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc3.BillingStreet = 'test';
        acc3.BillingCity = 'test';
        acc3.BillingCountry = 'Thailand';
        acc3.BillingPostalCode = '83786';
        acc3.Current_Subscription_Code__c = 'abc';
        acc3.PersonEmail = 'test12@yuni.com';
        acc3.Account_Rule_Code__c = 'PPL3';
        acc3.Previous_Account_Rule__c = 'test';
        acc3.Status__c = 'Suspended';
        acc3.Country__c = 'Thailand';
        acc3.PersonMobilePhone = '123495687';
        acc3.Mobile_Country__c ='64';
        acc3.Subscription_End_Date__c = system.today().addMonths(-9);
        acc3.Loyalty_Start_Date__c = system.today().addMonths(-1);
        acc3.Is_Qualify_Agent_Referral_Program__c = true;
        acc3.CEA_Salesperson_Number__c = 'U546348O';
        acc3.PersonBirthdate = Date.newInstance(1996, 12, 21);
        acc3.Mobile_Country__c = '66';
        insert acc3;*/
        String accStr = JSON.serialize(acc);
            
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        system.debug('subsdiary opp'+opp.Owner.Subsidiary__c);
        insert opp;
        
    /*    Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Stinger__c = true;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.Opportunity_Type__c = 'B2C - Upgrade';
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.From_Button__c = true;
        opp.Payment_Time__c = system.now();
        opp.Agent_Accepted_Time__c = system.now();
        opp.Last_Outbound_Sync__c = system.now();
        opp.Outbound_Sync_Error__c = 'test'; 
        opp.Guruland_Quote_Link__c = '';
        opp.Allowed_Payment_Type__c = 'All';
        opp.Count_of_Referral_Agent_Promotion__c = 1;
        opp.CurrencyIsoCode = 'THB';
        insert opp;
*/            

        
        Upgrade_Package_Lookup__c upl = new Upgrade_Package_Lookup__c(name=acc.Account_Rule_Code__c+' - th',country__c='Singapore',level__c=3,Upgrade_SKU__c='abc',Renewal_SKU__c='abc');
        insert upl;
        
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true,Subsidiary__c = sb.id,CurrencyIsoCode = 'SGD');
        insert pb;
        
        Product2 prod = new Product2(Name = acc.Account_Rule_Code__c +' test', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Is_Bundle__c= true,CustItem_Duration_Unit__c = 'Years');
        insert prod;
            
        Product2 prod1 = new Product2(Name = acc.Account_Rule_Code__c +' test', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Is_Bundle__c= true,CustItem_Duration_Unit__c = 'Years');
        insert prod1;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        List<PricebookEntry> pbList = new List<PricebookEntry>();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe;
        pbList.add(pbe);
        
        PricebookEntry pbe11 = new PricebookEntry(pricebook2id=pb.id, product2id=prod.id,unitprice=100.0, isActive=true,  CurrencyIsoCode = 'SGD');
        insert pbe11;
        string campaignPromoRectype = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Marketing Promo').getRecordTypeId();

        Campaign c = new campaign();
        c.RecordTypeId = campaignPromoRectype;
        c.Name = 'test campaign';
        c.Country__c = 'Thailand';
        c.IsActive = true;
        c.CurrencyIsoCode = 'THB';
        c.StartDate = system.today().addDays(-2);
        c.Campaign_Start_DateTime__c = system.today().addDays(-2);
        c.EndDate = system.today().addDays(2);
        c.Campaign_End_DateTime__c = system.today().addDays(2);
        insert c;
        //Campaign camp = [Select id, Name From Campaign LIMIT 1];
        Date tdy = system.today();
        String tdystr = string.valueOf(tdy.year()) + '-' + string.valueOf(tdy.month()) + '-' + string.valueOf(tdy.day());
        String pbe2Str = Json.serialize(pbe);
        
        Upgrade_Package_Mapping__c UPM = new Upgrade_Package_Mapping__c();
        UPM.Name = 'abc';
        UPM.Destination_Rule_Code__c = 'abc';
        UPM.Origin_Rule_Code__c = acc.Account_Rule_Code__c;
        UPM.Quantity__c = 1;
        UPM.SKU_Code__c = 'abc';
        UPM.Unit_Price__c = 1.00;
        UPM.Country__c = acc.Country__c;
        UPM.PC_SKU_Code__c = 'cda';
        UPM.PC_Quantity__c = 2.14;
        insert UPM;
        
     /*   
        Upgrade_Package_Lookup__c upl3 = new Upgrade_Package_Lookup__c();
        upl3.Country__c = acc.Country__c;
        upl3.Name = 'PPL3 -TH';
        upl3.Level__c = 3;
        upl3.Upgrade_SKU__c = prod.SKU_Code__c;
        upl3.Renewal_SKU__c = 'abc3';
        upl3.Renewal_Type__c = 'Renewal Upgrade';
        insert upl3;*/
            
        Item_Bundle__c itemBundel = new Item_Bundle__c();
        itemBundel.Parent_Product__c = prod.Id;
        itemBundel.Child_Product__c = prod1.Id;
        itemBundel.Qty__c = 10;
       // itemBundel.SNo__c = 1;
        itemBundel.Upload_Tag__c = 'Test tag';
        insert itemBundel;
        
        Test.setMock(HttpCalloutMock.class, new MockClassBillingAPI());
        OpportunityProductRegistrationStinger_cc.getConsumedAdCredit(accStr,null,opp.Id,null,'PG_1237');
        try
        {
            OpportunityProductRegistrationStinger_cc.getProductDurationvalue(accStr);
            OpportunityProductRegistrationStinger_cc.getOrderType(system.today().addMonths(-16), system.today(), 'Thailand');
            OpportunityProductRegistrationStinger_cc.saveUpgrade(accStr, pbe2Str, c.Id, 10.0, 'Others', tdystr, 1, 2,UPM, null,0,0,1000,null,0,0,1000);
        }
        catch(exception e)
        {}
        OpportunityProductRegistrationStinger_cc.getChild(pb.Id, prod.Id,10);
       // OpportunityProductRegistrationStinger_cc.getSubscriptionProduct(acc,'SBD',pb.Id,'Singapore',pbList,'Renewal_SKU__c');
     //   OpportunityProductRegistrationStinger_cc.getUpgradeProductList(acc,10);
            OpportunityProductRegistrationStinger_cc.justIncrement();
        Test.StopTest();
        }
        
    }
    
    @isTest
    public static void testMethod2(){
        /*User thisUser = [SELECT Id,Subsidiary__c,profile.name FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.Debug('Test Class User###' + thisUser);
        //System.runAs (thisUser) {
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = accRectype;
        acc.FirstName = 'IsYuni';
        acc.LastName = 'TestYuni';
        acc.AgentNet_ID__c = '67890';
        acc.Salutation = 'Mrs.';
        //a.Customer_Type__c = 'Agency';
        acc.CurrencyIsoCode = 'MYR';
        acc.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc.BillingStreet = 'test';
        acc.BillingCity = 'test';
        acc.BillingCountry = 'Singapore';
        acc.BillingPostalCode = '83786';
        acc.Current_Subscription_Code__c = 'abc';
        acc.PersonEmail = 'test12@yuni.com';
        acc.Account_Rule_Code__c = 'TRIAL';
        acc.Previous_Account_Rule__c = 'test';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.PersonMobilePhone = '123495687';
        acc.Mobile_Country__c ='65';
        acc.Subscription_End_Date__c = system.today().addMonths(-9);
        acc.Loyalty_Start_Date__c = system.today().addMonths(-1);
        acc.Is_Qualify_Agent_Referral_Program__c = true;
        acc.CEA_Salesperson_Number__c = 'P353456H';
        acc.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert acc;
        //Account acc2 = [Select id, name, Account_Rule_Code__c, Current_Subscription_Code__c, Subscription_Start_Date__c,Previous_Account_Rule__c,Status__c,Country__c,Mobile_Country__c From Account  WHERE Country__c = 'Malaysia' AND Mobile_Country__c = '60' Limit 1];
        //Account acc1 = [Select id, name, Account_Rule_Code__c, Current_Subscription_Code__c, Subscription_Start_Date__c,Previous_Account_Rule__c,Status__c,Country__c,Mobile_Country__c From Account WHERE Country__c = 'Thailand' AND Mobile_Country__c = '66' LIMIT 1];
        Upgrade_Package_Lookup__c upl = new Upgrade_Package_Lookup__c(name=acc.Previous_Account_Rule__c+' - th',country__c='Singapore',level__c=3,Upgrade_SKU__c='abc',Renewal_SKU__c='abc');
        insert upl;
        subsidiary__c sb =[select id,CurrencyIsoCode from subsidiary__c LIMIT 1];
        
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true,Subsidiary__c = sb.id,CurrencyIsoCode = 'SGD');
        insert pb;
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
        Product_Class__c productClass = PGTestDataFactory_v2.createProductClass('Subscription',sb);
       Product2 prod = new Product2(Name = acc.Account_Rule_Code__c +' test', Product_Class__c = productClass.Id, IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'Renewal_SKU__c', Is_Bundle__c= true,CurrencyIsoCode = 'SGD');
       insert prod;
        
        Product2 p2 = new Product2();
        p2.Name = 'Test Product';
        p2.Description = 'Test desc';
        p2.Product_Type__c = 'PG';
        p2.subsidiary__c = sb.Id;
        p2.IsActive = true;
        insert p2;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe12 = new PricebookEntry();
        pbe12.Pricebook2Id = StdpricebookId;
        pbe12.IsActive = true;
        pbe12.Product2Id = p2.Id;
        pbe12.UseStandardPrice = false;
        pbe12.CurrencyISOCode = 'SGD';
        pbe12.UnitPrice = 100;
        insert pbe12;
        
        Item_Bundle__c IB = new Item_Bundle__c();
        IB.Parent_Product__c = prod.Id;
        IB.Child_Product__c = p2.Id;
        IB.Qty__c = 1;
        insert IB;
        
        List<PricebookEntry> pbList = new List<PricebookEntry>();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe;
        pbList.add(pbe);
        
        PricebookEntry pbe11 = new PricebookEntry(pricebook2id=pb.id, product2id=prod.id,unitprice=100.0, isActive=true,  CurrencyIsoCode = 'SGD');
        insert pbe11;
        
        Campaign camp = [Select id, Name From Campaign LIMIT 1];
        Date tdy = system.today();
        String accStr = Json.serialize(acc);
        String tdystr = string.valueOf(tdy.year()) + '-' + string.valueOf(tdy.month()) + '-' + string.valueOf(tdy.day());
        String pbe2Str = Json.serialize(pbe);
        
        Upgrade_Package_Mapping__c UPM = new Upgrade_Package_Mapping__c();
        UPM.Name = 'abc';
        UPM.Destination_Rule_Code__c = 'abc';
        UPM.Origin_Rule_Code__c = acc.Account_Rule_Code__c;
        UPM.Quantity__c = 1;
        UPM.SKU_Code__c = 'abc';
        UPM.Unit_Price__c = 1.00;
        UPM.Country__c = acc.Country__c;
        insert UPM;
        
        Upgrade_Package_Lookup__c upl3 = new Upgrade_Package_Lookup__c();
        upl3.Country__c = acc.Country__c;
        upl3.Name = 'test3';
        upl3.Level__c = 3;
        upl3.Upgrade_SKU__c = prod.SKU_Code__c;
        upl3.Renewal_SKU__c = 'abc3';
        upl3.Renewal_Type__c = 'Renewal Upgrade';
        insert upl3;
        Test.startTest();
        OpportunityProductRegistrationStinger_cc.getSubscriptionProduct(acc,'SGD',StdpricebookId,'Singapore',pbList,'Renewal_SKU__c');
        try{
            OpportunityProductRegistrationStinger_cc.getOrderType(system.today().addmonths(-14), system.today(), 'Singapore');
            OpportunityProductRegistrationStinger_cc.saveUpgrade(accStr, pbe2Str, camp.Id, 10.0, 'Others', tdystr, 1, 2,UPM, null,0,0,1000,null,0,0,1000);
            OpportunityProductRegistrationStinger_cc.getProductDurationvalue(accStr);
            OpportunityProductRegistrationStinger_cc.getChild(pb.Id, prod.Id,10);
            OpportunityProductRegistrationStinger_cc.constructUpgrade(acc.id);
            OpportunityProductRegistrationStinger_cc.getUpgradeProductList(acc,10);
            OpportunityProductRegistrationStinger_cc.justIncrement();
        }
        catch(exception e)
        {}
        Test.StopTest(); */  
        //}
    }
    
    @isTest
    public static void method3(){
        /*User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Thailand' and isActive = true and profile.name = 'TH B2C Sales User' Limit 1];
        System.debug('thisUser'+thisUser);
        System.runAs (thisUser) {
        Trigger_Execute__c TEBillingAPI = new Trigger_Execute__c();
        TEBillingAPI.Name = 'BillingAPI';
        TEBillingAPI.Enable_del__c = true;
        insert TEBillingAPI;
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = accRectype;
        acc.FirstName = 'IsYuni';
        acc.LastName = 'TestYuni';
        acc.AgentNet_ID__c = '67890';
        acc.Salutation = 'Mrs.';
        //a.Customer_Type__c = 'Agency';
        acc.CurrencyIsoCode = 'THB';
        acc.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc.BillingStreet = 'test';
        acc.BillingCity = 'test';
        acc.BillingCountry = 'Thailand';
        acc.BillingPostalCode = '83786';
        acc.Current_Subscription_Code__c = 'abc';
        acc.PersonEmail = 'test12@yuni.com';
        acc.Account_Rule_Code__c = 'TRIAL';
        acc.Previous_Account_Rule__c = 'test';
        acc.Status__c = 'Suspended';
        acc.Country__c = 'Thailand';
        acc.PersonMobilePhone = '123495687';
        acc.Mobile_Country__c ='64';
        acc.Subscription_End_Date__c = system.today().addMonths(-9);
        acc.Loyalty_Start_Date__c = system.today().addMonths(-1);
        acc.Is_Qualify_Agent_Referral_Program__c = true;
        acc.CEA_Salesperson_Number__c = 'P353456H';
        acc.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert acc;
        //Account acc = [Select id, name, Account_Rule_Code__c, Current_Subscription_Code__c,Status__c, Subscription_Start_Date__c,Country__c From Account  WHERE Country__c = 'Thailand' LIMIT 1];
        //Account acc1 = [Select id, name, Account_Rule_Code__c, Current_Subscription_Code__c, Subscription_Start_Date__c,Previous_Account_Rule__c,Status__c,Country__c From Account  WHERE Country__c = 'Singapore' AND Account_Rule_Code__c = 'Advance'];
        String accStr = JSON.serialize(acc);
        Upgrade_Package_Lookup__c upl = new Upgrade_Package_Lookup__c(name=acc.Account_Rule_Code__c+' - th',country__c='Thailand',level__c=3,Upgrade_SKU__c='abc',Renewal_SKU__c='abc');
        insert upl;
        subsidiary__c sb =[select id from subsidiary__c];
        
        
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true,Subsidiary__c = sb.id,CurrencyIsoCode = 'THB');
        insert pb;
        
        Product2 prod = new Product2(Name = acc.Account_Rule_Code__c +' test', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'Renewal_SKU__c', Is_Bundle__c= true,CurrencyIsoCode = 'THB');
        insert prod;
        Product_Class__c productClass = PGTestDataFactory_v2.createProductClass('Subscription',sb);    
        Product2 prod1 = new Product2(Name = acc.Account_Rule_Code__c +' test', IsActive = true, Segment__c = 'B2C Only', Product_Class__c = productClass.Id, Product_Category__c = 'Subscription', SKU_Code__c = 'Renewal_SKU__c', Is_Bundle__c= true,CurrencyIsoCode = 'THB');
        insert prod1;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        List<PricebookEntry> pbList = new List<PricebookEntry>();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'THB');
        insert pbe;
        pbList.add(pbe);
        
        PricebookEntry pbe11 = new PricebookEntry(pricebook2id=pb.id, product2id=prod.id,unitprice=100.0, isActive=true,  CurrencyIsoCode = 'THB');
        insert pbe11;
        
        Upgrade_Package_Lookup__c upl3 = new Upgrade_Package_Lookup__c();
        upl3.Country__c = acc.Country__c;
        upl3.Name = 'test3';
        upl3.Level__c = 3;
        upl3.Upgrade_SKU__c = prod.SKU_Code__c;
        upl3.Renewal_SKU__c = 'abc3';
        upl3.Renewal_Type__c = 'Renewal Upgrade';
        insert upl3;
        
        Item_Bundle__c itemBundel = new Item_Bundle__c();
        itemBundel.Parent_Product__c = prod.Id;
        itemBundel.Child_Product__c = prod1.Id;
        itemBundel.Qty__c = 10;
       // itemBundel.SNo__c = 1;
        itemBundel.Upload_Tag__c = 'Test tag';
        insert itemBundel;
        
        Test.StartTest();
        try
        {
            OpportunityProductRegistrationStinger_cc.getConsumedAdCredit(accStr,'PBD123456','Test',null,'PG_1237');
            OpportunityProductRegistrationStinger_cc.getProductDurationvalue(accStr);
            OpportunityProductRegistrationStinger_cc.getOrderType(system.today().addMonths(-12), system.today(), '');
            OpportunityProductRegistrationStinger_cc.justIncrement();
        }
        catch(exception e)
        {}
        OpportunityProductRegistrationStinger_cc.getChild(pb.Id, prod.Id,10);
        OpportunityProductRegistrationStinger_cc.getUpgradeProductList(acc,10);
        OpportunityProductRegistrationStinger_cc.getSubscriptionProduct(acc,'THB',pb.Id,'Thailand',pbList,'Renewal_SKU__c');
        Test.StopTest();
        
        }*/
    }
    
    @isTest
    public static void method4(){
        Trigger_Execute__c TEBillingAPI = new Trigger_Execute__c();
        TEBillingAPI.Name = 'BillingAPI';
        TEBillingAPI.Enable_del__c = true;
        insert TEBillingAPI;
        //Account acc = [Select id, name, Account_Rule_Code__c, Current_Subscription_Code__c,Status__c, Subscription_Start_Date__c,Country__c From Account  WHERE Country__c = 'Thailand' LIMIT 1];
        Account acc = [Select id, name, Account_Rule_Code__c, Current_Subscription_Code__c,Account_Previous_Status__c, Subscription_Start_Date__c,Previous_Account_Rule__c,Status__c,Country__c From Account  WHERE Country__c = 'Singapore' AND Account_Rule_Code__c = 'Advance' limit 1];
        acc.Account_Rule_Code__c= 'TRIAL';
        acc.Status__c = 'Active';
        acc.Previous_Account_Rule__c = 'standard';
        acc.Account_Previous_Status__c = 'Trial';
       // insert acc;
     //   String accStr = JSON.serialize(acc);
        Upgrade_Package_Lookup__c upl = new Upgrade_Package_Lookup__c(name=acc.Account_Rule_Code__c+' - th',country__c='Thailand',level__c=3,Upgrade_SKU__c='abc',Renewal_SKU__c='abc');
        insert upl;
        subsidiary__c sb =[select id from subsidiary__c];
        
        
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true,Subsidiary__c = sb.id,CurrencyIsoCode = 'THB');
        insert pb;
        
        Product2 prod = new Product2(Name = acc.Account_Rule_Code__c +' test', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'Renewal_SKU__c', Is_Bundle__c= true,CurrencyIsoCode = 'THB');
        insert prod;
        
        Product2 prod1 = new Product2(Name = acc.Account_Rule_Code__c +' test', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'Renewal_SKU__c', Is_Bundle__c= true,CurrencyIsoCode = 'THB');
        insert prod1;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        List<PricebookEntry> pbList = new List<PricebookEntry>();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'THB');
        insert pbe;
        pbList.add(pbe);
        
        PricebookEntry pbe11 = new PricebookEntry(pricebook2id=pb.id, product2id=prod.id,unitprice=100.0, isActive=true,  CurrencyIsoCode = 'THB');
        insert pbe11;
        
        Campaign camp = [Select id, Name From Campaign LIMIT 1];
        Date tdy = system.today();
        String accStr = Json.serialize(acc);
        String tdystr = string.valueOf(tdy.year()) + '-' + string.valueOf(tdy.month()) + '-' + string.valueOf(tdy.day());
        String pbe2Str = Json.serialize(pbe);
        
        Upgrade_Package_Mapping__c UPM = new Upgrade_Package_Mapping__c();
        UPM.Name = 'abc';
        UPM.Destination_Rule_Code__c = 'abc';
        UPM.Origin_Rule_Code__c = acc.Account_Rule_Code__c;
        UPM.Quantity__c = 1;
        UPM.SKU_Code__c = 'abc';
        UPM.Unit_Price__c = 1.00;
        UPM.Country__c = acc.Country__c;
        UPM.PC_SKU_Code__c = 'abd';
        UPM.PC_Quantity__c = 3.21;
        insert UPM;
        
        Upgrade_Package_Lookup__c upl3 = new Upgrade_Package_Lookup__c();
        upl3.Country__c = acc.Country__c;
        upl3.Name = 'STANDARD';
        upl3.Level__c = 3;
        upl3.IsActive__c = true;
        upl3.Upgrade_SKU__c = prod.SKU_Code__c;
        upl3.Renewal_SKU__c = 'abc3';
        upl3.Renewal_Type__c = 'Renewal Upgrade';
        insert upl3;
        
        Item_Bundle__c itemBundel = new Item_Bundle__c();
        itemBundel.Parent_Product__c = prod.Id;
        itemBundel.Child_Product__c = prod1.Id;
        itemBundel.Qty__c = 10;
       // itemBundel.SNo__c = 1;
        itemBundel.Upload_Tag__c = 'Test tag';
        insert itemBundel;
        
        Test.StartTest();
        try
        {
            OpportunityProductRegistrationStinger_cc.getConsumedAdCredit(accStr,'PBD123456','Test',null,'PG_1237');
            OpportunityProductRegistrationStinger_cc.getProductDurationvalue(accStr);
            OpportunityProductRegistrationStinger_cc.saveUpgrade(accStr, pbe2Str, camp.Id, 10.0, 'Others', tdystr, 1, 2,UPM, null,0,0,1000,null,0,0,1000);
            OpportunityProductRegistrationStinger_cc.getOrderType(system.today().addMonths(-12), system.today(), '');
            OpportunityProductRegistrationStinger_cc.justIncrement();
        }
        catch(exception e)
        {}
        OpportunityProductRegistrationStinger_cc.getChild(pb.Id, prod.Id,10);
        OpportunityProductRegistrationStinger_cc.getUpgradeProductList(acc,10);
        OpportunityProductRegistrationStinger_cc.getSubscriptionProduct(acc,'SGD',pb.Id,'Singapore',pbList,'Renewal_SKU__c');
        Test.StopTest();
        
        
    }
    
    @isTest
    public static void testMethod5(){
        /*User thisUser = [SELECT Id,Subsidiary__c,profile.name FROM User WHERE country = 'Thailand' and isActive = true and profile.name = 'TH B2C Sales User' LIMIT 1];
        System.runAs (thisUser) {
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = accRectype;
        acc.FirstName = 'IsYuni';
        acc.LastName = 'TestYuni';
        acc.AgentNet_ID__c = '67890';
        acc.Salutation = 'Mrs.';
        //a.Customer_Type__c = 'Agency';
        acc.CurrencyIsoCode = 'THB';
        acc.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc.BillingStreet = 'test';
        acc.BillingCity = 'test';
        acc.BillingCountry = 'Thailand';
        acc.BillingPostalCode = '83786';
        acc.Current_Subscription_Code__c = 'abc';
        acc.PersonEmail = 'test12@yuni.com';
        acc.Account_Rule_Code__c = 'TRIAL';
        acc.Previous_Account_Rule__c = 'test';
        acc.Status__c = 'Suspended';
        acc.Country__c = 'Thailand';
        acc.PersonMobilePhone = '123495687';
        acc.Mobile_Country__c ='66';
        acc.Subscription_End_Date__c = system.today().addMonths(-9);
        acc.Loyalty_Start_Date__c = system.today().addMonths(-1);
        acc.Is_Qualify_Agent_Referral_Program__c = true;
        acc.CEA_Salesperson_Number__c = 'P353456H';
        acc.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert acc;
        //Account acc2 = [Select id, name, Account_Rule_Code__c, Current_Subscription_Code__c, Subscription_Start_Date__c,Previous_Account_Rule__c,Status__c,Country__c,Mobile_Country__c From Account  WHERE Country__c = 'Malaysia' AND Mobile_Country__c = '60' Limit 1];
        //Account acc1 = [Select id, name, Account_Rule_Code__c, Current_Subscription_Code__c, Subscription_Start_Date__c,Previous_Account_Rule__c,Status__c,Country__c,Mobile_Country__c From Account WHERE Country__c = 'Thailand' AND Mobile_Country__c = '66' LIMIT 1];
        Upgrade_Package_Lookup__c upl = new Upgrade_Package_Lookup__c(name=acc.Previous_Account_Rule__c+' - th',country__c='Singapore',level__c=3,Upgrade_SKU__c='abc',Renewal_SKU__c='abc');
        insert upl;
        subsidiary__c sb =[select id from subsidiary__c];
        
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true,Subsidiary__c = sb.id,CurrencyIsoCode = 'SGD');
        insert pb;
        
        //Product2 prod = new Product2(Name = acc.Account_Rule_Code__c +' test', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Is_Bundle__c= true,CustItem_Duration_Unit__c = 'Months');
        //insert prod;
        Product_Class__c productClass = PGTestDataFactory_v2.createProductClass('Subscription',sb);
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'THB',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, SKU_Code__c = 'Test',  Product_Type__c='PG',Description='DummyText',Product_Class__c = productClass.Id, Is_Bundle__c=true);
        insert prod;
        Product2 p2 = new Product2();
        p2.Name = 'Test Product';
        p2.Description = 'Test desc';
        p2.Product_Type__c = 'PG';
        p2.subsidiary__c = sb.Id;
        p2.IsActive = true;
        insert p2;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe12 = new PricebookEntry();
        pbe12.Pricebook2Id = StdpricebookId;
        pbe12.IsActive = true;
        pbe12.Product2Id = p2.Id;
        pbe12.UseStandardPrice = false;
        pbe12.CurrencyISOCode = 'SGD';
        pbe12.UnitPrice = 100;
        insert pbe12;
        
        Item_Bundle__c IB = new Item_Bundle__c();
        IB.Parent_Product__c = prod.Id;
        IB.Child_Product__c = p2.Id;
        IB.Qty__c = 1;
        insert IB;
        
        List<PricebookEntry> pbList = new List<PricebookEntry>();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe;
        pbList.add(pbe);
        
        PricebookEntry pbe11 = new PricebookEntry(pricebook2id=pb.id, product2id=prod.id,unitprice=100.0, isActive=true,  CurrencyIsoCode = 'SGD');
        insert pbe11;
        
        string campaignPromoRectype = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Marketing Promo').getRecordTypeId();
        
        Campaign c = new campaign();
        c.RecordTypeId = campaignPromoRectype;
        c.Name = 'test campaign';
        c.Country__c = 'Thailand';
        c.CurrencyIsoCode = 'THB';
        c.IsActive = true;
        c.StartDate = system.today().addDays(-2);
        c.Campaign_Start_DateTime__c = system.today().addDays(-2);
        c.EndDate = system.today().addDays(2);
        c.Campaign_End_DateTime__c = system.today().addDays(2);
        insert c;
        Date tdy = system.today();
        String accStr = Json.serialize(acc);
        String tdystr = string.valueOf(tdy.year()) + '-' + string.valueOf(tdy.month()) + '-' + string.valueOf(tdy.day());
        String pbe2Str = Json.serialize(pbe);
        
        Upgrade_Package_Mapping__c UPM = new Upgrade_Package_Mapping__c();
        UPM.Name = 'abc';
        UPM.Destination_Rule_Code__c = 'abc';
        UPM.Origin_Rule_Code__c = acc.Account_Rule_Code__c;
        UPM.Quantity__c = 1;
        UPM.SKU_Code__c = 'abc';
        UPM.Unit_Price__c = 1.00;
        UPM.Country__c = acc.Country__c;
        insert UPM;
        
        Upgrade_Package_Lookup__c upl3 = new Upgrade_Package_Lookup__c();
        upl3.Country__c = acc.Country__c;
        upl3.Name = 'test3';
        upl3.Level__c = 3;
        upl3.Upgrade_SKU__c = prod.SKU_Code__c;
        upl3.Renewal_SKU__c = 'abc3';
        upl3.Renewal_Type__c = 'Renewal Upgrade';
        insert upl3;
        Test.startTest();
        OpportunityProductRegistrationStinger_cc.getSubscriptionProduct(acc,'SGD',StdpricebookId,'Singapore',pbList,'Renewal_SKU__c');
        try{
            OpportunityProductRegistrationStinger_cc.getOrderType(system.today().addmonths(-14), system.today(), 'Malaysia');
            OpportunityProductRegistrationStinger_cc.saveUpgrade(accStr, pbe2Str, c.Id, 10.0, 'Others', tdystr, 1, 2,UPM, null,0,0,1000,null,0,0,1000);
            OpportunityProductRegistrationStinger_cc.getProductDurationvalue(accStr);
            OpportunityProductRegistrationStinger_cc.getChild(pb.Id, prod.Id,10);
            OpportunityProductRegistrationStinger_cc.constructUpgrade(acc.id);
            OpportunityProductRegistrationStinger_cc.getUpgradeProductList(acc,10);
            OpportunityProductRegistrationStinger_cc.justIncrement();
        }
        catch(exception e)
        {}
        Test.StopTest();   
        }*/
    }
    
    //Mock Response
    public class MockClassBillingAPI implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            system.debug('*****'+req.getEndpoint());
            
            res.setHeader('Content-Type', ' text/html');
            res.setBody('{"valid":true,"message":"test"}');
            res.setStatusCode(200);
            return res;
            
        }
    }
       
}
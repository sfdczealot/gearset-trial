@isTest
public class ProductSelectionController_Test {
    
    @isTest
    public static void ProductSelectionMethod(){
        
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        PGTestDataFactory_v2.initSetupData();
         //PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        
       /* Trigger_Execute__c objcustom3=new Trigger_Execute__c();
        objcustom3.Name='Trigger_OpportunityLineItem';
        objcustom3.Enable_del__c=true;
        insert objcustom3;*/
        list<Account> listAccount1 = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
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
        
        ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conVersion.ContentDocumentId;
        cdl.LinkedEntityId = newMedia.id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers'; 
        insert cdl;

        insert listAccount1;
        
        
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        insert objcustom;
        
        Trigger_Execute__c TEOppSplit=new Trigger_Execute__c();
        TEOppSplit.Name='Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c=true;
        insert TEOppSplit;
            
        Trigger_Execute__c objcustom2=new Trigger_Execute__c();
        objcustom2.Name='QuoteLineItemTrigger';
        objcustom2.Enable_del__c=true;
        insert objcustom2;
        
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
        a.Agency__c = listAccount1[0].Id;
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
        a.Account_Rule_Code__c = 'Advance';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'A123456G';
        a.VIP_Campaign__c = 'TestNameCampaign';
        a.VIP__c = true;
        a.Mobile_Country__c = '66';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Advance', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'PG01P5702S', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
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
        opp.Opportunity_Type__c = 'B2C - Standard';
        insert opp;
        
        Quote objQuote=new Quote();
        objQuote.OpportunityId=opp.Id;
        objQuote.CreatedDate__c=system.today();
        objQuote.name='test';
        objQuote.Status='Proposal';
        objQuote.PriceBook2Id = standardPB.Id;
        objQuote.Celigo_Account__c = a.Id;
        //objQuote.Record_Eligibility__c = 'VR_Validate_Agent_Status';
        insert objQuote;
        system.debug('check'+ objQuote);
        Item_Bundle__c bundle = new Item_Bundle__c();
        bundle.Qty__c = 3;
        bundle.Parent_Product__c = pbe1.Product2Id;
        bundle.Child_Product__c = pbe1.Product2Id;
        insert bundle;
            
           
        string campaignPromoRectype = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Marketing Promo').getRecordTypeId();
        
        Trigger_Execute__c PGCampMemberTrigger = new Trigger_Execute__c();
        PGCampMemberTrigger.Name = 'PGCampMemberTrigger';
        PGCampMemberTrigger.Enable_del__c = true;
        insert PGCampMemberTrigger;
        
        
        Trigger_Execute__c PGCampaignTrigger = new Trigger_Execute__c();
        PGCampaignTrigger.Name = 'PGCampaignTrigger';
        PGCampaignTrigger.Enable_del__c = true;
        insert PGCampaignTrigger;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampaignEligibilityTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
        
        Trigger_Execute__c TEEntPromo = new Trigger_Execute__c();
        TEEntPromo.Name = 'PGEntitlementPromoTrigger';
        TEEntPromo.Enable_del__c = true;
        insert TEEntPromo;
        
 /*       
        Campaign c = new campaign();
        c.RecordTypeId = campaignPromoRectype;
        c.Name = 'test campaign';
        c.Country__c = 'Singapore';
        c.IsActive = true;
        c.StartDate = system.today().addDays(-2);
        c.EndDate = system.today().addDays(2);
        c.Campaign_End_DateTime__c = system.today().addDays(2);
         c.Campaign_Start_DateTime__c = system.today().addDays(-2);
			insert c;
*/
 /*       
        Campaign renewal_c = new campaign();
        renewal_c.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Renewal Promotion').getRecordTypeId();
        renewal_c.Name = 'test renewal campaign';
        renewal_c.Country__c = 'Singapore';
        renewal_c.IsActive = true;
        insert renewal_c;
  */      
        /*list<Promotion_Discount_Value__c> listRenewalPDV = new list<Promotion_Discount_Value__c>();
        Promotion_Discount_Value__c pdv1 = new Promotion_Discount_Value__c();
        pdv1.Campaign__c = renewal_c.id;
        pdv1.Unit_Price__c = 10;
        pdv1.Quantity__c = 10;
        pdv1.Product_Reference__c = prod2.id;
        pdv1.Product__c = prod.id;
        pdv1.Qty__c = 3;
        pdv1.RecordTypeId = Schema.SObjectType.Promotion_Discount_Value__c.getRecordTypeInfosByName().get('Renewal Promotion').getRecordTypeId();
        listRenewalPDV.add(pdv1);
        
        Promotion_Discount_Value__c pdv2 = new Promotion_Discount_Value__c();
        pdv2.Campaign__c = renewal_c.id;
        pdv2.Unit_Price__c = 10;
        pdv2.Quantity__c = 10;
        pdv2.Product_Reference__c = prod.id;
        pdv2.Product__c = prod2.id;
        pdv2.Qty__c = 32;
        pdv2.RecordTypeId = Schema.SObjectType.Promotion_Discount_Value__c.getRecordTypeInfosByName().get('Renewal Promotion').getRecordTypeId();
        listRenewalPDV.add(pdv2);
        
        insert listRenewalPDV;        */
/*
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = c.id;
        cm.ContactId = [select Id,Account.PersonContactId from Opportunity where Id = :opp.Id LIMIT 1].Account.PersonContactId;
        insert cm;
 */       
        /*list<Tier_Pricing__c> listTP = new list<Tier_Pricing__c>();
        Tier_Pricing__c tp = new Tier_Pricing__c();
        tp.Campaign__c = c.id;
        tp.Name = 'test tier pricing';
        tp.Product_Reference__c = prod2.id;
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
 /*       
        Campaign parentCma = new Campaign();
        parentCma.Name = 'TestNameCampaign1';
        parentCma.Country__c = 'Singapore';
        parentCma.StartDate = system.today().addDays(-2);
        parentCma.EndDate = system.today().addDays(2);
        parentCma.IsActive = true;
        parentCma.Status = 'Active';
        insert parentCma;
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.StartDate = system.today().addDays(-2);
        cma.EndDate = system.today().addDays(2);
        cma.ParentId = parentCma.Id;
        cma.IsActive = true;
        
        insert cma;
        
        CampaignMemberStatus cms = new CampaignMemberStatus();
        cms.Label = 'Approved';
        cms.CampaignId = cma.Id;
        insert cms;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = [select Id,Account.PersonContactId from Opportunity where Id = :opp.Id LIMIT 1].Account.PersonContactId;
        cmp.Status = 'Approved';
        cmp.CampaignId = cma.Id;
        insert cmp;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;

*/
/*        
        Promo_Mechanic__c prm = new Promo_Mechanic__c();
        prm.Name = 'TestName';
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Usage__c = -1;
        prm.Status__c = 'Active';
        insert prm;
        Promo_Mechanic__c prm2 = new Promo_Mechanic__c();
        prm2.Name = 'TestName';
        prm2.Status__c = 'Active';
        prm2.Usage__c = -1;
        prm2.Eligible_Product__c = prod.Id;
        prm2.Campaign_Eligibility__c = ce1.Id;
        insert prm2;
 */       
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Quantity = 500;
         oli.Start_Date__c= system.today();
         oli.End_Date__c =system.today().adddays(1);
        oli.UnitPrice = 10000;
   //     oli.Parent_Id__c = 'hs4s4';
        insert oli;
        listOppLine.add(oli);
        //listOppLine.add(oli);
        //Insert listOppLine;
        opportunityLineItem oli1 = new opportunityLineItem();
        oli1.Product2Id = prod2.Id;
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbe2.Id;
        //oli1.Quantity= 6;
        oli1.Parent__c = oli.Id;
   //     oli1.Parent_Id__c = 'hs415s4';
        //oli1.Parent_Id__c = oli.Id;
        listOppLine.add(oli1);
        //Insert listOppLine;
        
        Trigger_Execute__c tef = new Trigger_Execute__c();
        tef.Name = 'QuoteLineItemTrigger';
        tef.Enable_del__c = false;
        insert tef;
/*            
        List<quoteLineItem> listquoteLine = new List<quoteLineItem>();
        quoteLineItem qli = new quoteLineItem();
        qli.Product2Id = prod.Id;
        qli.QuoteId = objQuote.Id;
        qli.PricebookEntryId = pbe2.Id;
        qli.Start_Date__c = System.today();
        qli.UnitPrice = 45;
        qli.Quantity = 3;
        insert qli;
        listquoteLine.add(qli);
        quoteLineItem qli1 = new quoteLineItem();
        qli1.Product2Id = prod2.Id;
        qli1.QuoteId = objQuote.Id;
        qli1.PricebookEntryId = pbe2.Id;
        qli1.Parent__c = qli.Id;
        qli1.Parent_Id__c = qli.Id;
        qli1.UnitPrice = 23;
        qli1.Quantity = 7;
        listquoteLine.add(qli1);
 */       
  //     Trigger_Execute__c tef = new Trigger_Execute__c(Name = 'QuoteLineItemTrigger');
  //      insert tef;
        
        ProductSelectionLightningPageController.OppLineItemTmp oplt = new ProductSelectionLightningPageController.OppLineItemTmp();
        system.assertEquals(null, oplt.ChildCategory, 'Invalid ChildCategory.');
        oplt.Id = '53454';
        oplt.Product2Id = 'test';
        oplt.Line_Description2 = 'test';
        oplt.UnitPrice = 2;
        oplt.Product_Type = 'type'; 
        oplt.Quantity=4;
        oplt.Complimentary=true;
        oplt.Parent='test';
        oplt.DiscountReason ='test';
        
 /*       ProductSelectionLightningPageController.DiscountInfo ds = new ProductSelectionLightningPageController.DiscountInfo();
        system.assertEquals(null, ds.BonusProductName, 'Invalid BonusProductName');
        ds.Name = 'Test';
        ds.BonusPrice = 2;
        ds.Description = 'DescriptionTest';
        ds.DiscountAmount = 200;
        ds.DiscountUnitPrice = 200;
        ds.BonusProduct = '2';
        ds.BonusProductName = 'test';
        ds.BonusQty = 7;
        ds.ProductType = 'test';
        ds.ProductDescription = 'test';
        ds.PricebookEntryId = pbe2.id;
        ds.CampaignId = c.id;
        ds.DiscountReason = 'test';
        ds.TaxCode = 'TaxCode';
        ds.TaxRate = 2;
        ds.Denomination = 3;
        ds.AccountName = 'AccountName';
        ds.renewalType = 'renewalType';
        ds.DiscountPercentage = 1;
        ds.MaxQuantity = 2.9;
        ds.MinQuantity = 1.2;
        ds.Quantity = 1;
        ds.Operator = 'Operator';
        ds.ProductReference = 'ProductReference';
 */       
  
        Test.startTest();
        Opportunity opp1 = [select Id, Name, AccountId, Account.Name,Account.VIP__c,Account.Approval_Status__c,Account.Loyalty_Start_Date__c, Account.Country__c, Account.CEA_Salesperson_Number__c, Account.PersonContactId, Account.Status__c, Account.Previous_Account_Rule__c, Account.Account_Rule_Code__c, Account.Subscription_Start_Date__c, Account.Is_Qualify_Agent_Referral_Program__c, Account.Referrer_Agent__c, Account.Current_Subscription_Code__c, Account.PG_Tenure__c, Pricebook2Id, PG_Tenure__c, Total_Spending__c, Subsidiary__c, Country__c,
                            Order_Type_Clone__c, to_VIP_Approval__c, to_Managerial_Approval__c, to_FOC_Approval__c, StageName, Approval_Status__c, CurrencyIsoCode, CloseDate from Opportunity LIMIT 1];
        ProductSelectionLightningPageController.getUserInfoAndOppRecord(objQuote.Id);
        ProductSelectionLightningPageController.getAvailableProductAndPromo(standardPB.Id,'SGD','Test',opp.Id,objQuote.Id);
        ProductSelectionLightningPageController.oliAndDefaultPromoList(opp.Id,objQuote.Id);
        ProductSelectionLightningPageController.saveOliData(opp.Id,listOppLine);
   //     ProductSelectionLightningPageController.getUserInfoAndOppRecord(objQuote.OpportunityId);
        ProductSelectionLightningPageController.getPickListValue('Account', 'Rating');
        ProductSelectionLightningPageController.getListData('Id','Name','Account');
        ProductSelectionLightningPageController.getListEligiblePromotion(opp1);
        ProductSelectionLightningPageController.getChild(pbe2.Pricebook2Id, pbe2.Product2Id);
        //ProductSelectionLightningPageController.getTierPricingInfo(new List<ProductSelectionLightningPageController.DiscountInfo>{ds},'Singapore');
        //ProductSelectionLightningPageController.getDiscountInfo(opp1,new List<ProductSelectionLightningPageController.DiscountInfo>{ds});
        Quote qu1 = [select Id, Name, Celigo_Account__c, Account.Name,Account.VIP__c,Account.Approval_Status__c,Account.Loyalty_Start_Date__c, Account.Country__c, Account.CEA_Salesperson_Number__c, Account.PersonContactId, Account.Status__c, Account.Previous_Account_Rule__c, Account.Account_Rule_Code__c, Account.Subscription_Start_Date__c, Account.Is_Qualify_Agent_Referral_Program__c, Account.Referrer_Agent__c, Account.Current_Subscription_Code__c, Account.PG_Tenure__c, opportunity.Pricebook2Id, Country__c
                     ,opportunity.Order_Type_Clone__c, to_VIP_Approval__c, to_Managerial_Approval__c, to_FOC_Approval__c, Status, Approval_Status__c, CurrencyIsoCode from Quote LIMIT 1];
 //       ProductSelectionLightningPageController.saveQliData(qu1.Id,listquoteLine,pbe2.Pricebook2Id,'SGD');
        Upgrade_Package_Lookup__c UGP = new Upgrade_Package_Lookup__c(Country__c=qu1.Account.Country__c,Name='Advance',Upgrade_SKU__c='MY01P3456r',Renewal_SKU__c='MY01P3456r',level__c = 1,isActive__c = true);
        insert UGP;
        Upgrade_Package_Lookup__c UGP2 = new Upgrade_Package_Lookup__c(Country__c=qu1.Account.Country__c,Name='Standard',Upgrade_SKU__c='PG01P5702S',Renewal_SKU__c='PG01P5702S',level__c = 2,isActive__c = true);
        insert UGP2;
        
        ProductSelectionLightningPageController.getRenewalOptions(qu1.Id);
        Test.stopTest();
        }
    }
    @isTest
    public static void ProductSelectionMethod2(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Thailand' and isActive = true and profile.name = 'TH B2C Sales User' Limit 1];
        System.runAs(thisuser){
        Trigger_Execute__c TE1 = new Trigger_Execute__c();
        TE1.Name = 'PGAccountTrigger';
        TE1.Enable_del__c = true;
        insert TE1;
        
        Trigger_Execute__c TEOppSplit=new Trigger_Execute__c();
        TEOppSplit.Name='Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c=true;
        insert TEOppSplit;
         id subId = PGTestDataFactory.createSubsidiary().Id;
         string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Thailand';
        agency.Subsidiary__c = subId;  
        
        Media__c newMedia = new Media__c();
        newMedia.Account__c = agency.id;
        newMedia.CurrencyIsoCode = 'THB';
        newMedia.IsActive__c = True;
        insert newMedia;
        
        Blob bodyblob = Blob.valueOf('PG Agency default');
        Contentversion cv = new contentversion(title ='PG Agency default',PathOnClient ='PG Agency default.jpg',versiondata = bodyblob,origin ='H');
        insert cv;
        
        ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conVersion.ContentDocumentId;
        cdl.LinkedEntityId = newMedia.id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers'; 
        insert cdl;
        
        insert agency;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
            
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
         a.BillingCountry = 'Thailand';
        a.BillingPostalCode = '83735';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'Advance';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Thailand';
        a.Mobile_Country__c= '65';
        a.PersonMobilePhone='1234577899';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'S674534K';
        a.VIP_Campaign__c = 'TestNameCampaign';
        a.VIP__c = true;
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
         Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        //opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.Opportunity_Type__c = 'B2C - Renewal';
        insert opp;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book',  IsActive = true, CurrencyIsoCode = 'THB');
        insert standardPB;
            
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'THB');
        insert productClass;
            
         Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'THB',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test',  Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Advance', CurrencyIsoCode = 'THB',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'PG01P5702S', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'THB', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'THB', useStandardPrice = false);
        insert pbe2;
        
         Trigger_Execute__c PGCampMemberTrigger = new Trigger_Execute__c();
        PGCampMemberTrigger.Name = 'PGCampMemberTrigger';
        PGCampMemberTrigger.Enable_del__c = true;
        insert PGCampMemberTrigger;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampaignEligibilityTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
            
        Trigger_Execute__c QutLineItem = new Trigger_Execute__c();
        QutLineItem.Name = 'QuoteLineItemTrigger';
        QutLineItem.Enable_del__c = true;
        insert QutLineItem;
        
        
        
      /*  Campaign parentCma = new Campaign();
        parentCma.Name = 'TestNameCampaign1';
        parentCma.Country__c = 'Thailand';
        parentCma.StartDate = system.today().addDays(-2);
        parentCma.EndDate = system.today().addDays(2);
        parentCma.IsActive = true;
        parentCma.CurrencyIsoCode = 'THB';
        parentCma.Status = 'Active';
        insert parentCma;
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Thailand';
        cma.StartDate = system.today().addDays(-2);
        cma.EndDate = system.today().addDays(2);
        cma.Status= 'Approved';
        cma.CurrencyIsoCode = 'THB';
        cma.ParentId = parentCma.Id;
        cma.IsActive = true;
        
        insert cma;
        
        CampaignMemberStatus cms = new CampaignMemberStatus(); //its an object
        cms.Label = 'Approved';
        cms.CampaignId = cma.Id;
        insert cms;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = [select Id,Account.PersonContactId from Opportunity where Id = :opp.Id LIMIT 1].Account.PersonContactId;
        cmp.Status = 'Approved';
        cmp.CampaignId = parentCma.Id;
        insert cmp;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;
       
        
        Promo_Mechanic__c prm = new Promo_Mechanic__c(); // child of Campaign_Eligibility__c & Product  
        prm.Name = 'TestName';
        prm.Usage__c = -1;
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Status__c = 'Active';
        insert prm;
        Promo_Mechanic__c prm2 = new Promo_Mechanic__c();
        prm2.Name = 'TestName';
        prm2.Eligible_Product__c = prod.Id;
        prm2.Campaign_Eligibility__c = ce1.Id;
        prm2.Status__c = 'Active';
        prm2.Usage__c = -1;
        insert prm2;*/
        
        
        
        
        Test.startTest();
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Quantity = 500;
         oli.Start_Date__c= system.today();
         oli.End_Date__c =system.today().adddays(1);
        oli.UnitPrice = 10000;
        //oli.Parent_Id__c ='demoparentid';
        insert oli;
        listOppLine.add(oli);
        //listOppLine.add(oli);
        //Insert listOppLine;
        opportunityLineItem oli1 = new opportunityLineItem();
        oli1.Product2Id = prod.Id;
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbe2.Id;
        //oli1.Quantity= 6;
        oli1.Parent__c = oli.Id;
        
        oli1.Parent_Id__c = oli.Id;
        listOppLine.add(oli1);
        
        Quote objQuote=new Quote();
        objQuote.OpportunityId=opp.Id;
        objQuote.CreatedDate__c=system.today();
        objQuote.name='test';
        objQuote.Status='Proposal';
        objQuote.PriceBook2Id = standardPB.Id;
        objQuote.Celigo_Account__c = a.Id;
        //objQuote.Record_Eligibility__c = 'VR_Validate_Agent_Status';
        insert objQuote;
        
         List<quoteLineItem> listquoteLine = new List<quoteLineItem>();
        quoteLineItem qli = new quoteLineItem();
        qli.Product2Id = prod.Id;
        qli.QuoteId = objQuote.Id;
        qli.PricebookEntryId = pbe2.Id;
        qli.Start_Date__c = System.today();
        qli.UnitPrice = 45;
        qli.Quantity = 3;
        insert qli;
        listquoteLine.add(qli);
        quoteLineItem qli1 = new quoteLineItem();
        qli1.Product2Id = prod.Id;
        qli1.QuoteId = objQuote.Id;
        qli1.PricebookEntryId = pbe2.Id;
        qli1.Parent__c = qli.Id;
        qli1.Parent_Id__c = qli.Id;
        qli1.UnitPrice = 23;
        qli1.Quantity = 7;
        insert qli1;
        listquoteLine.add(qli1);
       // Test.startTest();
        ProductSelectionLightningPageController.getRenewalOptions(objQuote.Id);
        ProductSelectionLightningPageController.saveOliData(opp.Id,listOppLine);
        ProductSelectionLightningPageController.getAvailableProductAndPromo(standardPB.Id,'SGD','Test',opp.Id,objQuote.Id);
        ProductSelectionLightningPageController.oliAndDefaultPromoList(opp.Id,'');
        ProductSelectionLightningPageController.saveQliData(objQuote.Id,listquoteLine,standardPB.Id,'SGD');
        
        Quote qu1 = [select Id, Name, Celigo_Account__c, Account.Name,Account.VIP__c,Account.Approval_Status__c,Account.Loyalty_Start_Date__c, Account.Country__c, Account.CEA_Salesperson_Number__c, Account.PersonContactId, Account.Status__c, Account.Previous_Account_Rule__c, Account.Account_Rule_Code__c, Account.Subscription_Start_Date__c, Account.Is_Qualify_Agent_Referral_Program__c, Account.Referrer_Agent__c, Account.Current_Subscription_Code__c, Account.PG_Tenure__c, opportunity.Pricebook2Id, Country__c
                     ,opportunity.Order_Type_Clone__c, to_VIP_Approval__c, to_Managerial_Approval__c, to_FOC_Approval__c, Status, Approval_Status__c, CurrencyIsoCode from Quote LIMIT 1];
 //       ProductSelectionLightningPageController.saveQliData(qu1.Id,listquoteLine,pbe2.Pricebook2Id,'SGD');
        Upgrade_Package_Lookup__c UGP = new Upgrade_Package_Lookup__c(Country__c=qu1.Account.Country__c,Name='Advance',Upgrade_SKU__c='MY01P3456r',Renewal_SKU__c='MY01P3456r',level__c = 1,isActive__c = true);
        insert UGP;
        Upgrade_Package_Lookup__c UGP2 = new Upgrade_Package_Lookup__c(Country__c=qu1.Account.Country__c,Name='Standard',Upgrade_SKU__c='PG01P5702S',Renewal_SKU__c='PG01P5702S',level__c = 2,isActive__c = true);
        insert UGP2;
        
        ProductSelectionLightningPageController.getRenewalOptions(qu1.Id);
        Test.stopTest();
    }
    }
    
    @isTest
    public static void ProductSelectionMethod3(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' Limit 1];
        System.runAs(thisuser){
        Trigger_Execute__c TE1 = new Trigger_Execute__c();
        TE1.Name = 'PGAccountTrigger';
        TE1.Enable_del__c = true;
        insert TE1;
        
        Trigger_Execute__c TEOppSplit=new Trigger_Execute__c();
        TEOppSplit.Name='Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c=true;
        insert TEOppSplit;
         id subId = PGTestDataFactory.createSubsidiary().Id;
         string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId; 
        
        
        
        Media__c newMedia = new Media__c();
        newMedia.Account__c = agency.id;
        newMedia.CurrencyIsoCode = 'SGD';
        newMedia.IsActive__c = True;
        insert newMedia;
        
        Blob bodyblob = Blob.valueOf('PG Agency default');
        Contentversion cv = new contentversion(title ='PG Agency default',PathOnClient ='PG Agency default.jpg',versiondata = bodyblob,origin ='H');
        insert cv;
        
            
        ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conVersion.ContentDocumentId;
        cdl.LinkedEntityId = newMedia.id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers'; 
        insert cdl;
        
        insert agency;
   
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
         a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '83735';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'Advance';
        a.Previous_Account_Rule__c = 'trial';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Mobile_Country__c= '66';
        a.PersonMobilePhone='1234577899';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'S674534K';
        a.VIP_Campaign__c = 'TestNameCampaign';
        a.VIP__c = true;
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
       
         Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        //opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.Opportunity_Type__c = 'B2C - Renewal';
        insert opp;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book',  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        Product2 prod2 = new Product2(Name = 'Standard', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'MY01P3456r',Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'LY01P3456P',  Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true, Revised_Product__c =prod2.Id,Effective_till__c =null);
        insert prod;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod2.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.id, product2id=prod2.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
         Trigger_Execute__c PGCampMemberTrigger = new Trigger_Execute__c();
        PGCampMemberTrigger.Name = 'PGCampMemberTrigger';
        PGCampMemberTrigger.Enable_del__c = true;
        insert PGCampMemberTrigger;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampaignEligibilityTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
            
        Trigger_Execute__c QutLineItem = new Trigger_Execute__c();
        QutLineItem.Name = 'QuoteLineItemTrigger';
        QutLineItem.Enable_del__c = true;
        insert QutLineItem;
        
        
  /*      
        Campaign parentCma = new Campaign();
        parentCma.Name = 'TestNameCampaign1';
        parentCma.Country__c = 'Thailand';
        parentCma.StartDate = system.today().addDays(-2);
        parentCma.EndDate = system.today().addDays(2);
        parentCma.IsActive = true;
        parentCma.CurrencyIsoCode = 'THB';
        parentCma.Status = 'Approved';
        insert parentCma;
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Thailand';
        cma.StartDate = system.today().addDays(-2);
        cma.EndDate = system.today().addDays(2);
        cma.Status= 'Approved';
        cma.CurrencyIsoCode = 'THB';
        cma.ParentId = parentCma.Id;
        cma.IsActive = true;
        
        insert cma;
        
        CampaignMemberStatus cms = new CampaignMemberStatus(); //its an object
        cms.Label = 'Approved';
        cms.CampaignId = cma.Id;
        insert cms;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = [select Id,Account.PersonContactId from Opportunity where Id = :opp.Id LIMIT 1].Account.PersonContactId;
        cmp.Status = 'Approved';
        cmp.CampaignId = parentCma.Id;
        insert cmp;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;
       
        
        Promo_Mechanic__c prm = new Promo_Mechanic__c(); // child of Campaign_Eligibility__c & Product  
        prm.Name = 'TestName';
        prm.Usage__c = -1;
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Status__c = 'Active';
        insert prm;
        Promo_Mechanic__c prm2 = new Promo_Mechanic__c();
        prm2.Name = 'TestName';
        prm2.Eligible_Product__c = prod.Id;
        prm2.Campaign_Eligibility__c = ce1.Id;
        prm2.Status__c = 'Active';
        prm2.Usage__c = -1;
        insert prm2;
        
  */      
        
        
        Test.startTest();
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod2.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Quantity = 500;
         oli.Start_Date__c= system.today();
         oli.End_Date__c =system.today().adddays(1);
        oli.UnitPrice = 10000;
        //oli.Parent_Id__c ='demoparentid';
        insert oli;
        listOppLine.add(oli);
        //listOppLine.add(oli);
        //Insert listOppLine;
        opportunityLineItem oli1 = new opportunityLineItem();
        oli1.Product2Id = prod2.Id;
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbe2.Id;
        //oli1.Quantity= 6;
        oli1.Parent__c = oli.Id;
        
        oli1.Parent_Id__c = oli.Id;
        listOppLine.add(oli1);
        
        Quote objQuote=new Quote();
        objQuote.OpportunityId=opp.Id;
        objQuote.CreatedDate__c=system.today();
        objQuote.name='test';
        objQuote.Status='Proposal';
        objQuote.PriceBook2Id = pbe2.Pricebook2Id/*standardPB.Id*/;
        objQuote.Celigo_Account__c = a.Id;
        objQuote.CurrencyIsoCode = 'SGD';    
        //objQuote.Record_Eligibility__c = 'VR_Validate_Agent_Status';
        insert objQuote;
 
         List<quoteLineItem> listquoteLine = new List<quoteLineItem>();
        quoteLineItem qli = new quoteLineItem();
        qli.Product2Id = prod.Id;
        qli.QuoteId = objQuote.Id;
        qli.PricebookEntryId = pbe2.Id;
        qli.Start_Date__c = System.today();
        qli.UnitPrice = 45;
        qli.Quantity = 3;
        insert qli;
        listquoteLine.add(qli);
        quoteLineItem qli1 = new quoteLineItem();
        qli1.Product2Id = prod.Id;
        qli1.QuoteId = objQuote.Id;
        qli1.PricebookEntryId = pbe2.Id;
        qli1.Parent__c = qli.Id;
        qli1.Parent_Id__c = qli.Id;
        qli1.UnitPrice = 23;
        qli1.Start_Date__c = system.today();
        qli1.Quantity = 7;
        qli1.Discount_Reason__c = 'Marketing Promo';
        insert qli1;
        listquoteLine.add(qli1); 
        //insert listquoteLine;
       // Test.startTest();
        Upgrade_Package_Lookup__c UGP = new Upgrade_Package_Lookup__c(Country__c='Singapore' ,Name='Standard',Upgrade_SKU__c='MY01P3456r',Renewal_SKU__c='MY01P3456r',level__c = 1, IsActive__c =true);
        insert UGP;
        Upgrade_Package_Lookup__c UGP2 = new Upgrade_Package_Lookup__c(Country__c='Singapore',Name='Advance',Upgrade_SKU__c='MY01P3456q',Renewal_SKU__c='MY01P3456q',level__c = 2,isActive__c = true);
        insert UGP2;

        ProductSelectionLightningPageController.getRenewalOptions(objQuote.Id);
        ProductSelectionLightningPageController.saveOliData(opp.Id,listOppLine);
        ProductSelectionLightningPageController.getAvailableProductAndPromo(standardPB.Id,'SGD','Test',opp.Id,objQuote.Id);
        ProductSelectionLightningPageController.oliAndDefaultPromoList(opp.Id,objQuote.Id);
        ProductSelectionLightningPageController.saveQliData(objQuote.Id,listquoteLine,standardPB.Id,'SGD');
        Test.stopTest();
    }
    }
    
    @isTest
    public static void ProductSelectionMethod4(){
        
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        PGTestDataFactory_v2.initSetupData();
         //PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        
       /* Trigger_Execute__c objcustom3=new Trigger_Execute__c();
        objcustom3.Name='Trigger_OpportunityLineItem';
        objcustom3.Enable_del__c=true;
        insert objcustom3;*/
        list<Account> listAccount1 = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
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
        
        ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conVersion.ContentDocumentId;
        cdl.LinkedEntityId = newMedia.id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers'; 
        insert cdl;

        insert listAccount1;
        
        
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        insert objcustom;
        
        Trigger_Execute__c TEOppSplit=new Trigger_Execute__c();
        TEOppSplit.Name='Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c=true;
        insert TEOppSplit;
            
        Trigger_Execute__c objcustom2=new Trigger_Execute__c();
        objcustom2.Name='QuoteLineItemTrigger';
        objcustom2.Enable_del__c=true;
        insert objcustom2;
        
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
        a.Agency__c = listAccount1[0].Id;
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
        a.CEA_Salesperson_Number__c = 'A123456G';
        a.VIP_Campaign__c = 'TestNameCampaign';
        a.VIP__c = true;
        a.Mobile_Country__c = '66';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'PG01P5702S', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'PG02B5721S', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod2.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod2.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
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
        opp.Opportunity_Type__c = 'B2C - Standard';
        insert opp;
        
        Quote objQuote=new Quote();
        objQuote.OpportunityId=opp.Id;
        objQuote.CreatedDate__c=system.today();
        objQuote.name='test';
        objQuote.Status='Proposal';
        objQuote.PriceBook2Id = standardPB.Id;
        objQuote.Celigo_Account__c = a.Id;
        //objQuote.Record_Eligibility__c = 'VR_Validate_Agent_Status';
        insert objQuote;
        system.debug('check'+ objQuote);
        Item_Bundle__c bundle = new Item_Bundle__c();
        bundle.Qty__c = 3;
        bundle.Parent_Product__c = prod.id/*pbe1.Product2Id*/;
        bundle.Child_Product__c = pbe1.Product2Id;
        insert bundle;
            
           
        string campaignPromoRectype = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Marketing Promo').getRecordTypeId();
        
        Trigger_Execute__c PGCampMemberTrigger = new Trigger_Execute__c();
        PGCampMemberTrigger.Name = 'PGCampMemberTrigger';
        PGCampMemberTrigger.Enable_del__c = true;
        insert PGCampMemberTrigger;
        
        
        Trigger_Execute__c PGCampaignTrigger = new Trigger_Execute__c();
        PGCampaignTrigger.Name = 'PGCampaignTrigger';
        PGCampaignTrigger.Enable_del__c = true;
        insert PGCampaignTrigger;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampaignEligibilityTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
        
        Trigger_Execute__c TEEntPromo = new Trigger_Execute__c();
        TEEntPromo.Name = 'PGEntitlementPromoTrigger';
        TEEntPromo.Enable_del__c = true;
        insert TEEntPromo;
        
 /*       
        Campaign c = new campaign();
        c.RecordTypeId = campaignPromoRectype;
        c.Name = 'test campaign';
        c.Country__c = 'Singapore';
        c.IsActive = true;
        c.StartDate = system.today().addDays(-2);
        c.EndDate = system.today().addDays(2);
        c.Campaign_End_DateTime__c = system.today().addDays(2);
         c.Campaign_Start_DateTime__c = system.today().addDays(-2);
			insert c;
*/
 /*       
        Campaign renewal_c = new campaign();
        renewal_c.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Renewal Promotion').getRecordTypeId();
        renewal_c.Name = 'test renewal campaign';
        renewal_c.Country__c = 'Singapore';
        renewal_c.IsActive = true;
        insert renewal_c;
  */      
        /*list<Promotion_Discount_Value__c> listRenewalPDV = new list<Promotion_Discount_Value__c>();
        Promotion_Discount_Value__c pdv1 = new Promotion_Discount_Value__c();
        pdv1.Campaign__c = renewal_c.id;
        pdv1.Unit_Price__c = 10;
        pdv1.Quantity__c = 10;
        pdv1.Product_Reference__c = prod2.id;
        pdv1.Product__c = prod.id;
        pdv1.Qty__c = 3;
        pdv1.RecordTypeId = Schema.SObjectType.Promotion_Discount_Value__c.getRecordTypeInfosByName().get('Renewal Promotion').getRecordTypeId();
        listRenewalPDV.add(pdv1);
        
        Promotion_Discount_Value__c pdv2 = new Promotion_Discount_Value__c();
        pdv2.Campaign__c = renewal_c.id;
        pdv2.Unit_Price__c = 10;
        pdv2.Quantity__c = 10;
        pdv2.Product_Reference__c = prod.id;
        pdv2.Product__c = prod2.id;
        pdv2.Qty__c = 32;
        pdv2.RecordTypeId = Schema.SObjectType.Promotion_Discount_Value__c.getRecordTypeInfosByName().get('Renewal Promotion').getRecordTypeId();
        listRenewalPDV.add(pdv2);
        
        insert listRenewalPDV;        */
/*
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = c.id;
        cm.ContactId = [select Id,Account.PersonContactId from Opportunity where Id = :opp.Id LIMIT 1].Account.PersonContactId;
        insert cm;
 */       
        /*list<Tier_Pricing__c> listTP = new list<Tier_Pricing__c>();
        Tier_Pricing__c tp = new Tier_Pricing__c();
        tp.Campaign__c = c.id;
        tp.Name = 'test tier pricing';
        tp.Product_Reference__c = prod2.id;
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
 /*       
        Campaign parentCma = new Campaign();
        parentCma.Name = 'TestNameCampaign1';
        parentCma.Country__c = 'Singapore';
        parentCma.StartDate = system.today().addDays(-2);
        parentCma.EndDate = system.today().addDays(2);
        parentCma.IsActive = true;
        parentCma.Status = 'Active';
        insert parentCma;
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.StartDate = system.today().addDays(-2);
        cma.EndDate = system.today().addDays(2);
        cma.ParentId = parentCma.Id;
        cma.IsActive = true;
        
        insert cma;
        
        CampaignMemberStatus cms = new CampaignMemberStatus();
        cms.Label = 'Approved';
        cms.CampaignId = cma.Id;
        insert cms;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = [select Id,Account.PersonContactId from Opportunity where Id = :opp.Id LIMIT 1].Account.PersonContactId;
        cmp.Status = 'Approved';
        cmp.CampaignId = cma.Id;
        insert cmp;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;

*/
/*        
        Promo_Mechanic__c prm = new Promo_Mechanic__c();
        prm.Name = 'TestName';
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Usage__c = -1;
        prm.Status__c = 'Active';
        insert prm;
        Promo_Mechanic__c prm2 = new Promo_Mechanic__c();
        prm2.Name = 'TestName';
        prm2.Status__c = 'Active';
        prm2.Usage__c = -1;
        prm2.Eligible_Product__c = prod.Id;
        prm2.Campaign_Eligibility__c = ce1.Id;
        insert prm2;
 */       
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Quantity = 500;
         oli.Start_Date__c= system.today();
         oli.End_Date__c =system.today().adddays(1);
        oli.UnitPrice = 10000;
        oli.Parent_Id__c = 'hs4s4';
        insert oli;
        listOppLine.add(oli);
        //listOppLine.add(oli);
        //Insert listOppLine;
        opportunityLineItem oli1 = new opportunityLineItem();
        oli1.Product2Id = prod2.Id;
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbe2.Id;
        //oli1.Quantity= 6;
        oli1.Parent__c = oli.Id;
        oli1.Parent_Id__c = 'hs415s4';
        //oli1.Parent_Id__c = oli.Id;
        listOppLine.add(oli1);
        //Insert listOppLine;
        
        Trigger_Execute__c tef = new Trigger_Execute__c();
        tef.Name = 'QuoteLineItemTrigger';
        tef.Enable_del__c = false;
        insert tef;
/*            
        List<quoteLineItem> listquoteLine = new List<quoteLineItem>();
        quoteLineItem qli = new quoteLineItem();
        qli.Product2Id = prod.Id;
        qli.QuoteId = objQuote.Id;
        qli.PricebookEntryId = pbe2.Id;
        qli.Start_Date__c = System.today();
        qli.UnitPrice = 45;
        qli.Quantity = 3;
        insert qli;
        listquoteLine.add(qli);
        quoteLineItem qli1 = new quoteLineItem();
        qli1.Product2Id = prod2.Id;
        qli1.QuoteId = objQuote.Id;
        qli1.PricebookEntryId = pbe2.Id;
        qli1.Parent__c = qli.Id;
        qli1.Parent_Id__c = qli.Id;
        qli1.UnitPrice = 23;
        qli1.Quantity = 7;
        listquoteLine.add(qli1);
 */       
  //     Trigger_Execute__c tef = new Trigger_Execute__c(Name = 'QuoteLineItemTrigger');
  //      insert tef;
        
        ProductSelectionLightningPageController.OppLineItemTmp oplt = new ProductSelectionLightningPageController.OppLineItemTmp();
        system.assertEquals(null, oplt.ChildCategory, 'Invalid ChildCategory.');
        oplt.Id = '53454';
        oplt.Product2Id = 'test';
        oplt.Line_Description2 = 'test';
        oplt.UnitPrice = 2;
        oplt.Product_Type = 'type'; 
        oplt.Quantity=4;
        oplt.Complimentary=true;
        oplt.Parent='test';
        oplt.DiscountReason ='test';
        
 /*       ProductSelectionLightningPageController.DiscountInfo ds = new ProductSelectionLightningPageController.DiscountInfo();
        system.assertEquals(null, ds.BonusProductName, 'Invalid BonusProductName');
        ds.Name = 'Test';
        ds.BonusPrice = 2;
        ds.Description = 'DescriptionTest';
        ds.DiscountAmount = 200;
        ds.DiscountUnitPrice = 200;
        ds.BonusProduct = '2';
        ds.BonusProductName = 'test';
        ds.BonusQty = 7;
        ds.ProductType = 'test';
        ds.ProductDescription = 'test';
        ds.PricebookEntryId = pbe2.id;
        ds.CampaignId = c.id;
        ds.DiscountReason = 'test';
        ds.TaxCode = 'TaxCode';
        ds.TaxRate = 2;
        ds.Denomination = 3;
        ds.AccountName = 'AccountName';
        ds.renewalType = 'renewalType';
        ds.DiscountPercentage = 1;
        ds.MaxQuantity = 2.9;
        ds.MinQuantity = 1.2;
        ds.Quantity = 1;
        ds.Operator = 'Operator';
        ds.ProductReference = 'ProductReference';
 */      
          ProductSelectionLightningPageController.DiscountInfo discount = new ProductSelectionLightningPageController.DiscountInfo();

       
        discount.Name = 'Test Discount';
        discount.Description = 'Test Description';
        discount.IsAny = true;
        discount.recordType = 'Test Record Type';
        discount.PricebookEntryId = 'Test Pricebook Entry Id';
        discount.ProductReference = 'Test Product Reference';
        discount.Operator = 'Test Operator';
        discount.Quantity = 2;
        discount.MinQuantity = 1;
        discount.MaxQuantity = 10;
        discount.DiscountPercentage = 10;
        discount.DiscountAmount = 5;
        discount.DiscountUnitPrice = 100;
        discount.BonusProduct = 'Test Bonus Product';
        discount.BonusProductName = 'Test Bonus Product Name';
        discount.BonusQty = 1;
        discount.BonusPrice = 50;
        discount.ProductType = 'Test Product Type';
        discount.ProductDescription = 'Test Product Description';
        discount.CampaignId = 'Test Campaign Id';
        discount.IsLoyalty = false;
        discount.IsTier = true;
        discount.DiscountReason = 'Test Discount Reason';
        discount.DiscountReasonChild = 'Test Discount Reason Child';
        discount.ChildCategory = 'Test Child Category';
        discount.TaxCode = 'Test Tax Code';
        discount.TaxRate = 5;
        discount.EligibleVip = 'Test Eligible VIP';
        discount.Denomination = 10;
        discount.AccountName = 'Test Account Name';
        discount.renewalType = 'Test Renewal Type';

        // Call the methods of the DiscountInfo class to test its functionality
        System.assertEquals('Test Discount', discount.Name);
        System.assertEquals('Test Description', discount.Description);
        System.assertEquals(true, discount.IsAny);
        System.assertEquals('Test Record Type', discount.recordType);
        System.assertEquals('Test Pricebook Entry Id', discount.PricebookEntryId);
        System.assertEquals('Test Product Reference', discount.ProductReference);
        System.assertEquals('Test Operator', discount.Operator);
        System.assertEquals(2, discount.Quantity);
        System.assertEquals(1, discount.MinQuantity);
        System.assertEquals(10, discount.MaxQuantity);
        System.assertEquals(10, discount.DiscountPercentage);
        System.assertEquals(5, discount.DiscountAmount);
        System.assertEquals(100, discount.DiscountUnitPrice);
        System.assertEquals('Test Bonus Product', discount.BonusProduct);
        System.assertEquals('Test Bonus Product Name', discount.BonusProductName);
        System.assertEquals(1, discount.BonusQty);
        System.assertEquals(50, discount.BonusPrice);
        System.assertEquals('Test Product Type', discount.ProductType);
        System.assertEquals('Test Product Description', discount.ProductDescription);
        System.assertEquals('Test Campaign Id', discount.CampaignId);
        System.assertEquals(false, discount.IsLoyalty);
        System.assertEquals(true, discount.IsTier);
        System.assertEquals('Test Discount Reason', discount.DiscountReason);
        System.assertEquals('Test Discount Reason Child', discount.DiscountReasonChild);
     //   System.assertEquals('Test Child Category', discount.Child);
  
        Test.startTest();
        Opportunity opp1 = [select Id, Name, AccountId, Account.Name,Account.VIP__c,Account.Approval_Status__c,Account.Loyalty_Start_Date__c, Account.Country__c, Account.CEA_Salesperson_Number__c, Account.PersonContactId, Account.Status__c, Account.Previous_Account_Rule__c, Account.Account_Rule_Code__c, Account.Subscription_Start_Date__c, Account.Is_Qualify_Agent_Referral_Program__c, Account.Referrer_Agent__c, Account.Current_Subscription_Code__c, Account.PG_Tenure__c, Pricebook2Id, PG_Tenure__c, Total_Spending__c, Subsidiary__c, Country__c,
                            Order_Type_Clone__c, to_VIP_Approval__c, to_Managerial_Approval__c, to_FOC_Approval__c, StageName, Approval_Status__c, CurrencyIsoCode, CloseDate from Opportunity LIMIT 1];
        ProductSelectionLightningPageController.getUserInfoAndOppRecord(objQuote.Id);
        ProductSelectionLightningPageController.getAvailableProductAndPromo(standardPB.Id,'SGD','Test',opp.Id,objQuote.Id);
        ProductSelectionLightningPageController.oliAndDefaultPromoList(opp.Id,objQuote.Id);
        ProductSelectionLightningPageController.saveOliData(opp.Id,listOppLine);
   //     ProductSelectionLightningPageController.getUserInfoAndOppRecord(objQuote.OpportunityId);
        ProductSelectionLightningPageController.getPickListValue('Account', 'Rating');
        ProductSelectionLightningPageController.getListData('Id','Name','Account');
        ProductSelectionLightningPageController.getListEligiblePromotion(opp1);
        ProductSelectionLightningPageController.getChild(pbe2.Pricebook2Id, prod.Id);
        //ProductSelectionLightningPageController.getTierPricingInfo(new List<ProductSelectionLightningPageController.DiscountInfo>{ds},'Singapore');
        //ProductSelectionLightningPageController.getDiscountInfo(opp1,new List<ProductSelectionLightningPageController.DiscountInfo>{ds});
        Quote qu1 = [select Id, Name, Celigo_Account__c, Account.Name,Account.VIP__c,Account.Approval_Status__c,Account.Loyalty_Start_Date__c, Account.Country__c, Account.CEA_Salesperson_Number__c, Account.PersonContactId, Account.Status__c, Account.Previous_Account_Rule__c, Account.Account_Rule_Code__c, Account.Subscription_Start_Date__c, Account.Is_Qualify_Agent_Referral_Program__c, Account.Referrer_Agent__c, Account.Current_Subscription_Code__c, Account.PG_Tenure__c, opportunity.Pricebook2Id, Country__c
                     ,opportunity.Order_Type_Clone__c, to_VIP_Approval__c, to_Managerial_Approval__c, to_FOC_Approval__c, Status, Approval_Status__c, CurrencyIsoCode from Quote LIMIT 1];
 //       ProductSelectionLightningPageController.saveQliData(qu1.Id,listquoteLine,pbe2.Pricebook2Id,'SGD');
        Upgrade_Package_Lookup__c UGP = new Upgrade_Package_Lookup__c(Country__c=qu1.Account.Country__c,Name='test',Upgrade_SKU__c='MY01P3456r',Renewal_SKU__c='LY01P3456P',level__c = 2);
        insert UGP;
        
        ProductSelectionLightningPageController.getRenewalOptions(qu1.Id);
        Test.stopTest();
        }
    }
    
    @isTest
    public static void ProductSelectionMethod5(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' Limit 1];
        System.runAs(thisuser){
        Trigger_Execute__c TE1 = new Trigger_Execute__c();
        TE1.Name = 'PGAccountTrigger';
        TE1.Enable_del__c = true;
        insert TE1;
        
        Trigger_Execute__c TEOppSplit=new Trigger_Execute__c();
        TEOppSplit.Name='Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c=true;
        insert TEOppSplit;
         id subId = PGTestDataFactory.createSubsidiary().Id;
         string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId; 
        
        
        
        Media__c newMedia = new Media__c();
        newMedia.Account__c = agency.id;
        newMedia.CurrencyIsoCode = 'SGD';
        newMedia.IsActive__c = True;
        insert newMedia;
        
        Blob bodyblob = Blob.valueOf('PG Agency default');
        Contentversion cv = new contentversion(title ='PG Agency default',PathOnClient ='PG Agency default.jpg',versiondata = bodyblob,origin ='H');
        insert cv;
        
            
        ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conVersion.ContentDocumentId;
        cdl.LinkedEntityId = newMedia.id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers'; 
        insert cdl;
        
        insert agency;
            Date myDate = Date.today();
            Date newDate = myDate.addYears(-2);
            
            
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
         a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '83735';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'trial';
        a.Previous_Account_Rule__c = 'trial';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Mobile_Country__c= '66';
        a.PersonMobilePhone='1234577899';
        a.Subscription_End_Date__c = Date.newInstance(1996, 12, 21) /*system.today().addMonths(-9)*/;//2022-09-18  2023-02-23
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'S674534K';
        a.VIP_Campaign__c = 'TestNameCampaign';
        a.VIP__c = true;
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
       
         Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        //opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.Opportunity_Type__c = 'B2C - Renewal';
        insert opp;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book',  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'LY01P3456P',Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'LY01P3456P',  Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true, Revised_Product__c =prod2.Id,Effective_till__c =null /*Date.newInstance(2024, 12, 21)*/);
        insert prod;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
         Trigger_Execute__c PGCampMemberTrigger = new Trigger_Execute__c();
        PGCampMemberTrigger.Name = 'PGCampMemberTrigger';
        PGCampMemberTrigger.Enable_del__c = true;
        insert PGCampMemberTrigger;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampaignEligibilityTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
            
        Trigger_Execute__c QutLineItem = new Trigger_Execute__c();
        QutLineItem.Name = 'QuoteLineItemTrigger';
        QutLineItem.Enable_del__c = true;
        insert QutLineItem;
        
        
  /*      
        Campaign parentCma = new Campaign();
        parentCma.Name = 'TestNameCampaign1';
        parentCma.Country__c = 'Thailand';
        parentCma.StartDate = system.today().addDays(-2);
        parentCma.EndDate = system.today().addDays(2);
        parentCma.IsActive = true;
        parentCma.CurrencyIsoCode = 'THB';
        parentCma.Status = 'Approved';
        insert parentCma;
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Thailand';
        cma.StartDate = system.today().addDays(-2);
        cma.EndDate = system.today().addDays(2);
        cma.Status= 'Approved';
        cma.CurrencyIsoCode = 'THB';
        cma.ParentId = parentCma.Id;
        cma.IsActive = true;
        
        insert cma;
        
        CampaignMemberStatus cms = new CampaignMemberStatus(); //its an object
        cms.Label = 'Approved';
        cms.CampaignId = cma.Id;
        insert cms;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = [select Id,Account.PersonContactId from Opportunity where Id = :opp.Id LIMIT 1].Account.PersonContactId;
        cmp.Status = 'Approved';
        cmp.CampaignId = parentCma.Id;
        insert cmp;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;
       
        
        Promo_Mechanic__c prm = new Promo_Mechanic__c(); // child of Campaign_Eligibility__c & Product  
        prm.Name = 'TestName';
        prm.Usage__c = -1;
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Status__c = 'Active';
        insert prm;
        Promo_Mechanic__c prm2 = new Promo_Mechanic__c();
        prm2.Name = 'TestName';
        prm2.Eligible_Product__c = prod.Id;
        prm2.Campaign_Eligibility__c = ce1.Id;
        prm2.Status__c = 'Active';
        prm2.Usage__c = -1;
        insert prm2;
        
  */      
        
        
        Test.startTest();
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Quantity = 500;
         oli.Start_Date__c= system.today();
         oli.End_Date__c =system.today().adddays(1);
        oli.UnitPrice = 10000;
        //oli.Parent_Id__c ='demoparentid';
        insert oli;
        listOppLine.add(oli);
        //listOppLine.add(oli);
        //Insert listOppLine;
        opportunityLineItem oli1 = new opportunityLineItem();
        oli1.Product2Id = prod.Id;
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbe2.Id;
        //oli1.Quantity= 6;
        oli1.Parent__c = oli.Id;
        
        oli1.Parent_Id__c = oli.Id;
        listOppLine.add(oli1);
        
        Quote objQuote=new Quote();
        objQuote.OpportunityId=opp.Id;
        objQuote.CreatedDate__c=system.today();
        objQuote.name='test';
        objQuote.Status='Proposal';
        objQuote.PriceBook2Id = pbe2.Pricebook2Id/*standardPB.Id*/;
        objQuote.Celigo_Account__c = a.Id;
        objQuote.CurrencyIsoCode = 'SGD';    
        //objQuote.Record_Eligibility__c = 'VR_Validate_Agent_Status';
        insert objQuote;
 
         List<quoteLineItem> listquoteLine = new List<quoteLineItem>();
        quoteLineItem qli = new quoteLineItem();
        qli.Product2Id = prod.Id;
        qli.QuoteId = objQuote.Id;
        qli.PricebookEntryId = pbe2.Id;
        qli.Start_Date__c = System.today();
        qli.UnitPrice = 45;
        qli.Quantity = 3;
        insert qli;
        listquoteLine.add(qli);
        quoteLineItem qli1 = new quoteLineItem();
        qli1.Product2Id = prod.Id;
        qli1.QuoteId = objQuote.Id;
        qli1.PricebookEntryId = pbe2.Id;
        qli1.Parent__c = qli.Id;
        qli1.Parent_Id__c = qli.Id;
        qli1.UnitPrice = 23;
        qli1.Quantity = 7;
        qli1.Discount_Reason__c = 'Marketing Promo';
        insert qli1;
        listquoteLine.add(qli1); 
    //    insert listquoteLine;
       // Test.startTest();
       Upgrade_Package_Lookup__c UGP = new Upgrade_Package_Lookup__c(Country__c='Singapore' ,Name='trial- SG',Upgrade_SKU__c='MY01P3456r',Renewal_SKU__c='LY01P3456P',level__c = 3, IsActive__c =true);
        insert UGP;

        ProductSelectionLightningPageController.getRenewalOptions(objQuote.Id);
        ProductSelectionLightningPageController.saveOliData(opp.Id,listOppLine);
        ProductSelectionLightningPageController.getAvailableProductAndPromo(standardPB.Id,'SGD','Test',opp.Id,objQuote.Id);
        ProductSelectionLightningPageController.oliAndDefaultPromoList(opp.Id,'');
        ProductSelectionLightningPageController.saveQliData(objQuote.Id,listquoteLine,standardPB.Id,'SGD');
        Test.stopTest();
    }
    }
   @isTest
    public static void ProductSelectionMethod6(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Malaysia' and isActive = true and profile.name = 'MY B2C Sales User' Limit 1];
        System.runAs(thisuser){
        Trigger_Execute__c TE1 = new Trigger_Execute__c();
        TE1.Name = 'PGAccountTrigger';
        TE1.Enable_del__c = true;
        insert TE1;
        
        Trigger_Execute__c TEOppSplit=new Trigger_Execute__c();
        TEOppSplit.Name='Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c=true;
        insert TEOppSplit;
         id subId = PGTestDataFactory.createSubsidiary().Id;
         string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Malaysia';
        agency.Subsidiary__c = subId;  
        
        Media__c newMedia = new Media__c();
        newMedia.Account__c = agency.id;
        newMedia.CurrencyIsoCode = 'MYR';
        newMedia.IsActive__c = True;
        insert newMedia;
        
        Blob bodyblob = Blob.valueOf('PG Agency default');
        Contentversion cv = new contentversion(title ='PG Agency default',PathOnClient ='PG Agency default.jpg',versiondata = bodyblob,origin ='H');
        insert cv;
        
        ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conVersion.ContentDocumentId;
        cdl.LinkedEntityId = newMedia.id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers'; 
        insert cdl;
        
        insert agency;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
            
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
         a.BillingCountry = 'Malaysia';
        a.BillingPostalCode = '83735';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'Advance';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Malaysia';
        a.Mobile_Country__c= '65';
        a.PersonMobilePhone='1234577899';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'S674534K';
        a.VIP_Campaign__c = 'TestNameCampaign';
        a.VIP__c = true;
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
         Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        //opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.Opportunity_Type__c = 'B2C - Renewal';
        insert opp;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book',  IsActive = true, CurrencyIsoCode = 'MYR');
        insert standardPB;
            
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'MYR');
        insert productClass;
            
         Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'MYR',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test',  Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Advance', CurrencyIsoCode = 'MYR',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'PG01P5702S', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'MYR', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'MYR', useStandardPrice = false);
        insert pbe2;
        
         Trigger_Execute__c PGCampMemberTrigger = new Trigger_Execute__c();
        PGCampMemberTrigger.Name = 'PGCampMemberTrigger';
        PGCampMemberTrigger.Enable_del__c = true;
        insert PGCampMemberTrigger;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampaignEligibilityTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
            
        Trigger_Execute__c QutLineItem = new Trigger_Execute__c();
        QutLineItem.Name = 'QuoteLineItemTrigger';
        QutLineItem.Enable_del__c = true;
        insert QutLineItem;
        
        
        
      /*  Campaign parentCma = new Campaign();
        parentCma.Name = 'TestNameCampaign1';
        parentCma.Country__c = 'Thailand';
        parentCma.StartDate = system.today().addDays(-2);
        parentCma.EndDate = system.today().addDays(2);
        parentCma.IsActive = true;
        parentCma.CurrencyIsoCode = 'THB';
        parentCma.Status = 'Active';
        insert parentCma;
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Thailand';
        cma.StartDate = system.today().addDays(-2);
        cma.EndDate = system.today().addDays(2);
        cma.Status= 'Approved';
        cma.CurrencyIsoCode = 'THB';
        cma.ParentId = parentCma.Id;
        cma.IsActive = true;
        
        insert cma;
        
        CampaignMemberStatus cms = new CampaignMemberStatus(); //its an object
        cms.Label = 'Approved';
        cms.CampaignId = cma.Id;
        insert cms;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = [select Id,Account.PersonContactId from Opportunity where Id = :opp.Id LIMIT 1].Account.PersonContactId;
        cmp.Status = 'Approved';
        cmp.CampaignId = parentCma.Id;
        insert cmp;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;
       
        
        Promo_Mechanic__c prm = new Promo_Mechanic__c(); // child of Campaign_Eligibility__c & Product  
        prm.Name = 'TestName';
        prm.Usage__c = -1;
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Status__c = 'Active';
        insert prm;
        Promo_Mechanic__c prm2 = new Promo_Mechanic__c();
        prm2.Name = 'TestName';
        prm2.Eligible_Product__c = prod.Id;
        prm2.Campaign_Eligibility__c = ce1.Id;
        prm2.Status__c = 'Active';
        prm2.Usage__c = -1;
        insert prm2;*/
        
        
        
        
        Test.startTest();
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Quantity = 500;
         oli.Start_Date__c= system.today();
         oli.End_Date__c =system.today().adddays(1);
        oli.UnitPrice = 10000;
        //oli.Parent_Id__c ='demoparentid';
        insert oli;
        listOppLine.add(oli);
        //listOppLine.add(oli);
        //Insert listOppLine;
        opportunityLineItem oli1 = new opportunityLineItem();
        oli1.Product2Id = prod.Id;
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbe2.Id;
        //oli1.Quantity= 6;
        oli1.Parent__c = oli.Id;
        
        oli1.Parent_Id__c = oli.Id;
        listOppLine.add(oli1);
        
        Quote objQuote=new Quote();
        objQuote.OpportunityId=opp.Id;
        objQuote.CreatedDate__c=system.today();
        objQuote.name='test';
        objQuote.Status='Proposal';
        objQuote.PriceBook2Id = standardPB.Id;
        objQuote.Celigo_Account__c = a.Id;
        //objQuote.Record_Eligibility__c = 'VR_Validate_Agent_Status';
        insert objQuote;
        
         List<quoteLineItem> listquoteLine = new List<quoteLineItem>();
        quoteLineItem qli = new quoteLineItem();
        qli.Product2Id = prod.Id;
        qli.QuoteId = objQuote.Id;
        qli.PricebookEntryId = pbe2.Id;
        qli.Start_Date__c = System.today();
        qli.UnitPrice = 45;
        qli.Quantity = 3;
        insert qli;
        listquoteLine.add(qli);
        quoteLineItem qli1 = new quoteLineItem();
        qli1.Product2Id = prod.Id;
        qli1.QuoteId = objQuote.Id;
        qli1.Start_Date__c = System.today();    
        qli1.PricebookEntryId = pbe2.Id;
        qli1.Parent__c = qli.Id;
        qli1.Parent_Id__c = qli.Id;
        qli1.UnitPrice = 23;
        qli1.Quantity = 7;
        insert qli1;
        listquoteLine.add(qli1);
       // Test.startTest();
        ProductSelectionLightningPageController.getRenewalOptions(objQuote.Id);
        ProductSelectionLightningPageController.saveOliData(opp.Id,listOppLine);
        ProductSelectionLightningPageController.getAvailableProductAndPromo(standardPB.Id,'SGD','Test',opp.Id,objQuote.Id);
        ProductSelectionLightningPageController.oliAndDefaultPromoList(opp.Id,objQuote.Id);
        ProductSelectionLightningPageController.saveQliData(objQuote.Id,listquoteLine,standardPB.Id,'SGD');
        
        Quote qu1 = [select Id, Name, Celigo_Account__c, Account.Name,Account.VIP__c,Account.Approval_Status__c,Account.Loyalty_Start_Date__c, Account.Country__c, Account.CEA_Salesperson_Number__c, Account.PersonContactId, Account.Status__c, Account.Previous_Account_Rule__c, Account.Account_Rule_Code__c, Account.Subscription_Start_Date__c, Account.Is_Qualify_Agent_Referral_Program__c, Account.Referrer_Agent__c, Account.Current_Subscription_Code__c, Account.PG_Tenure__c, opportunity.Pricebook2Id, Country__c
                     ,opportunity.Order_Type_Clone__c, to_VIP_Approval__c, to_Managerial_Approval__c, to_FOC_Approval__c, Status, Approval_Status__c, CurrencyIsoCode from Quote LIMIT 1];
 //       ProductSelectionLightningPageController.saveQliData(qu1.Id,listquoteLine,pbe2.Pricebook2Id,'SGD');
        Upgrade_Package_Lookup__c UGP = new Upgrade_Package_Lookup__c(Country__c=qu1.Account.Country__c,Name='Advance',Upgrade_SKU__c='MY01P3456r',Renewal_SKU__c='MY01P3456r',level__c = 1,isActive__c = true);
        insert UGP;
        Upgrade_Package_Lookup__c UGP2 = new Upgrade_Package_Lookup__c(Country__c=qu1.Account.Country__c,Name='Standard',Upgrade_SKU__c='PG01P5702S',Renewal_SKU__c='PG01P5702S',level__c = 2,isActive__c = true);
        insert UGP2;
        
        ProductSelectionLightningPageController.getRenewalOptions(qu1.Id);
        Test.stopTest();
        }
    }
}
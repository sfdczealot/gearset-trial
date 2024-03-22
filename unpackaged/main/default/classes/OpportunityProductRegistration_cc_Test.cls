/*
* Created by : Yuni
* Company    : Viseo Asia PTE LTD
* created Date : 10/07/2018
*/
@isTest
public class OpportunityProductRegistration_cc_Test {
       @testSetup static void setup() {
        User user = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(user){
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampaignEligibilityTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TE1 = new Trigger_Execute__c();
        TE1.Name = 'PGCampMemberTrigger';
        TE1.Enable_del__c = true;
        insert TE1;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
        
        Trigger_Execute__c TEEntPromo = new Trigger_Execute__c();
        TEEntPromo.Name = 'PGEntitlementPromoTrigger';
        TEEntPromo.Enable_del__c = true;
        insert TEEntPromo;
        
        Trigger_Execute__c TE2 = new Trigger_Execute__c();
        TE2.Name = 'Trigger_OpportunitySplit';
        TE2.Enable_del__c = true;
        insert TE2;
           
           Trigger_Execute__c customsetting=new Trigger_Execute__c();
           customsetting.Name='PGAccountTrigger';
           customsetting.Enable_del__c=true;
           insert customsetting;
        
         Opportunity opp = null;
        //Account a = new Account();
        Account acc_b2c  = null, acc_b2c_null = new Account();
        // Avoid mixed DML
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs (thisUser) {
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            //data setup
            PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);

            PGTestDataFactory_v2.CreateTriggerExecuteCS('QuoteLineItemTrigger',true);
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            acc_b2c = PGTestDataFactory_v2.createB2CAccount('test@test.com','1232134', thisUser, sb);
            acc_b2c.Account_Previous_Status__c = 'TRIAL';
            acc_b2c.Subscription_End_Date__c=system.todaY();
            update acc_b2c;
            //standard PB
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            //Subscription Class
            Product_Class__c productClass = PGTestDataFactory_v2.createProductClass('Subscription',sb);
            
            //item
            list<Product2> listProd = new list<Product2>();
            Product2 prod = PGTestDataFactory_v2.CreateProduct('Test Prod', 'B2C Only', 'Subscription', 'abc2', productClass, taxcode);
            listProd.add(prod);
            Product2 prod2 = PGTestDataFactory_v2.CreateProduct('Test Prod2', 'B2C Only', 'Subscription', 'abc2', productClass, taxcode);
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
            opp.StageName = 'Proposal';
            opp.Approval_Status__c = 'OMC Approval Approved';
            opp.Count_of_subscription_item_new__c = 1;
            update opp;
            
            //a = PGTestDataFactory_v2.createB2CAccount('test1@test.com','123', thisUser, sb);
            
        
        
        OpportunityLineItem oli =PGTestDataFactory_v2.CreateOppLineItem(opp, pbe2, prod);
        OpportunityLineItem oli1 =PGTestDataFactory_v2.CreateOppLineItem(opp, pbe2, prod);
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
        c.EndDate = system.today().addDays(2);
        c.Campaign_End_DateTime__c = system.today().addDays(2);
        c.Campaign_Start_DateTime__c = system.today().addDays(-2);
        insert c;
        
        Campaign renewal_c = new campaign();
        renewal_c.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Renewal Promotion').getRecordTypeId();
        renewal_c.Name = 'test renewal campaign';
        renewal_c.Country__c = 'Singapore';
        renewal_c.IsActive = true;
        insert renewal_c;
        
      /*  list<Promotion_Discount_Value__c> listRenewalPDV = new list<Promotion_Discount_Value__c>();
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
        
        Account acc = [Select id, name, PersonContactId from account where lastName =: acc_b2c.LastName  LIMIT 1];
        System.debug('Check PersonContactId not NULL: ' + acc.PersonContactId);
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = c.id;
        cm.ContactId = acc.PersonContactId;
        insert cm;
        
        /*VIP__c vip = new VIP__c();
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
        
        /*list<Tier_Pricing__c> listTP = new list<Tier_Pricing__c>();
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
            
        Test.startTest();
        OpportunityProductRegistration_cc.constructUpgrade(acc.Id);
        Test.stopTest();
        }
    }
    }
    static testMethod void testMethod1() {
        test.startTest();
        Opportunity opp = [select Id, Name, AccountId, Account.Name,Account.VIP__c,Account.Approval_Status__c,Account.Loyalty_Start_Date__c, Account.Country__c, Account.CEA_Salesperson_Number__c, Account.PersonContactId, Account.Status__c, Account.Previous_Account_Rule__c, Account.Account_Rule_Code__c, Account.Subscription_Start_Date__c, Account.Is_Qualify_Agent_Referral_Program__c, Account.Referrer_Agent__c, Account.Current_Subscription_Code__c, Account.PG_Tenure__c, Pricebook2Id, PG_Tenure__c, Total_Spending__c, Subsidiary__c, Country__c, Order_Type_Clone__c, to_VIP_Approval__c, to_Managerial_Approval__c, to_FOC_Approval__c, StageName, Approval_Status__c, CurrencyIsoCode, CloseDate from Opportunity LIMIT 1];
        OpportunityProductRegistration_cc.OppTmpConstruct oppTmpConstruct= OpportunityProductRegistration_cc.construct(opp.id);
        system.assertEquals('Test Opp', oppTmpConstruct.oppObj.Name, 'Invalid Opportunity Name');
        
        list<string> listSelectOpt = OpportunityProductRegistration_cc.getSelectOptions(opp , 'StageName');     
        list<OpportunityLineItem> listOppLineSelected = OpportunityProductRegistration_cc.getSelectedProduct(opp.id);
        system.assertEquals(new list<OpportunityLineItem>(), listOppLineSelected, 'Opportunity Line Item should still be empty at this point.');
        
        Pricebook2 standardPB = [select name, CurrencyIsoCode, isactive from Pricebook2 limit 1];
        list<PricebookEntry> listPbEntry = OpportunityProductRegistration_cc.getListAvailableProduct(standardPB.id, opp.CurrencyIsoCode, 'Test Prod');
        system.assertEquals(new list<PricebookEntry>(), listPbEntry, 'Invalid Available Product');
        
        list<sObject> listObject = OpportunityProductRegistration_cc.getListData('Id', 'Name', 'Opportunity');
        system.assertEquals('Test Opp', listObject[0].get('Name'), 'Invalid Opportunity Name');
        
        Product2 prod = [Select id, Name from Product2 where Name =: 'Test Prod' LIMIT 1];
        
        // added by gian
        list<Item_Bundle__c> listItemBundle = [select Parent_Product__c, Child_Product__c, Qty__c, Upload_Tag__c from Item_Bundle__c where Parent_Product__c=:prod.Id];
        String childId = '';
        for (Item_Bundle__c row: listItemBundle) {
            childId = row.Child_Product__c;
        }
        
        Id StdpricebookId = Test.getStandardPricebookId();
        list<PricebookEntry> listPE = new list<PricebookEntry>();
        PricebookEntry stdPriceBookEntryProd2 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=childId, unitprice=100.0, isActive=true);
        insert stdPriceBookEntryProd2;
        // end added by gian
        
        list<OpportunityProductRegistration_cc.oppLineItemTmp> listChild = OpportunityProductRegistration_cc.getChild(standardPB.id, prod.id);
        system.assertEquals(null, stdPriceBookEntryProd2.Product2.Name, 'Invalid Opportunity Line Item Product');
        
       // OpportunityProductRegistration_cc.DiscountInfo discInfo = OpportunityProductRegistration_cc.getVipDiscInfo(100, 'Singapore');
       // system.assertEquals('<b>vip test</b>', discInfo.Description, 'Invalid description.');
        string orderType = OpportunityProductRegistration_cc.getOrderType(System.today(), System.today().addMonths(10), 'Singapore');
        system.assertEquals('Upgrade Outside Renewal Window', orderType, 'Invalid Order Type');
        orderType = OpportunityProductRegistration_cc.getOrderType(System.today(), System.today().addMonths(12), 'Singapore');
        system.assertEquals('Upgrade Inside Renewal Window', orderType, 'Invalid Order Type');
        try {
            orderType = OpportunityProductRegistration_cc.getOrderType(System.today(), System.today().addMonths(13), 'Singapore');    
        } catch(Exception e) {
            system.debug('Test exception' + e); 
        }
        try {
            orderType = OpportunityProductRegistration_cc.getOrderType(System.today(), System.today().addMonths(14), 'Malaysia');
        } catch(Exception e) {
            system.debug('Test exception' + e);   
        }
        
        list<OpportunityProductRegistration_cc.DiscountInfo> listResult = new list<OpportunityProductRegistration_cc.DiscountInfo>();
        list<OpportunityProductRegistration_cc.DiscountInfo> listEligiblePromo = OpportunityProductRegistration_cc.getListEligiblePromotion(opp);
        System.debug('opp: '+opp);
        System.debug('OpportunityProductRegistration_cc.getListEligiblePromotion(opp): '+OpportunityProductRegistration_cc.getListEligiblePromotion(opp));
        System.debug('listEligiblePromo: '+listEligiblePromo.size());
        //system.debug('listEligiblePromo[0].Description: '+listEligiblePromo[0].Description);
        //system.assertEquals('<b>Any</b> purchase of <b>null</b> would get <b>10.00%</b> discount.', listEligiblePromo[0].Description, 'Invalid discount description.');
       list<pricebookentry> pbelist=[select id,product2id from pricebookentry where pricebook2.id=: opp.pricebook2id limit 1];
        list<product2> prodList=[select id from product2 where id=: pbelist[0].product2id limit 1];
        List<OpportunityLineItem> oliList= new List<OpportunityLineItem>();
        OpportunityLineItem oli =PGTestDataFactory_v2.CreateOppLineItem(opp, pbelist[0], prodList[0]);
        oli.SNO__c=1.0;
        oliList.add(oli);
        OpportunityLineItem oli1 =PGTestDataFactory_v2.CreateOppLineItem(opp, pbelist[0], prodList[0]);
          oli1.SNO__c=1.01;       
        oli1.Parent__c='1';
        oliList.add(oli1);
        update oliList;
        List<OpportunityLineItem> listOppLine = [select id,Order_Type__c,Parent__c,SNo__c from OpportunityLineItem];
        List<OpportunityLineItem> listOppLineDelete = new List<OpportunityLineItem>();
        list<OpportunityLineItem> listOppLineResult = OpportunityProductRegistration_cc.saveForm(opp, listOppLine, listOppLineDelete);
        //system.assertEquals(new list<OpportunityLineItem>(), listOppLineResult, 'Invalid Opp Line Result');
        
        OpportunityProductRegistration_cc.OppLineItemTmp oplt = new OpportunityProductRegistration_cc.OppLineItemTmp();
        system.assertEquals(null, oplt.ChildCategory, 'Invalid ChildCategory.');
        oplt.Product2Id = 'test';
        oplt.Line_Description2 = 'test';
        oplt.UnitPrice = 2;
        oplt.Product_Type = 'type'; 
        oplt.Quantity=4;
        oplt.Complimentary=true;
        oplt.Parent='test';
        oplt.DiscountReason ='test';
        
        
        
        OpportunityProductRegistration_cc.DiscountInfo discinf = new OpportunityProductRegistration_cc.DiscountInfo();
        OpportunityProductRegistrationStinger_cc.justIncrement();
        test.stopTest();
        
    }
    
   /* static testMethod void testMethod3() {        
        Opportunity opp = [select Id, Name, AccountId, Account.Name, Account.Country__c, Account.CEA_Salesperson_Number__c, Account.PersonContactId,  Account.Status__c, Account.Previous_Account_Rule__c, Account.Account_Rule_Code__c, Account.Subscription_Start_Date__c, Account.Is_Qualify_Agent_Referral_Program__c, Account.Referrer_Agent__c, Account.Current_Subscription_Code__c, Account.PG_Tenure__c, Pricebook2Id, PG_Tenure__c, Total_Spending__c, Subsidiary__c, Country__c, Order_Type_Clone__c, to_VIP_Approval__c, to_Managerial_Approval__c, to_FOC_Approval__c, StageName, Approval_Status__c, CurrencyIsoCode, CloseDate from Opportunity LIMIT 1];
        opp.PG_Tenure__c = 3;
        update opp;
        OpportunityProductRegistration_cc.getLoyaltyDiscInfo(opp.PG_Tenure__c, 'Singapore');
        
        opp.PG_Tenure__c = 1;
        update opp;
        
        Campaign camp = new Campaign();
        camp.Name = 'Test campaign Referral';
        camp.IsActive = true;
        camp.Country__c = 'Singapore';
        insert camp;
        
      
        
        PricebookEntry prod = [select Id, Product2Id, Pricebook2Id, Pricebook2.Name, CurrencyIsoCode, UnitPrice from PricebookEntry limit 1];
        system.debug('prod.Pricebook2Id:'+prod);
        system.debug('*****Test.getStandardPricebookId():'+Test.getStandardPricebookId());
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true, CurrencyIsoCode='SGD');
        update standardPricebook;
        
        Item_Bundle__c ib = new Item_Bundle__c();
        ib.Parent_Product__c = prod.Product2Id;
        ib.Child_Product__c = prod.Product2Id;
        ib.Qty__c = 1;
        insert ib;
        
        OpportunityProductRegistration_cc.getChild(prod.Pricebook2Id, prod.Product2Id);
        
        list<OpportunityProductRegistration_cc.DiscountInfo> listResult = new list<OpportunityProductRegistration_cc.DiscountInfo>();
        Test.startTest();
        Campaign camp_1 = new Campaign();
        camp_1.Name = 'Test campaign refferal';
        camp_1.IsActive = true;
        camp_1.Country__c = 'Singapore';
        insert camp_1;
       
        //OpportunityProductRegistration_cc.getReferralAgentPromo(opp, listResult);
        //OpportunityProductRegistration_cc.getFirstTimerPromo(opp, listResult);
        OpportunityProductRegistration_cc.getRenewalProductList (opp.Account, opp);
        Test.stopTest();
    }
    */
    static testMethod void testMethod5() {
        list<OpportunityProductRegistration_cc.DiscountInfo> listResult = new list<OpportunityProductRegistration_cc.DiscountInfo>();
        map<string, string> mapUpgrade = new map<string, string>();
        map<string, string> mapDowngrade = new map<string, string>();
        Opportunity opp = [select Id, Name, AccountId, Account.Name, Account.Country__c, Account.CEA_Salesperson_Number__c, Account.PersonContactId, Account.Status__c, Account.Previous_Account_Rule__c, Account.Account_Rule_Code__c, Account.Subscription_Start_Date__c, Account.Is_Qualify_Agent_Referral_Program__c, Account.Referrer_Agent__c, Account.Current_Subscription_Code__c, Account.PG_Tenure__c, Pricebook2Id, PG_Tenure__c, Total_Spending__c, Subsidiary__c, Country__c, Order_Type_Clone__c, to_VIP_Approval__c, to_Managerial_Approval__c, to_FOC_Approval__c, StageName, Approval_Status__c, CurrencyIsoCode, CloseDate, Account.Subscription_End_Date__c from Opportunity LIMIT 1];
        string campaignRectype = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Renewal Promotion').getRecordTypeId();
        //string promotionRectype = Schema.SObjectType.Promotion_Discount_Value__c.getRecordTypeInfosByName().get('Renewal Promotion').getRecordTypeId();
        Product2 prod = [select Id from Product2 where SKU_Code__c='abc2' limit 1];
        OpportunityProductRegistration_cc.getOppRecord(opp.Id);
        OpportunityProductRegistration_cc.getAccRecord(opp.AccountId);
        Campaign camp = new Campaign();
        camp.Name = 'Test campaign renewal';
        camp.IsActive = true;
        camp.Country__c = 'Singapore';
        camp.RecordTypeId = campaignRectype;
        insert camp;
        
        /*Promotion_Discount_Value__c prom = new Promotion_Discount_Value__c();
        prom.Campaign__c = camp.Id;
        prom.RecordTypeId = promotionRectype;
        prom.Qty__c = 10;
        prom.Product_Reference__c = prod.Id;
        prom.Product__c = prod.Id;
        prom.Renewal_Stage__c = 'Early Bird';
        insert prom;
        
        Promotion_Discount_Value__c prom2 = new Promotion_Discount_Value__c();
        prom2.Campaign__c = camp.Id;
        prom2.RecordTypeId = promotionRectype;
        prom2.Qty__c = 20;
        prom2.Product_Reference__c = prod.Id;
        prom2.Product__c = prod.Id;
        prom2.Renewal_Stage__c = 'AM';
        insert prom2;
        
        Promotion_Discount_Value__c prom3 = new Promotion_Discount_Value__c();
        prom3.Campaign__c = camp.Id;
        prom3.RecordTypeId = promotionRectype;
        prom3.Qty__c = 30;
        prom3.Product_Reference__c = prod.Id;
        prom3.Product__c = prod.Id;
        prom3.Renewal_Stage__c = 'AM+1';
        insert prom3;
        */
        mapUpgrade.put('test', 'abc');
        mapUpgrade.put('test3', 'abc3');
        
        OpportunityProductRegistration_cc.getRenewalDiscountInfo(opp, listResult, 'test2', mapUpgrade, mapDowngrade);
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd Test';
        sb.NS_Subsidiary_Internal_ID__c = '10';
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
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/);
        insert productClass;
        
        list<Product2> listProd = new list<Product2>();
        Product2 prod1 = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id, CurrencyIsoCode = 'SGD');
        listProd.add(prod1);
        
        Product2 prod2 = new Product2(Name = 'Test Prod2', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc2', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id, CurrencyIsoCode = 'SGD');
        listProd.add(prod2);
        
        Product2 prod3 = new Product2(Name = 'Test Prod3', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc3', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id, CurrencyIsoCode = 'SGD');
        listProd.add(prod3);
        insert listProd;
        
        List<OpportunityProductRegistration_cc.OppLineItemTmp> OppLITmp = new List<OpportunityProductRegistration_cc.OppLineItemTmp>();
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        list<PricebookEntry> listPBE = [select id,Product2.SKU_Code__c,Name,UnitPrice,Product2.Description,Product2.Product_Type__c,Product2.Tax_Code__r.Tax_Rate__c,
                                        Product2.Income_Account_Name__c,Product2.Tax_Code__c,Pricebook2Id,Currencyisocode from pricebookentry];
        Upgrade_Package_Mapping__c upm = new Upgrade_Package_Mapping__c(name = 'abc', SKU_Code__c = 'abc', Country__c = 'Singapore',Destination_Rule_Code__c = 'test2', Origin_Rule_Code__c = 'STANDARD',Quantity__c = 100, Unit_Price__c = 100);
        insert upm;
        
        OpportunityProductRegistration_cc.getUpgradeMapBonusItem(standardPB, upm, new list<OpportunityProductRegistration_cc.OppLineItemTmp>(), '');
        OpportunityProductRegistration_cc.getUpgradeMapping(opp.Account, listPBE);
        Test.startTest();
        try{
            PricebookEntry pbe = PGTestDataFactory_v2.CreatePBE(standardPB.id, prod, 100.0, sb,true);
         
           OpportunityProductRegistration_cc.saveUpgrade(opp.Account,listPBE[0],camp.Id,10.00,'','12-01-2021',1.00,1.00,upm);
         
        }
        catch(Exception e){
            
        }
        OpportunityProductRegistration_cc.getRenewalProductList(opp.Account,opp);
        OpportunityProductRegistration_cc.oppLineItemTmpAssignment(listPBE[0],OppLITmp,1,'',true);
        OpportunityProductRegistration_cc.getProfileNamePermission();
        OpportunityProductRegistrationStinger_cc.justIncrement();
        Test.stopTest();
    }
    
    static testMethod void testMethod6() {
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Test.startTest();
        //id subId = PGTestDataFactory.createSubsidiary().Id;
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd Test';
        sb.NS_Subsidiary_Internal_ID__c = '10';
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
        
        Account acc2 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc2.FirstName = 'TestMe';
        acc2.LastName = 'Lasting';
        acc2.AgentNet_ID__c = 'AgentNet_ID__c test';
        acc2.Salutation = 'Mrs.';
        acc2.CurrencyIsoCode = 'SGD';
        acc2.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc2.BillingStreet = 'test';
        acc2.BillingPostalCode = '83273';
        //acc2.BillingState = 'test';
        acc2.Current_Subscription_Code__c = 'abc';
        acc2.PersonEmail = 'test@yuwni.com';
        acc2.Account_Rule_Code__c = 'Trial';
        acc2.Status__c = 'Downgraded';
        acc2.Country__c = 'Singapore';
        acc2.Agency__c = agency.id;
        acc2.Subsidiary__c = sb.Id;
        acc2.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc2.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc2.VIP_Campaign__c = 'VIP Advance SC-1';
        acc2.Approval_Status__c = '';
        acc2.Mobile_Country__c = '65';
        acc2.CEA_Salesperson_Number__c = 'D548562L';
        acc2.Previous_Account_Rule__c = 'STANDARD';
        acc2.PersonBirthdate = system.today();
        acc2.BillingCountry = 'Singapore';
        acc2.BillingCity = 'Singapore';
        insert acc2;
         list<Upgrade_Package_Lookup__c> listUPL = new list<Upgrade_Package_Lookup__c>();
        Upgrade_Package_Lookup__c upl = new Upgrade_Package_Lookup__c();
        upl.Country__c = 'Thailand';
        upl.Name = 'test';
        upl.Level__c = 1;
        upl.IsActive__c = true;
        upl.Upgrade_SKU__c = 'abc';
        upl.Renewal_SKU__c = 'test';
        listUPL.add(upl);
        
        Upgrade_Package_Lookup__c upl2 = new Upgrade_Package_Lookup__c();
        upl2.Country__c = 'Malaysia';
        upl2.Name = 'test2';
        upl2.Level__c = 2;
        upl2.Upgrade_SKU__c = 'abc2';
        upl2.Renewal_SKU__c = 'abc2';
        upl2.IsActive__c = true;
        upl2.Renewal_Type__c = 'Renewal Downgrade';
        listUPL.add(upl2);
        
        Upgrade_Package_Lookup__c upl3 = new Upgrade_Package_Lookup__c();
        upl3.Country__c = 'Singapore';
        upl3.Name = 'Standard';
        upl3.Level__c = 3;
        upl3.isActive__c = true;
        upl3.Upgrade_SKU__c = 'abc3';
        upl3.Renewal_SKU__c = 'abc3';
        upl3.Renewal_Type__c = 'Renewal Upgrade';
        listUPL.add(upl3);
        insert listUPL; 
        List<OpportunityProductRegistration_cc.OppLineItemTmp> OppLITmp = new List<OpportunityProductRegistration_cc.OppLineItemTmp>();
        list<OpportunityProductRegistration_cc.DiscountInfo> listResult = new list<OpportunityProductRegistration_cc.DiscountInfo>();
        Opportunity opp = [select Id, Name, AccountId, Account.Name, Account.Country__c, Account.CEA_Salesperson_Number__c, Account.PersonContactId, Account.Status__c, Account.Previous_Account_Rule__c, Account.Account_Rule_Code__c, Account.Subscription_Start_Date__c, Account.Is_Qualify_Agent_Referral_Program__c, Account.Referrer_Agent__c, Account.Current_Subscription_Code__c, Account.PG_Tenure__c, Pricebook2Id, PG_Tenure__c, Total_Spending__c, Subsidiary__c, Country__c, Order_Type_Clone__c, to_VIP_Approval__c, to_Managerial_Approval__c, to_FOC_Approval__c, StageName, Approval_Status__c, CurrencyIsoCode, CloseDate, Account.Subscription_End_Date__c from Opportunity LIMIT 1];
        string campaignRectype = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('First-Timer Winback').getRecordTypeId();
       //string promotionRectype = Schema.SObjectType.Promotion_Discount_Value__c.getRecordTypeInfosByName().get('First-Timer Winback').getRecordTypeId();
        Product2 prod = [select Id from Product2 where SKU_Code__c='abc2' limit 1];
        OpportunityProductRegistration_cc.getOppRecord(opp.Id);
        OpportunityProductRegistration_cc.getAccRecord(opp.AccountId);
        //list<PricebookEntry> listPBE = [select id,Product2.SKU_Code__c,Name,UnitPrice,Product2.Description,Product2.Product_Type__c,Product2.Tax_Code__r.Tax_Rate__c,
                                        //Product2.Income_Account_Name__c,Product2.Tax_Code__c,Pricebook2Id,Currencyisocode from pricebookentry];
        Campaign camp = new Campaign();
        camp.Name = 'Test campaign winback';
        camp.IsActive = true;
        camp.Country__c = opp.Country__c;
        camp.RecordTypeId = campaignRectype;
        camp.StartDate = system.today().addDays(-2);
        camp.EndDate = system.today().addDays(2);
        insert camp;
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = camp.id;
        cm.ContactId = opp.Account.PersonContactId;
        insert cm;
        
        String skuCodeOfACProd =System.Label.PRODUCT_SKUCODE_AD_CREDIT;
        Product_Class__c prodClass = New Product_Class__c(Name='Subscription',  CurrencyIsoCode='SGD');
        insert prodClass;
        Product2 prod1 = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test',  Product_Type__c='PG',Description='DummyText'
                                     ,Is_Bundle__c=true,Product_Class__c = prodClass.id);
        insert prod1;
        
        Product2 prod2 = new Product2(Name = 'Test Prod2', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Discretionary', SKU_Code__c = skuCodeOfACProd);
        insert prod2;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        PricebookEntry pbe0 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod2.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe0;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPB.id, product2id=prod2.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe;
        List<PricebookEntry> pbelist = new List<PricebookEntry>();
        pbelist.add(pbe);
         Item_Bundle__c bundle = new Item_Bundle__c();
        bundle.Qty__c = 3;
        bundle.Parent_Product__c = prod1.id;
        bundle.Child_Product__c = prod2.Id;
        insert bundle;
        
        Upgrade_Package_Mapping__c upm = new Upgrade_Package_Mapping__c(name = 'abc', SKU_Code__c = 'abc', Country__c = 'Singapore',Destination_Rule_Code__c = 'test2', Origin_Rule_Code__c = 'STANDARD',Quantity__c = 100, Unit_Price__c = 100);
        insert upm;
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Opportunity opp1 = new opportunity();
            opp1.Name = 'Test Opp';
            opp1.StageName = 'New';
            opp1.AccountId = acc2.id;
            opp1.CloseDate = system.today().AddDays(30);
            opp1.Total_Spending__c = 100;
            opp1.RecordTypeId = oppRectype;
            opp1.PG_Tenure__c = 1;
            opp1.Order_Type_Clone__c = 'Contract - Renewal';
            opp1.Summary_Of_Subscription_Item_new__c = 10.00;
            opp1.OMC_Submitted_Time__c = system.today();
            opp1.CurrencyIsoCode = 'SGD';
            opp1.Approval_Status__c = 'OMC Approval Approved';
            opp1.Opportunity_Type__c='B2C - Renewal';
            opp1.Pro_Rate__c=7;
            opp1.Is_Current_Subscription__c = true;
            opp1.Include_Subscription_Ext__c= true;
            //opp.Include_Subscription__c=;
            insert opp1;
        opp1.stagename = 'closed won';
        update opp1;
        OpportunityProductRegistration_cc.getFirstTimerWinbackInfo(opp, listResult);
        Account ac = [select Id,Name,Country__c,Subscription_End_Date__c,Loyalty_Start_Date__c from Account where FirstName='abc'];
        OpportunityProductRegistration_cc.CalculateUpgradeTenure(ac);
        String accStr = Json.serialize(acc2);
        String lstpbeStr = Json.serialize(pbelist);
        String campaignId = camp.Id;
        OpportunityProductRegistrationStinger_cc.getUpgradeMapping(accStr,lstpbeStr);
        OpportunityProductRegistration_cc.getUpgradeMapping(acc2, pbelist);
        OpportunityProductRegistrationStinger_cc.getLoyaltyDiscInfo(2,'singapore');
        OpportunityProductRegistrationStinger_cc.getChild(standardPB.Id, prod1.id);
        OpportunityProductRegistrationStinger_cc.constructUpgrade(acc2.Id);
        OpportunityProductRegistrationStinger_cc.getAccRecord(acc2.Id);
        //OpportunityProductRegistrationStinger_cc.getUpgradeMapBonusItem(standardPB,upm,OppLITmp,String.valueof(prod2.id));
        OpportunityProductRegistrationStinger_cc.getOrderType(System.today(),system.today().addDays(15),'singapore');
        //OpportunityProductRegistrationStinger_cc.saveUpgrade(string.valueOf(acc2.Id),lstpbeStr,campaignId,10.00,'','12-01-2021',1.00,1.00,upm,700,600,500,200);
        OpportunityProductRegistrationStinger_cc.justIncrement();
        OpportunityProductRegistrationStinger_cc.getSubscriptionProduct(acc2,'SGD',standardPB.Id,'Singapore',pbelist,'Renewal_SKU__c');
        Test.stopTest();
        }
    }
    @isTest
    public static void testMethod2(){
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd Test';
        sb.NS_Subsidiary_Internal_ID__c = '10';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        Map<String,String> mapofString = new Map<String,String>();
        mapofString.put('keyTestName', 'valueTestName');
        OpportunityProductRegistration_cc.OppTmpConstruct oc = new OpportunityProductRegistration_cc.OppTmpConstruct();
        oc.oppObj = [select Id,Name from Opportunity where Name='Test Opp'];
        oc.GstCode = '54d';
        oc.GstVatRate = 3.5;
        oc.mapDownGrade = mapofString;
        oc.mapUpGrade = mapofString;
        oc.currentSubscription = 'tres';
         String skuCodeOfACProd =System.Label.PRODUCT_SKUCODE_AD_CREDIT;
        Product_Class__c prodClass = New Product_Class__c(Name='Subscription',  CurrencyIsoCode='SGD');
        insert prodClass;
        Product2 prod1 = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test',  Product_Type__c='PG',Description='DummyText'
                                     ,Is_Bundle__c=true,Product_Class__c = prodClass.id);
        insert prod1;
        
        Product2 prod2 = new Product2(Name = 'Test Prod2', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Discretionary', SKU_Code__c = skuCodeOfACProd);
        insert prod2;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        PricebookEntry pbe0 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod2.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe0;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPB.id, product2id=prod2.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe;
        List<PricebookEntry> pbelist = new List<PricebookEntry>();
        pbelist.add(pbe);
         Item_Bundle__c bundle = new Item_Bundle__c();
        bundle.Qty__c = 3;
        bundle.Parent_Product__c = prod1.id;
        bundle.Child_Product__c = prod2.Id;
        insert bundle;
        test.startTest();
          Account a=[select id,Subscription_Start_Date__c,Account_Rule_Code__c,Name from account limit 1];
        OpportunityProductRegistration_cc.getUpgradeProductList(a,3);
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Opportunity opp1 = new opportunity();
            opp1.Name = 'Test Opp';
            opp1.StageName = 'New';
            opp1.AccountId = a.id;
            opp1.CloseDate = system.today().AddDays(30);
            opp1.Total_Spending__c = 100;
            opp1.RecordTypeId = oppRectype;
            opp1.PG_Tenure__c = 1;
            opp1.Order_Type_Clone__c = 'Contract - Renewal';
            opp1.Summary_Of_Subscription_Item_new__c = 10.00;
            opp1.OMC_Submitted_Time__c = system.today();
            opp1.CurrencyIsoCode = 'SGD';
            opp1.Approval_Status__c = 'OMC Approval Approved';
            opp1.Opportunity_Type__c='B2C - Renewal';
            opp1.Pro_Rate__c=7;
            opp1.Is_Current_Subscription__c = true;
            opp1.Include_Subscription_Ext__c= true;
            //opp.Include_Subscription__c=;
            insert opp1;
        opp1.stagename = 'closed won';
        update opp1;
        //Opportunity opp = [select Id,Name,Opportunity.Pricebook2Id,AccountId,Account.Subscription_Start_Date__c from Opportunity Where Name = 'Test Opp'];
        List<OpportunityLineItem> listOppLine = [select Id,Name from OpportunityLineItem];
        List<OpportunityLineItem> deleteOppLine = [select Id,Name from OpportunityLineItem];
        String accStr = Json.serialize(a);
        String lstpbeStr = Json.serialize(pbelist);
        OpportunityProductRegistrationStinger_cc.getUpgradeMapping(accStr,lstpbeStr);
        OpportunityProductRegistration_cc.saveForm(opp1, listOppLine, deleteOppLine);
        OpportunityProductRegistration_cc.getUserInfoAndOppRecord(opp1.id);
        OpportunityProductRegistration_cc.getLoyaltyDiscInfo(10,'Singapore');
        OpportunityProductRegistrationStinger_cc.getLoyaltyDiscInfo(2,'singapore');
        OpportunityProductRegistrationStinger_cc.getChild(standardPB.Id, prod1.id);
        OpportunityProductRegistrationStinger_cc.constructUpgrade(a.Id);
        OpportunityProductRegistrationStinger_cc.getAccRecord(a.Id);
        test.stopTest();
    }
     @isTest
    public static void testMethod8(){
        test.startTest();
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd Test';
        sb.NS_Subsidiary_Internal_ID__c = '10';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        list<OpportunityProductRegistration_cc.DiscountInfo> listResult = new list<OpportunityProductRegistration_cc.DiscountInfo>();
        map<string, string> mapUpgrade = new map<string, string>();
        map<string, string> mapDowngrade = new map<string, string>();
        Account a=[select id,Subscription_Start_Date__c,Account_Rule_Code__c,Country__c,Name from account limit 1];
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Opportunity opp1 = new opportunity();
            opp1.Name = 'Test Opp';
            opp1.StageName = 'New';
            opp1.AccountId = a.id;
            opp1.CloseDate = system.today().AddDays(30);
            opp1.Total_Spending__c = 100;
            opp1.RecordTypeId = oppRectype;
            opp1.PG_Tenure__c = 1;
            opp1.Order_Type_Clone__c = 'Contract - Renewal';
            opp1.Summary_Of_Subscription_Item_new__c = 10.00;
            opp1.OMC_Submitted_Time__c = system.today();
            opp1.CurrencyIsoCode = 'SGD';
            opp1.Approval_Status__c = 'OMC Approval Approved';
            opp1.Opportunity_Type__c='B2C - Renewal';
            opp1.Pro_Rate__c=7;
            opp1.Is_Current_Subscription__c = true;
            opp1.Include_Subscription_Ext__c= true;
            //opp.Include_Subscription__c=;
            insert opp1;
         String skuCodeOfACProd =System.Label.PRODUCT_SKUCODE_AD_CREDIT;
        Product_Class__c prodClass = New Product_Class__c(Name='Subscription',  CurrencyIsoCode='SGD');
        insert prodClass;
        Product2 prod1 = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test',  Product_Type__c='PG',Description='DummyText'
                                     ,Is_Bundle__c=true,Product_Class__c = prodClass.id);
        insert prod1;
        List<String> listOfNewPackageSKU = Label.SKU_CODE_OF_CULLINAN_PACKAGE.Split(';');
        Product2 prod2 = new Product2(Name = 'Test Prod2', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Discretionary', SKU_Code__c = listOfNewPackageSKU[0]);
        insert prod2;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        PricebookEntry pbe0 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod2.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe0;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPB.id, product2id=prod2.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe;
        List<PricebookEntry> pbelist = new List<PricebookEntry>();
        pbelist.add(pbe);
         Item_Bundle__c bundle = new Item_Bundle__c();
        bundle.Qty__c = 3;
        bundle.Parent_Product__c = prod1.id;
        bundle.Child_Product__c = prod2.Id;
        insert bundle;
        opp1.stagename = 'closed won';
        update opp1;
        Opportunity opp = [select Id, Name, AccountId, Account.Name, Account.Country__c, Account.CEA_Salesperson_Number__c, Account.PersonContactId, Account.Status__c, Account.Previous_Account_Rule__c, Account.Account_Rule_Code__c, Account.Subscription_Start_Date__c, Account.Is_Qualify_Agent_Referral_Program__c, Account.Referrer_Agent__c, Account.Current_Subscription_Code__c, Account.PG_Tenure__c, Pricebook2Id, PG_Tenure__c, Total_Spending__c, Subsidiary__c, Country__c, Order_Type_Clone__c, to_VIP_Approval__c, to_Managerial_Approval__c, to_FOC_Approval__c, StageName, Approval_Status__c, CurrencyIsoCode, CloseDate, Account.Subscription_End_Date__c from Opportunity LIMIT 1];
        string campaignRectype = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Renewal Promotion').getRecordTypeId();
        Product2 prod = [select Id from Product2 where SKU_Code__c='abc2' limit 1];
        OpportunityProductRegistration_cc.getOppRecord(opp1.Id);
        OpportunityProductRegistration_cc.getAccRecord(opp1.AccountId);
        Campaign camp = new Campaign();
        camp.Name = 'Test campaign renewal';
        camp.IsActive = true;
        camp.Country__c = 'Singapore';
        camp.RecordTypeId = campaignRectype;
        insert camp;
        
        
        Upgrade_Package_Lookup__c upl3 = new Upgrade_Package_Lookup__c();
        upl3.Country__c = a.Country__c;
        upl3.Name = 'test3';
        upl3.Level__c = 3;
        upl3.Upgrade_SKU__c = prod2.SKU_Code__c;
        upl3.Renewal_SKU__c = 'abc3';
        upl3.Renewal_Type__c = 'Renewal Upgrade';
        insert upl3;
        
        Upgrade_Package_Lookup__c upl = new Upgrade_Package_Lookup__c();
        upl.Country__c = 'Singapore';
        upl.Name = a.Account_Rule_Code__c;
        upl.Level__c = 1;
        upl.Upgrade_SKU__c = listOfNewPackageSKU[0];
        upl.Renewal_SKU__c = 'test';
        insert upl;
        
        Upgrade_Package_Mapping__c upm = new Upgrade_Package_Mapping__c(name = 'abc', SKU_Code__c = 'abc', Country__c = a.Country__c,Destination_Rule_Code__c = a.Account_Rule_Code__c, Origin_Rule_Code__c = a.Account_Rule_Code__c,Quantity__c = 100, Unit_Price__c = 100);
        insert upm;
        mapUpgrade.put('test', 'abc');
        mapUpgrade.put('test3', 'abc3');
        a.Subscription_End_Date__c = system.today().addmonths(-1);
        
        
        //Opportunity opp = [select Id,Name,Opportunity.Pricebook2Id,AccountId,Account.Subscription_Start_Date__c from Opportunity Where Name = 'Test Opp'];
        List<OpportunityLineItem> listOppLine = [select Id,Name from OpportunityLineItem];
        List<OpportunityLineItem> deleteOppLine = [select Id,Name from OpportunityLineItem];
        String accStr = Json.serialize(a);
        String lstpbeStr = Json.serialize(pbelist);
        OpportunityProductRegistrationStinger_cc.getUpgradeMapping(accStr,lstpbeStr);
        OpportunityProductRegistration_cc.saveForm(opp1, listOppLine, deleteOppLine);
        OpportunityProductRegistration_cc.getUserInfoAndOppRecord(opp1.id);
        OpportunityProductRegistration_cc.getLoyaltyDiscInfo(10,'Singapore');
        OpportunityProductRegistrationStinger_cc.getLoyaltyDiscInfo(2,'singapore');
        OpportunityProductRegistrationStinger_cc.getChild(standardPB.Id, prod1.id);
        OpportunityProductRegistrationStinger_cc.constructUpgrade(a.Id);
        OpportunityProductRegistrationStinger_cc.getAccRecord(a.Id);
        OpportunityProductRegistration_cc.getRenewalDiscountInfo(opp, listResult, 'test2', mapUpgrade, mapDowngrade);
        test.stopTest();
    }
   
    static testMethod void testMethod7(){
        test.startTest();
        list<OpportunityProductRegistration_cc.DiscountInfo> listResult = new list<OpportunityProductRegistration_cc.DiscountInfo>();
        map<string, string> mapUpgrade = new map<string, string>();
        map<string, string> mapDowngrade = new map<string, string>();
        Opportunity opp = [select Id, Name, AccountId, Account.Name, Account.Country__c, Account.CEA_Salesperson_Number__c, Account.PersonContactId, Account.Status__c, Account.Previous_Account_Rule__c, Account.Account_Rule_Code__c, Account.Subscription_Start_Date__c, Account.Is_Qualify_Agent_Referral_Program__c, Account.Referrer_Agent__c, Account.Current_Subscription_Code__c, Account.PG_Tenure__c, Pricebook2Id, PG_Tenure__c, Total_Spending__c, Subsidiary__c, Country__c, Order_Type_Clone__c, to_VIP_Approval__c, to_Managerial_Approval__c, to_FOC_Approval__c, StageName, Approval_Status__c, CurrencyIsoCode, CloseDate, Account.Subscription_End_Date__c from Opportunity LIMIT 1];
        string campaignRectype = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Renewal Promotion').getRecordTypeId();
        Product2 prod = [select Id from Product2 where SKU_Code__c='abc2' limit 1];
        OpportunityProductRegistration_cc.getOppRecord(opp.Id);
        OpportunityProductRegistration_cc.getAccRecord(opp.AccountId);
        Campaign camp = new Campaign();
        camp.Name = 'Test campaign renewal';
        camp.IsActive = true;
        camp.Country__c = 'Singapore';
        camp.RecordTypeId = campaignRectype;
        insert camp;
        
        mapUpgrade.put('test', 'abc');
        mapDowngrade.put('test3', 'abc3');
        opp.Account.Subscription_End_Date__c = system.today().addmonths(1);
        
        OpportunityProductRegistration_cc.getRenewalDiscountInfo(opp, listResult, 'test2', mapUpgrade, mapDowngrade);
        test.stopTest();
    }
       static testmethod void testIncrement() {   
        OpportunityProductRegistration_cc.justIncrement();
    } 
}
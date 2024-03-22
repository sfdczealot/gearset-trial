@isTest
public class DailyBatchToCalculateCarryOverAC_Test {
    
    @isTest
    public static void calculateCarryOverAC(){
        User user = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(user){
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        Trigger_Execute__c TE1 = new Trigger_Execute__c();
        TE1.Name = 'PGAccountTrigger';
        TE1.Enable_del__c = true;
        insert TE1;
        
        Trigger_Execute__c TEOpp = new Trigger_Execute__c();
        TEOpp.Name = 'PGOpportunityTrigger';
        TEOpp.Enable_del__c = true;
        insert TEOpp;
        
        Trigger_Execute__c TEOppMember = new Trigger_Execute__c();
        TEOppMember.Name = 'Trigger_OpportunitySplit';
        TEOppMember.Enable_del__c = true;
        insert TEOppMember;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'QuoteLineItemTrigger';
        insert TE;
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='Trigger_Quote';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c TE2 = new Trigger_Execute__c();
        TE2.Name = 'BillingAPI';
        TE2.Enable_del__c = false;
        insert TE2;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = '89953';
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
        a.CEA_Salesperson_Number__c = 'A215463G';
        a.PersonBirthdate=system.today();
        insert a;
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        String skuCodeOfACProd =System.Label.PRODUCT_SKUCODE_AD_CREDIT;
        Product_Class__c prodClass = New Product_Class__c(Name='Subscription',	CurrencyIsoCode='SGD');
        insert prodClass;

        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test',  Product_Type__c='PG',Description='DummyText'
                                     ,Is_Bundle__c=true,Product_Class__c = prodClass.id);
        insert prod;
        
        Product2 prod2 = new Product2(Name = 'Test Prod2', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Discretionary', SKU_Code__c = skuCodeOfACProd);
        insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        PricebookEntry pbe0 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe0;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPB.id, product2id=prod.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe;
        
        Item_Bundle__c bundle = new Item_Bundle__c();
        bundle.Qty__c = 3;
        bundle.Parent_Product__c = prod.id;
        bundle.Child_Product__c = prod2.Id;
        insert bundle;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.Opportunity_Type__c = 'B2C - Upgrade';
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;
        
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Test Opp';
        opp1.StageName = 'Pending OMC Approval';
        opp1.AccountId = a.id;
        opp1.CloseDate = system.today().AddDays(30);
        opp1.Subsidiary__c = sb.id;
        opp1.Total_Spending__c = 100;
        opp1.RecordTypeId = oppRectype;
        opp1.Opportunity_Type__c = 'B2C - Standard';
        opp1.PG_Tenure__c = 1;
        opp1.count_of_subscription_item_new__c = 100.0;
        opp1.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp1;
         
        
        
        /*opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 500;
        oli.Start_Date__c= system.today();
        oli.End_Date__c =system.today().adddays(1);
        oli.UnitPrice = 10000;
        oli.Complimentary__c = false;
        oli.Discount_Reason__c ='First-Timer Discount';
        oli.Amount_Despite_VIP__c = 10;
        oli.Product_Category__c ='Subscription';
        oli.Push_to_NetSuite__c = true;
        insert oli;
        
        oli.Product_Category__c ='Subscription';
        update oli;*/
        
        OpportunityLineItem oppLine = New OpportunityLineItem();
        oppLine.OpportunityId = opp1.Id;
        oppLine.PricebookEntryId = pbe.Id;
        oppLine.Product2Id = prod.Id;
        oppLine.UnitPrice = 90000;
        oppLine.Quantity = 3;
        oppLine.discount = 0.5;
        oppLine.Start_Date__c = system.today();
        oppLine.End_Date__c = system.today();
        oppLine.Amount_Despite_VIP__c = 300;
        oppLine.Pro_Rate_Amount__c = 2;
        oppLine.Product_Category__c ='Subscription';
        oppLine.Complimentary__c = false;
        oppLine.Push_to_NetSuite__c = true;
        oppLine.Discount_Reason__c = 'Managerial Discount';
        insert oppLine;
        
        oppLine.Product_Category__c ='Subscription';
        update oppLine;
        
        system.debug('opp@@'+opp);
        system.debug('oli@@'+oppLine);

        Test.startTest();
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp1.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.PriceBook2Id = standardPB.Id;
        qu.Agent_Accepted_Time__c = system.now();
        insert qu;       
       
        QuoteLineItem qli = new QuoteLineItem();
        qli.Product2Id = prod2.Id;
        qli.QuoteId = qu.Id;
        qli.PricebookEntryId = pbe.Id;
        qli.Start_Date__c = System.today();
        qli.UnitPrice = 90000;
        qli.Quantity = 2;
        qli.Discount__c = 0.5;
        qli.CurrPackageAdCredit__c = 4000;
        qli.Discount = 0.5;
        qli.SNo__c = 1.08;
        qli.Discount_Reason__c = 'Managerial Discount';
        qli.Discount_Amount__c = 0.00;
        qli.IsDiscretionaryAC__c = True;
        insert qli;
        
        Quote qu1 = new Quote();
        qu1.Name = 'Test Quote';
        qu1.Status = 'Proposal';
        qu1.From_Button__c = true;
        qu1.CreatedDate__c = system.today().AddDays(30);
        qu1.Payment_Time__c = system.now();
        qu1.Last_Outbound_Sync__c = system.now();
        qu1.Outbound_Sync_Error__c = 'test';
        qu1.OpportunityId = Opp.id;
        qu1.Allowed_Payment_Type__c = 'All';
        qu1.Count_of_Referral_Agent_Promotion__c = 1;
        qu1.Payment_Amount__c = null;
        qu1.CurrencyIsoCode = 'SGD';
        qu1.PriceBook2Id = standardPB.Id;
        qu1.Agent_Accepted_Time__c = system.now();
        insert qu1;       
       
        QuoteLineItem qli1 = new QuoteLineItem();
        qli1.Product2Id = prod2.Id;
        qli1.QuoteId = qu1.Id;
        qli1.PricebookEntryId = pbe.Id;
        qli1.Start_Date__c = System.today();
        qli1.UnitPrice = 90000;
        qli1.Quantity = 2;
        qli1.Discount__c = 0.5;
        qli1.CurrPackageAdCredit__c = 4000;
        qli1.Discount = 0.5;
        qli1.SNo__c = 1.08;
        qli1.Discount_Reason__c = 'Managerial Discount';
        qli1.Discount_Amount__c = 0.00;
        qli1.IsDiscretionaryAC__c = True;
        insert qli1;
       
        opp1.SyncedQuoteId = qu.Id;
        opp1.StageName = 'Closed Won';
        
        
        Test.setMock(HttpCalloutMock.class, new DailyBatchToCalculateCarryOverACMock());
        
        update opp1;
        DailyBatchToCalculateCarryOverAC calculateCarryOver = new DailyBatchToCalculateCarryOverAC();
        Database.executeBatch(calculateCarryOver);
        Test.stopTest();
        }
    } 
      
}
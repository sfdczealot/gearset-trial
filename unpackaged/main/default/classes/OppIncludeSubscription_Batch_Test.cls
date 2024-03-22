/**
* Created by Yuni on 9/21/2018.
*/
@IsTest
public class OppIncludeSubscription_Batch_Test {
    static testMethod void runTest() {
        Test.startTest();
        list<Opportunity> listOpp = new list<Opportunity>();
        list<Opportunity> listOpp2 = new list<Opportunity>();
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        
        Subsidiary__c sb = PGTestDataFactory.createSubsidiary();
        PGTestDataFactory_v2.initSetupData();
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
        a.Status__c = 'Active';
        a.Account_Rule_Code__c = 'test';
        a.Subsidiary__pc = sb.Id;
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = '51231231';
        a.Current_Subscription_Spending_Amount__c = 200;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Closed Won';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(-30);
        opp.Subsidiary__c = sb.id;
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = false;
        opp.Is_Current_Subscription__c = true;
        opp.RecordTypeId =oppRectype;
        opp.Include_Subscription_Ext__c = true;
        opp.Summary_Of_Subscription_Item_new__c = null;
        opp.Total_Spending_on_Discretionary_Prod_new__c = null;
        opp.Order_Type_Clone__c = 'Contract - Upgrade';
        opp.Approval_Status__c = 'OMC Approval Approved';
		opp.OMC_Approved_Date__c = date.today().addDays(-366);
        listOpp.add(opp);
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/);
        insert productClass;
        
        list<Product2> listProd = new list<Product2>();
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        listProd.add(prod);
        
        Product2 prod2 = new Product2(Name = 'Test Prod2', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        listProd.add(prod2);
        insert listProd;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        list<PricebookEntry> listPBE = new list<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true);
        listPBE.add(pbe);
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, CurrencyIsoCode = 'SGD', UseStandardPrice = false);
        listPBE.add(pbe2);
        insert listPBE;
        
        opp = new opportunity();
        opp.Name = 'Test Opp 2';
        opp.StageName = 'Closed Won';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(-10);
        opp.Subsidiary__c = sb.id;
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = true;
        opp.Is_Current_Subscription__c = true;
        opp.RecordTypeId =oppRectype;
        opp.Include_Subscription_Ext__c = true;
        opp.Order_Type_Clone__c = 'Contract - Upgrade';
        opp.Total_Spending_on_Discretionary_Prod_new__c = null;
        opp.Approval_Status__c = 'OMC Approval Approved';
		opp.OMC_Approved_Date__c = date.today().addDays(-366);
        listOpp.add(opp);
        
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Test Opp 3';
        opp1.StageName = 'Closed Won';
        opp1.AccountId = a.id;
        opp1.CloseDate = system.today().AddDays(-325);
        opp1.Subsidiary__c = sb.id;
        opp1.PG_Tenure__c = 4;
        opp1.Total_Spending__c = 100;
        opp1.Months_Included__c = true;
        opp1.Is_Current_Subscription__c = true;
       	opp1.RecordTypeId =oppRectype;
        opp1.Include_Subscription_Ext__c = true;
        opp1.Order_Type_Clone__c = 'Contract - Upgrade';
        opp1.Summary_Of_Subscription_Item_new__c = null;
        opp1.Total_Spending_on_Discretionary_Prod_new__c = null;
        opp.Approval_Status__c = 'OMC Approval Approved';
		opp.OMC_Approved_Date__c = date.today().addDays(-366);
        listOpp.add(opp1);
        
        insert listOpp;
        
        Integer SummaryAmount1 = 0, SummaryAmount2 = 0;
        list<OpportunityLineItem> listOppLine = new list<OpportunityLineItem>();
        OpportunityLineItem oppLine = New OpportunityLineItem();
        oppLine.OpportunityId = listOpp[0].Id;
        oppLine.Push_to_NetSuite__c = true;
        oppLine.PricebookEntryId = pbe2.Id;
        oppLine.Product2Id = prod.Id;
        oppLine.UnitPrice = 300;
        oppLine.Product_Category__c = 'Subscription';
        oppLine.Discount_Reason__c = 'VIP (Relationship)';
        oppLine.Quantity = 2;
        SummaryAmount1 = 300;
        oppline.Amount_Despite_VIP__c = 300;
        listOppLine.add(oppLine);
        
        oppLine = New OpportunityLineItem();
        oppLine.OpportunityId = listOpp[1].Id;
        oppLine.Push_to_NetSuite__c = true;
        oppLine.PricebookEntryId = pbe2.Id;
        oppLine.Product2Id = prod.Id;
        oppLine.UnitPrice = 2500;
        oppLine.Quantity = 2;
        SummaryAmount2 = 2500;
        oppline.Amount_Despite_VIP__c = 2500;
        oppLine.Product_Category__c = 'Subscription';
        listOppLine.add(oppLine);
        insert listOppLine;
        
        //oppLine = [select Id, Product_Category__c, Amount_Despite_VIP__c, Opportunity.Summary_Of_Subscription_Item__c, UnitPrice, Amount__c from OpportunityLineItem where id =: opp.id or id=:opp1.Id];
        system.debug('OPPLINE:'+oppLine);
        
        //listOpp = [Select id, Is_Current_Subscription__c, StageName, Include_Subscription_Ext__c, Attachment_Limit_Exceeded__c, OMC_Approved_Date__c, Approval_Status__c,Summary_Of_Subscription_Item__c,IsWon,recordtype.name,Summary_Of_Subscription_Item_new__c from opportunity where id =: opp.id or id=:opp1.Id];
        for (Opportunity row: listOpp) {
            row.StageName = 'Closed Won';
            row.Approval_Status__c = 'OMC Approval Approved';
            row.Is_Current_Subscription__c = true;
            row.Attachment_Limit_Exceeded__c = true;
            if(row.Id == opp1.Id){
                row.OMC_Approved_Date__c = date.today().addDays(-366);
            }
            else{
                row.OMC_Approved_Date__c = date.today();
            }
            row.Summary_Of_Subscription_Item_new__c = 1;
            //
        } 
        update listOpp;
        
        system.debug('IKI:' + [Select id,accountid,Total_Spending_on_Discretionary_Prod_new__c, Is_Current_Subscription__c, StageName, Include_Subscription_Ext__c,Include_Subscription__c , Attachment_Limit_Exceeded__c, OMC_Approved_Date__c, Approval_Status__c,Summary_Of_Subscription_Item__c,IsWon,recordtype.name,Summary_Of_Subscription_Item_new__c from opportunity where id =: opp.id or id=:opp1.Id]);
        //listOpp2 = [select Id, Name, AccountId, Include_Subscription__c, Include_Subscription_Ext__c, ByAuto__c, CloseDate, Is_Current_Subscription__c, Summary_Of_Subscription_Item_new__c, iswon, RecordType.Name, Account.Status__c  from Opportunity where RecordType.Name='B2C' and IsWon=true and Account.Status__c!='Cancelled' order by CloseDate desc];
        
        OppIncludeSubscription_BatchSchedulable schedulable = new OppIncludeSubscription_BatchSchedulable('');
        String sch = '0 0 0 * * ? *';
        system.schedule('Test Schedule', sch, schedulable);
        
        //AccountCurrentSubscriptionFix z = new AccountCurrentSubscriptionFix();
        //database.executeBatch(z);
        OppIncludeSubscription_Batch x = new OppIncludeSubscription_Batch(a.id);
        //  and ((Include_Subscription__c=true and Include_Subscription_Ext__c=false) or (Include_Subscription__c=false and Include_Subscription_Ext__c=true) or (Is_Current_Subscription__c=true and DAY_ONLY(OMC_Approved_Date__C)<=today))
        database.executeBatch(x);
        
        /*Database.executeBatch(new OppIncludeSubscription_Batch(a.id));
        Database.executeBatch(new OppIncludeSubscription_Batch(null));
        ExcludeFromSpending_BatchSchedulable schedulable = new ExcludeFromSpending_BatchSchedulable(a.id);
        String sch = '0 0 0 * * ? *';
        system.schedule('Test Schedule', sch, schedulable);
        */
        SlackAlert_Batch w = new SlackAlert_Batch();
        database.executeBatch(w);
        Database.executeBatch(new OptyRollUpFieldUpd_Batch(opp.id));
        Database.executeBatch(new OptyRollUpFieldUpd_Batch(opp1.id));
        Database.executeBatch(new OptyRollUpFieldUpd_Batch_DF());
        
        Database.executeBatch(new AccountCSS_Batch_DF());
        Database.executeBatch(new AccountCSSRefundCOVID_DF());
        Database.executeBatch(new AccountCSS_Batch(a.Id));
        Database.executeBatch(new AccountTS_Batch_DF());
        Database.executeBatch(new AccountTS_Batch(a.Id));
        //Database.executeBatch(new OptyAmtDespiteVIPUpg_Batch_DF());
        //Database.executeBatch(new OptyAmtDespiteVIPRen_Batch_DF());
        
        
    }
    static testMethod void runTest2(){
              
         test.startTest(); 
         list<Opportunity> listOpp = new list<Opportunity>();
        list<Opportunity> listOpp2 = new list<Opportunity>();
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        
        Subsidiary__c sb = PGTestDataFactory.createSubsidiary();
        PGTestDataFactory_v2.initSetupData();
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
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Status__c = 'Active';
        a.Account_Rule_Code__c = 'test';
        a.Subsidiary__pc = sb.Id;
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = '51231231';
        a.PersonBirthdate = date.newInstance(1970, 1, 1);
        a.Current_Subscription_Spending_Amount__c = 200;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Closed Won';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(-30);
        opp.Subsidiary__c = sb.id;
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = false;
        opp.Is_Current_Subscription__c = true;
        opp.RecordTypeId =oppRectype;
        opp.Include_Subscription_Ext__c = true;
        opp.Summary_Of_Subscription_Item_new__c = null;
        opp.Total_Spending_on_Discretionary_Prod_new__c = null;
        opp.Order_Type_Clone__c = 'Contract - Upgrade';
        opp.Approval_Status__c = 'OMC Approval Approved';
		opp.OMC_Approved_Date__c = date.today().addDays(-366);
        listOpp.add(opp);
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/);
        insert productClass;
        
        list<Product2> listProd = new list<Product2>();
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        listProd.add(prod);
        
        Product2 prod2 = new Product2(Name = 'Test Prod2', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        listProd.add(prod2);
        insert listProd;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        list<PricebookEntry> listPBE = new list<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true);
        listPBE.add(pbe);
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, CurrencyIsoCode = 'SGD', UseStandardPrice = false);
        listPBE.add(pbe2);
        insert listPBE;
        
        opp = new opportunity();
        opp.Name = 'Test Opp 2';
        opp.StageName = 'Closed Won';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(-10);
        opp.Subsidiary__c = sb.id;
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = true;
        opp.Is_Current_Subscription__c = true;
        opp.RecordTypeId =oppRectype;
        opp.Include_Subscription_Ext__c = true;
        opp.Order_Type_Clone__c = 'Contract - Upgrade';
        opp.Total_Spending_on_Discretionary_Prod_new__c = null;
        opp.Approval_Status__c = 'OMC Approval Approved';
		opp.OMC_Approved_Date__c = date.today().addDays(-366);
        listOpp.add(opp);
        
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Test Opp 3';
        opp1.StageName = 'Closed Won';
        opp1.AccountId = a.id;
        opp1.CloseDate = system.today().AddDays(-325);
        opp1.Subsidiary__c = sb.id;
        opp1.PG_Tenure__c = 4;
        opp1.Total_Spending__c = 100;
        opp1.Months_Included__c = true;
        opp1.Is_Current_Subscription__c = true;
       	opp1.RecordTypeId =oppRectype;
        opp1.Include_Subscription_Ext__c = true;
        opp1.Order_Type_Clone__c = 'Contract - Upgrade';
        opp1.Summary_Of_Subscription_Item_new__c = null;
        opp1.Total_Spending_on_Discretionary_Prod_new__c = null;
        opp.Approval_Status__c = 'OMC Approval Approved';
		opp.OMC_Approved_Date__c = date.today().addDays(-366);
        listOpp.add(opp1);
        
        insert listOpp;
        
        Integer SummaryAmount1 = 0, SummaryAmount2 = 0;
        list<OpportunityLineItem> listOppLine = new list<OpportunityLineItem>();
        OpportunityLineItem oppLine = New OpportunityLineItem();
        oppLine.OpportunityId = listOpp[0].Id;
        oppLine.Push_to_NetSuite__c = true;
        oppLine.PricebookEntryId = pbe2.Id;
        oppLine.Product2Id = prod.Id;
        oppLine.UnitPrice = 300;
        oppLine.Product_Category__c = 'Subscription';
        oppLine.Discount_Reason__c = 'VIP (Relationship)';
        oppLine.Quantity = 2;
        SummaryAmount1 = 300;
        oppline.Amount_Despite_VIP__c = 300;
        listOppLine.add(oppLine);
        
        oppLine = New OpportunityLineItem();
        oppLine.OpportunityId = listOpp[1].Id;
        oppLine.Push_to_NetSuite__c = true;
        oppLine.PricebookEntryId = pbe2.Id;
        oppLine.Product2Id = prod.Id;
        oppLine.UnitPrice = 2500;
        oppLine.Quantity = 2;
        SummaryAmount2 = 2500;
        oppline.Amount_Despite_VIP__c = 2500;
        oppLine.Product_Category__c = 'Subscription';
        listOppLine.add(oppLine);
        insert listOppLine;
        
        //oppLine = [select Id, Product_Category__c, Amount_Despite_VIP__c, Opportunity.Summary_Of_Subscription_Item__c, UnitPrice, Amount__c from OpportunityLineItem where id =: opp.id or id=:opp1.Id];
        system.debug('OPPLINE:'+oppLine);
        
        //listOpp = [Select id, Is_Current_Subscription__c, StageName, Include_Subscription_Ext__c, Attachment_Limit_Exceeded__c, OMC_Approved_Date__c, Approval_Status__c,Summary_Of_Subscription_Item__c,IsWon,recordtype.name,Summary_Of_Subscription_Item_new__c from opportunity where id =: opp.id or id=:opp1.Id];
        for (Opportunity row: listOpp) {
            row.StageName = 'Closed Won';
            row.Approval_Status__c = 'OMC Approval Approved';
            row.Is_Current_Subscription__c = true;
            row.Attachment_Limit_Exceeded__c = true;
            if(row.Id == opp1.Id){
                row.OMC_Approved_Date__c = date.today().addDays(-366);
            }
            else{
                row.OMC_Approved_Date__c = date.today();
            }
            row.Summary_Of_Subscription_Item_new__c = 1;
            //
        } 
        update listOpp;
      
        Database.executeBatch(new OptyRollUpFieldUpd_Batch(opp.id));
        Database.executeBatch(new OptyRollUpFieldUpd_Batch(opp1.id));
         System.schedule('Job from test class 5', '0 0 0 * * ? *', new SlackAlert_BatchSchedulable());
        System.schedule('Job from test class 3', '0 0 0 * * ? *', new AccountCSS_BatchSchedulable());
        System.schedule('Job from test class 4', '0 0 0 * * ? *', new AccountTS_BatchSchedulable());
       test.stopTest();
        
    }

	static testMethod void runTest3(){
              
         test.startTest(); 
         list<Opportunity> listOpp = new list<Opportunity>();
        list<Opportunity> listOpp2 = new list<Opportunity>();
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        PGTestDataFactory_v2.initSetupData();
        Subsidiary__c sb = PGTestDataFactory.createSubsidiary();
        
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
      //  a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Status__c = 'Active';
        a.Account_Rule_Code__c = 'test';
        a.Subsidiary__pc = sb.Id;
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = '51231231';
        a.PersonBirthdate = date.newInstance(1970, 1, 1);
        a.Current_Subscription_Spending_Amount__c = 200;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Closed Won';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(-30);
        opp.Subsidiary__c = sb.id;
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = false;
        opp.Is_Current_Subscription__c = true;
        opp.RecordTypeId =oppRectype;
        opp.Include_Subscription_Ext__c = true;
        opp.Summary_Of_Subscription_Item_new__c = null;
        opp.Total_Spending_on_Discretionary_Prod_new__c = null;
        opp.Order_Type_Clone__c = 'Contract - Upgrade';
        opp.Approval_Status__c = 'OMC Approval Approved';
		opp.OMC_Approved_Date__c = date.today().addDays(-366);
        listOpp.add(opp);
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/);
        insert productClass;
        
        list<Product2> listProd = new list<Product2>();
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        listProd.add(prod);
        
        Product2 prod2 = new Product2(Name = 'Test Prod2', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        listProd.add(prod2);
        insert listProd;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        list<PricebookEntry> listPBE = new list<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true);
        listPBE.add(pbe);
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, CurrencyIsoCode = 'SGD', UseStandardPrice = false);
        listPBE.add(pbe2);
        insert listPBE;
        
        opp = new opportunity();
        opp.Name = 'Test Opp 2';
        opp.StageName = 'Closed Won';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(-10);
        opp.Subsidiary__c = sb.id;
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = true;
        opp.Is_Current_Subscription__c = true;
        opp.RecordTypeId =oppRectype;
        opp.Include_Subscription_Ext__c = true;
        opp.Order_Type_Clone__c = 'Contract - Upgrade';
        opp.Total_Spending_on_Discretionary_Prod_new__c = null;
        opp.Approval_Status__c = 'OMC Approval Approved';
		opp.OMC_Approved_Date__c = date.today().addDays(-366);
        listOpp.add(opp);
        
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Test Opp 3';
        opp1.StageName = 'Closed Won';
        opp1.AccountId = a.id;
        opp1.CloseDate = system.today().AddDays(-325);
        opp1.Subsidiary__c = sb.id;
        opp1.PG_Tenure__c = 4;
        opp1.Total_Spending__c = 100;
        opp1.Months_Included__c = true;
        opp1.Is_Current_Subscription__c = true;
       	opp1.RecordTypeId =oppRectype;
        opp1.Include_Subscription_Ext__c = true;
        opp1.Order_Type_Clone__c = 'Contract - Upgrade';
        opp1.Summary_Of_Subscription_Item_new__c = null;
        opp1.Total_Spending_on_Discretionary_Prod_new__c = null;
        opp.Approval_Status__c = 'OMC Approval Approved';
		opp.OMC_Approved_Date__c = date.today().addDays(-366);
        listOpp.add(opp1);
        
        insert listOpp;
        
        Integer SummaryAmount1 = 0, SummaryAmount2 = 0;
        list<OpportunityLineItem> listOppLine = new list<OpportunityLineItem>();
        OpportunityLineItem oppLine = New OpportunityLineItem();
        oppLine.OpportunityId = listOpp[0].Id;
        oppLine.Push_to_NetSuite__c = true;
        oppLine.PricebookEntryId = pbe2.Id;
        oppLine.Product2Id = prod.Id;
        oppLine.UnitPrice = 300;
        oppLine.Product_Category__c = 'Subscription';
        oppLine.Discount_Reason__c = 'VIP (Relationship)';
        oppLine.Quantity = 2;
        SummaryAmount1 = 300;
        oppline.Amount_Despite_VIP__c = 300;
        listOppLine.add(oppLine);
        
        oppLine = New OpportunityLineItem();
        oppLine.OpportunityId = listOpp[1].Id;
        oppLine.Push_to_NetSuite__c = true;
        oppLine.PricebookEntryId = pbe2.Id;
        oppLine.Product2Id = prod.Id;
        oppLine.UnitPrice = 2500;
        oppLine.Quantity = 2;
        SummaryAmount2 = 2500;
        oppline.Amount_Despite_VIP__c = 2500;
        oppLine.Product_Category__c = 'Subscription';
        oppLine.Discount_Reason__c = 'VIP (Spending)';
        listOppLine.add(oppLine);
        insert listOppLine;
        
        //oppLine = [select Id, Product_Category__c, Amount_Despite_VIP__c, Opportunity.Summary_Of_Subscription_Item__c, UnitPrice, Amount__c from OpportunityLineItem where id =: opp.id or id=:opp1.Id];
        system.debug('OPPLINE:'+oppLine);
        
        //listOpp = [Select id, Is_Current_Subscription__c, StageName, Include_Subscription_Ext__c, Attachment_Limit_Exceeded__c, OMC_Approved_Date__c, Approval_Status__c,Summary_Of_Subscription_Item__c,IsWon,recordtype.name,Summary_Of_Subscription_Item_new__c from opportunity where id =: opp.id or id=:opp1.Id];
        for (Opportunity row: listOpp) {
            row.StageName = 'Closed Won';
            row.Approval_Status__c = 'OMC Approval Approved';
            row.Is_Current_Subscription__c = true;
            row.Attachment_Limit_Exceeded__c = true;
            if(row.Id == opp1.Id){
                row.OMC_Approved_Date__c = date.today().addDays(-366);
            }
            else{
                row.OMC_Approved_Date__c = date.today();
            }
            row.Summary_Of_Subscription_Item_new__c = 1;
            //
        } 
        update listOpp;
      
        Database.executeBatch(new OptyRollUpFieldUpd_Batch_DF());
       test.stopTest();
        
    }
    
}
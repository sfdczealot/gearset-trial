@IsTest
public class OptyAmtDespiteVIPRen_Batch_DF_Test {
    static testMethod void runTest1() {
        Test.startTest();
        list<Opportunity> listOpp = new list<Opportunity>();
        
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
      //  a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Status__c = 'Active';
        a.Account_Rule_Code__c = 'test';
        a.Subsidiary__pc = sb.Id;
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = '51231231';
        a.PersonBirthdate = system.today();
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
        opp.Include_Subscription_Ext__c = false;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        listOpp.add(opp);
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Subscription', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/);
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
        opp.Include_Subscription_Ext__c = false;
        opp.Payment_Amount__c = 290;
        opp.Pro_Rate__c = 20;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        listOpp.add(opp);
        
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Test Opp 3';
        opp1.StageName = 'Closed Won';
        opp1.AccountId = a.id;
        opp1.CloseDate = system.today().AddDays(-40);
        opp1.Subsidiary__c = sb.id;
        opp1.PG_Tenure__c = 4;
        opp1.Total_Spending__c = 100;
        opp1.Months_Included__c = true;
        opp1.Is_Current_Subscription__c = true;
        opp1.RecordTypeId =oppRectype;
        opp1.Include_Subscription_Ext__c = false;
        opp1.Order_Type_Clone__c = 'Contract - Renewal';
        opp1.Payment_Amount__c = 2400;
        opp1.Pro_Rate__c = 0.00;
        listOpp.add(opp1);
        
        insert listOpp;
        integer linecount = 0;
        Integer SummaryAmount1 = 0, SummaryAmount2 = 0;
        list<OpportunityLineItem> listOppLine = new list<OpportunityLineItem>();
        OpportunityLineItem oppLine = New OpportunityLineItem();
        oppLine.OpportunityId = opp.Id;
        oppLine.Push_to_NetSuite__c = true;
        oppLine.PricebookEntryId = pbe2.Id;
        oppLine.Product2Id = prod.Id;
        oppLine.UnitPrice = 300;
        oppLine.Product_Category__c = 'Subscription';
        oppLine.Discount_Reason__c = 'VIP (Spending)';
        oppLine.Quantity = 2;
        SummaryAmount1 = 300;
        linecount++;
        oppline.Amount_Despite_VIP__c = 300;
        listOppLine.add(oppLine);
        
        oppLine = New OpportunityLineItem();
        oppLine.OpportunityId = opp1.Id;
        oppLine.Push_to_NetSuite__c = true;
        oppLine.PricebookEntryId = pbe2.Id;
        oppLine.Product2Id = prod.Id;
        oppLine.UnitPrice = 2500;
        oppLine.Quantity = 2;
        SummaryAmount2 = 2500;
        oppLine.Discount_Reason__c = 'Others';
        oppline.Amount_Despite_VIP__c = 2500;
        oppLine.Product_Category__c = 'Subscription';
        listOppLine.add(oppLine);
        linecount++;
        insert listOppLine;
        system.debug('linecount:'+linecount);
        oppLine = [select Id, Product_Category__c, Amount_Despite_VIP__c, Opportunity.Summary_Of_Subscription_Item__c, UnitPrice, Amount__c from OpportunityLineItem where Id=:oppLine.Id];
        system.debug('OPPLINE:'+oppLine);
        
        listOpp = [Select id, StageName, Approval_Status__c,Summary_Of_Subscription_Item__c from opportunity where id =: opp.id or id=:opp1.Id];
        for (Opportunity row: listOpp) {
            row.StageName = 'Closed Won';
            row.Approval_Status__c = 'OMC Approval Approved';
            row.Is_Current_Subscription__c = true;
            row.Attachment_Limit_Exceeded__c = true;
            /*if(row.id == opp.Id){
                row.Summary_Of_Subscription_Item__c = SummaryAmount1;
            }
            if(row.id == opp1.Id){
                row.Summary_Of_Subscription_Item__c = SummaryAmount2;
            }*/
            //System.assertEquals(1.00, row.Summary_Of_Subscription_Item_new__c);
        }
        update listOpp;
        system.debug('IKI:' + listOpp);
        Database.executeBatch(new OptyAmtDespiteVIPRen_Batch_DF());
        Test.stoptest();
     
    }
    static testMethod void runTest2() {
        Test.startTest();
        list<Opportunity> listOpp = new list<Opportunity>();
        
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
        a.PersonBirthdate =system.today();
            
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
        opp.Include_Subscription_Ext__c = false;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        listOpp.add(opp);
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Subscription', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/);
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
        opp.Include_Subscription_Ext__c = false;
        opp.Payment_Amount__c = 290;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        listOpp.add(opp);
        
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Test Opp 3';
        opp1.StageName = 'Closed Won';
        opp1.AccountId = a.id;
        opp1.CloseDate = system.today().AddDays(-40);
        opp1.Subsidiary__c = sb.id;
        opp1.PG_Tenure__c = 4;
        opp1.Total_Spending__c = 100;
        opp1.Months_Included__c = true;
        opp1.Is_Current_Subscription__c = true;
        opp1.RecordTypeId =oppRectype;
        opp1.Include_Subscription_Ext__c = false;
        opp1.Order_Type_Clone__c = 'Contract - Renewal';
        opp1.Payment_Amount__c = 2400;
        listOpp.add(opp1);
        
        insert listOpp;
        integer linecount = 0;
        Integer SummaryAmount1 = 0, SummaryAmount2 = 0;
        list<OpportunityLineItem> listOppLine = new list<OpportunityLineItem>();
        OpportunityLineItem oppLine = New OpportunityLineItem();
        oppLine.OpportunityId = opp.Id;
        oppLine.Push_to_NetSuite__c = true;
        oppLine.PricebookEntryId = pbe2.Id;
        oppLine.Product2Id = prod.Id;
        oppLine.UnitPrice = 300;
        oppLine.Product_Category__c = 'Subscription';
        oppLine.Quantity = 2;
        SummaryAmount1 = 300;
        linecount++;
        oppline.Amount_Despite_VIP__c = 300;
        listOppLine.add(oppLine);
        oppLine = New OpportunityLineItem();
        oppLine.OpportunityId = opp.Id;
        oppLine.Push_to_NetSuite__c = true;
        oppLine.PricebookEntryId = pbe2.Id;
        oppLine.Product2Id = prod.Id;
        oppLine.UnitPrice = 300;
        oppLine.Product_Category__c = 'Subscription';
        oppline.PO__c = true;
        oppline.Start_Date__c = system.today();
        oppline.End_Date__c = system.today().AddDays(365);
        oppLine.Quantity = 2;
        SummaryAmount1 = 0;
        linecount++;
        oppline.Amount_Despite_VIP__c = 0;
        listOppLine.add(oppLine);
        
        oppLine = New OpportunityLineItem();
        oppLine.OpportunityId = opp1.Id;
        oppLine.Push_to_NetSuite__c = true;
        oppLine.PricebookEntryId = pbe2.Id;
        oppLine.Product2Id = prod.Id;
        oppLine.UnitPrice = 2500;
        oppLine.Quantity = 2;
        SummaryAmount2 = 2500;
        oppline.Amount_Despite_VIP__c = 2500;
        oppLine.Product_Category__c = 'Subscription';
        listOppLine.add(oppLine);
        oppLine = New OpportunityLineItem();
        oppLine.OpportunityId = opp1.Id;
        oppLine.Push_to_NetSuite__c = false;
        oppLine.PricebookEntryId = pbe2.Id;
        oppLine.Product2Id = prod.Id;
        oppLine.UnitPrice = 0;
        oppLine.Product_Category__c = 'Subscription';
        oppline.PO__c = true;
        oppline.Start_Date__c = system.today();
        oppline.End_Date__c = system.today().AddDays(365);
        oppLine.Quantity = 2;
        SummaryAmount1 = 0;
        linecount++;
        oppline.Amount_Despite_VIP__c = 0;
        linecount++;
        listOppLine.add(oppLine);
        
        insert listOppLine;
        system.debug('linecount:'+linecount);
        oppLine = [select Id, Product_Category__c, Amount_Despite_VIP__c, Opportunity.Summary_Of_Subscription_Item__c, UnitPrice, Amount__c from OpportunityLineItem where Id=:oppLine.Id];
        system.debug('OPPLINE:'+oppLine);
        
        listOpp = [Select id, StageName, Approval_Status__c,Summary_Of_Subscription_Item__c from opportunity where id =: opp.id or id=:opp1.Id];
        for (Opportunity row: listOpp) {
            row.StageName = 'Closed Won';
            row.Approval_Status__c = 'OMC Approval Approved';
            row.Is_Current_Subscription__c = true;
            row.Attachment_Limit_Exceeded__c = true;
            /*if(row.id == opp.Id){
                row.Summary_Of_Subscription_Item__c = SummaryAmount1;
            }
            if(row.id == opp1.Id){
                row.Summary_Of_Subscription_Item__c = SummaryAmount2;
            }*/
            //System.assertEquals(1.00, row.Summary_Of_Subscription_Item_new__c);
        }
        update listOpp;
        system.debug('IKI:' + listOpp);
        Database.executeBatch(new OptyAmtDespiteVIPRen_Batch_DF());
        Test.stoptest(); 
    }
}
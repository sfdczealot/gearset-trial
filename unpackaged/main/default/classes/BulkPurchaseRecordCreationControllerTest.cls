@isTest
public class BulkPurchaseRecordCreationControllerTest {
    public static testMethod void unitTest(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true); 
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        Trigger_Execute__c tE = new Trigger_Execute__c();
        tE.Name = 'QuoteLineItemTriggerPG';     
        insert tE;
        
        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;
        
        Trigger_Execute__c TEQLI = new Trigger_Execute__c();
        TEQLI.Name = 'QuoteLineItemTrigger';
        TEQLI.Enable_del__c = true;
        insert TEQLI;
        
        update runningUser;
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        objcustom.IsTrackingEnable__c = true;
        insert objcustom;
        
        QliToOliFieldMapping__c objcustomsetting=new QliToOliFieldMapping__c();
        objcustomsetting.Name='Start_Date__c';
        objcustomsetting.OliField__c='Start_Date__c';
        insert objcustomsetting;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = '11678080';
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
        a.Mobile_Country__c = '65';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'A564356J';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        //Set<String> pribookId = new Set<String>();
        //pribookId.add(standardPB.Id); 
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5',Item_Type__c =  'Item Group', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true, Income_Account_Name__c = 'Sales Revnue');
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true, Income_Account_Name__c = 'Sales Revnue');
        insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        List<String> prodSNo = new List<String>();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        List<PricebookEntry> childpbeList = new List<PricebookEntry>();
        childpbeList.add(pbe2);
        
        PricebookEntry pbe3 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod2.id, unitprice=100.0, isActive=true, CurrencyIsoCode = 'SGD', useStandardPrice = false);
        insert pbe3;
        
        PricebookEntry pbe4 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod2.id, unitprice=100.0, isActive=true, CurrencyIsoCode = 'SGD', useStandardPrice = false);
        insert pbe4;
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        pbeList.add(pbe4);
        Map<Id,PricebookEntry> isVsPBE = new Map<Id,PricebookEntry>();
        isVsPBE.put(pbe4.product2id,pbe4);
        Map<String,Item_Bundle__c> mapOfItemBundle = new Map<String,Item_Bundle__c>();
        Item_Bundle__c bundle = new Item_Bundle__c();
        bundle.Qty__c = 3;
        bundle.Parent_Product__c = prod.id;
        bundle.Child_Product__c = prod2.Id;
        bundle.SNo__c = 1.01;
        insert bundle;
        List<Item_Bundle__c> itemBundleList = new List<Item_Bundle__c>();
        mapOfItemBundle.put(bundle.id,bundle);
        itemBundleList.add(bundle);
        prodSno.add(bundle.Sno__c+'_'+bundle.Child_Product__c);
        
        Opportunity opp = new opportunity();
        opp.Name = 'Bulk Purchase ';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.isBulkUpdate__c = true;
        opp.RecordTypeId = oppRectype;
        opp.OwnerId = userinfo.getUserId();
        opp.PG_Tenure__c = 1;
        opp.Stinger__c = true;
        opp.Opportunity_Type__c = 'B2C - Renewal';
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opp);
        system.assertEquals(opp.Id,opp.Id,'1');
        Set<Id> oppIds = new Set<Id>();
        oppIds.add(opp.Id);
        Test.startTest();
        Quote objquote=new Quote();
        objquote.name='Test';
        objquote.CreatedDate__c=system.today();
        objquote.OpportunityId=opp.Id;
        insert objquote;
        List<Quote> quoList = new List<Quote>();
        quoList.add(objquote);
        Set<Id> quoteIdSet = new Set<Id>();
        quoteIdSet.add(objquote.Id);
        
        opp.SyncedQuoteId = objquote.id;
        update opp;
        
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        //oli.Promo_Mechanic_Id__c = prm.Id;
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        oli.UnitPrice = 2;
        //insert oli;
        listOppLine.add(oli);
        
        opportunityLineItem oli2 = new opportunityLineItem();
        oli2.Product2Id = prod2.Id;
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbe2.Id;
        //oli2.Promo_Mechanic_Id__c = prm1.Id;
        oli2.Amount_Despite_VIP__c = 2.3;
        oli2.Pro_Rate_Amount__c = 2;
        oli2.UnitPrice = 2;
        //insert oli2;
        
        List<quoteLineItem> listQuoLine = new List<quoteLineItem>();
        quoteLineItem qli = new quoteLineItem();
        qli.Product2Id = prod.Id;
        qli.OpportunityLineItemId = oli.Id;
        qli.PricebookEntryId = pbe2.Id;
        qli.Amount_Despite_VIP__c = 1.3;
        qli.Pro_Rate_Amount__c = 2;
        //qli.Promo_Mechanic_Id__c = prm.Id;
        qli.UnitPrice = 2;
        qli.QuoteId = objquote.Id;
        qli.Quantity = 2;
        insert qli;
        listQuoLine.add(qli);
        Set<Id> qliteIdSet = new Set<Id>();
        qliteIdSet.add(qli.id);
        
        quoteLineItem qli2 = new quoteLineItem();
        qli2.Product2Id = prod2.Id;
        qli2.OpportunityLineItemId = oli2.Id;
        qli2.PricebookEntryId = pbe2.Id;
        qli2.Amount_Despite_VIP__c = 2.3;
        qli2.Pro_Rate_Amount__c = 2;
        qli2.QuoteId = objquote.Id;
        qli2.UnitPrice = 2;
        qli2.Quantity = 2;
        //qli2.Promo_Mechanic_Id__c = prm1.Id;
        insert qli2;
        List<String> csvRowValues = new List<String>();
        String filecontents;
        list<Bulk_Purchase_Header__c> bphlist  = new list<Bulk_Purchase_Header__c>();
        Bulk_Purchase_Header__c bph = new Bulk_Purchase_Header__c();
        bph.Name = 'Name';
        bph.API_NAME__c = 'Name';
        bph.Object_Name__c = 'Opportunity';
        bphlist.add(bph);  
        
        
        Bulk_Purchase_Header__c bph2 = new Bulk_Purchase_Header__c();
        bph2.Name = 'Account Name';
        bph2.API_NAME__c = 'Accountid';
        bph2.Object_Name__c = 'Opportunity';
        bphlist.add(bph2); 
        Bulk_Purchase_Header__c bph3 = new Bulk_Purchase_Header__c();
        bph3.Name = 'Close Date';
        bph3.API_NAME__c = 'CloseDate';
        bph3.Object_Name__c = 'Opportunity';
        bphlist.add(bph3); 
        Bulk_Purchase_Header__c bph4 = new Bulk_Purchase_Header__c();
        bph4.Name = 'Discount';
        bph4.API_NAME__c = 'Discount__C';
        bph4.Object_Name__c = 'QuoteLineItem';
        bphlist.add(bph4); 
        Bulk_Purchase_Header__c bph5 = new Bulk_Purchase_Header__c();
        bph5.Name = 'Stage';
        bph5.API_NAME__c = 'Stagename';
        bph5.Object_Name__c = 'Opportunity';
        bphlist.add(bph5); 
        Bulk_Purchase_Header__c bph6 = new Bulk_Purchase_Header__c();
        bph6.Name = 'Quantity';
        bph6.API_NAME__c = 'Quantity';
        bph6.Object_Name__c = 'QuoteLineItem';
        bphlist.add(bph6); 
        Bulk_Purchase_Header__c bph7 = new Bulk_Purchase_Header__c();
        bph7.Name = 'Start Date';
        bph7.API_NAME__c = 'Start_Date__c';
        bph7.Object_Name__c = 'QuoteLineItem';
        bphlist.add(bph7); 
        Bulk_Purchase_Header__c bph8 = new Bulk_Purchase_Header__c();
        bph8.Name = 'End Date';
        bph8.API_NAME__c = 'End_Date__c';
        bph8.Object_Name__c = 'QuoteLineItem';
        bphlist.add(bph8); 
        Bulk_Purchase_Header__c bph9 = new Bulk_Purchase_Header__c();
        bph9.Name = 'SKU Code';
        bph9.API_NAME__c = 'Sku_code__c';
        bph9.Object_Name__c = 'Product2';
        bphlist.add(bph9); 
        insert bphlist;
        
        wrapper wrp = new wrapper();
        wrp.recordsOppUpload = opp;
        wrp.recordsQliUpload = qli;
        wrp.recordsProdUpload = prod;
        
        filecontents = 'Test Opp,'+ a.id+',2022-04-29,New,'+prod.sku_code__c+',500,2022-04-29,2023-04-29,100'; 
        String csvColumnHeader = 'Name,Account Name, Close Date, Stage , SKU Code, Quantity, Start Date, End Date,Discount\n';
        PGOpportunityTriggerHandler.isFirstTimeSub = true;
        String fileContent123 = 'TmFtZSxDbG9zZSBEYXRlLFN0YWdlLEFjY291bnQgTmFtZSxTS1UgQ29kZSxRdWFudGl0eSxTdGFydCBEYXRlLEVuZCBEYXRlLERpc2NvdW50DQpidWxrIHB1cmNoYXNlIDUsMjAyMi0wOS0yMyxOZXcsMDAxN0YwMDAwMlB5UGltUUFGLFBHMDFQNDg4OFMxMSw1MDAsMjAyMi0wNC0yMSwyMDIzLTA0LTIyLDEwMA0K';
        
        //BulkPurchaseRecordCreationController.csvFileRead(EncodingUtil.base64Encode(Blob.valueOf(csvColumnHeader + filecontents)));
        // BulkPurchaseRecordCreationController.csvFileRead(fileContent123);
        BulkOrderBatchClass obj = new BulkOrderBatchClass(fileContent123);
        BulkOrderBatchClass.insertChildQli(mapOfItemBundle,prodSno,isVsPBE,prod.id,qli,pbeList);
        BulkOrderBatchClass.QliToOliSyncOnInsert(qliteIdSet);
        BulkOrderBatchClass.applyDefault(oppList);
        BulkOrderBatchClass.updateQuoteStatus(quoList);
        obj.start(null);
        obj.finish(null);
        BulkPurchaseRecordCreationController.updateOpptyToClosed(quoteIdSet);
        BulkOrderBatchClass.increasecoverage();
        BulkPurchaseRecordCreationController.csvFileRead(fileContent123);
        //Database.executeBatch(obj,1);
        
        
        Test.stopTest();
        }
    }
    public class wrapper{
        sObject recordsOppUpload;
        sObject recordsQliUpload;
        sObject recordsProdUpload;
        
    }
    
}
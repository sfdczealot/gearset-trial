@isTest
public class UpgradePackageCalculatorSG_Test {
    
    @isTest
    public static void getUpgradeForecast_Test(){
        Test.startTest();
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        //Insert custom setting
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGAccountTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        // Insert account 
        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agent').getRecordTypeId();
        Account acc = new Account();
        acc.Salutation = 'Mr.';
        acc.FirstName = 'Test';
        acc.LastName = 'Acc';
        acc.CurrencyIsoCode = 'SGD';
        acc.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc.Subscription_End_Date__c = system.today().addMonths(+1);
        acc.BillingStreet = 'test';
        acc.BillingCity = 'test';
        acc.billingcountryCode='SG';
        acc.Country__c = 'Singapore';
        acc.BillingPostalCode = '83737';
        acc.Account_Rule_Code__c = 'Standard';
        acc.PersonEmail = 'test@upgradecalculator.com';
        acc.CEA_Salesperson_Number__c = '85638';
        acc.PersonBirthdate = system.today();
        acc.Status__c = 'Active';
        acc.Account_Previous_Status__c = 'Trial';
        acc.RecordTypeId = recordTypeId;
        acc.CEA_Salesperson_Number__c = 'S458456L';
        acc.Mobile_Country__c = '65';
        insert acc;
        
        //running user
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        
        // Insert subsidiary 
        Subsidiary__c sb = PGTestDataFactory.createSubsidiary();
        Map<String,Subsidiary__c> sbMap = new Map<String,Subsidiary__c>();
        sbMap.put(sb.Id, sb);
        
        // Insert tax code 
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        // Insert Upgrade Package Lookup List
        List<Upgrade_Package_Lookup__c> listOfUPL = new List<Upgrade_Package_Lookup__c>();
        Upgrade_Package_Lookup__c upl1 = new Upgrade_Package_Lookup__c();
        upl1.Country__c = sb.Country__c;
        upl1.Name = 'Standard - SG';
        upl1.Level__c = 1;
        upl1.Upgrade_SKU__c = 'PG01P4886S';
        upl1.Renewal_SKU__c = 'abc2';
        upl1.Renewal_Type__c = 'Renewal Downgrade';
        
        listOfUPL.add(upl1);
        
        Upgrade_Package_Lookup__c upl2 = new Upgrade_Package_Lookup__c();
        upl2.Country__c = sb.Country__c;
        upl2.Name = 'Advance - SG';
        upl2.Level__c = 2;
        upl2.Upgrade_SKU__c = 'PG01P4887S';
        upl2.Renewal_SKU__c = 'abc2';
        upl2.Renewal_Type__c = 'Renewal Downgrade';
        listOfUPL.add(upl2);
        insert listOfUPL;
        
        // Insert Pricebook 
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        // Insert Product Class 
        Product_Class__c productClass = new Product_Class__c(Name = 'Subscription', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        // Insert Product 
        Product2 prod = new Product2(Name = 'Advance', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'PG01P4887S',CurrencyIsoCode = 'SGD',Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        insert prod;
        
        // Standard Pricebook 
        Id StdpricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> pbList = new List<PricebookEntry>();
        // Insert Custom Pricebook 
        Pricebook2 pb = new Pricebook2(Name ='PropertyGuru Pte Ltd',isActive = true,CurrencyIsoCode = 'SGD',Subsidiary__c =sb.Id);
        insert pb;
        
        // Insert Pricebook Entry
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe1;
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=pb.Id,product2id=prod.id, unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        pbList.add(pbe2);
        insert pbList;
        Date startDate = Date.newInstance(2016, 12, 9);
        //Test.startTest();
        UpgradePackageCalculatorSG.getUpgradeForecast(acc.Id,pbList,10.0,prod.SKU_Code__c);
        UpgradePackageCalculatorSG.getUpgradeForecast(acc.Id);
        UpgradeForecastController.getUpgradeForecast(acc.Id);
        UpgradeForecastController.getUpgradeForecast(null);
        UpgradePackageCalculatorSG.getPreviousMonIfItsNotMon(system.today());
        }
        Test.stopTest();
    }    
    
    @isTest
    public static void getUpgradeForecast_Test1(){
        Test.startTest();
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        //Insert custom setting
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGAccountTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        // Insert account 
        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agent').getRecordTypeId();
        Account acc = new Account();
        acc.Salutation = 'Mr.';
        acc.FirstName = 'Test';
        acc.LastName = 'Acc';
        acc.CurrencyIsoCode = 'SGD';
        acc.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc.Subscription_End_Date__c = system.today().addMonths(+1);
        acc.BillingStreet = 'test';
        acc.BillingCity = 'test';
        acc.billingcountryCode='SG';
        acc.Country__c = 'Singapore';
        acc.BillingPostalCode = '83737';
        acc.Account_Rule_Code__c = 'Standard';
        acc.PersonEmail = 'test@upgradecalculator.com';
        acc.CEA_Salesperson_Number__c = '85638';
        acc.PersonBirthdate = system.today();
        acc.Status__c = 'Downgraded';
        acc.Account_Previous_Status__c = 'Active';
        acc.RecordTypeId = recordTypeId;
        acc.CEA_Salesperson_Number__c = 'S458456L';
        acc.Mobile_Country__c = '65';
        insert acc;
        
        //running user
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        
        // Insert subsidiary 
        Subsidiary__c sb = PGTestDataFactory.createSubsidiary();
        Map<String,Subsidiary__c> sbMap = new Map<String,Subsidiary__c>();
        sbMap.put(sb.Id, sb);
        
        // Insert tax code 
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        // Insert Upgrade Package Lookup List
        List<Upgrade_Package_Lookup__c> listOfUPL = new List<Upgrade_Package_Lookup__c>();
        Upgrade_Package_Lookup__c upl1 = new Upgrade_Package_Lookup__c();
        upl1.Country__c = sb.Country__c;
        upl1.Name = 'Standard - SG';
        upl1.Level__c = 1;
        upl1.Upgrade_SKU__c = 'PG01P4886S';
        upl1.Renewal_SKU__c = 'abc2';
        upl1.Renewal_Type__c = 'Renewal Downgrade';
        
        listOfUPL.add(upl1);
        
        Upgrade_Package_Lookup__c upl2 = new Upgrade_Package_Lookup__c();
        upl2.Country__c = sb.Country__c;
        upl2.Name = 'Advance - SG';
        upl2.Level__c = 2;
        upl2.Upgrade_SKU__c = 'PG01P4887S';
        upl2.Renewal_SKU__c = 'abc2';
        upl2.Renewal_Type__c = 'Renewal Downgrade';
        listOfUPL.add(upl2);
        insert listOfUPL;
            
        // Insert Pricebook 
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        // Insert Product Class 
        Product_Class__c productClass = new Product_Class__c(Name = 'Subscription', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        // Insert Product
        Product2 prod1 = new Product2(Name = 'Advance', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'PG01P4887S',CurrencyIsoCode = 'SGD',Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        insert prod1;
            
        Product2 prod = new Product2(Name = 'Advance', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'PG01P4887S',CurrencyIsoCode = 'SGD',Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        insert prod;
        
        // Standard Pricebook 
        Id StdpricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> pbList = new List<PricebookEntry>();
        // Insert Custom Pricebook 
        Pricebook2 pb = new Pricebook2(Name ='PropertyGuru Pte Ltd',isActive = true,CurrencyIsoCode = 'SGD',Subsidiary__c =sb.Id);
        insert pb;
        
        // Insert Pricebook Entry
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe1;
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=pb.Id,product2id=prod.id, unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        pbList.add(pbe2);
        insert pbList;
          Item_Bundle__c  itm = new Item_Bundle__c();
            itm.Parent_Product__c = prod1.id;
        Date startDate = Date.newInstance(2020, 12, 9);
        //Test.startTest();   
        UpgradePackageCalculatorSG.getUpgradeForecast(acc.Id,pbList,10.0,prod.SKU_Code__c);
        UpgradePackageCalculatorSG.getUpgradeForecast(acc.Id);
        UpgradeForecastController.getUpgradeForecast(acc.Id);
        UpgradeForecastController.getUpgradeForecast(null);
        }
        Test.stopTest();
    }
}
@isTest 
public class BatchToUpdateFullfilmentItemsTest{
    static testMethod void testMethod1(){
        TestDataSetupBasic.insertPGAccountTrigger();
        String randomNumber = String.valueOf(Integer.valueOf((Math.random() * 100)));
        Corporate_Brand_Name__c corporateBrandName = new Corporate_Brand_Name__c();
        List<Corporate_Brand_Name__c> corporateBrandNameList = [SELECT Id FROM Corporate_Brand_Name__c];
        if (corporateBrandNameList.size() > 0) {
            corporateBrandName = corporateBrandNameList[0];
        } else {
            corporateBrandName = new Corporate_Brand_Name__c(Name = 'Test Corporate Brand Name ' + randomNumber,
                                                             Global_Customer_Segment__c = 'Advertiser');
            insert corporateBrandName;
        }
        
        Id recordTypeId = CS_utl_RecordType.getRecordTypeId(Account.getSObjectType(), 'B2B - Account');
        Account testAccount = new Account(Name = 'Test Account', Website = 'www.cloudsense.com',
                                          BillingCity = 'City', BillingCountry = 'United States', BillingCountryCode = 'US', BillingPostalCode = '10000',
                                          BillingState = 'Alabama', BillingStateCode = 'AL', BillingStreet = 'Some Street', Billing_email__c = 'some@some.com',
                                          Industry = 'Agency', Industry_Tier_2__c = 'Media Agency', Type = 'Advertiser', CurrencyIsoCode = 'EUR',
                                          Corporate_Brand_Name__c = corporateBrandName.Id, RecordTypeId = recordTypeId,Status__c = 'Active',AgentNet_ID__c = 'test');
        insert testAccount;
        
        /*method to create a test Fulfilment*/
        csdf__Fulfilment__c testFulfilment = new csdf__Fulfilment__c();
        testFulfilment.csdf__Advertiser__c = testAccount.Id;
        testFulfilment.csdf__Name__c = 'Test_' + Datetime.now();
        insert testFulfilment;
        
        cscfga__Product_Configuration__c testProdConfig = new cscfga__Product_Configuration__c();
        testProdConfig.Name = 'Test Product Configuration';
        insert testProdConfig;
        
        cscfga__Attribute__c testAttr = new cscfga__Attribute__c();
        testAttr.cscfga__Product_Configuration__c = testProdConfig.Id;
        testAttr.cscfga__Is_Line_Item__c = true;
        testAttr.Name = 'Fulfilment Item';
        insert testAttr;
        
        /*method to create a test Fulfilment item*/
        csdf__Fulfilment_Item__c testFulfilmentItem = new csdf__Fulfilment_Item__c();
        testFulfilmentItem.csdf__Fulfilment__c = testFulfilment.Id;
        testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
        testFulfilmentItem.csdf__Flight_End__c = System.now();
        testFulfilmentItem.csdf__Name__c = 'testful';
        testFulfilmentItem.csdf__Availability_Check_Total_Amount__c = 1;
        testFulfilmentItem.csdf__Quantity__c = 20;
        testFulfilmentItem.csdf__Billing_Category__c = 'CPM';
        testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
        testFulfilmentItem.csdf__Flight_End__c = System.now();
        testFulfilmentItem.csdf__Quantity__c = 10;
        testFulfilmentItem.Served_By__c = 'Non-Ad Served';
        testFulfilmentItem.Product_Configuration__c = testProdConfig.Id;
        insert testFulfilmentItem;
        
        Test.startTest();
        BatchToUpdateFullfilmentItems obj = new BatchToUpdateFullfilmentItems();
        DataBase.executeBatch(obj); 
        Test.stopTest();
    }
}
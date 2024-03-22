@isTest
public class SO_ExpirationTaskCreation_BatchTest {
    
    @isTest
    public static void TestData(){
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        
        Account testAccount = TestDataSetupSO.createAccount();
        testAccount.RecordTypeId = accRectype ;
        insert  testAccount;
        
        Contact testContact = TestDatasetupSO.createContact(testAccount);
        insert testContact;
        
        Opportunity testOpportunity = TestDataSetupSO.createOpportunity(testAccount, testContact);
        insert testOpportunity;        
        
        csmso__Sales_Order__c testSO3 = TestDatasetupSO.createSalesOrder(testAccount, testOpportunity); 
        testSO3.SO_Start_Date__c = system.today();
        testSO3.SO_End_Date__c=system.today().addDays(177);
        testSo3.Sold__c = true;

        insert testSO3;

        
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);
       // insert prodDef;
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(csmso__Sales_Order__c = testSO3.id, Name = 'test basket', cscfga__Total_Price__c = 100, Payment_Amount__c = 2, Appr_Code__c = '2', Payment_Date__c = system.today(), Payment_Reference__c = 'PayPal', Payment_Gateway__c = 'PayPal', Payment_Mode__c = 'PayPal', EcomReference__c  = 'test');
        insert basket;
        
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(cscfga__Product_Basket__c = Basket.Id, name = 'Ad-Served', cscfga__Quantity__c = 2, Start_Date__c = system.today(), cscfga__Unit_Price__c = 20, End_Date__c = system.today()+3, cscfga__Product_Family__c = 'Ad Served', cscfga__Parent_Configuration__c = null);
        insert pc1;
        
        /*List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,SOList,testAccount);
insert fulfilment;*/
        csdf__Fulfilment__c testFulfilment = new csdf__Fulfilment__c();
        testFulfilment.Sales_Order__c = testSO3.id;
        testFulfilment.csdf__status__c = 'Ready';
        testFulfilment.csdf__Advertiser__c = testAccount.id;
        testFulfilment.csdf__Name__c = testAccount.id;
        insert testFulfilment;
        
        //List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,testFulfilment,ProdConfigs);
        csdf__Fulfilment_Item__c testFulfilmentItem = new csdf__Fulfilment_Item__c();
        testFulfilmentItem.csdf__Fulfilment__c = testFulfilment.id;
        testFulfilmentItem.product_configuration__c = pc1.id;
        testFulfilmentItem.csdf__Flight_Beginning__c = DateTime.valueof(System.now()-30);
        testFulfilmentItem.csdf__Flight_End__c = DateTime.valueof(System.now()+30);
        testFulfilmentItem.csdf__Name__c = testFulfilment.id;
        testFulfilmentItem.csdf__Status__c = 'Ready';
        testFulfilmentItem.Insertion_Quantity__c = 1600;
        testFulfilmentItem.csdf__Quantity__c = 1600;
        insert testFulfilmentItem;
        
        Test.startTest();
        Database.executeBatch(new SO_ExpirationTaskCreation_Batch());
        Test.stopTest();
    }    
}
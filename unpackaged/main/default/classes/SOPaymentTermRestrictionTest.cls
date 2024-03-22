@isTest
public class SOPaymentTermRestrictionTest{
    
    @isTest
    static void runTestMethod(){
        
        
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
        
        
        
        
        
        Id idRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B').getRecordTypeId();  
        Opportunity testOpportunity = new Opportunity(Name = 'testOpportunityForSalesOrderSupportTest' + System.now().getTime(),
                                                      AccountId = testAccount.Id,
                                                      StageName = 'Prospecting',
                                                      CloseDate = System.today(),
                                                      RecordTypeId = idRecordType
                                                     );
        insert testOpportunity ;
        
        QliToOliFieldMapping__c setting = new QliToOliFieldMapping__c();
        setting.Name = 'Amount_Despite_VIP__c';
        setting.OliField__c = 'Amount_Despite_VIP__c';
        insert setting;
        
        Payment_Term__c paymentTerm = new Payment_Term__c();
        paymentTerm.Name = 'Monthly';
        paymentTerm.NS_Payment_Term_ID__c = 123456.00;
        insert paymentTerm;
        

        csmso__Sales_Order__c so = new csmso__Sales_Order__c();
        so.Advertiser_Final__c = testAccount.Id;
        so.csmso__Advertiser__c = testAccount.Id;
        so.csmso__Status__c = 'In Progress';
        so.csmso__Opportunity__c = testOpportunity.Id;
        so.Primary_Sales_Order__c = true;
       // so.NetSuite_Payment_Term__c = paymentTerm.Id;
        insert so;
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        prodBasket.Name = 'Basket test';
        prodBasket.Appr_Code__c = '2';
        prodBasket.Payment_Amount__c = 2;
        prodBasket.cscfga__Total_Price__c = 100;
        prodBasket.Payment_Date__c = System.today();
        prodBasket.Payment_Reference__c = 'PayPal';
        prodBasket.Payment_Gateway__c = 'PayPal';
        prodBasket.Payment_Mode__c = 'PayPal';
        prodBasket.EcomReference__c = 'test';
        prodbasket.csmso__Sales_Order__c = so.id;
        insert prodBasket;
        so.NetSuite_Payment_Term__c = paymentTerm.Id;
        try{
        update so;
        }
        catch (exception e){
            
        }
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.cscfga__Product_Family__c ='MPD Subscriptions';
       
        insert prodCOnfig;
        update so;
    }
}
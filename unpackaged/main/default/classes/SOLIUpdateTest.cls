@IsTest
public class SOLIUpdateTest {
    
    @IsTest
    public static void logictest() {
        PGTestDataFactory_v2.initSetupData();
        Account acc = new Account(name = 'test', country__c = 'Singapore',AgentKey__c='SG1212',BillingPostalCode='12345');
        insert acc;
        Opportunity opp = new Opportunity(AccountId = acc.id, Name = 'Opp test1',
                                          CloseDate = System.today() +10, StageName = 'Prospecting',BasketId__c ='1223');
        
        Insert opp;
        csmso__Sales_Order__c testSO = TestDatasetupSO.createSalesOrder(acc, Opp);
    insert testSO;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Name = 'test basket', cscfga__Total_Price__c = 100, 
                                                                         Payment_Amount__c = 2, Appr_Code__c = '2', Payment_Date__c = system.today(),
                                                                         Payment_Reference__c = 'Paypal', Payment_Gateway__c = 'Adyen', 
                                                                         Payment_Mode__c = 'PayPal', EcomReference__c  = 'test',
                                                                         csmso__Sales_Order__c=testSO.id
                                                                        );
        insert basket;
        Tax_Code__c tax = new Tax_Code__c(Name = 'test', Active__c = true, NS_Tax_Internal_ID__c = '20', Tax_Rate__c = 20);
        insert tax;
        
        cspmb__Price_Item__c  priceItem = new cspmb__Price_Item__c (name = 'test', Tax_Code__c = tax.Id,Product_Category__c  = 'Awards');
        insert priceItem;
        
        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(name = 'Ad Credits', cscfga__Quantity__c = 2, Start_Date__c = system.today(), cscfga__Unit_Price__c = 20, End_Date__c = system.today()+3, cscfga__Product_Family__c = 'Ad Credits', cscfga__Product_Basket__c = basket.Id);
        insert pc;
        cscfga__Attribute__c attr1 = new cscfga__Attribute__c (name = 'Offering', cscfga__Is_Line_Item__c = true, cscfga__Value__c = string.valueOf(priceItem.Id), cscfga__Price__c = 10, cscfga__List_Price__c = 20, cscfga__Product_Configuration__c = pc.Id);
        insert attr1;
    }
}
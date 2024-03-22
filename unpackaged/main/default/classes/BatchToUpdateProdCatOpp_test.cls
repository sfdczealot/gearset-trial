@isTest 
public class BatchToUpdateProdCatOpp_test {
    @testSetup
    public static void DataSetup(){
        Pricebook2 pricebookPGSG = new Pricebook2();
        pricebookPGSG.Name = 'PG SG';
        pricebookPGSG.IsActive = true; 
        pricebookPGSG.CurrencyIsoCode = 'SGD';
        insert pricebookPGSG;
        Account acc = TestDataSetupBasic.createAccount();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        insert acc;
        Contact con = TestDataSetupBasic.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        opp.Pricebook2Id = pricebookPGSG.Id;
        insert opp;
        csmso__Sales_Order__c so =TestDataSetupSO.createSalesOrder(acc,opp);
        insert so;
        opp.Primary_Sales_Order__c = so.id;
        update Opp;
        Product2 product2Awards = new Product2();
        product2Awards.Name = 'product2Name';
        product2Awards.CurrencyIsoCode = 'SGD';
        //product2sToInsert.add(product2Awards);
        
        insert product2Awards;
       
        Id stdPriceBook = Test.getStandardPricebookId();
        PricebookEntry pricebookEntryStandard = new PricebookEntry();
        pricebookEntryStandard.UnitPrice = 20;
        pricebookEntryStandard.IsActive = true;
        pricebookEntryStandard.CurrencyIsoCode = 'SGD';
        pricebookEntryStandard.Product2Id = product2Awards.Id;
        pricebookEntryStandard.Pricebook2Id = stdPriceBook;
        insert pricebookEntryStandard;
        
        PricebookEntry pricebookEntryPGSG = new PricebookEntry();
        pricebookEntryPGSG.UnitPrice = 40;
        pricebookEntryPGSG.IsActive = true;
        pricebookEntryPGSG.CurrencyIsoCode = 'SGD';
        pricebookEntryPGSG.Product2Id = product2Awards.Id;
        pricebookEntryPGSG.Pricebook2Id = pricebookPGSG.Id;
        insert pricebookEntryPGSG;

        OpportunityLineItem oli = new OpportunityLineItem(Product_Configuration__c='wertyui'+'',Product_category__c='Discretionary',pricebookentryid=pricebookEntryPGSG.id,product2id=product2Awards.id,Opportunityid=Opp.id);
        insert oli;

        
    }
    @isTest
    public static void test1(){
        Database.executeBatch(new BatchToUpdateProdCatOpp());
    }
}
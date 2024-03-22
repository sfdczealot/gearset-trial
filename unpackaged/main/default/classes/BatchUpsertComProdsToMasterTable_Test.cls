@isTest
public class BatchUpsertComProdsToMasterTable_Test{
    
    public static testmethod void unitTest(){
        
        list<cspmb__Price_Item__c> comProdsList = new list<cspmb__Price_Item__c>();
        
        Tax_Code__c taxCode = new Tax_Code__c();
        taxCode.Name = 'AJP';
        taxCode.Tax_Rate__c = 6.6;
        taxCode.Country__c = 'Malaysia';
        taxCode.Active__c = true;
        taxCode.Description__c = 'Test Description';
        taxCode.NS_Tax_Internal_ID__c = '4904';
        Insert taxCode;
        
        cspmb__Price_Item__c comProd = new cspmb__Price_Item__c();
        comprod.Name = 'Test prod';
        comprod.cspmb__Is_Active__c = true;
        comprod.Bundle_Only__c = false;
        comprod.SKU__c = 'CGhjhgGHFDGFD';
        comprod.Income_Account__c = '1374';
        //comprod.Deferred_Revenue_Account__c = '1427';
        comprod.Tax_Code__c = taxCode.Id;
        comprod.Product_Category__c = 'Developer Listings';
        comprod.Product_Class__c = 'Developer Listings : Listings';
        comprod.Product_Subclass__c = '773';
        comprod.cspmb__Effective_Start_Date__c = System.today();
        comprod.cspmb__Effective_End_Date__c = System.today().adddays(10);
        comprod.cspmb__One_Off_Charge__c = 500.05;
        comProdsList.add(comprod);
        
        Insert comProdsList;
        
        Test.startTest();
        BatchUpsertComProdsToMasterTable objBatch = new BatchUpsertComProdsToMasterTable();
        Database.executeBatch(objBatch);
        objBatch.execute(null, comProdsList);
        Test.stopTest();        
    }
}
@isTest
public class BatchUpsertAddOnAssToMasterTable_Test {
    public static testmethod void unitTest(){
        
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> addOnAssList = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        
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
        comprod.Tax_Code__c = taxCode.Id;
        comprod.Product_Category__c = 'Developer Listings';
        comprod.Product_Class__c = 'Developer Listings : Listings';
        comprod.Product_Subclass__c = '773';
        comprod.cspmb__Effective_Start_Date__c = System.today();
        comprod.cspmb__Effective_End_Date__c = System.today().adddays(10);
        comprod.cspmb__One_Off_Charge__c = 500.05;
        Insert comprod;
        
        cspmb__Add_On_Price_Item__c addon1 = new cspmb__Add_On_Price_Item__c();
        addon1.Name = 'Test Name';
        addon1.Income_Account__c = '636';
        addon1.cspmb__Contract_Term__c = '12';
        addon1.cspmb__Product_Definition_Name__c = 	'Sample Product';
        addon1.cspmb__Effective_Start_Date__c = System.today();
        addon1.cspmb__Effective_End_Date__c = System.today().adddays(365);
        addon1.cspmb__Is_Active__c = true;
        addon1.cspmb__One_Off_Charge__c = 256;
        addon1.Tax_Code__c = taxCode.Id;
        Insert addon1;
        
        cspmb__Price_Item_Add_On_Price_Item_Association__c addOnAss1 = new cspmb__Price_Item_Add_On_Price_Item_Association__c();
        addOnAss1.cspmb__Add_On_Price_Item__c = addon1.Id;
        addOnAss1.cspmb__Price_Item__c = comprod.Id;
        addOnAss1.cspmb__Min__c = 1;
        addOnAss1.cspmb__Max__c = 2;
        addOnAss1.cspmb__One_Off_Charge__c = 250;
        addOnAss1.cspmb__Overrides_Add_On_Charges__c = true;
        addOnAss1.cspmb__effective_start_date__c = System.today();
        addOnAss1.cspmb__effective_end_date__c = System.today().addDays(365);
        addOnAssList.add(addOnAss1);
        
        Insert addOnAssList;
        
        Test.startTest();
        BatchUpsertAddOnAssToMasterTable objBatch = new BatchUpsertAddOnAssToMasterTable();
        Database.executeBatch(objBatch);
        objBatch.execute(null, addOnAssList);
        Test.stopTest();        
    }
    
}
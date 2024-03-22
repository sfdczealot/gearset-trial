@isTest
public class BatchUpsertAddOnToMasterTable_Test {
    public static testmethod void unitTest(){
        
        List<cspmb__Add_On_Price_Item__c> addOnList = new List<cspmb__Add_On_Price_Item__c>();
        
        Tax_Code__c taxCode = new Tax_Code__c();
        taxCode.Name = 'AJP';
        taxCode.Tax_Rate__c = 6.6;
        taxCode.Country__c = 'Malaysia';
        taxCode.Active__c = true;
        taxCode.Description__c = 'Test Description';
        taxCode.NS_Tax_Internal_ID__c = '4904';
        Insert taxCode;
        
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
        addOnList.add(addon1);
        
        Insert addOnList;
        
        Test.startTest();
        BatchUpsertAddOnToMasterTable objBatch = new BatchUpsertAddOnToMasterTable();
        Database.executeBatch(objBatch);
        objBatch.execute(null, addOnList);
        Test.stopTest();
        
        
    }
}
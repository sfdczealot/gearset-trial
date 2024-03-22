global class BatchUpsertAddOnToMasterTable implements Database.Batchable<sObject>, Schedulable{
    
    public void execute(SchedulableContext sc){  
        DataBase.executeBatch(new BatchUpsertAddOnToMasterTable());  
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String thisday = String.valueOf(DateTime.now()).replace(' ', 'T');
        String beforeday = String.valueOf(DateTime.now().adddays(Integer.valueOf(Label.Fetch_Records_of_Days))).replace(' ', 'T');
        thisday = thisday + 'Z';
        beforeday = beforeday + 'Z';        
        String query = Label.Fetch_Add_On_Query;
        query = query.replace('DateFrom', beforeday);
        query = query.replace('today', thisday);
        
        System.debug('query** '+query);
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<cspmb__Add_On_Price_Item__c>scope){
        
        Set<Id> aoPIds = new Set<Id>();
        for(cspmb__Add_On_Price_Item__c aoPI : scope){
            aoPIds.add(aoPI.Id);
        }
        
        Map<String, Product_Master_Table__c> ActualRecToPmRecMap = new Map<String, Product_Master_Table__c>();
        for(Product_Master_Table__c pmt : [Select id, Name, Actual_Record_Id__c, Product_Name__c, Active__c, Bundle_Only__c,
                                               SKU_Number__c, Income_Account_Code__c, Deferred_Account_Code__c, Tax_Code__c, Product_Definition_Name__c,
                                               Product_Class__c, Effective_start_date__c, Product_Stored_In__c,
                                               Effective_end_date__c, Product_List_Price__c, Product_Subclass__c, Product_Catagory__c, Description__c
                                               from Product_Master_Table__c where Actual_Record_Id__c =: aoPIds]){
            ActualRecToPmRecMap.put(pmt.Actual_Record_Id__c, pmt);
        }
        
        Map<String,String> incomeAcc = getPicklistvalue('cspmb__Add_On_Price_Item__c', 'Income_Account__c');
        Map<String,String> deferredAcc = getPicklistvalue('cspmb__Add_On_Price_Item__c', 'Deferred_Revenue_Account__c');
        Map<String,String> prodCategory = getPicklistvalue('cspmb__Add_On_Price_Item__c', 'Product_Category__c');
        Map<String,String> prodClass = getPicklistvalue('cspmb__Add_On_Price_Item__c', 'Product_Class__c');
        Map<String,String> prodSubClass = getPicklistvalue('cspmb__Add_On_Price_Item__c', 'Product_Subclass__c');
        Map<String,String> contractTerm = getPicklistvalue('cspmb__Add_On_Price_Item__c', 'cspmb__Contract_Term__c');
        
        List<Product_Master_Table__c> masterRecordsList = new List<Product_Master_Table__c>();
        for (cspmb__Add_On_Price_Item__c ao : scope)
        {
            Product_Master_Table__c masterRecord = new Product_Master_Table__c();
            if(ActualRecToPmRecMap.containskey(ao.Id))
                masterRecord.Id = ActualRecToPmRecMap.get(ao.Id).Id;
            masterRecord.Actual_Record_Id__c = ao.Id;
            masterRecord.Product_Name__c = ao.Name;
            masterRecord.Active__c = ao.cspmb__Is_Active__c;
            masterRecord.Bundle_Only__c = ao.Bundle_Only__c;
            masterRecord.Income_Account_Code__c = incomeAcc.get(ao.Income_Account__c);
            masterRecord.Deferred_Account_Code__c = deferredAcc.get(ao.Deferred_Revenue_Account__c);
            masterRecord.Tax_Code__c = ao.Tax_Code__c;
            masterRecord.Product_Catagory__c = prodCategory.get(ao.Product_Category__c);
            masterRecord.Product_Class__c = prodClass.get(ao.Product_Class__c);
            masterRecord.Product_Subclass__c = prodSubClass.get(ao.Product_Subclass__c);
            masterRecord.Effective_start_date__c = ao.cspmb__Effective_Start_Date__c;
            masterRecord.Effective_end_date__c = ao.cspmb__Effective_End_Date__c;
            masterRecord.Product_List_Price__c = ao.cspmb__One_Off_Charge__c;
            masterRecord.Product_Definition_Name__c = ao.cspmb__Product_Definition_Name__c;
            masterRecord.Product_Stored_In__c = 'Add On';
            masterRecord.Description__c = ao.cspmb__Add_On_Price_Item_Description__c;
            masterRecord.Contract_Term__c = contractTerm.get(ao.cspmb__Contract_Term__c);
            masterRecord.CurrencyIsoCode = ao.CurrencyIsoCode;
            masterRecord.Effective_Today__c = ao.Effective_Today__c;            
            masterRecordsList.add(masterRecord);
        }
        if(!masterRecordsList.isEmpty())
            Upsert masterRecordsList;
    }
    global void finish(Database.BatchableContext BC){
    }
    
    public Map<String, String> getPicklistvalue(String objectName, String fieldName){
        
        Map<String, String> picklistValuesMaps = new Map<String, String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            picklistValuesMaps.put(pickListVal.getValue(), pickListVal.getLabel());
        }
        return picklistValuesMaps;
    }
}
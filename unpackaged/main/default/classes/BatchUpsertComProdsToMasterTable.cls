global class BatchUpsertComProdsToMasterTable implements Database.Batchable<sObject>, Schedulable {
    
    public void execute(SchedulableContext sc){  
        DataBase.executeBatch(new BatchUpsertComProdsToMasterTable());  
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String thisday = String.valueOf(DateTime.now()).replace(' ', 'T');
        String beforeday = String.valueOf(DateTime.now().adddays(Integer.valueOf(Label.Fetch_Records_of_Days))).replace(' ', 'T');
        thisday = thisday + 'Z';
        beforeday = beforeday + 'Z';        
        String query = Label.Fetch_Commercial_Products_Query;
        query = query.replace('DateFrom', beforeday);
        query = query.replace('today', thisday);
        
        System.debug('query** '+query);
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<cspmb__Price_Item__c>scope){
        
        Set<Id> piIds = new Set<Id>();
        for(cspmb__Price_Item__c pi : scope){
            piIds.add(pi.Id);
        }
        
        Map<String, Product_Master_Table__c> ActualRecToPmRecMap = new Map<String, Product_Master_Table__c>();
        for(Product_Master_Table__c pmt : [Select id, Name, Actual_Record_Id__c, Product_Name__c, Active__c, Bundle_Only__c,
                                               SKU_Number__c, Income_Account_Code__c, Deferred_Account_Code__c, Tax_Code__c, Product_Definition_Name__c,
                                               Product_Class__c, Effective_start_date__c, Product_Stored_In__c,
                                               Effective_end_date__c, Product_List_Price__c, Product_Subclass__c, Product_Catagory__c, Description__c
                                               from Product_Master_Table__c where Actual_Record_Id__c =: piIds]){
            ActualRecToPmRecMap.put(pmt.Actual_Record_Id__c, pmt);
        }
        
        Map<String,String> incomeAcc = getPicklistvalue('cspmb__Price_Item__c', 'Income_Account__c');
        Map<String,String> deferredAcc = getPicklistvalue('cspmb__Price_Item__c', 'Deferred_Revenue_Account__c');
        Map<String,String> prodCategory = getPicklistvalue('cspmb__Price_Item__c', 'Product_Category__c');
        Map<String,String> prodClass = getPicklistvalue('cspmb__Price_Item__c', 'Product_Class__c');
        Map<String,String> prodSubClass = getPicklistvalue('cspmb__Price_Item__c', 'Product_Subclass__c');
        Map<String,String> role = getPicklistvalue('cspmb__Price_Item__c', 'cspmb__Role__c');
        Map<String,String> durationTerm = getPicklistvalue('cspmb__Price_Item__c', 'Duration_Term__c');
        Map<String,String> contractTerm = getPicklistvalue('cspmb__Price_Item__c', 'cspmb__Contract_Term__c');
        
        List<Product_Master_Table__c> masterRecordsList = new List<Product_Master_Table__c>();
        for (cspmb__Price_Item__c cp : scope)
        {
            Product_Master_Table__c masterRecord = new Product_Master_Table__c();
            if(ActualRecToPmRecMap.containskey(cp.Id))
                masterRecord.Id = ActualRecToPmRecMap.get(cp.Id).Id;
            masterRecord.Actual_Record_Id__c = cp.Id;
            masterRecord.Product_Name__c = cp.Name;
            masterRecord.Active__c = cp.cspmb__Is_Active__c;
            masterRecord.Bundle_Only__c = cp.Bundle_Only__c;
            masterRecord.SKU_Number__c = cp.SKU__c;
            masterRecord.Income_Account_Code__c = incomeAcc.get(cp.Income_Account__c);
            masterRecord.Deferred_Account_Code__c = deferredAcc.get(cp.Deferred_Revenue_Account__c);
            masterRecord.Tax_Code__c = cp.Tax_Code__c;
            masterRecord.Product_Catagory__c = prodCategory.get(cp.Product_Category__c);
            masterRecord.Product_Class__c = prodClass.get(cp.Product_Class__c);
            masterRecord.Product_Subclass__c = prodSubClass.get(cp.Product_Subclass__c);
            masterRecord.Effective_start_date__c = cp.cspmb__Effective_Start_Date__c;
            masterRecord.Effective_end_date__c = cp.cspmb__Effective_End_Date__c;
            masterRecord.Product_List_Price__c = cp.cspmb__One_Off_Charge__c;
            masterRecord.Product_Definition_Name__c = cp.cspmb__Product_Definition_Name__c;
            masterRecord.Product_Stored_In__c = 'Commercial Product';
            masterRecord.Description__c = cp.Line_Description__c;
            masterRecord.Commercial_Product_Role__c = role.get(cp.cspmb__Role__c);
            masterRecord.Duration__c = cp.Duration__c;
            masterRecord.Duration_Term__c = durationTerm.get(cp.Duration_Term__c);
            masterRecord.Contract_Term__c = contractTerm.get(cp.cspmb__Contract_Term__c);
            masterRecord.CurrencyIsoCode = cp.CurrencyIsoCode;
            masterRecord.Amortisation_Duration__c = cp.Amortisation_Duration__c;
            masterRecord.Amortisation_Percent__c = cp.Amortisation_Percent__c;
            masterRecord.Additional_Revenue_Split__c = cp.Additional_Revenue_Split__c;
            if(ActualRecToPmRecMap.containskey(cp.cspmb__Master_Price_item__c))            
                masterRecord.Parent_Product_Master__c = ActualRecToPmRecMap.get(cp.cspmb__Master_Price_item__c).Id;            
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
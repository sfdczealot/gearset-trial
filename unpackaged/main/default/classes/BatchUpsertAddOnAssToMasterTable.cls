global class BatchUpsertAddOnAssToMasterTable implements Database.Batchable<sObject>, Schedulable{
public void execute(SchedulableContext sc){  
        DataBase.executeBatch(new BatchUpsertAddOnAssToMasterTable());  
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String thisday = String.valueOf(DateTime.now()).replace(' ', 'T');
        String beforeday = String.valueOf(DateTime.now().adddays(Integer.valueOf(Label.Fetch_Records_of_Days))).replace(' ', 'T');
        thisday = thisday + 'Z';
        beforeday = beforeday + 'Z';        
        String query = Label.Fetch_Add_On_Association_Query;
        query = query.replace('DateFrom', beforeday);
        query = query.replace('today', thisday);
        
        System.debug('query** '+query);
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<cspmb__Price_Item_Add_On_Price_Item_Association__c>scope){
        Set<Id> addOnAssociations = new Set<Id>();
        Set<String> ComProds = new Set<String>();
        Set<String> AddOns = new Set<String>();
        for(cspmb__Price_Item_Add_On_Price_Item_Association__c aoa : scope){
            addOnAssociations.add(aoa.Id);
            ComProds.add(aoa.cspmb__Price_Item__c);
            AddOns.add(aoa.cspmb__Add_On_Price_Item__c);
        }
        
        Map<String, Product_Master_Table__c> ActualRecToPmRecMap = new Map<String, Product_Master_Table__c>();
        for(Product_Master_Table__c pmt : [Select id, Name, Actual_Record_Id__c, Product_Name__c, Active__c, Bundle_Only__c,
                                               SKU_Number__c, Income_Account_Code__c, Deferred_Account_Code__c, Tax_Code__c, Product_Definition_Name__c,
                                               Product_Class__c, Effective_start_date__c, Product_Stored_In__c,
                                               Effective_end_date__c, Product_List_Price__c, Product_Subclass__c, Product_Catagory__c, Description__c
                                               from Product_Master_Table__c where Actual_Record_Id__c =: addOnAssociations
                                               OR Actual_Record_Id__c =: ComProds
                                               OR Actual_Record_Id__c =: AddOns]){
                                                   ActualRecToPmRecMap.put(pmt.Actual_Record_Id__c, pmt);
                                               }
        List<Product_Master_Table__c> masterRecordsList = new List<Product_Master_Table__c>();
        for (cspmb__Price_Item_Add_On_Price_Item_Association__c aoa : scope)
        {
            Product_Master_Table__c masterRecord = new Product_Master_Table__c();
            if(ActualRecToPmRecMap.containskey(aoa.Id))
                masterRecord.Id = ActualRecToPmRecMap.get(aoa.Id).Id;
            masterRecord.Actual_Record_Id__c = aoa.Id;
            if(ActualRecToPmRecMap.containskey(aoa.cspmb__Price_Item__c))
                masterRecord.Commercial_Product__c = ActualRecToPmRecMap.get(aoa.cspmb__Price_Item__c).Id;
            if(ActualRecToPmRecMap.containskey(aoa.cspmb__Add_On_Price_Item__c))
                masterRecord.Add_On__c = ActualRecToPmRecMap.get(aoa.cspmb__Add_On_Price_Item__c).Id;
            masterRecord.Product_List_Price__c = aoa.cspmb__One_Off_Charge__c;
            masterRecord.Product_Stored_In__c = 'Add on Association';
            masterRecord.Product_Name__c = aoa.Name;
            masterRecord.Min__c = aoa.cspmb__Min__c;
            masterRecord.Max__c = aoa.cspmb__Max__c;
            masterRecord.Sequence__c = aoa.cspmb__Sequence__c;
            masterRecord.Overrides_Add_On_Charges__c = aoa.cspmb__Overrides_Add_On_Charges__c;
            masterRecordsList.add(masterRecord);
        }
        if(!masterRecordsList.isEmpty())
            Upsert masterRecordsList;
    }
     global void finish(Database.BatchableContext BC){
    }
}
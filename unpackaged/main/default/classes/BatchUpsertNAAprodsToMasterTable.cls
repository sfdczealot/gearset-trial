global class BatchUpsertNAAprodsToMasterTable implements Database.Batchable<sObject>, Schedulable{
    
    public void execute(SchedulableContext sc){  
        DataBase.executeBatch(new BatchUpsertNAAprodsToMasterTable());  
    }
    
    global Database.QueryLocator start( Database.BatchableContext BC ) {
        String thisday = String.valueOf(DateTime.now()).replace(' ', 'T');
        String beforeday = String.valueOf(DateTime.now().adddays(Integer.valueOf(Label.Fetch_Records_of_Days))).replace(' ', 'T');
        thisday = thisday + 'Z';
        beforeday = beforeday + 'Z';
        String query = Label.Fetch_NAA_Products_Query;
        query = query.replace('DateFrom', beforeday);
        query = query.replace('today', thisday);
        
        System.debug('query** '+query);
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<csmso__Node_Advert_Assignment__c>scope){
        
        List<Product_Master_Table__c> masterRecordsList = new List<Product_Master_Table__c>();
        Map<String, csmso__Rate_Card_Item_Price__c> naaToRateCardItemMap = new Map<String, csmso__Rate_Card_Item_Price__c>();
        Set<Id> naaIds = new Set<Id>();
        if(!scope.isEmpty()){
            for(csmso__Node_Advert_Assignment__c naa : scope){
                naaIds.add(naa.Id);
            }
        }
            
        List<csmso__Rate_Card_Item_Price__c> RateCardItemList = [Select Id, Name, csmso__Price_Per_Unit__c, Income_Account__c, Deferred_Revenue_Account__c, csmso__Rate_Card__r.csmso__From_Date__c,
                                                                 Tax_Code__c, Product_Category__c, Product_Class__c, Product_Subclass__c, csmso__Advert_Assignment__c, csmso__Rate_Card__r.csmso__To_Date__c
                                                                 from csmso__Rate_Card_Item_Price__c where csmso__Advert_Assignment__c =: naaIds];
        System.debug('RateCardItemList*** '+RateCardItemList);
        If(!RateCardItemList.isEmpty()){
            for(csmso__Rate_Card_Item_Price__c rcItem : RateCardItemList){
                naaToRateCardItemMap.put(rcItem.csmso__Advert_Assignment__c, rcItem);
            }
        }
        
        Map<String, Product_Master_Table__c> ActualRecToPmRecMap = new Map<String, Product_Master_Table__c>();
        for(Product_Master_Table__c pmt : [Select id, Name, Actual_Record_Id__c, Product_Name__c, Active__c, Bundle_Only__c,
                                               SKU_Number__c, Income_Account_Code__c, Deferred_Account_Code__c, Tax_Code__c,
                                               Product_Class__c, Effective_start_date__c, Product_Stored_In__c, Product_Definition_Name__c,
                                               Effective_end_date__c, Product_List_Price__c, Product_Subclass__c, Product_Catagory__c
                                               from Product_Master_Table__c where Actual_Record_Id__c =: naaIds]){
            ActualRecToPmRecMap.put(pmt.Actual_Record_Id__c, pmt);
        }
        Map<String,String> incomeAcc = getPicklistvalue('csmso__Rate_Card_Item_Price__c', 'Income_Account__c');
        Map<String,String> deferredAcc = getPicklistvalue('csmso__Rate_Card_Item_Price__c', 'Deferred_Revenue_Account__c');
        Map<String,String> prodCategory = getPicklistvalue('csmso__Rate_Card_Item_Price__c', 'Product_Category__c');
        Map<String,String> prodClass = getPicklistvalue('csmso__Rate_Card_Item_Price__c', 'Product_Class__c');
        Map<String,String> prodSubClass = getPicklistvalue('csmso__Rate_Card_Item_Price__c', 'Product_Subclass__c');
        Map<String,String> durationTerm = getPicklistvalue('csmso__Node_Advert_Assignment__c', 'Duration_Term__c');
        
        for(csmso__Node_Advert_Assignment__c na : scope){
            Product_Master_Table__c masterRecord = new Product_Master_Table__c();
            if(ActualRecToPmRecMap.containskey(na.Id))
                masterRecord.Id = ActualRecToPmRecMap.get(na.Id).Id;
            masterRecord.Actual_Record_Id__c = na.Id;
            masterRecord.Product_Name__c = na.Product_Name__c;
            masterRecord.Bundle_Only__c = na.Bundle_Only__c;
            masterRecord.Product_Stored_In__c = 'Node Advert Assignment';
            masterRecord.Description__c = na.Product_Info__c;
            masterRecord.Rev_Accrual_GL_Code__c = na.Rev_Accrual_GL_Code__c;
            masterRecord.Product_Definition_Name__c = na.Served_by__c;
            masterRecord.Duration__c = na.Duration__c;
            masterRecord.Duration_Term__c = durationTerm.get(na.Duration_Term__c);
            masterRecord.CurrencyIsoCode = na.CurrencyIsoCode;
            masterRecord.SOV__c = na.SOV__c;
            masterRecord.Starting_Day__c = na.Starting_Day__c;
            if(naaToRateCardItemMap.containskey(na.Id) && naaToRateCardItemMap.get(na.Id) != null){
                masterRecord.Income_Account_Code__c = incomeAcc.get(naaToRateCardItemMap.get(na.Id).Income_Account__c);
                masterRecord.Deferred_Account_Code__c = deferredAcc.get(naaToRateCardItemMap.get(na.Id).Deferred_Revenue_Account__c);
                masterRecord.Tax_Code__c = naaToRateCardItemMap.get(na.Id).Tax_Code__c;
                masterRecord.Effective_end_date__c = naaToRateCardItemMap.get(na.Id).csmso__Rate_Card__r.csmso__To_Date__c;
                masterRecord.Effective_start_date__c = naaToRateCardItemMap.get(na.Id).csmso__Rate_Card__r.csmso__From_Date__c;
                masterRecord.Product_Catagory__c = prodCategory.get(naaToRateCardItemMap.get(na.Id).Product_Category__c);
                masterRecord.Product_Class__c = prodClass.get(naaToRateCardItemMap.get(na.Id).Product_Class__c);
                masterRecord.Product_Subclass__c = prodSubClass.get(naaToRateCardItemMap.get(na.Id).Product_Subclass__c);
                masterRecord.Product_List_Price__c = naaToRateCardItemMap.get(na.Id).csmso__Price_Per_Unit__c;
            }                        
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
        for( Schema.PicklistEntry pickListVal : ple){
            picklistValuesMaps.put(pickListVal.getValue(), pickListVal.getLabel());
        } 
        return picklistValuesMaps;
    }
}
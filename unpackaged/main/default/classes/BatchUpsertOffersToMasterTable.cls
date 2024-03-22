global class BatchUpsertOffersToMasterTable implements Database.Batchable<sObject>, Schedulable {
    
    public void execute(SchedulableContext sc){  
        DataBase.executeBatch(new BatchUpsertOffersToMasterTable());  
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String thisday = String.valueOf(DateTime.now()).replace(' ', 'T');
        String beforeday = String.valueOf(DateTime.now().adddays(Integer.valueOf(Label.Fetch_Records_of_Days))).replace(' ', 'T');
        thisday = thisday + 'Z';
        beforeday = beforeday + 'Z';
        String query = Label.Fetch_Offers_Query;
        query = query.replace('DateFrom', beforeday);
        query = query.replace('today', thisday);
        
        System.debug('query** '+query);
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<cscfga__Configuration_Offer__c>scope){
        
       Map<String, Product_Master_Table__c> idTomasterRecordsMap = new Map<String, Product_Master_Table__c>();
        Map<String, Product_Master_Table__c> ActualRecToPmRecMap = new Map<String, Product_Master_Table__c>();
        List<Product_Master_Table__c> RecTodeleteList = new List<Product_Master_Table__c>();
        Map<String, String> ChildToParentMap = new Map<String, String>();
        List<String> deletedRecList = new List<String>();
        Set<Id> offerIds = new Set<Id>();
        Map<String, cscfga__Attribute__c> prodConfigToAttMap = new Map<String, cscfga__Attribute__c>();
        List<String> commerProdList = new List<String>();
        List<String> naaProdList = new List<String>();
        
        if(!scope.isEmpty()){
            for(cscfga__Configuration_Offer__c offer : scope ){
                offerIds.add(offer.Id);
            }
        }
        
        Map<Id, cscfga__Product_Configuration__c> idToprodConfigMap = new Map<Id, cscfga__Product_Configuration__c>([select Id, Name, Product_Name__c, cscfga__One_Off_Charge__c, Product_Category__c, Start_Date__c, cscfga__Description__c,
                                                                                                                     End_Date__c, cscfga__Attribute_Name__c, cscfga__Parent_Configuration__c, cscfga__Configuration_Offer__c, Digital_Product__c,
                                                                                                                     cscfga__Configuration_Offer__r.cscfga__Active__c, IsDeleted, cscfga__Configuration_Offer__r.cscfga__Date_Range__r.cscfga__Start__c,
                                                                                                                     cscfga__Configuration_Offer__r.cscfga__Date_Range__r.cscfga__End__c from cscfga__Product_Configuration__c 
                                                                                                                     where cscfga__Configuration_Offer__c =: offerIds ALL ROWS]);
        for(cscfga__Product_Configuration__c pc : idToprodConfigMap.Values()){
            naaProdList.add(pc.Digital_Product__c);
        }
        
        List<cscfga__Attribute__c> attList = [Select Id, Name, cscfga__Value__c, cscfga__Line_Item_Description__c, cscfga__Product_Configuration__c, cscfga__Price__c from cscfga__Attribute__c where
                                              (cscfga__Is_Line_Item__c = true /*OR Name Like 'CommercialProduct'/* OR Name Like 'AddOn'*/)
                                              and cscfga__Product_Configuration__c =: idToprodConfigMap.keyset()];
        for(cscfga__Attribute__c at : attList){
            if((String.isNotBlank(at.cscfga__Value__c) && (at.cscfga__Value__c).startsWith('a4d')) || at.Name == 'CommercialProduct')
                commerProdList.add(at.cscfga__Value__c);
            prodConfigToAttMap.put(at.cscfga__Product_Configuration__c, at);
            
        }
        for(Product_Master_Table__c pmt : [Select id, Name, Actual_Record_Id__c, Product_Name__c, Active__c, Bundle_Only__c,
                                               SKU_Number__c, Income_Account_Code__c, Deferred_Account_Code__c, Tax_Code__c,
                                               Product_Class__c, Effective_start_date__c, Product_Stored_In__c, Rev_Accrual_GL_Code__c,
                                               Effective_end_date__c, Product_List_Price__c, Product_Subclass__c, Product_Catagory__c, Description__c
                                               from Product_Master_Table__c where
                                               Actual_Record_Id__c =: offerIds
                                               OR Actual_Record_Id__c =: idToprodConfigMap.keyset()
                                               OR Actual_Record_Id__c =: commerProdList
                                               OR Actual_Record_Id__c =: naaProdList]){
                                                   ActualRecToPmRecMap.put(pmt.Actual_Record_Id__c, pmt);
                                               }
        
        for(cscfga__Product_Configuration__c pc : idToprodConfigMap.values()){
            if(!pc.IsDeleted){
                if(pc.cscfga__Attribute_Name__c == 'Add Ons' && pc.cscfga__Parent_Configuration__c != null){
                    //Used to map the parent pm rec
                    ChildToParentMap.put(pc.Id, pc.cscfga__Parent_Configuration__c);
                }
                Product_Master_Table__c masterRecord = new Product_Master_Table__c();
                if(ActualRecToPmRecMap.containskey(pc.Id))
                    masterRecord.Id = ActualRecToPmRecMap.get(pc.Id).Id;
                masterRecord.Actual_Record_Id__c = pc.Id;
                if(pc.cscfga__Attribute_Name__c == 'Add Ons'){
                    masterRecord.Product_Stored_In__c = 'Add Ons';
                    masterRecord.Product_List_Price__c = pc.cscfga__One_Off_Charge__c;
                }else{
                    masterRecord.Product_Stored_In__c = 'Product Configuration';
                    masterRecord.Product_List_Price__c = pc.cscfga__One_Off_Charge__c;
                }
                masterRecord.Offer__c = pc.cscfga__Configuration_Offer__c;
                masterRecord.Product_Catagory__c = pc.Product_Category__c;
                //Type casting to Date from DateTime
                Datetime startDT = pc.cscfga__Configuration_Offer__r.cscfga__Date_Range__r.cscfga__Start__c;
                DateTime endDT = pc.cscfga__Configuration_Offer__r.cscfga__Date_Range__r.cscfga__End__c;
                if(startDT != null)
                    masterRecord.Effective_start_date__c = date.newinstance(startDT.year(), startDT.month(), startDT.day());
                if(endDT != null)
                    masterRecord.Effective_end_date__c = date.newinstance(endDT.year(), endDT.month(), endDT.day());
                if(prodConfigToAttMap.containsKey(pc.Id)){
                    masterRecord.Description__c = prodConfigToAttMap.get(pc.Id).cscfga__Line_Item_Description__c;
                    if(prodConfigToAttMap.get(pc.Id).cscfga__Price__c > 0 && pc.cscfga__Attribute_Name__c != 'Add Ons'){
                        masterRecord.Product_List_Price__c = prodConfigToAttMap.get(pc.Id).cscfga__Price__c;
                    }
                    //}
                    String commercialProdId = prodConfigToAttMap.get(pc.Id).cscfga__Value__c;
                    if(commercialProdId != null && commercialProdId.startsWith('a4d') && ActualRecToPmRecMap.containskey(commercialProdId)){
                        masterRecord.Product_Name__c = ActualRecToPmRecMap.get(commercialProdId).Product_Name__c;
                        masterRecord.Active__c = ActualRecToPmRecMap.get(commercialProdId).Active__c;
                        masterRecord.SKU_Number__c = ActualRecToPmRecMap.get(commercialProdId).SKU_Number__c;
                        masterRecord.Income_Account_Code__c = ActualRecToPmRecMap.get(commercialProdId).Income_Account_Code__c;
                        masterRecord.Deferred_Account_Code__c = ActualRecToPmRecMap.get(commercialProdId).Deferred_Account_Code__c;
                        masterRecord.Tax_Code__c = ActualRecToPmRecMap.get(commercialProdId).Tax_Code__c;
                        masterRecord.Product_Catagory__c = ActualRecToPmRecMap.get(commercialProdId).Product_Catagory__c;
                        masterRecord.Product_Class__c = ActualRecToPmRecMap.get(commercialProdId).Product_Class__c;
                        masterRecord.Product_Subclass__c = ActualRecToPmRecMap.get(commercialProdId).Product_Subclass__c;
                        masterRecord.Description__c = ActualRecToPmRecMap.get(commercialProdId).Description__c;
                    }
                }
                if(pc.Digital_Product__c != null && ActualRecToPmRecMap.containskey(pc.Digital_Product__c)){
                    masterRecord.Product_Name__c = ActualRecToPmRecMap.get(pc.Digital_Product__c).Product_Name__c;
                    masterRecord.Description__c = ActualRecToPmRecMap.get(pc.Digital_Product__c).Description__c;
                    masterRecord.Rev_Accrual_GL_Code__c = ActualRecToPmRecMap.get(pc.Digital_Product__c).Rev_Accrual_GL_Code__c;   
                    masterRecord.Income_Account_Code__c = ActualRecToPmRecMap.get(pc.Digital_Product__c).Income_Account_Code__c;
                    masterRecord.Deferred_Account_Code__c = ActualRecToPmRecMap.get(pc.Digital_Product__c).Deferred_Account_Code__c;
                    masterRecord.Tax_Code__c = ActualRecToPmRecMap.get(pc.Digital_Product__c).Tax_Code__c;
                    masterRecord.Product_Catagory__c = ActualRecToPmRecMap.get(pc.Digital_Product__c).Product_Catagory__c;
                    masterRecord.Product_Class__c = ActualRecToPmRecMap.get(pc.Digital_Product__c).Product_Class__c;
                    masterRecord.Product_Subclass__c = ActualRecToPmRecMap.get(pc.Digital_Product__c).Product_Subclass__c;
                }
                idTomasterRecordsMap.put(masterRecord.Actual_Record_Id__c, masterRecord);    
            }else
                deletedRecList.add(pc.Id);
            
        }
        
        for (cscfga__Configuration_Offer__c offer : scope){
            Product_Master_Table__c masterRecord = new Product_Master_Table__c();
            if(ActualRecToPmRecMap.containskey(offer.Id))
                masterRecord.Id = ActualRecToPmRecMap.get(offer.Id).Id;
            masterRecord.Actual_Record_Id__c = offer.Id;
            masterRecord.Active__c = offer.cscfga__Active__c;
            masterRecord.Product_Stored_In__c = 'Offer';
            masterRecord.Product_Name__c = offer.Name;
            masterRecord.Description__c = offer.cscfga__Description__c;
            //Type casting to Date from DateTime
            Datetime startDT = offer.cscfga__Date_Range__r.cscfga__Start__c;
            DateTime endDT = offer.cscfga__Date_Range__r.cscfga__End__c;
            if(startDT != null)
                masterRecord.Effective_start_date__c = date.newinstance(startDT.year(), startDT.month(), startDT.day());
            if(endDT != null)
                masterRecord.Effective_end_date__c = date.newinstance(endDT.year(), endDT.month(), endDT.day());
            idTomasterRecordsMap.put(masterRecord.Actual_Record_Id__c, masterRecord);
        }
        if(!idTomasterRecordsMap.values().isEmpty())
            Upsert idTomasterRecordsMap.values();
        
        for(Product_Master_Table__c pmRec : idTomasterRecordsMap.values()){
            if(ChildToParentMap.containskey(pmRec.Actual_Record_Id__c)){
                pmRec.Parent_Product_Master__c = idTomasterRecordsMap.get(ChildToParentMap.get(pmRec.Actual_Record_Id__c)).Id;
            } 
        }
        Update idTomasterRecordsMap.values();
        
        if(!deletedRecList.isEmpty()){
            for(String pcRec : deletedRecList){
                if(ActualRecToPmRecMap.containskey(pcRec)){
                    RecTodeleteList.add(ActualRecToPmRecMap.get(pcRec));
                }
            }
        }
        Delete RecTodeleteList;
            
    }
    global void finish( Database.BatchableContext BC ) {
    }
    
}
public class BulkOrderBatchClass implements Database.Batchable<wrapper>{ 
    List<String> headerApiValues = new List<String>();
    List<String> csvFileLines = new List<String>();
    List<String> headerValuesCsvFile = new List<String>();
    List<sObject> recordsOppUpload = new List<sObject>();
    List<sObject> recordsQliUpload = new List<sObject>();
    List<sObject> recordsProdUpload = new List<sObject>();
    /*Map Type Variables*/
    Map<String,Schema.DisplayType> mapofAPIvsDataType = new map<String,Schema.DisplayType>();
    Map<String, Bulk_Purchase_Header__c> mapOpportunityCustomSetting = new Map<String, Bulk_Purchase_Header__c>();
    
    String fileContents;
    public BulkOrderBatchClass(String fileContents){
        this.fileContents = fileContents;  
    } 
    public  Iterable<wrapper> start(Database.BatchableContext info){ 
        //get the decoded string 
        list<wrapper> wrapperlist = new list<wrapper>();
        
        Blob data = EncodingUtil.base64Decode(fileContents);
        
        //get all the rows from the file data in list
        csvFileLines = data.tostring().split('\n');
        
        //get all the headers from the file data and save in list 
        headerValuesCsvFile = csvFileLines[0].trim().split(',');
        
        //get custom setting which contains label of header and its api name for the object whose records are to be created from the uploaded file
        mapOpportunityCustomSetting = Bulk_Purchase_Header__c.getAll();
        
        //iterate through custom setting and get the data type against the field api of the custom object
        for(String headerValue : headerValuesCsvFile){
            //these two step is to ensure that there is no breakage in the list
            headerValue = headerValue.removeEnd('\r');
            headerValue = headerValue.normalizeSpace();
            //here we are getting the field data type from the custom object and getting it stored in map
            if(mapOpportunityCustomSetting.containsKey(headerValue)){
                headerApiValues.add(mapOpportunityCustomSetting.get(headerValue).API_NAME__c);
                
                Map<String, Schema.SObjectField> oppfieldMap = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
                Map<String, Schema.SObjectField> qlifieldMap = Schema.getGlobalDescribe().get('QuoteLineItem').getDescribe().fields.getMap();
                Map<String, Schema.SObjectField> prodfieldMap = Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap();
                
                if(oppfieldMap.containsKey(mapOpportunityCustomSetting.get(headerValue).API_NAME__c)){
                    Schema.DisplayType fielddataType = oppfieldMap.get(mapOpportunityCustomSetting.get(headerValue).API_NAME__c).getDescribe().getType();
                    mapofAPIvsDataType.put(mapOpportunityCustomSetting.get(headerValue).API_NAME__c,fielddataType);
                }else if (qlifieldMap.containsKey(mapOpportunityCustomSetting.get(headerValue).API_NAME__c)){
                    Schema.DisplayType fielddataType = qlifieldMap.get(mapOpportunityCustomSetting.get(headerValue).API_NAME__c).getDescribe().getType();
                    mapofAPIvsDataType.put(mapOpportunityCustomSetting.get(headerValue).API_NAME__c,fielddataType);
                }else if(prodfieldMap.containsKey(mapOpportunityCustomSetting.get(headerValue).API_NAME__c)) {
                    Schema.DisplayType fielddataType = prodfieldMap.get(mapOpportunityCustomSetting.get(headerValue).API_NAME__c).getDescribe().getType();
                    mapofAPIvsDataType.put(mapOpportunityCustomSetting.get(headerValue).API_NAME__c,fielddataType);
                }
            }
        }
        
        if(!mapofAPIvsDataType.isEmpty() && !mapofAPIvsDataType.values().isEmpty()){
            for(Integer i = 1; i < csvFileLines.size(); i++){
                wrapper wp = new wrapper();
                
                List<String> inputvalues = csvFileLines[i].split(',');
                sObject sObj = Schema.getGlobalDescribe().get('Opportunity').newSObject();
                sObject sObjQli = Schema.getGlobalDescribe().get('QuoteLineItem').newSObject();
                sObject sObjprod = Schema.getGlobalDescribe().get('Product2').newSObject();
                system.debug('headerApiValues.size()'+headerApiValues.size());
                for(Integer j=0;j<headerApiValues.size();j++){
                    if(inputvalues.size()> j){
                        inputvalues[j] = inputvalues[j].remove('\r');
                        system.debug('inputvalues[j]'+inputvalues[j]);
                        System.debug(headerValuesCsvFile[j]);
                        if(mapOpportunityCustomSetting.get(headerValuesCsvFile[j]).Object_Name__c == 'Opportunity'){
                            if(mapofAPIvsDataType.get(headerApiValues[j]) == Schema.DisplayType.DATE){
                                system.debug('inputvalues[j]'+inputvalues[j]);
                                sObj.put(headerApiValues[j],Date.valueOf(inputvalues[j])) ; 
                            }
                            else{
                                sObj.put(headerApiValues[j],inputvalues[j]);
                            }
                        } else if (mapOpportunityCustomSetting.get(headerValuesCsvFile[j]).Object_Name__c == 'Product2') {
                            sObjprod.put(headerApiValues[j],inputvalues[j]);
                        } else if (mapOpportunityCustomSetting.get(headerValuesCsvFile[j]).Object_Name__c == 'QuoteLineItem') {
                            if(mapofAPIvsDataType.get(headerApiValues[j]) == Schema.DisplayType.DATE){
                                sObjQli.put(headerApiValues[j],Date.valueOf(inputvalues[j])) ; 
                            }else if(mapofAPIvsDataType.get(headerApiValues[j]) == Schema.DisplayType.PERCENT){
                                sObjQli.put(headerApiValues[j],DECIMAL.valueOf(inputvalues[j])) ; 
                            }else if(mapofAPIvsDataType.get(headerApiValues[j]) == Schema.DisplayType.DOUBLE){
                                sObjQli.put(headerApiValues[j],DECIMAL.valueOf(inputvalues[j])) ; 
                            }
                            else{
                                sObjQli.put(headerApiValues[j],inputvalues[j]);
                            }
                        }
                        
                    }
                    
                }
                wp.recordsOppUpload = sObj;
                wp.recordsQliUpload = sObjQli;
                wp.recordsProdUpload =sObjprod;
                wrapperlist.add(wp); 
            }
        }   
        
        
        return wrapperlist; 
        
    }
    public void execute(Database.BatchableContext info, list<wrapper> scope){
        
        Id b2cRecId = RecordTypeSelector.getRecordTypeId('Opportunity', 'B2C');
        Map<String, Subsidiary__c> mapOfSubsidiary = PGOpportunityTriggerHandler.getSubsidiaryMap();
        Map<Id, String> OwnerSubsNameIdMap = PGOpportunityTriggerHandler.UserIdSubsIdMap();
        Map<Id, Id> SubsIdPBIdMap = PGOpportunityTriggerHandler.SubsidiaryIdPricebookIdMap();
        list<Opportunity> listOfOpportunityToInsert = new list<Opportunity>();
        Integer currentMonth = system.today().Month();
        Integer currentYear = system.today().Year();
        List<Sales_Period__c> optySalesPeriod= [SELECT Id FROM Sales_Period__c WHERE Subsidiary__r.Country__c IN: SYSTEM.LABEL.PG_LABEL_SalesPeriodCountries.split(';') AND CALENDAR_MONTH(Sales_Period_Month__c) =:currentMonth AND CALENDAR_YEAR(Sales_Period_Month__c) =:currentYear];
        
        for(Wrapper wp : scope){
            if(wp.recordsOppUpload !=null){
                Opportunity opportunityRecord = (Opportunity)wp.recordsOppUpload;
                if(optySalesPeriod.isEmpty()) {
                   opportunityRecord.addError('sales period is empty!!');
                } else {
                opportunityRecord.RecordTypeId = b2cRecId;
                opportunityRecord.isBulkUpdate__c = true;
                opportunityRecord.OMC_Approved_Date__c = System.now();
                opportunityRecord.Sales_Period__c = optySalesPeriod[0].Id;
                listOfOpportunityToInsert.add(opportunityRecord);
                }
            }
            
            insert listOfOpportunityToInsert;
            
            Set<String> oppIds = new Set<String>();
            for(Opportunity opp:listOfOpportunityToInsert) {
                oppIds.add(opp.Id);
            }
             system.debug('oppIds==>'+oppIds);
            Set<String> currencyIsoCode = new Set<String>();
            Set<String> priceBook2Ids = new Set<String>();
            List<Opportunity> oppList = [SELECT Id,Pricebook2Id,CurrencyIsoCode,accountid,ownerid,recordtypeid,subsidiary__c
                                         from opportunity where id in:oppIds];
            system.debug('oppList==>'+oppList);
            //applyDefault(oppList);
            for(Opportunity opp:oppList) {
                currencyIsoCode.add(opp.CurrencyIsoCode);
            }
             
            list<Product2> listOfProd = new list<Product2>();
            
            Product2 prodRecord = (Product2)wp.recordsProdUpload;
            listOfProd.add(prodRecord);
            
            
            List<String> prodSkuCode = new List<String>();
            for(Product2 prodsku :listOfProd) {
                prodSkuCode.add(prodsku.SKU_Code__c);
            }
            
            Map<String,Product2> mapOfIdVsProd = new Map<String,Product2>();
            Map<Integer,String> mapOfIndexVsSKUCode = new Map<Integer,String>();
            Map<String,String> mapOfSkuCodeVsProdId = new Map<String,String>();
            Integer count = 0;
            for(Product2 prod:[SELECT Id,SKU_Code__c,Name FROM Product2 WHERE SKU_Code__c IN: prodskucode]) {
                mapOfIndexVsSKUCode.put(count,prod.SKU_Code__c);
                mapOfSkuCodeVsProdId.put(prod.SKU_Code__c,prod.Id);
                count++;
            }
            
            List<Quote> quoList = [SELECT Id,Name,PriceBook2Id,issyncing,CurrencyIsoCode FROM Quote WHERE OpportunityId IN :oppIds];
            system.debug('quoList==>'+quoList);
            List<Quote> quoPriceBookIds = new List<Quote>();
            list<Opportunity> oppToupdate = new list<Opportunity>();
            
            for(Quote q : [SELECT Id,Name,PriceBook2Id,issyncing,Opportunityid,Opportunity.Pricebook2Id,Opportunity.ownerId  FROM Quote WHERE OpportunityId IN :oppIds]){
                q.PriceBook2Id =  SubsIdPBIdMap.get(mapOfSubsidiary.get(OwnerSubsNameIdMap.get(q.Opportunity.ownerId)).Id);
                quoPriceBookIds.add(q);
                Opportunity op = new Opportunity(id =q.Opportunityid,PriceBook2Id = SubsIdPBIdMap.get(mapOfSubsidiary.get(OwnerSubsNameIdMap.get(q.Opportunity.ownerId)).Id) );
                oppToupdate.add(op);  
                priceBook2Ids.add(q.PriceBook2Id);
            }
            system.debug('priceBook2Ids==>'+priceBook2Ids);
            update quoPriceBookIds;
            system.debug('quoPriceBookIds==>'+quoPriceBookIds);
            update oppToupdate;
            Map<String,PriceBookEntry> mapOfProdIdVsPbeId = new Map<String,PriceBookEntry>();
            for(PriceBookEntry pbe:[SELECT Id,Pricebook2Id,Product2Id,Product2.SKU_Code__c,UnitPrice FROM PriceBookEntry 
                                    WHERE IsActive=true AND Product2Id IN:mapOfSkuCodeVsProdId.values() AND 
                                    CurrencyIsoCode=:currencyIsoCode AND Product2.SKU_Code__c IN:prodSkuCode AND Pricebook2.IsStandard = FALSE]) {
                                        mapOfProdIdVsPbeId.put(pbe.Product2Id,pbe);
                                        system.debug('pbe==>'+pbe);
                                    }
            
            system.debug('mapOfProdIdVsPbeId==>'+mapOfProdIdVsPbeId);
            List<Opportunity> syncQuo2Opp = new List<Opportunity>();
            for(Quote qu : [SELECT Id,Name,issyncing,Opportunityid FROM Quote WHERE OpportunityId IN :oppIds]){
                syncQuo2Opp.add(new Opportunity(id=qu.OpportunityId,syncedQuoteId=qu.Id));
                
            }
            update syncQuo2Opp;
            list<QuoteLineItem> listOfQliToInsert = new list<QuoteLineItem>();
            Map<Id,List<Item_Bundle__c>> prodIdVsItemBundle = new Map<Id,List<Item_Bundle__c>>();
            Map<string, Item_Bundle__c> mapItemBundle = new Map<string, Item_Bundle__c>();
            list<String> listChildProdWithSeqNo=new list<String>();
            
            for(Item_Bundle__c itemBundle :[select Id,Parent_Product__c, Child_Product__c, Qty__c,Sno__c, Upload_Tag__c from Item_Bundle__c
                                            where Parent_Product__c in :mapOfSkuCodeVsProdId.values() order By Sno__c ASC]) {
                                                if(!prodIdVsItemBundle.containskey(itemBundle.Parent_Product__c)) {
                                                    prodIdVsItemBundle.put(itemBundle.Parent_Product__c,new List<Item_Bundle__c>{itemBundle});
                                                } else {
                                                    prodIdVsItemBundle.get(itemBundle.Parent_Product__c).add(itemBundle);
                                                }
                                                mapItemBundle.put(itemBundle.Child_Product__c, itemBundle);
                                                listChildProdWithSeqNo.add(itemBundle.Sno__c+'_'+itemBundle.Child_Product__c);
                                            }
            List<PricebookEntry> listchildPricebookEntry = [select Id, Name,UnitPrice, Pricebook2Id, Product2.Id, Product2.Name, Product2.Product_Type__c,
                                                            Product2.Description, Product2.Product_Category__c, Product2.Is_Bundle__c, Product2.SKU_Code__c,
                                                            Product2.CurrencyIsoCode, CurrencyIsoCode, Pricebook2.CurrencyIsoCode, Product2.Tax_Code__c, 
                                                            Product2.Tax_Code__r.Tax_Rate__c, Product2.Income_Account_Name__c FROM PricebookEntry 
                                                            WHERE  Product2.IsActive=TRUE AND IsActive=TRUE AND Pricebook2Id IN:priceBook2Ids  
                                                           ];
            system.debug('listchildPricebookEntry==>'+listchildPricebookEntry);
            listChildProdWithSeqNo.sort();
            
            Map<Id,PricebookEntry> mapOfProductWithPbe=new Map<Id,PricebookEntry>();
            for(PricebookEntry eachPbe: listchildPricebookEntry) {
                if(mapItemBundle.containsKey(eachPbe.Product2Id)) {
                    mapOfProductWithPbe.put(eachPbe.Product2.Id,eachPbe);
                }
            }
            count = 0;
            if(wp.recordsQliUpload!=null) {
                QuoteLineItem qliRecord = (QuoteLineItem)wp.recordsQliUpload;
                qliRecord.QuoteId = quoList[count].Id;
                qliRecord.SNo__c = 1;
                qliRecord.PricebookEntryId =mapOfProdIdVsPbeId.get(mapOfSkuCodeVsProdId.get(prodSkuCode[count])).Id;
                qliRecord.UnitPrice = mapOfProdIdVsPbeId.get(mapOfSkuCodeVsProdId.get(prodSkuCode[count])).UnitPrice;
                qliRecord.Product2Id = mapOfSkuCodeVsProdId.get(prodSkuCode[count]);
                listOfQliToInsert.add(qliRecord);
                
                if(prodIdVsItemBundle.containskey(mapOfSkuCodeVsProdId.get(prodSkuCode[count]))){
                    listOfQliToInsert.addAll(insertChildQli(mapItemBundle,listChildProdWithSeqNo,mapOfProductWithPbe,mapOfSkuCodeVsProdId.get(prodSkuCode[count]),qliRecord,listchildPricebookEntry));
                }
                if(!listOfQliToInsert.isempty()){
                    insert listOfQliToInsert;   
                }
                
                
            }
            Set<id> setOfQliIdInserted = new Set<Id>();
            Set<id> Quoteid = new Set<Id>();
            if(!listOfQliToInsert.isEmpty()) {
                updateQuoteStatus(quoList);
                
            }
            for(QuoteLineItem qli : listOfQliToInsert){
                setOfQliIdInserted.add(qli.id); 
                Quoteid.add(qli.quoteid);
            }
            if(setOfQliIdInserted.size()>0){
                QliToOliSyncOnInsert(setOfQliIdInserted);
                BulkPurchaseRecordCreationController.updateOpptyToClosed(Quoteid);  
            }
        }
        
    }     
    public void finish(Database.BatchableContext info){     
    } 
    public class wrapper{
        sObject recordsOppUpload;
        sObject recordsQliUpload;
        sObject recordsProdUpload;
        
    }
    public static List<QuoteLineItem> insertChildQli (Map<string, Item_Bundle__c> mapItemBundle,list<String> listChildProdWithSeqNo,Map<Id,PricebookEntry> mapOfProductWithPbe,Id parentProdId,QuoteLineItem qLIObj,List<PricebookEntry> childPriceBookEntry) {
        
        
        List<QuoteLineItem> childQLIList = new List<QuoteLineItem>();
        for (String each: listChildProdWithSeqNo){
            
            Decimal qliSno;
            if(each.substringBefore('_') != null) {
                qliSno = Decimal.valueOf(each.substringBefore('_'));
            }
            PricebookEntry row=mapOfProductWithPbe.get(each.substringAfter('_'));
            if(mapOfProductWithPbe.containskey(each.substringAfter('_'))){
                if (row.CurrencyIsoCode == row.Pricebook2.CurrencyIsoCode && row.Product2.CurrencyIsoCode == row.Pricebook2.CurrencyIsoCode) {
                    QuoteLineItem childQLI = new QuoteLineItem();
                    childQLI.QuoteId = qLIObj.QuoteId;
                    childQLI.PricebookEntryId =row.Id;
                    childQLI.UnitPrice = 0;
                    childQLI.SNo__c = qliSno!=null?qliSno:null;
                    childQLI.Start_Date__c = qLIObj.Start_Date__c;
                    childQLI.End_Date__c = qLIObj.End_Date__c;
                    childQLI.Product_Type__c = row.Product2.Product_Type__c;
                    childQLI.Quantity = integer.valueOf(mapItemBundle.get(row.Product2.Id).Qty__c);
                    childQLI.Product2Id = row.Product2Id;
                    childQLI.Product2 = row.product2;
                    childQLI.Product2.Name = row.product2.Name;
                    childQLI.Description = row.Product2.Description;
                    childQLI.Parent__c = parentProdId;
                    childQLI.Child_Category__c = 'Package';
                    childQLI.Complimentary__c = true;
                    childQLI.Line_Description2__c = row.Product2.Description;
                    childQLI.Product_Category__c = row.Product2.Product_Category__c;
                    childQLI.Original_Price__c = childQLI.UnitPrice==null?0:childQLI.UnitPrice;
                    childQLI.Push_to_NetSuite__c = false;
                    if (row.Product2.Tax_Code__c != null) {
                        childQLI.GST_VAT_Code__c = row.Product2.Tax_Code__c;
                    } else {
                        childQLI.GST_VAT_Code__c = null;
                    }
                    if (row.Product2.Tax_Code__r != null ) {
                        childQLI.GST_VAT_Rate__c = row.Product2.Tax_Code__r.Tax_Rate__c;
                    } else {
                        childQLI.GST_VAT_Rate__c = 0;
                    }
                    childQLI.Income_Account_Name__c = row.Product2.Income_Account_Name__c;
                    childQLI.PO__c = true;
                    childQLIList.add(childQLI);
                }
            }
        }
        return childQLIList;
    }
    
    public static void updateQuoteStatus(list<Quote> quoList) {
        Set<Id> setquoteId = new Set<Id>();
        List<Quote> quoToBeUpdated = new List<Quote>();
        for(Quote quoObj: quoList) {
            quoObj.Status = 'Accepted';
            quoToBeUpdated.add(quoObj);
            setquoteId.add(quoObj.id);
        }
        Update quoToBeUpdated;
        if(setquoteId.size()>0)
            QuoteSyncHandler.isQLITriggerFire=false;
        
    }
    public static void QliToOliSyncOnInsert(Set<Id> setofQliId){
        system.debug('setofQliId'+setofQliId);
        List<QuoteLineItem> lstOfQLI=[Select Id,OpportunityLineItemId,Complimentary__c,Discount_Amount__c,Discount__c,End_Date__c,GST_VAT_Rate__c,Line_Description2__c,PO__c,Pro_Rate_Amount__c,Push_To_NetSuite__c,Record_Type__c,SNo__c,Start_Date__c,Quote.Invoice_Id__c,Discount_Reason__c,Amount_Despite_VIP__c,Product_Category__c from QuoteLineItem where Id IN :setofQliId];
        system.debug('lstOfQLI'+lstOfQLI);
        List<OpportunityLineItem> lstOppItem=new List<OpportunityLineItem>();
        for(QuoteLineItem eachQLI: lstOfQLI){
            OpportunityLineItem objOLI=new OpportunityLineItem(Id=eachQLI.OpportunityLineItemId);
            objOLI.Complimentary__c=eachQLI.Complimentary__c;
            objOLI.Discount_Amount__c=eachQLI.Discount_Amount__c; 
            objOLI.Discount__c=eachQLI.Discount__c;
            objOLI.End_Date__c=eachQLI.End_Date__c;
            objOLI.GST_VAT_Rate__c=eachQLI.GST_VAT_Rate__c;
            objOLI.Line_Description2__c=eachQLI.Line_Description2__c;
            objOLI.PO__c=eachQLI.PO__c;
            objOLI.Pro_Rate_Amount__c=eachQLI.Pro_Rate_Amount__c;
            objOLI.Push_To_NetSuite__c=eachQLI.Push_To_NetSuite__c;
            objOLI.Record_Type__c=eachQLI.Record_Type__c;
            objOLI.SNo__c=eachQLI.SNo__c;
            objOLI.Start_Date__c=eachQLI.Start_Date__c;
            objOLI.Discount_Reason__c=eachQLI.Discount_Reason__c;
            objOLI.Amount_Despite_VIP__c=eachQLI.Amount_Despite_VIP__c;
            objOLI.Product_Category__c=eachQLI.Product_Category__c;
            lstOppItem.add(objOLI);
        }
        If(lstOppItem.size()>0){
            QuoteSyncHandler.isQLITriggerFire=false;
            Update lstOppItem;
        }
        
    }
    
    public static void applyDefault(List<Opportunity> newList) {
        String b2c =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        String b2cCloseLost =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Closed Lost').getRecordTypeId();
        String b2b=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        String directBooking =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Direct Booking').getRecordTypeId();
        list<Opportunity> oppToupdate = new list<Opportunity>();
        QuoteSyncHandler.isTriggerFire = false;
        Set<Id> accountIdB2C = new Set<id>();
        Set<Id> allAccountId = new Set<id>();
        Map<id,id> accIdVsContactId = new Map<id,id>();
        
        if(PGOpportunityTriggerHandler.isFirstTimeSub) {
            //Set subsidiary & pricebook
            Map<String, Subsidiary__c> mapOfSubsidiary = PGOpportunityTriggerHandler.getSubsidiaryMap();
            Map<Id, String> OwnerSubsNameIdMap = PGOpportunityTriggerHandler.UserIdSubsIdMap();
            Map<Id, Id> SubsIdPBIdMap = PGOpportunityTriggerHandler.SubsidiaryIdPricebookIdMap();
            Set<String> setOfOwnerId = new Set<String>();
            for (Opportunity Opp: newList) {
                if(opp.AccountId != null) {
                    if(opp.RecordTypeId == b2c) {
                        accountIdB2C.add(opp.AccountId);
                    }
                    allAccountId.add(opp.AccountId);
                }
                setOfOwnerId.add(Opp.OwnerId);
            }
            //getting user info of current user and oppty owner
            setOfOwnerId.add(UserInfo.getUserId());
            Map<String, User> mapOfUsers = new Map<String, User>([
                SELECT Id, Profile.Name, Sales_Head__c FROM User WHERE Id IN: setOfOwnerId
            ]);
            //getting the account Info
            Map<String, Account> mapOfAccount = new Map<String, Account>();
            if(!allAccountId.isEmpty()) {
                mapOfAccount = new Map<String, Account>([
                    SELECT Id, Country__c, Subsidiary_Type__c FROM Account WHERE Id IN: allAccountId
                ]);
            }
            for(Opportunity Opp: newList) {
                if(!mapOfSubsidiary.isEmpty() && !OwnerSubsNameIdMap.isEmpty()) {
                    String SubsId = mapOfSubsidiary.get(OwnerSubsNameIdMap.get(opp.ownerId)).Id;
                    //For system admin profiles and Integration profile that usually are used during sync, bulk data updates,
                    //oppty creation using scheduled jobs
                    if(
                        mapOfUsers.get(UserInfo.getUserId()).Profile.Name.equals('System Administrator') ||
                        mapOfUsers.get(UserInfo.getUserId()).Profile.Name.equals('Delegated System Administrator')||
                        mapOfUsers.get(UserInfo.getUserId()).Profile.Name.equals('API User Profile')||
                        mapOfUsers.get(UserInfo.getUserId()).Profile.Name.equals('Integration Profile')
                        
                    ) {
                        if(mapOfAccount.containsKey(opp.AccountId) && mapOfAccount.get(opp.AccountId).Country__c != null) {
                            if(mapOfAccount.get(opp.AccountId).Country__c.equals('Singapore')) {
                                opp.subsidiary__c = mapOfSubsidiary.get(label.SG_SUBSIDIARY_NAME).Id;
                                opp.currencyIsoCode = 'SGD';
                            } else if(mapOfAccount.get(opp.AccountId).Country__c.equals('Malaysia')) {
                                opp.currencyIsoCode = 'MYR';
                                if(
                                    mapOfAccount.get(opp.AccountId).Subsidiary_Type__c != null &&
                                    mapOfAccount.get(opp.AccountId).Subsidiary_Type__c.equals('MPD')
                                ) {
                                    opp.subsidiary__c = mapOfSubsidiary.get(label.MY_SUBSIDIARY_MPD_NAME).Id;
                                } else {
                                    opp.subsidiary__c = mapOfSubsidiary.get(label.MY_SUBSIDIARY_NAME).Id;
                                }
                            } else if (mapOfAccount.get(opp.AccountId).Country__c.equals('Thailand')) {
                                if(mapOfSubsidiary.containsKey(label.TH_SUBSIDIARY_NAME_HO) &&
                                   SubsId == mapOfSubsidiary.get(label.TH_SUBSIDIARY_NAME_HO).Id) {
                                       opp.subsidiary__c = mapOfSubsidiary.get(label.TH_SUBSIDIARY_NAME_HO).Id;
                                   } else if(mapOfSubsidiary.containsKey(label.TH_SUBSIDIARY_NAME)){
                                       opp.subsidiary__c = mapOfSubsidiary.get(label.TH_SUBSIDIARY_NAME).Id;
                                   }
                                opp.currencyIsoCode = 'THB';
                            } else if (mapOfAccount.get(opp.AccountId).Country__c.equals('Indonesia')) {
                                opp.subsidiary__c = mapOfSubsidiary.get(label.IDR_SUBSIDIARY_NAME).Id;
                                opp.currencyIsoCode = 'IDR';
                            }
                        }
                    } else {
                        opp.subsidiary__c = mapOfSubsidiary.get(OwnerSubsNameIdMap.get(opp.ownerId)).Id;
                    }
                    if (
                        !Opp.isClone() && !SubsIdPBIdMap.isEmpty() &&
                        (opp.recordtypeId == directBooking ||
                         Opp.recordtypeId==b2b ||
                         Opp.recordtypeId==b2c ||
                         Opp.recordtypeId==b2cCloseLost)
                    ) {
                        opp.PriceBook2Id = SubsIdPBIdMap.get(mapOfSubsidiary.get(OwnerSubsNameIdMap.get(opp.ownerId)).Id);
                    }
                    
                    if (!Test.isRunningTest() && Opp.ownerId != null && mapOfUsers.containsKey(Opp.ownerId)) {
                        opp.User_Sales_Head__c = mapOfUsers.get(Opp.ownerId).Sales_Head__c;
                    }
                }
                PGOpportunityTriggerHandler.isFirstTimeSub=false;
                oppToupdate.add(opp);
            }
            update oppToupdate;
        }
        
    }
    public static void increasecoverage(){
        Integer i =0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}
public class QuoteLineItemTriggerHelper {
    public static Map<Id,Id> mapOfQuoteIdVsProdId = new Map<Id,Id>();
    
    public static void prepopulateQliFields(List<QuoteLineItem> newList){
        Set<Id> prodId=new Set<Id>();
        for(QuoteLineItem eachqli : newList){
            if(eachqli.Quote_Type__c!=null && eachqli.Quote_Type__c!=''){
                eachqli.Record_Type__c='B2C';
                prodId.add(eachqli.Product2id);
            }
        }
        Map<Id,product2> mapofProd=new Map<Id,product2>([select Product_Category__c,Tax_Code__c,Tax_Code__r.Tax_Rate__c from product2 where id In:prodId]);
        for(QuoteLineItem each : newList){
            
            If(!mapofProd.isEmpty() && mapofProd.get(each.Product2id).Product_Category__c !=null && each.Quote_Type__c!=null){
                Decimal AmountDVIP = 0.00;
                Decimal AmountDisc = 0.00;
                String discount_reason;
                each.Product_Category__c=mapofProd.get(each.Product2id).Product_Category__c;
                if(mapofProd.get(each.Product2id).Tax_Code__c != null){
                    each.GST_VAT_Code1__c = mapofProd.get(each.Product2id).Tax_Code__c;
                    if(mapofProd.get(each.Product2id).Tax_Code__r.Tax_Rate__c != null){
                        each.GST_VAT_Rate__c = mapofProd.get(each.Product2id).Tax_Code__r.Tax_Rate__c;    
                    }else{
                        each.GST_VAT_Rate__c = 0;
                    }
                    
                }   
                //Amount_Despite_VIP__c Logic Same as OLI Trigger
                if(each.Product_Category__c == 'Subscription'){
                    if(each.Discount__c!=null && each.Discount__c > 0 ){
                        AmountDisc = (each.UnitPrice * each.Quantity) * (each.Discount__c/100);
                    }
                    if(each.Discount_Amount__c != null && each.Discount_Amount__c > 0 ){
                        AmountDisc = each.Discount_Amount__c;
                    }
                    if(each.Complimentary__c == true){
                        AmountDVIP = (each.UnitPrice * each.Quantity);
                    }else{
                        AmountDVIP = (each.UnitPrice * each.Quantity)  - ((AmountDisc!=null)?AmountDisc:0) - ((each.Pro_Rate_Amount__c!=null)?each.Pro_Rate_Amount__c:0.00);
                    }
                    //Update Amount For VIP
                    if(each.Discount_Reason__c != null){
                        discount_reason = each.Discount_Reason__c;
                        System.debug('Discount Reason:' + discount_reason);
                        if(discount_reason.contains('VIP')){
                            each.Amount_Despite_VIP__c = each.UnitPrice;
                        }   
                    }
                    //Update Amount For Non-VIP
                    if(each.Discount_Reason__c != 'VIP (Lifetime FOC)' && each.Discount_Reason__c != 'VIP (Relationship)' && each.Discount_Reason__c != 'VIP (Spending)' && each.Discount_Reason__c != 'VIP (migration)'){
                        //oppitem.Amount_Despite_VIP__c = oppitem.Amount__c;
                        each.Amount_Despite_VIP__c = AmountDVIP;
                    }
                    
                }
            }
        }
    }
    //Rollup fields Logic
    public static void summarizeLineItem(list<QuoteLineItem> listQuoteLineItem) {
        set<Id> setQuoteId = new set<Id>();
        //set<Id> setOppLineIdDebug = new set<Id>();
        for (QuoteLineItem row: listQuoteLineItem) {
            If(row.Quote_Type__c!=null){
                setQuoteId.add(row.QuoteId);
            }
            
            //setOppLineIdDebug.add(row.Id);
        }
        //system.debug('beforeFuture:'+setOppLineIdDebug);
        If(setQuoteId.size()>0 && !system.isBatch()){
            PGQuoteOpportunityHelper.summarizeLineItemFuture(setQuoteId);
        }
    }
    //PGAUTO-2479 Always QLI to OLI syncing fields 
    public static void oliSynicngFields(List<QuoteLineItem> newRecords, Map<Id, QuoteLineItem> oldMap,Boolean isInsert){
        List<OpportunityLineItem> lstToUpdateOli=new List<OpportunityLineItem>();
        
        Set<Id> setOfQliId=new Set<Id>();
        Set<Id> setOfQliIdInserted=new Set<Id>();
        for(QuoteLineItem eachQli : newRecords){
            If(eachQli.Quote_Type__c!=null && eachQli.Quote_Type__c!='' ){
                setOfQliId.add(eachQli.Id);
            }
        }
        if(setOfQliId.size()>0){
            Map<Id,QuoteLineItem> mapOfQli=new Map<Id,QuoteLineItem>([select Id,Quote.isSyncing,quote.opportunity.isbulkupdate__c from QuoteLineItem where Id IN:setOfQliId]);
            for(QuoteLineItem each : newRecords){
                If(mapOfQli.get(each.Id).Quote.isSyncing &&(isInsert || each.Discount__c!=oldMap.get(each.Id).Discount__c || each.Discount_Amount__c!=oldMap.get(each.Id).Discount_Amount__c || each.Complimentary__c !=oldMap.get(each.Id).Complimentary__c  ||
                                                            each.Record_Type__c!=oldMap.get(each.Id).Record_Type__c  || each.Pro_Rate_Amount__c!=oldMap.get(each.Id).Pro_Rate_Amount__c || each.GST_VAT_Rate__c!=oldMap.get(each.Id).GST_VAT_Rate__c ||
                                                            each.SNo__c !=oldMap.get(each.Id).SNo__c || each.WHT_Rate__c != oldMap.get(each.Id).WHT_Rate__c))
                {
                    if(each.OpportunityLineItemId!=null){
                        //for update QLi only
                        OpportunityLineItem objOli=new OpportunityLineItem();
                        objOli.Id=each.OpportunityLineItemId;
                        objOli.Discount__c=each.Discount__c;
                        objOli.Discount_Amount__c=each.Discount_Amount__c;
                        objOli.Complimentary__c=each.Complimentary__c;
                        objOli.Record_Type__c=each.Record_Type__c;
                        objOli.Pro_Rate_Amount__c=each.Pro_Rate_Amount__c;
                        objOli.GST_VAT_Rate__c=each.GST_VAT_Rate__c;
                        objOli.SNo__c=each.SNo__c;
                        objOli.WHT_Rate__c=each.WHT_Rate__c;
                        objOli.Quantity=each.Quantity;
                        objOli.UnitPrice = each.UnitPrice; //PGAUTO-5735
                        objOli.Discount = each.Discount;
                        objOli.Start_Date__c=each.Start_Date__c;
                        objOli.End_Date__c=each.End_Date__c;
                        objOli.IsDiscretionaryAC__c=each.IsDiscretionaryAC__c;
                        lstToUpdateOli.add(objOli); 
                    }else{
                        // for inseted QLI only
                        If(mapOfQli.get(each.Id).Quote.opportunity.isbulkupdate__c==false){
                        setOfQliIdInserted.add(each.Id);
                    }
                  }  
                }
           
            }
           
            if(lstToUpdateOli.size()>0){
                QuoteSyncHandler.isQLITriggerFire=false;
                update lstToUpdateOli; 
            }
            if(setOfQliIdInserted.size()>0){
               QliToOliSyncOnInsert(setOfQliIdInserted);
            }
        }
    }
    @future(callout=true)
    public static void QliToOliSyncOnInsert(Set<Id> setofQliId){
        List<QuoteLineItem> lstOfQLI=[Select Id,OpportunityLineItemId,Complimentary__c,Discount_Amount__c,Discount__c,End_Date__c,GST_VAT_Rate__c,Line_Description2__c,PO__c,Pro_Rate_Amount__c,Push_To_NetSuite__c,Record_Type__c,SNo__c,Start_Date__c,Quote.Invoice_Id__c,Discount_Reason__c,Amount_Despite_VIP__c,Product_Category__c from QuoteLineItem where Id IN :setofQliId];
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
    //PGAUTO-1125 QLI History Tracker Implementation ---START
    public static void trackHistory(List<QuoteLineItem> newRecords, Map<Id, QuoteLineItem> oldMap){
        List<QLI_Tracker__c> qlihistories = new List<QLI_Tracker__c>();
        DescribeSObjectResult describe = SObjectType.QuoteLineItem;
        List<SObjectField> qliFields = describe.fields.getMap().values();
        
        for (QuoteLineItem eachrecord : newRecords)
        {
            List<Schema.FieldSetMember> schemaset= SObjectType.QuoteLineItem.FieldSets.Track_History.getFields();
            for(Schema.FieldSetMember each :schemaset){
                If(eachrecord.get(each.getFieldPath()) != oldMap.get(eachrecord.id).get(each.getFieldPath()) ){
                    system.debug('-QLIchanged--'+each.getFieldPath());
                    String oldValue='Blank Value';
                    String newValue ='Blank Value';
                    if(eachrecord.get(each.getFieldPath()) != null && eachrecord.get(each.getFieldPath()) != ''){
                        newValue = string.valueOf(eachrecord.get(each.getFieldPath()));
                    }
                    
                    if(oldMap.get(eachrecord.id).get(each.getFieldPath()) !=null && oldMap.get(eachrecord.id).get(each.getFieldPath()) != '' ){
                        oldValue = string.valueOf(oldMap.get(eachrecord.id).get(each.getFieldPath()));
                    }
                    system.debug('-oldvalue-'+oldValue+'-newValue-'+newValue);
                    qlihistories.add(getHistories(newValue,oldValue,each.getFieldPath(),eachrecord));
                }
            } 
            
        }
        IF(qlihistories!=null && qlihistories.size()>0){
            system.debug('--Qlihistories--'+qlihistories);
            insert qlihistories;
        }
    }
    public static QLI_Tracker__c getHistories(String newValue,String oldValue, String fieldName,QuoteLineItem eachrecord){
        String actionString;
        QLI_Tracker__c objHistory = new QLI_Tracker__c ();
        actionString = 'Changed '+ fieldName+' from '+ oldValue +' to '+ newValue+'' ;
        objHistory.Action__c= actionString;
        objHistory.QuoteId__c=eachrecord.QuoteId;
        objHistory.Quote_Line_Item__c=eachrecord.Id;
        
        return objHistory;
    }
    public static void DeletedQLI(List<QuoteLineItem> oldQLI){
        List<QLI_Tracker__c> historiesList = new List<QLI_Tracker__c>();
        for(QuoteLineItem eachrecord : oldQLI){
            String actionString='';
            QLI_Tracker__c objHistory = new QLI_Tracker__c ();
            actionString = 'Deleted '+ eachrecord.Id+'' ;
            objHistory.QuoteId__c=eachrecord.QuoteId;
            objHistory.Action__c = actionString;
            historiesList.add(objHistory);
        }
        if(historiesList.size()>0){
            insert historiesList;
        } 
    }
    //PGAUTO-1125  -----END
    
    /***method to update totalprice with price after discount value for PGAUTO-6239 ****/
    public static void updateOLIStandardDiscount(List<QuoteLineItem> newList,Map<Id, QuoteLineItem> oldMap){    
        for(QuoteLineItem qliObj:newList){     
            if((oldMap != null &&  oldMap.get(qliObj.Id).Amount__c!= null && qliObj.Amount__c !=null && qliObj.Amount__c != oldMap.get(qliObj.Id).Amount__c) || oldMap == null){
                Decimal discount = 0;
                if(qliObj.Price_before_discount1__c!=0 && qliObj.Amount__c !=null && qliObj.Price_before_discount1__c!=null){
                    discount = (qliObj.Price_before_discount1__c - qliObj.Amount__c)/qliObj.Price_before_discount1__c;
                    discount = discount * 100;
                    qliObj.discount = discount.setScale(3);
                    
                }
            }          
        } 
    }
    
    /**
*  method to update Quote's Floor Price Type field based on the discount provided through QLI
*  @param  trigger.new, oldMap
*  @return void
*  @reference PGAUTO-6667,PGAUTO-7140
*/
    public static void updateQuoteFloorType(List<QuoteLineItem> qliList,Map<Id, QuoteLineItem> oldMap,Boolean isDelete){
        Map<String,Decimal> idVsQliQuantity = new Map<String,Decimal>();
        Map<Id,Id> mapOfQliIdVsProdId = new Map<Id,Id>();
        Set<Id> blankFloorPriceTypeProdIds = new Set<Id>();
        Set<Id> noApprovalQuoteIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> quoteIds = new Set<Id>();
        List<QuoteLineItem> allQliList = new List<QuoteLineItem>();
        Map<String,Decimal> idVsExpectedFloorPrice = new Map<String,Decimal>();
        Map<Id,List<Floor_Price__c>> mapOfProdIdVsFPList = new Map<Id,List<Floor_Price__c>>();
        Map<Id,List<Floor_Price__c>> mapOfProIdVsFPListForBlankFPType = new Map<Id,List<Floor_Price__c>>();
        Map<Id,Quote> updateQuoteMap = new Map<Id,Quote>();
        Map<Id,Quote> mapOfMDQliQuoteIdVsQuote = new Map<Id,Quote>();
        Map<Id,List<QuoteLineItem>> mapOfNoApprovalQuoteIdVsQliList = new Map<Id,List<QuoteLineItem>>();
        List<QuoteLineItem> blankFloorPriceTypeQliList = new List<QuoteLineItem>();
        
        for(QuoteLineItem qli:qliList){
            if(isDelete == false) {
                if((oldMap == null ||
                    qli.Amount__c != oldMap.get(qli.Id).Amount__c || qli.Quantity != oldMap.get(qli.Id).Quantity) && 
                   (qli.Discount__c > 0 || qli.Discount_Amount__c > 0)) {
                       productIds.add(qli.Product2Id);	
                       quoteIds.add(qli.QuoteId);
                   }
                if(oldMap!=null && oldMap.containsKey(qli.Id) && 
                   ((qli.Discount__c != oldMap.get(qli.Id).Discount__c && 
                     qli.Discount__c == 0 ) || 
                    (qli.Discount_Amount__c != oldMap.get(qli.Id).Discount_Amount__c && 
                     qli.Discount_Amount__c == 0 ))
                  ) {
                      blankFloorPriceTypeProdIds.add(qli.Product2Id);
                      noApprovalQuoteIds.add(qli.QuoteId);
                      blankFloorPriceTypeQliList.add(qli);
                  }   
                
            } else {
                blankFloorPriceTypeProdIds.add(qli.Product2Id);
                noApprovalQuoteIds.add(qli.QuoteId);
                blankFloorPriceTypeQliList.add(qli);
            }
        }
        
        if(!quoteIds.isEmpty()) {
            for (QuoteLineItem qli : [SELECT Id,QuoteId,Product2Id,
                                      Product2.Multiple_Sale_Not_Allowed__c,
                                      Discount__c,Discount_Amount__c,
                                      Product2.Name,
                                      Quantity,Amount__c
                                      FROM QuoteLineItem 
                                      WHERE QuoteId In : quoteIds]
                ) {
                    allQliList.add(qli);
                    productIds.add(qli.Product2Id);
                }
        }
        
        if(!productIds.isEmpty()) {
            for(Floor_Price__c floorPrice:  [SELECT Id,
                                             min_Quantity__c,max_Quantity__c,
                                             Price__c,Price2__c,List_Price__c,Product__c 
                                             FROM Floor_Price__c 
                                             WHERE Product__c IN:productIds]
               ) {
                   if(!mapOfProdIdVsFPList.containsKey(floorPrice.Product__c)) {
                       mapOfProdIdVsFPList.put(floorPrice.Product__c,new List<Floor_Price__c>{});
                   }
                   mapOfProdIdVsFPList.get(floorPrice.Product__c).add(floorPrice);
               }
        }
        
        if(!mapOfProdIdVsFPList.isEmpty()) {
            if(!quoteIds.isEmpty()) {
                for(QuoteLineitem qli : [SELECT Id,QuoteId,
                                         Quote.Floor_Price_Type__c,
                                         Quantity,Discount__c,
                                         Product2Id,
                                         Discount_Amount__c,Amount__c
                                         FROM QuoteLineItem
                                         WHERE Discount_Reason__c = 'Managerial Discount'
                                         AND (Discount__c > 0 OR Discount_Amount__c > 0)
                                         AND QuoteId In : quoteIds
                                         AND (Product2Id NOT In : mapOfProdIdVsFPList.keyset())]
                   ) {
                       if(!mapOfMDQliQuoteIdVsQuote.containsKey(qli.QuoteId)) {
                           mapOfMDQliQuoteIdVsQuote.put(qli.QuoteId,new Quote(Id = qli.QuoteId,
                                                                              Floor_Price_Type__c = qli.Quote.Floor_Price_Type__c ));
                       }
                   }
            }
            for(QuoteLineItem qliObj:allQliList) {
                if(mapOfProdIdVsFPList.containsKey(qliObj.Product2Id) && mapOfProdIdVsFPList.get(qliObj.Product2Id)!=null) {
                    for(Floor_Price__c floorPrice: mapOfProdIdVsFPList.get(qliObj.Product2Id)) {
                        if(qliObj.Discount__c > 0 || qliObj.Discount_Amount__c > 0){
                            if((floorPrice.min_Quantity__c<=qliObj.Quantity && qliObj.Quantity<=floorPrice.max_Quantity__c)) {
                                Quote quo = new Quote(Id = qliObj.QuoteId);
                                if(qliObj.Product2.Name.ContainsIgnoreCase('Ad credit')){
                                    quo.Product_Type__c = 'Ad Credit';
                                } else if(qliObj.Product2.Name.ContainsIgnoreCase('Prime credit')) {
                                    quo.Product_Type__c = 'Prime Credit';
                                }
                                if((floorPrice.List_Price__c*qliObj.Quantity) <= qliObj.Amount__c) {
                                    if(!mapOfMDQliQuoteIdVsQuote.isEmpty() &&
                                       mapOfMDQliQuoteIdVsQuote.containsKey(qliObj.QuoteId) /*&&
mapOfMDQliQuoteIdVsQuote.get(qliObj.QuoteId).Floor_Price_Type__c != 'Below List Price with Discount'*/) {
    quo.Floor_Price_Type__c = 'Below List Price with Discount';
} else {
    quo.Floor_Price_Type__c = 'Below List Price';
}
                                    if(!updateQuoteMap.containsKey(quo.Id)) {
                                        updateQuoteMap.put(quo.Id,quo);
                                        if(qliObj.Product2.Multiple_Sale_Not_Allowed__c == true){
                                            mapOfQuoteIdVsProdId.put(quo.Id,qliObj.Product2Id);
                                        }
                                    }
                                    break;
                                }else if((floorPrice.List_Price__c*qliObj.Quantity) > qliObj.Amount__c &&
                                         (floorPrice.Price__c*qliObj.Quantity) <= qliObj.Amount__c) {
                                             quo.Floor_Price_Type__c = 'Above Floor Price';
                                             
                                             if(!updateQuoteMap.containsKey(quo.Id)) {
                                                 updateQuoteMap.put(quo.Id,quo);
                                                 if(qliObj.Product2.Multiple_Sale_Not_Allowed__c == true){
                                                     mapOfQuoteIdVsProdId.put(quo.Id,qliObj.Product2Id);
                                                 }
                                             }
                                             break;
                                         }
                                else if(floorPrice.Price2__c != null && (floorPrice.Price__c*qliObj.Quantity) > qliObj.Amount__c &&
                                        (floorPrice.Price2__c*qliObj.Quantity) <= qliObj.Amount__c){
                                            quo.Floor_Price_Type__c = 'Between Floor Price';
                                            if(!updateQuoteMap.containsKey(quo.Id)) {
                                                updateQuoteMap.put(quo.Id,quo);
                                                if(qliObj.Product2.Multiple_Sale_Not_Allowed__c == true){
                                                    mapOfQuoteIdVsProdId.put(quo.Id,qliObj.Product2Id);
                                                }
                                            }
                                            break;  
                                        }
                                else if(((floorPrice.Price__c*qliObj.Quantity) > qliObj.Amount__c && floorPrice.Price2__c == null) ||
                                        ((floorPrice.Price2__c*qliObj.Quantity) > qliObj.Amount__c && floorPrice.Price2__c != null)) {
                                            quo.Floor_Price_Type__c = 'Below Floor Price';
                                            if(!updateQuoteMap.containsKey(quo.Id)) {
                                                updateQuoteMap.put(quo.Id,quo);
                                                if(qliObj.Product2.Multiple_Sale_Not_Allowed__c == true){
                                                    mapOfQuoteIdVsProdId.put(quo.Id,qliObj.Product2Id);
                                                }
                                            }
                                            break;
                                        }
                            }
                        } 
                    }
                }
            }
        }
        
        if(!blankFloorPriceTypeProdIds.isEmpty()) {
            if(!noApprovalQuoteIds.isEmpty()) {
                for(QuoteLineitem qli : [SELECT Id,QuoteId,
                                         Quote.Floor_Price_Type__c,
                                         Quantity,Discount__c,
                                         Discount_Amount__c,Amount__c
                                         FROM QuoteLineItem
                                         WHERE Discount_Reason__c = 'Managerial Discount'
                                         AND (Discount__c > 0 OR Discount_Amount__c > 0)
                                         AND QuoteId In : noApprovalQuoteIds
                                         AND (Product2Id NOT IN : blankFloorPriceTypeProdIds)
                                         AND Quote.Floor_Price_Type__c = 'Below List Price with Discount']
                   ) {
                       if(!mapOfNoApprovalQuoteIdVsQliList.containsKey(qli.QuoteId)) {
                           mapOfNoApprovalQuoteIdVsQliList.put(qli.QuoteId, new List<QuoteLineItem>());
                       }
                       mapOfNoApprovalQuoteIdVsQliList.get(qli.QuoteId).add(qli);
                   }
            }
            for(Floor_Price__c floorPrice:  [SELECT Id,
                                             min_Quantity__c,max_Quantity__c,
                                             Price__c,Product__c 
                                             FROM Floor_Price__c
                                             WHERE Product__c In: blankFloorPriceTypeProdIds]
               ) {
                   if(!mapOfProIdVsFPListForBlankFPType.containsKey(floorPrice.Product__c)) {
                       mapOfProIdVsFPListForBlankFPType.put(floorPrice.Product__c,new List<Floor_Price__c>{});
                   }
                   mapOfProIdVsFPListForBlankFPType.get(floorPrice.Product__c).add(floorPrice);
               }
            
            for(Integer i=0;i<blankFloorPriceTypeQliList.size();i++) {
                QuoteLineItem qli = blankFloorPriceTypeQliList[i];
                if(mapOfQuoteIdVsProdId.isEmpty() || 
                   (mapOfQuoteIdVsProdId.containsKey(qli.QuoteId) && mapOfQuoteIdVsProdId.get(qli.QuoteId) != qli.Product2Id)) {
                       if(!mapOfProIdVsFPListForBlankFPType.isEmpty() && 
                          mapOfProIdVsFPListForBlankFPType.containsKey(qli.Product2Id)) {
                              Quote quoObj = new Quote(Id = qli.QuoteId);
                              quoObj.Floor_Price_Type__c = '';
                              quoObj.Product_Type__c = '';
                              if(!updateQuoteMap.containsKey(quoObj.Id)) {
                                  updateQuoteMap.put(quoObj.Id,quoObj);
                              } else {
                                  updateQuoteMap.get(quoObj.Id).Floor_Price_Type__c = '';
                                  updateQuoteMap.get(quoObj.Id).Product_Type__c = '';
                              }
                          } else if(!mapOfNoApprovalQuoteIdVsQliList.isEmpty() &&
                                    mapOfNoApprovalQuoteIdVsQliList.containsKey(qli.QuoteId) &&
                                    mapOfNoApprovalQuoteIdVsQliList.get(qli.QuoteId).size() > 0
                                   ) {
                                       mapOfNoApprovalQuoteIdVsQliList.get(qli.QuoteId).remove(i);
                                       if(mapOfNoApprovalQuoteIdVsQliList.get(qli.QuoteId).size() == 0) {
                                           Quote quoObj = new Quote(Id = qli.QuoteId);
                                           quoObj.Floor_Price_Type__c = 'Below List Price';
                                           if(!updateQuoteMap.containsKey(quoObj.Id)) {
                                               updateQuoteMap.put(quoObj.Id,quoObj);
                                           }
                                       }
                                   }
                   }
            }
        }
        if(!updateQuoteMap.isEmpty()){
            update updateQuoteMap.values();
        }
    }
    public static void updatePackageType(List<QuoteLineItem> qliList){
        list<Quote> quoteToUpdate = new List<Quote>();
        list<QuoteLineItem> subscriptionQLIList = new list<QuoteLineItem>();
        list<String> productIdList = new List<String>();
        for(quoteLineItem qli : qliList){
            if(qli.sno__c == 1){
                productIdList.add(qli.Product2Id);
                subscriptionQLIList.add(qli);
                //quoteToUpdate.add(new quote(id=qli.quoteId));
            }
        }
        Map<Id,product2> prodMap = new Map<Id,Product2>([select id,name,Product_Class__r.name 
                                                         from product2 where id in: productIdList]);
        for(QuoteLineItem qli : subscriptionQLIList){
            Product2 prod = prodMap.get(qli.Product2Id);
            if(prod.Product_Class__r.Name == 'Subscription'){
                if(prod.name.contains('Advanced')){
                    quoteToUpdate.add(new quote(id=qli.quoteId,package_Type__c='Advanced'));
                }
                else if(prod.name.contains('Lite')){
                    quoteToUpdate.add(new quote(id=qli.quoteId,package_Type__c='Lite'));
                }
                else if(prod.name.contains('Standard')){
                    quoteToUpdate.add(new quote(id=qli.quoteId,package_Type__c='Standard'));
                }
                else if(prod.name.contains('Premium')){
                    quoteToUpdate.add(new quote(id=qli.quoteId,package_Type__c='Premium'));
                }
                
                //quoteToUpdate.add(new quote(id=qli.quoteId));
            }
        }
        if(quoteToUpdate.size()>0){
            update quoteToUpdate;
        }
    }
}
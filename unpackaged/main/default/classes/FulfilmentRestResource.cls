@RestResource(urlMapping='/orders/*')
global class FulfilmentRestResource {
    
    @HttpGet
    global static void getFulfilment(){
        
        String recordId = RestContext.request.params.get('id');
        String offsetStr = RestContext.request.params.get('offset');
        String pageSizeStr = RestContext.request.params.get('page_size');
        String updatedSince = RestContext.request.params.get('updated_since');
        String previousOrderNumber = RestContext.request.params.get('last_order_number');
        String accountId = RestContext.request.params.get('rea_id');
        String provisionedStr = RestContext.request.params.get('provisioned');
        boolean provisioned = false;
        Boolean singleRecordMode = false;
        Integer offsetNumber = 0;
        Integer pageSizeNumber = 200;
        Integer DEFAULTPAGESIZE = 200;
        String orderByField = 'Name';
        String nextlink;
        
        if (recordId != null && recordId != '') {
            singleRecordMode = true;
        }
        if (offsetStr != null && offsetStr.isNumeric()) {
            offsetNumber = Integer.valueOf(offsetStr);
        }
        if (pageSizeStr != null && pageSizeStr.isNumeric()) {
            pageSizeNumber = Integer.valueOf(pageSizeStr) > DEFAULTPAGESIZE
                ? DEFAULTPAGESIZE
                : Integer.valueOf(pageSizeStr);
        }
        if (
            provisionedStr != null && Boolean.valueOf(provisionedStr.toLowerCase())
        ) {
            provisioned = true;
        }
        
        String fulfilmentQueryStr = 'Select id,Name,Sales_Order__c,Sales_Order__r.Name,Sales_Order__r.Billing_schedule__c,Sales_Order__r.ERP_External_ID__c,Sales_Order__r.SO_Start_Date__c,csdf__Name__c,Sales_Order__r.csmso__Opportunity__r.CurrencyIsoCode,'+
            'Sales_Order__r.csmso__Opportunity__r.Amount,'+
            'Sales_Order__r.csmso__Opportunity__r.Customer_PO__c,'+
            'Sales_Order__r.csmso__Opportunity__r.Remarks__c,'+
            'Sales_Order__r.csmso__Opportunity__r.Recordtype.DeveloperName,'+
            'Sales_Order__r.csmso__Opportunity__r.OwnerId,'+
            'Sales_Order__r.csmso__Opportunity__r.NetSuite_Contract_Id__c,'+
            'Sales_Order__r.csmso__Opportunity__r.Account.Name,'+
            'Sales_Order__r.csmso__Opportunity__r.Account.NetSuite_Id__c,'+
            'Sales_Order__r.csmso__Opportunity__r.Account.IsPersonAccount ,'+
            'Sales_Order__r.csmso__Opportunity__r.Owner.email,'+
            'Sales_Order__r.csmso__Opportunity__r.Billing_Entity__c,'+
            'Sales_Order__r.csmso__Opportunity__r.Billing_Address__r.Name,'+
            'Sales_Order__r.csmso__Opportunity__r.Billing_Address__r.BillingCountry__c,'+
            'Sales_Order__r.csmso__Opportunity__r.Billing_Address__r.Billing_State__c,'+
            'Sales_Order__r.csmso__Opportunity__r.Billing_Address__r.Billing_City__c,'+
            'Sales_Order__r.csmso__Opportunity__r.Billing_Address__r.Billing_Postal_Code__c,'+
            'Sales_Order__r.csmso__Opportunity__r.Billing_Entity__r.Name,'+
            'Sales_Order__r.csmso__Opportunity__r.b2b_Billing_Contact__r.Name,'+
            'Sales_Order__r.csmso__Opportunity__r.b2b_Billing_Contact__r.Phone,'+
            'Sales_Order__r.csmso__Opportunity__r.Account.B2B_ipp_REA__c,'+
            'Sales_Order__r.NetSuite_Payment_Term__r.Name,'+
            '(Select id, Name, csdf__Billing_Category__c,Description__c,csdf__Flight_Beginning__c,Product_Configuration__r.Net_Rate_Final__c,Rate_Card_Item_Price__c ,Product_Configuration__r.Net_Cost__c,'+
            'Product_Configuration__r.cscfga__originating_offer__r.name, Product_Configuration__r.cscfga__originating_offer__r.Offer_code__c,Product_Configuration__r.cscfga__package_guid__c,Product_Configuration__r.cscfga__one_off_charge_line_discount_value__c,Product_Configuration__r.Net_Rate__c,Insertion_Quantity__c ,csdf__Flight_End__c, Actual_Start_Date__c, Actual_End_Date__c, csdf__Rate__c,csdf__Quantity__c,Product_Configuration__r.Id,Total_Price__c,Total_Value_Per_Line_before_discount__c,csdf__Status__c ,Status_Manual_Tracking__c  from csdf__Fulfilment_Items__r),'+
            'Sales_Order__r.csmso__Opportunity__r.Subsidiary__r.Name From csdf__Fulfilment__c';
        
        if (singleRecordMode) {
            fulfilmentQueryStr += ' Where Sales_Order__c = :recordId';
        }else{
            
            if (updatedSince != null||accountId != null||provisioned||previousOrderNumber!=null){
                fulfilmentQueryStr += ' Where ';
                
                if (updatedSince != null) {
                    fulfilmentQueryStr += 'LastModifiedDate >= ' + updatedSince + '';
                }
                
                //if an REA ID account value is provided, only return rows pertaining to that account
                if (accountId != null) {
                    if (updatedSince != null){
                        fulfilmentQueryStr +=' AND ';  
                    }
                    fulfilmentQueryStr += ' Sales_Order__r.csmso__Opportunity__r.Account.B2B_ipp_REA__c = :accountId ';
                }
                
                //if provisioned flag is true, only return rows with an external id indicating netsuite sync
                if (provisioned) {
                    if (updatedSince != null||accountId != null){
                        fulfilmentQueryStr +=' AND ';  
                    }
                    fulfilmentQueryStr += ' Sales_Order__r.csmso__Opportunity__r.Account.NetSuite_Id__c != null ';
                }
                if (previousOrderNumber != null) {
                    if (updatedSince != null||accountId != null||provisioned){
                        fulfilmentQueryStr +=' AND ';  
                    }
                    fulfilmentQueryStr +=
                        orderByField +
                        ' > \'' +
                        previousOrderNumber +
                        '\' ';
                }
            }
            
            fulfilmentQueryStr +=
                ' Order by ' +
                orderByField +
                ' Limit :pageSizeNumber Offset :offsetNumber';
            
            
            String resourceName = 'orders';
            nextLink =
                '/services/apexrest/' +
                resourceName +
                '?page_size=' +
                pageSizeNumber;
            
            if (updatedSince != null) {
                nextLink += '&updated_since=' + updatedSince;
            }
            
            if (accountId != null) {
                nextLink += '&rea_id=' + accountId;
            }
            
            if (provisioned) {
                nextLink += '&provisioned=true';
            }
        } 
        
        system.debug(fulfilmentQueryStr);
        list<sObject> records = Database.query(fulfilmentQueryStr);
        
        List<csdf__Fulfilment__c> fulfilmentList = (List<csdf__Fulfilment__c>) records;
        
        Map<id,csdf__Fulfilment_Item__c> Mapfli = new Map<id,csdf__Fulfilment_Item__c>([ Select id, Rate_Card_Item_Price__c ,csdf__Billing_Category__c ,Product_Configuration__r.Net_Cost__c,Product_Configuration__r.cscfga__package_guid__c, Name, Description__c, Actual_Start_Date__c, 
                                                                                        Actual_End_Date__c, csdf__Rate__c,csdf__Quantity__c,Insertion_Quantity__c ,Product_Configuration__r.cscfga__one_off_charge_line_discount_value__c,
                                                                                        Product_Configuration__c,Total_Price__c,csdf__Fulfilment__c,Product_Configuration__r.Net_Rate_Final__c,
                                                                                        Total_Value_Per_Line_before_discount__c,Product_Configuration__r.Net_Rate__c,
                                                                                        (Select id,Name, ipp_Payment_Terms__c,Billing_Date__c,Billing_Amount__c From Billing_Schedules_new5__r),
                                                                                        Product_Configuration__r.Digital_Product__c   ,Product_Configuration__r.cscfga__originating_offer__r.Offer_code__c                     
                                                                                        from csdf__Fulfilment_Item__c
                                                                                        WHERE csdf__Fulfilment__c IN :fulfilmentList]);
        
        System.debug('---'+fulfilmentList.size());
        
        /*   String billingScheduleStr = 'select Id, Name,Sales_Order__c,Billing_Period_Start_Date__c, Fulfilment_Item__c,createddate, ipp_Payment_Terms__c,Billing_Amount__c,Billing_Date__c from CS_Billing_Schedule_Item__c';
if (singleRecordMode) {
billingScheduleStr += ' Where Sales_Order__c = :recordId';
}

system.debug(billingScheduleStr);
list<sObject> BSrecords = Database.query(billingScheduleStr);

List<CS_Billing_Schedule_Item__c> fulfilmentList = (List<CS_Billing_Schedule_Item__c>) records;*/
        
        list<CS_Billing_Schedule_Item__c> billingSchedulelist = new list<CS_Billing_Schedule_Item__c>([select Id, Name,Sales_Order__c,Billing_Period_Start_Date__c, Fulfilment_Item__c,createddate, ipp_Payment_Terms__c,Billing_Amount__c,Billing_Date__c from CS_Billing_Schedule_Item__c where Sales_Order__c = :recordId ]);
        Map<id,list<CS_Billing_Schedule_Item__c>> SOtoBillScheduleMap = new Map<id,list<CS_Billing_Schedule_Item__c>>();
        SOtoBillScheduleMap.put(recordId,billingSchedulelist);
        
        Map<String, list<wrapperbillingSchedule>> packageIDVSBS = new Map<String, list<wrapperbillingSchedule>>();
        Map<String, String> packageIDvsCode = new Map<String, String>();
        Map<String, String> packageIDvsNameDesc = new Map<String, String>();
        list<wrapperFulfilment> wrapperList = new list<wrapperFulfilment>();
        Set<id> ProConId = new Set<id>();
        
        Map<id, OpportunityLineItem> MapProductConToOli = new Map<id, OpportunityLineItem>();
        Map<id, Id> OliVsProductCon = new Map<id, Id>();
        
        
        for(ID objid: Mapfli.keySet()){
            if(Mapfli.get(objid).Product_Configuration__c != null)
                ProConId.add(Mapfli.get(objid).Product_Configuration__c);
            
        }
        
        Map<id,cscfga__Product_Configuration__c> ProductConfiMap = new Map<id,cscfga__Product_Configuration__c>([Select id,Name,Digital_Product__r.Product_Code__c,Digital_Product__r.Product_Info__c,Digital_Product__r.name,Digital_Product__r.description__c From cscfga__Product_Configuration__c
                                                                                                                 Where id IN:ProConId]);
        
        Set<Id> productIds = new Set<Id>();
        Set<id> cpId = new Set<id>();
        for(OpportunityLineItem oli: [Select id, Name,Parent__c,Product2.SKU_Code__c,SNo__c,Product2Id,Product_Configuration__c,Is_Bundle__c,Amount__c,End_Date__c,
                                      GST_VAT_Code__r.Tax_Rate__c,GST_VAT_Code__r.Name,Commercial_Product__c From OpportunityLineItem Where Product_Configuration__c IN:ProConId]){
                                          productIds.add(oli.Product2Id);
                                          MapProductConToOli.put(oli.Product_Configuration__c,oli); 
                                          OliVsProductCon.put(oli.id,oli.Product_Configuration__c);
                                          cpId.add(oli.Commercial_Product__c);
                                      }
        
        Map<id,cspmb__Price_Item__c> cpMap = new Map<id,cspmb__Price_Item__c>([Select id, Name, Line_Description__c,cspmb__Price_Item_Code__c From cspmb__Price_Item__c Where id IN: cpId]);
        
        Boolean flag=true;
        for(csdf__Fulfilment__c fulfil: fulfilmentList){
            
            System.debug('%%%Child record'+fulfil.csdf__Fulfilment_Items__r.size());
            
            wrapperFulfilment objfulfil = new wrapperFulfilment();
            
            wrapperCustomer objcustomer = new wrapperCustomer();
            wrapperbillAddress objbillAdd = new wrapperbillAddress();
            list<wrapperbillingSchedule> billSchedulelist = new list<wrapperbillingSchedule>();
            list<list<wrapperbillingSchedule>> recurrrence = new list<list<wrapperbillingSchedule>>();
            wrapbillingSchedule bill = new wrapbillingSchedule();
            
            // Fulfilment wrapper
            objfulfil.totalAmount = fulfil.Sales_Order__r.csmso__Opportunity__r.Amount;
            objfulfil.startDate = fulfil.Sales_Order__r.SO_Start_Date__c;
            objfulfil.sellingSubsidiaryId = fulfil.Sales_Order__r.csmso__Opportunity__r.Subsidiary__c;
            objfulfil.salesPerson = fulfil.Sales_Order__r.csmso__Opportunity__r.Owner.email;
            objfulfil.salesForceId = fulfil.Sales_Order__c;
            objfulfil.quoteNumber = fulfil.Sales_Order__r.Name;
            objfulfil.externalId = fulfil.Sales_Order__r.ERP_External_ID__c;
            objfulfil.customerPoNumber = fulfil.Sales_Order__r.csmso__Opportunity__r.Customer_PO__c;
            objfulfil.currencyIsoCode = fulfil.Sales_Order__r.csmso__Opportunity__r.CurrencyIsoCode;
            objfulfil.terms = fulfil.Sales_Order__r.NetSuite_Payment_Term__r.Name;
            
            list<wrapperfulfilmentlineitem> listItem = new list<wrapperfulfilmentlineitem>(); 
            
            for(csdf__Fulfilment_Item__c item: fulfil.csdf__Fulfilment_Items__r){
                
                wrapperfulfilmentlineitem fulfilItem = new wrapperfulfilmentlineitem();
                // wrapperbillingSchedule billSchedule = new wrapperbillingSchedule();
                wrapbillingSchedule billToSchedule = new wrapbillingSchedule();
                Decimal num;
                
                // FulfilmentItem wrapper
                fulfilItem.Name = item.Name;
                if(item.csdf__Status__c == 'Delivering' || item.csdf__Status__c =='Completed'  || 
                   item.Status_Manual_Tracking__c  == 'Delivering' || item.Status_Manual_Tracking__c  =='Completed' ){
                       fulfilItem.startDate = item.Actual_Start_Date__c!=null?item.Actual_Start_Date__c:item.csdf__Flight_Beginning__c.date();
                       fulfilItem.endDate = item.Actual_End_Date__c!=null ?item.Actual_End_Date__c:item.csdf__Flight_End__c.date() ;
                       
                   }else{
                       fulfilItem.startDate = item.Actual_Start_Date__c!=null?item.Actual_Start_Date__c.addYears(1):item.csdf__Flight_Beginning__c.date().addYears(1);
                       fulfilItem.endDate = item.Actual_End_Date__c!=null ?item.Actual_End_Date__c.addYears(1):item.csdf__Flight_End__c.date().addYears(1);
                   }
                //fulfilItem.endDate = item.Actual_End_Date__c!=null ?item.Actual_End_Date__c:item.csdf__Flight_End__c.date() ;
                /*system.debug( item.Product_Configuration__r.Net_Rate_Final__c);
                  system.debug( item.Product_Configuration__r.Net_Cost__c);
                  system.debug( item.Product_Configuration__r.Net_Rate__c);
                if(item.Product_Configuration__r.Net_Rate_Final__c != null && item.Product_Configuration__r.Net_Rate_Final__c!=0){
                    fulfilItem.rate = item.Product_Configuration__r.Net_Rate_Final__c;
                }else if(item.Product_Configuration__r.Net_Cost__c != null && item.Product_Configuration__r.Net_Cost__c != 0){
                      fulfilItem.rate = item.Product_Configuration__r.Net_Cost__c;
                } else*/
                
                    fulfilItem.rate = item.Rate_Card_Item_Price__c ;
                system.debug('%%%'+fulfilItem.rate );
                
                if( item.Insertion_Quantity__c != null && item.Insertion_Quantity__c != 0){
                    if(item.csdf__Billing_Category__c == 'CPM'){
                        fulfilItem.quantity = item.Insertion_Quantity__c/1000;
                    }else
                        fulfilItem.quantity = item.Insertion_Quantity__c;
                }else{
                    if(item.csdf__Billing_Category__c == 'CPM'){
                        fulfilItem.quantity = item.csdf__Quantity__c/1000;
                    }else
                        fulfilItem.quantity = item.csdf__Quantity__c;
                }
                   // fulfilItem.quantity = item.csdf__Quantity__c;
                fulfilItem.salesforceLineId = item.id; 
                fulfilItem.supplyingSubsidiary = fulfil.Sales_Order__r.csmso__Opportunity__r.Subsidiary__c; 
                // fulfilItem.description = (MapProductConToOli.containskey(item.Product_Configuration__r.Id) && MapProductConToOli.get(item.Product_Configuration__r.Id).Commercial_Product__c != null)  ? cpMap.get(MapProductConToOli.get(item.Product_Configuration__r.Id).Commercial_Product__c).Name+ ' ' + cpMap.get(MapProductConToOli.get(item.Product_Configuration__r.Id).Commercial_Product__c).Line_Description__c : null;
                fulfilItem.salesforceBundleId = item.Product_Configuration__r.cscfga__package_guid__c;
                
                if(item.Product_Configuration__r.cscfga__package_guid__c != null){
                    system.debug('!!!! '+item.Product_Configuration__r.cscfga__package_guid__c);
                    system.debug('!!!! in if '+packageIDVSBS); 
                    system.debug(!packageIDVSBS.containsKey(item.Product_Configuration__r.cscfga__package_guid__c));
                    if(!packageIDVSBS.containsKey(item.Product_Configuration__r.cscfga__package_guid__c)){
                        packageIDVSBS.put(item.Product_Configuration__r.cscfga__package_guid__c,null);
                        packageIDvsCode.put(item.Product_Configuration__r.cscfga__package_guid__c,item.Product_Configuration__r.cscfga__originating_offer__r.offer_code__c);
                       packageIDvsNameDesc.put(item.Product_Configuration__r.cscfga__package_guid__c,item.Product_Configuration__r.cscfga__originating_offer__r.name );
                        system.debug('!!!! in if '+packageIDVSBS); 
                    } 
                    
                }
                // system.debug('!!!! '+packageIDVSBS); 
                fulfilItem.description = (MapProductConToOli.containskey(item.Product_Configuration__r.Id) && MapProductConToOli.get(item.Product_Configuration__r.Id).Commercial_Product__c != null )  ? cpMap.get(MapProductConToOli.get(item.Product_Configuration__r.Id).Commercial_Product__c).Name+ ' ' + cpMap.get(MapProductConToOli.get(item.Product_Configuration__r.Id).Commercial_Product__c).Line_Description__c : 
                (ProductConfiMap.containskey(item.Product_Configuration__r.Id) && ProductConfiMap.get(item.Product_Configuration__r.Id)!=null) ? ProductConfiMap.get(item.Product_Configuration__r.Id).Digital_Product__r.name +'\n\n'+ProductConfiMap.get(item.Product_Configuration__r.Id).Digital_Product__r.Product_Info__c : null ;                     
             fulfilItem.description = fulfilItem.description.replace('null','');
                if(item.csdf__Billing_Category__c == 'cpm'){
                     fulfilItem.discountAmount = (item.Total_Value_Per_Line_before_discount__c/1000) - item.Total_Price__c;
                    if( fulfilItem.discountAmount == null ||  fulfilItem.discountAmount == 0){
                        fulfilItem.discountAmount = (item.Product_Configuration__r.cscfga__one_off_charge_line_discount_value__c)/1000;
                    }
                }else {
                    fulfilItem.discountAmount = item.Total_Value_Per_Line_before_discount__c - item.Total_Price__c;
                    if( fulfilItem.discountAmount == null ||  fulfilItem.discountAmount == 0){
                        fulfilItem.discountAmount = item.Product_Configuration__r.cscfga__one_off_charge_line_discount_value__c;
                    }
                }
                fulfilItem.isBundle = MapProductConToOli.containskey(item.Product_Configuration__r.Id) ? MapProductConToOli.get(item.Product_Configuration__r.Id).Is_Bundle__c : null;
                if(item.Product_Configuration__r.cscfga__package_guid__c !=null)
                    fulfilItem.isbundled = true;
                else
                    fulfilItem.isbundled = false;
                
                system.debug('The ****'+MapProductConToOli);
                fulfilItem.totalAmount = MapProductConToOli.containskey(item.Product_Configuration__r.Id)  ? MapProductConToOli.get(item.Product_Configuration__r.Id).Amount__c : null;
                fulfilItem.item = (MapProductConToOli.containskey(item.Product_Configuration__r.Id) && MapProductConToOli.get(item.Product_Configuration__r.Id).Commercial_Product__c != null )  ? cpMap.get(MapProductConToOli.get(item.Product_Configuration__r.Id).Commercial_Product__c).cspmb__Price_Item_Code__c : 
                (ProductConfiMap.containskey(item.Product_Configuration__r.Id) && ProductConfiMap.get(item.Product_Configuration__r.Id)!=null) ? ProductConfiMap.get(item.Product_Configuration__r.Id).Digital_Product__r.Product_Code__c : null ;
                //  fulfilItem.item = ProductConfiMap.get(item.Product_Configuration__r.Id).Digital_Product__r.Product_Code__c;
                fulfilItem.taxRate = MapProductConToOli.containskey(item.Product_Configuration__r.Id)  ? MapProductConToOli.get(item.Product_Configuration__r.Id).GST_VAT_Code__r.Tax_Rate__c : null;
                fulfilItem.taxCode = MapProductConToOli.containskey(item.Product_Configuration__r.Id)  ? MapProductConToOli.get(item.Product_Configuration__r.Id).GST_VAT_Code__r.Name : null;
                num = MapProductConToOli.containskey(item.Product_Configuration__r.Id)  ? MapProductConToOli.get(item.Product_Configuration__r.Id).SNo__c : null;
                
                
              
                system.debug( Mapfli.get(item.Id).Billing_Schedules_new5__r.size()>0 );
                system.debug(num);
                if(fulfil.Sales_Order__r.Billing_schedule__c == 'Bill by item' 
                   && Mapfli.get(item.Id).Billing_Schedules_new5__r.size()>0 ){
                       wrapperbillingSchedule billSchedule = new wrapperbillingSchedule();
                       billSchedule.terms = Mapfli.get(item.Id).Billing_Schedules_new5__r[0]. ipp_Payment_Terms__c;
                       billSchedule.issueDate = Mapfli.get(item.Id).Billing_Schedules_new5__r[0].Billing_Date__c;
                       billSchedule.amount = Mapfli.get(item.Id).Billing_Schedules_new5__r[0].Billing_Amount__c;
                       system.debug('&&&^& before'+packageIDVSBS);
                       
                       // when BundleId is no null.
                       if(item.Product_Configuration__r.cscfga__package_guid__c !=null){
                           List<wrapperbillingSchedule> temp = new List<wrapperbillingSchedule>();
                           if(packageIDVSBS.containsKey(item.Product_Configuration__r.cscfga__package_guid__c)){
                               //   system.debug()
                               if(packageIDVSBS.get(item.Product_Configuration__r.cscfga__package_guid__c)!=null)
                                   temp = packageIDVSBS.get(item.Product_Configuration__r.cscfga__package_guid__c);
                               temp.add(billSchedule);
                               packageIDVSBS.put(item.Product_Configuration__r.cscfga__package_guid__c,temp);
                           }
                           
                           else{
                               //  List<wrapperbillingSchedule> temp = new  List<wrapperbillingSchedule>();
                               temp.add(billSchedule);
                               packageIDVSBS.put(item.Product_Configuration__r.cscfga__package_guid__c,temp);
                               
                           }
                           system.debug('&&&^&'+packageIDVSBS);
                       }
                       else{
                           billToSchedule.recurrence.add(billSchedule);
                           fulfilItem.billingSchedule = billToSchedule;
                           
                       }
                       flag=false;
                   }
                else{
                    
                }
                
                
                listItem.add(fulfilItem);
                
            }
            // wrapperbillingSchedule billSchedule = new wrapperbillingSchedule();
            // to create parent dummy records
            for(String packageID: packageIDVSBS.keySet()){
                wrapperfulfilmentlineitem fulfilItem = new wrapperfulfilmentlineitem();
                
                wrapbillingSchedule billToSchedule = new wrapbillingSchedule();
                
                fulfilItem.salesforceLineId = packageID; 
                fulfilItem.supplyingSubsidiary = fulfil.Sales_Order__r.csmso__Opportunity__r.Subsidiary__c; 
                fulfilItem.description = packageIDvsNameDesc.get(packageID);
                fulfilItem.salesforceBundleId = null;
                fulfilItem.isBundle = true;
          
                    fulfilItem.isbundled = false;
                fulfilItem.item = packageIDvsCode.get(packageID);
                if(packageIDVSBS.get(packageID)!= null ){
                    Decimal totalAmt = 0;
                    Date earliestDate;
                    String terms;
                    for(wrapperbillingSchedule wbs : packageIDVSBS.get(packageID)){
                        terms = wbs.terms;
                        totalAmt += wbs.amount;
                        if(earliestDate == null){
                            earliestDate = wbs.issueDate;
                        }
                        else{
                            Date fliDate;
                            if(wbs.issueDate != null)
                                fliDate = wbs.issueDate;
                            if(earliestDate > fliDate){
                                earliestDate = fliDate;
                            }
                        }
                    }
                    wrapperbillingSchedule bs = new wrapperbillingSchedule();
                    bs.issueDate = earliestDate;
                    bs.amount = totalAmt;
                    bs.terms = terms;
                    List<wrapperbillingSchedule> bsList = new List<wrapperbillingSchedule>();
                    bsList.add(bs);
                    billToSchedule.recurrence.addall(bsList);
                    fulfilItem.billingSchedule = billToSchedule;
                }
                listItem.add(fulfilItem);
            }
            // list of items wrapper
            objfulfil.items = (fulfil.csdf__Fulfilment_Items__r.size() != 0) ? listItem : null;
            
            //customer wrapper 
            objcustomer.name = fulfil.Sales_Order__r.csmso__Opportunity__r.Account.Name;
            // objcustomer.reaId = fulfil.Sales_Order__r.csmso__Opportunity__r.Account.B2B_ipp_REA__c;
            objcustomer.billingEntityId = fulfil.Sales_Order__r.csmso__Opportunity__r.Accountid;
            objcustomer.type = (fulfil.Sales_Order__r.csmso__Opportunity__r.Account.IsPersonAccount != false) ? 'Person Account' : 'Business' ;
            objfulfil.customer = objcustomer;
            
            //billAddress wrapper 
            objbillAdd.address1 = fulfil.Sales_Order__r.csmso__Opportunity__r.Billing_Address__r.Name;
            objbillAdd.addressee = fulfil.Sales_Order__r.csmso__Opportunity__r.Billing_Entity__r.Name;
            objbillAdd.country = fulfil.Sales_Order__r.csmso__Opportunity__r.Billing_Address__r.BillingCountry__c;
            objbillAdd.city = fulfil.Sales_Order__r.csmso__Opportunity__r.Billing_Address__r.Billing_City__c;
            objbillAdd.state = fulfil.Sales_Order__r.csmso__Opportunity__r.Billing_Address__r.Billing_State__c  ;
            objbillAdd.zip = fulfil.Sales_Order__r.csmso__Opportunity__r.Billing_Address__r.Billing_Postal_Code__c;
            system.debug(fulfil.Sales_Order__r.csmso__Opportunity__r.b2b_Billing_Contact__r.Name);
            objbillAdd.attention = fulfil.Sales_Order__r.csmso__Opportunity__r.b2b_Billing_Contact__r.Name;
            objbillAdd.phone = fulfil.Sales_Order__r.csmso__Opportunity__r.b2b_Billing_Contact__r.phone;
            objfulfil.billAddress = objbillAdd;
            
            // objfulfil.generalbillingSchedule = billSchedulelist;
            if(flag){
                for(CS_Billing_Schedule_Item__c bs: SOtoBillScheduleMap.get(recordId)){
                    wrapperbillingSchedule billSchedule1 = new wrapperbillingSchedule();
                    
                    billSchedule1.terms = bs.ipp_Payment_Terms__c;
                    billSchedule1.issueDate = bs.Billing_Date__c;
                    billSchedule1.amount = bs.Billing_Amount__c;
                    
                    billSchedulelist.add(billSchedule1);
                }
            }
            if(billSchedulelist.size()>0){
                //    bill.recurrence = new list<>();
                bill.recurrence.addall(billSchedulelist);   
            }
            
            
            objfulfil.billingSchedule = (fulfil.csdf__Fulfilment_Items__r.size()==0 || fulfil.Sales_Order__r.Billing_schedule__c == 'Bill by item') ? null : bill;
            
            
            wrapperList.add(objfulfil);
            
        }
        wrapperResponse res = new wrapperResponse();
        res.details = wrapperList;
        res.next = nextLink;
        try {
            if (wrapperList.isEmpty()) {
                returnError(
                    '400',
                    'EMPTY_RECORD',
                    'No records were found. Please contact a SPOT Administrator.'
                );
            } else {
                system.debug(wrapperList);
                RestContext.response.responseBody = Blob.valueOf(
                    JSON.serialize(res)
                );
            }
        } catch (Exception e) {
            returnError('400', 'UNKNOWN_EXCEPTION', e.getMessage());
        }
        
    }
    public static void returnError(String statusCode, String errorCode, String errorMessage){
        RestContext.response.statusCode = Integer.valueOf(statusCode);
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new APIErrorOutput(errorCode, errorMessage)));
    } 
    public class APIErrorOutput{
        public String errorCode;
        public String errorMessage;
        
        public APIErrorOutput(String code, String message){
            errorCode = code;
            errorMessage = message;
        }
    }
    public static void childProducts(){
        
    }
    global class wrapperResponse{
        list<wrapperFulfilment> details = new list<wrapperFulfilment>();
        String next;
    }
    global class wrapperFulfilment{
        
        global Decimal totalAmount {get;set;}
        global Date startDate {get;set;}
        global String sellingSubsidiaryId {get;set;}
        global String salesPerson {get;set;}
        global String salesForceId {get;set;}
        global String quoteNumber {get;set;}
        global String lineOfBusiness {get;set;}
        global String externalId {get;set;}
        global String customerPoNumber {get;set;}
        global String currencyIsoCode {get;set;}
        global String terms {get;set;}
        
        global list<wrapperfulfilmentlineitem> items {get;set;}
        global wrapperCustomer customer {get;set;}
        global wrapperbillAddress billAddress {get;set;}
        global wrapbillingSchedule billingSchedule {get;set;}
        
        global wrapperFulfilment(){
            this.totalAmount = null;
            this.startDate = null;
            this.sellingSubsidiaryId = null;
            this.salesPerson = null;
            this.salesForceId = null;
            this.quoteNumber = null;
            this.lineOfBusiness = 'DEVELOPER';
            this.externalId = null;
            this.customerPoNumber = null;
            this.CurrencyIsoCode = null;
            this.billAddress = null;
            this.items = null;
            this.customer = null;
            
        }
    }
    
    global class wrapperfulfilmentlineitem{
        
        global String name {get;set;}
        global Date  endDate {get;set;}
        global Date startDate {get;set;}
        global String salesforceLineId {get;set;}
        global String supplyingSubsidiary {get;set;}
        global Decimal rate {get;set;}
        global Decimal quantity {get;set;}
        global String description {get;set;}
        global Boolean isBundle {get;set;}
        global Boolean isBundled {get;set;}
        global Decimal totalAmount {get;set;}
        global String item {get;set;}
        global Decimal discountAmount {get;set;}
        global Decimal taxRate {get;set;}
        global String taxCode {get;set;}
        global String salesforceBundleId {get;set;}
        global wrapbillingSchedule billingSchedule {get;set;}
        
        global wrapperfulfilmentlineitem(){
            this.name = null;
            this.endDate = null;
            this.startDate = null;
            this.salesforceLineId = null;
            this.rate = null;
            this.quantity = null;
            this.description = null;
            this.isBundle = false;
            this.totalAmount = null;
            this.item = null;
            this.discountAmount = null;
            this.taxRate = null;
            this.taxCode = null;
            this.supplyingSubsidiary = null;
            this.salesforceBundleId = null;
            this.billingSchedule = null;
            
        } 
    }
    
    global class wrapperCustomer{
        
        global String name {get;set;}
        global String type {get;set;}
        global String billingEntityId {get;set;}
        
        global wrapperCustomer(){
            this.name = null;
            this.type = null;
            this.billingEntityId = null;
        }
    }
    
    global class wrapperbillAddress{
        
        global String address1 {get;set;}
        global String country {get;set;}
        global String city {get;set;}
        global String state {get;set;}
        global String zip {get;set;}
        global String attention {get;set;}
        global String phone {get;set;}
        global String addressee {get;set;}
        global wrapperbillAddress(){
            this.addressee = null;
            this.address1 = null;
            this.country = null;
            this.city = null;
            this.state = null;
            this.zip = null;
            this.attention = null;
            this.phone = null;
        }
    }
    
    global class wrapperbillingSchedule{
        
        global String terms {get;set;}
        global Date issueDate {get;set;}
        global Decimal amount {get;set;}
        
        global wrapperbillingSchedule(){
            
            this.terms = null;
            this.issueDate = null;
            this.amount = null;
        }
    }
    global class wrapbillingSchedule{
        List<wrapperbillingSchedule> recurrence = new list<wrapperbillingSchedule>();
        global wrapbillingSchedule(){   
            this.recurrence =  new list<wrapperbillingSchedule>();
            
        }
    }  
    
}
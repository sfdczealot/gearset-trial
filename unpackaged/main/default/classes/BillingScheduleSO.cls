global without sharing class BillingScheduleSO implements CSPOFA.ExecutionHandler,CSPOFA.Calloutable{
    private List<Object> calloutResults;
    global BillingScheduleSO() {
    }
    public Boolean performCallouts(List<SObject> data) {
        List<CSPOFA__Orchestration_Step__c> stepList = (List<CSPOFA__Orchestration_Step__c>)data;
        System.debug('step:::'+stepList[0].CSPOFA__Orchestration_Process__c);
        //System.debug('stepSO:::'+stepList[0].CSPOFA__Orchestration_Process__r.Sales_Order__c);
        Boolean calloutsPerformed = false;
        ///Decimal eventTotalPrice = 0;
        Decimal othersTotalPrice = 0;
        String salesOrderId = stepList[0].Sales_Order__c;
        System.debug('so:::'+salesOrderId);
        cs_Billing_schedule__c bs = new cs_Billing_schedule__c();
        CS_Sales_Order_Schedule__c sos = new CS_Sales_Order_Schedule__c();
        List<cs_Billing_schedule__c> bsList =  [select id from cs_Billing_schedule__c where Sales_Order__c = :salesOrderId];
        List<CS_Sales_Order_Schedule__c> sosList =  [select id from CS_Sales_Order_Schedule__c where Sales_Order__c = :salesOrderId];
        //Logic
        //dont execute code if SalesOrder is Sold
        
        List<csdf__Fulfilment_Item__c> allFulfilmentItems = new List<csdf__Fulfilment_Item__c>();
        List<csdf__Fulfilment_Item__c> fulfilmentItems = new List<csdf__Fulfilment_Item__c>();
        List<csdf__Fulfilment_Item__c> eventsFulfilmentItems = new List<csdf__Fulfilment_Item__c>();
        allFulfilmentItems = [SELECT Id, Product_Configuration__r.cscfga__Total_Price__c, Insertion_Quantity__c,
                              Actual_Start_date__c, csdf__Fulfilment__r.sales_order__c, csdf__Flight_Beginning__c, 
                              csdf__Fulfilment__r.sales_order__r.csmso__From__c,Total_Price__c,csdf__rate__c,
                              csdf__Fulfilment__r.sales_order__r.Product_Subsidiary__c,
                              Product_Configuration__r.cscfga__One_Off_Charge__c,
                              csdf__Fulfilment__r.sales_order__r.sold__c, csdf__Fulfilment__r.sales_order__r.Billing_Schedule__c, 
                              csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__r.Total_Amount__c, 
                              csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__c,
                              csdf__Fulfilment__r.sales_order__r.NetSuite_Payment_Term__r.Name , 
                              Product_Configuration__r.Name,csdf__Billing_Category__c
                              FROM csdf__Fulfilment_Item__c
                              WHERE csdf__Fulfilment__r.sales_order__c = :salesOrderId ];
        if(AllFulfilmentItems[0].csdf__Fulfilment__r.sales_order__r.sold__c 
           || AllFulfilmentItems[0].csdf__Fulfilment__r.sales_order__r.Product_Subsidiary__c == 'PG'){
               return true;
           }
        
        if(bsList.Size() == 0){
            if(sosList.Size() == 0){
                sos = new CS_Sales_Order_Schedule__c(Sales_Order__c = salesOrderId);
                insert sos;
            }
            else 
                sos = sosList[0];
            bs = new cs_Billing_schedule__c(Sales_Order__c = salesOrderId, CS_Sales_Order_Schedule__c = sos.Id );
            insert bs;
        } else {
            bs = bsList[0];
        }
        delete [select id from CS_Billing_Schedule_Item__c where Sales_Order__c =: salesOrderId];
        //filter events FLI
        for(csdf__Fulfilment_Item__c fi : allFulfilmentItems){
            if(fi.Product_Configuration__r.Name == 'Events'){
                eventsFulfilmentItems.add(fi);
                
            }else{
                if(fi.Product_Configuration__r.Name == 'Ad Served'){
                    if(fi.csdf__Billing_Category__c == 'CPM'){
                        othersTotalPrice += fi.csdf__Rate__c*fi.Insertion_Quantity__c/1000;
                    }else
                        othersTotalPrice += fi.csdf__Rate__c*fi.Insertion_Quantity__c;
                }
                else if(fi.Product_Configuration__r.Name == 'Developer Listings'){
                    
                    othersTotalPrice += fi.csdf__Rate__c*fi.Insertion_Quantity__c;
                }
                else if(fi.Product_Configuration__r.Name == 'Marketing Services'){
                    othersTotalPrice+= fi.Product_Configuration__r.cscfga__One_Off_Charge__c*fi.Insertion_Quantity__c;
                }
                else
                    othersTotalPrice += fi.Product_Configuration__r.cscfga__Total_Price__c*fi.Insertion_Quantity__c;
                fulfilmentItems.add(fi);
            }
            
        }
        String billingType = AllFulfilmentItems[0].csdf__Fulfilment__r.sales_order__r.Billing_Schedule__c;
        if(billingType == null ){
            return true;
        }
        
        List<CS_Billing_Schedule_Item__c> bsiList = new List<CS_Billing_Schedule_Item__c>();
        
        //  List<CS_Billing_Schedule_Item__c> updatedBsiList = new List<CS_Billing_Schedule_Item__c>();
        Decimal totalAmount=0;
        
        
        if(fulfilmentItems.size() > 0){   
            switch on billingType {
                when 'Full bill upon signing'{
                    csdf__Fulfilment_Item__c fi = fulfilmentItems[0];
                    bsiList.add(new CS_Billing_Schedule_Item__c(Opportunity__c = fi.csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__c,
                                                                Sales_Order__c = fi.csdf__Fulfilment__r.sales_order__c,
                                                                ipp_Payment_Terms__c = fi.csdf__Fulfilment__r.sales_order__r.NetSuite_Payment_Term__r.Name,
                                                                Billing_Amount__c = othersTotalPrice,
                                                                Total_Price__c = othersTotalPrice,
                                                                Billing_Date__c = System.today(), Billing_Period_Start_Date__c =  System.today(), 
                                                                Billing_Period_End_Date__c =  System.today().addMonths(1).addYears(1),
                                                                Billing_Schedule__c = bs.id));
                    totalAmount += othersTotalPrice;
                }  
                when 'Full bill upon delivery'{
                    csdf__Fulfilment_Item__c fi = fulfilmentItems[0];
                    bsiList.add(new CS_Billing_Schedule_Item__c(Opportunity__c = fi.csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__c,
                                                                Sales_Order__c = fi.csdf__Fulfilment__r.sales_order__c,
                                                                Total_Price__c = othersTotalPrice.setScale(2,System.RoundingMode.HALF_UP),
                                                                Billing_Date__c = fi.csdf__Fulfilment__r.sales_order__r.csmso__From__c.addYears(1),
                                                                Billing_Schedule__c = bs.id,
                                                                ipp_Payment_Terms__c = fi.csdf__Fulfilment__r.sales_order__r.NetSuite_Payment_Term__r.Name,
                                                                Billing_Amount__c = othersTotalPrice.setScale(2,System.RoundingMode.HALF_UP),
                                                                Billing_Period_Start_Date__c =  fi.csdf__Fulfilment__r.sales_order__r.csmso__From__c.addYears(1), 
                                                                Billing_Period_End_Date__c =  fi.csdf__Fulfilment__r.sales_order__r.csmso__From__c.addMonths(1).addYears(1)));
                    totalAmount += othersTotalPrice.setScale(2,System.RoundingMode.HALF_UP);
                }
                when 'Bill by item'{
                    for( csdf__Fulfilment_Item__c fi : fulfilmentItems){
                        Date startDate;
                        if(fi.Actual_Start_Date__c  != null){
                            startDate = fi.Actual_Start_Date__c ;
                        }
                        else 
                            startDate = date.newinstance(fi.csdf__Flight_Beginning__c.year(), fi.csdf__Flight_Beginning__c.month(), fi.csdf__Flight_Beginning__c.day());
                        Decimal rate = 0;
                        if(fi.Product_Configuration__r.Name == 'Ad Served'){
                            if(fi.csdf__Billing_Category__c == 'CPM'){
                                rate = fi.csdf__Rate__c*fi.Insertion_Quantity__c/1000;
                            }else
                                rate = fi.csdf__Rate__c*fi.Insertion_Quantity__c;
                        }
                        else if(fi.Product_Configuration__r.Name == 'Marketing Services'){
                            rate+= fi.Product_Configuration__r.cscfga__One_Off_Charge__c*fi.Insertion_Quantity__c;
                        }
                        else if(fi.Product_Configuration__r.Name == 'Developer Listings'){
                           rate = fi.csdf__Rate__c*fi.Insertion_Quantity__c;
                        }
                        else
                            rate = fi.Product_Configuration__r.cscfga__Total_Price__c*fi.Insertion_Quantity__c;
                        
                        CS_Billing_Schedule_Item__c bsi = new CS_Billing_Schedule_Item__c(Opportunity__c = fi.csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__c,
                                                                                          Sales_Order__c = fi.csdf__Fulfilment__r.sales_order__c,
                                                                                          Total_Price__c =rate,
                                                                                          Billing_Amount__c = rate,
                                                                                          Fulfilment_Item__c = fi.Id,
                                                                                          ipp_Payment_Terms__c = fi.csdf__Fulfilment__r.sales_order__r.NetSuite_Payment_Term__r.Name,
                                                                                          Billing_Date__c =  startDate.addYears(1), 
                                                                                          Billing_Schedule__c = bs.id,
                                                                                          Billing_Period_Start_Date__c =  startDate.addYears(1), 
                                                                                          Billing_Period_End_Date__c =  startDate.addMonths(1).addYears(1));
                        bsiList.add(bsi);
                        totalAmount += bsi.Total_Price__c;
                    }
                }
                when '3 months'{
                    csdf__Fulfilment_Item__c fi = fulfilmentItems[0];
                    for(integer i=1;i<4;i++){
                        CS_Billing_Schedule_Item__c bsi = new CS_Billing_Schedule_Item__c(Opportunity__c = fi.csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__c,
                                                                                          Sales_Order__c = fi.csdf__Fulfilment__r.sales_order__c,
                                                                                          Total_Price__c = (othersTotalPrice/3).setScale(2,System.RoundingMode.HALF_UP),
                                                                                          Billing_Date__c =  fi.csdf__Fulfilment__r.sales_order__r.csmso__From__c.addMonths(i-1).addYears(1), 
                                                                                          Billing_Schedule__c = bs.id,
                                                                                          ipp_Payment_Terms__c = fi.csdf__Fulfilment__r.sales_order__r.NetSuite_Payment_Term__r.Name,
                                                                                          Billing_Amount__c = (othersTotalPrice/3).setScale(2,System.RoundingMode.HALF_UP),
                                                                                          Billing_Period_Start_Date__c =  fi.csdf__Fulfilment__r.sales_order__r.csmso__From__c.addMonths(i-1).addYears(1), 
                                                                                          Billing_Period_End_Date__c =  fi.csdf__Fulfilment__r.sales_order__r.csmso__From__c.addMonths(i).addYears(1));
                        bsiList.add(bsi);
                        totalAmount += bsi.Total_Price__c;
                    }
                }
                when '6 months'{
                    csdf__Fulfilment_Item__c fi = fulfilmentItems[0];
                    for(integer i=1;i<7;i++){
                        CS_Billing_Schedule_Item__c bsi = new CS_Billing_Schedule_Item__c(Opportunity__c = fi.csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__c,
                                                                                          Sales_Order__c = fi.csdf__Fulfilment__r.sales_order__c,
                                                                                          ipp_Payment_Terms__c = fi.csdf__Fulfilment__r.sales_order__r.NetSuite_Payment_Term__r.Name,
                                                                                          Total_Price__c = (othersTotalPrice/6).setScale(2,System.RoundingMode.HALF_UP),
                                                                                          Billing_Date__c = fi.csdf__Fulfilment__r.sales_order__r.csmso__From__c.addMonths(i-1).addYears(1), 
                                                                                          Billing_Schedule__c = bs.id,
                                                                                          Billing_Amount__c = (othersTotalPrice/6).setScale(2,System.RoundingMode.HALF_UP),
                                                                                          Billing_Period_Start_Date__c =  fi.csdf__Fulfilment__r.sales_order__r.csmso__From__c.addMonths(i-1).addYears(1), 
                                                                                          Billing_Period_End_Date__c =  fi.csdf__Fulfilment__r.sales_order__r.csmso__From__c.addMonths(i).addYears(1));
                        bsiList.add(bsi);
                        totalAmount += bsi.Total_Price__c;
                    }
                }
                when '12 months'{
                    csdf__Fulfilment_Item__c fi = fulfilmentItems[0];
                    for(integer i=1;i<=12;i++){
                        CS_Billing_Schedule_Item__c bsi = new CS_Billing_Schedule_Item__c(Opportunity__c = fi.csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__c,
                                                                                          Sales_Order__c = fi.csdf__Fulfilment__r.sales_order__c,
                                                                                          Total_Price__c = (othersTotalPrice/12).setScale(2,System.RoundingMode.HALF_UP),
                                                                                          Billing_Date__c = fi.csdf__Fulfilment__r.sales_order__r.csmso__From__c.addMonths(i-1).addYears(1), 
                                                                                          Billing_Schedule__c = bs.id,
                                                                                          ipp_Payment_Terms__c = fi.csdf__Fulfilment__r.sales_order__r.NetSuite_Payment_Term__r.Name,
                                                                                          Billing_Amount__c = (othersTotalPrice/12).setScale(2,System.RoundingMode.HALF_UP),
                                                                                          Billing_Period_Start_Date__c =  fi.csdf__Fulfilment__r.sales_order__r.csmso__From__c.addMonths(i-1).addYears(1), 
                                                                                          Billing_Period_End_Date__c =  fi.csdf__Fulfilment__r.sales_order__r.csmso__From__c.addMonths(i).addYears(1));
                        bsiList.add(bsi);
                        totalAmount += bsi.Total_Price__c;
                    }
                }
                
            }
        }
        
        Decimal eventsAmount=0;
        for(csdf__Fulfilment_Item__c fi : eventsFulfilmentItems){
            eventsAmount += fi.Product_Configuration__r.cscfga__Total_Price__c; 
            Date startDate;
            if(fi.Actual_Start_Date__c  != null){
                startDate = fi.Actual_Start_Date__c ;
            }
            else 
                startDate = date.newinstance(fi.csdf__Flight_Beginning__c.year(), fi.csdf__Flight_Beginning__c.month(), fi.csdf__Flight_Beginning__c.day());
            system.debug(System.today().daysBetween(startDate));
            if(System.today().daysBetween(startDate) <= 90 )
                bsiList.add(new CS_Billing_Schedule_Item__c(Opportunity__c = fi.csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__c,
                                                            Sales_Order__c = fi.csdf__Fulfilment__r.sales_order__c,
                                                            Total_Price__c = fi.csdf__Rate__c *fi.Insertion_Quantity__c,
                                                            ipp_Payment_Terms__c = fi.csdf__Fulfilment__r.sales_order__r.NetSuite_Payment_Term__r.Name,
                                                            Fulfilment_Item__c = fi.Id,
                                                            billing_Amount__c = fi.csdf__Rate__c*fi.Insertion_Quantity__c,
                                                            Billing_Date__c = System.today(), 
                                                            Billing_Schedule__c = bs.id,
                                                            Billing_Period_Start_Date__c = System.today(), 
                                                            Billing_Period_End_Date__c = System.today().addMonths(1)));
            else{
                bsiList.add(new CS_Billing_Schedule_Item__c(Opportunity__c = fi.csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__c,
                                                            Sales_Order__c = fi.csdf__Fulfilment__r.sales_order__c,
                                                            Total_Price__c = fi.csdf__Rate__c/2 *fi.Insertion_Quantity__c,
                                                            Fulfilment_Item__c = fi.Id,
                                                            billing_Amount__c = fi.csdf__Rate__c/2*fi.Insertion_Quantity__c,
                                                            ipp_Payment_Terms__c = fi.csdf__Fulfilment__r.sales_order__r.NetSuite_Payment_Term__r.Name,
                                                            Billing_Date__c = System.today(), 
                                                            Billing_Schedule__c = bs.id,
                                                            Billing_Period_Start_Date__c = System.today(), 
                                                            Billing_Period_End_Date__c = System.today().addMonths(1)));
                bsiList.add(new CS_Billing_Schedule_Item__c(Opportunity__c = fi.csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__c,
                                                            Sales_Order__c = fi.csdf__Fulfilment__r.sales_order__c,
                                                            Total_Price__c = fi.csdf__Rate__c/2*fi.Insertion_Quantity__c ,
                                                            billing_Amount__c = fi.csdf__Rate__c/2*fi.Insertion_Quantity__c,
                                                            Fulfilment_Item__c = fi.Id,
                                                            ipp_Payment_Terms__c = fi.csdf__Fulfilment__r.sales_order__r.NetSuite_Payment_Term__r.Name,
                                                            Billing_Date__c = startDate.addMonths(-1), 
                                                            Billing_Schedule__c = bs.id,
                                                            Billing_Period_Start_Date__c = startDate.addMonths(-1), 
                                                            Billing_Period_End_Date__c = startDate));
            }
            
        }
        system.debug(totalAmount+eventsAmount);
        //   system.debug(fulfilmentItems[0].csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__r.Total_Amount__c);
        if(fulfilmentItems.Size() > 0){ 
            system.debug('ss');
            system.debug(totalAmount);
            system.debug(eventsAmount);
            system.debug(othersTotalPrice);
            if(totalAmount+eventsAmount != othersTotalPrice){
                CS_Billing_Schedule_Item__c bsi = bsiList[bsilist.size()-1]; 
                bsiList.remove(bsilist.size()-1);
                //updatedBsiList.addAll(bsiList);
                // (23083.33 + 0.04) + (23083.33*11)
                //23083.33 - (276999.96 - 277000)
                decimal finalPrice =bsi.Total_Price__c + (othersTotalPrice - totalAmount+eventsAmount);
                system.debug(bsi.Total_Price__c + (othersTotalPrice - totalAmount+eventsAmount));
                bsi.Total_Price__c =  finalPrice;
                bsi.Billing_Amount__c = finalPrice;
                BsiList.add(bsi);
            }
        }
        system.debug(bsiList.size());
        
        /*if(updatedBsiList.size() > 0){
insert updatedBsiList;
}else*/
        insert bsiList;
        calloutsPerformed=true;
        return calloutsPerformed;
    }
    global List<SObject> process(List<SObject> data) {
        List<sObject> result = new List<sObject>();
        
        List<CSPOFA__Orchestration_Step__c> stepList =
            (List<CSPOFA__Orchestration_Step__c>)data;
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            step.CSPOFA__Status__c = 'Complete';
            step.CSPOFA__Completed_Date__c = Date.today();
            step.CSPOFA__Message__c = 'Custom step succeeded';
            result.add(step);
        }
        
        return result;
    }
}
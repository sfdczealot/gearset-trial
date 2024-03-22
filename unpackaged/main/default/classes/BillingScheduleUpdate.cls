public class BillingScheduleUpdate {
    @InvocableMethod
    public static void updateSchedules(List<String> IDList){
        csdf__Fulfilment_Item__c FLI = [select Id, csdf__Fulfilment__r.Sales_order__c,csdf__Fulfilment__r.Sales_Order__r.Billing_Schedule__c,Actual_Start_Date__c,csdf__Flight_Beginning__c
                                        from csdf__Fulfilment_Item__c 
                                        where id =:IDList ];
        String salesOrderId = FLI.csdf__Fulfilment__r.Sales_order__c;
        List<csdf__Fulfilment_Item__c> AllFli = [select Id, csdf__Fulfilment__r.Sales_order__c,Actual_Start_Date__c,csdf__Flight_Beginning__c
                                                 from csdf__Fulfilment_Item__c 
                                                 where csdf__Fulfilment__r.Sales_order__c =:salesOrderId 
                                                 and (Status_Manual_Tracking__c in ('Delivering','Completed') or csdf__Status__c in ('Delivering','Completed'))
                                                 and (Not Product_Configuration__r.Name like '%events%')
                                                ];
        
        List<CS_Billing_Schedule_Item__c> bsiList = [select id,Sales_Order__r.Billing_Schedule__c,Sales_Order__r.csmso__From__c,Billing_Period_Start_Date__c , 
                                                     Fulfilment_Item__c from CS_Billing_Schedule_Item__c where Sales_Order__c =: salesOrderId and  (Not Fulfilment_Item__r.Product_Configuration__r.Name like '%events%')];
        Date earliestStartDate ;
        //find earliest Start date
        for(csdf__Fulfilment_Item__c fi : AllFli){
            if(earliestStartDate == null){
                if(fi.Actual_Start_Date__c != null)
                    earliestStartDate = fi.Actual_Start_Date__c;
                else
                    earliestStartDate = fi.csdf__Flight_Beginning__c.date() ;
            }
            else{
                Date fliDate;
                if(fi.Actual_Start_Date__c != null)
                    fliDate = fi.Actual_Start_Date__c;
                else
                    fliDate = fi.csdf__Flight_Beginning__c.date() ;
                if(earliestStartDate > fliDate){
                    earliestStartDate = fliDate;
                }
            }
        }
        system.debug(earliestStartDate);
        //delete bsiList;
        String billingType = FLI.csdf__Fulfilment__r.Sales_Order__r.Billing_Schedule__c;
        if(billingType == 'Bill by item'){
            for( CS_Billing_Schedule_Item__c bsi : bsiList){
                
                if(bsi.Fulfilment_Item__c == FLI.Id){
                    Date startDate;
                    if(FLI.Actual_Start_Date__c  != null){
                        startDate = FLI.Actual_Start_Date__c ;
                    }
                    else 
                        startDate = date.newinstance(FLI.csdf__Flight_Beginning__c.year(), FLI.csdf__Flight_Beginning__c.month(), FLI.csdf__Flight_Beginning__c.day());
                    if(bsi.Billing_Period_Start_Date__c != startDate){
                        bsi.Billing_Date__c = startDate;
                        bsi.Billing_Period_Start_Date__c =  startDate;
                        bsi.Billing_Period_End_Date__c =  startDate.addMonths(1);
                    }
                    
                }
            }
            update bsiList;
        }
        else if(billingType == 'Full bill upon delivery'){
            if(bsiList[0].Billing_Period_Start_Date__c != earliestStartDate){
                bsiList[0].Billing_Date__c = earliestStartDate;
                bsiList[0].Billing_Period_Start_Date__c = earliestStartDate;
                bsiList[0].Billing_Period_End_Date__c = earliestStartDate.addMonths(1);
            }
            update bsiList;
        }
        else if(billingType == '3 Months' || billingType == '12 Months' || billingType == '6 Months'){
            Integer j =1;
            for(CS_Billing_Schedule_Item__c bsi : BsiList){
                if(bsi.Fulfilment_Item__c == null){
                    bsi.Billing_Date__c = earliestStartDate.addMonths(j-1);
                    bsi.Billing_Period_Start_Date__c =   earliestStartDate.addMonths(j-1);
                    bsi.Billing_Period_End_Date__c =   earliestStartDate.addMonths(j+1);
                }
                j++;
            }
            update bsiList;
           
            //delete bsiList;
        }
         callNetsuite(salesOrderId);
    }
    @future(callout=true)
    public static void callNetsuite(String orderId){
         HTTPResponse response;
        String endpoint =Label.billingScheduleiPP_endpoint ;
      
        Map<string,string> reqHeaders = new Map<string,string>();
        reqHeaders.put('Authorization',  Label.billingScheduleiPP_Auth);
        String reqbody = '{"orderId": "'+orderId+'"}';
        system.debug(reqHeaders); 
        system.debug('reqbody@@'+reqbody);
        response = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,endPoint,reqbody,'POST',true,false,null,NULL);
        system.debug('response@@'+response);
        if(!Test.isRunningTest()){
            if(response.getStatusCode() == 450) {
                throw new AuraHandledException('ERROR : Server error');
            }
            if(response.getStatusCode() != 200) { 
                Map<String,Object> errorMap = (Map<String,Object>)system.JSON.deserializeUntyped(response.getBody());
                if(errorMap.containsKey('message')){
                    throw new AuraHandledException('ERROR : '+ errorMap.get('message'));
                }
                if(errorMap.containsKey('error')){
                    throw new AuraHandledException('ERROR : '+ errorMap.get('error'));
                }
            }
        }
    }
}
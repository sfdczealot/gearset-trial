public class PGPaymentTriggerHandler implements PGTriggerInterface
{
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public void beforeInsert(List<sObject> newList) {
        
        List<Payment__c> paymList  = new List<Payment__c>();
        paymList = (list<Payment__c>)newList;
        PGPaymentTriggerHandler.paymentAmount(paymList);
    }
    
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {        
        List<Payment__c> paymList  = new List<Payment__c>();
        paymList = (list<Payment__c>)newList;
        PGPaymentTriggerHandler.paymentAmount(paymList);
    }
    
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
    }
    
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
    }
    
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
    }
    
    public void afterUnDelete(List<sObject> newList , Map<Id, sObject> newMap) {
    }
    
    public static void paymentAmount(List<Payment__c> newList){
        
        Map<Id,Quote> mapOfQuoIdVsQuote = new Map<Id,Quote>();
        Map<Id,List<Payment__c>> mapOfOppIdVsPrevPayment = new Map<Id,List<Payment__c>>();
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> quoteIdSet = new Set<Id>();
        Set<Id> paymentId = new Set<Id>();
        Set<String> setOfPaymentMethodNSId= new Set<String>{'28','29','7','32'};
            
            for (Payment__c payment: newList) {
                oppIdSet.add(payment.Opportunity_Record__c);
                quoteIdSet.add(payment.Quote_Record__c);
                paymentId.add(payment.Id);
            }
        
        for(Payment__c prevPayment :   [SELECT Id, Opportunity_Record__c,
                                        Payment_Mode__c, Reference_Number__c,
                                        Amount2__c,Quote_Record__c,
                                        Payment_Method__r.NS_Internal_ID__c
                                        FROM Payment__c 
                                        WHERE Opportunity_Record__c In: oppIdSet 
                                        AND Id Not In: paymentId]
           ){
               if(!mapOfOppIdVsPrevPayment.containsKey(prevPayment.Opportunity_Record__c)){
                   mapOfOppIdVsPrevPayment.put(prevPayment.Opportunity_Record__c,new List<Payment__c>{prevPayment}); 
               }
               else{
                   mapOfOppIdVsPrevPayment.get(prevPayment.Opportunity_Record__c).add(prevPayment);
               }
           }
        
        Map<Id,Opportunity> mapOfOppIdVsOpp = new Map<Id,Opportunity>([SELECT Id,Opportunity_Type__c,
                                                                       country__c,Name, CurrencyIsoCode,
                                                                       RecordType.Name, StageName, 
                                                                       Total_Gross_Amount__c 
                                                                       FROM Opportunity 
                                                                       WHERE Id In :oppIdSet]);
        
        for(Quote quo: [Select Id,Name,CurrencyIsoCode,
                        RecordType.Name,Status,
                        Total_Gross_Amount__c,
                        Total_WHT_Amount__c,
                        Country__c,OpportunityId
                        FROM Quote 
                        WHERE Id In: quoteIdSet
                        AND OpportunityId In: oppIdSet]
           ){
               mapOfQuoIdVsQuote.put(quo.Id,quo);         
           }
        
        
        for (Payment__c payment: newList) {
            if(mapOfOppIdVsOpp.containsKey(payment.Opportunity_Record__c) &&
               (mapOfOppIdVsOpp.get(payment.Opportunity_Record__c).RecordType.Name == 'B2C' ||
                mapOfOppIdVsOpp.get(payment.Opportunity_Record__c).RecordType.Name == 'B2B')) {
                    
                    if(String.isBlank(mapOfOppIdVsOpp.get(payment.Opportunity_Record__c).Opportunity_Type__c) &&
                       mapOfOppIdVsOpp.get(payment.Opportunity_Record__c).StageName != 'Pending OMC Approval') {
                           payment.addError('Payment Creation not allowed! You can only create Payment during Pending OMC Approval Stage.');
                       }
                    else if(String.isNotBlank(mapOfOppIdVsOpp.get(payment.Opportunity_Record__c).Opportunity_Type__c) &&
                            String.isBlank(payment.Quote_Record__c)) {
                                payment.addError('No Quote Present');
                            }
                    else if(String.isNotBlank(mapOfOppIdVsOpp.get(payment.Opportunity_Record__c).Opportunity_Type__c) &&
                            !(mapOfQuoIdVsQuote.get(payment.Quote_Record__c).Status == 'Pending Online Payment' || 
                              mapOfQuoIdVsQuote.get(payment.Quote_Record__c).Status == 'Pending OMC approval')) {
                                  payment.addError('Payment Creation not allowed! You can only create Payment during Pending OMC Approval and Pending Online Payment Status.'); 
                              }else{
                                  Decimal paymentAmount = 0;
                                  Decimal totalGrossAmount = 0;
                                  Boolean isMorePaymentAmount = true;
                                  
                                  if(mapOfOppIdVsPrevPayment.containsKey(payment.Opportunity_Record__c)) {
                                      for(Payment__c oldPayment : mapOfOppIdVsPrevPayment.get(payment.Opportunity_Record__c)){
                                          if(payment.Reference_Number__c == oldPayment.Reference_Number__c){
                                              if(mapOfOppIdVsOpp.get(payment.Opportunity_Record__c).country__c!='Thailand' ||
                                                 oldPayment.Payment_Mode__c!= 'Offline' || 
                                                 !setOfPaymentMethodNSId.contains(oldPayment.Payment_Method__r.NS_Internal_ID__c)){
                                                     payment.addError('Duplicate Reference Number Detected!');
                                                 }
                                          } 
                                          if(String.isNotBlank(mapOfOppIdVsOpp.get(payment.Opportunity_Record__c).Opportunity_Type__c) &&
                                             mapOfQuoIdVsQuote.get(payment.Quote_Record__c).Id == oldPayment.Quote_Record__c &&
                                             oldPayment.Payment_Mode__c !='Offline' && payment.Payment_Mode__c =='Offline' ){
                                                 payment.addError('Payment Creation not allowed! already created payment record whose payment mode is offline.');
                                             }
                                          
                                          paymentAmount = paymentAmount + oldPayment.Amount2__c;
                                      }
                                  }
                                  
                                  paymentAmount = paymentAmount + payment.Amount2__c;
                                  if(mapOfQuoIdVsQuote.get(payment.Quote_Record__c).Country__c == 'Thailand' &&
                                     mapOfQuoIdVsQuote.get(payment.Quote_Record__c).Total_WHT_Amount__c != null &&
                                     mapOfQuoIdVsQuote.get(payment.Quote_Record__c).Total_WHT_Amount__c>0){
                                         paymentAmount = paymentAmount + mapOfQuoIdVsQuote.get(payment.Quote_Record__c).Total_WHT_Amount__c;
                                     }
                                  
                                  if(String.isBlank(mapOfOppIdVsOpp.get(payment.Opportunity_Record__c).Opportunity_Type__c)) {
                                      totalGrossAmount = mapOfOppIdVsOpp.get(payment.Opportunity_Record__c).Total_Gross_Amount__c;
                                  }else if(String.isNotBlank(mapOfOppIdVsOpp.get(payment.Opportunity_Record__c).Opportunity_Type__c)) {
                                      totalGrossAmount = mapOfQuoIdVsQuote.get(payment.Quote_Record__c).Total_Gross_Amount__c;
                                  }
                                  
                                  if(paymentAmount.setScale(2, system.roundingMode.DOWN) == totalGrossAmount.setScale(2, system.roundingMode.DOWN)) {
                                      //same amount
                                      isMorePaymentAmount = false;
                                  } else if(paymentAmount.setScale(2, system.roundingMode.CEILING) == totalGrossAmount.setScale(2, system.roundingMode.DOWN)) {
                                      //same amount
                                      isMorePaymentAmount = false;
                                  } else if(paymentAmount.setScale(2, system.roundingMode.DOWN) == totalGrossAmount.setScale(2, system.roundingMode.CEILING)) {
                                      //same amount
                                      isMorePaymentAmount = false;
                                  } else if(paymentAmount.setScale(2, system.roundingMode.DOWN) > totalGrossAmount.setScale(2, system.roundingMode.DOWN)) {
                                      isMorePaymentAmount = true;
                                  } else {
                                      //less payment
                                      isMorePaymentAmount = false;
                                  }
                                  if(isMorePaymentAmount) {
                                      payment.addError('Payment Creation Failed!\nPayment Amount is greater than the total amount.');
                                  }
                              }
                    
                }
            
            if(mapOfOppIdVsOpp.containsKey(payment.Opportunity_Record__c)) {
                payment.CurrencyIsoCode = mapOfOppIdVsOpp.get(payment.Opportunity_Record__c).CurrencyIsoCode;
                payment.Amount__c = payment.Amount2__c;
            }
        }
    }
    
}
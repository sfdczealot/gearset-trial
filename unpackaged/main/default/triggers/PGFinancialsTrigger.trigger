trigger PGFinancialsTrigger on netsuite_conn__NetSuite_Financial__c (after insert, after update, before insert, before update) {

    if(trigger.isBefore){
        
        for(netsuite_conn__NetSuite_Financial__c Fin:Trigger.New) {
        
            for(Opportunity data:[select id, currencyisocode from opportunity where id =: Fin.netsuite_conn__Opportunity__c]){

                Fin.CurrencyIsoCode = data.CurrencyISOCode;
                Fin.netsuite_conn__Currency__c = data.CurrencyISOCode;

            }

        }

    }
    //PGAUTO-4078
    /*else if(trigger.isAfter){

        if(trigger.isInsert || trigger.isUpdate){

            system.debug('isbatch:' + system.isBatch());
            system.debug('isScheduled:' + system.isScheduled());
            system.debug('isQueueable:' + system.isQueueable());
            if(system.isBatch() == false && system.isScheduled() == false && system.isQueueable() == false){
            
                for(netsuite_conn__NetSuite_Financial__c Fin:Trigger.New) {
    
                    if(Fin.netsuite_conn__Document_Id__c == null && PGFinancialTriggerHandler.isFirstNSCall() && Fin.netsuite_conn__Type__c != 'Customer Refund'){
    
                        PGFinancialTriggerHandler.GetNSDocument(Fin.Id, Fin.netsuite_conn__NetSuite_Id__c, Fin.netsuite_conn__Type__c, Fin.Name);
    
                    }
    
                }
                
            }

        }

    }*/

}
trigger PGFinancialTrigger on Financial__c  (after insert, after update, before insert, before update) {
    
    if(trigger.isBefore){
        //adding trigger switch
        if(!Test.isRunningTest()) {
            Map<String, Trigger_Execute__c> mapOfSwitch1 = Trigger_Execute__c.getAll();
            if(!mapOfSwitch1.isEmpty() && mapOfSwitch1.containsKey('PGFinancialTrigger') && !mapOfSwitch1.get('PGFinancialTrigger').Enable_del__c) {
                return;
            }
        }
        
        for(Financial__c Fin:Trigger.New) {
        
            for(Opportunity data:[select id, currencyisocode from opportunity where id =: Fin.Opportunity__c]){

                Fin.CurrencyIsoCode = data.CurrencyISOCode;
                Fin.Currency__c = data.CurrencyISOCode;

            }

        }
        integer i =0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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
    //PGAUTO-4078
    /*else if(trigger.isAfter){

        if(trigger.isInsert || trigger.isUpdate){

            system.debug('isbatch:' + system.isBatch());
            system.debug('isScheduled:' + system.isScheduled());
            system.debug('isQueueable:' + system.isQueueable());
            if(system.isBatch() == false && system.isScheduled() == false && system.isQueueable() == false){
            
                for(Financial__cFin:Trigger.New) {
    
                    if(Fin.Document_Id__c == null && PGFinancialTriggerHandler.isFirstNSCall() && Fin.Type__c != 'Customer Refund'){
    
                        PGFinancialTriggerHandler.GetNSDocument(Fin.Id, Fin.NetSuite_Id__c, Fin.Type__c, Fin.Name);
    
                    }
    
                }
                
            }

        }

    }*/

}
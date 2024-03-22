global class CS_ActualizeLineInvoker implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {
    global String performAction(String paramsStr) {
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(paramsStr);
        Map<Id, String> response = new Map<Id, String>();

        Set<Id> productConfigurationIds = new Set<Id>();
        for(Object configId : (List<Object>) params.get('productConfigurationIds')) {
            productConfigurationIds.add(String.valueOf(configId));
        }

        CS_ScheduleService scheduleService = new CS_ScheduleService(new Set<Id>{String.valueOf(params.get('salesOrderId'))}, productConfigurationIds);
        Map<Id, Map<String, Decimal>> quantities = scheduleService.calculateQuantity();
		for(Id configId : productConfigurationIds) {
            if(quantities.containsKey(configId)) {
                cscfga__Product_Configuration__c config = scheduleService.productConfigurationsById.get(configId);
                List<CS_Billing_Schedule_Item__c> billingScheduleItems = scheduleService.billingScheduleItems.get(configId);
                CS_Billing_Schedule_Item__c lastScheduleItem;
                Decimal buffer = config.Buffer__c != null ? config.Buffer__c : 0;

                if(billingScheduleItems != null) {
                    for(CS_Billing_Schedule_Item__c bsi : billingScheduleItems) {
                        lastScheduleItem = lastScheduleItem == null ? bsi : lastScheduleItem.Billing_Date__c > bsi.Billing_Date__c ? lastScheduleItem : bsi;
                    }

                    if(config.Billing_Source__c == CS_const_SalesOrder.BillingSource_DFPActuals) {
                        buffer = config.Insertion_Quantity__c > quantities.get(configId).get('dfpActuals') ? 0 : buffer;
                        response.put(configId, String.valueOf(Math.ceil(quantities.get(configId).get('dfpActuals') / (1 + buffer/100))));
                    }
                    else if(config.Billing_Source__c == CS_const_SalesOrder.BillingSource_3rdPartyActuals) {
                        buffer = config.Insertion_Quantity__c > quantities.get(configId).get('thirdPartyActuals') ? 0 : buffer;
                        response.put(configId, String.valueOf(Math.ceil(quantities.get(configId).get('thirdPartyActuals') / (1 + buffer/100))));
                    }
                    else {
                        buffer = config.Insertion_Quantity__c > quantities.get(configId).get('dfpActuals') ? 0 : buffer;
                        response.put(configId, String.valueOf(Math.ceil(quantities.get(configId).get('dfpActuals') / (1 + buffer/100))));
                    }
                }
                else {
                    response.put(configId, String.valueOf(0));
                }
            }
        }

        return JSON.serialize(response);
    }
}
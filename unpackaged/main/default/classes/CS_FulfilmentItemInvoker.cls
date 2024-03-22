global with sharing class CS_FulfilmentItemInvoker {
    global String performAction(String parameters) {
        Set<Id> configurationIds = (Set<Id>) JSON.deserialize(parameters, Set<Id>.class);

        List<csdf__Fulfilment_Item__c> fulfilmentItems = CS_FulfilmentService.generateFulfilmentItems(configurationIds, false);

        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItemsByConfig = new Map<Id, csdf__Fulfilment_Item__c>();
        for(csdf__Fulfilment_Item__c fulfilmentItem : fulfilmentItems) {
            fulfilmentItemsByConfig.put(fulfilmentItem.Product_Configuration__c, fulfilmentItem);
        }

        return JSON.serialize(fulfilmentItemsByConfig);
    }
}
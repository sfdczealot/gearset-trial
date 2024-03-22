/**
 * Created by jameshladek on 3/10/20.
 */

global class CS_FulfilmentReadyHandler extends CS_StepHandlerBase {
    global CS_FulfilmentReadyHandler() {
        this.action = 'Fulfilment Start';
    }

    global override CSPOFA__Orchestration_Step__c doWork(Object params) {
        Map<String, Object> paramsType = (Map<String, Object>) params;
        CSPOFA__Orchestration_Step__c step = (CSPOFA__Orchestration_Step__c) paramsType.get('step');

        Set<Id> salesOrderIds = new Set<Id>{(Id) step.Sales_Order__c};

        List<cscfga__Attribute__c> attributes = [SELECT id, name, cscfga__Value__c, cscfga__Product_Configuration__c  FROM cscfga__Attribute__c
                                                WHERE cscfga__Product_Configuration__r.Sales_Order__c IN :salesOrderIds
                                                AND cscfga__Product_Configuration__r.Fulfilment_Item_Status__c != 'Paused Inventory Released'
                                                AND cscfga__Product_Configuration__r.Served_By__c != 'DFP'
                                                AND Name = 'Fulfilment Item Status'];
        for(cscfga__Attribute__c att : attributes) {
            att.cscfga__Value__c = 'Ready';
            att.cscfga__Display_Value__c = 'Ready';
        }
        update attributes;

        List<csdf__Fulfilment_Item__c> fulfilmentItems = [SELECT Id, csdf__Status__c FROM csdf__Fulfilment_Item__c
                                                            WHERE Served_By__c != 'DFP' AND csdf__Status__c != 'Ready' AND csdf__Status__c != 'Paused Inventory Released'
                                                            AND csdf__Fulfilment__r.Sales_Order__c = :salesOrderIds];
        for(csdf__Fulfilment_Item__c fulfilmentItem : fulfilmentItems) {
            fulfilmentItem.csdf__Status__c = 'Ready';
        }
        update fulfilmentItems;

        return setStepProgress(step, 'Completed updating Fulfilment Items to Ready');
    }
}
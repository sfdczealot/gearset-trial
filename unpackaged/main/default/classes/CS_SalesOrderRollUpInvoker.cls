global with sharing class CS_SalesOrderRollUpInvoker {
    global String performAction(String parameters) {
        Id salesOrderId = (Id)JSON.deserialize(parameters,Id.class);

        CS_P_SOLIRollup cspsoliRollup = new CS_P_SOLIRollup(false);
        cspsoliRollup.addApplicableSalesOrderId(Id.valueOf(salesOrderId));
        cspsoliRollup.doRollup();

        CS_ScheduleService.generateSchedules(new Set<Id>{salesOrderId}, null);

        Map<Id, cscfga__Product_Configuration__c> configs = new Map<Id, cscfga__Product_Configuration__c>([SELECT Id, Line_Id__c FROM cscfga__Product_Configuration__c WHERE Sales_Order__c = :salesOrderId]);

        return JSON.serialize(configs);
    }
}
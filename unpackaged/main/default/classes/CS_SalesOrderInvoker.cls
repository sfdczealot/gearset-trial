global with sharing class CS_SalesOrderInvoker {
    global String performAction(String parameters) {
        Id salesOrderId = (Id) JSON.deserialize(parameters, Id.class);
        csmso__Sales_Order__c salesOrder = [
                SELECT Id, csmso__Status__c, Current_User_Profile_Name__c,
                       Compliant_for_Reserve_Release__c, SO_Lines_All_Valid__c, Can_Reserve_Inventory__c,
                       FLAG_Freq_Cap_Override_Lock__c, FLAG_Freq_Cap_Override_Unlock__c, CurrencyIsoCode
                FROM csmso__Sales_Order__c
                WHERE Id = :salesOrderId
        ];

        return JSON.serialize(salesOrder);
    }
}
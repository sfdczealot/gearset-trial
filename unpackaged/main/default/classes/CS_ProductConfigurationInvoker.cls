/**
 * Created by tvrtko.matosevic on 14/06/2019.
 */
global with sharing class CS_ProductConfigurationInvoker {
    global String performAction(String parameters) {
        Id configId = (Id)JSON.deserialize(parameters,Id.class);

        cscfga__Product_Configuration__c productConfiguration = [
                SELECT Id, Can_Be_Cloned__c, Can_Be_Deleted__c, cscfga__originating_offer__c
                FROM cscfga__Product_Configuration__c
                WHERE Id = :configId
        ];

        return JSON.serialize(productConfiguration);
    }
}
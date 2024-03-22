/**
 * Created by ivan.ravnjak on 29.4.2020..
 */

global with sharing class CS_ArchivePollActionInvoker {

    global String performAction(String parameters) {
        List<Id> productConfigurationIds = (List<Id>) JSON.deserialize(parameters, List<Id>.class);
        return JSON.serialize(archivePollCheck(productConfigurationIds));
    }

    public static Map<Id, ArchivePollResponse> archivePollCheck(List<Id> productConfigurationIds) {
        List<csdf__Fulfilment_Item__c> fulfilmentItems = [
                SELECT Id, csdf__Status__c, csdf__Cancel_Message_Status__c, Reservation_Status__c, Product_Configuration__c
                FROM csdf__Fulfilment_Item__c
                WHERE Product_Configuration__c IN :productConfigurationIds
        ];

        Map<Id, ArchivePollResponse> responsesMap = new Map<Id, ArchivePollResponse>();
        for (csdf__Fulfilment_Item__c fulfilmentItem : fulfilmentItems) {
            ArchivePollResponse pollResponse = new ArchivePollResponse();
            pollResponse.archiveMessageStatus = fulfilmentItem.csdf__Cancel_Message_Status__c;

            if (fulfilmentItem.csdf__Cancel_Message_Status__c == 'Completed') {
                pollResponse.responseStatus = 'Success';
                pollResponse.fulfilmentItemStatus = fulfilmentItem.csdf__Status__c;
                pollResponse.reservationItemStatus = fulfilmentItem.Reservation_Status__c;
            }
            else if (fulfilmentItem.csdf__Cancel_Message_Status__c.contains('Error')) {
                pollResponse.responseStatus = 'Error';
                pollResponse.responseMessage = 'Error on Ad Server Integration';
            }

            responsesMap.put(fulfilmentItem.Product_Configuration__c, pollResponse);
        }

        return responsesMap;
    }

    public class ArchivePollResponse {
        public String archiveMessageStatus { get; set; }
        public String fulfilmentItemStatus { get; set; }
        public String reservationItemStatus { get; set; }
        public String responseStatus { get; set; }
        public String responseMessage { get; set; }
    }
}
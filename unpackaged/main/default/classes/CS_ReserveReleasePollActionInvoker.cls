global with sharing class CS_ReserveReleasePollActionInvoker {

    global String performAction(String parameters) {
        List<Id> productConfigurationIds = (List<Id>) JSON.deserialize(parameters, List<Id>.class);
        return JSON.serialize(reserveReleasePollCheck(productConfigurationIds));
    }

    public static Map<Id, ReserveReleasePollResponse> reserveReleasePollCheck (List<Id> productConfigurationIds) {
        List<csdf__Fulfilment_Item__c> fulfilmentItems = [
                SELECT Id, csdf__Pause_Resume_Message_Status__c, Reservation_Status__c, Product_Configuration__r.Line_ID__c
                FROM csdf__Fulfilment_Item__c
                WHERE Product_Configuration__c IN :productConfigurationIds
        ];

        Map<Id, ReserveReleasePollResponse> responsesMap = new Map<Id, ReserveReleasePollResponse>();
        for (csdf__Fulfilment_Item__c fulfilmentItem : fulfilmentItems) {
            ReserveReleasePollResponse pollResponse = new ReserveReleasePollResponse();
            pollResponse.reserveReleaseMessageStatus = fulfilmentItem.csdf__Pause_Resume_Message_Status__c;

            if (fulfilmentItem.csdf__Pause_Resume_Message_Status__c == 'Completed') {
                pollResponse.responseStatus = 'Success';
                pollResponse.reservationStatus = fulfilmentItem.Reservation_Status__c;
            }
            else if (fulfilmentItem.csdf__Pause_Resume_Message_Status__c.contains('Error')) {
                pollResponse.responseStatus = 'Error';
                pollResponse.responseMessage = 'Error on Ad Server Integration';
            }

            responsesMap.put(fulfilmentItem.Product_Configuration__c, pollResponse);
        }

        return responsesMap;
    }

    public class ReserveReleasePollResponse {
        public String reserveReleaseMessageStatus { get; set; }
        public String reservationStatus { get; set; }
        public String responseStatus { get; set; }
        public String responseMessage { get; set; }
    }
}
/**
 * Created by ivan.ravnjak on 29.4.2020..
 */

global with sharing class CS_PauseResumePollActionInvoker {

    global String performAction(String parameters) {
        List<Id> productConfigurationIds = (List<Id>) JSON.deserialize(parameters, List<Id>.class);
        return JSON.serialize(reserveReleasePollCheck(productConfigurationIds));
    }

    public static Map<Id, PauseResumePollResponse> reserveReleasePollCheck (List<Id> productConfigurationIds) {
        List<csdf__Fulfilment_Item__c> fulfilmentItems = [
                SELECT Id, csdf__Pause_Resume_Message_Status__c, Reservation_Status__c, Product_Configuration__r.Line_ID__c, csdf__Status__c
                FROM csdf__Fulfilment_Item__c
                WHERE Product_Configuration__c IN :productConfigurationIds
        ];

        Map<Id, PauseResumePollResponse> responsesMap = new Map<Id, PauseResumePollResponse>();
        for (csdf__Fulfilment_Item__c fulfilmentItem : fulfilmentItems) {
            PauseResumePollResponse pollResponse = new PauseResumePollResponse();
            pollResponse.pauseResumeMessageStatus = fulfilmentItem.csdf__Pause_Resume_Message_Status__c;

            if (fulfilmentItem.csdf__Pause_Resume_Message_Status__c == 'Completed') {
                pollResponse.responseStatus = 'Success';
                pollResponse.fulfilmentItemStatus = fulfilmentItem.csdf__Status__c;
            }
            else if (fulfilmentItem.csdf__Pause_Resume_Message_Status__c.contains('Error')) {
                pollResponse.responseStatus = 'Error';
                pollResponse.responseMessage = 'Error on Ad Server Integration';
            }

            responsesMap.put(fulfilmentItem.Product_Configuration__c, pollResponse);
        }

        return responsesMap;
    }

    public class PauseResumePollResponse {
        public String pauseResumeMessageStatus { get; set; }
        public String fulfilmentItemStatus { get; set; }
        public String responseStatus { get; set; }
        public String responseMessage { get; set; }
    }
}
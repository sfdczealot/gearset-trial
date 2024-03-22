global with sharing class CancelArchivePollActionInvoker implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {

 global String performAction(String parameters) {
  Id fulfilmentItemId = (Id) JSON.deserialize(parameters, Id.class);

  List<csdf__Fulfilment_Item__c> fulfilmentItems =
   [SELECT Id, csdf__Status__c, csdf__Cancel_Message_Status__c, Reservation_Status__c
      FROM csdf__Fulfilment_Item__c WHERE Id = :fulfilmentItemId];

  Map<String, String> responseMap = new Map<String, String>();
  if (fulfilmentItems.isEmpty()) {
   responseMap.put('status', 'Error');
   responseMap.put('responseMessage', 'Fulfilment Item ' + fulfilmentItemId + ' cannot be found');
  } else {
   csdf__Fulfilment_Item__c fulfilmentItem = fulfilmentItems.iterator().next();
   responseMap.put('status', fulfilmentItem.csdf__Cancel_Message_Status__c);
   if (fulfilmentItem.csdf__Cancel_Message_Status__c == 'Completed') {
    responseMap.put('responseMessage', 'Success');
    responseMap.put('fulfilmentItemStatus', fulfilmentItem.csdf__Status__c);
    responseMap.put('reservationtemStatus', fulfilmentItem.Reservation_Status__c);
   }
  }

  return JSON.serialize(responseMap);
 }
}
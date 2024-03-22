global with sharing class CS_NodeAdvertAssignmentInvoker implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {
    global String performAction(String parameters) {
        Id nnaId = (Id) JSON.deserialize(parameters, Id.class);
        csmso__Node_Advert_Assignment__c nodeAdvertAssignment = [
                SELECT Id, Ad_Slot_Template__c, Targeting_Template__c, Lock_Frequency_Capping__c, Default_Frequency_Capping__c, Skip_Approvals__c
                FROM csmso__Node_Advert_Assignment__c
                WHERE Id = :nnaId
        ];

        return JSON.serialize(nodeAdvertAssignment);
    }
}
global with sharing class CS_PremiumChargesInvoker implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {
    global String performAction(String parameters) {
        List<Id> premiumIds = (List<Id>) JSON.deserialize(parameters, List<Id>.class);
        List<Premium_Group_Charge__c> premiumGroupCharges = [SELECT Id, Premium_Percentage__c, Premium_Flat_Rate__c, Premium_Group_Name__c
                                                             FROM Premium_Group_Charge__c
                                                             WHERE Id IN :premiumIds
                                                             ORDER BY Premium_Percentage__c ASC];
        return JSON.serialize(premiumGroupCharges);
    }
}
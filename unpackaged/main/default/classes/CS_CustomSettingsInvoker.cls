global class CS_CustomSettingsInvoker implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {
    global String performAction(String params) {
        CS_Custom_Settings__c csCustomSettings = CS_Custom_Settings__c.getInstance(UserInfo.getUserId());
        return JSON.serialize(csCustomSettings);
    }
}
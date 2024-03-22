/**
@name UpdateOnClosedWonTriggerHandler
@Description Handler class for Updates On Closed Won event Trigger
@Version 1.0
@reference SF-6204
*/
public without sharing class UpdateOnClosedWonTriggerHandler {
    public void runTrigger() {
        // Method will be called to handle After Insert Updates_On_Closed_Won__e
        if(Trigger.isAfter && Trigger.isInsert) {
            onAfterinsert((list<Updates_On_Closed_Won__e >)trigger.new);
        }
    }
    
    private void onAfterInsert(list<Updates_On_Closed_Won__e> listTriggerNew) {
        updateRollUpFields(listTriggerNew);
    }
    
    /**
*  Method used to update the field on account and oppty after closed won/converted.
*  @name updateRollUpFields
*  @param trigger new data
*  @return void
*/
    private void updateRollUpFields(list<Updates_On_Closed_Won__e> listTriggerNew) {
        for(Updates_On_Closed_Won__e eachEvent : listTriggerNew) {
            if(eachEvent.Is_Self_Serve__c == false && eachEvent.Account_Id__c != null) {
                AmountRollUpHandler.populateClosedWonFields(eachEvent.Account_Id__c,null);
            }
            else if(eachEvent.Is_Self_Serve__c == true && eachEvent.Opportunity_Id__c != null) {
                AmountRollUpHandler.populateConvertedSSFields(eachEvent.Opportunity_Id__c);
            }
        }
    }
}
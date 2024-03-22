trigger CS_OfferTrigger on cscfga__Configuration_Offer__c (before insert, before update) {

    // DISPATCHER TRIGGER PATTERN
    if(CS_utl_user.isTriggerActiveForMe()) {

        CS_ProcessDispatcher dispatcher = new CS_ProcessDispatcher();

        if(Trigger.isBefore) {

            if(Trigger.isInsert) {

                dispatcher.addProcesses(new List<CS_ProcessBase> {
                    new CS_P_OfferMarketOrderTypeChanged()
                });
            }

            if(Trigger.isUpdate) {

                dispatcher.addProcesses(new List<CS_ProcessBase> {
                    new CS_P_OfferMarketOrderTypeChanged(Trigger.oldMap)
                });
            }

        }

        dispatcher.dispatch();
    }
    // DISPATCHER TRIGGER PATTERN
}
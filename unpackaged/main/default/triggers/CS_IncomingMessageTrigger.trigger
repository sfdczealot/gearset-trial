trigger CS_IncomingMessageTrigger on csam__Incoming_Message__c (before insert) {
    if(Trigger.isBefore && Trigger.isInsert) {
        for(csam__Incoming_Message__c im : Trigger.new) {
            if(String.isNotBlank(im.csam__Incoming_Url_Path__c) && im.csam__Incoming_Url_Path__c.equalsIgnoreCase('/csam/callback/customReport')) {
                im.csam__Can_Reset_Map_References__c = true;
            }
        }
    }
}
@isTest
public class CS_IncomingMessageTriggerTest {
    @isTest
    public static void test_IncomingMessageTrigger() {
        csam__Incoming_Message__c incomingMessage = new csam__Incoming_Message__c(
            csam__Incoming_Url_Path__c = '/csam/callback/customReport',
            csam__HTTP_Method__c = 'POST'
        );
        insert incomingMessage;
        csam__Incoming_Message__c incomingMessageTest = [SELECT Id, csam__Can_Reset_Map_References__c FROM csam__Incoming_Message__c LIMIT 1];
        
        System.assert(incomingMessageTest.csam__Can_Reset_Map_References__c);
    }
}
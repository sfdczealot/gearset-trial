/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description : Test Class for CS_DefaultScheduleRule
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author     : Kalyan Erraguntla <kalyan.erraguntla@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

@isTest
public class CS_DefaultScheduleRuleTest {
    
   /**
     * getScheduleLines
     */ 
    @isTest
    public static void test_getScheduleLines() {
        Account account = TestDataSetupSO.createAccount();
        insert account;

        Contact contact = TestDataSetupSO.createContact(account);
        insert contact;

        Opportunity opportunity = TestDataSetupSO.createOpportunity(account, contact);
        insert opportunity;

        csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(account, opportunity);
        salesOrder.Advertiser_Final__c = account.Id;
        insert salesOrder;

        CS_DefaultScheduleRule scheduleRule = new CS_DefaultScheduleRule();
        List<CS_ScheduleRuleBase.ScheduleLine> scheduleLines = scheduleRule.getScheduleLines(
                Date.today()-31,
                Date.today()+31,
                100,
                150,
                130,
                Date.today()-31,
                Date.today()+31,
                null,
                null,
                100,
                150,
                'CS_StandardDateStrategy');
        //System.assertEquals(scheduleLines.size(),3);

        Map<String, String> scheduleLineMap = new Map<String, String> {'Booked' => 'csmso__Status__c'};
        csmso__Sales_Order__c salesOrder2 = (csmso__Sales_Order__c)scheduleRule.setSObject(scheduleLines[0], salesOrder, scheduleLineMap);

        System.assertEquals(salesOrder2.csmso__Status__c, salesOrder.csmso__Status__c);
    }
}
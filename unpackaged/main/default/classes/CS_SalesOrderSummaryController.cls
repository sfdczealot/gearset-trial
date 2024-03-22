/**
 * Created by sasa.marjancic on 22.4.2020..
 */

public with sharing class CS_SalesOrderSummaryController {
    @AuraEnabled(cacheable=true)
    public static List<CSPOFA__Orchestration_Step_Template__c> getPossibleSteps(Id salesOrder, String orderType) {
        csmso__Sales_Order__c so = [SELECT Id, Last_Date_Retracted__c, Sold__c, In_Retraction__c FROM csmso__Sales_Order__c WHERE Id = :salesOrder];
        Set<String> processType = new Set<String> {'Common', orderType == 'Programmatic Guaranteed' ? orderType : 'Direct'};
        Set<String> phases = new Set<String> {'Common', so.In_Retraction__c == true ? 'In-Flight' : 'New Sale'};

        return [Select id, CSPOFA__Milestone_Label__c, CSPOFA__Milestone_Description__c, Name
        From CSPOFA__Orchestration_Step_Template__c
        Where CSPOFA__Orchestration_Process_Template__r.CSPOFA__Process_Type__c IN :processType
        And CSPOFA__Milestone__c = true And Milestone_Phase__c IN :phases
        And (Not CSPOFA__Orchestration_Process_Template__r.Name like '%Archived%')
        Order by CSPOFA__Milestone_Label__c asc];
    }

    @AuraEnabled(cacheable=true)
    public static List<CSPOFA__Orchestration_Step__c> getActiveSteps(Id salesOrder) {
        csmso__Sales_Order__c so = [SELECT Id, Last_Date_Retracted__c FROM csmso__Sales_Order__c WHERE Id = :salesOrder];
        Set<String> phases = new Set<String> {'Common', so.Last_Date_Retracted__c != null ? 'In-Flight' : 'New Sale'};

        return [Select id, CSPOFA__Milestone_Label__c, CSPOFA__Milestone_Description__c, Name, CSPOFA__Status__c
        From CSPOFA__Orchestration_Step__c
        Where ((CSPOFA__Orchestration_Process__r.CSPOFA__Root_Process__c != null AND CSPOFA__Orchestration_Process__r.CSPOFA__Root_Process__r.CSPOFA__State__c NOT IN ('TERMINATED', 'ARCHIVED', 'COMPLETED'))
        OR (CSPOFA__Orchestration_Process__r.CSPOFA__Root_Process__c = null AND CSPOFA__Orchestration_Process__r.CSPOFA__State__c NOT IN ('TERMINATED', 'ARCHIVED', 'COMPLETED')))
        And CSPOFA__Milestone__c = true And CSPOFA__Orchestration_Process__r.Sales_Order__c = :salesOrder And CSPOFA__Orchestration_Step_Template__r.Milestone_Phase__c IN :phases
        Order by CSPOFA__Milestone_Label__c asc];
    }
}
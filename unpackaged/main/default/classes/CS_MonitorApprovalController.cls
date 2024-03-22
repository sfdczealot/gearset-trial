/**
 * Created by jameshladek on 2/19/20.
 */

public with sharing class CS_MonitorApprovalController {

    @AuraEnabled
    public static csmso__Sales_Order__c findMonitorValues(String soId) {
        return [
                SELECT Id, ARM_Approval__c, Inventory_Approval__c, Pricing_Approval__c, Customer_Approval__c, Legal_Approval__c,
                        Countersign_IO_Approval__c, Compliance_Approval__c, Account_Check_Approval__c, Is_Programmatic__c,
                        SD_Approval__c,CM_Approval__c,HOB_Approval__c,CBO_Approval__c,OMC_Approval__c
                FROM csmso__Sales_Order__c
                WHERE Id = :soId
        ];
    }

}
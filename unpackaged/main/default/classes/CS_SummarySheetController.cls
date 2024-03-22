/**
 * Created by jameshladek on 4/1/20.
 */

public with sharing class CS_SummarySheetController {

    @AuraEnabled
    public static csmso__Sales_Order__c getSummaryData(Id soId) {
        return [
                SELECT Id, SO_Lines_Number_of_lines__c, SO_Lines_Gross_Total__c, SO_Gross_Amount__c
                        , csmso__Status__c, eCPM__c, Total_Impressions__c, Total_Delivered__c, Total_Spend__c
                FROM csmso__Sales_Order__c
                WHERE Id = :soId
        ];
    } 
}
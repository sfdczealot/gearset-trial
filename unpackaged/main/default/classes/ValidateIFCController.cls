/**************************************************************************************************************************************************************************
* @author       Ivan Ravnjak
* @description  Invoked on 'Validate IFC' button on SO, checks if changes on the Line Item are valid.
* @date         2018-09-25
* @param        paramsStr(Map<String, String>) string of parametrs from 
**************************************************************************************************************************************************************************/

global with sharing class ValidateIFCController implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {

    private class IFCValidationResult {

        public Boolean isError { get; set; }
        public String errorMsg { get; set; }
        public Map<String, Decimal> quantities { get; set; }

        public IFCValidationResult(String getErrorMsg, Map<String, Decimal> quantities) {
            isError = String.isNotBlank(getErrorMsg);
            errorMsg = getErrorMsg;
            this.quantities = quantities;
        }
    }

    global String performAction(String paramsStr) {
        Map<String, Object> paramsObj = (Map<String, Object>)JSON.deserializeUntyped(paramsStr);
        
        Id configId = paramsObj.containsKey('ConfigId') ? Id.valueOf(String.valueOf(paramsObj.get('ConfigId'))) : null;
        Id salesOrderId = paramsObj.containsKey('Sales_Order_Id_0') ? Id.valueOf(String.valueOf(paramsObj.get('Sales_Order_Id_0'))) : null;
        Integer insertionQuantity = paramsObj.containsKey('Insertion_Quantity_0') ? Integer.valueOf(paramsObj.get('Insertion_Quantity_0')) : null;
        Integer totalQuantity = paramsObj.containsKey('Calculated_Quantity_0') ? Integer.valueOf(paramsObj.get('Calculated_Quantity_0')) : null;
        Date startDate = paramsObj.containsKey('Start_Date_0') ? Date.valueOf(String.valueOf(paramsObj.get('Start_Date_0'))) : null;
        Date endDate = paramsObj.containsKey('End_Date_0') ? Date.valueOf(String.valueOf(paramsObj.get('End_Date_0'))) : null;
        String flightBeginDateTimeSelected = paramsObj.containsKey('Flight_Begin_Date_Time_Selected_0') ? String.valueOf(paramsObj.get('Flight_Begin_Date_Time_Selected_0')) : null;
        String flightEndDateTimeSelected = paramsObj.containsKey('Flight_End_Date_Time_Selected_0') ? String.valueOf(paramsObj.get('Flight_End_Date_Time_Selected_0')) : null;
        Decimal unitPrice = paramsObj.containsKey('Rate_0') ? Decimal.valueOf(String.valueOf(paramsObj.get('Rate_0'))) : null;  
        String fulfilmentItemStatus = paramsObj.containsKey('Fulfilment_Item_Status_0') ? String.valueOf(paramsObj.get('Fulfilment_Item_Status_0')) : null;
        String billingSource = paramsObj.containsKey('Billing_Source_0') ? String.valueOf(paramsObj.get('Billing_Source_0')) : null;
        Boolean x3rdPartyVerification = paramsObj.containsKey('x3rd_Party_Verification_0') ? Boolean.valueOf(paramsObj.get('x3rd_Party_Verification_0')) : null;
        Boolean x3rdPartyTracking = paramsObj.containsKey('x3rd_Party_Tracking_0') ? Boolean.valueOf(paramsObj.get('x3rd_Party_Tracking_0')) : null;
        
        String x3rdPartyAdServer = paramsObj.containsKey('x3rd_Party_Ad_Server_0') ? String.valueOf(paramsObj.get('x3rd_Party_Ad_Server_0')) : null;
        List<X3rd_Party_Ad_Server__c> currentAdServers = [SELECT Id, X3rd_Party_Ad_Server__c 
                                                    FROM X3rd_Party_Ad_Server__c 
                                                    WHERE Id = :x3rdPartyAdServer];
        String x3rdPartyAdServerName = !currentAdServers.isEmpty() ? currentAdServers.get(0).X3rd_Party_Ad_Server__c : null;

        CS_ScheduleService scheduleService = new CS_ScheduleService(new Set<Id>{salesOrderId}, new Set<Id>{configId});
        scheduleService.productConfigurations = new Map<Id, List<cscfga__Product_Configuration__c>>{salesOrderId => new List<cscfga__Product_Configuration__c>{
                new cscfga__Product_Configuration__c(Id = configId, Sales_Order__c = salesOrderId,
                        Insertion_Quantity__c = insertionQuantity,
                        Scheduled_Quantity__c = totalQuantity,
                        Flight_Begin__c = startDate, Flight_End__c = endDate, Net_Rate_Final__c = unitPrice,
                        Flight_Begin_Date_Time_Selected__c = flightBeginDateTimeSelected,
                        Flight_End_Date_Time_Selected__c = flightEndDateTimeSelected,
                        Fulfilment_Item_Status__c = fulfilmentItemStatus,
                        Billing_Source__c = billingSource,
                        X3rd_Party_Verification__c = x3rdPartyVerification,
                        X3rd_Party_Tracking__c = x3rdPartyTracking,
                        X3rd_Party_Ad_Server__r = new X3rd_Party_Ad_Server__c(X3rd_Party_Ad_Server__c = x3rdPartyAdServerName))
        }};

        return JSON.serialize(new IFCValidationResult(scheduleService.validateSchedules(false), scheduleService.calculateQuantity().get(configId)));
    }
}
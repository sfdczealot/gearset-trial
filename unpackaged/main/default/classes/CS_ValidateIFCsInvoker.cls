/**
 * Created by tvrtko.matosevic on 10/06/2019.
 */

global with sharing class CS_ValidateIFCsInvoker{

    private class IFCValidationResult {
        public Boolean isError { get; set; }
        public String errorMsg { get; set; }

        public IFCValidationResult(String getErrorMsg) {
            isError = String.isNotBlank(getErrorMsg);
            errorMsg = getErrorMsg;
        }
    }

    global String performAction(String paramsStr) {
        System.debug('paramsStr => ' + paramsStr);
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(paramsStr);
        List<Map<String, Object>> paramsObj = new List<Map<String, Object>>();
        Set<String> x3rdPartyAdServers = new Set<String>();

        for (Object instance : (List<Object>) data.get('data')) {
            Map<String, Object> param = (Map<String, Object>) instance;
            if(param.containsKey('x3rd_Party_Ad_Server_0') && String.isNotBlank(String.valueOf(param.get('x3rd_Party_Ad_Server_0')))) {
                x3rdPartyAdServers.add( String.valueOf(param.get('x3rd_Party_Ad_Server_0')));
            }

            paramsObj.add(param);
        }

        Map<Id, X3rd_Party_Ad_Server__c> adServers = new Map<Id, X3rd_Party_Ad_Server__c>();
        if (!x3rdPartyAdServers.isEmpty()) {
            adServers = new Map<Id, X3rd_Party_Ad_Server__c>([
                    SELECT Id, X3rd_Party_Ad_Server__c
                    FROM X3rd_Party_Ad_Server__c
                    WHERE Id = :x3rdPartyAdServers
            ]);
        }

        Map<Id, cscfga__Product_Configuration__c> productConfigurations = new Map<Id, cscfga__Product_Configuration__c>();
        Id salesOrderId = paramsObj[0].containsKey('Sales_Order_Id_0') ? Id.valueOf(String.valueOf(paramsObj[0].get('Sales_Order_Id_0'))) : null;
        for (Map <String, Object> param : paramsObj) {
            Id configId = param.containsKey('ConfigId') ? Id.valueOf(String.valueOf(param.get('ConfigId'))) : null;
            Integer insertionQuantity = param.containsKey('Insertion_Quantity_0') ? Integer.valueOf(param.get('Insertion_Quantity_0')) : null;
            Integer totalQuantity = param.containsKey('Calculated_Quantity_0') ? Integer.valueOf(param.get('Calculated_Quantity_0')) : null;
            Date startDate = param.containsKey('Start_Date_0') ? Date.valueOf(String.valueOf(param.get('Start_Date_0'))) : null;
            Date endDate = param.containsKey('End_Date_0') ? Date.valueOf(String.valueOf(param.get('End_Date_0'))) : null;
            String flightBeginDateTimeSelected = param.containsKey('Flight_Begin_Date_Time_Selected_0') ? String.valueOf(param.get('Flight_Begin_Date_Time_Selected_0')) : null;
            String flightEndDateTimeSelected = param.containsKey('Flight_End_Date_Time_Selected_0') ? String.valueOf(param.get('Flight_End_Date_Time_Selected_0')) : null;
            Decimal unitPrice = param.containsKey('Rate_0') ? Decimal.valueOf(String.valueOf(param.get('Rate_0'))) : null;
            String fulfilmentItemStatus = param.containsKey('Fulfilment_Item_Status_0') ? String.valueOf(param.get('Fulfilment_Item_Status_0')) : null;

            String billingSource = param.containsKey('Billing_Source_0') ? String.valueOf(param.get('Billing_Source_0')) : null;
            Boolean x3rdPartyVerification = param.containsKey('x3rd_Party_Verification_0') ? Boolean.valueOf(param.get('x3rd_Party_Verification_0')) : null;
            Boolean x3rdPartyTracking = param.containsKey('x3rd_Party_Tracking_0') ? Boolean.valueOf(param.get('x3rd_Party_Tracking_0')) : null;
            String x3rdPartyAdServer = param.containsKey('x3rd_Party_Ad_Server_0') ? String.valueOf(param.get('x3rd_Party_Ad_Server_0')) : null;
            String x3rdPartyAdServerName = !adServers.isEmpty() && String.isNotBlank(x3rdPartyAdServer) ? adServers.get(x3rdPartyAdServer).X3rd_Party_Ad_Server__c : null;

            cscfga__Product_Configuration__c productConfiguration =
                new cscfga__Product_Configuration__c(
                        Id = configId,
                        Sales_Order__c = salesOrderId,
                        Insertion_Quantity__c = insertionQuantity,
                        Scheduled_Quantity__c = totalQuantity,
                        Flight_Begin__c = startDate,
                        Flight_End__c = endDate,
                        Net_Rate_Final__c = unitPrice,
                        Flight_Begin_Date_Time_Selected__c = flightBeginDateTimeSelected,
                        Flight_End_Date_Time_Selected__c = flightEndDateTimeSelected,
                        Fulfilment_Item_Status__c = fulfilmentItemStatus,
                        Billing_Source__c = billingSource,
                        X3rd_Party_Verification__c = x3rdPartyVerification,
                        X3rd_Party_Tracking__c = x3rdPartyTracking,
                        X3rd_Party_Ad_Server__r = new X3rd_Party_Ad_Server__c(X3rd_Party_Ad_Server__c = x3rdPartyAdServerName)
                );
            productConfigurations.put(configId, productConfiguration);
        }

        return JSON.serialize(new IFCValidationResult(CS_ScheduleService.validateSchedules(
                new Set<Id>{ salesOrderId },
                productConfigurations.keySet(),
                new Map<Id, List<cscfga__Product_Configuration__c>>{ salesOrderId => productConfigurations.values() },
                false)));
    }
}
/**************************************************************************************************************************************************************************
* @author       Ivan Ravnjak
* @description  Invoked on 'Unlock' button on SO, updates status on Line, Bill Schedule and Rev Rec depending on Line parameters
* @date         2018-09-11
* @param        params(Map<String, String>) map of search fields from config
* @param        parentFieldValue(String) Value of parent Field Value
*
* History
* 30/10/18      C. Steen    Renamed On_Hold Flag to Under_IFC to reduce confusion about 'what hold means''
*
* History
* 07/12/18      A. Topic    Changed Conditions for Locked and Partially Locked
**************************************************************************************************************************************************************************/
global with sharing class UnlockLineController implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate{
    global String performAction(String parameters) {
        Id configId = (Id) JSON.deserialize(parameters, Id.class);
        
        List<String> attNames = new List<String>{'Flight Begin Date Time Selected', 'Flight End Date Time Selected'};
        List<CS_Billing_Schedule_Item__c> billingScheduleList = [SELECT 
                                                                   Id, Name, Sales_Order__c, Product_Configuration__c, Fulfilment_Item__c, 
                                                                   Status__c, Is_Open__c, Is_Closed__c, IsForecast__c 
                                                                 FROM 
                                                                     CS_Billing_Schedule_Item__c
                                                                 WHERE 
                                                                    Product_Configuration__c = :configId ];

        List<cscfga__Attribute__c> salesOrderLinesAttrList = [  SELECT 
                                                                   Id, Name, cscfga__Value__c 
                                                                FROM 
                                                                    cscfga__Attribute__c
                                                                WHERE 
                                                                    cscfga__Product_Configuration__c = :configId AND Name IN :attNames];

        List<csdf__Fulfilment_Item__c> fiList = [SELECT id, csdf__Status__c 
                                                  FROM csdf__Fulfilment_Item__c 
                                                  WHERE Product_Configuration__c=:configId ORDER BY Last_Action_from_DFP__c DESC]; 

        cscfga__Product_Configuration__c pc = [SELECT Id, Sales_Order__r.Is_Programmatic__c
                                               FROM cscfga__Product_Configuration__c
                                               WHERE Id = :configId
                                               LIMIT 1];

        Boolean hasAllLinesClosed = true;
        Boolean hasAllLinesOpen = true;
        Boolean hasOpenBillSch = false;
        Boolean lockedForReconciliation = false;

        // process related Billing Schedules
        for ( CS_Billing_Schedule_Item__c currentBillSchedule : billingScheduleList ) {
            if ( currentBillSchedule.Is_Open__c ) {
                hasOpenBillSch = true;
                hasAllLinesClosed = false;
            }
            if ( currentBillSchedule.Is_Closed__c )  {
                hasAllLinesOpen = false;
            }
            if ( currentBillSchedule.IsForecast__c ) {
                hasAllLinesOpen = false;
            }

            if ( currentBillSchedule.Status__c == 'Pending' || currentBillSchedule.Status__c == 'Ready' ) {
                lockedForReconciliation = true;
            }
        }

        Boolean startDateAfterToday;
        Boolean endDateBeforeToday;
        Datetime todaysDateTime = DateTime.now();
        
        // find start/end datetime
        for ( cscfga__Attribute__c currentAttribute : salesOrderLinesAttrList ) {
            system.debug('#### currentAttribute.cscfga__Value__c '+currentAttribute.Name+' - '+currentAttribute.cscfga__Value__c);
            if ( currentAttribute.Name == 'Flight Begin Date Time Selected'){
                DateTime flightBeginDateTime;
                
                if(currentAttribute.cscfga__Value__c.split(' ').size() > 2){
                    flightBeginDateTime = CS_utl_Datetime.getTimezoneOffset(currentAttribute.cscfga__Value__c);
                } else {
                    flightBeginDateTime = DateTime.valueOf(currentAttribute.cscfga__Value__c+':00');
                }
                
                if ( flightBeginDateTime > todaysDateTime ) {
                    startDateAfterToday = true;
                } else {
                    startDateAfterToday = false;
                }
            }


            if ( currentAttribute.Name == 'Flight End Date Time Selected'){
                DateTime flightEndDateTime;

                if(currentAttribute.cscfga__Value__c.split(' ').size() > 2){
                    flightEndDateTime = CS_utl_Datetime.getTimezoneOffset(currentAttribute.cscfga__Value__c);
                } else {
                    flightEndDateTime = DateTime.valueOf(currentAttribute.cscfga__Value__c+':00');
                }
                
                if ( flightEndDateTime.addDays(14) > todaysDateTime ) {
                    endDateBeforeToday = false;
                } else {
                    endDateBeforeToday = true;
                }
            }
        }
        
        // FI status
        Boolean isActiveLine = fiList[0].csdf__Status__c != CS_const_SalesOrder.FulfilmentItemStatus_Draft 
                               && fiList[0].csdf__Status__c != CS_const_SalesOrder.FulfilmentItemStatus_Inactive 
                               && fiList[0].csdf__Status__c != CS_const_SalesOrder.FulfilmentItemStatus_Ready;

        //final status check
        String finalStatus = 'Locked';
        if ( endDateBeforeToday == true && isActiveLine) {
            finalStatus = 'Partially Locked';
        }
        // Partially Locked - Line is partially Invoiced & End date is in the future and Line is not locked for reconciliation
        if ((endDateBeforeToday == false || !isActiveLine)) {
            finalStatus = 'Partially Locked';
        }
        if (pc.Sales_Order__r.Is_Programmatic__c) {
            // Unlocked - Non-delivering lines with future start dates
            if ( startDateAfterToday == true && (endDateBeforeToday == false || !isActiveLine) ) {
                finalStatus = 'Unlocked';
            }
        }
        else {
            // Unlocked - Line is NOT Invoiced & End date is in the future and Line is not locked for reconciliation
            if ( hasAllLinesOpen && startDateAfterToday == true && (endDateBeforeToday == false || !isActiveLine) && lockedForReconciliation == false ) {
                finalStatus = 'Unlocked';
            }
        }
        
        if (!pc.Sales_Order__r.Is_Programmatic__c) {
            // IF Sales Order Line is Partially Locked or Unlocked ALL related Billing Schedule and Rev Rec Schedule with Status = Open is set On Hold for IFC
            if ( finalStatus == 'Unlocked' || finalStatus == 'Partially Locked' ) {
                updateSchedules(configId, finalStatus, billingScheduleList);
            }
        }

        System.debug('#### Unlock Controller / hasAllLinesClosed - '+hasAllLinesClosed+' / lockedForReconciliation - '+lockedForReconciliation);
        System.debug('#### Unlock Controller / hasOpenBillSch - '+hasOpenBillSch+' / endDateBeforeToday - '+endDateBeforeToday);
        System.debug('#### Unlock Controller / hasAllLinesOpen - '+hasAllLinesOpen+' / startDateAfterToday - '+startDateAfterToday);
        System.debug('#### Unlock Controller / finalStatus - '+finalStatus);
        
        return JSON.serialize(finalStatus);
    }


    public static void updateSchedules(String configId, String finalStatus, List<CS_Billing_Schedule_Item__c> billingScheduleItemList){
        List<CS_Revenue_Schedule__c> revRecScheduleList = [SELECT 
                                                                       Id, Name , Under_IFC__c
                                                                    FROM 
                                                                        CS_Revenue_Schedule__c
                                                                    WHERE 
                                                                        Product_Configuration__c = :configId ];
        
         // NEW - We only need to update the billing schedule Headers here.
         // CPS 30/10/2018
         List<CS_Billing_Schedule__c> billingScheduleList = [SELECT 
                                                            Id, Name , Under_IFC__c
                                                         FROM 
                                                             CS_Billing_Schedule__c
                                                         WHERE 
                                                            Product_Configuration__c = :configId ];



        List<CS_Revenue_Schedule__c> revRecSchedulesUpdate = new List<CS_Revenue_Schedule__c>();
        for (CS_Revenue_Schedule__c currentRevRecSch : revRecScheduleList ) {
            if ( currentRevRecSch.Under_IFC__c == false ){
                currentRevRecSch.Under_IFC__c = true;
                revRecSchedulesUpdate.add(currentRevRecSch);
            }
        }
        
        if ( !revRecSchedulesUpdate.isEmpty() ){
            UPDATE revRecSchedulesUpdate;
        }


        // CPS 30/10/18 - We just need to update the Billing Schedule Headers here, not each item.

        List<CS_Billing_Schedule__c> billSchedulesUpdate = new List<CS_Billing_Schedule__c>();
        for (CS_Billing_Schedule__c currentBillSch : billingScheduleList ) {
            if ( currentBillSch.Under_IFC__c == false ){
                currentBillSch.Under_IFC__c = true;
                billSchedulesUpdate.add(currentBillSch);
            }
        }
        
        if ( !billSchedulesUpdate.isEmpty() ){
            UPDATE billSchedulesUpdate;
        }
    }
}
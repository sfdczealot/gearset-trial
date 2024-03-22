trigger AllSalesOrderTriggers on csmso__Sales_Order__c (before insert, after insert, before update, after update,before delete) {
             
    // Check the Custom settings to see if we are running triggers
    if (!CS_TriggerHandler.GetTriggersEnabled() || CS_utl_user.isDeactivatedForDataMigration)
        return;

    // DISPATCHER TRIGGER PATTERN
    if(CS_utl_user.isTriggerActiveForMe()) {
        CS_ProcessDispatcher dispatcher = new CS_ProcessDispatcher();

        if(Trigger.isAfter) { 
            if(Trigger.isUpdate) {
                dispatcher.addProcesses(new List<CS_ProcessBase> {
                    new CS_P_UpsertFulfilment(Trigger.oldMap),
                    new CS_P_approvalSnapshotNew(Trigger.oldMap),
                    new CS_P_PrimarySOChange(Trigger.oldMap),
                    new CS_P_SOBillAdvertiserAgencyChange(Trigger.oldMap),
                    new CS_P_UpdatePrimarySO(Trigger.oldMap),
                    new CS_P_SOApprovalFieldsUpdate(Trigger.oldMap),
                    new CS_P_PrimarySOInProgressOppQualified(Trigger.oldMap),
                    new CS_P_OMCApprovalEmail(Trigger.oldMap),
                    new CS_P_SOReservationExpirationDate(Trigger.oldMap),
                    new UpdateFulfilmentItemSyncToNS(Trigger.newMap,Trigger.OldMap),
                    new RejectSOApprovalProcess(Trigger.newMap)
                });
                
              //  SalesOrderEventHandler.publishEvent(Trigger.new,Trigger.newMap,Trigger.OldMap);

                if (trigger.size > 0) {
                    CSPOFA.Events.emit('update', Trigger.newMap.keySet());
                }
            }
            
            if(Trigger.isInsert) {
                dispatcher.addProcesses(new List<CS_ProcessBase> {
                    new CS_P_UpsertFulfilment(Trigger.oldMap),
                    new CS_P_PrimarySOChange(Trigger.oldMap),
                    new CS_P_UpdatePrimarySO(Trigger.oldMap)
                });
            }
            
         //   SalesOrderEventHandler.publishEvent(Trigger.new,null,null);
        }
        
        if(Trigger.isBefore) {
            if(Trigger.IsDelete) {
               dispatcher.addProcesses(new List<CS_ProcessBase> {
                    new RestrictSODeletionCreation(Trigger.old)                    
                });
            }
            if(Trigger.isUpdate) {
                dispatcher.addProcesses(new List<CS_ProcessBase> {
                    new CS_P_SOMarket(Trigger.oldMap),
                    new CS_P_SOPriceRecalculation(Trigger.oldMap),
                    new CS_P_SOReadyToBook(Trigger.oldMap),
                    new CS_P_SORejected(Trigger.oldMap),
                    new CS_P_SORejectComment(Trigger.oldMap),
                    new CS_P_SOStatusCalculateTime(Trigger.oldMap),
                    new CS_P_SOApprovalCheckCalculateTime(Trigger.oldMap),
                    new SOPaymentTermRestriction(Trigger.newMap,Trigger.OldMap)
                });
            }
            
            if(Trigger.isInsert) {
                dispatcher.addProcesses(new List<CS_ProcessBase> {
                    new CS_P_SetPrimarySO(),
                    new RestrictSODeletionCreation(Trigger.new)                    
                });
            }
        }
        
        dispatcher.dispatch();
    }
    // DISPATCHER TRIGGER PATTERN
    
    if(CS_utl_user.isTriggerActiveForMe()) {
        if (trigger.isBefore && trigger.isInsert) {
            Set<Id> activeOppIds = new Set<Id> ();
            Set<Id> userids = new set<id>();
            CS_Custom_Settings__c mcs = CS_Custom_Settings__c.getInstance();

            
            //############################################
            // Get the active opps here
            //############################################
            for (csmso__Sales_Order__c so : trigger.new) {
                System.debug('***** so.csmso__Opportunity__c ' + so.csmso__Opportunity__c);
                activeOppIds.add(so.csmso__Opportunity__c);
            }

            
            sobjectHelper helper = new sObjecthelper('Opportunity');
            string fields = helper.getFieldListAsCSV(false);
            string SOQL = 'Select ' + fields + ' from opportunity where Id in :activeOppIds';
            map<id,sObject> oppsById = new map<id,sObject>(Database.Query(SOQL));
            System.debug('***** oppsById ' + oppsById);
            
            //############################################
            // Perform Property Mapping from the Opp to the SO
            //############################################
            PropertyMappingEngine.FieldMappingPair[] fmps = new PropertyMappingEngine.FieldMappingPair[]{};  
            for (csmso__Sales_Order__c so : trigger.new)
            {
                if (so.Related_Sales_Order__c != null || so.External_Order_Id__c != null){ // prevent running OppToSalesOrder mapping for cloned SOs 
                    continue;                           // (OppToSalesOrderCloning mapping should have been run for them)
                }

                Opportunity opp = (Opportunity)oppsById.get(so.csmso__Opportunity__c);
                
                PropertyMappingEngine.FieldMappingPair pair = new PropertyMappingEngine.FieldMappingPair();
                pair.Source = opp;
                pair.Destinations = new sObject[]{so};
                fmps.add(pair);
            }
            
            sobject[] toUpdate = PropertyMappingEngine.mapsObjectFields('OppToSalesOrder', fmps);
            // The update happens after the trigger;

            //########################
            // Set Rate Card on SO
            // added 11/09/2018 - Ivan Ravnjak
            //########################
            CS_TriggerHandler.execute(new CS_SalesOrderDelegate());
        }

        //########################
        // Set Rate Card Filtering record
        // added 21/09/2018 - Ivan Ravnjak
        //########################
        if (trigger.isAfter && trigger.isInsert) {
            CS_TriggerHandler.execute(new CS_SalesOrderDelegate());
        }

        //########################
        // Update So fields from RC
        // added 11/09/2018 - Ivan Ravnjak
        //########################
        if (trigger.isBefore && trigger.isUpdate) {
            CS_TriggerHandler.execute(new CS_SalesOrderDelegate());
        }

        if (trigger.isAfter && trigger.isUpdate) {
            CS_TriggerHandler.execute(new CS_SalesOrderDelegate());
        }
                
    }
}
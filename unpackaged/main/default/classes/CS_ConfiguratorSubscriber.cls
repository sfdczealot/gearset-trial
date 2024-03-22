global class CS_ConfiguratorSubscriber extends csutil.ASubscriber {
    public static Map<String, Billing_Schedule_Rule__c> billingRules {
        get {
            if(billingRules == null) {
                billingRules = new Map<String, Billing_Schedule_Rule__c>();
                for(Billing_Schedule_Rule__c bsr : [Select Id, Name, RecordType.DeveloperName From Billing_Schedule_Rule__c]) {
                    billingRules.put(bsr.RecordType.DeveloperName + '.' + bsr.Name, bsr);
                }
            }
            return billingRules;
        }
        set;
    }

    public override void onMessage(String topic, String subject, Map<String, Object> payload) {
//        System.debug(LoggingLevel.WARN, '**** Topic: ' + topic);
//        System.debug(LoggingLevel.WARN, '**** Subject: ' + subject);
//        System.debug(LoggingLevel.WARN, '**** Payload: ' + JSON.serialize(payload));

        if (subject.equals('AfterSaveV2')) {
            System.debug(LoggingLevel.WARN, '***** Entered AfterSaveV2');

            if (payload.get('Container') instanceof cscfga__Product_Basket__c) {
                Map<Id, cscfga__Product_Configuration__c> currentProductConfigurations =
                        new Map<Id, cscfga__Product_Configuration__c>((List<cscfga__Product_Configuration__c>) payload.get('AllConfigs'));

                Map<Id, cscfga__Product_Configuration__c> configs = new Map<Id, cscfga__Product_Configuration__c>([
                        SELECT Id, Line_ID__c, Line_ID_Number__c, FLAG_Running_in_MLE__c
                        FROM cscfga__Product_Configuration__c
                        WHERE Id IN :currentProductConfigurations.keySet()
                ]);

                Map<String, cscfga__Attribute__c> attributes = getAttributes(payload);

                if (!attributes.containsKey('FLAG Running in MLE') || !attributes.get('FLAG Running in MLE').cscfga__Value__c.equalsIgnoreCase('Yes')) {
                    Map<Id, csmso__Sales_Order__c> salesOrders = getSalesOrders(new Set<Id>{
                            ((cscfga__Product_Basket__c) payload.get('Container')).Id
                    });

                    //CS_ScheduleService.generateSchedules(salesOrders.keySet(), currentProductConfigurations.keySet());

                    Set<Id> salesOrdersForApproval = new Set<Id>();
                    for(csmso__Sales_Order__c salesOrder : salesOrders.values()){
                        if(salesOrder.csmso__Status__c != CS_const_SalesOrder.Status_Booked){
                            salesOrdersForApproval.add(salesOrder.Id);
                        }
                    }
                    CS_ApprovalService.checkApprovals(salesOrdersForApproval);
                }

                Map<Id, cscfga__Attribute__c> attrsToUpdate = new Map<Id, cscfga__Attribute__c>();

                //TO SUPPORT PROP-453
                List<csdf__Fulfilment_Item__c> fisToUpdate = new List<csdf__Fulfilment_Item__c>();
                Map<Id, csdf__Fulfilment_Item__c> FIWithPCReferenceMap = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id, Product_Configuration__c FROM csdf__Fulfilment_Item__c WHERE Product_Configuration__c IN: configs.keySet()]);

                Map<Id, cscfga__Product_Configuration__c> configsToUpdate = new Map<Id, cscfga__Product_Configuration__c>();
                for (cscfga__Product_Configuration__c config : configs.values()) {
                    if (String.isBlank(config.Line_ID__c)) {
                        config.Line_ID__c = config.Line_ID_Number__c;
                        configsToUpdate.put(config.Id, config);
                    }

                    if (attributes.containsKey('Line ID') && (String.isBlank(attributes.get('Line ID').cscfga__Value__c) || attributes.get('Line ID').cscfga__Value__c != config.Line_ID__c)) {
                        cscfga__Attribute__c att = attributes.get('Line ID');
                        att.cscfga__Value__c = config.Line_ID_Number__c;
                        attrsToUpdate.put(att.Id, att);
                    }

                    //TO SUPPORT PROP-453 and keeping FI reference in place
                    if ( attributes.containsKey('Fulfilment Item') && String.isNotBlank(attributes.get('Fulfilment Item').cscfga__Display_Value__c) ) {
                        Id pcFulfilmentItemID = Id.valueOf(attributes.get('Fulfilment Item').cscfga__Display_Value__c);

                        if ( !FIWithPCReferenceMap.containsKey(pcFulfilmentItemID) ) {
                            fisToUpdate.add(
                                    new csdf__Fulfilment_Item__c (
                                        Id = pcFulfilmentItemID,
                                        Product_Configuration__c = config.Id
                                    )
                            );
                        }
                    }


                    if (config.FLAG_Running_in_MLE__c) {
                        config.FLAG_Running_in_MLE__c = false;
                        configsToUpdate.put(config.Id, config);
                    }
                    if (attributes.containsKey('FLAG Running in MLE')
                            && (attributes.get('FLAG Running in MLE').cscfga__Value__c.equalsIgnoreCase('true') || attributes.get('FLAG Running in MLE').cscfga__Value__c.equalsIgnoreCase('Yes'))) {
                        cscfga__Attribute__c att = attributes.get('FLAG Running in MLE');
                        att.cscfga__Value__c = 'No';
                        attrsToUpdate.put(att.Id, att);
                    }
                }

                update attrsToUpdate.values();
                update configsToUpdate.values();
                update fisToUpdate;
            }
        }

        else if (subject.equals('BeforeSaveV2')) {
            System.debug(LoggingLevel.WARN, '***** Entered BeforeSaveV2');

            if(payload.get('Container') instanceOf cscfga__Product_Basket__c) {
                List<cscfga__Product_Configuration__c> currentProductConfigurations = (List<cscfga__Product_Configuration__c>) payload.get('AllConfigs');
                Map<String, cscfga__Attribute__c> attributes = getAttributes(payload);

                Map<String, Object> currentTargetingByConfigId = new Map<String, Object>();
                for(cscfga__Product_Configuration__c config : currentProductConfigurations) {
                    config.Last_Changed_Date__c = System.now();
                    if(attributes.containsKey('FLAG Running in MLE') && attributes.get('FLAG Running in MLE').cscfga__Value__c.equalsIgnoreCase('Yes')) {
                        config.FLAG_Running_in_MLE__c = true;
                    }

                    if(attributes.containsKey('Fulfilment Item Status')) {
                        String fulfilmentItemStatus = attributes.get('Fulfilment Item Status').cscfga__Value__c;
                        config.IFC_Change__c = String.isBlank(fulfilmentItemStatus) || fulfilmentItemStatus.equalsIgnoreCase('Draft') ? 'No' : 'Yes';
                    }

                    if(attributes.containsKey('Flight Begin Date Time Selected')) {
                        DateTime flightDateGmt = CS_utl_Datetime.getTimezoneOffset(attributes.get('Flight Begin Date Time Selected').cscfga__Value__c);
                        config.put('Flight_Begin_Logged_User_Timezone__c', flightDateGmt);
                    }

                    if(attributes.containsKey('Flight End Date Time Selected')) {
                        DateTime flightDateGmt = CS_utl_Datetime.getTimezoneOffset(attributes.get('Flight End Date Time Selected').cscfga__Value__c);
                        config.put('Flight_End_Logged_User_Timezone__c', flightDateGmt);
                    }

                    if(attributes.containsKey('Flight Begin Date Time')) {
                        DateTime flightDateGmt = CS_DateUtils.parseDateTime(attributes.get('Flight Begin Date Time').cscfga__Value__c);
                        config.put('csmso__Flight_Begin__c', flightDateGmt);
                    }

                    if(attributes.containsKey('Flight End Date Time')) {
                        DateTime flightDateGmt = CS_DateUtils.parseDateTime(attributes.get('Flight End Date Time').cscfga__Value__c);
                        config.put('csmso__Flight_End__c', flightDateGmt);
                    }

                    if(attributes.containsKey('Served By')) {
                        String servedBy = attributes.get('Served By').cscfga__Value__c;
                        if(servedBy.equalsIgnoreCase('Megaphone')){
                            config.Requires_Manual_Reconciliation__c = true;
                        }
                    }

                    if(attributes.containsKey('FLAG Run On Open')) {
                        cscfga__Attribute__c flagRunOnOpen = attributes.get('FLAG Run On Open');
                        flagRunOnOpen.cscfga__Value__c = 'Yes';
                    }

                    if ((config.cscfga__Product_Family__c == 'Ad Served' || config.cscfga__Product_Family__c == 'Programmatic Guaranteed')
                            && attributes.containsKey('Current Targetings')) {
                        String currentTargeting = attributes.get('Current Targetings').cscfga__Value__c;
                        currentTargetingByConfigId.put(config.Id, currentTargeting);
                    }

                    if(attributes.containsKey('Billing Calendar') && String.isNotBlank(attributes.get('Billing Calendar').cscfga__Value__c)) {
                        String calendarType = attributes.get('Billing Calendar').cscfga__Value__c;

                        config.Billing_Schedule_Rule__c = billingRules.get(CS_const_BillingScheduleRule.RecordType_DeveloperName_DigitalBillingRule + '.' + (calendarType == CS_const_BillingScheduleItem.BillingCalendar_Standard ?
                                CS_const_BillingScheduleRule.Type_MonthlyProRataStandard : CS_const_BillingScheduleRule.Type_MonthlyProRataBroadcast)).Id;
                        if(attributes.containsKey('Billing Schedule Rule')) {
                            attributes.get('Billing Schedule Rule').cscfga__Value__c = config.Billing_Schedule_Rule__c;
                        }
                        config.Revenue_Schedule_Rule__c = billingRules.get(CS_const_BillingScheduleRule.RecordType_DeveloperName_RevenueRecognitionRule + '.' + CS_const_BillingScheduleRule.Type_MonthlyProRataStandard).Id;
                        if(attributes.containsKey('Rev Rec Schedule Rule')) {
                            attributes.get('Rev Rec Schedule Rule').cscfga__Value__c = config.Revenue_Schedule_Rule__c;
                        }
                    }
                }

                if (!currentTargetingByConfigId.isEmpty()) {
                    Map<String, String> targetingListForComplianceByConfigId = CS_CurrentTargetingsTransformer.transformToTargetingList(currentTargetingByConfigId);
                    for(cscfga__Product_Configuration__c config : currentProductConfigurations) {
                        if (attributes.containsKey('Targeting List for Compliance')) {
                            cscfga__Attribute__c currentTargetingAttr = attributes.get('Targeting List for Compliance');
                            currentTargetingAttr.cscfga__Value__c = targetingListForComplianceByConfigId.get(config.Id);
                        }
                    }
                }
            }
        }

        else if (subject.equals('Deleted')) {
            System.debug(LoggingLevel.WARN, '***** Entered Deleted');
        }
    }

    public Map<String, cscfga__Attribute__c> getAttributes(Map<String, Object> payload) {
        Map<String, cscfga__Attribute__c> attMap = new Map<String, cscfga__Attribute__c>();
        List<cscfga__Attribute__c> attributes = (List<cscfga__Attribute__c>) payload.get('AllAttrs');
        for(cscfga__Attribute__c att : attributes) {
            attMap.put(att.Name, att);
        }

        return attMap;
    }

    public Map<Id, csmso__Sales_Order__c> getSalesOrders(Set<Id> basketIds) {
        Map<Id, csmso__Sales_Order__c> salesOrders = new Map<Id, csmso__Sales_Order__c>();
        String queryString = CS_utl_Soql.buildQuery(
                Schema.cscfga__Product_Basket__c.getSObjectType(),
                new Map<String, Set<Id>>{'Id' => basketIds},
                CS_utl_Array.join(new List<String>{
                        CS_utl_SObject.getFieldList(csmso__Sales_Order__c.getSobjectType(), 'csmso__Sales_Order__r.')
                }, ','
                )
        );

        for(cscfga__Product_Basket__c basket : (List<cscfga__Product_Basket__c>) Database.Query(queryString)) {
            salesOrders.put(basket.csmso__Sales_Order__c, basket.csmso__Sales_Order__r);
        }

        return salesOrders;
    }
    public class ConfigurationException extends Exception {}
}
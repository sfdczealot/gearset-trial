/*
 * Translating Google API messages to the language understandable to a end user
 * Updating Fulfilment record with the Google API message that is captured on the incomingMessage (JSON attachment)
 * and translating Google API message using the mapping in the Custom setting
 */

global with sharing class FulfilmentExceptionEvent implements csam.ObserverApi.IObserver {
    static List<FulfilmentExceptionEventMapping__c> exceptionEventMapping {
        get {
            if (exceptionEventMapping == null) {
                exceptionEventMapping = FulfilmentExceptionEventMapping__c.getAll().values();
            }
            return exceptionEventMapping;
        }
        set;
    }

    static Map<Id, csam__ObjectGraph_Callout_Handler__c> handlers {
        get {
            if (handlers == null) {
                handlers = new Map<Id, csam__ObjectGraph_Callout_Handler__c>([
                        SELECT Id, Handler_Class__c
                        FROM csam__ObjectGraph_Callout_Handler__c
                ]);
            }
            return handlers;
        }
        set;
    }

    static CS_Custom_Settings__c csCustomSettings {
        get {
            if (csCustomSettings == null) {
                csCustomSettings = CS_Custom_Settings__c.getInstance();
            }
            return csCustomSettings;
        }
        set;
    }

    @TestVisible
    Map<Id, Message> messages {
        get {
            if (messages == null) {
                messages = new Map<Id, Message>();
            }
            return messages;
        }
        set;
    }

    @TestVisible
    Set<Id> fulfilmentIdsMsg {
        get {
            if (fulfilmentIdsMsg == null) {
                fulfilmentIdsMsg = new Set<Id>();
                for (Message msg : messages.values()) {
                    if (String.isNotBlank(msg.fulfilmentId)) {
                        fulfilmentIdsMsg.add(msg.fulfilmentId);
                    }
                }
            }
            return fulfilmentIdsMsg;
        }
        set;
    }

    @TestVisible
    Set<Id> fulfilmentIds {
        get {
            if (fulfilmentIds == null) {
                fulfilmentIds = new Set<Id>(fulfilmentIdsMsg);
                for (csdf__Fulfilment_Item__c fi : fulfilmentItemsMsg) {
                    fulfilmentIds.add(fi.csdf__Fulfilment__c);
                }
            }
            return fulfilmentIds;
        }
        set;
    }

    @TestVisible
    Set<Id> fulfilmentItemIdsMsg {
        get {
            if (fulfilmentItemIdsMsg == null) {
                fulfilmentItemIdsMsg = new Set<Id>();
                for (Message msg : messages.values()) {
                    fulfilmentItemIdsMsg.addAll(msg.fulfilmentItemIds);
                }
            }
            return fulfilmentItemIdsMsg;
        }
        set;
    }

    @TestVisible
    Set<Id> salesOrderIds {
        get {
            if (salesOrderIds == null) {
                salesOrderIds = new Set<Id>();
                for (csdf__Fulfilment__c fulfilment : fulfilments.values()) {
                    salesOrderIds.add(fulfilment.Sales_Order__c);
                }
            }
            return salesOrderIds;
        }
        set;
    }

    @TestVisible
    List<csdf__Fulfilment_Item__c> fulfilmentItemsMsg {
        get {
            if (fulfilmentItemsMsg == null) {
                fulfilmentItemsMsg = [
                        SELECT Id, csdf__Fulfilment__c, Sales_Order__c
                        FROM csdf__Fulfilment_Item__c
                        WHERE Id = :fulfilmentItemIdsMsg
                ];
            }
            return fulfilmentItemsMsg;
        }
        set;
    }

    @TestVisible
    List<csdf__Fulfilment__c> fulfilmentsMsg {
        get {
            if (fulfilmentsMsg == null) {
                fulfilmentsMsg = [
                        SELECT Id, csdf__Fulfilment_Message_Status__c, Error_Message__c, Message_Translated__c, Sales_Order__c,
                                csdf__Is_Programmatic__c, csdf__Status__c, Negotiation_Status__c, Proposal_Status__c
                        FROM csdf__Fulfilment__c
                        WHERE Id = :fulfilmentIdsMsg
                        FOR UPDATE
                ];
            }
            return fulfilmentsMsg;
        }
        set;
    }

    @TestVisible
    Map<Id, List<csdf__Fulfilment_Item__c>> fulfilmentItems {
        get {
            if (fulfilmentItems == null) {
                fulfilmentItems = CS_utl_Fulfilment.getFulfilmentItems(fulfilmentIds);
            }
            return fulfilmentItems;
        }
        set;
    }

    @TestVisible
    Map<Id, csdf__Fulfilment_Item__c> fulfilmentItemsById {
        get {
            if (fulfilmentItemsById == null) {
                fulfilmentItemsById = new Map<Id, csdf__Fulfilment_Item__c>();
                for (List<csdf__Fulfilment_Item__c> fis : fulfilmentItems.values()) {
                    fulfilmentItemsById.putAll(fis);
                }
            }
            return fulfilmentItemsById;
        }
        set;
    }

    @TestVisible
    Map<Id, csdf__Fulfilment__c> fulfilments {
        get {
            if (fulfilments == null) {
                fulfilments = new Map<Id, csdf__Fulfilment__c> (
                [
                        SELECT Id, csdf__Fulfilment_Message_Status__c, Error_Message__c, Message_Translated__c, Sales_Order__c,
                                csdf__Is_Programmatic__c, csdf__Status__c, Negotiation_Status__c, Proposal_Status__c
                        FROM csdf__Fulfilment__c
                        WHERE Id = :fulfilmentIds
                        FOR UPDATE
                ]);
            }
            return fulfilments;
        }
        set;
    }

    @TestVisible
    Map<Id, List<CS_Billing_Schedule_Item__c>> billingScheduleItems {
        get {
            if (billingScheduleItems == null) {
                billingScheduleItems = new Map<Id, List<CS_Billing_Schedule_Item__c>>();
                for (CS_Billing_Schedule_Item__c bsi : [
                        SELECT Id, Status__c, Billing_Schedule__c,
                                Sales_Order__c, Product_Configuration__c, Valid_for_Auto_Cancellation__c
                        FROM CS_Billing_Schedule_Item__c
                        WHERE Sales_Order__c = :salesOrderIds
                ]) {
                    if (!billingScheduleItems.containsKey(bsi.Sales_Order__c)) {
                        billingScheduleItems.put(bsi.Sales_Order__c, new List<CS_Billing_Schedule_Item__c>());
                    }
                    billingScheduleItems.get(bsi.Sales_Order__c).add(bsi);
                }
            }
            return billingScheduleItems;
        }
        set;
    }

    @TestVisible
    Map<Id, List<CS_Revenue_Schedule_Item__c>> revenueScheduleItems {
        get {
            if (revenueScheduleItems == null) {
                revenueScheduleItems = new Map<Id, List<CS_Revenue_Schedule_Item__c>>();
                for (CS_Revenue_Schedule_Item__c rsi : [
                        SELECT Id, Status__c, Revenue_Schedule__c,
                                Sales_Order__c, Product_Configuration__c, Valid_for_Auto_Cancellation__c
                        FROM CS_Revenue_Schedule_Item__c
                        WHERE Sales_Order__c = :salesOrderIds
                ]) {
                    if (!revenueScheduleItems.containsKey(rsi.Sales_Order__c)) {
                        revenueScheduleItems.put(rsi.Sales_Order__c, new List<CS_Revenue_Schedule_Item__c>());
                    }
                    revenueScheduleItems.get(rsi.Sales_Order__c).add(rsi);
                }
            }
            return revenueScheduleItems;
        }
        set;
    }

    @TestVisible
    Map<Id, csmso__Sales_Order__c> salesOrders {
        get {
            if (salesOrders == null) {
                salesOrders = new Map<Id, csmso__Sales_Order__c>([
                        SELECT Id, Callout_Type__c, SO_Lines_Ad_Server_Items__c, csmso__Status__c, Is_Programmatic__c, Primary_Sales_Order__c, csmso__Opportunity__c, Sold__c
                        FROM csmso__Sales_Order__c
                        WHERE Id = :salesOrderIds
                        FOR UPDATE
                ]);
            }
            return salesOrders;
        }
        set;
    }

    Map<Id, List<CSPOFA__Orchestration_Step__c>> steps {
        get {
            if(steps == null) {
                steps = new Map<Id, List<CSPOFA__Orchestration_Step__c>>();
                for(CSPOFA__Orchestration_Step__c step : [SELECT Id, Name, CSPOFA__Status__c, CSPOFA__External_Id__c FROM CSPOFA__Orchestration_Step__c WHERE CSPOFA__external_id__c IN :salesOrderIds AND CSPOFA__Status__c = 'Waiting For Feedback']) {
                    if(!steps.containsKey(step.CSPOFA__external_id__c)) {
                        steps.put(step.CSPOFA__external_id__c, new List<CSPOFA__Orchestration_Step__c>());
                    }

                    steps.get(step.CSPOFA__external_id__c).add(step);
                }
            }

            return steps;
        }
        set;
    }

    @TestVisible
    Map<String, Map<Id, SObject>> objectsToUpdate {
        get {
            if (objectsToUpdate == null) {
                objectsToUpdate = new Map<String, Map<Id, SObject>>();
            }
            return objectsToUpdate;
        }
        set;
    }

    private void addToUpdate(List<SObject> objs) {
        for (SObject obj : objs) {
            String objName = obj.getSObjectType().getDescribe().getName();
            if (!objectsToUpdate.containsKey(objName)) {
                objectsToUpdate.put(objName, new Map<Id, SObject>());
            }

            objectsToUpdate.get(objName).put(obj.Id, obj);
        }
    }

    private CS_LogWorker log {
        get {
            if (log == null) {
                log = CS_LogWorker.getInstance();
            }
            return log;
        }
        set;
    }

    private Boolean success {
        get {
            if (success == null) {
                success = true;
            }
            return success;
        }
        set;
    }

    global void execute(csam.ObserverApi.Observable o, Object arg) {
        try {
            if (o instanceof csam.InboundMessageObservable) {
                csam.InboundMessageObservable observable = (csam.InboundMessageObservable) o;

                for (csam__Incoming_Message__c incomingMessage : observable.getMessages()) {
                    if (incomingMessage.csam__Final_Chunk__c && incomingMessage.csam__Outgoing_Message__c != null &&
                            incomingMessage.csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__c != null &&
                            (incomingMessage.csam__Status__c == 'Integration Error'
                                    || incomingMessage.csam__Status__c == 'Process Error'
                                    || incomingMessage.csam__Status__c == 'Processed')) {
                        if (!messages.containsKey(incomingMessage.csam__Outgoing_Message__c)) {
                            messages.put(incomingMessage.csam__Outgoing_Message__c, new Message(incomingMessage));
                        }
                    }
                }

                if (!messages.isEmpty()) {
                    for (csam__Outgoing_Message_Record__c outgoingMessageRecord : [
                            SELECT csam__Object_Record_Id__c, csam__Outgoing_Message__c, csam__Object_Name__c
                            FROM csam__Outgoing_Message_Record__c
                            WHERE csam__Outgoing_Message__c IN :messages.keySet()
                            AND (csam__Object_Name__c = 'csdf__Fulfilment_Item__c' OR csam__Object_Name__c = 'csdf__Fulfilment__c')
                    ]) {
                        messages.get(outgoingMessageRecord.csam__Outgoing_Message__c).addRecord(outgoingMessageRecord);
                    }

                    for (Message msg : messages.values()) {
                        List<csdf__Fulfilment__c> fulfilmentsForMessage = msg.getFulfilments(fulfilments, fulfilmentItemsById);
                        for (csdf__Fulfilment__c fulfilment : fulfilmentsForMessage) {
                            csmso__Sales_Order__c salesOrder = salesOrders.get(fulfilment.Sales_Order__c);
                            if (salesOrder != null) {
                                List<csdf__Fulfilment_Item__c> fItems = fulfilmentItems.get(fulfilment.Id);

                                Type handlerType = Type.forName(msg.handlerClass);
                                HandlerWorker handler = (HandlerWorker) handlerType.newInstance();
                                handler.init(msg, salesOrder, fulfilment, fItems, billingScheduleItems.get(salesOrder.Id), revenueScheduleItems.get(salesOrder.Id), steps.get(salesOrder.Id), this.log);
                                addToUpdate(handler.doWork());
                                addToUpdate(new List<SObject>{
                                        fulfilment, salesOrder
                                });
                            }
                        }
                    }

                    for (String sObjectType : objectsToUpdate.keySet()) {
                        if (!objectsToUpdate.get(sObjectType).isEmpty()) {
                            List<Database.SaveResult> results = Database.update(objectsToUpdate.get(sObjectType).values(), false);
                            for (Integer i = 0; i < results.size(); i++) {
                                if (!results.get(i).isSuccess()) {
                                    log.addMessage(objectsToUpdate.get(sObjectType).values().get(i), results.get(i));
                                    success = false;
                                }
                            }
                        }
                    }
                }
            }
        }

        catch (Exception e) {
            success = false;

            for (Message msg : messages.values()) {
                log.addMessage(msg.messageId, e.getMessage(), e.getTypeName(), msg.handlerType, e.getStackTraceString());
            }

            if (salesOrderIds != null) {
                List<csmso__Sales_Order__c> soToUpdate = new List<csmso__Sales_Order__c>();
                for (Id salesOrderId : salesOrderIds) {
                    if (String.isNotBlank(salesOrderId)) {
                        csmso__Sales_Order__c so = new csmso__Sales_Order__c(
                                Id = salesOrderId,
                                Callout_Type__c = null,
                                csmso__Process_Message_Type__c = 'error',
                                Error_Message__c = 'Unknown Error - Contact your System Administrator',
                                csmso__Process_Message__c = 'Unknown Error - Contact your System Administrator',
                                Loading_Screen__c = 'Off'
                        );

                        soToUpdate.add(so);
                    }
                }

                if (!soToUpdate.isEmpty()) {
                    update soToUpdate;
                }
            }
        }

        if (!success || !log.logMessages.isEmpty()) {
            log.save('FulfilmentExceptionEvent', 'Integration', null, false, null);
        }
    }

    global class Message {
        public Id messageId { get; set; }
        public String message { get; set; }
        public String handlerType { get; set; }
        public String handlerClass { get; set; }
        public Id fulfilmentId { get; set; }
        public Set<Id> fulfilmentItemIds { get; set; }

        global Message(csam__Incoming_Message__c inMessage) {
            this.messageId = inMessage.csam__Outgoing_Message__c;
            this.message = resolveErrorMessage(inMessage);
            this.handlerType = inMessage.csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__r.Name;
            this.handlerClass = FulfilmentExceptionEvent.handlers.get(inMessage.csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__c).Handler_Class__c;
            this.fulfilmentItemIds = new Set<Id>();
        }

        public Boolean isError(List<String> ignoreErrors) {
            return String.isNotBlank(this.message) && !isIgnoredError(ignoreErrors);
        }

        public Boolean isIgnoredError(List<String> ignoreErrors) {
            Boolean isError = String.isNotBlank(this.message);
            if (isError) {
                for (String ignoreError : ignoreErrors) {
                    if (this.message.contains(ignoreError)) {
                        return true;
                    }
                }
            }

            return false;
        }

        public void addRecord(csam__Outgoing_Message_Record__c messageRecord) {
            if (messageRecord.csam__Object_Name__c == 'csdf__Fulfilment_Item__c') {
                fulfilmentItemIds.add(messageRecord.csam__Object_Record_Id__c);
            } else if (messageRecord.csam__Object_Name__c == 'csdf__Fulfilment__c') {
                fulfilmentId = messageRecord.csam__Object_Record_Id__c;
            }
        }

        public List<csdf__Fulfilment__c> getFulfilments(Map<Id, csdf__Fulfilment__c> fulfilments, Map<Id, csdf__Fulfilment_Item__c> fulfilmentItemsById) {
            if (this.fulfilmentId != null) {
                return new List<csdf__Fulfilment__c>{
                        fulfilments.get(this.fulfilmentId)
                };
            } else {
                Map<Id, csdf__Fulfilment__c> fulfilmentsToReturn = new Map<Id, csdf__Fulfilment__c>();
                for (csdf__Fulfilment_Item__c fi : fulfilmentItemsById.values()) {
                    fulfilmentsToReturn.put(fi.csdf__Fulfilment__c, fulfilments.get(fi.csdf__Fulfilment__c));
                }

                return fulfilmentsToReturn.values();
            }
        }

        private String resolveErrorMessage(csam__Incoming_Message__c inMessage) {
            if (inMessage.csam__Status__c.equals('Integration Error')) {
                Attachment attach = [SELECT Id, Body FROM Attachment WHERE ParentId = :inMessage.Id AND Name LIKE 'Message_%' LIMIT 1];

                String content = ' ';
                content = attach.Body.toString();
                ErrorResponse errRes = (ErrorResponse) JSON.deserialize(content, ErrorResponse.class);

                Pattern p = Pattern.compile('Caused by: com.cloudsense.messaging.UnrecoverableException: (.*)');
                Matcher pm = p.matcher(errRes.stackTrace);
                if (pm.find()) {
                    return pm.group(1);
                } else {
                    Pattern p1 = Pattern.compile('Caused by: \\[(.*)\\]');
                    Matcher pm1 = p1.matcher(errRes.stackTrace);
                    if (pm1.find()) {
                        return pm1.group(1);
                    } else {
                        return errRes.errorMessage;
                    }
                }
            } else if (inMessage.csam__Status__c.equals('Process Error')) {
                Attachment attach = [SELECT Id, Name, CreatedDate FROM Attachment WHERE ParentId = :inMessage.Id AND (NOT Name LIKE 'Message_%') ORDER BY CreatedDate DESC LIMIT 1];
                return attach.Name;
            }

            return null;
        }
    }

    global virtual class HandlerWorker {
        public Message msg { get; set; }
        public csmso__Sales_Order__c salesOrder { get; set; }
        public csdf__Fulfilment__c fulfilment { get; set; }
        public List<csdf__Fulfilment_Item__c> fulfilmentItems { get; set; }
        public List<CS_Billing_Schedule_Item__c> billingScheduleItems { get; set; }
        public List<CS_Revenue_Schedule_Item__c> revenueScheduleItems { get; set; }
        public List<CSPOFA__Orchestration_Step__c> steps {get; set;}
        public Boolean isCompleted { get; set; }
        public Boolean turnOffLoadingScreenWhenCompleted { get; set; }
        public Integer calloutChunkSize { get; set; }
        public Long spinWaitBeforeCallout_ms { get; set; }
        public CS_LogWorker log { get; set; }

        public virtual void init(Message msg, csmso__Sales_Order__c salesOrder, csdf__Fulfilment__c fulfilment,
                List<csdf__Fulfilment_Item__c> fulfilmentItems, List<CS_Billing_Schedule_Item__c> billingScheduleItems,
                List<CS_Revenue_Schedule_Item__c> revenueScheduleItems, List<CSPOFA__Orchestration_Step__c> steps, CS_LogWorker log) {
            this.msg = msg;
            this.turnOffLoadingScreenWhenCompleted = true;
            this.isCompleted = CS_utl_Fulfilment.isCalloutCompleted(msg.handlerType, fulfilmentItems);
            this.salesOrder = salesOrder;
            this.fulfilment = fulfilment;
            this.fulfilmentItems = fulfilmentItems;
            this.billingScheduleItems = billingScheduleItems;
            this.revenueScheduleItems = revenueScheduleItems;
            this.steps = steps;
            this.calloutChunkSize = FulfilmentExceptionEvent.csCustomSettings.Integration_Chunk_Size__c.intValue();
            this.spinWaitBeforeCallout_ms = FulfilmentExceptionEvent.csCustomSettings.Integration_Delay_Between_Callouts__c.longValue();
            this.log = log;
        }

        public Set<String> validateLines(String fieldToCheck, String valueToCompare, String fieldToReturn) {
            Set<String> fieldValues = new Set<String>();
            for(csdf__Fulfilment_Item__c fi : this.fulfilmentItems) {
                if(CS_utl_Comparison.Comparison.EQUALS == CS_utl_Comparison.compare(CS_utl_SObject.getFieldValue(fi, fieldToCheck), valueToCompare)) {
                    fieldValues.add(CS_utl_SObject.getFieldValue(fi, fieldToReturn));
                }
            }

            return fieldValues;
        }

        public virtual List<SObject> doWork() {
            List<SObject> result = new List<SObject>();
            fulfilment.Message_Type__c = msg.handlerType;
            fulfilment.Error_Message__c = fulfilment.csdf__Fulfilment_Message_Status__c + ' ' + msg.message;
            fulfilment.Error_Message__c = fulfilment.Error_Message__c.length() > 255 ? fulfilment.Error_Message__c.substring(0, 255) : fulfilment.Error_Message__c;
            fulfilment.Message_Translated__c = String.isNotBlank(msg.message) ? 'Unknown Error - Contact your System Administrator' : null;
            if (String.isNotBlank(fulfilment.Error_Message__c)) {
                for (FulfilmentExceptionEventMapping__c exc : FulfilmentExceptionEvent.exceptionEventMapping) {
                    if (fulfilment.Error_Message__c.contains(exc.Input_Message__c)) {
                        fulfilment.Error_Message__c = exc.Input_Message__c;
                        fulfilment.Message_Translated__c = exc.Output_Message__c;
                        break;
                    }
                }
            }

            if (msg.fulfilmentId != null) {
                for (csdf__Fulfilment_Item__c fi : fulfilmentItems) {
                    result.add(setStatus(fi));
                }
            } else if (!msg.fulfilmentItemIds.isEmpty()) {
                Map<Id, csdf__Fulfilment_Item__c> fulfilmentItemsById = new Map<Id, csdf__Fulfilment_Item__c>(fulfilmentItems);
                for (Id fulfilmentItemId : msg.fulfilmentItemIds) {
                    csdf__Fulfilment_Item__c fi = fulfilmentItemsById.get(fulfilmentItemId);
                    result.add(setStatus(fi));
                }
            }

            if (msg.isError(ignoreErrors())) {
                salesOrder.Callout_Type__c = null;
                salesOrder.csmso__Process_Message_Type__c = 'error';
                salesOrder.Error_Message__c = fulfilment.Error_Message__c;
                salesOrder.csmso__Process_Message__c = fulfilment.Message_Translated__c;
                salesOrder.Loading_Screen__c = 'Off';
            }
            if (isCompleted) {
                if (salesOrder.Is_Programmatic__c) {
                    salesOrder.Negotiation_Status__c = fulfilment.Negotiation_Status__c;
                    salesOrder.Proposal_Status__c = fulfilment.Proposal_Status__c;
                    if (fulfilment.csdf__Status__c == CS_const_SalesOrder.Status_Draft) {
                        if (CS_ProgrammaticSalesOrderStateManager.PG_STATUSES_TO_REFRESH.contains(salesOrder.csmso__Status__c)) {
                            salesOrder.csmso__Status__c = CS_const_SalesOrder.Status_ReadyForCustomerApproval;
                        }
                    } else {
                        if (CS_ProgrammaticSalesOrderStateManager.PG_STATUSES_TO_REFRESH.contains(salesOrder.csmso__Status__c) ||
                                fulfilment.Negotiation_Status__c.equalsIgnoreCase('AWAITING_SELLER_REVIEW')) {
                            if (CS_ProgrammaticSalesOrderStateManager.PG_DFP_TO_SO_STATUSES.containsKey(fulfilment.Negotiation_Status__c + '-' + fulfilment.Proposal_Status__c)) {
                                salesOrder.csmso__Status__c = CS_ProgrammaticSalesOrderStateManager.PG_DFP_TO_SO_STATUSES.get(fulfilment.Negotiation_Status__c + '-' + fulfilment.Proposal_Status__c);
                                if (fulfilment.Negotiation_Status__c.equalsIgnoreCase('FINALIZED') && fulfilment.Proposal_Status__c.equalsIgnoreCase('APPROVED')) {
                                    salesOrder.Last_Date_Approved__c = Datetime.now();
                                } else if (fulfilment.Negotiation_Status__c.equalsIgnoreCase('CANCELLED')) {
                                    salesOrder.Primary_Sales_Order__c = false;
                                }
                            }
                        }
                    }
                }

                if (turnOffLoadingScreenWhenCompleted) {
                    salesOrder.Loading_Screen__c = 'Off';
                }

                if(steps != null) {
                    For(CSPOFA__Orchestration_Step__c step : steps) {
                        step.CSPOFA__Status__c = 'Complete';
                        step.CSPOFA__Message__c = 'Action completed.';
                        step.CSPOFA__Completed_Date__c = Date.today();
                        result.add(step);
                    }
                }
            }

            return result;
        }

        public virtual void prepareWork() {
            Map<Id, csdf__Fulfilment_Item__c> fiToHandle = new Map<Id, csdf__Fulfilment_Item__c>();
            Map<String, Set<Id>> queuedActions = new Map<String, Set<Id>>();

            for (csdf__Fulfilment_Item__c fi : fulfilmentItems) {
                if (CS_utl_Fulfilment.getStatus(msg.handlerType, fi) == 'Waiting') {
                    fiToHandle.put(fi.Id, fi);
                }

                if (String.isNotBlank(fi.Queued_Action__c)) {
                    if (!queuedActions.containsKey(fi.Queued_Action__c)) {
                        queuedActions.put(fi.Queued_Action__c, new Set<Id>());
                    }
                    queuedActions.get(fi.Queued_Action__c).add(fi.Id);
                }
            }

            if (!fiToHandle.isEmpty()) {
                CS_FulfilmentWorker.prepareWork(msg.handlerType, fulfilment.Id, fiToHandle.keySet(), calloutChunkSize, spinWaitBeforeCallout_ms);
            } else if (!queuedActions.keySet().isEmpty()) {
                String queuedAction = new List<String>(queuedActions.keySet()).get(0);
                CS_FulfilmentWorker.prepareWork(queuedAction, fulfilment.Id, queuedActions.get(queuedAction), calloutChunkSize, spinWaitBeforeCallout_ms);
            }
        }

        public csdf__Fulfilment_Item__c setStatus(csdf__Fulfilment_Item__c fi){
            if (fi != null) {
                if (fi.Is_Archived__c) {
                    fi.csdf__Status__c = 'Paused Inventory Released';
                } else if (fi.csdf__Status__c == 'Paused Inventory Released') {
                    if (fi.Reservation_Status__c == 'RELEASED' || fi.Reservation_Status__c == 'UNRESERVED') fi.csdf__Status__c = 'Inventory Released'; else fi.csdf__Status__c = 'Paused';
                }

                if (msg.handlerType == fi.Queued_Action__c) {
                    fi.Queued_Action__c = null;
                }
            }
            return fi;
        }

        public virtual List<String> ignoreErrors() {
            return new List<String>();
        }
    }


    global class BaseHandlerWorker extends HandlerWorker {
        public override List<SObject> doWork() {
            List<SObject> result = super.doWork();
            if (this.isCompleted) {

            } else {
                prepareWork();
            }

            return result;
        }
    }

    global class PushSOStatusHandleWorker extends HandlerWorker {
        public override List<SObject> doWork() {
            List<SObject> result = super.doWork();

            if (String.isNotBlank(msg.message)
                    && msg.message.contains('NOT_UNIQUE @')) {

                salesOrder.csmso__Process_Message__c = Label.SO_SF_Sales_Order_Status_Not_Pushed_To_DFP;
                salesOrder.csmso__Process_Message_Type__c = CS_const_SalesOrder.ProcessMessageSeverity_Warning;
            } else if (String.isNotBlank(msg.message)
                    && (msg.message.contains('EXCEEDED_QUOTA @') || msg.message.contains('SERVER_ERROR @'))) { // retrying last failed request

                CS_FulfilmentWorkerStatusPush.prepareWork('SO Status Push', new Set<Id>{
                        fulfilment.Id
                });
            }

            if (this.isCompleted) {

            } else {
                prepareWork();
            }

            return result;
        }
    }

    global class AvailCheckSingleHandlerWorker extends HandlerWorker {

        public override void init(Message msg, csmso__Sales_Order__c salesOrder, csdf__Fulfilment__c fulfilment,
                List<csdf__Fulfilment_Item__c> fulfilmentItems, List<CS_Billing_Schedule_Item__c> billingScheduleItems,
                List<CS_Revenue_Schedule_Item__c> revenueScheduleItems, List<CSPOFA__Orchestration_Step__c> steps, CS_LogWorker log) {
            super.init(msg, salesOrder, fulfilment, fulfilmentItems, billingScheduleItems, revenueScheduleItems, steps, log);
            spinWaitBeforeCallout_ms = 0;
            //calloutChunkSize = 1;
        }

        public override List<SObject> doWork() {
            List<SObject> result = new List<SObject>();

            Map<Id, csdf__Fulfilment_Item__c> fulfilmentItemsById = new Map<Id, csdf__Fulfilment_Item__c>(fulfilmentItems);

            if (String.isNotBlank(msg.message)
                    && (msg.message.contains('EXCEEDED_QUOTA @') ||
                    msg.message.contains('SERVER_NOT_AVAILABLE @') ||
                    msg.message.contains('NOT_UNIQUE @') ||
                    msg.message.contains('unable to obtain exclusive access'))) { // retrying last failed request

                for (Id fulfilmentItemId : msg.fulfilmentItemIds) {
                    csdf__Fulfilment_Item__c fi = fulfilmentItemsById.get(fulfilmentItemId);
                    if (fi != null) {
                        CS_utl_Fulfilment.setStatus(msg.handlerType, fi, 'Waiting');
                        result.add(fi);
                    }

                    this.log.addMessage(fulfilmentItemId, msg.message.abbreviate(255), CS_const_LogMessage.Type_Error, msg.handlerType);
                }

                prepareWork();
            } else {
                if (msg.isIgnoredError(ignoreErrors())) {
                    for (Id fulfilmentItemId : msg.fulfilmentItemIds) {
                        csdf__Fulfilment_Item__c fi = fulfilmentItemsById.get(fulfilmentItemId);
                        fi.csdf__Availability_Check_Available_Amount__c = 0;
                        fi.csdf__Availability_Check_Delivery_Amount__c = 0;
                        fi.csdf__Availability_Check_Total_Amount__c = 0;
                        fi.csdf__Availability_Check_Status__c = 'Completed';
                        fi.csdf__Availability_Check_Date_Time__c = System.now();
                    }
                }
                result = super.doWork();

                if (!isCompleted) {
                    prepareWork();
                }
            }

            return result;
        }

        public override List<String> ignoreErrors() {
            return new List<String>{
                    'ForecastingError.NO_FORECAST_YET',
                    'CommonError.NOT_APPLICABLE'
            };
        }
    }

    global class FulfilmentPGRequestAcceptanceHandler extends HandlerWorker {
        public override List<SObject> doWork() {
            List<SObject> result = super.doWork();

            if (this.isCompleted) {
                //salesOrder.csmso__Status__c = CS_const_SalesOrder.Status_PendingCustomerApproval;
            } else {
                prepareWork();
            }

            return result;
        }
    }

    global class AvailCheckHandlerWorker extends HandlerWorker {

        public override void init(Message msg, csmso__Sales_Order__c salesOrder, csdf__Fulfilment__c fulfilment,
                List<csdf__Fulfilment_Item__c> fulfilmentItems, List<CS_Billing_Schedule_Item__c> billingScheduleItems,
                List<CS_Revenue_Schedule_Item__c> revenueScheduleItems, List<CSPOFA__Orchestration_Step__c> steps, CS_LogWorker log) {
            super.init(msg, salesOrder, fulfilment, fulfilmentItems, billingScheduleItems, revenueScheduleItems, steps, log);
            spinWaitBeforeCallout_ms = 0;
            //calloutChunkSize = 1;
        }

        public override List<SObject> doWork() {
            List<SObject> result = new List<SObject>();

            Map<Id, csdf__Fulfilment_Item__c> fulfilmentItemsById = new Map<Id, csdf__Fulfilment_Item__c>(fulfilmentItems);

            if (String.isNotBlank(msg.message)
                    && (msg.message.contains('EXCEEDED_QUOTA @') ||
                    msg.message.contains('SERVER_NOT_AVAILABLE @') ||
                    msg.message.contains('SERVER_ERROR @') ||
                    msg.message.contains('NOT_UNIQUE @') ||
                    msg.message.contains('unable to obtain exclusive access'))) { // retrying last failed request

                for (Id fulfilmentItemId : msg.fulfilmentItemIds) {
                    csdf__Fulfilment_Item__c fi = fulfilmentItemsById.get(fulfilmentItemId);
                    if (fi != null) {
                        CS_utl_Fulfilment.setStatus(msg.handlerType, fi, 'Waiting');
                        result.add(fi);
                    }

                    this.log.addMessage(fulfilmentItemId, msg.message.abbreviate(255), CS_const_LogMessage.Type_Error, msg.handlerType);
                }

                //spinWaitBeforeCallout_ms = Integer.valueof(Math.random() * FulfilmentExceptionEvent.csCustomSettings.Integration_Delay_Between_Callouts__c.longValue());

                prepareWork();
            } else {
                result = super.doWork();
                if (msg.fulfilmentId != null) {
                    for (csdf__Fulfilment_Item__c fi : fulfilmentItems) {
                        fi.Last_Action_from_DFP__c = Datetime.now();
                        if (msg.isIgnoredError(ignoreErrors())) {
                            fi.csdf__Availability_Check_Available_Amount__c = 0;
                            fi.csdf__Availability_Check_Delivery_Amount__c = 0;
                            fi.csdf__Availability_Check_Total_Amount__c = 0;
                            fi.csdf__Availability_Check_Status__c = 'Completed';
                            fi.csdf__Availability_Check_Date_Time__c = System.now();
                        }
                        result.add(fi);
                    }
                } else {
                    for (Id fulfilmentItemId : msg.fulfilmentItemIds) {
                        csdf__Fulfilment_Item__c fi = fulfilmentItemsById.get(fulfilmentItemId);
                        if (fi != null) {
                            fi.Last_Action_from_DFP__c = Datetime.now();
                            if (msg.isIgnoredError(ignoreErrors())) {
                                fi.csdf__Availability_Check_Available_Amount__c = 0;
                                fi.csdf__Availability_Check_Delivery_Amount__c = 0;
                                fi.csdf__Availability_Check_Total_Amount__c = 0;
                                fi.csdf__Availability_Check_Status__c = 'Completed';
                                fi.csdf__Availability_Check_Date_Time__c = System.now();
                            }
                            result.add(fi);
                        }
                    }
                }

                if (msg.isError(ignoreErrors())) {
                    salesOrder.Order_Synced_before_final_approval__c = false;
                    salesOrder.Callout_Type__c = null;
                } else if (isCompleted) {
                    salesOrder.Order_Synced_before_final_approval__c = true;
                    salesOrder.Flighting_Pending_Check_Avail__c = false;
                    salesOrder.Callout_Type__c = null;

                    Set<String> noInventorylines = validateLines('Inventory_Available__c', 'No', 'Product_Configuration__r.Line_Id__c');
                    noInventorylines.removeAll(validateLines('Product_Configuration__r.Overbook__c', 'true', 'Product_Configuration__r.Line_Id__c'));
                    noInventorylines.removeAll(validateLines('Product_Configuration__r.Fulfilment_Item_Status__c', CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased, 'Product_Configuration__r.Line_Id__c'));
                    List<String> lineIds = new List<String>(noInventorylines);
                    if(!lineIds.isEmpty()) {
                        salesOrder.csmso__Process_Message__c = ('The following Sales Order Line Items do not have inventory available: ' + CS_utl_Array.join(lineIds, ', ')).abbreviate(1024);
                        salesOrder.csmso__Process_Message_Type__c = CS_const_SalesOrder.ProcessMessageSeverity_Information;
                    }

                }

                if (!isCompleted) {
                    prepareWork();
                }
            }

            return result;
        }

        public override List<String> ignoreErrors() {
            return new List<String>{
                    'ForecastingError.NO_FORECAST_YET',
                    'CommonError.NOT_APPLICABLE'
            };
        }
    }

    global class PushHandlerWorker extends HandlerWorker {

        public override void init(Message msg, csmso__Sales_Order__c salesOrder, csdf__Fulfilment__c fulfilment,
                List<csdf__Fulfilment_Item__c> fulfilmentItems, List<CS_Billing_Schedule_Item__c> billingScheduleItems,
                List<CS_Revenue_Schedule_Item__c> revenueScheduleItems, List<CSPOFA__Orchestration_Step__c> steps, CS_LogWorker log) {
            super.init(msg, salesOrder, fulfilment, fulfilmentItems, billingScheduleItems, revenueScheduleItems, steps, log);
            turnOffLoadingScreenWhenCompleted = true;
        }

        public override List<SObject> doWork() {
            List<SObject> result = super.doWork();
            if (msg.fulfilmentId != null) {
                for (csdf__Fulfilment_Item__c fi : this.fulfilmentItems) {
                    fi.Last_Action_from_DFP__c = Datetime.now();
                    result.add(fi);
                }
            } else {
                Map<Id, csdf__Fulfilment_Item__c> fulfilmentItemsById = new Map<Id, csdf__Fulfilment_Item__c>(this.fulfilmentItems);
                for (Id fulfilmentItemId : msg.fulfilmentItemIds) {
                    csdf__Fulfilment_Item__c fi = fulfilmentItemsById.get(fulfilmentItemId);
                    if (fi != null) {
                        fi.Last_Action_from_DFP__c = Datetime.now();
                        result.add(fi);
                    }
                }
            }

            if (this.isCompleted && !msg.isError(ignoreErrors())) {

            } else {
                prepareWork();
            }

            return result;
        }
    }

    global class ReserveHandlerWorker extends HandlerWorker {
        public override List<SObject> doWork() {
            List<SObject> result = super.doWork();
            if (msg.fulfilmentId != null) {
                for (csdf__Fulfilment_Item__c fi : this.fulfilmentItems) {
                    fi.Last_Action_from_DFP__c = Datetime.now();
                    result.add(fi);
                }
            } else {
                Map<Id, csdf__Fulfilment_Item__c> fulfilmentItemsById = new Map<Id, csdf__Fulfilment_Item__c>(this.fulfilmentItems);
                for (Id fulfilmentItemId : msg.fulfilmentItemIds) {
                    csdf__Fulfilment_Item__c fi = fulfilmentItemsById.get(fulfilmentItemId);
                    if (fi != null) {
                        fi.Reserve_Expiration_Date__c = Date.today().addDays(15);
                        fi.Last_Action_from_DFP__c = Datetime.now();
                        result.add(fi);
                    }
                }
            }

            if (this.isCompleted) {

            } else {
                prepareWork();
            }

            return result;
        }

    }

    global class ReserveReleaseHandlerWorker extends HandlerWorker {
        public override void init(Message msg, csmso__Sales_Order__c salesOrder, csdf__Fulfilment__c fulfilment,
                List<csdf__Fulfilment_Item__c> fulfilmentItems, List<CS_Billing_Schedule_Item__c> billingScheduleItems,
                List<CS_Revenue_Schedule_Item__c> revenueScheduleItems, List<CSPOFA__Orchestration_Step__c> steps, CS_LogWorker log) {
            super.init(msg, salesOrder, fulfilment, fulfilmentItems, billingScheduleItems, revenueScheduleItems, steps, log);
            turnOffLoadingScreenWhenCompleted = String.isNotBlank(salesOrder.Callout_Type__c) && !salesOrder.Callout_Type__c.contains('ButtonSOBook') ? true : false;
        }

        public override List<SObject> doWork() {
            List<SObject> result = super.doWork();
            if (msg.fulfilmentId != null) {
                for (csdf__Fulfilment_Item__c fi : this.fulfilmentItems) {
                    fi.Last_Action_from_DFP__c = Datetime.now();
                    result.add(fi);
                }
            } else {
                Map<Id, csdf__Fulfilment_Item__c> fulfilmentItemsById = new Map<Id, csdf__Fulfilment_Item__c>(this.fulfilmentItems);
                for (Id fulfilmentItemId : msg.fulfilmentItemIds) {
                    csdf__Fulfilment_Item__c fi = fulfilmentItemsById.get(fulfilmentItemId);
                    if (fi != null) {
                        fi.Last_Action_from_DFP__c = Datetime.now();
                        Date reserveExpirationDate = null;
                        if ((salesOrder.Is_Programmatic__c && fi.Reservation_Status__c == 'RESERVED')
                                || fi.Product_Configuration__r.Reserve_Inventory__c) {
                            reserveExpirationDate = Date.today().addDays(15);
                        }
                        fi.Reserve_Expiration_Date__c = reserveExpirationDate;

                        result.add(fi);
                    }
                }
            }

            if (!this.isCompleted) {
                prepareWork();
            }

            return result;
        }


        public override List<String> ignoreErrors() {
            return new List<String>{
                    'LineItemOperationError.HAS_NO_ACTIVE_CREATIVES'
            };
        }
    }

    global class RefreshHandlerWorker extends HandlerWorker {
        public override List<SObject> doWork() {
            List<SObject> result = new List<SObject>();
            Map<Id, csdf__Fulfilment_Item__c> fulfilmentItemsById = new Map<Id, csdf__Fulfilment_Item__c>(this.fulfilmentItems);

            if (String.isNotBlank(msg.message)
                    && (msg.message.contains('unable to obtain exclusive access'))) { // retrying last failed request
                for (Id fulfilmentItemId : msg.fulfilmentItemIds) {
                    csdf__Fulfilment_Item__c fi = fulfilmentItemsById.get(fulfilmentItemId);
                    if (fi != null) {
                        CS_utl_Fulfilment.setStatus(msg.handlerType, fi, 'Waiting');
                        result.add(fi);
                    }

                    //this.log.addMessage(fulfilmentItemId, msg.message.abbreviate(255), CS_const_LogMessage.Type_Error, msg.handlerType);
                }

                prepareWork();
            } else {
                result = super.doWork();

                if (msg.fulfilmentId != null) {
                    for (csdf__Fulfilment_Item__c fi : this.fulfilmentItems) {
                        fi.Last_Action_from_DFP__c = Datetime.now();
                        result.add(fi);
                    }
                } else {
                    for (Id fulfilmentItemId : msg.fulfilmentItemIds) {
                        csdf__Fulfilment_Item__c fi = fulfilmentItemsById.get(fulfilmentItemId);
                        if (fi != null) {
                            fi.Last_Action_from_DFP__c = Datetime.now();

                            result.add(fi);
                        }
                    }
                }

                if (this.isCompleted && !msg.isError(ignoreErrors())) {
                    salesOrder.csmso__Process_Message_Type__c = '';
                    salesOrder.Error_Message__c = '';
                    salesOrder.csmso__Process_Message__c = '';
                }

                if (this.isCompleted && String.isNotBlank(salesOrder.Callout_Type__c)) {
                    if (salesOrder.Callout_Type__c.contains('ButtonSORetract')) {
                        if (salesOrder.Callout_Type__c == 'ButtonSORetract') {
                            salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_RETRACTED;
                            salesOrder.Last_Date_Retracted__c = System.now();
                            salesOrder.Order_Synced_before_final_approval__c = false;
                            salesOrder.Callout_Type__c = null;
                        } else {
                            salesOrder.Callout_Type__c = 'RetractionService';
                        }
                    }

                    if (salesOrder.Callout_Type__c == 'ButtonSOCancelRetract') {
                        salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_BOOKED;
                        salesOrder.Last_Date_Booked__c = System.now();
                        salesOrder.Callout_Type__c = null;
                    }
                }

                if (!this.isCompleted) {
                    prepareWork();
                }
            }

            return result;
        }
    }

    global class CancelHandlerWorker extends HandlerWorker {
        public override List<SObject> doWork() {
            List<SObject> result = super.doWork();

            if (msg.fulfilmentId != null) {
                for (csdf__Fulfilment_Item__c fi : this.fulfilmentItems) {
                    fi.Last_Action_from_DFP__c = Datetime.now();
                    result.add(fi);
                }
            } else {
                Map<Id, csdf__Fulfilment_Item__c> fulfilmentItemsById = new Map<Id, csdf__Fulfilment_Item__c>(this.fulfilmentItems);
                for (Id fulfilmentItemId : msg.fulfilmentItemIds) {
                    csdf__Fulfilment_Item__c fi = fulfilmentItemsById.get(fulfilmentItemId);
                    if (fi != null) {
                        fi.Last_Action_from_DFP__c = Datetime.now();
                        result.add(fi);
                    }
                }
            }

            if (this.isCompleted && !msg.isError(ignoreErrors())) {
                CS_utl_SalesOrder.killSalesOrder(salesOrder, null, this.fulfilmentItems, billingScheduleItems, revenueScheduleItems);
            } else {
                prepareWork();
            }

            return result;
        }
    }

    global class CancelItemHandlerWorker extends HandlerWorker {
        public override List<SObject> doWork() {
            List<SObject> result = super.doWork();

            Map<Id, csdf__Fulfilment_Item__c> fulfilmentItemsById = new Map<Id, csdf__Fulfilment_Item__c>(this.fulfilmentItems);
            if (!msg.isError(ignoreErrors())) {
                for (Id fulfilmentItemId : this.msg.fulfilmentItemIds) {
                    csdf__Fulfilment_Item__c fi = fulfilmentItemsById.get(fulfilmentItemId);
                    if (billingScheduleItems != null) {
                        for (CS_Billing_Schedule_Item__c bsi : billingScheduleItems) {
                            if (fi.Product_Configuration__c == bsi.Product_Configuration__c
                                    && bsi.Valid_for_Auto_Cancellation__c) {

                                bsi.Status__c = CS_const_SalesOrder.ScheduleStatus_Cancelled;
                                result.add(bsi);
                            }
                        }
                    }
                    if (revenueScheduleItems != null) {
                        for (CS_Revenue_Schedule_Item__c rsi : revenueScheduleItems) {
                            if (fi.Product_Configuration__c == rsi.Product_Configuration__c
                                    && rsi.Valid_for_Auto_Cancellation__c) {

                                rsi.Status__c = CS_const_SalesOrder.ScheduleStatus_Cancelled;
                                result.add(rsi);
                            }
                        }
                    }
                }
            }

            //support Archive process
            if (msg.fulfilmentId != null) {
                for (csdf__Fulfilment_Item__c fi : this.fulfilmentItems) {
                    fi.Last_Action_from_DFP__c = Datetime.now();
                    result.add(fi);
                }
            } else {
                for (Id fulfilmentItemId : msg.fulfilmentItemIds) {
                    csdf__Fulfilment_Item__c fi = fulfilmentItemsById.get(fulfilmentItemId);
                    if (fi != null) {
                        fi.Last_Action_from_DFP__c = Datetime.now();
                        result.add(fi);
                    }
                }
            }

            return result;
        }
    }

    global class RetractProposalHandlerWorker extends HandlerWorker {
        public override List<SObject> doWork() {

            List<SObject> result = super.doWork();
            if (this.isCompleted) {
                salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_RETRACTED;
                salesOrder.Last_Date_Retracted__c = System.now();
                salesOrder.Order_Synced_before_final_approval__c = false;
                salesOrder.Callout_Type__c = null;
                if (fulfilment.Negotiation_Status__c.equalsIgnoreCase('FINALIZED')) {
                    salesOrder.Last_Date_Approved__c = Datetime.now();
                }
            } else {
                prepareWork();
            }

            return result;
        }
    }

    @TestVisible
    private class ErrorResponse {
        /**
         * Integration server error message
         */
        @TestVisible
        private String errorMessage { get; }

        /**
         * Full exception stack trace from the Integration server
         */
        @TestVisible
        private String stackTrace { get; }
    }


}
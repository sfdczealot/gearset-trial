/**
 * @description Digital Fulfilment integration utility. Exposed methods allow creation of Fulfilment Items, running of
 * availability check, polling availability check responses and provisioning on destination Ad Servers.
 * 
 */
public class DigitalFulfilmentAdapterUtil {

    /**
     * @description Invokes check availability method with captured data content used to create or update a Fulfilment
     * Item.
     * @param attrs attributes defining the data content for Fulfilment Item
     * @return Fulfilment Item Id of new or updated Fulfilment Item record
     */
    public static Id checkAvailability(CS_FulfilmentService.DigitalFulfilmentAttributes attrs) {
        Id fulfilmentItemId = DigitalFulfilmentAdapterUtil.createOrUpdateFulfilmentItem(attrs, true);
  		DigitalFulfilmentAdapterUtil.invokeAvailabilityCheck(fulfilmentItemId);

        return fulfilmentItemId;
    }

    /**
    * @description Availability check data poller. The method is usually used to pull the data from Salesforce and to
    * check whether the availability check response has arrived.
    * @param fulfilmentItemId Fulfilment Item record Id of a Fulfilment Item to check for the Availability Check data
    * @return wrapped poller response
    */
    public static AvailabilityCheckPollResponse availabilityCheckPoll(Id fulfilmentItemId) {
        System.debug('Polling for: ' + fulfilmentItemId);
        AvailabilityCheckPollResponse response = availabilityCheckPoll(new Id[]{
                fulfilmentItemId
        }).get(fulfilmentItemId);
        System.debug('Response: ' + JSON.serialize(response));
        return response;
    }

    /**
     * Preventing instantiation
     */
    private DigitalFulfilmentAdapterUtil() {

    }

    //Used for creating FI onLoad before productConfiguration id is known
    public static Id createDummyFulfilmentItem(Id salesOrderId) {
        List<csmso__Sales_Order__c> SOlist = [SELECT Id,csmso__Advertiser__c,Proposal_Name__c FROM csmso__Sales_Order__c WHERE Id = :salesOrderId];
        List<csdf__Ad_Server__c> ADserverList = [SELECT Id FROM csdf__Ad_Server__c];
        if (SOlist.isEmpty() || ADserverList.isEmpty()) {
            return null;
        }
        csdf__Ad_Server__c AdServer = ADserverList[0];
        csmso__Sales_Order__c SO = SOlist[0];
        csdf__Fulfilment_Item__c fulfilmentItem = new csdf__Fulfilment_Item__c();
        csdf__Fulfilment__c fulfilment;

        //check if there is a Fulfilment or it needs to be created
        List<csdf__Fulfilment__c> fulfilments = [SELECT Id FROM csdf__Fulfilment__c WHERE Sales_Order__c = :salesOrderId];
        if (fulfilments.isEmpty()) {
            fulfilment = new csdf__Fulfilment__c(Sales_Order__c = salesOrderId);
            fulfilment.csdf__Name__c = SO.Proposal_Name__c;
            fulfilment.csdf__Advertiser__c = SO.csmso__Advertiser__c;
            fulfilment.csdf__Ad_Server__c = AdServer.Id;
            insert fulfilment;
        }
        else {
            fulfilment = fulfilments[0];
        }
        fulfilmentItem.csdf__Fulfilment__c = fulfilment.Id;
        fulfilmentItem.csdf__Flight_Beginning__c = Datetime.newInstance(1999, 2, 11, 8, 6, 16);
        fulfilmentItem.csdf__Flight_End__c = Datetime.newInstance(1999, 2, 11, 8, 6, 16);
        fulfilmentItem.csdf__Name__c = 'Dummy FI' + System.now();
        fulfilmentItem.csdf__Quantity__c = 1;
        insert fulfilmentItem;
        return fulfilmentItem.Id;
    }

    public static void deleteEmptyFulfilmentItems() {
        List<csdf__Fulfilment_Item__c> fiList = [SELECT Id FROM csdf__Fulfilment_Item__c WHERE Product_Configuration__c = NULL];
        if (!fiList.isEmpty())
            delete fiList;
    }

    //We can only delete Fulfilment Items from the SO being processed, otherwise we might delete lines that are being created for other SOs
    public static void deleteEmptyFulfilmentItems(String fulfilmentString) {
        List<csdf__Fulfilment_Item__c> fiList = [SELECT Id FROM csdf__Fulfilment_Item__c WHERE Product_Configuration__c = NULL AND csdf__Fulfilment__c = :fulfilmentString];
        if (!fiList.isEmpty())
            delete fiList;
    }

    //We can only delete Fulfilment Items from the SO being processed, otherwise we might delete lines that are being created for other SOs
    public static void deleteEmptyFulfilmentItems(Id fulfilmentItemId) {
        List<csdf__Fulfilment_Item__c> fiList = [SELECT Id FROM csdf__Fulfilment_Item__c WHERE Product_Configuration__c = NULL AND Id = :fulfilmentItemId];
        if (!fiList.isEmpty())
            delete fiList;
    }

    //We can only delete Fulfilment Items from the SO being processed, otherwise we might delete lines that are being created for other SOs
    public static void deleteEmptyFulfilmentItems(List<Id> fulfilmentItemIds) {
        List<csdf__Fulfilment_Item__c> fiList = [SELECT Id FROM csdf__Fulfilment_Item__c WHERE Product_Configuration__c = NULL AND Id IN :fulfilmentItemIds];
        if (!fiList.isEmpty())
            delete fiList;
    }

    public static String doGlobalCheckAvails(Map<Id, cscfga__Product_Configuration__c> configs) {
        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id, Name, csdf__Fulfilment__c FROM csdf__Fulfilment_Item__c
        WHERE Product_Configuration__c IN :configs.keySet()
        AND Product_Configuration__r.Eligible_for_Check_Availability__c = true]);

        for (csdf__Fulfilment_Item__c fi : fulfilmentItems.values()) {
            fi.csdf__Availability_Check_Status__c = 'Waiting';
        }
        update fulfilmentItems.values();

        CS_FulfilmentWorker.prepareWork('SO Fulfilment Item Availability Check', fulfilmentItems.values().get(0).csdf__Fulfilment__c, fulfilmentItems.keySet());
        return 'Verifying availability of the Sales Order.';
    }

    public static String updateStatus(String salesOrderId) {
        Map<Id, csdf__Fulfilment__c> fulfilments = new Map<Id, csdf__Fulfilment__c>([SELECT Id, Name FROM csdf__Fulfilment__c WHERE Sales_Order__c = :salesOrderId]);
        Set<Id> fulKeys = fulfilments.keySet();
        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id, Name FROM csdf__Fulfilment_Item__c WHERE csdf__Fulfilment__c IN :fulKeys AND Served_By__c = 'DFP' AND csdf__Status__c != 'Draft' AND Pushed_to_DFP__c = TRUE]);

        for (csdf__Fulfilment_Item__c fi : fulfilmentItems.values()) {
            fi.csdf__Status_Update_Message_Status__c = 'Waiting';
        }
        update fulfilmentItems.values();

        CS_FulfilmentWorker.prepareWork('Fulfilment Item Refresh', fulfilments.values().get(0).Id, fulfilmentItems.keySet());
        return 'Updating Sales Order.';
    }

    public static String fulfilmentPerformanceGathering(String salesOrderId) {
        Map<Id, csdf__Fulfilment__c> fulfilments = new Map<Id, csdf__Fulfilment__c>([SELECT Id, Name FROM csdf__Fulfilment__c WHERE Sales_Order__c = :salesOrderId]);
        Set<Id> fulKeys = fulfilments.keySet();
        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id, Name FROM csdf__Fulfilment_Item__c WHERE csdf__Fulfilment__c IN :fulKeys AND Served_By__c = 'DFP' AND csdf__Status__c != 'Draft']);
        CS_FulfilmentWorker.prepareWork('Fulfilment Item Performance Gathering', fulfilments.values().get(0).Id, fulfilmentItems.keySet());
        return 'Gathering performance for Sales Order.';
    }

    //Archiving
    public static String fulfilmentCancel(String salesOrderId) {
        Map<Id, csdf__Fulfilment__c> fulfilments = new Map<Id, csdf__Fulfilment__c>([SELECT Id, Name FROM csdf__Fulfilment__c WHERE Sales_Order__c = :salesOrderId]);
        Set<Id> fulKeys = fulfilments.keySet();

        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>();

        fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id, Name FROM csdf__Fulfilment_Item__c WHERE csdf__Fulfilment__c IN :fulKeys AND Served_By__c = 'DFP' AND csdf__Status__c != 'Paused Inventory Released' AND csdf__Ad_Server_Id__c != NULL]);

        for (csdf__Fulfilment_Item__c fi : fulfilmentItems.values()) {
            fi.csdf__Cancel_Message_Status__c = 'Waiting';
        }
        update fulfilmentItems.values();

        CS_FulfilmentWorker.prepareWork('Fulfilment Item Cancel', fulfilments.values().get(0).Id, fulfilmentItems.keySet());
        return 'Cancelling Sales Order.';
    }

    public static String fulfilmentItemCancel(String fiID) {
        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id, Name, csdf__Fulfilment__c FROM csdf__Fulfilment_Item__c WHERE Id = :fiID AND Served_By__c = 'DFP' AND csdf__Status__c != 'Paused Inventory Released']);

        for (csdf__Fulfilment_Item__c fi : fulfilmentItems.values()) {
            fi.csdf__Cancel_Message_Status__c = 'Waiting';
        }
        update fulfilmentItems.values();

        CS_FulfilmentWorker.prepareWork('Fulfilment Item Cancel', fulfilmentItems.values().get(0).csdf__Fulfilment__c, fulfilmentItems.keySet());
        return 'Cancelling Sales Order.';
    }

    //Perf Gath should only run for Fulfilment items with non future dates - Begin
    public static String fulfilmentItemPerformanceGathering(String salesOrderId) {
        Map<Id, csdf__Fulfilment__c> fulfilments = new Map<Id, csdf__Fulfilment__c>([SELECT Id, Name FROM csdf__Fulfilment__c WHERE Sales_Order__c = :salesOrderId]);

        Datetime reqStartDateTime;
        Datetime reqEndDateTime;
        Set<String> statusesToConsider = new Set<String>{
                'Delivering', 'Delivery Extended', 'Paused', 'Paused Inventory Released', 'Completed'
        };

        reqStartDateTime = System.now();
        reqEndDateTime = System.now().addHours(-2);

        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id, Name FROM csdf__Fulfilment_Item__c WHERE csdf__Fulfilment__r.Sales_Order__c = :salesOrderId AND csdf__Status__c IN :statusesToConsider AND csdf__Flight_Beginning__c <= :reqStartDateTime AND csdf__Flight_End__c >= :reqEndDateTime AND csdf__Ad_Server_Id__c != NULL]);
        if (!fulfilmentItems.isEmpty()) {
            CS_FulfilmentWorker.prepareWork('Fulfilment Item Performance Gathering', fulfilments.values().get(0).Id, fulfilmentItems.keySet());
            return 'Gathering performance for Sales Order.';
        }
        else {
            return 'OK';
        }
    }

    public static String pushToAdServer(String salesOrderId) {
        List<csdf__Fulfilment__c> fulfilments = [SELECT Id, csdf__Ad_Server_Id__c FROM csdf__Fulfilment__c WHERE Sales_Order__c = :salesOrderId];
        if (fulfilments.size() != 1) {
            throw new CS_FulfilmentService.AmbiguousException('Fulfilment is defined ambiguously!');
        }
        csdf__Fulfilment__c fulfilment = fulfilments[0];

        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id, Name, Product_Configuration__r.Reservation_Status__c, csdf__Fulfilment__r.Sales_Order__r.Last_Date_Booked__c, Product_Configuration__r.Order_Line_ID__c
        FROM csdf__Fulfilment_Item__c
        WHERE csdf__Fulfilment__c = :fulfilment.Id
        AND Product_Configuration__r.Fulfilment_Item_Status__c != 'Paused Inventory Released'
        AND Product_Configuration__r.Served_By__c = 'DFP']);
        for (csdf__Fulfilment_Item__c fi : fulfilmentItems.values()) {
            fi.csdf__Fulfilment_Message_Status__c = 'Waiting';
        }
        update fulfilmentItems.values();

        CS_FulfilmentWorker.prepareWork('Fulfilment Item Push', fulfilment.Id, fulfilmentItems.keySet());

        return 'Pushing Sales Order to Ad Server.';
    }

    public static String pushToAdServerSOStatus(List<Id> fulfilmentIds) {
        if (fulfilmentIds.isEmpty()) {
            throw new CS_FulfilmentService.AmbiguousException('There are no fulfilments!');
        }
        deleteEmptyFulfilmentItems(fulfilmentIds);

        CS_FulfilmentWorkerStatusPush.prepareWork('SO Status Push', new Set<Id>(fulfilmentIds));
        return 'Pushing Sales Order Status to Ad Server.';
    }

    public static String fulfilmentItemReserveRelease(String salesOrderId) {
        return fulfilmentItemReserveRelease(salesOrderId, (new Map<Id, cscfga__Product_Configuration__c>([SELECT Id From cscfga__Product_Configuration__c WHERE  Sales_Order__c = :salesOrderId AND (Ad_Type__c = 'Standard' OR Ad_Type__c = 'Sponsorship')])).keySet());
    }

    public static String fulfilmentItemReserveRelease(String salesOrderId, Set<Id> productConfigIds) {
        List<csdf__Fulfilment__c> fulfilments = [SELECT Id, csdf__Ad_Server_Id__c FROM csdf__Fulfilment__c WHERE Sales_Order__c = :salesOrderId];
        if (fulfilments.size() != 1) {
            throw new CS_FulfilmentService.AmbiguousException('Fulfilment is defined ambiguously!');
        }
        csdf__Fulfilment__c fulfilment = fulfilments[0];
        String fulfilmentString = fulfilment.Id;

        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([
                SELECT Id, Name
                FROM csdf__Fulfilment_Item__c
                WHERE csdf__Fulfilment__c = :fulfilment.Id AND
                Product_Configuration__r.Sales_Order__r.Order_Type__c != 'House Non-Guaranteed' AND
                csdf__Status__c != 'Paused Inventory Released' AND Served_By__c = 'DFP' AND
                Product_Configuration__c in :productConfigIds
        ]);
        for (csdf__Fulfilment_Item__c fi : fulfilmentItems.values()) {
            fi.csdf__Pause_Resume_Message_Status__c = 'Waiting';
        }
        update fulfilmentItems.values();

        CS_FulfilmentWorker.prepareWork('Fulfilment Item Reserve Release', fulfilment.Id, fulfilmentItems.keySet());
        return 'Reserving Releasing Fulfilment Items.';
    }

    /**
    *@description helper class for PG callouts - uses queueable
    */
    public class CS_PGCalloutHelperWorker extends CS_QueueableWorker implements Database.AllowsCallouts {

        public CS_PGCalloutHelperWorker(Object params) {
            super('CS_PGCalloutHelperWorker', params);
        }

        public override void doWork() {
            Map<String, Object> paramsType = (Map<String, Object>) this.params;
            List<Id> fulfilmentList = new List<Id>();

            String calloutType = (String) paramsType.get('CalloutType');
            Id salesOrderId = (Id) paramsType.get('salesOrderId');

            csdf__Fulfilment__c fulfilment = [
                    SELECT Id, csdf__Ad_Server_Id__c
                    FROM csdf__Fulfilment__c
                    WHERE Sales_Order__c = :salesOrderId
                    LIMIT 1
            ];

            fulfilmentList.add(fulfilment.Id);

            csam.ObjectGraphCalloutHandler.createAndSendFromIds(calloutType, fulfilmentList);
        }
    }

    /**
    *@description method to call Request for Acceptance for PG proposals
    * 2019-11-22  ivan.ravnjak@cloudsense.com  Made callout queueable
    */
    public static String requestAcceptance(String salesOrderId) {
        CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();
        DigitalFulfilmentAdapterUtil.CS_PGCalloutHelperWorker helperWorker = new DigitalFulfilmentAdapterUtil.CS_PGCalloutHelperWorker(new Map<String, Object> {
                'CalloutType' => 'Fulfilment PG Request Acceptance',
                'salesOrderId' => salesOrderId
        });
        dispatcher.addWorker(helperWorker);
        dispatcher.dispatch();

        return 'Sending PG Request Acceptance';
    }

    /**
    *@description method to call the retract process used explicitly for retracting / opening  PG proposals
    * in order to make inflight changes or cancel.
    * 2019-11-22  ivan.ravnjak@cloudsense.com  Made callout queueable
    */
    public static String retractPGProposal(String salesOrderId) {
        CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();
        DigitalFulfilmentAdapterUtil.CS_PGCalloutHelperWorker helperWorker = new DigitalFulfilmentAdapterUtil.CS_PGCalloutHelperWorker(new Map<String, Object> {
                'CalloutType' => 'Fulfilment PG Retract Proposal',
                'salesOrderId' => salesOrderId
        });
        dispatcher.addWorker(helperWorker);
        dispatcher.dispatch();

        return 'Sending PG Proposal Retraction';
    }

    /**
     * @description Invokes Availability Check (creates new availability check message on the outgoing message queue)
     * from the defined fulfilment item record.
     * @param fulfilmentItemId id of the fulfilment item record on which the availability check has to be executed
     * @return outgoing message creation message
     */
    public static String invokeAvailabilityCheck(Id fulfilmentItemId) {
        csdf__Fulfilment_item__c fi = [select id,Served_By__c from csdf__Fulfilment_item__c where id=:fulfilmentItemId];
      
        if( fi.Served_By__c == 'Developer Listings'){
            Sobject s =  DeveloperListingInventoriesCheck.checkInventory(fulfilmentItemId);
update s;
            return 'executionTime:'+system.now();
        }
        else
            return csam.ObjectGraphCalloutHandler.createAndSend('Fulfilment Item Availability Check', fulfilmentItemId).responseMessage;
    }

    /**
     * @description Invokes Ad Server Fulfilment Upsert (creates new fulfilment message on the outgoing message queue)
     * from the defined fulfilment item record.
     * @param fulfilmentItemId id of the fulfilment item record on which the fulfilment has to be executed
     * @return outgoing message creation message
     */
    public static String invokeFulfilment(Id fulfilmentItemId) {
        //We can only delete Fulfilment Items from the SO being processed, otherwise we might delete lines that are being created for other SOs
        deleteEmptyFulfilmentItems(fulfilmentItemId);
        return csam.ObjectGraphCalloutHandler.queueMessageFromIds('Fulfilment Item Push', new List<Id>{
                fulfilmentItemId
        }).responseMessage;
    }

    /**
     * @description Invokes Ad Server Fulfilment Upserts (creates new bulkified fulfilment message on the outgoing message queue)
     * from the defined fulfilment item record.
     * @param fulfilmentItemIds id of the fulfilment item records on which the fulfilment has to be executed
     * @return outgoing message creation message
     */
    public static String invokeFulfilment(Set<Id> fulfilmentItemIds) {
        return DigitalFulfilmentAdapterUtil.invokeFulfilment(new List<Id>(fulfilmentItemIds));
    }

    /**
     * @description Invokes Ad Server Fulfilment Upserts (creates new bulkified fulfilment message on the outgoing message queue)
     * from the defined fulfilment item record.
     * @param fulfilmentItemIds id of the fulfilment item records on which the fulfilment has to be executed
     * @return outgoing message creation message
     */
    public static String invokeFulfilment(List<Id> fulfilmentItemIds) {
        deleteEmptyFulfilmentItems(fulfilmentItemIds);

        return csam.ObjectGraphCalloutHandler.queueMessageFromIds('Fulfilment Item Push', fulfilmentItemIds).responseMessage;
    }

    public static Id createOrUpdateFulfilmentItem(CS_FulfilmentService.DigitalFulfilmentAttributes fulfilmentAttributes) {
        return createOrUpdateFulfilmentItem(fulfilmentAttributes, false);
    }

    public static Id createOrUpdateFulfilmentItem(CS_FulfilmentService.DigitalFulfilmentAttributes fulfilmentAttributes, Boolean temporary) {
        CS_FulfilmentService fulfilmentService = new CS_FulfilmentService(new List<CS_FulfilmentService.DigitalFulfilmentAttributes>{
                fulfilmentAttributes
        }, temporary);
     try{
        return fulfilmentService.generateFulfilmentItems().get(0).Id;
     }
     catch(exception e){
         system.debug(e);
         throw e;
     }
    }

    /**
     * @description Polls fulfilment item records for availability check responses.
     * @param fulfilmentItemIds ids of the fulfilment item record on which there are pending availability checks
     * @return response map of map. First is keyed with fulfilment item ids, second with keys:
     * <ul><li>
     * <strong>Status</strong> - status of the availability check process. Available statuses: <em>Completed</em> -
     * successfully completed, <em>Error</em> - error during processing, <em>Pending</em> - process in execution,
     * <em>Waiting</em> - prior to any execution.
     * </li></ul>
     * <p>
     * When <strong>Status</strong> is <em>Completed</em> or <em>Error</em>, following key is available:
     * <ul><li>
     * <strong>ResponseMessage</strong> - response message from the Ad Server Integration
     * </li></ul>
     * <p>
     * When <strong>Status</strong> is <em>Completed</em> additional keys are available:
     * <ul><li>
     * <strong>AvailableAmount</strong> - available amount for the fulfilment item
     * </li><li>
     * <strong>TotalAmount</strong> - total amount represents available amount + reserved inventory by fulfilled orders
     * on the destination ad server
     * </li><li>
     * <strong>ExecutionTime</strong> - execution DateTime <em>yyyy-MM-dd HH:mm:ss</em>
     * </li></ul>
    */
    public static Map<Id, AvailabilityCheckPollResponse> availabilityCheckPoll(List<Id> fulfilmentItemIds) {
        List<csdf__Fulfilment_Item__c> fulfilmentItems = [
                    SELECT Id, csdf__Availability_Check_Available_Amount__c, csdf__Availability_Check_Delivery_Amount__c, csdf__Availability_Check_Total_Amount__c,
                            csdf__Availability_Check_Date_Time__c, csdf__Availability_Check_Status__c, Contending_Items_Extended__c, Product_Configuration__c, Inventory_Message__c, Inventory_Available__c
                    FROM csdf__Fulfilment_Item__c
                WHERE Id IN :fulfilmentItemIds
        ];

        Map<Id, AvailabilityCheckPollResponse> responsesMap = new Map<Id, AvailabilityCheckPollResponse>();

        for (csdf__Fulfilment_Item__c fulfilmentItem : fulfilmentItems) {
            AvailabilityCheckPollResponse pollResponse = new AvailabilityCheckPollResponse();
            pollResponse.status = fulfilmentItem.csdf__Availability_Check_Status__c;
            if (fulfilmentItem.csdf__Availability_Check_Status__c == 'Completed') {
                pollResponse.responseMessage = 'Success';
                pollResponse.availableAmount = fulfilmentItem.csdf__Availability_Check_Available_Amount__c;
                pollResponse.deliveryAmount = fulfilmentItem.csdf__Availability_Check_Delivery_Amount__c;
                pollResponse.totalAmount = fulfilmentItem.csdf__Availability_Check_Total_Amount__c;
                pollResponse.executionTime = fulfilmentItem.csdf__Availability_Check_Date_Time__c;
                pollResponse.contendingItems = fulfilmentItem.Contending_Items_Extended__c;
                pollResponse.inventoryAvailable = fulfilmentItem.Inventory_Available__c;
                pollResponse.inventoryMessage = fulfilmentItem.Inventory_Message__c;
            }
            else if (fulfilmentItem.csdf__Availability_Check_Status__c.contains('Error')) {
                pollResponse.responseMessage = 'Error on Ad Server Integration';
            }

            responsesMap.put(fulfilmentItem.Id, pollResponse);
        }

        return responsesMap;
    }

    /**
     * @description Availability Check Poll response wrapper object.
     */
    public class AvailabilityCheckPollResponse {
        // mandatory params
        public String status { get; set; }
        public String responseMessage { get; set; }

        // params on availability check response
        public String inventoryAvailable { get; set; }
        public String inventoryMessage { get; set; }
        public Decimal availableAmount { get; set; }
        public Decimal deliveryAmount { get; set; }
        public Decimal totalAmount { get; set; }
        public Datetime executionTime { get; set; }

        // currently only escaped JSON string
        public String contendingItems { get; set; }
    }
}
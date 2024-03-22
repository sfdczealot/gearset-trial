public class CS_SO_PushCompletedWorker extends CS_QueueableWorker implements Database.AllowsCallouts {
    public CS_SO_PushCompletedWorker(Object params) {
        super('CS_SO_PushCompletedWorker', params);
    }

    public override void doWork() {
        
        Map<String, Object> paramsType = (Map<String, Object>) this.params;
        Id salesOrderId = (Id) paramsType.get('salesOrderId');
        csmso__Sales_Order__c so = [
                SELECT Id, In_Retraction__c, csmso__Status__c, Is_Programmatic__c, Primary_Sales_Order__c
                FROM csmso__Sales_Order__c
                WHERE Id = :salesOrderId
        ];

        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c(Id = salesOrderId,
                Reason_for_Retraction__c = null,
                csmso__Status__c = so.Is_Programmatic__c ? CS_const_SalesOrder.Status_Reserved : (so.In_Retraction__c ? CS_const_SalesOrder.Status_Booked : CS_const_SalesOrder.Status_Reserved),
                Last_Date_Booked__c = System.now(),
                Primary_Sales_Order__c = true,
                Callout_Type__c = null,
                Loading_Screen__c = 'Off');
        update salesOrder;

        if (!so.Is_Programmatic__c) {
            CS_ScheduleService.deleteForecastSchedules(new Set<Id>{
                    salesOrderId
            });

            if(so.Primary_Sales_Order__c) {
                CS_ScheduleService.generateSchedules(new Set<Id>{
                        salesOrderId
                }, null);
            }

            if(!so.In_Retraction__c) {
                salesOrder.csmso__status__c = CS_const_SalesOrder.Status_PendingLegalApproval;
                update salesOrder;
            }
        }
    }

    public static void prepareWork(Id salesOrderId) {
        CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();

        dispatcher.addWorker(new CS_SO_PushCompletedWorker(new Map<String, Object>{
                'salesOrderId' => salesOrderId
        }));

        dispatcher.dispatch();
    }
}
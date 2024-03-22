/**
 * @name CS_BatchConsolidateActuals
 * @description Class that handles consolidation of actuals
 * @revision
 *
 */
public class CS_BatchConsolidateActuals extends CS_SalesOrderScheduleBatch implements Schedulable {
    @TestVisible
    private static String INITIAL_QUERY_TEMPLATE = 'SELECT Id, Sales_Order__c FROM CS_Sales_Order_Schedule__c ' +
                                                   'WHERE (Sales_Order__r.Last_Date_Booked__c != null AND Sales_Order__r.From_Calculated__c <= {0} AND Last_Billing_Date__c >= {1})';
    
    public static List<String> Schedules_To_Process = new List<String> {
        'CS_ActualsService.CS_BillingActualsService',
        'CS_ActualsService.CS_RevenueActualsService'
    };
    
    private Date executeDate;

    public static Integer chunkLimit = (Integer) CS_Custom_Settings__c.getInstance().Consolidation_Size__c;
    
    /**
     * Class constructor
     * @return CS_BatchConsolidateActuals
     */
    public CS_BatchConsolidateActuals() {
        this(Date.today());
    }
    
    /**
     * Class constructor
     * @return CS_BatchConsolidateActuals
     */
    public CS_BatchConsolidateActuals(Date executeDate) {
        super('CS_BatchConsolidateActuals', 1);
        this.executeDate = executeDate;
    }
    
    public override void init(String processName, Integer batchSize) {
        super.init(processName, batchSize);
        this.executeDate = Date.today();
        
        List<csdf__Custom_Report_Execution__c> reportExecution = [SELECT Id, csdf__Report_Status__c
                                                                  FROM csdf__Custom_Report_Execution__c
                                                                  WHERE CreatedDate = TODAY AND
                                                                  csdf__Custom_Report_Definition__r.Scheduled_Execution__c = true AND
                                                                  csdf__Report_Status__c != 'Integration Error' AND csdf__Report_Status__c != 'Completed'];
        this.delayExecution = !reportExecution.isEmpty();
    }
    
    /**
     * Method that locks Billing Schedule Items
     * @param  salesOrders List<SObject>
     */
    public override void doWork(List<SObject> salesOrders) {
        if(!salesOrders.isEmpty()) {
            Map<Id, SObject> salesOrdersToProcess = new Map<Id, SObject>();
            for(SObject salesOrderSchedule : salesOrders) {
                salesOrdersToProcess.put(String.valueOf(salesOrderSchedule.get('Sales_Order__c')), salesOrderSchedule);
            }
            
            CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();

            try {
                for(String processServiceName : Schedules_To_Process) {
                    Type processService = Type.forName(processServiceName);
                    CS_ActualsService service = (CS_ActualsService) processService.newInstance();
                    
                    List<SObject> scheduleItems = service.doCalculate(salesOrdersToProcess.keySet(), executeDate);
                    if(scheduleItems.size() > chunkLimit) {
                        prepareWork(dispatcher, scheduleItems, salesOrdersToProcess.keySet(), executeDate, processServiceName);
                    }
                }

                dispatcher.dispatch();
            }
            catch (Exception e) {
                for(Id salesOrderId : salesOrdersToProcess.keySet()) {
                    log.addMessage(e, salesOrderId);
                }
                
                this.success = false;
            }
        }
    }
    
    @TestVisible
    protected override Database.QueryLocator onStart() {
        this.queryString = getQueryString(INITIAL_QUERY_TEMPLATE);
        
        return super.onStart();
    }
    
    @TestVisible
    private String getQueryString(String template) {
        return String.format(template, new List<String>{
            String.valueOf(executeDate.addDays(7)),
            String.valueOf(executeDate.addDays(-7))
        });
    }

    public class CS_ActualsWorker extends CS_QueueableWorker {
        public CS_ActualsWorker(Object params) {
            super('CS_ActualsWorker', params);
        }

        public override void doWork() {
            system.debug(this.params);
            Map<String, Object> paramsType = (Map<String, Object>) this.params;
            List<SObject> scheduleItems = (List<SObject>) paramsType.get('scheduleItems');
            Set<Id> salesOrderIds = (Set<Id>) paramsType.get('salesOrderIds');
            Date executeDate = (Date) paramsType.get('executeDate');
            String service = (String) paramsType.get('service');

            try {
                Type processService = Type.forName(service);
                CS_ActualsService serviceType = (CS_ActualsService) processService.newInstance();
                serviceType.doCalculate(scheduleItems, salesOrderIds, executeDate);
            }
            catch (Exception e) {
                for(Id salesOrderId : salesOrderIds) {
                    log.addMessage(e, salesOrderId);
                }
                
                this.success = false;
            }
        }
    }

    public static void prepareWork(CS_QueueableDispatcher dispatcher, List<SObject> scheduleItems,
                                                Set<Id> salesOrderIds, Date executeDate, String service) {
        Integer chunkSize = (Integer) CS_Custom_Settings__c.getInstance().Consolidation_Size__c;

        Integer addedItems = 0;
        List<SObject> currentScheduleItems = new List<SObject>();
        for(SObject item : scheduleItems) {
            if(currentScheduleItems.size() < chunkSize) {
                currentScheduleItems.add(item);
                addedItems++;
            }
            
            if(currentScheduleItems.size() >= chunkSize || scheduleItems.size() == addedItems) {
                dispatcher.addWorker(new CS_ActualsWorker(new Map<String, Object> {
                    'scheduleItems' => currentScheduleItems.clone(),
                    'salesOrderIds' => salesOrderIds,
                    'executeDate' => executeDate,
                    'service' => service
                }));

                currentScheduleItems = new List<SObject>();
            }
        }
    }
}
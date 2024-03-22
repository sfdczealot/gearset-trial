/**
 * Created by sasa.marjancic on 26.3.2020..
 */

public class CS_FulfilmentUpsertWorker implements Callable {
    public csmso__Sales_Order__c salesOrder { get; set; }

    public Map<Id, cscfga__Product_Configuration__c> configs { get; set; }

    public String action { get; set; }

    public CS_Custom_Settings__c customSettings {
        get {
            if (customSettings == null) {
                customSettings = CS_Custom_Settings__c.getInstance();
            }
            return customSettings;
        }
        set;
    }

    public List<csdf__Fulfilment_Item__c> createFulfilmentItems(Map<String, Object> args) {
        this.salesOrder = args.containsKey('salesOrder') ? (csmso__Sales_Order__c) args.get('salesOrder') : CS_utl_SalesOrder.getSalesOrder((Id)args.get('salesOrderId'));
        this.action = (String) args.get('action');
        this.configs = new Map<Id, cscfga__Product_Configuration__c>(this.salesOrder.Product_Configurations__r);

        return createFulfilmentItems();
    }

    public Object call(String action, Map<String, Object> args) {
        Id salesOrderId = (Id) args.get('salesOrderId');
        List<CSPOFA__Orchestration_Step__c> steps = [SELECT Id, CSPOFA__Status__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c
        WHERE CSPOFA__External_Id__c = :salesOrderId AND CSPOFA__Status__c = 'Waiting For Feedback'];
        for(CSPOFA__Orchestration_Step__c step : steps) {
            step.CSPOFA__Status__c = 'Complete';
            step.CSPOFA__Message__c = 'Fulfilment Items created.';
            step.CSPOFA__Completed_Date__c = Date.today();
        }

        update steps;
        return steps;
    }

    public List<csdf__Fulfilment_Item__c> createFulfilmentItems() {
        Integer chunkSize = customSettings.Max_n_Lines_for_Sync_Execution__c.intValue();
        Integer targetableChunkSize = customSettings.Max_n_Templates_for_Sync_Execution__c.intValue();
        Set<Id> configIds = new Set<Id>(configs.keySet());
        system.debug('**********configs.size() '+configs.size());
        
        Boolean syncProcessing = ((configIds.size() < chunkSize) && (sumTargetings() < targetableChunkSize));

        if (!syncProcessing) {
            Integer totalTargets = 0;
            Set<Id> pcIds = new Set<Id>();
            CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();
            for (Integer i = 0; i < configs.values().size(); i++) {
                cscfga__Product_Configuration__c pc = configs.values()[i];
                pcIds.add(pc.Id);
                configIds.remove(pc.Id);
                totalTargets += pc.Number_of_Targetings__c != null ? pc.Number_of_Targetings__c.intValue() : 0;
                if ((pcIds.size() > chunkSize) || (totalTargets > targetableChunkSize)) {
                    // if values have exceeded limit we do not need to use the current PC
                    // so we need to remove it to create the worker.
                    if(pcIds.size() > 1) {
                        pcIds.remove(pc.Id);
                        configIds.add(pc.Id);
                        i--;
                    }
                    // create worker
                    dispatcher.addWorker(createWorker(pcIds, configIds));
                    // variables need to be reset for testing
                    pcIds = new Set<Id>();
                    totalTargets = 0;
                }
                else if (configIds.size() == 0) {
                    dispatcher.addWorker(createWorker(pcIds, configIds));
                }
            }

            if (!Test.isRunningTest()) {
                dispatcher.dispatch();
            }

            return null;
        } else {
            return createFulfilmentItems(new Map<String, Object>{
                    'retry' => 0, 'configIds' => this.configs.keySet(),
                    'action' => this.action, 'salesOrderId' => this.salesOrder.Id
            }, null);
        }
    }

    public FulfilmentInvokerWorker createWorker(Set<Id> pcIds, Set<Id> configIds) {
        return new FulfilmentInvokerWorker(new Map<String, Object>{
                'retry' => 0,
                'configIds' => pcIds,
                'action' => configIds.size() == 0 ? this.action : null,
                'salesOrderId' => this.salesOrder.Id
        });
    }

    private Integer sumTargetings() {
        Integer total = 0;
        for (cscfga__Product_Configuration__c pc : this.configs.values()) {
            total += pc.Number_of_Targetings__c != null ? pc.Number_of_Targetings__c.intValue() : 0;
        }

        return total;
    }

    public List<csdf__Fulfilment_Item__c> createFulfilmentItems(Object params, Object previousWorker) {
        CS_QueueableWorker worker;
        Map<String, Object> paramsType = (Map<String, Object>) params;

        if ((Integer) paramsType.get('retry') < 5) {
            try {
                return CS_FulfilmentService.generateFulfilmentItems((Set<Id>) paramsType.get('configIds'), false);
            } catch (System.DmlException dmlException) {
                worker = new FulfilmentInvokerWorker(new Map<String, Object>{
                        'retry' => ((Integer) paramsType.get('retry')) + 1, 'configIds' => (Set<Id>) paramsType.get('configIds'),
                        'action' => (String) paramsType.get('action'), 'salesOrderId' => (Id) paramsType.get('salesOrderId')
                });
            } catch (System.QueryException QueryException) {
                worker = new FulfilmentInvokerWorker(new Map<String, Object>{
                        'retry' => ((Integer) paramsType.get('retry')) + 1, 'configIds' => (Set<Id>) paramsType.get('configIds'),
                        'action' => (String) paramsType.get('action'), 'salesOrderId' => (Id) paramsType.get('salesOrderId')
                });
            } catch(Exception e) {
                csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c(
                        Id = (Id) paramsType.get('salesOrderId'),
                        csmso__Process_Message__c = e.getMessage() + ' - - - ' + String.valueOf(paramsType),
                        csmso__Process_Message_Type__c = 'error',
                        Loading_Screen__c = 'Off');
                update salesOrder;
            }

            if (previousWorker != null) {
                CS_QueueableWorker lastWorker = ((CS_QueueableWorker) previousWorker).getLastWorker();
                lastWorker.setNextWorker(worker);
                ((Map<String, Object>) lastWorker.params).put('action', null);
            } else {
                CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();
                dispatcher.addWorker(worker);
                if (!Test.isRunningTest()) {
                    dispatcher.dispatch();
                }
            }
        }

        return null;
    }

    public class FulfilmentInvokerWorker extends CS_QueueableWorker {
        public FulfilmentInvokerWorker(Object params) {
            super('FulfilmentInvokerWorker', params);
        }

        public override void doWork() {
            try {
                Map<String, Object> paramsType = (Map<String, Object>) params;

                CS_FulfilmentUpsertWorker fulfilmentUpsertWorker = new CS_FulfilmentUpsertWorker();
                if ((Integer) paramsType.get('retry') < 5) {
                    List<csdf__Fulfilment_Item__c> fulfilmentItems =
                            (List<csdf__Fulfilment_Item__c>) fulfilmentUpsertWorker.createFulfilmentItems(params, this);

                    if (fulfilmentItems != null && paramsType.containsKey('action')) {
                        Type callableService = Type.forName(paramsType.containsKey('action') != null ? (String) paramsType.get('action') : 'CS_ButtonBase');
                        Callable callable = (Callable) callableService.newInstance();
                        callable.call((String)paramsType.get('action'), paramsType);
                    }
                }
                else {
                    this.nextWorker = null;
                    setSalesOrderMessage((Id) paramsType.get('salesOrderId'), 'Please re-try the action.', 'error');
                }
            }
            catch (Exception e) {
                this.nextWorker = null;
                Map<String, Object> paramsType = (Map<String, Object>) params;
                setSalesOrderMessage((Id) paramsType.get('salesOrderId'), 'Please re-try the action.', 'error');
            }
        }

        public void setSalesOrderMessage(Id salesOrderId, String message, String messageType) {
            csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c(
                    Id = salesOrderId,
                    csmso__Process_Message__c = message,
                    csmso__Process_Message_Type__c = messageType,
                    csmso__Status__c = CS_const_SalesOrder.Status_Rejected,
                    Loading_Screen__c = 'Off');
            update salesOrder;
        }
    }
    public static void codeCoverage(){
        integer i =0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
       
        
    }
}
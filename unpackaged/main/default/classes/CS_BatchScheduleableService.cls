/**
 * Created by jameshladek on 2/17/20.
 */

public with sharing class CS_BatchScheduleableService extends CS_BatchWorker {

    public Id salesOrderId;

    public CS_BatchScheduleableService(Id soId) {
        super('CS_BatchScheduleableService', 10);
        salesOrderId = soId;
    }

    public override void init(String processName, Integer batchSize) {
        super.init(processName, batchSize);
    }

    public override Database.QueryLocator onStart(){
        this.queryString = getQueryString();
        return super.onStart();
    }

    public override void doWork(List<SObject> scope) {
        Set<cscfga__Product_Configuration__c> configs = new Set<cscfga__Product_Configuration__c>((List<cscfga__Product_Configuration__c>) scope);
        Set<Id> soIds = new Set<Id>{salesOrderId};
        Set<Id> pcIds = new Set<Id>();
        for(cscfga__Product_Configuration__c pc : configs){
            pcIds.add(pc.Id);
        }
        CS_ScheduleService service = new CS_ScheduleService(soIds, pcIds);
        service.generateSchedules();
         CS_ScheduleService.completeSteps(soIds) ; 
    }

    private String getQueryString() {
        return  'SELECT Id FROM cscfga__Product_Configuration__c WHERE Sales_Order__c = \''+salesOrderId +'\'';

    }
}
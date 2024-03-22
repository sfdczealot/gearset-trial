public class CS_PGUpdateFulfilmentsBatch extends CS_BatchWorker implements Database.AllowsCallouts {
    public static string QUERY_TEMPLATE = 
            'SELECT Id, Sales_Order__c, Sales_Order__r.Is_Programmatic__c ' +
            'FROM csdf__Fulfilment__c ' +
            'WHERE csdf__Ad_Server_Id__c != NULL AND csdf__Is_Programmatic__c = true AND ' +
            'Sales_Order__r.To_Date_Time_Calculated__c >= YESTERDAY';

    /**
     * Class constructor
     * @return CS_PGUpdateFulfilmentsBatch
     */
    public CS_PGUpdateFulfilmentsBatch() {
        super('CS_PGUpdateFulfilmentsBatch', 1);
        this.queryString = QUERY_TEMPLATE;      
    }

    @TestVisible
    protected override Database.QueryLocator onStart() {
        this.queryString = QUERY_TEMPLATE;
        
        return super.onStart();
    }
    
    public static void schedule(){
        System.schedule('Update PG Fulfilments ' + System.currentTimeMillis(), 
                        '0 0 0/1 ? * * *', 
                        new CS_PGUpdateFulfilmentsBatch());
    }
    
    /**
     * Method that handles processing of Orders
     * @param  sObjects List<SObject>
     */
    public override void doWork(List<SObject> sObjects) {
        CS_Util.spinWait(1000);
        
        Map<Id, SObject> fulfilments = new Map<Id, SObject>(sObjects);

        if(!Test.isRunningTest()){
            csam.ObjectGraphCalloutHandler.createAndSendFromIds('Fulfilment Refresh', new List<Id>(fulfilments.keySet()));
        }
    }
}
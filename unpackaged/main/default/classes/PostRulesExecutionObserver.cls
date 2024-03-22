global with sharing class PostRulesExecutionObserver implements csam.ObserverApi.IObserver{
    global PostRulesExecutionObserver() { }  

    global void execute(csam.ObserverApi.Observable o, Object arg) {

        if (o instanceof csb2c.ProductBasketObservable || Test.isRunningTest()) {
            csb2c.ProductBasketObservable pBObservable = (csb2c.ProductBasketObservable) o;
            List<Id> basketIds = pBObservable.getBasketIds();

            CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();
            dispatcher.addWorker(new CreateOppObserver_new(new Map<String, Object> {
                    'basketIds' => basketIds
            }));
//            CreateOppObserver updateJob = new CreateOppObserver(basketIds);
//            ID jobID = System.enqueueJob(updateJob);
            dispatcher.dispatch();
        }
        
    }
    
}
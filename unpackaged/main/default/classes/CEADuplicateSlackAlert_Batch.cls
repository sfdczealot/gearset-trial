global class CEADuplicateSlackAlert_Batch implements Database.Batchable<aggregateresult>,Database.AllowsCallouts{
    
    String query;
    String errorResponse;
    
    public class Payload {
        String text; 
    }
    
    global Iterable<aggregateresult> start(Database.BatchableContext bc) {
        String query = 'SELECT CEA_Salesperson_Number__c, count(Id) FROM Account WHERE (NOT Account_Rule_Code__c like \'%CORP%\') and Country__c=\'Singapore\' and CEA_Salesperson_Number__c!=NULL and recordtype.developerName= \'Agent\' GROUP BY CEA_Salesperson_Number__c HAVING count(Id)>1';
        return new AggregateIterable(query);
    }
    
    
    global void execute(Database.BatchableContext bC, list<AggregateResult> listCEA) {
        
        if (!runningInASandbox() || Test.isRunningTest()) {
            
            Payload payloadData = new Payload();
            Integer count = 0;
            String title = '';
            String text = '```"CEA NO.", "COUNT"\n';
            String payload = '';
            for (AggregateResult recList: ListCEA) {
                text += '"'+recList.get('CEA_Salesperson_Number__c')+'", "'+recList.get('expr0')+'"\n';
                Count++;
            }
            if(Count > 0){
                text += '```';
                title += label.CEA_SLACK_NOTIFICATION+' '+ Count +' duplicate CEA agents found \n'; 
                payload += title + text;
                
            }
            system.debug('payload   '+payload);
            if(payload <> ''){
                system.debug(system.JSON.serialize(payload));
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(label.PG_LABEL_PGAutomationAlert);
                req.setMethod('POST');
                req.setHeader('Cache-Control', 'no-cache');
                req.setHeader('Content-Type', 'application/json');
                PayloadData.text = payload;
                string request = system.JSON.serialize(PayloadData);
                req.setBody(request);
                if(!Test.isRunningTest()){
                    HttpResponse res = h.send(req);
                    if (res.getStatusCode() <> 200) {
                        errorResponse = res.getBody();
                        system.debug(errorResponse);
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bC) {
        
    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
}
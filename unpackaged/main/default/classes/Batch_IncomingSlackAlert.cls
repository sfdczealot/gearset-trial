Global class Batch_IncomingSlackAlert implements Database.Batchable<SObject>,system.Schedulable,Database.AllowsCallouts{
    
    String errorResponse;
    
   public class Payload {
        String text;
    } 
    
    Global Database.QueryLocator Start(Database.BatchableContext BC){
        DateTime createdDate = DateTime.now().addHours(-3);
        String query = 'SELECT createddate,Name,Id,csam__Status__c,csam__Content_Type__c,csam__URL_Host__c,csam__Delivery_Tag__c FROM csam__Outgoing_Message__c where  csam__Status__c=\'Waiting for response\'  AND createdDate < :createdDate';        
        return Database.getQueryLocator(query);
    }
    
    Global void execute(Database.BatchableContext BC, list<csam__Outgoing_Message__c> scope){
        
        payload payloadData = new payload();
        integer count = 0;
        String payload = '';
        String title = '';
        String text = '```"Id", "Status"\n';
        
        for(csam__Outgoing_Message__c message:scope){
            system.debug('incoming messages==>' +message);
            text += '"'+message.Id+'", "'+message.csam__Status__c+'"\n';
            Count++;
        }
        
        if(Count > 0){
            title ='<@UT08YGN95> '+'Outgoing Message is stuck at waiting for response \n'; 
            payload += title + text;
        }          
        
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
    
    
    Global void finish(Database.BatchableContext BC){}
    global void execute(SchedulableContext sc) {
        
        Database.executeBatch(new Batch_IncomingSlackAlert());
    }
}
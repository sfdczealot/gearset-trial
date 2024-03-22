global class SlackAlert_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts{

    String query, errorResponse;

    public class Payload {
        String text;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        String query = label.PG_LABEL_AttLimit_q;
        if(query == 'null'){
            query = 'select id,createddate,Opportunity_Number__c from opportunity where Attachment_Limit_Exceeded__c = true and StageName = \'Closed Won\'';
        }
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Opportunity> OpptyAttachmentSkip) {
        
        if (!runningInASandbox() || Test.isRunningTest()) {
            
            Payload PayloadData = new Payload();
            Integer Count = 0;
            String slack_user = label.PG_LABEL_AttLimit_User;
            String title = '', text = '```"OPPTY_NUMBER", "SALESFORCE_ID", "CREATED_DATE"\n', payload = '';
            for (Opportunity recList: OpptyAttachmentSkip) {
                text += '"'+recList.Opportunity_Number__c+'", "'+recList.Id+'", "'+recList.CreatedDate+'"\n';
                Count++;
            }
            if(Count > 0){
                text += '```';
                title += slack_user+' ' +Count +' oppty have skip NetSuite Sync due to attachment limit exceeded\n'; 
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
    }
    
    global void finish(Database.BatchableContext BC) {

    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
}
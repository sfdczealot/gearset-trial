global class NoOLI_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts{

    String query, errorResponse;

    public class Payload {
        String text;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        String query = label.PG_LABEL_NoOLI_Batch_q;
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Opportunity> OpptyNoOLI) {
        Payload PayloadData = new Payload();
        Integer Count = 0;
        String slack_user = label.PG_LABEL_NoOLI_User;
        String title = '', text = '```"OPPTY_NUMBER", "SALESFORCE_ID", "LASTMODIFIED_DATE", "LASTMODIFIED_BY"\n', payload = '';
        for (Opportunity recList: OpptyNoOLI) {
            text += '"'+recList.Opportunity_Number__c+'", "'+recList.Id+'", "'+recList.LastModifiedDate+'", "'+recList.LastModifiedBy.Name+'", "'+recList.StageName+'"\n';
            count++;
        }
        if(Count > 0){
            text += '```';
            String orgEnv = runningInASandbox() ? 'sandbox' : 'production';
            title += slack_user+' ' +Count +' oppty(s) have no OLI in ' + orgEnv + 'environment\n'; 
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
    
    global void finish(Database.BatchableContext BC) {

    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
}
// Common class to send alert on PG Automation Channel of Slack
//Test Class: BatchToComputeTotalSpending_Test
public class SlackAlert {
    
    public class Payload {
        String text;
    }
    
    public static void notifyPGAutoChannel(String payload){
           if(!runningInASandbox() || Test.isRunningTest()){  
        Payload PayloadData = new Payload();
            
            if(payload <> ''){
                system.debug('@@@@JSONpayload'+system.JSON.serialize(payload));
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(label.PG_LABEL_PGAutomationAlert);
                req.setMethod('POST');
                req.setHeader('Cache-Control', 'no-cache');
                req.setHeader('Content-Type', 'application/json');
                PayloadData.text = payload;
                string request = system.JSON.serialize(PayloadData);
                system.debug('@@@@request'+request);
                req.setBody(request);
                if(!Test.isRunningTest()){
                    // Commented temporarily
                    HttpResponse res = h.send(req);
                    if (res.getStatusCode() <> 200) {
                        String errorResponse = res.getBody();
                        system.debug(errorResponse);
                    }
                }
            }
        }
    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

}
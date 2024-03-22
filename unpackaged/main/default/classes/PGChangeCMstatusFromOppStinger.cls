global class PGChangeCMstatusFromOppStinger implements Database.Batchable<sObject>,Database.AllowsCallouts{
    
    global String query;
    global set<Id> setOfQuoteIds;
    global PGChangeCMstatusFromOppStinger(set<Id> setOfQuoteIds){
        this.setOfQuoteIds = setOfQuoteIds;
        query = 'SELECT Id, Name, Quote_Number__c, Status, Country__c, Opp_Quote_Ref_num__c,Account.AgentNet_ID__c,Hash_Code__c FROM Quote where Id IN: setOfQuoteIds';
        
    }
    	
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Quote> scope){
        for(Quote sObj : scope){
            
            String requestJson = createJson(sObj);
            if(String.isNotBlank(requestJson)){
                String retResponse = calloutToJson(requestJson,sObj);
                if(String.isNotBlank(retResponse) && !retResponse.ContainsIgnoreCase('Error') ){
                    system.debug('SUCCESS');
                    
                }else {
                    System.debug('ERROR Or Empty Response');
                    
                }
            }
            
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    global static string createJson(Quote qt){
        if(String.isNotBlank(qt.Country__c)){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject ();
                gen.writeStringField('status', 'close');
            gen.writeEndObject();
            return gen.getAsString(); 
        }

        return '';
        
    }
    global static string calloutToJson(String requestJson,Quote quote){
        
        Map<string,string> reqHeaders = new Map<string,string>();
        HttpResponse res;
        String hashCode = encodingutil.urlEncode(quote.Hash_Code__c,'UTF-8');
        String RootEndpoint;
        String clientId = label.PG_LABEL_OpportunityPaymentClientId;
        String clientSecret = label.PG_LABEL_OpportunityPaymentClientSecret;  
        if (runningInASandbox()) {
            RootEndpoint = label.PG_LABEL_OpportunityQuotePaymentAPI_SB+'/'+hashCode;
        }
        else{
            RootEndpoint = label.PG_LABEL_OpportunityQuotePaymentAPI+'/'+hashCode;
        }
        
        reqHeaders.put('x-client-id', clientId);
        reqHeaders.put('x-client-secret', clientSecret);
        reqHeaders.put('Content-Type', 'application/json');
        
        res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,'','PATCH',true,true,blob.valueOf(requestJson),null);
        if(res!=null){
            system.debug('>>>>res.getBody() '+res.getBody());
            return res.getBody() ;
        }else{
            return '';
        }
        
        
        
    }
     public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}
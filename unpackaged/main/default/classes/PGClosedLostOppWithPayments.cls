global class PGClosedLostOppWithPayments implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful,schedulable  {
    
    String errorResponse;
    Map<String,list<opportunity>> opportunityWithOwner = new Map<String,list<opportunity>>();
    
    public class Payload {
        String text;
    }
    
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(this, 100);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query ;
        if(!Test.isrunningtest()){
            query = 'SELECT Id,OpportunityId,CreatedDate,Opportunity.StageName , Field FROM OpportunityFieldHistory where Field = \'Stagename\' and Opportunity.StageName = \'Closed Lost\'  AND CreatedDate = yesterday';  
            
        }else{
            query = 'SELECT Id,OpportunityId,CreatedDate,Opportunity.StageName , Field FROM OpportunityFieldHistory where Field = \'Stagename\' and Opportunity.StageName = \'Closed Lost\'  AND CreatedDate = today';  
            
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<OpportunityFieldHistory> ClosedLostOppHistory){
        if (!runningInASandbox()||Test.isRunningTest()) {
            list<Id> oppIds = new List<Id>();
            
            for(OpportunityFieldHistory OFH : ClosedLostOppHistory){
                oppIds.add(OFH.OpportunityId);
            }
            Payload PayloadData = new Payload();
            Integer Count = 0;
            String title = '', text = '```"OPPORTUNITY_Number__c", "OPPORTUNITY_LONGID", "ACCOUNT_Name", "OWNER_EMAIL"\n', payload = '';
            for(Opportunity opp : [Select id,Name,Opportunity_Number__c,OwnerId,Owner.Name,Opp_Long_ID__c,Account.Name,Owner.Email,(Select id from Payments__r) from Opportunity where id In :oppIds]){
                if(opp.Payments__r != null && !opp.Payments__r.isEmpty()){
                    if(!opportunityWithOwner.containsKey(opp.Owner.Email)){
                        opportunityWithOwner.put(opp.Owner.Email,new list<opportunity>{opp}); 
                    }
                    else{
                        list<opportunity> opp_list= opportunityWithOwner.get(opp.Owner.Email);
                        opp_list.add(opp);
                        opportunityWithOwner.put(opp.Owner.Email,opp_list);
                    }
                    system.debug('opportunityWithOwner'+opportunityWithOwner);
                    text += '"'+opp.Opportunity_Number__c+'", "'+opp.Opp_Long_ID__c+'", "'+opp.Account.Name+'", "'+opp.Owner.Email+'"\n';
                    Count++;
                }
            }   
            
            
            if(Count > 0){
                text += '```';
                title += Count +' Opportunity with Payment have been closed lost\n'; 
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
                system.debug('request'+request);
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
    
    
    global void finish(Database.BatchableContext BC){
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for(String owner : opportunityWithOwner.keyset()){
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setSaveAsActivity(False);
            message.setTargetObjectId(opportunityWithOwner.get(owner)[0].ownerid);
            message.subject = 'OPPORTUNITY WITH PAYMENT BUT CLOSED LOST';
            System.debug('id'+opportunityWithOwner.get(owner)[0].ownerid);
            String body = 'Dear '+opportunityWithOwner.get(owner)[0].Owner.Name+',\n' +
                '\n Below is the list of Opportunities those are CLOSED LOST and have a Payment :\n';
            
            for(Opportunity opp : opportunityWithOwner.get(owner)){
                body += '\n Opportunity Name :'+opp.name +'\n Opportunity Link'+ URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+
                    '\n Account Name : '+opp.account.name+'\n'+'\n';
            }
            System.debug(body);
            message.setPlainTextBody(body);
            messages.add(message);
            
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if(!results.isempty()){
            if (results[0].success) {
                System.debug('The email to Owners were sent successfully.');
            } else {
                System.debug('The email to Owners failed to send: '+ results[0].errors[0].message);
            }      
        }
        
    }
    
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    } 
}
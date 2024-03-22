public class WhatsAppUtils {

    public static List<WAMessage__c> listAllMessageByCustomer(String customerPhone){
        List<WAMessage__c> messages = new List<WAMessage__c>();
        messages = [SELECT Id, Name, MessageContent__c, MessageType__c, Outgoing__c FROM WAMessage__c WHERE CustomerPhone__c =: customerPhone];
        return messages;
    }
    public static WAMessage__c sendTextMessage(String messageContent, String toPhone){
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('https://graph.facebook.com/v17.0/102183599609150/messages');
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Authorization', 'Bearer EAAcU4T1scjoBO6ZABK3I4RuFALyaZAAKbExOUovd8VDXHjtpzAz0fVdyZAY1ZAqsHVfSjjudyT9lH149L1BH0ZANtbQlV2fpSr6JUKSSGTcCfdqoEPPPZBjBJzmMvSKxow5vmsNdtOpCWaDoJjgxyuW4ZBfdAf8hwb4Q7Ng5IkSH4ANwvj55XHzDE8iPnB4WDNbSDJDqTVqCMT1EAvYcVJ9K3bZCeTdMhzWgG2sZD');
        
        String messageBody = '{'+
        '    "messaging_product": "whatsapp",'+
        '    "recipient_type": "individual",'+
        '    "to": "'+toPhone+'",'+
        '    "type": "text",'+
        '    "text": {'+
        '        "preview_url": false,'+
        '        "body": "'+messageContent+'"'+
        '    }'+
        '}';
        
        httpReq.setBody(messageBody);
        
        Http http = new Http();
        WAMessage__c salesforceMessage = new WAMessage__c();
        try{
            HttpResponse response = http.send(httpReq);
            if( response.getStatusCode() == 200 ){
                // Parse & Create Message Record
                System.debug('Successful!');
                WhatsAppUtils responseFromWA = (WhatsAppUtils) JSON.deserialize( response.getBody() , WhatsAppUtils.class);
                
                salesforceMessage.MessageContent__c = messageContent;
                salesforceMessage.CustomerPhone__c = toPhone;
                salesforceMessage.MessageID__c = responseFromWA.messages.get(0).id;
                salesforceMessage.MessageType__c = 'text';
                salesforceMessage.Outgoing__c = True;
                salesforceMessage.AgentName__c = UserInfo.getFirstName()+' '+ UserInfo.getLastName();
                upsert salesforceMessage MessageID__c;
            }
        }catch(System.CalloutException ex){
            System.debug(' CalloutException Executed '+ ex.getStackTraceString() );
            System.debug(' CalloutException Executed '+ ex.getMessage() );
        }catch(System.Exception ex){
            System.debug(' System.Exception Executed '+ ex.getStackTraceString() );
        }
        return salesforceMessage;
    }
    
  public String messaging_product;
    public contacts[] contacts;
    public messages[] messages;
    public class contacts {
        public String input;
        public String wa_id;
    }
    public class messages {
        public String id;
    }
}
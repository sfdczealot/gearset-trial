public class WhatsappIntegration {
    
    @AuraEnabled
    public static boolean sendTemplateMessage (String contactId){
        System.Debug('contactId###' + contactId);
        
        Contact contact = [SELECT id,MobilePhone FROM Contact WHERE Id =: contactId];

        String whatsNumber = '+91'+contact.MobilePhone;

        Http http = new Http ();
        
        HttpRequest hreq = new HttpRequest();
        hreq.setEndpoint('https://graph.facebook.com/v13.0/102183599609150/messages');
        hreq.setHeader('Content-Type', 'application/json');
        hreq.setMethod('POST');
        
        String body = '{ "messaging_product": "whatsapp", "to" : "'+whatsNumber+'", "type" : "template", "template": {"name": "hello_world", "language":{"code":"en_US"}}}';
        hreq.setBody(body);
        
        String apiToken = 'EAAcU4T1scjoBAId0gnrB2xihP2UyAtpvG5yZBhFCxaKdp9mASAYfJ8aDHPL5tL6km40pHuTtFUtoMJHyH0buDklVPi4nZCc3GHaWRZC658t5dKKho3ZBUC3vCBQtnHzD4eaIULee9Hc1ftFLGbqAd1f9dQ6ygUm7naD27OQ4rcdP5zE1TpDXpVtZAy2rcdz9BWmZCoBxANsQCg5pOGCv90k57ZCgWpunWMZD'; 
        hreq.setHeader('Authorization', 'Bearer '+apiToken);
        
        HttpResponse hres = http.send(hreq);
        
        if(hres.getStatusCode()== 200){
            return true;
        }
        return false;
    }
}
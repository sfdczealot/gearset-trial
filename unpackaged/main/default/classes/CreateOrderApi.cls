@RestResource(urlMapping='/CreateOrder/')
global class CreateOrderApi {
    
    @HttpGet
    global static csdf__Fulfilment__c doGet(){
        RestRequest req = RestContext.request;
        Map<String,String> fulfilrequestParas = req.params;
       // String fulfilId = fulfilrequestParas.get('id');
        RestResponse res = Restcontext.response;
        Set<id> fId = new Set<id>();
        fId.add(fulfilrequestParas.get('id'));
        
     
        
        csdf__Fulfilment__c fulfil = [Select id,Name,Sales_Order__r.SO_Start_Date__c From csdf__Fulfilment__c Where id IN:fId];
        return fulfil;
        
        
    }
    

}
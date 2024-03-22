global class GurulandApi {

    @AuraEnabled
    public static String getAgentNetKey(Id recordId) {
        Account acc = [select Id,AgentKey__c,Status__c  from Account where Id =: recordId LIMIT 1];
        system.debug('Agent key is ' + acc.AgentKey__c);
        if(acc.AgentKey__c == null || acc.AgentKey__c == '' ) {
            throw new AuraHandledException('Agentnet id is empty');
        } else if(acc.Status__c != 'Pending' && acc.Status__c != 'Expired' && acc.Status__c != 'Suspended') {
            throw new AuraHandledException('Agent status should be Pending or Expired or Suspended');
        }
        return acc.AgentKey__c;
    }

    @AuraEnabled
    public static String callResendApi (id accId){
        HttpResponse response = GurulandApi.callResendEndpoint(accId);
        return String.valueOf(response.getStatusCode());
    }

    public static HttpResponse callResendEndpoint (id accId){
        Account objAccount = [SELECT Id, AgentKey__c, Country__c, AgentNet_ID__c FROM Account WHERE Id =: accId LIMIT 1];

        if(String.isNotBlank(objAccount.Country__c) && objAccount.Country__c.equals('Singapore')) {
            return callResendEndpointSG(objAccount);
        } else {
            return callResendEndpointNonSG(objAccount);
        }
    }

    private static HttpResponse callResendEndpointSG(Account objAccount) {
        //endpoint
        String RootEndpoint;
        if (runningInASandbox()) {
            RootEndpoint = label.PG_LABEL_AgentSyncEndPoint_SB_SG;
        } else {
            RootEndpoint = label.PG_LABEL_AgentSyncEndPoint_SG;
        }
        if(String.isNotBlank(objAccount.Country__c)) {
            RootEndpoint = RootEndpoint.replace('$AgentCountry', objAccount.Country__c.toLowerCase());
        }

        //header
        Map<string,string> reqHeaders = new Map<string,string>();
        reqHeaders.put('Content-Type', 'application/json');
        reqHeaders.put('User-Agent', 'pgsf');
        reqHeaders.put('accept', '*/*');

        //body
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        if(objAccount.AgentNet_ID__c != null) {
            gen.writeNumberField('agentId', Long.valueOf(objAccount.AgentNet_ID__c));
        }
        gen.writeBooleanField('setPassword', true);
        gen.writeEndObject();

        HttpResponse res;
        if(Test.isRunningTest()) {
            String resString = '{"agentId":"10244901","code":"AG2000","message":"Resend verification email is successful."}';
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(resString);
        } else {
            res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders, RootEndpoint, gen.getAsString(), 'POST', true, false, null, null);
            if(res.getStatusCode() == 200){
                System.debug('Agent verification email sent');
            } else {
                System.debug('Agent verification email send failure ' + res.getStatusCode());
            }
        }
        return res;
    }

    private static HttpResponse callResendEndpointNonSG(Account objAccount) {
        Map<string,string> reqHeaders = new Map<string,string>();
        HttpResponse res;

        String RootEndpoint, RootEndpointKey;

        if (runningInASandbox()) {
            RootEndpoint = label.PG_LABEL_AgentSyncEndPoint_SB;
            RootEndpointKey = label.PG_LABEL_AgentSyncEndPointKey_SB;
        }
        else{
            RootEndpoint = label.PG_LABEL_AgentSyncEndPoint;
            RootEndpointKey = label.PG_LABEL_AgentSyncEndPointKey;
        }

        String region = (objAccount.AgentKey__c).substring(0,2).toLowerCase();
        String agentNetId = (objAccount.AgentKey__c).substring(2);
        RootEndpoint = RootEndpoint.replace('agentId', agentNetId).replace('agentRegion',region);

        reqHeaders.put('Cache-Control', 'no-cache');
        reqHeaders.put('Authorization', RootEndpointKey);
        reqHeaders.put('Content-Type', 'application/json');
        reqHeaders.put('User-Agent', 'salesforce/apex');

        if(Test.isRunningTest()) {
            String resString = '{"agentId":"10244901","code":"AG2000","message":"Resend verification email is successful."}';
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(resString);
        } else {
            res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,'','POST',false,false,null,null);
            if(res.getStatusCode() == 200){
                System.debug('Agent verification email sent');
            } else {
                System.debug('Agent verification email send failure ' + res.getStatusCode());
            }
        }
        return res;
    }

    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}
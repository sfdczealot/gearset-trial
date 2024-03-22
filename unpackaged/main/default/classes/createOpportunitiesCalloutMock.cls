@isTest
global class createOpportunitiesCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"label":"Name","value":"t"},{"label":"Name","value":"te"},{"label":"Name","value":"tes"},{"label":"Name","value":"test"},{"label":"Name","value":"test "},{"label":"Name","value":"test o"},{"label":"Name","value":"test op"},{"label":"Name","value":"test opp"},{"label":"StageName","value":"New"},{"label":"CloseDate","value":"2022-06-30"},{"label":"Startdate","value":"2022-06-29"},{"label":"iPProducts","value":"MYIPCT_DIGDEP_LITEPKG"},{"label":"AccountId","value":"0017F00001hgfpQQAQ"},{"label":"Opportunity_Type__c","value":"B2C - Standard"},{"label":"Priority__c","value":"Low"},{"label":"PGProducts","value":"Test"}}]');
        res.setStatusCode(200);
        return res;
    }

}
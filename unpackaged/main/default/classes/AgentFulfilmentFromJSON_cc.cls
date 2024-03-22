/*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : to catch Agent fulfilment data from Property Guru to Classes
Inputs      : JSON Request
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
public class AgentFulfilmentFromJSON_cc{
    public response response;
    public String method;  
    public String region;   
    public payload payload;
    class response {
        public Integer total;   
        public records[] records;
    }
    class records {
        public Integer id;  
        public Integer webuserId;   
        public String invoiceId;    
        public String externalId;   
        public Integer billingSourceId; 
        public purchasedDate purchasedDate;
        public String internalId;   
        public startDate startDate;
        public expiryDate expiryDate;
        public String name; 
        public String productCode;  
        public String purchasedQuantity;  
        public String statusCode;  
        public Integer utilizedQuantity;    
        public Integer balanceQuantity; 
    }
    class purchasedDate {
        public String sdate;   
        public Integer timezone_type;   
        public String timezone; 
    }
    class startDate {
        public String sdate;   
        public Integer timezone_type;  
        public String timezone; 
    }
    class expiryDate {
        public String sdate;    
        public Integer timezone_type;   
        public String timezone; 
    }
    class payload {
        public String webuserId;   
        public String productCode; 
        public String statusCode;  
    }
    public class FulfilmentRequest{
        string method = 'gurulandPPSummaryGet', region;
        payloads payload;
    }
    public class payloads{
        string webuserId, productCode = 'PG_1237', statusCode = 'ACTIVE';
    }  
    
/*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : send JSON request to Guruland endpoint to get the Agent fulfilment data from Property Guru
Inputs      : Salesforce Accound Id
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static list<JsonTmp> getAgentFulfilment(id accId,Boolean isPrimeCreditCall){
        list<JsonTmp> listResult = new list<JsonTmp>();
        list<string> listIdx = new list<string>();
        map<string, list<JsonTmp>> mapResultTmp = new map<string, list<JsonTmp>>();
        list<date> listMapDate = new list<date>();
        map<date, list<string>> mapDateIdx = new map<date, list<string>>();
        Map<string,string> reqHeaders = new Map<string,string>();
        HTTPResponse res;
        string mapIdx;
        integer seq = 0;
        JsonTmp result;
        Account row = new Account();
        
        list<id> accountid = new list<id>();  
        String RootEndpoint, RootEndpointKey;

        if (runningInASandbox()) {
            RootEndpoint = label.PG_LABEL_Agent_Fulfilment_Endpoint_SB; 
            RootEndpointKey = label.PG_LABEL_Agent_Fulfilment_Key_SB;
        }
        else{
            RootEndpoint = label.PG_LABEL_Agent_Fulfilment_Endpoint;
            RootEndpointKey = label.PG_LABEL_Agent_Fulfilment_Key; 
        }

        reqHeaders.put('x-api-key', RootEndpointKey);
        reqHeaders.put('Cache-Control', 'no-cache');
        
        list <Account> rowHelper = new list<Account>([SELECT id, Agentnet_id__c,Country__c FROM Account WHERE id =: accId ]);
        string Country_Code = '';
        if(rowHelper.size()>0){
            row = rowHelper.get(0);
            CountryCode__C[] countrycode = CountryCode__c.getAll().Values();
            map<string,string> cc = new map<string,string>();
            for (integer i = 0 ; i<countrycode.size();i++){
                cc.put(countrycode[i].name,countrycode[i].code__c);
            }
            if(row.Country__c <> null){
                Country_Code = cc.get(string.valueOF(row.Country__c.toLowerCase()));
            }
            
            FulfilmentRequest  agentFulfilment = new  FulfilmentRequest();
            payloads pay = new payloads();
            if(isPrimeCreditCall){
                pay.productCode=Label.PRIME_CREDIT_PRODUCTCODE;
            }
            pay.webuserId = row.Agentnet_id__c;
            agentFulfilment.region = Country_Code;    
            agentFulfilment.payload = pay;
            
            string request = system.JSON.serialize(agentFulfilment);
            if(Test.isRunningTest()){
                String resString = '{"response":{"total":8,"records":[{"id":607091,"webuserId":153317,"invoiceId":"CMP-BrandRefreshAdCredits-153317","externalId":"CMP-BrandRefreshAdCredits-153317","billingSourceId":3,"purchasedDate":{"date":"2018-04-03 16:29:24.000000","timezone_type":3,"timezone":"Asia/Singapore"},"internalId":"CMP-BrandRefreshAdCredits-153317_1","startDate":{"date":"2018-04-03 16:29:24.000000","timezone_type":3,"timezone":"Asia/Singapore"},"expiryDate":{"date":"2019-04-02 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"name":"PG02R3246 Ad Credit (1 Credit)","productCode":"PG_1237","purchasedQuantity":20,"statusCode":"ACTIVE","utilizedQuantity":0,"balanceQuantity":20},{"id":681892,"webuserId":153317,"invoiceId":"0065D000003Zgd3QAC","externalId":"PGSO-18000317","billingSourceId":3,"purchasedDate":{"date":"2018-08-16 11:57:18.000000","timezone_type":3,"timezone":"Asia/Singapore"},"internalId":"PGSO-18000317_1","startDate":{"date":"2018-08-16 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"expiryDate":{"date":"2019-08-15 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"name":"PG02R3246 Ad Credit (1 Credit)","productCode":"PG_1237","purchasedQuantity":1,"statusCode":"ACTIVE","utilizedQuantity":0,"balanceQuantity":1},{"id":681897,"webuserId":153317,"invoiceId":"0065D000003Zh63QAC","externalId":"PGSO-18000323","billingSourceId":3,"purchasedDate":{"date":"2018-08-16 14:32:19.000000","timezone_type":3,"timezone":"Asia/Singapore"},"internalId":"PGSO-18000323_1","startDate":{"date":"2018-08-16 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"expiryDate":{"date":"2019-08-15 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"name":"PG02R3246 Ad Credit (1 Credit)","productCode":"PG_1237","purchasedQuantity":1,"statusCode":"ACTIVE","utilizedQuantity":0,"balanceQuantity":1},{"id":681903,"webuserId":153317,"invoiceId":"0065D000003Zhx7QAC","externalId":"PGSO-18000329","billingSourceId":3,"purchasedDate":{"date":"2018-08-16 16:32:43.000000","timezone_type":3,"timezone":"Asia/Singapore"},"internalId":"PGSO-18000329_1","startDate":{"date":"2018-08-16 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"expiryDate":{"date":"2019-08-15 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"name":"PG02R3246 Ad Credit (1 Credit)","productCode":"PG_1237","purchasedQuantity":1,"statusCode":"ACTIVE","utilizedQuantity":0,"balanceQuantity":1},{"id":681904,"webuserId":153317,"invoiceId":"0065D000003Zi3qQAC","externalId":"PGSO-18000332","billingSourceId":3,"purchasedDate":{"date":"2018-08-16 17:07:03.000000","timezone_type":3,"timezone":"Asia/Singapore"},"internalId":"PGSO-18000332_1","startDate":{"date":"2018-08-16 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"expiryDate":{"date":"2019-08-15 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"name":"PG02R3246 Ad Credit (1 Credit)","productCode":"PG_1237","purchasedQuantity":1,"statusCode":"ACTIVE","utilizedQuantity":0,"balanceQuantity":1},{"id":681921,"webuserId":153317,"invoiceId":"0065D000003ZiPoQAK","externalId":"PGSO-18000335","billingSourceId":3,"purchasedDate":{"date":"2018-08-16 18:43:17.000000","timezone_type":3,"timezone":"Asia/Singapore"},"internalId":"PGSO-18000335_1","startDate":{"date":"2018-08-16 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"expiryDate":{"date":"2019-08-15 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"name":"PG02R3246 Ad Credit (1 Credit)","productCode":"PG_1237","purchasedQuantity":10,"statusCode":"ACTIVE","utilizedQuantity":0,"balanceQuantity":10},{"id":486376,"webuserId":153317,"invoiceId":"1296579","externalId":"PGSO/SG34289","billingSourceId":3,"purchasedDate":{"date":"2017-07-10 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"internalId":"1296579_1_4","startDate":{"date":"2017-08-27 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"expiryDate":{"date":"2018-08-26 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"name":"PG02B3249 Bundle Ad Credit (1 Credit)","productCode":"PG_1237","purchasedQuantity":7200,"statusCode":"ACTIVE","utilizedQuantity":6236,"balanceQuantity":964},{"id":486383,"webuserId":153317,"invoiceId":"1296579","externalId":"PGSO/SG34289","billingSourceId":3,"purchasedDate":{"date":"2017-07-10 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"internalId":"1296579_15","startDate":{"date":"2017-08-27 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"expiryDate":{"date":"2018-08-26 00:00:00.000000","timezone_type":3,"timezone":"Asia/Singapore"},"name":"PG02R3246 Ad Credit (1 Credit)","productCode":"PG_1237","purchasedQuantity":400,"statusCode":"ACTIVE","utilizedQuantity":0,"balanceQuantity":400}]},"region":"sg","payload":{"webuserId":"153317","statusCode":"ACTIVE","productCode":"PG_1237"},"method":"gurulandPPSummaryGet"}';

                res = new HttpResponse();
                res.setStatusCode(200);
                res.setBody(resString);
            }else{
                res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,request,'POST',true,false,null,null);
            }
            if(res!=null){
            if(res.getStatusCode() == 200){
                string JSON = res.getBody().replaceALL('date','sdate');
                AgentFulfilmentFromJSON_cc af =  (AgentFulfilmentFromJSON_cc) System.JSON.deserialize(json, AgentFulfilmentFromJSON_cc.class);
                for(integer i=0 ;i<=af.response.records.size()-1;i++) {
                    if (!mapResultTmp.keySet().contains(af.response.records[i].externalId)) {
                        listResult = new list<JsonTmp>();
                        result = new JsonTmp();
                        result.Name = af.response.records[i].externalId;
                        result.IsGrouping = true;
                        listResult.add(result);
                        seq = 0;
                    } else {
                        listResult = mapResultTmp.get(af.response.records[i].externalId);
                        seq = listResult[listResult.size()-1].SequenceNumber;
                    }

                    if (!listMapDate.contains(stringToDate(af.response.records[i].startdate.sdate))) {
                        listMapDate.add(stringToDate(af.response.records[i].startdate.sdate));
                    }

                    if (mapDateIdx.keySet().contains(stringToDate(af.response.records[i].startdate.sdate))) {
                        listIdx = mapDateIdx.get(stringToDate(af.response.records[i].startdate.sdate));
                    } else {
                        listIdx = new list<string>();
                    }
                    if (!listIdx.contains(af.response.records[i].externalId)) {
                        listIdx.add(af.response.records[i].externalId);
                    }
                    mapDateIdx.put(stringToDate(af.response.records[i].startdate.sdate), listIdx);

                    result = new JsonTmp();
                    result.SequenceNumber = ++seq;
                    result.Status = af.response.records[i].statusCode;
                    result.Name = af.response.records[i].name;
                    result.StartDate = stringToDate(af.response.records[i].startdate.sdate);
                    result.EndDate = stringToDate(af.response.records[i].expiryDate.sdate);
                    result.PurchasedQuantity = af.response.records[i].purchasedQuantity;
                    result.BalanceQuantity = af.response.records[i].balanceQuantity;
                    listResult.add(result);
                    mapResultTmp.put(af.response.records[i].externalId, listResult);
                }
                listMapDate.sort();
                listResult = new list<JsonTmp>();
                for (integer idx=listMapDate.size()-1; idx>=0; idx--) {
                    for (string rowIdx: mapDateIdx.get(listMapDate.get(idx))) {
                        for (JsonTmp rowJson: mapResultTmp.get(rowIdx)) {
                            listResult.add(rowJson);
                        }
                    }
                }
            }
        }
        }
        return listResult;
    }
    
    /*------------------------------------------------------------
    Author      : Whisnu Satriya Wardhana
    Company     : Viseo Asia PTE LTD
    Description : To convert date in string format to date format.
    Inputs      : params<string> Date in string format
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    ------------------------------------------------------------*/
    @TestVisible
    private static date stringToDate(string params) {
        string[] test = params.split(' ');
        test = test[0].split('\\-');
        integer dateYear = integer.valueOf(test[0]);
        integer dateMonth = integer.valueOf(test[1]);
        integer dateDay = integer.valueOf(test[2]);
        date result = Date.newInstance(dateYear, dateMonth, dateDay);
        return result;
    }
    
    public class JsonTmp {
        @AuraEnabled
        public integer SequenceNumber {get; set;}
        @AuraEnabled
        public string Name {get; set;}
        @AuraEnabled
        public string Status {get; set;}
        @AuraEnabled
        public date StartDate {get; set;}
        @AuraEnabled
        public date EndDate {get; set;}
        @AuraEnabled
        public String PurchasedQuantity {get; set;}
        @AuraEnabled
        public decimal BalanceQuantity {get; set;}
        @AuraEnabled
        public boolean IsGrouping {get; set;}
        
        public JsonTmp() {
            IsGrouping = false;
        }
    }

    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}
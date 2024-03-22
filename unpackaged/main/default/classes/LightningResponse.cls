// @Description used for sending the response on the lightning component

public with sharing class LightningResponse {
    @AuraEnabled @testVisible
    public Boolean isSuccess{get; set;}
    @AuraEnabled @testVisible
    public String message{get; set;}
    @AuraEnabled @testVisible
    public String response{get; set;}
    @AuraEnabled @testVisible
    public Map<String,String> responseCredit{get; set;}
    
    public LightningResponse(Boolean isSuccess, String message, String response) {
        this.isSuccess = isSuccess;
        this.message = message;
        this.response = response;
    }
    public LightningResponse(Boolean isSuccess, String message, Map<String,String> responseCredit) {
        this.isSuccess = isSuccess;
        this.message = message;
        this.responseCredit = responseCredit;
    }
}
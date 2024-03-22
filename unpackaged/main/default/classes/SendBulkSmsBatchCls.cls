public with sharing class SendBulkSmsBatchCls implements Database.batchable<sObject>,Database.AllowsCallouts,Database.stateful{
    set<String> setOfAgentNumbers=new set<String>();
    map<String,Task> mapOfAgentNumberVsResponseTask=new map<String,Task>(); 
    String smsBody;
    String country;
    public SendBulkSmsBatchCls(set<String> agentMobileNumbers,String smsText,String agentCountry) {
        this.setOfAgentNumbers=agentMobileNumbers;
        this.smsBody=smsText;   
        this.country=agentCountry;
    }
    public Database.queryLocator start(Database.BatchableContext bc){
        String query='select id,Name,AgentNet_ID__c,PersonContactId,PersonMobilePhone,PersonEmail,Mobile_Country__c,Country__c from Account where PersonMobilePhone In:setOfAgentNumbers and Country__c =:country and RecordType.DeveloperName=\'Agent\' ';
        if(country == Label.MALAYSIA_REGION || country == Label.SINGAPORE_REGION){
            query+=' and CEA_Salesperson_Number__c != null ';
        }
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc,list<sObject> agentAccounts){
        list<Account> accounts=(list<Account>)agentAccounts;
        list<Task> listOfTaskToInsert=new list<Task>();
        String mobileCountryCode=AccountActionsCalloutHelper.mapOfCountryNameVsMobileCode.get(country.tolowerCase());
        if(accounts != null && String.isNotBlank(mobileCountryCode) != null && String.isNotBlank(smsBody)){
            for(Account agentAccount:accounts){
                //sms api callout already sent for this agent number
                if(mapOfAgentNumberVsResponseTask.containsKey(agentAccount.PersonMobilePhone)){
                    Task logRecord=mapOfAgentNumberVsResponseTask.get(agentAccount.PersonMobilePhone).clone(false,true,false,false);
                    logRecord.WhatId=agentAccount.Id;
                    logRecord.WhoId=agentAccount.PersonContactId;
                    listOfTaskToInsert.add(logRecord);
                    continue;
                }
                HttpResponse response=AccountActionsCtlr.sendSMSCallout(agentAccount,new map<String,String>{'smsBody'=>smsBody,'clientAppName'=>Label.SF_SEND_SMS_CLIENT_APP_NAME,'categoryName'=>Label.Send_Sales_SMS_Category,'recipientMobileNumber'=>mobileCountryCode+agentAccount.PersonMobilePhone},null);
                Task logTaskRecord=AccountActionsCtlr.logSMSResponse(response,agentAccount,smsBody);
                mapOfAgentNumberVsResponseTask.put(agentAccount.PersonMobilePhone,logTaskRecord.clone(false,true,false,false));
                listOfTaskToInsert.add(logTaskRecord);
            }
            if(!listOfTaskToInsert.isEmpty()){
                Database.saveResult[] saveResult=Database.insert(listOfTaskToInsert,false);
                for ( Integer i=0; i< listOfTaskToInsert.size();i++){ 
                    if(!saveResult[i].isSuccess()){
                        String errorMessage='Send SMS Error:Failed To Create Task Record Via SendBulkSmsBatchCls.\nDetails:'+listOfTaskToInsert[i].Description+'\nException Message:'+saveResult[i].getErrors()[0].getMessage();
                        AccountActionsCtlr.addErrorLog(null,listOfTaskToInsert[i].whatId,errorMessage);
                    }
                }
            }
            AccountActionsCtlr.createErrorLog();
        }
    }
    public void finish(Database.BatchableContext bc){

    }
}
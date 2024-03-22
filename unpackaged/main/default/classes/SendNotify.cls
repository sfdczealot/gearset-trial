/*
* Test Class: SendNotify_Test_v2
*/

/*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Send notify (Call Bitfrost)
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/

public class SendNotify {
    static string errResponsee = '' ;
    public class Agent { 
        String id;     String region= '';     String entity;        String origin = 'sfsc';  
    }
    
    public class OmcApproved { 
        String id;     String region= '';     String entity ;        String origin = 'sfsc';  
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : to prevent Salesforce called Bitfrost when updates happen from API
Inputs      : New Account Data and Old Account Data
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    
    public static void updateAccountHandler(list<account> acc, map<id,Account> OldMapAcc){
        boolean Go = false;  
        list<id> accID = new list<id>();
        Map<String,String> MapAccRT = new Map<String,String>();
        
        for (RecordType rt : [SELECT Id,Name FROM RecordType WHERE SObjectType='Account']){
            MapAccRT.put(rt.Name,rt.Id);
        } 
        
        // Custom Labels for getting account fields (Country Specific)
        List<String> listOfSGFields = System.label.PG_LABEL_BIFROST_SYNC_SG.split(',');
        List<String> listOfMYFields = System.label.PG_LABEL_BIFROST_SYNC_MY.split(',');
        List<String> listOfTHFields = System.label.PG_LABEL_BIFROST_SYNC_TH.split(',');
        Map<String,List<String>> countryVsFields  = new Map<String,List<String>> {
            'Thailand' => listOfTHFields , 'Singapore'=> listOfSGFields , 'Malaysia'=> listOfMYFields };
                
                for(Account ac : acc){
                    String name = '';
                    //string acName=ac.Name.toLowerCase();
                    if(ac.RecordTypeid== MapAccRT.get('Agent'))
                    {
                        name= ac.FirstName + ac.LastName;
                    }
                    else name = ac.Name;
                    if(!(name.containsIgnoreCase('Test SFDC')) ) {
                        if(ac.Updated_from_API__c == oldMapAcc.get(ac.id).Updated_from_API__c ){   
                            if(ac.RecordTypeid== MapAccRT.get('Agent') || ac.RecordTypeid== MapAccRT.get('Agency')){
                                //Calling Bifrost API only when these fields of Account are updated(For MY,SG,TH )
                                if(countryVsFields.containsKey(ac.Country__c))
                                {
                                    for(String fieldName : countryVsFields.get(ac.Country__c)) { 
                                        if (ac.get(fieldName) != oldMapAcc.get(ac.Id).get(fieldName)) {
                                            //Change in status field for SG and MY region 
                                            if(fieldName == 'Status__c' && (ac.Country__c == 'Singapore' || ac.Country__c== 'Malaysia')){
                                                //Only suspended status updated will be synced to bifrost
                                                if(ac.get(fieldName) == 'Suspended') Go = true;
                                            }
                                            //Change in field othan than status
                                            else	Go = true;
                                            if(Go){
                                                
                                                AccID.add(ac.id);
                                                break;    
                                            } 
                                        }
                                    }
                                }
                                // For Indonesia and other
                                else{
                                    Go = true;
                                    AccID.add(ac.id);
                                }
                            }
                        }
                    }
                }
        if(AccID.size()>0){
            if(Go == true){
                afterInsert(AccID);
            }
        }
        
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : to prevent Salesforce called Bitfrost when insert happen from API
Inputs      : List of Salesforce Account
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    public static void insertAccountHandler(list<account> acc){
        boolean Go = false;  
        list<id> accID = new list<id>();
        Map<String,String> MapAccRT = new Map<String,String>();    
        for (RecordType rt : [SELECT Id,Name FROM RecordType WHERE SObjectType='Account']){
            MapAccRT.put(rt.Name,rt.Id);
        } 
        for(Account ac : [select id,recordtype.id,Inserted_from_API__c,Name,LastName,Country__c from account where id in: Acc]){
            
            string acName=ac.Name.toLowerCase();
            if(!(ac.Name.containsIgnoreCase('Test SFDC')) ) {
                if(ac.RecordTypeid== MapAccRT.get('Agent') || ac.RecordTypeid== MapAccRT.get('Agency')){
                    Go = true;
                    AccID.add(ac.id);
                }
            }
            
        }
        if(AccID.size()>0){
            if(Go == true){
                afterInsert(AccID);
            }
        }
        
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Send Salesforce Account Id by calling Bitfrost API
Inputs      : List of Salesforce Account Id
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @future(callout = true)
    public static void afterInsert(list<id> Acc){
        Map<string,string> reqHeaders = new Map<string,string>();
        HttpResponse res ;
        
        map<string, string> mapCountryCode = EligibilityHandler.getMapCountryCode();
        errResponsee='';
        
        try{
            list<id> accountid = new list<id>();  
            String RootEndpoint, RootEndpoint_Key;
            
            if (runningInASandbox()) {
                RootEndpoint = label.PG_LABEL_SendNotifyEndpoint_SB; 
                RootEndpoint_Key = label.PG_LABEL_sendNotifyKey_SB;
            }
            else{
                RootEndpoint = label.PG_LABEL_SendNotifyEndpoint;
                RootEndpoint_Key = label.PG_LABEL_sendNotifyKey; 
            }
            
            reqHeaders.put('Content-Type', 'application/json');
            reqHeaders.put('x-api-key', RootEndpoint_Key);
            reqHeaders.put('Cache-Control', 'no-cache');
            
            
            List <Account> AccountToSend = [select id, Country__c, recordtype.name from account where id  =: Acc];
            agent agt = new agent();
            for(Account row : AccountToSend){
                agt.id = row.id;
                agt.region = mapCountryCode.get(row.Country__c.toLowerCase());
                if( row.recordtype.name == 'b2b - Account')
                    agt.entity = 'developer';
                else
                agt.entity = row.recordtype.name.toLowerCase();
            }   
            string request = system.JSON.serialize(agt);
            if(Test.isRunningTest()){
                res = new HttpResponse();
                res.setStatusCode(212);
                res.setBody('This is just a test');
            }else{
                res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,request,'POST',true,false,null,null);
            }
            system.debug('res.getBody() '+res.getBody());
            if(res.getStatusCode() <> 200){
                errResponsee = res.getBody();
            }
            
            updateAccount(acc);
            
        }catch(DmlException e){
            errResponsee =  e.getMessage();
            system.debug('errResponsee@@'+errResponsee);
            updateAccount(Acc);
        }
        
        
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : to update Last Outbound Sync and Outbound Sync Error in Salesforce Account 
Inputs      : List of Salesforce Account Id
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    public static void updateAccount(list<id> AccID){
        list<account> acc = [select id,last_outbound_sync__c,updated_from_API__c from account where id in: AccID] ; 
        for(Account row : acc){          
            row.Last_Outbound_Sync__c = system.now();
            row.Outbound_Sync_Error__c = errResponsee;
        }    
        update acc;
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : to update Last Outbound Sync and Outbound Sync Error in Salesforce Opportunity 
Inputs      : List of Salesforce Account Id
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    public static void updateOpportunity(list<id> OpptyID){
        list<Opportunity> opp = [select id,Last_Outbound_Sync__c,ByAuto__c,Outbound_Sync_Error__c from Opportunity where id in: OpptyID] ; 
        for(Opportunity row : Opp){ 
            row.Last_Outbound_Sync__c = system.now();
            row.Outbound_Sync_Error__c = errResponsee;
            row.ByAuto__c = true;
        }
        update Opp;
    }
    
    /**
*  This method is used for calling a future method (notifyBiforst) for logo syncing
*  @name agencyLogoSync
*  @param List<Account>
*  @return void
*  @reference AUTOMATION-9056
**/
    public static void agencyLogoSync(List<Account> agencyList){
        List<Id> mediaIds = new List<Id>();
        List<Media__c> mediaList = [SELECT Id,Account__c,IsActive__c,CurrencyIsoCode FROM Media__c WHERE Account__c IN:agencyList AND IsActive__c = true];
        for(Media__c objMedia : mediaList) {
            mediaIds.add(objMedia.Id);
        }
        
        if(!mediaIds.isEmpty()) {
            notifyBiforst(mediaIds);
        }
    }
    
    /**
*  This method is used for calling Bifrost to Sync the default logo of newly created Agency
*  @name notifyBiforst
*  @param List<Id>
*  @return void
*  @reference AUTOMATION-9056
**/
    
    @future(callout = true)
    public static void notifyBiforst(List<Id> mediaIdsList){
        
        List<media__c> mediaList = [SELECT Id,Account__c,IsActive__c,CurrencyIsoCode FROM Media__c WHERE Id =:mediaIdsList];
        Map<string, string> mapCountryCode = EligibilityHandler.getMapCountryCode();
        Map<string,string> reqHeaders = new Map<string,string>();
        String RootEndpoint, RootEndpoint_Key;
        HttpResponse res ;
        
        
        if (runningInASandbox()) {
            RootEndpoint = label.PG_LABEL_SendNotifyEndpoint_SB; 
            RootEndpoint_Key = label.PG_LABEL_sendNotifyKey_SB;
        }
        else{
            RootEndpoint = label.PG_LABEL_SendNotifyEndpoint;
            RootEndpoint_Key = label.PG_LABEL_sendNotifyKey; 
        }
        
        reqHeaders.put('Content-Type', 'application/json');
        reqHeaders.put('x-api-key', RootEndpoint_Key);
        reqHeaders.put('Content-Type', 'application/json');
        
        for(media__c objMedia : mediaList) {
            Account mediaAccount = [SELECT Id,Country__c FROM Account WHERE Id =:objMedia.Account__c];
            AgencyLogo objlogo= new AgencyLogo();
            objlogo.id = objMedia.Account__c;
            objlogo.region = mapCountryCode.get(mediaAccount.Country__c.toLowerCase());
            string requestt = system.JSON.serialize(objlogo);
            
            if(Test.isRunningTest()){
                res = new HttpResponse();
                res.setStatusCode(212);
                res.setBody('This is just a test');
            }else{
                res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,requestt,'POST',true,false,null,null);
            }
            
            if(!Test.isRunningTest() && res.getStatusCode() == 200){
                if(objMedia !=null){
                    system.debug('syncing successfull');
                }
            }
        }
        
    }
    
    public class AgencyLogo { 
        String id;     String region= '';     String entity = 'media' ;        String origin = 'sfsc';  
    }
    //  to check if execution is initiated from sandox or production 
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
}
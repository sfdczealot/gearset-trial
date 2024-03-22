/*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Endpoint to handle integration between Guruland (Agent) and Salesforce (Account)
Inputs      : JSON Request
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
@RestResource(urlMapping='/api/agent/*')
global class AgentAPI {
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Wrapper class to map guruland JSON request into class
Inputs      : JSON Request
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    global class Guruland { 
        
        String PersonTitle;             String FirstName;               String LastName;                Date PersonBirthdate;
        String Status;                  String Phone;                   String PersonEmail;             Date Subscription_End_Date;
        String Agency_id;               String Agency_name;             String Country;                 String Guruland_Created_Date;  
        String CEA_Salesperson_Number;  String Industry;                String Customer_Type;           Date Loyalty_Start_Date;
        String Fax;                     String PersonMobilePhone;       String PersonMailingStreet;     Date Subscription_Start_Date;
        String PersonMailingPostalCode; String PersonMailingCity;       String Mobile_Country;          String Netsuite_ID;
        String Account_Rule;            String Account_Rule_Code;       String Salutation;
        String CEA_license;             String AgentNet_ID;             String Id;                      String BillingState;
        String AgentKey;                String Website;                 String AgentNet_Error;          LocalLanguage_fields Local_Language_Data ; 
        String ActiveListingCount;		List<overlappingAgent> overlapAgent; 
   }
    
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Wrapper Class to map Salesforce Account fields to fields in Mapping Field documents
Inputs      : objObject <sObject>: Account
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    global class toGuruland {
        
        String PersonTitle;             String FirstName;               String LastName;                Date PersonBirthdate;
        String Status;                  String Phone;                   String PersonEmail;             Date Subscription_End_Date;
        String Agency_id;               String Agency_name;             String Country;                 String Guruland_Created_Date;  
        String CEA_Salesperson_Number;  String Industry;                String Customer_Type;           Date Loyalty_Start_Date;
        String Fax;                     String PersonMobilePhone;       String PersonMailingStreet;     Date Subscription_Start_Date;
        String PersonMailingPostalCode; String PersonMailingCity;       String Mobile_Country;          String Netsuite_ID;
        String Account_Rule;            String Account_Rule_Code;       String Salutation;
        String CEA_license;             String AgentNet_ID;             String Id;                      String BillingState;
        String AgentKey;                String Website;                 LocalLanguage_fields Local_Language_Data;
        String REA_Id;					List<overlappingAgent> overlapAgent; 
        
        
        toGuruland( String PersonTitle, String FirstName, String LastName, Date PersonBirthdate, String Status,String Phone, String PersonEmail,Date Subscription_End_Date,String Agency_id,
                   String Agency_name,String Country,Datetime Guruland_Created_Date,String CEA_salesperson_number,String Industry,String Customer_type, Date Loyalty_Start_Date,String Fax,
                   String Postcode,String City, String State, String Mobile_Country,String Account_Rule,String Account_Rule_Code,String CEA_license,
                   String User_id,String Id,date Subscription_Start_Date,String PersonMailingStreet,String Mobile, LocalLanguage_fields Local_Language_Data, String REA_Id,List<overlappingAgent> overlapAgent
                   
                  ){
                      
                      this.PersonTitle = PersonTitle;             this.FirstName = FirstName;         this.LastName = LastName;                this.Mobile_Country = Mobile_Country; 
                      this.Status = Status;                       this.Phone = Phone;                 this.PersonEmail = PersonEmail;          
                      this.Agency_id = Agency_id;                 this.Agency_name = Agency_name;     this.Country = Country;                  this.Loyalty_Start_Date= Loyalty_Start_Date;
                      this.Industry = Industry;                   this.Customer_Type = Customer_type; this.PersonBirthdate = PersonBirthdate;  this.Subscription_End_Date= Subscription_End_Date;
                      this.CEA_license = CEA_license;             this.AgentNet_ID = User_id;         this.Subscription_Start_Date= Subscription_Start_Date;
                      this.id = id;                               this.PersonMobilePhone = Mobile;    this.Fax = Fax;                          this.PersonMailingStreet = PersonMailingStreet;
                      this.Account_Rule= Account_Rule;            this.PersonMailingCity = City;      this.PersonMailingPostalCode = Postcode; this.Account_Rule_Code = account_rule_code;    
                      this.CEA_Salesperson_Number = CEA_salesperson_number;
                      this.Guruland_Created_Date = String.valueOF(Guruland_Created_Date);
                      this.BillingState = State;
                      this.Local_Language_Data = Local_Language_Data;
                      this.overlapAgent = overlapAgent;
                      
                      if (String.isNotBlank(REA_Id)) {
                          this.REA_Id = REA_Id;
                      }
                  }
    }
    /*-----------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Insert into Salesforce Account with Wrapper Class values.
Inputs      : Wrapper Class Guruland
Return: Account
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    global static Account MappingField(Guruland guru,boolean updateLSD){
        Map<String,String> MapAccRT = new Map<String,String>();
        Date previousEndDate = null;
        String previousRule = null;
        Id referenceAgencyId = null;
        String SalesforceID = null;
        
        for (RecordType rt : [SELECT Id,Name FROM RecordType WHERE SObjectType='Account']){
            MapAccRT.put(rt.Name,rt.Id);
        }
        list<Account> existingAccWithId = new List<Account>([select id  from account where Id =: guru.Id LIMIT 1 ]);
        list<Account> existingAccWithKey = new List<Account>([select id from account where AgentKey__c =:guru.AgentKey and AgentKey__c not in: null LIMIT 1 ]);
        list<Account> existingAccWithEmail = new List<Account>([select id from account where PersonEmail =:guru.PersonEmail and Country__c =:guru.Country and recordtypeid =: MapAccRT.get('Agent') LIMIT 1 ]);
        
        
        Date Loyalty_Start_Date;
        
        if (existingAccWithKey.size()>0){
            SalesforceID = existingAccWithKey[0].Id;
            
            
        } else if (existingAccWithId.size()>0){
            SalesforceID = existingAccWithId[0].Id;
            
        } else if (existingAccWithEmail.size()>0){
            SalesforceID = existingAccWithEmail[0].Id;
            
        }
        
        system.debug('Agent account exists: ' + SalesforceID);
        
        List<Account> existingAgency = new List<Account>([SELECT id FROM Account WHERE recordtypeid =: MapAccRT.get('Agency') and Agency_Id__c =: guru.Agency_Id and Country__c =: guru.Country]);
        
        if(existingAgency.size() > 0 ){
            referenceAgencyId = existingAgency[0].id;
        }
        
        datetime GlCreatedDate ;
        if(guru.Guruland_Created_Date == null){
            GlCreatedDate = null;
        }else{
            GlCreatedDate =  Datetime.valueOf(guru.Guruland_Created_Date);
        }
        
        list<Account> dummyAccount= new list<Account>([Select Subscription_End_Date__c ,Loyalty_Start_Date__c,Updated_from_API__c,NetSuite_Id__c,Account_Rule_Code__c,Previous_Account_Rule__c, Previous_Acct_End_Date__c,Agentnet_ID__c from Account where id =: guru.Id or AgentKey__c =:guru.AgentKey Limit 1]);
        Account row = new Account();
        if(dummyAccount.size()>0){
            row = dummyAccount[0];
            if(row.Subscription_End_Date__c <> null && row.Subscription_End_Date__c <> guru.Subscription_End_Date){
                System.debug('Insert Previous Acc End Date');
                previousEndDate = row.Subscription_End_Date__c ;               
            }else{
                previousEndDate = row.Previous_Acct_End_Date__c;     
            }
            if(row.Account_Rule_Code__c<> '' && row.Account_Rule_Code__c <> guru.Account_Rule_Code){
                System.debug('Insert Previous Acc Rule');
                previousRule = row.Account_Rule_Code__c;
            }else{
                previousRule = row.Previous_Account_Rule__c;
            }
            if(updateLSD){
                Loyalty_Start_Date = guru.Loyalty_Start_Date;
            }else{
                Loyalty_Start_Date = row.Loyalty_Start_Date__c;  
            }
            
            
        }else{
           Loyalty_Start_Date = guru.Loyalty_Start_Date;  
        }
        String apiAgentName = '';
        if (guru.Agency_name!=null) apiAgentName = guru.Agency_name.unescapeHTML4();
        Account Acc = new Account(PersonTitle = guru.PersonTitle,              Firstname = guru.FirstName,                     RecordtypeId = MapAccRT.get('Agent'),                            
                                  PersonBirthdate = guru.PersonBirthdate,      Status__c = guru.Status,                        BillingStreet = guru.PersonMailingStreet,
                                  PersonEmail = guru.PersonEmail,              Guruland_Created_Date__c = GlCreatedDate,       Mobile_Country__c = guru.Mobile_Country,
                                  Country__c = guru.Country,                   Subscription_End_Date__c = guru.Subscription_End_Date,
                                  Fax = guru.Fax,                              Industry = guru.Industry,                       CEA_Salesperson_Number__c = guru.CEA_Salesperson_Number,
                                  Customer_Type__c = guru.Customer_Type,       AgentNet_ID__c = guru.AgentNet_ID,              Loyalty_Start_Date__c = Loyalty_Start_Date,
                                  Phone = guru.phone,                          Reference_Agency_Id__c = guru.Agency_id,        BillingPostalCode = guru.PersonMailingPostalCode,
                                  BillingCity = guru.PersonMailingCity,        Lastname = guru.LastName,                       Subscription_Start_Date__c = guru.Subscription_Start_Date,
                                  CEA_license__c = guru.CEA_license,           Account_Rule__c = guru.Account_Rule,            Agency_name__c = apiAgentName,
                                  PersonMobilePhone = guru.PersonMobilePhone,  Account_Rule_Code__c = guru.Account_Rule_Code,  
                                  AgentKey__c = guru.AgentKey,                 Website = guru.Website,                         Salutation = guru.Salutation,
                                  Previous_Acct_End_Date__c = previousEndDate, Previous_Account_Rule__c = previousRule,        Updated_from_API__c = !row.Updated_from_API__c,
                                  Inserted_from_API__c = true,                 Id = SalesforceID,
                                  AgentNet_Error__c = guru.AgentNet_Error,     BillingCountry = guru.Country,   
                                  BillingState = guru.BillingState
                                 );
        
        if(referenceAgencyId!=null){
            system.debug('referenceAgencyId is not null');
            acc.Agency__c = referenceAgencyId;
        } else{
            system.debug('referenceAgencyId is null');
            acc.AgentNet_Error__c= acc.AgentNet_Error__c!=null ? acc.AgentNet_Error__c +' Not able to find Agency '+guru.Agency_id +' in SF' : 'Not able to find Agency '+guru.Agency_id +' in SF';
            //acc.AgentNet_Error__c +=' Not able to find Agency '+guru.Agency_id +' in SF';
        }
        if(guru.Local_Language_Data != null){
            acc.LocalLanguage_First_Name__c = guru.Local_Language_Data.LocalLanguage_First_Name;
            acc.LocalLanguage_Last_Name__c = guru.Local_Language_Data.LocalLanguage_Last_Name;
            acc.LocalLanguage_Title__c = guru.Local_Language_Data.LocalLanguage_Title;
            acc.LocalLanguage_Billing_Street__c = guru.Local_Language_Data.LocalLanguage_Billing_Street;
            
        }
        if(guru.ActiveListingCount != null){
            acc.of_active_listings__c = Decimal.valueof(guru.ActiveListingCount);
        }
        
        if(string.isNotBlank(guru.Netsuite_ID)){
            acc.NetSuite_Id__c	 = guru.Netsuite_ID;
        }
        return  Acc;
    }    
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Post Method to Insert/Update Salesforce Account with data from Guruland. Guruland must include <AgentNet_Id>Salesforce External Id or <Id>Salesforce Id
If External Id / Salesforce Id is found then this Post method will update the Agent record, else will insert new Agent record.
Inputs      : JSON Request.
Outputs     : Upsert Salesforce Account record.
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @HttpPost
    global static void upsertAgent() {
        string result = '';
        Boolean IsGood = true;
        Http http = new Http();
        RestRequest request = Restcontext.request;
        system.debug(request.requestBody.tostring());           
        RestResponse res = RestContext.response;
        Savepoint sp = Database.setSavepoint();    
        Try{  
            Guruland guru = (Guruland)JSON.deserialize(RestContext.request.requestBody.tostring(),Guruland.class);
            Map<String,object> guruData = (Map<String,object>)JSON.deserializeUntyped(RestContext.request.requestBody.tostring());
            boolean updateLSD = true;
            
            if(!guruData.containsKey('Loyalty_Start_Date')){
                updateLSD = false;  
            }
            
            List<String> Key = new List<String>();
            List<String> exKey = new List<String>();
            if(guru.AgentNet_Id<>null){
                exKey.add(guru.AgentNet_Id);
            }    
            Key.add(guru.Id); 
            
            List<Account> AccountToUpsert = new list<Account>();            
            Account Acc = Mappingfield(guru,updateLSD);
            if(guru.lastname == null || guru.firstname == null || guru.Country == null || guru.PersonMobilePhone == null || guru.PersonEmail==null || (guru.Agency_id == null && guru.Agency_Name == null) || (guru.Country == 'Singapore' && (guru.Salutation == null || guru.PersonBirthdate == null))){
                isGood = false;
            }else{
                AccounttoUpsert.add(Acc);
            }
            if(isGood==false){
                res.statusCode = 400;
                result = 'One or many of these required field are missing : FirstName, LastName, PersonTitle, PersonBirthdate, Phone, PersonEmail, Country, and one of (Agency_id or Agency_Name)';
                res.responseBody = blob.valueOf(result);
            }else{
                upsert AccountToUpsert;
                res.statusCode = 200;
                result =  system.JSON.serialize(guru);
                res.responseBody = blob.valueOf(result);                       
            }
        }catch(DmlException e){
            Database.rollback(sp);
            res.statusCode = 400;
            system.debug('ERROR' + e.getMessage() + e.getLineNumber());
            result =  e.getMessage();
            res.responseBody = blob.valueOf(result);
        }
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : GET method. To send requested Salesforce Agent record by Guruland. Guruland must include <Id>Salesforce Id to get the Agent data. 
Inputs      : JSON <Id>Salesforce Id.
Return      : Salesforce Agent record.
fld <string>: Specified field name 
------------------------------------------------------------*/
    @HttpGet
    global static void getAccount() {
        String result;
        String agencyID = null;
        RestResponse res = RestContext.response;
        Map<String,String> MapAccRT = new Map<String,String>();
        for (RecordType rt : [SELECT Id,Name FROM RecordType WHERE SObjectType='Account']){
            MapAccRT.put(rt.Name,rt.Id);
        }
        String AccID = RestContext.request.params.get('id');
        System.debug('AccID '+AccID);
        System.debug('MapAccRT. '+MapAccRT.get('Agent'));
        List <Account> AccountToReturn = new list<account>([SELECT Id,Name,PersonTitle,FirstName,LastName, PersonBirthdate,PersonMobilePhone,Status__c,BillingPostalCode,PersonMailingPostalCode ,
                                                            BillingStreet,PersonMailingStreet,BillingCity,PersonMailingCity,BillingState,PersonEmail,Guruland_Created_Date__c,et4ae5__Mobile_Country_Code__pc,Agency_Id__c,
                                                            Agency_Name__c,Country__c,  Subscription_Start_Date__c,Subscription_End_Date__c,Fax,Industry,CEA_Salesperson_Number__c,
                                                            Customer_Type__c,AgentNet_ID__c,Loyalty_Start_Date__c,Phone,Account_Rule_Code__c,Account_Rule__c, CEA_License__c,Reference_Agency_Id__c,LocalLanguage_First_Name__c,LocalLanguage_Title__c,
                                                            LocalLanguage_Last_Name__c,LocalLanguage_Billing_Street__c,Brickz_Agent__c,Overlap_Agent__c,External_Field__c ,
                                                            Mobile_Country__C,AgentKey__c,Salutation,Website,Agency__c,NetSuite_Id__c,iPP_REA_ID__c	 FROM Account WHERE id =: AccID and recordtypeid =: MapAccRT.get('Agent')]);
        
        if(AccountToReturn.size()>0){
            if(AccountToReturn[0].Agency__c <> null ){
                List<Account> existingAgency = new List<Account>([SELECT id,Agency_Id__c FROM Account WHERE recordtypeid =: MapAccRT.get('Agency') and id=:AccountToReturn[0].Agency__c]);
                AgencyID=existingAgency[0].Agency_Id__c;
            }   
            
            for(Account a : AccountToReturn){
                LocalLanguage_fields fields = null;

                if(a.country__c=='Thailand')
                {
                    fields = new LocalLanguage_fields();
                    fields.LocalLanguage_First_Name = a.LocalLanguage_First_Name__c;
                    fields.LocalLanguage_Title = a.LocalLanguage_Title__c;   
                    fields.LocalLanguage_Last_Name = a.LocalLanguage_Last_Name__c; 
                    fields.LocalLanguage_Billing_Street = a.LocalLanguage_Billing_Street__c;  
                }
                List<overlappingAgent> overlapAgentList;  
                if(a.country__c == 'Malaysia'){
                                  overlappingAgent overlapAgentDetails =null;
                    if(a.External_field__c != null){
                        overlapAgentList =  new list<overlappingAgent>();
                        
                        if(a.Brickz_Agent__c == true && a.iPP_REA_ID__c!=null){
                            overlapAgentDetails = new overlappingAgent();
                            overlapAgentDetails.site = 'brickz' ;
                            overlapAgentDetails.id= a.iPP_REA_ID__c ;  
                            overlapAgentList.add(overlapAgentDetails);
                        }
                        if(a.Overlap_Agent__c == true && a.iPP_REA_ID__c!=null){
                            overlapAgentDetails = new overlappingAgent();
                            overlapAgentDetails.site = 'ipp';
                            overlapAgentDetails.id= a.iPP_REA_ID__c ;  
                            overlapAgentList.add(overlapAgentDetails);
                        }
                  
                    
             
                    }
                }
               
                  toGuruland toGuru= new toGuruland(a.PersonTitle,a.FirstName,a.LastName,a.PersonBirthdate,a.Status__c,a.Phone,a.PersonEmail,a.Subscription_End_Date__c,AgencyID,
                                                  a.Agency_Name__c,a.Country__c,a.Guruland_Created_Date__c, a.CEA_Salesperson_Number__c,a.Industry, a.Customer_Type__c,a.Loyalty_Start_Date__c,a.Fax,
                                                  a.BillingPostalCode,a.BillingCity,a.BillingState,a.Mobile_Country__c,a.Account_Rule__c,
                                                  a.Account_Rule_Code__c,a.CEA_License__c,a.AgentNet_ID__c,string.valueOF(a.id), a.Subscription_Start_Date__c,a.BillingStreet,a.PersonMobilePhone,fields,a.iPP_REA_ID__c,overlapAgentList);
                toGuru.Website = a.Website;
                toGuru.AgentKey = a.AgentKey__c;
                toGuru.Salutation = a.Salutation;
                toGuru.Netsuite_ID = a.NetSuite_Id__c;
                
                res.statusCode = 200;
                result =   system.JSON.serialize(toGuru);
                system.debug(result);
                res.responseBody = blob.valueOf(result);
                
            }    
        }else{
            res.statusCode = 400;
            result =  'Agent requested by Guruland does not exist in Salesforce.';
            res.responseBody = blob.valueOf(result);
        }  
        
    }
    //Wrapper to store Local Language fields
    Public class LocalLanguage_fields{
        String LocalLanguage_First_Name;
        String LocalLanguage_Title;   
        String LocalLanguage_Last_Name; 
        String LocalLanguage_Billing_Street;  
        
    }
    public class overlappingAgent{
        String site;
        String id;
    }
    
}
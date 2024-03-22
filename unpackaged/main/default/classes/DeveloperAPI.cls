@RestResource(urlMapping='/api/developer/*')
global class DeveloperAPI {
    public class response {
        public Agent agent;
        public Person person;
        public ContactResponse contact;
        public UserDetails user;
    }
    public class Agent {
        public Object agencyId;
        public Object licenseId;
    }    
    public class UserDetails {
        public String accountRuleCode;
        public String userid;
        public Object subscriptionEnd;
        public String password;
    }
    public class Person {
        public String title;
        public String firstname;
        public Object birthdate;
        public String lastname;
    }   
    public class ContactResponse {
        public String country;
        public Object city;
        public String mobileCountry;
        public String mobile;
        public Object postcode;
        public String telephone;
        public String email;
        public Object extension;
        public Object region;
    }   
    public class updateResponse{
       /* public String licenseId;
        public String website;
        public String jobTitle; */
        public cls_webUser webUser;
       /* public cls_agency agency;
        public cls_audit audit;*/
        public String developerId;
    }   
   class cls_webUser {
        public cls_person person;
    }
    class cls_person {
     /*  public cls_contactInformation contactInformation;
        public String title;    
        public String lastname;   */ 
        public String firstname; 
    }
   /* class cls_contactInformation {
        public String street1;  
        public String street2;  
        public String region;   
        public cls_mobile mobile;
        public String email;
        public String countryCode;  
        public cls_telephone telephone;
        public String fax;
    }
    class cls_mobile {
        public String subscriberNumber; 
        public String countryCode;  
    }
    class cls_telephone {
        public String subscriberNumber; 
    }*/
    class cls_agency {
        public String id;
    }
    class cls_audit {
        public String userId;
        public String ipAddress;
    }
    class cls_upsertAccount{
        String firstName;
        String lastName;
        String countryCode;
        String mobile;
        String phone;
        String website;
        String email;
        String accID;
        String developerKey;
        String Country;
     }
    
    @HttpGet
    global static void getDeveloperAccount() {
        String result;
        RestResponse res = RestContext.response;
        String AccID = RestContext.request.params.get('id');    
        String devRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId(); 
        
        List <Account> AccountToReturn = new list<account>([SELECT Id, Developer_ID__c, DisplayName__c, Name, Country__c, Mobile_country__c, 
                                                            Phone, PersonMobilePhone, Status__c, website, fax
                                                            FROM Account WHERE id =: AccID and recordtypeid =: devRecType]);
        if(!AccountToReturn.isEmpty()){
        List<Opportunity> oppList = [SELECT Id, b2b_Billing_contact__r.MobilePhone, b2b_Billing_contact__r.Email, (Select id, Contact.MobilePhone,
                                                                          contact.Email from OpportunityContactRoles limit 1) from opportunity where accountID =: AccID and stageName = 'CLosed Won' 
                                                               
                                                               order by closeDate desc limit 1];
                   /*     if(oppList.isEmpty()){
                 res.statusCode = 400;
            result =  'Developer has no valid PPL Closed won oppty';
            res.responseBody = blob.valueOf(result);
                return;
            }*/
            
            System.debug('@@@Acc:::'+AccountToReturn.size());
            System.debug('###Opp:::'+oppList.size());
          //  System.debug('%%%'+oppList[0].OpportunityContactRoles[0]);
            
            res.statusCode = 200;
            if(AccountToReturn[0].Developer_ID__c == null)
                result = createResponse(AccountToReturn[0], oppList[0]);
            else
                result = updateResponse(AccountToReturn[0]);
            res.responseBody = blob.valueOf(result);
        }else{
            res.statusCode = 400;
            result =  'Developer requested by Guruland does not exist in Salesforce.';
            res.responseBody = blob.valueOf(result);
        }  
    }
    
    public static String createResponse(Account acc,Opportunity opp){
        Response oResponse = new Response();
        String name;
        // String[] name;
        if(acc.DisplayName__c != null){
        name = acc.DisplayName__c;//.Split(' ');
        } else
            name = acc.name;//.Split(' ');
        ContactResponse contact = new ContactResponse();
        Agent age = new agent();
        Person pers = new Person();
        UserDetails userDet = new UserDetails();
        pers.Title = 'Mr';
       /* pers.FirstName = name[0];
        if(name.size() > 1){
          
            name.remove(0);
            pers.lastname = String.join(name, ' ');
        }*/
        pers.FirstName = name;
          pers.lastname = '-';
        switch on acc.Country__c {
            when 'Malaysia' {       
                contact.country = 'MY';
                 contact.mobileCountry = '60';
            }   
            when 'Thailand' {       
                contact.country = 'TH';
                 contact.mobileCountry = '66';
            }
            when 'Singapore' {      
                contact.country = 'SG';
            }
            when 'Indonesia' {      
                contact.country = 'ID';
                 contact.mobileCountry = '62';
            }
            when else {       // default block, optional
                // code block 4
            }
        }
        //  contact.country = acc.Country__c;
        contact.mobile = opp.b2b_Billing_contact__r.MobilePhone;
       
        contact.email = opp.b2b_Billing_contact__r.Email; 
        userDet.accountRuleCode = 'DEVELOPER';
        userDet.userid = opp.b2b_Billing_contact__r.Email;
        userDet.password = 'welcome@pg';
        oResponse.contact = contact;
        oResponse.person = pers;
        oResponse.user = userDet;
        oResponse.agent = age;
        return System.JSON.serialize(oResponse);
    }
    
    public static String updateResponse(Account acc){
        system.debug('updateresponse');
        updateResponse oResponse = new updateResponse();
        cls_webUser webUser = new cls_webUser();
        cls_person person = new cls_person();
    /*    cls_contactInformation contactInfo = new cls_contactInformation();
        cls_mobile mobile = new cls_mobile();
        cls_telephone telephone = new cls_telephone();
        oresponse.website = acc.Website;*/
      /*   mobile.subscriberNumber = acc.Mobile__c;
        mobile.countryCode = acc.Mobile_Country__c;
       contactInfo.mobile = mobile;
        contactInfo.email = acc.Email__c;*/
       /* if(acc.phone !=null ){
        if(acc.Mobile_Country__c !=null)
            telephone.subscriberNumber = acc.Mobile_Country__c +''+ acc.phone;
        else
            telephone.subscriberNumber = acc.phone;
        }
        contactInfo.telephone = telephone;
        contactInfo.fax = acc.fax;*/
      //  person.title = 'Mr';
       // person.contactInformation = contactInfo;
        String name; 
        // String[] name;
        if(acc.DisplayName__c != null){
        name = acc.DisplayName__c;//.Split(' ');
        } else
            name = acc.name;//.Split(' ');
        
     
        person.FirstName = name;
      //    person.lastname = '-';*/
        webUser.person = person;
        oResponse.developerId = acc.Developer_id__c; 
        oResponse.webUser = webUser;
       
        return System.JSON.serialize(oResponse);
    }
    
    @HttpPost
    global static void upsertDeveloperAccount() {
        Http http = new Http();
        RestRequest request = Restcontext.request;
        system.debug(request.requestBody.tostring());           
        RestResponse res = RestContext.response;
        Savepoint sp = Database.setSavepoint(); 
        String sfID;
        String result;
        list<Account> existingAccWithId = new list<Account> ();
        list<Account> existingAccWithKey = new list<Account> ();
        //list<Account> existingAccWithEmail = new list<Account> ();
        Try{  
            String devRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
            cls_upsertAccount upsertAcc = (cls_upsertAccount)JSON.deserialize(RestContext.request.requestBody.tostring(),cls_upsertAccount.class);
            if( upsertAcc.AccID != null)
                existingAccWithId  = [select id  from account where Id =: upsertAcc.AccID and recordtypeid =: devRecordTypeID LIMIT 1 ];
            if( upsertAcc.developerKey != null)
                existingAccWithKey = [select id from account where Developer_Key__c =:upsertAcc.developerKey and recordtypeid =: devRecordTypeID LIMIT 1 ];
            /*if(upsertAcc.email != null)
                existingAccWithEmail = [select id from account where Email__c =:upsertAcc.email and Country__c =:upsertAcc.country and recordtypeid =: devRecordTypeID LIMIT 1 ];
            */
            if (existingAccWithKey.size()>0){
                sfID = existingAccWithKey[0].Id;
            } else if (existingAccWithId.size()>0){
                sfID = existingAccWithId[0].Id;
            }
            
            Account acc = new Account();
            if(sfID != null){
                acc.Id = sfID;
            }
            else{
                acc.RecordTypeId = devRecordTypeID;
            }
            if(upsertAcc.firstname != null )
                acc.DisplayName__c = upsertAcc.firstName;
            if(upsertAcc.lastName != null)
                acc.DisplayName__c +=  ' '+upsertAcc.LastName;
           /* if(upsertAcc.countryCode != null)
                acc.Mobile_Country__c = upsertAcc.countryCode;
            if(upsertAcc.mobile != null)
                acc.Mobile__c = upsertAcc.mobile;
            if(upsertAcc.phone != null)
                acc.Phone = upsertAcc.phone;
            if(upsertAcc.website != null)
                acc.Website = upsertAcc.website;
            if(upsertAcc.country != null)
                acc.Country__c = upsertAcc.country;
            if(upsertAcc.email != null)
                acc.Email__c = upsertAcc.email;*/
            system.debug(acc);
            upsert acc;
             system.debug('Developer account updated successfully');
            res.statusCode = 200;
            result =  'Developer account updated successfully';
            res.responseBody = blob.valueOf(result);
        }
        Catch(Exception e){
            system.debug(e.getLineNumber() + e.getMessage());
            res.statusCode = 400;
            result =  'ERROR : at '+e.getLineNumber() +' Message ' +e.getMessage();
            res.responseBody = blob.valueOf(result);
        }
        
    }
}
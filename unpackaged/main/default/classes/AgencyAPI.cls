/*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Endpoint for Agency Integration. Include Get method to send Salesforce Agency Data, and Post method to upsert Agency.
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/

@RestResource(urlMapping='/api/agency/*')
global class AgencyAPI {
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Wrapper class to map salesforce field into Guruland agency field in integration document.
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    Global class cls_Logo {
        public String FileName;	//filename.ext
        public String Media_Id;	//latest active media__c.id
    }
    global class Agency { 
        String Id;          					String Agency_Name;    String Country;  
        String CEA_Salesperson_Number;          String CEA_License;    String Agency_Id;
        cls_Logo Logo;							String Agency_Name_Local_Language;
        Agency( String salesforce_id,String name,String cea_license_no,
               String license_id, String Country, String Agency_Id){
                   this.Id = salesforce_id; 						this.Agency_Name = name;
                   this.CEA_Salesperson_Number = cea_license_no;    this.CEA_License = license_id;
                   this.Country = Country;							this.Agency_Id = Agency_ID;
               }
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Wrapper class to map guruland JSON request into salesforce class.
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    global class GurulandPost { 
        String Id; String Agency_Id;   String AgentNet_Error;
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Post method, to update Agency records <Agency_Id__c> with Agency_Id from Guruland. Guruland must include <id>salesforce Id to update Agency records.
Inputs      : JSON < String Id; String Agency_Id >

History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @HttpPost
    global static void updateAgency() {
        String result = '';
        Boolean isGood = true;
        Http http = new Http();
        RestRequest request = Restcontext.request;
        system.debug('Guruland Request : ' + request.requestBody.tostring());           
        RestResponse res = RestContext.response;
        Savepoint sp = Database.setSavepoint();   
        try{
            GurulandPost GPost = (GurulandPost)System.JSON.deserialize(RestContext.request.requestBody.tostring(),GurulandPost.class);
            List<account> AgencyToReturn = new list<account>([select Id,AgentNet_Error__c,name,Agency_id__c,Country__c,CEA_Salesperson_Number__c,CEA_License__c from account where id = : GPost.Id]); 
            Account AccountToUpdate = new Account();
            if(AgencyToReturn.size()==0){
                res.statusCode = 400;
                res.responseBody = blob.valueOf('Agency requested by guruland does not exist in Salesforce');
            }else{
                AccountToUpdate = AgencyToReturn.get(0);
                
                if(GPost.Agency_Id != null){
                    system.debug('Agency_Id : ' + GPost.Agency_Id);
                    AccountToUpdate.Agency_id__c = GPost.Agency_Id;
                }
                if(GPost.AgentNet_Error != null){
                    AccountToUpdate.AgentNet_Error__c = GPost.AgentNet_Error;
                }
                
                Update AccountToUpdate;
                Agency row = new Agency(AgencyToReturn[0].id, AgencyToReturn[0].name, AgencyToReturn[0].CEA_Salesperson_Number__c, AgencyToReturn[0].CEA_License__c,AgencyToReturn[0].Country__c,AgencyToReturn[0].Agency_id__c);           
                res.statusCode = 200;
                result =  system.JSON.serialize(row);
                res.responseBody = blob.valueOf(result);
            }
        }catch(DmlException e){
            Database.rollback(sp);
            res.statusCode = 400;
            system.debug('ERROR' + e.getMessage());
            result =  e.getMessage();
            res.responseBody = blob.valueOf(result);
        }
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Get method, to send requested Salesforce Agency record by Guruland. Guruland must include <id> Salesforce Id to get the Agency data.
Inputs      : JSON < String Id >

History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/    
    @HttpGet
    global static void getAccount() {
        String Id = RestContext.request.params.get('id');
        String result;
        RestResponse res = RestContext.response;
        
        List<Account> AgencyToReturn = new list<Account>([SELECT Id,name,Agency_id__c,Country__c,CEA_Salesperson_Number__c,CEA_License__c,Local_Language_Account_Name__c FROM Account WHERE id =: Id]);
        if(AgencyToReturn.size() > 0){
            Agency row = new Agency(AgencyToReturn[0].id, AgencyToReturn[0].name, AgencyToReturn[0].CEA_Salesperson_Number__c, AgencyToReturn[0].CEA_License__c,AgencyToReturn[0].Country__c,AgencyToReturn[0].Agency_id__c);
            row.Agency_Name_Local_Language=AgencyToReturn[0].Local_Language_Account_Name__c;
            List<Media__c> lstmedia=[SELECT Id,Account__r.Agency_Id__c,createdDate FROM Media__c where Account__c=:Id and isActive__c=true  order By createdDate Desc limit:1];
            If(lstmedia.size()>0){
                ContentDocumentLink ObjContentDoc = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId=:lstmedia[0].Id];
                Contentversion attach=[SELECT Id,Title,ContentDocumentId,fileType,FileExtension FROM ContentVersion where ContentDocumentId=:ObjContentDoc.ContentDocumentId];
                cls_Logo objlogo=new cls_Logo(); 
                objlogo.FileName=attach.Title+'.'+attach.FileExtension;
                objlogo.Media_Id =lstmedia[0].Id;
                row.Logo =objlogo;
            }
            result =   system.JSON.serialize(row);
            system.debug('Salesforce Response : ' + result);
            res.responseBody = blob.valueOf(result);	
        }else{  res.statusCode = 200;
              res.statusCode = 400;
              result =  'Agency requested by Guruland does not exist in Salesforce.';
              system.debug('Salesforce Response : ' + result);
              res.responseBody = blob.valueOf(result);
             }        
        
    }
}
@RestResource(urlMapping='/api/pgcampaign/pccampaignmember/')
global class PrimeCreditCampaignMemAPI {
    public class errorWrapper{
        String msg;
        String contactId;
        
    }
    public class SuccessWrapper{
        String CampaignMemberID;
        String contactId;
        
    }
    @HttpPost
    global static void upsertCampaignMember(){
       PGCampMemberTriggerHandler.TriggerDisabled=true; 
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String, Object> params;
        List<CampaignMember> insertCampaignMemberList = new List<CampaignMember>();
        
        if(request != null && String.isNotBlank(request.requestBody.toString())){
            system.debug('---<<<req>>>--- '+request.requestBody.toString());
            params = (Map<String, Object>)JSON.deserializeUntyped(request.requestBody.toString());
        }
        
        //system.debug('campaignId>>> '+params.get('campaignId'));
        List<Object>CMList;
        Map<String, Object> paramsCM;
        
        if(params == null){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('status', 'failure');
            gen.writeStringField('message', 'Params are not present.');
            gen.writeEndObject();
            String jsonData = gen.getAsString();
            res.statusCode = 200;
            res.responseBody =Blob.valueOf(gen.getAsString());
            return; 
        }
        
        if(params != null && (params.get('campaignId') == '' || params.get('campaignId') == null)){
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('status', 'failure');
            gen.writeStringField('message', 'CampaignId is Empty.');
            gen.writeEndObject();
            String jsonData = gen.getAsString();
            res.statusCode = 200;
            res.responseBody =Blob.valueOf(gen.getAsString());
            return;
            
        }
        List<Campaign> campList = [SELECT Id, IsActive FROM Campaign
                                   where Id = : String.valueOf(params.get('campaignId')) ];
        if(campList == null || campList.size()  == 0){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('status', 'failure');
            gen.writeStringField('message', 'Campaign does not exist in Salesforce');
            gen.writeEndObject();
            String jsonData = gen.getAsString();
            res.statusCode = 200;
            res.responseBody =Blob.valueOf(gen.getAsString());
            return; 
        }
        Campaign cam = campList[0];
        
        if(!cam.IsActive){
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('status', 'failure');
            gen.writeStringField('message', 'Campaign '+cam.Id+' is inactive');
            gen.writeEndObject();
            String jsonData = gen.getAsString();
            res.statusCode = 200;
            res.responseBody =Blob.valueOf(gen.getAsString());
            return; 
            
            
        }
        
        
        
        if(params != null&& params.containsKey('campaignMember') 
           && params.get('campaignMember') !=null && params.get('campaignMember') != ''){
               CMList= (List<Object>)params.get('campaignMember');
               if(CMList.isEmpty()){
                   JSONGenerator gen = JSON.createGenerator(true);
                   gen.writeStartObject();
                   gen.writeStringField('status', 'failure');
                   gen.writeStringField('message', 'Campaign Member Info is Empty.');
                   gen.writeEndObject();
                   String jsonData = gen.getAsString();
                   res.statusCode = 200;
                   res.responseBody =Blob.valueOf(gen.getAsString());
                   return; 
               }
               
               for(object obj : CMList){
                   Map<String,Object> cm =  (Map<String,Object>)obj;
                   if(cm.get('contactId') == '' || cm.get('contactId') == null){
                       JSONGenerator gen = JSON.createGenerator(true);
                       gen.writeStartObject();
                       gen.writeStringField('status', 'failure');
                       gen.writeStringField('message', ' Contact Id is missing'); 
                       gen.writeEndObject();
                       String jsonData = gen.getAsString();
                       res.statusCode = 200;
                       res.responseBody =Blob.valueOf(gen.getAsString());
                       return; 
                   } else{
                       CampaignMember insertMember = new CampaignMember(ContactId = (String)cm.get('contactId'), 
                                                                        status=(String)cm.get('status' ) ,
                                                                        CampaignId = String.valueOf(params.get('campaignId')),
                                                                        Needs_to_Sync__c = (Boolean)cm.get('syncNeeded') );
                       insertCampaignMemberList.add(insertMember);
                   }
               }
               
               
               
           }
        List<errorWrapper> ewList = new List<errorWrapper>();
        List<SuccessWrapper> successList = new List<SuccessWrapper>();
        Set<Id> campaignMemberIdsSet = new Set<Id>();
        
        if(insertCampaignMemberList.size()>0){
            
            List<Database.upsertResult> results = Database.upsert(insertCampaignMemberList,false);
            system.debug(results);	
            
            for(Integer i=0;i<results.size();i++){
                if(!results[i].isSuccess()){
                    system.debug(results[i].getErrors());
                    system.debug(insertCampaignMemberList[i]); 
                    for (Database.Error err : results[i].getErrors()) {
                        System.debug('Error : '+err.getMessage());
                        errorWrapper ew = new errorWrapper();
                        ew.msg=err.getMessage();
                        ew.contactId=insertCampaignMemberList[i].contactid;
                        ewList.add(ew );
                    }
                    
                }
                else if(results[i].isSuccess()){
                    SuccessWrapper sw = new SuccessWrapper();
                    sw.contactid = insertCampaignMemberList[i].contactid;
                    campaignMemberIdsSet.add(results[i].getid());
                    sw.CampaignMemberID = results[i].getid();
                    successList.add(sw);
                }
                
            }
            
            List<CampaignMember> CampaignMemberList = [select Id,Status,ContactId,LeadId,campaignId,Campaign.PG_Campaign_Id__c 
                                                       from CampaignMember where Id In : campaignMemberIdsSet];
            
            system.debug('CampaignMemberList>>> '+CampaignMemberList);
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
         
            if(CampaignMemberList != null && CampaignMemberList.size()>0){
                
                Self_Serve_Campaign_Notification__e newSSNotification = new Self_Serve_Campaign_Notification__e();
                newSSNotification.SF_Campaign_Id__c = CampaignMemberList[0].campaignId;
                newSSNotification.PG_Campaign_Id__c = CampaignMemberList[0].Campaign.PG_Campaign_Id__c;
                EventBus.publish(newSSNotification);
                system.debug('event published');
                
                
            }
            
            res.statusCode = 200;
            if(ewList.size()>0){ 
                gen.writeFieldName('Error');
                gen.writeStartArray();
                for(errorWrapper key : ewList){
                    gen.writeStartObject();
                    gen.writeStringField('msg', key.msg);
                    gen.writeStringField('contactId', key.contactId);
                    gen.writeEndObject();
                }
                gen.writeEndArray();
                //gen.writeStringField('error',JSON.serialize(ewList));
            }
            if(successList.size()>0){
                
                    gen.writeFieldName('success');
                    gen.writeStartArray();
                    for(SuccessWrapper key : successList){
                        gen.writeStartObject();
                        gen.writeStringField('CampaignmemberId', key.campaignMemberId);
                        gen.writeStringField('contactId', key.contactId);
                        gen.writeEndObject();
                    }
                    gen.writeEndArray();
                  //  gen.writeStringField('Success',JSON.serialize(successList));
            }
                res.responseBody =Blob.valueOf(gen.getAsString());
                
                return; 
                
                
            
            
            
            
        }
    }
}
/*
* TestClass : PGCampaigns_Test
*/
@RestResource(urlMapping='/api/pgcampaign/upsertcampaignmember/')
global class PGCampaigns {
    
    @HttpPost
    global static void upsertCampaignMember(){
        
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String, Object> params;
        
        if(request != null && String.isNotBlank(request.requestBody.toString())){
            system.debug('---<<<req>>>--- '+request.requestBody.toString());
            params = (Map<String, Object>)JSON.deserializeUntyped(request.requestBody.toString());
        }
        
        //system.debug('campaignId>>> '+params.get('campaignId'));
        
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
        List<Campaign> campList = [SELECT Id, IsActive FROM Campaign where Id = : String.valueOf(params.get('campaignId')) ];
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
        
        
        if(params != null&& params.containsKey('campaignMember') && params.get('campaignMember') !=null && params.get('campaignMember') != ''){
            
            paramsCM = (Map<String, Object>)params.get('campaignMember');
            if(paramsCM == null){
                
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
            if(paramsCM != null && (paramsCM.get('contactId') == '' || paramsCM.get('contactId') == null) && (paramsCM.get('id') == '' || paramsCM.get('id') == null)){
                
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('status', 'failure');
                gen.writeStringField('message', 'Campaign Member and Contact Id both are missing'); 
                gen.writeEndObject();
                String jsonData = gen.getAsString();
                res.statusCode = 200;
                res.responseBody =Blob.valueOf(gen.getAsString());
                return; 
                
                
            }
            
        }
        
       // system.debug('campaignMemberId>>> '+paramsCM.get('id'));
      //  system.debug('contactId>>> '+paramsCM.get('contactId'));
      ///  system.debug('status>>> '+paramsCM.get('status'));
        
        String campaignMemberId = paramsCM.containsKey('id')?String.valueOf(paramsCM.get('id')):'';
        String contactID = paramsCM.containsKey('contactId')?String.valueOf(paramsCM.get('contactId')):'';
        
        List<CampaignMember> insertAndUpdateCampaignMemberList = new List<CampaignMember>();
        
        list<CampaignMember> existingCampaignMember = new list<CampaignMember>();
        
        
        
        if(String.isNotBlank(campaignMemberId)){
            existingCampaignMember = [Select Id,Status from CampaignMember where ID =:campaignMemberId ];
            if(existingCampaignMember.size()>0){
                CampaignMember updateMember = new CampaignMember(Id = campaignMemberId, status=String.valueOf(paramsCM.get('status')));
                insertAndUpdateCampaignMemberList.add(updateMember);
            }else{
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('status', 'failure');
                gen.writeStringField('message', 'Did not find CampaignMember for given Id');
                gen.writeEndObject();
                String jsonData = gen.getAsString();
                res.statusCode = 200;
                res.responseBody =Blob.valueOf(gen.getAsString());
                //return jsonData;
            }
            
            
        }
        else if(String.isNotBlank(contactId)){
            
            existingCampaignMember = [Select Id,Status from CampaignMember where CampaignId =:String.valueOf(params.get('campaignId')) AND ContactId =:contactId ];
            if(existingCampaignMember.size()>0){
                CampaignMember updateMember = new CampaignMember(Id = existingCampaignMember[0].Id, status=String.valueOf(paramsCM.get('status')));
                insertAndUpdateCampaignMemberList.add(updateMember);
            }else{
                CampaignMember updateMember = new CampaignMember(ContactId = contactId, status=String.valueOf(paramsCM.get('status')) ,CampaignId = String.valueOf(params.get('campaignId')));
                insertAndUpdateCampaignMemberList.add(updateMember);
            }
            
        }
        
        
        List<String> errorListMessage = new List<String>();
        Set<Id> campaignMemberIdsSet = new Set<Id>();
        
        if(insertAndUpdateCampaignMemberList.size()>0){
            
            List<Database.upsertResult> results = Database.upsert(insertAndUpdateCampaignMemberList,false);
            
            for (Database.UpsertResult sr : results) {
                if (sr.isSuccess()) {
                    campaignMemberIdsSet.add(sr.getId());
                    System.debug('Successfully inserted CM ' + sr.getId());
                } else {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('Error : '+err.getMessage());
                        errorListMessage.add(err.getMessage());
                    }
                }
            }
            
        }
        
        List<CampaignMember> CampaignMemberList = [select Id,Status,ContactId,LeadId,campaignId from CampaignMember where Id In : campaignMemberIdsSet];
        
        system.debug('CampaignMemberList>>> '+CampaignMemberList);
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        if(CampaignMemberList != null && CampaignMemberList.size()>0){
            
            gen.writeStringField('status', 'success');
            gen.writeStringField('campaignId', CampaignMemberList[0].campaignId);
            gen.writeFieldName('campaignMember');
            gen.writeStartObject();
            gen.writeStringField('id', CampaignMemberList[0].Id);
            gen.writeStringField('contactId', CampaignMemberList[0].ContactId);
            gen.writeStringField('status', CampaignMemberList[0].Status);
            gen.writeEndObject();
            res.statusCode = 200;
            res.responseBody =Blob.valueOf(gen.getAsString());  
            return; 
            
        }else{
            if(errorListMessage != null && errorListMessage.size()>0){
                
                gen.writeStringField('status', 'failure');
                gen.writeStringField('message', errorListMessage[0]);
                res.statusCode = 200;
                res.responseBody =Blob.valueOf(gen.getAsString());
                return; 
                
            }
            
        }
        
        // gen.writeEndObject();
        
        //  String successOrErrorMsg = gen.getAsString();
        
        // return successOrErrorMsg;
    }
    
    
}
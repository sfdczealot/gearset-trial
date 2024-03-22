public class CMOperationsBatch implements DataBase.Batchable<Sobject>,Database.Stateful{
    
    //public map<id,list<sObject>> idVsListOfObjectMap;
    public Id scope;
    public list<sObject> sObjectList;
    public Set<String> oldLeadVsContactId = new Set<String>();
        
    
    public CMOperationsBatch(Id scope,list<sObject> sObjectList){
        
        this.scope = scope; 
        this.sObjectList = sObjectList;
    }
    
    public DataBase.QueryLocator start(DataBase.BatchableContext bc){
        
        for(Sobject obj : this.sObjectList){
            String objectName= Id.valueOf(obj.id).getSobjectType().getDescribe().getName()+'';
            if(objectName == 'CampaignMember'){
                CampaignMember cm = (CampaignMember)obj;
                 oldLeadVsContactId.add(cm.contactId);
            }
            else  if(objectName == 'Lead'){
                Lead ld = (Lead)obj;
                    oldLeadVsContactId.add(ld.Id);    
            }
        else  if(objectName == 'Contact'){
                Contact con = (Contact)obj;
                    oldLeadVsContactId.add(con.Id);
            }
            
        }
        
        Campaign_Eligibility__c CE = [Select id,Campaign__c from Campaign_Eligibility__c where Id =: this.scope Limit 1];
        Id campId = CE.Campaign__c;
        String query = 'Select Id,ContactId,LeadId,CampaignId,Status from CampaignMember where CampaignId =:campId AND (CreatedBy.Profile.Name=\'System Administrator\' OR CreatedBy.Profile.Name=\'Delegated System Administrator\' OR CreatedBy.Profile.Name=\'API User Profile\')';
        return DataBase.getQueryLocator(query);
        
    }
    
    public void execute(DataBase.BatchableContext bc,List<CampaignMember> CMS){
        //to have id of Lead and Contact which are received from engine 
       //list of Campaign Members to be inserted
        List<CampaignMember> insertCampaignMemberList = new List<CampaignMember>();
        //list of Campaign Members to be updated
        List<CampaignMember> updateCampaignMemberList = new List<CampaignMember>();
        Campaign_Eligibility__c objCampElig = [Select id, Campaign__c, Campaign__r.RecordType.Name from Campaign_Eligibility__c where Id =: this.scope Limit 1];
        
        //In below loop we will have a list of CM to be updated
        for(CampaignMember cl : CMS){
            //if CM existing status is Eligible
            if(cl.Status == 'Eligible'|| cl.Status == 'Joined' || cl.Status == 'Re-eligible'){
                //if new Eligibe list contains Campaign members
                if(oldLeadVsContactId.contains(cl.LeadId) || oldLeadVsContactId.contains(cl.ContactId)){
                    if(oldLeadVsContactId.contains(cl.LeadId))
                        oldLeadVsContactId.remove(cl.LeadId);
                    else
                        oldLeadVsContactId.remove(cl.ContactId);
                }
                //if Member was Eligible before but revoked in current process
                else {
                    cl.status = 'Revoked';
                    if(objCampElig.Campaign__r.RecordType.Name == 'Self Serve Marketing Promotion') {
                        cl.Needs_to_Sync__c = true;
                    }
                    updateCampaignMemberList.add(cl);
                }
                
            }
            //if existing Campaign Member isn't eligible
            else{
                //when Campaign member was not eligible before but eligible in current process
                if(oldLeadVsContactId.contains(cl.LeadId) || oldLeadVsContactId.contains(cl.ContactId)){
                    cl.Status = 'Eligible';
                    if(objCampElig.Campaign__r.RecordType.Name == 'Self Serve Marketing Promotion') {
                        cl.Needs_to_Sync__c = true;
                    }
                    updateCampaignMemberList.add(cl);
                    if(oldLeadVsContactId.contains(cl.LeadId))
                        oldLeadVsContactId.remove(cl.LeadId);
                    else
                        oldLeadVsContactId.remove(cl.ContactId);
                }   
            }
            
        }
        
        if(!updateCampaignMemberList.isEmpty())
            update updateCampaignMemberList;
        
    }
    
    public void finish(DataBase.BatchableContext bc){
        if(!oldLeadVsContactId.isEmpty()){
            Database.executeBatch(new CMInsertCRE(scope,oldLeadVsContactId), 8000);
        } else {
            //event used to send the info to workato
            //PGAUTO-5803
            List<Campaign_Eligibility__c> listCampEligible = [
                SELECT Id, Campaign__c, Campaign__r.PG_Campaign_Id__c, Campaign__r.RecordType.Name
                FROM Campaign_Eligibility__c 
                WHERE Id =: this.scope 
                AND Campaign__r.RecordType.Name = 'Self Serve Marketing Promotion'
            ];
             List<Campaign_Eligibility__c> listSSCampEligible = [
                SELECT Id, Campaign__c, Campaign__r.PG_Campaign_Id__c, Campaign__r.RecordType.Name
                FROM Campaign_Eligibility__c 
                WHERE Id =: this.scope 
                AND Campaign__r.RecordType.Name = 'Self Serve Renewal campaigns'
            ];
             if(!listSSCampEligible.isEmpty()) {
                RSS_discount_campaign_event__e   newSSNotification = new RSS_discount_campaign_event__e ();
                newSSNotification.campaign_ID__c  = listSSCampEligible[0].Campaign__c;
                newSSNotification.event_type__c  = 'Batch';
                EventBus.publish(newSSNotification);
            }
            if(!listCampEligible.isEmpty()) {
                Self_Serve_Campaign_Notification__e newSSNotification = new Self_Serve_Campaign_Notification__e();
                newSSNotification.SF_Campaign_Id__c = listCampEligible[0].Campaign__c;
                newSSNotification.PG_Campaign_Id__c = listCampEligible[0].Campaign__r.PG_Campaign_Id__c;
                EventBus.publish(newSSNotification);
            }
        }
    }
}
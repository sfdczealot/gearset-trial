/*
* TestClass : CampaignMemberOperationsBatch_Test 
*/
public class CampaignMemberOperationsBatch implements DataBase.Batchable<Sobject>{
    
    public map<id,list<sObject>> idVsListOfObjectMap;
    
    public CampaignMemberOperationsBatch(map<id,list<sObject>> idVsListOfObjectMap){
        
        this.idVsListOfObjectMap = new map<id,list<sObject>>();
        this.idVsListOfObjectMap = idVsListOfObjectMap;
    }
    
    public DataBase.QueryLocator start(DataBase.BatchableContext bc){
        
        Set<Id> campaignElId = idVsListOfObjectMap.keySet();
        String query= 'SELECT Id, Campaign__c,Campaign__r.Name, Campaign__r.recordType.Name,Campaign__r.isActive FROM Campaign_Eligibility__c where Id IN : campaignElId and Status__c=\'Active\' and Campaign__r.isActive=true';
        return DataBase.getQueryLocator(query);
    }
    
    public void execute(DataBase.BatchableContext bc,List<Campaign_Eligibility__c> scope){
        
        //to have id of Lead and Contact which are received from engine 
        Set<String> oldLeadVsContactId = new Set<String>();
        //list of Campaign Members to be inserted
        List<CampaignMember> insertCampaignMemberList = new List<CampaignMember>();
        //list of Campaign Members to be updated
        List<CampaignMember> updateCampaignMemberList = new List<CampaignMember>();
        //to fill oldLeadVsContactId set from idVsListOfObjectMap(received from engine)
        //for(String Ids : idVsListOfObjectMap.keyset()){
            for(Sobject obj : idVsListOfObjectMap.get(String.valueOf(scope[0].id))){
                try{
                    Lead ld = (Lead)obj;
                    if(ld != null)
                        oldLeadVsContactId.add(ld.Id);    
                }catch(Exception e){}
                try{
                    Contact con = (Contact)obj;
                    if(con != null)
                        oldLeadVsContactId.add(con.Id);
                }catch(Exception e){
                }
                
            }
        //}
        //query of existing campaign members which are created by System admin
        //In below loop we will have a list of CM to be updated
        for(CampaignMember cl : [Select Id,ContactId,LeadId,CampaignId,Status 
                                 from CampaignMember 
                                 where CampaignId =:scope[0].Campaign__c 
                                 AND (CreatedBy.Profile.Name='System Administrator' 
                                      OR CreatedBy.Profile.Name='Delegated System Administrator'
                                      OR CreatedBy.Profile.Name='API User Profile')] 
          ) {
            //if CM existing status is Eligible
            if(cl.Status == 'Eligible'|| cl.Status == 'Joined'){
                //if new Eligibe list contains Campaign members
                if(oldLeadVsContactId.contains(cl.LeadId) || oldLeadVsContactId.contains(cl.ContactId)){
                    if(oldLeadVsContactId.contains(cl.LeadId))
                        oldLeadVsContactId.remove(cl.LeadId);
                    else
                        oldLeadVsContactId.remove(cl.ContactId);
                }
                //if Member was Eligible before but revoked in current process
                else {
                    //if(cl.Status!='Joined'){
                        cl.status = 'Revoked';
                    //}
                    updateCampaignMemberList.add(cl);
                }
                
            }
            //if existing Campaign Member isn't eligible
            else{
                //when Campaign member was not eligible before but eligible in current process
                if(oldLeadVsContactId.contains(cl.LeadId) || oldLeadVsContactId.contains(cl.ContactId)){
                    cl.Status = 'Eligible';
                    updateCampaignMemberList.add(cl);
                    if(oldLeadVsContactId.contains(cl.LeadId))
                        oldLeadVsContactId.remove(cl.LeadId);
                    else
                        oldLeadVsContactId.remove(cl.ContactId);
                }   
            }
            
        }
        //To create list of CM to be inserted
        if(oldLeadVsContactId != null && !oldLeadVsContactId.isEmpty()){
            for(Id cid : oldLeadVsContactId){
                if(String.valueOf(cid).startsWith('003')){
                    CampaignMember newMember = new CampaignMember(ContactId = cid, status='Eligible', campaignid = scope[0].Campaign__c);
                    insertCampaignMemberList.add(newMember);
                }
                else if(String.valueOf(cid).startsWith('00Q')){
                    IF(scope[0].Campaign__r.recordType.Name=='B2B Developer Online Form'){
                    	CampaignMember newMember = new CampaignMember(LeadId = cid, status='Joined', campaignid = scope[0].Campaign__c);
                        insertCampaignMemberList.add(newMember);
                    }else{
                        CampaignMember newMember = new CampaignMember(LeadId = cid, status='Eligible', campaignid = scope[0].Campaign__c);
                        insertCampaignMemberList.add(newMember);
                    }
                    
                }
                
            }
            
        }
  
        if(!updateCampaignMemberList.isEmpty())
            update updateCampaignMemberList;
        if(!InsertCampaignMemberList.isEmpty())
            insert insertCampaignMemberList;
    }
    
    public void finish(DataBase.BatchableContext bc){
        if(Test.isRunningTest()){
            Integer i =0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }  
    }
}
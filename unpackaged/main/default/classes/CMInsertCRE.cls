/*
 * TestClass : CMInsertCRE_Test
 */
public class CMInsertCRE implements DataBase.Batchable<String>,Database.stateful,Database.AllowsCallouts{
    
    public class Payload {
        String text;
    }
    public String campaignId;
    //public map<id,list<sObject>> idVsListOfObjectMap;
    public Id scope;
    public list<String> oldLeadVsContactId = new list<String>(); 
    public Database.SaveResult[] allInsertList ;    
    public list<Id> conLeadIds;
    List<Self_Serve_Campaign_Notification__e> listSSNotification = new List<Self_Serve_Campaign_Notification__e>();    
  List<RSS_discount_campaign_event__e > listRSSNotification = new List<RSS_discount_campaign_event__e >();    
    public CMInsertCRE(){ 
        
    }
    public CMInsertCRE(Id scope,Set<String> oldLeadVsContactId){ 
        
        this.scope = scope;
        this.oldLeadVsContactId.addAll(oldLeadVsContactId);
        allInsertList = new list<Database.SaveResult>();
        conLeadIds = new list<id>();
    }
    
    public Iterable<String> start(DataBase.BatchableContext bc){
        
        return oldLeadVsContactId;
    }
    
    public void execute(DataBase.BatchableContext bc,List<String> oldLeadVsContactId2){
        PGCampMemberTriggerHandler.Bypass = true;
        Campaign_Eligibility__c camp = [
            SELECT Id, Campaign__c, Campaign__r.RecordType.Name, Campaign__r.PG_Campaign_Id__c
            FROM Campaign_Eligibility__c 
            WHERE Id =: scope
        ];
        campaignId = camp.Campaign__c;
        list<CampaignMember> insertCampaignMemberList = new list<CampaignMember>();
        //To create list of CM to be inserted
        if(oldLeadVsContactId2 != null && !oldLeadVsContactId2.isEmpty()){
            for(String cid : oldLeadVsContactId2){
                if(String.valueOf(cid).startsWith('003')){
                    CampaignMember newMember = new CampaignMember(ContactId = cid, status='Eligible', campaignid = camp.Campaign__c);
                    if(camp.Campaign__r.RecordType.Name.equals('Self Serve Marketing Promotion')) {
                        newMember.Needs_to_Sync__c = true;
                    }
                    conLeadIds.add(cid);
                    insertCampaignMemberList.add(newMember);
                }
                else if(String.valueOf(cid).startsWith('00Q')){
                    IF(camp.Campaign__r.recordType.Name=='B2B Developer Online Form'){
                        CampaignMember newMember = new CampaignMember(LeadId = cid, status='Joined', campaignid = camp.Campaign__c);
                        conLeadIds.add(cid);
                        insertCampaignMemberList.add(newMember);
                    }else{
                        CampaignMember newMember = new CampaignMember(LeadId = cid, status='Eligible', campaignid = camp.Campaign__c);
                        if(camp.Campaign__r.RecordType.Name.equals('Self Serve Marketing Promotion')) {
                            newMember.Needs_to_Sync__c = true;
                        }
                        conLeadIds.add(cid);
                        insertCampaignMemberList.add(newMember);
                    }
                    
                }
                
            }
            
        }
        if(!insertCampaignMemberList.isEmpty()){
            Database.SaveResult[] insertList = Database.insert(insertCampaignMemberList,false);
            allInsertList.addAll(insertList);
        }
        
        if(camp.Campaign__r.RecordType.Name.equals('Self Serve Marketing Promotion')) {
            Self_Serve_Campaign_Notification__e newSSNotification = new Self_Serve_Campaign_Notification__e();
            newSSNotification.SF_Campaign_Id__c = camp.Campaign__c;
            newSSNotification.PG_Campaign_Id__c = camp.Campaign__r.PG_Campaign_Id__c;
            listSSNotification.add(newSSNotification);
        }
         if(camp.Campaign__r.RecordType.Name.equals('Self Serve Renewal campaigns')) {
            RSS_discount_campaign_event__e  newSSNotification = new RSS_discount_campaign_event__e ();
            newSSNotification.campaign_ID__c  = camp.Campaign__c;
                newSSNotification.event_type__c  = 'Batch';
            listRSSNotification.add(newSSNotification);
        }
    }
    
    public void finish(DataBase.BatchableContext bc){
        campaignMemberSlackAlert(campaignId,allInsertList);
        if(!listSSNotification.isEmpty()) {
            //event used to send the info to workato
            //PGAUTO-5803
            EventBus.publish(listSSNotification);
        }
         if(!listRSSNotification.isEmpty())
         EventBus.publish(listRSSNotification);
    
    }
    
    public void campaignMemberSlackAlert(String campaignId, Database.SaveResult[] insertList){
        
        if(!runningInASandbox() || Test.isRunningTest()){
        
            Payload PayloadData = new Payload();
            Integer Count = 0;
            String title = '', text = '```"CampaignId", "Contact/Lead Id", "Error"\n', payload = '';
            for(integer i=0;i<insertList.size();i++){
                if(insertList[i] !=null && !insertList[i].isSuccess() && insertList[i].getErrors() !=null && insertList[i].getErrors().size() > 0 ){
                    //text += '"", '+String.valueOf(insertList[i].getErrors()[0].getMessage())+'"\n';
                    String conLead = conLeadIds==null || conLeadIds[i] == null ?'':conLeadIds[i];
                    text += '"'+campaignId+'", "'+conLead+'", "'+String.valueOf(insertList[i].getErrors()[0].getMessage())+'"\n';
                        Count++;
                }
            }
            
            if(Count > 0){
                text += '```';
                title += '<@U02AP0BELQ0> <@UTDHN0FU2>'+Count +' CampaignMembers with error\n';
                payload += title + text;
            }
            if(payload <> ''){
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(label.PG_LABEL_PGAutomationAlert);
                req.setMethod('POST');
                req.setHeader('Cache-Control', 'no-cache');
                req.setHeader('Content-Type', 'application/json');
                PayloadData.text = payload;
                string request = system.JSON.serialize(PayloadData);
                req.setBody(request);
                if(!Test.isRunningTest()){
                    HttpResponse res = h.send(req);
                    if (res.getStatusCode() <> 200) {
                        String errorResponse = res.getBody();
                    }
                }
            }
        }
    }
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
}
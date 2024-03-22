public without sharing class CampaignEligibilityEventHandler {
    
    public static void addContactToFirstTimerCampaign(List<Account> accountList,Map<Id,Account> oldMap){
    
        system.debug('accountList:::::'+JSON.serializePretty(accountList)); 
        system.debug('oldMap:::::'+JSON.serializePretty(oldMap));
        list<id> personContactIds = new list<Id>();
        list<Account> accountsToProcess = new list<Account>();
        for(Account acc : accountList){
            if(acc.Status__c == 'Trial' && (oldMap == null || oldMap.get(acc.Id) == null || String.isBlank(oldMap.get(acc.Id).Status__c))){
                personContactIds.add(acc.PersonContactId);
                accountsToProcess.add(acc);
            }else if(acc.Status__c == 'Trial' && oldMap != null && oldMap.get(acc.Id) != null && String.isNotBlank(oldMap.get(acc.Id).Status__c) && oldMap.get(acc.Id).Status__c == 'Pending'){
                personContactIds.add(acc.PersonContactId);
                accountsToProcess.add(acc);
            }else if(acc.Status__c == 'Expired' && oldMap != null && oldMap.get(acc.Id) != null && oldMap.get(acc.Id).Status__c != 'Expired'){
                personContactIds.add(acc.PersonContactId);
                accountsToProcess.add(acc);
            }
        }
        if(accountsToProcess.isEmpty()){
            return ;
        }
        list<Campaign> firstTimerCampaigns = [select id,Country__c,(Select id,Status,ContactId from CampaignMembers where ContactId IN : personContactIds) from Campaign where RecordType.DeveloperName = 'FirstTimer' AND isActive = true AND ParentId != null Order By CreatedDate ASC];
    	list<CampaignMember> listCampaignMemberToInsert = new list<CampaignMember>();
        list<CampaignMember> listCampaignMemberToUpdate = new list<CampaignMember>();
        
        map<String,list<id>> CountryVsCampaignId = new map<String,list<id>>();
        map<id,String> CMIdVsStatus = new map<id,String>();
        
        map<String,Id> campContactIdVsCMId = new map<String,Id>();      
        
        system.debug('firstTimerCampaigns>>> '+firstTimerCampaigns);
        for(Campaign cam : firstTimerCampaigns){
            if(CountryVsCampaignId.containsKey(cam.Country__c)){
                CountryVsCampaignId.get(cam.Country__c).add(cam.id);
            }else{
                CountryVsCampaignId.put(cam.Country__c,new list<id>{cam.id});
            }
            
            set<Id> cmIds = new set<Id>();
            for(CampaignMember CM : cam.CampaignMembers){
                CMIdVsStatus.put(CM.ContactId,CM.Status);
                cmIds.add(CM.ContactId);
                campContactIdVsCMId.put(cam.Id+';'+CM.contactId,CM.Id);
            }
            
        }
        system.debug('CMIdVsStatus:::::'+JSON.serializePretty(CMIdVsStatus));
        system.debug('accountsToProcess:::::'+JSON.serializePretty(accountsToProcess));
        
        system.debug('CountryVsCampaignId>>> '+CountryVsCampaignId);
        for(Account acc : accountsToProcess){
            list<Id> campaignIdList = new list<Id>();
            if(CountryVsCampaignId.containsKey(acc.Country__c)){
                campaignIdList = CountryVsCampaignId.get(acc.Country__c);
            }
            system.debug('campaignIdList>>> '+campaignIdList);
            for(Id campaignId : campaignIdList){
                system.debug('campaignId>>> '+campaignId);
                if(String.isNotBlank(campaignId)){
                    if(campContactIdVsCMId.containsKey(campaignId+';'+acc.PersonContactId)){
                        listCampaignMemberToUpdate.add(New CampaignMember(Id = campContactIdVsCMId.get(campaignId+';'+acc.PersonContactId), Status='Eligible'));
                    }else{
                        listCampaignMemberToInsert.add(new CampaignMember(CampaignId=campaignId, ContactId= acc.personContactId, Status='Eligible'));
                    }
                }
        	}
        }
        
        if(!listCampaignMemberToInsert.isEmpty()){
            insert listCampaignMemberToInsert;
        }
        if(!listCampaignMemberToUpdate.isEmpty()){
            Update listCampaignMemberToUpdate;
        }
        
    } 
}
public class B2BPrimaryCampUpdateLogic {
    @future
    public static void methodB2BCampaign(Map<Id,Id> mapofOppwithAccountId){
        Map<Id,Account> mapAllAccount=new Map<Id,Account>([select id,Name,(select Id from Contacts order By createdDate Asc) from Account where Id IN: mapofOppwithAccountId.values()]);
        Set<Id> setofConId=new Set<Id>();
        for(Account eachacc : mapAllAccount.Values()){
            for(Contact eachcon: eachacc.Contacts){
                setofConId.add(eachcon.Id);
            }
        }
        //Can add more status conditions in where condition
        if(setofConId.size()>0){
            List<Opportunity> lsttoupdate=new List<Opportunity>();//Final List for updating
            List<CampaignMember> lstCampMem=[select Id,ContactID,CampaignId,Campaign.recordType.Name,Campaign.isActive,Campaign.startDate from CampaignMember where Campaign.isActive=true and Campaign.recordType.Name Like'%B2B%' and status In ('Attended','Responded','Joined')  and ContactID IN: setofConId order by Campaign.startDate ASC];
            Map<ID,ID> mapofContIDVsCampMemID=new Map<ID,ID>();
            for(CampaignMember eachMem: lstCampMem){
                //At last latest Campaign is assgined to Contact
                mapofContIDVsCampMemID.put(eachMem.ContactID,eachMem.CampaignId);
              }
            //Final loop for updating Campaign related to Opportunity
            for(ID eachOpp : mapofOppwithAccountId.KeySet()){
                for(Contact eachcon: mapAllAccount.get(mapofOppwithAccountId.get(eachOpp)).Contacts){
                    If(mapofContIDVsCampMemID.ContainsKey(eachcon.Id)){
                        Opportunity objOpp=new Opportunity(Id=eachOpp,CampaignId=mapofContIDVsCampMemID.get(eachcon.Id));
                        lsttoupdate.add(objOpp);
                    }
                }
            }
            if(lsttoupdate.size()>0){
                Database.update(lsttoupdate,false);
            }
        }
       
    }
}
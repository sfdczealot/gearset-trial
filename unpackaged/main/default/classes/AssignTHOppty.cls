// to Assign TH renewal Oppty based on round robin to sales rep
public class AssignTHOppty {
    
    // this method is used to get list of TH - Renewal Sales Rep
    public static List<User> getTHRenewalSalesRep(){
        List<User> listUser=[Select id from User where
                             UserRole.name = 'TH - Renewal Sales Rep' 
                             and IsActive = true];
        return listUser;
    }
    // this method is used to divide all the generated TH renewals opp among the sales rep
    public static void assignOppty(Map<String, list<Opportunity>> ruleCodeMap){
       
        
        String thLead=label.PG_LABEL_TH_Renewal_Team_Lead;
        
        List<Opportunity> assignOppty=new list<opportunity>();
        Integer alrAssigned=0;
        List<User> listUser=getTHRenewalSalesRep();
        if(listUser.size()>0){
        for(String key : ruleCodeMap.keySet()){
            Integer individualOppty;
            Integer leftOppty;
            Integer totaloppty=ruleCodeMap.get(key).size();
            leftOppty = math.mod(totalOppty,listUser.size());
            individualOppty = (totalOppty-leftOppty)/listUser.size();
            Integer opptyAlrAssigned =0 ;
            list<Opportunity> oppList =ruleCodeMap.get(key);
            system.debug('oppty assigned to lead '+leftOppty+'   '+key);
            
            for(user u : listUser){
               for(Integer i=0;i<individualOppty;i++){
                    assignOppty.add(new Opportunity(ownerid=u.id,
                                                    id=oppList[opptyAlrAssigned].id));
                    opptyAlrAssigned++;
                }//assignment for
                
            }//user for
        }
        }
        // update assignOppty;
        Database.executeBatch(new UpdateRenewalOppOwner_Batch(assignOppty),10);
    }
    
}
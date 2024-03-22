public class AssignMY_SGRenewalOpp {
    
    // fetch the list of users having role as MY renewal Team lead or MY Renewal Sales Rep
    public static List<User> getMYRenewalSalesRep(){
        List<User> listUser=[Select id from User where
                             (UserRole.name = 'MY - Renewal Team Lead' or UserRole.Name = 'MY - Renewal Sales Rep')
                             and IsActive = true];
        return listUser;
    }
    
    // divide the renewal oppty's among MY renewal sales rep/lead
    public static void assignMYRenewalOppty(Map<String, list<Opportunity>> ruleCodeMapMY){
        List<User> listUser=getMYRenewalSalesRep();
        List<Opportunity> oppList=new List<Opportunity>();
        integer userCount=listUser.size();
        integer i=0;
        List<Upgrade_Package_Lookup__c> upgPkgList = [Select Country__c,Level__c,Name, Renewal_SKU__c,Upgrade_SKU__c,Renewal_Type__c,IsActive__c 
                                                      from Upgrade_Package_Lookup__c where  Country__c ='Malaysia' order by Level__c desc];
        for(String s:ruleCodeMapMY.keySet()){
            system.debug('>>>>><<<< '+s);
        }
        for(Upgrade_Package_Lookup__c upgPkg : upgPkgList){
            String ruleCode =upgPkg.name.replace(' - MY','').toLowerCase();
            system.debug('ruleCode    '+ruleCode);
            if(ruleCodeMapMY.containsKey(ruleCode)){
                for(Opportunity opp : ruleCodeMapMY.get(ruleCode)){
                    oppList.add(new opportunity(id=opp.id,ownerid=listUser[i].id));
                    //opp.ownerid=listUser[i].id;
                    i++;
                    if(i==userCount){
                        i=0;
                    }
                }
            }
        }
        Database.executeBatch(new UpdateRenewalOppOwner_Batch(oppList),10);
        //call batch class
    }
}
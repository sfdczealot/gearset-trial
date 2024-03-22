public class opportunityTriggerHelper {
      public static Boolean isPrimeCreditFirstTime = true; 
    public static void validateDeletion(List<Opportunity> oldList){

        // PGAUTO-1814 Profile should not be able to delete Oppty.
        String AllowAccess = System.Label.PG_LABEL_Profile_access_to_delete_Opptys;
        if(!allowAccess.contains(UserInfo.getProfileId())){
            PGOpportunityTriggerHandler.validateDelete(oldList);
        }
    }

    public static void befIns(List<Opportunity> newList){
        List<Opportunity> oppList = new List<Opportunity>();
        if(enabled()){
            for(Opportunity opty : newList) {                
                if (!system.isBatch() || opty.isBulkUpdate__c) {
                    oppList.add(opty);
                    if(QuoteSyncHandler.isTriggerFire || !Test.isRunningTest()) {
                        //Subsidiary and pricebook population code moved to applyDefault method
                        //PGAUTO-5535
                        applyDefault(oppList);
                        
                        //PGAUTO-2941
                        //Set payment term as Immediate
                        PGOpportunityTriggerHandler.insertHandler(newList);
                        
                        //Reset fields when cloning opportunity and set Opp.isClone__c
                        PGOpportunityTriggerHandler.resetField(newList);
                        PGOpportunityTriggerHandler.setIsClone(newList);
                        
                    }
                    PGOpportunityTriggerHandler.validationOnBillingAddress(newList,null,null);
                }
                
            }
        }
    }
    
    public static void befUpdate(List<Opportunity> newList, Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap){
        
        if(enabled()){
            String b2c =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
            String b2cCloseLost =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Closed Lost').getRecordTypeId();
            String b2b=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
            String b2css = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Self-Serve').getRecordTypeId();
            
            if (!system.isBatch() ) {
                
                // Eligibility Initialization End
                
                if (QuoteSyncHandler.isTriggerFire || Test.isRunningTest()) {
                    QuoteSyncHandler.isTriggerFire = false;
                    //to get ProfileID of Integration user
                    String profId;
                    /* commented on 2nd june 2021, as this variable is not used on the code, PGAUTO-5461
try{
profId=[select id from profile where name='Integration Profile' Limit 1].id;
}
catch (Exception e){
system.debug('ERROR  '+e.getMessage());
}*/
                    
                    
                    if(PGOpportunityTriggerHandler.isFirstTimeSub || Test.isRunningTest()) {
                        
                        //optmising code for soql error
                        Set<Id> setOfChangedOppId = new Set<Id>();
                        Set<Id> setOfOppOwnerId = new Set<Id>();
                        for (Opportunity eachOpp: newList) {
                            if(
                                eachOpp.OwnerId != oldMap.get(eachOpp.Id).OwnerId ||
                                eachOpp.RecordtypeId != oldMap.get(eachOpp.Id).RecordtypeId ||
                                eachOpp.PriceBook2Id == null
                            ) {
                                setOfChangedOppId.add(eachOpp.Id);
                                setOfOppOwnerId.add(eachOpp.OwnerId);
                            }
                            System.Debug('rec###' + eachOpp.RecordTypeId);
                            System.Debug('b2c###' + b2c);
                            System.Debug('b2css###' + b2css);
                            System.Debug('opptype###' + eachOpp.Opportunity_Type__c);
                            System.Debug('old stage###' + oldMap.get(eachOpp.Id).StageName);
                            System.Debug('new stage###' + eachOpp.StageName);
                            if(!Test.isRunningTest() && (eachOpp.RecordTypeId == b2c || eachOpp.RecordTypeId == b2css) && 
                                (eachOpp.Opportunity_Type__c == 'B2C - Renewal' || eachOpp.Opportunity_Type__c == 'Self-Serve Renewal') &&
                                oldMap.get(eachOpp.Id).StageName != eachOpp.StageName && (eachOpp.StageName == 'Closed Won' || eachOpp.StageName == 'Converted')) {
                                    populateRenewalType(newList,oldMap);
                            }
                        }
                        if(!setOfChangedOppId.isEmpty()) {
                            Map<Id, User> mapOfUserId = new Map<Id, User>([SELECT Id, Sales_Head__c FROM User WHERE Id IN: setOfOppOwnerId]);
                            //Set subsidiary & pricebook
                            Map < String, Subsidiary__c > mapOfSubsidiary = PGOpportunityTriggerHandler.getSubsidiaryMap();
                            Map < Id, String > OwnerSubsNameIdMap = PGOpportunityTriggerHandler.UserIdSubsIdMap();
                            Map < Id, Id > SubsIdPBIdMap = PGOpportunityTriggerHandler.SubsidiaryIdPricebookIdMap();
                            Set<Id> accIds = new Set<id>();
                            Map<id,id> accIdVsContactId = new Map<id,id>();
                            for (Opportunity Opp: newList) {
                                if (System.isScheduled() == false && setOfChangedOppId.contains(Opp.Id)) {
                                    if (mapOfSubsidiary != null && mapOfSubsidiary.size() > 0 && OwnerSubsNameIdMap != null && OwnerSubsNameIdMap.size() > 0) {
                                        String SubsId = mapOfSubsidiary.get(OwnerSubsNameIdMap.get(opp.ownerId)).Id;
                                        if (!Opp.isClone() && SubsIdPBIdMap != null && SubsIdPBIdMap.size() > 0 && (Opp.recordtypeId==b2b || Opp.recordtypeId==b2c || Opp.recordtypeId==b2cCloseLost)) {
                                            opp.PriceBook2Id = SubsIdPBIdMap.get(mapOfSubsidiary.get(OwnerSubsNameIdMap.get(opp.ownerId)).Id);
                                        }
                                        
                                        if (!Test.isRunningTest()) {
                                            if (Opp.ownerId != null && mapOfUserId.containsKey(Opp.ownerId)) {
                                                opp.User_Sales_Head__c = mapOfUserId.get(Opp.ownerId).Sales_Head__c;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (PGOpportunityTriggerHandler.isownerFirstTime)  {//PGAUTO-2941
                        PGOpportunityTriggerHandler.checkOwnerUpdate(newMap, oldMap);
                        PGOpportunityTriggerHandler.updateOMCRejectedReason(newList, oldMap);
                        PGOpportunityTriggerHandler.restrictB2CStageName(newList,oldMap);
                        PGOpportunityTriggerHandler.isownerFirstTime= false;
                      
                    }
                    PGOpportunityTriggerHandler.validationOnBillingAddress(newList,newMap,oldMap);
                    updateSubsidiary(newList,newMap,oldMap);
                }
            }
           // validateProxyCustomer(newList,oldMap);
        }
     
    }   
  /* AUTOMATION-9240 
   * public static void validateProxyCustomer(List<Opportunity> newList,Map<Id, Opportunity> oldMap){
      String b2b=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
       Set<id> accIds = new Set<Id>(); 
       Map<Id,Set<Id>> childVsParent = new Map<Id,Set<Id>>();
        for(Opportunity Op : newList) {
          accIds.add(op.AccountId);
        }  
        for(Account_Hierarchy__c hierarcy : [Select id,Child_Account__c,Parent_Account__c from Account_Hierarchy__c where Child_Account__c IN : accIds]){
            if(childVsParent.containskey(hierarcy.Child_Account__c)){
             Set<Id> accId = childVsParent.get(hierarcy.Child_Account__c);
             accId.add(hierarcy.Parent_Account__c);  
             childVsParent.put(hierarcy.Child_Account__c,accId);       
           
            }
            else{
               Set<id> accId = new Set<Id>(); 
               accId.add(hierarcy.Parent_Account__c); 
               childVsParent.put(hierarcy.Child_Account__c,accId);       
            
            }
           
        }
      for(Opportunity Op : newList) { 
           Set<Id> parentAccountIds = new Set<Id>();
            if (Op.Proxy_Customer__c <> oldMap.get(Op.id).Proxy_Customer__c && op.recordtypeId==b2b && Op.Proxy_Customer__c!=null) {
               if(childVsParent.containskey(op.accountid)){
                  parentAccountIds = childVsParent.get(op.accountid);
               } 
                if(!parentAccountIds.contains(op.Proxy_Customer__c)){
                    op.adderror('Proxy Customer must be a parent of Opportunity\'s Account');
                }
            } 
        }      
    } */ 

    public static void createQuote(List<Opportunity> newList, Map<Id,Opportunity> newMap){
        if(enabled()){
            String b2c =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
            String b2cCloseLost =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Closed Lost').getRecordTypeId();
            String b2b=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
            if(newList[0].RecordTypeId == b2c && QuoteSyncHandler.isOppFire){
                QuoteSyncHandler.isOppFire = false;
                QuoteSyncHandler.createQuote(newList);
                
            }
        }
        
    }
    
    public static void aftUpdate(List<Opportunity> newList, List<Opportunity> oldList, Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap){
        if(enabled()){
            String b2c =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
            String b2cCloseLost =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Closed Lost').getRecordTypeId();
            String b2b=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
            
            if (!system.isBatch() ) {
                system.debug('PGOpportunityTriggerHandler.isFirstTime'+PGOpportunityTriggerHandler.isFirstTime);
                if(PGOpportunityTriggerHandler.isFirstTime) {
                    if(PGOpportunityTriggerHandler.isFirstTimeSOKill) {
                        PGOpportunityTriggerHandler.killSO(newMap,oldMap);
                        PGOpportunityTriggerHandler.isFirstTimeSOKill=false;
                    }
                    if(System.isFuture() == false && System.isScheduled() == false && System.isQueueable() == false && System.isBatch() == false){
                        PGOpportunityTriggerHandler.updatePrimCampB2B(newList,oldMap);
                    }
                    if ((newList[0].RecordTypeId == b2c || newList[0].RecordTypeId == b2cCloseLost )) {
                        PGOpportunityTriggerHandler.updatePgTenureBonus(newList, oldMap);
                        //to create CampaignInfluence record on the basic of closed Won Opportunity Stage
                        //to change campaign Member status on the basis of Opportunity Stage
                        //To change Task Status to Completed
                        if(PGOpportunityTriggerHandler.isFirstTime){
                            PGOpportunityTriggerHandler.isFirstTime = false;
                            PGOpportunityTriggerHandler.changeCampaignMemberStatus(newList, oldMap);
                            PGOpportunityTriggerHandler.createCampaignInfluenceRecords(newList,oldMap);
                            PGOpportunityTriggerHandler.closeTaskStatus(newList,oldMap);
                        }
                    }
                    
                    //Call Approval process
                    if(newList[0].RecordTypeId.equals(b2b)){
                        PGOpportunityTriggerHandler.submitB2BApproval(newList[0],oldList[0]);
                    }
                    //Update VIP checkbox in Account object
                    PGOpportunityTriggerHandler.updateAgentVIP(newList,oldmap);
                    //Trigger sync to NS
                    List<Updates_On_Closed_Won__e> listOfEvents = new List<Updates_On_Closed_Won__e>();
                    for (Opportunity record: newList) {
                        if (record.Sync_To_NetSuite__c == true && record.StageName == 'Closed Won' && (record.recordtypeId==b2b || record.recordtypeId==b2c)) {
                            //exclude
                            //to update Subscription Activation Date
                            if(record.recordtypeId==b2c){
                                if(
                                    record.StageName != oldMap.get(record.Id).StageName ||
                                    record.Sync_To_NetSuite__c != oldMap.get(record.Id).Sync_To_NetSuite__c
                                ) {
                                    listOfEvents.add(new Updates_On_Closed_Won__e(
                                        Account_Id__c = record.AccountId,
                                        Opportunity_Id__c = record.Id
                                    ));
                                }
                                if(
                                    PGOpportunityTriggerHandler.isFirstNSCall() &&
                                    System.isFuture() == false &&
                                    System.isScheduled() == false &&
                                    System.isQueueable() == false
                                ) {
                                    PGOpportunityTriggerHandler.updateAccountnextSubsDate(oldMap.get(record.id), record);
                                }
                            }
                        }
                    }
                    system.debug('listOfEvents'+listOfEvents);
                    system.debug('isFirstTime'+PGOpportunityTriggerHandler.isFirstTime);
                    system.debug('system.isBatch()'+!system.isBatch());
                    if(!listOfEvents.isEmpty()) {
                        EventBus.publish(listOfEvents);
                    }
                    if ((newList[0].RecordTypeId == b2cCloseLost ||newList[0].RecordTypeId ==b2c )) {
                        PGOpportunityTriggerHandler.setAgentQualifyReferral(oldMap, newList);
                    }
                }
            }
        }
    }
    
    public static Boolean enabled(){
        boolean isEnabled = true;
        //Check trigger execute
        if(!Test.isRunningTest()) {
            Trigger_Execute__c TE = Trigger_Execute__c.getValues('PGOpportunityTrigger');
            isEnabled = TE.Enable_del__c;
        }
        return isEnabled;
    } 
    
    //method called from before insert of Opportunity
    //service method moved from befIns
    private static void applyDefault(List<Opportunity> newList) {
        String b2c =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        String b2cCloseLost =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Closed Lost').getRecordTypeId();
        String b2b=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        String directBooking =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Direct Booking').getRecordTypeId();
        QuoteSyncHandler.isTriggerFire = false;
        Set<Id> accountIdB2C = new Set<id>();
        Set<Id> allAccountId = new Set<id>();
        Map<id,id> accIdVsContactId = new Map<id,id>();
        
        if(PGOpportunityTriggerHandler.isFirstTimeSub) {
            //Set subsidiary & pricebook
            Map<String, Subsidiary__c> mapOfSubsidiary = PGOpportunityTriggerHandler.getSubsidiaryMap();
            Map<Id, String> OwnerSubsNameIdMap = PGOpportunityTriggerHandler.UserIdSubsIdMap();
            Map<Id, Id> SubsIdPBIdMap = PGOpportunityTriggerHandler.SubsidiaryIdPricebookIdMap();
            Set<String> setOfOwnerId = new Set<String>();
            for (Opportunity Opp: newList) {
                if(opp.AccountId != null) {
                    if(opp.RecordTypeId == b2c) {
                        accountIdB2C.add(opp.AccountId);
                    }
                    allAccountId.add(opp.AccountId);
                }
                setOfOwnerId.add(Opp.OwnerId);
            }
            //getting user info of current user and oppty owner
            setOfOwnerId.add(UserInfo.getUserId());
            Map<String, User> mapOfUsers = new Map<String, User>([
                SELECT Id, Profile.Name, Sales_Head__c FROM User WHERE Id IN: setOfOwnerId
            ]);
            //getting the account Info
            Map<String, Account> mapOfAccount = new Map<String, Account>();
            if(!allAccountId.isEmpty()) {
                mapOfAccount = new Map<String, Account>([
                    SELECT Id, Country__c, Subsidiary_Type__c FROM Account WHERE Id IN: allAccountId
                ]);
            }
            for(Opportunity Opp: newList) {
                if(!System.isScheduled() || opp.isBulkUpdate__c) {
                    if(!mapOfSubsidiary.isEmpty() && !OwnerSubsNameIdMap.isEmpty()) {
                        system.debug('OwnerSubsNameIdMap==>'+OwnerSubsNameIdMap);
                        system.debug('OwnerSubsNameIdMap.get(opp.ownerId)==>'+OwnerSubsNameIdMap.get(opp.ownerId));
                        system.debug('mapOfSubsidiary==>'+mapOfSubsidiary);
                        system.debug('mapOfSubsidiary=1=>'+mapOfSubsidiary.get(OwnerSubsNameIdMap.get(opp.ownerId)));
                        String SubsId = mapOfSubsidiary.get(OwnerSubsNameIdMap.get(opp.ownerId)).Id;
                        //For system admin profiles and Integration profile that usually are used during sync, bulk data updates,
                        //oppty creation using scheduled jobs
                        if(
                            mapOfUsers.get(UserInfo.getUserId()).Profile.Name.equals('System Administrator') ||
                            mapOfUsers.get(UserInfo.getUserId()).Profile.Name.equals('Delegated System Administrator')||
                            mapOfUsers.get(UserInfo.getUserId()).Profile.Name.equals('API User Profile')||
                            mapOfUsers.get(UserInfo.getUserId()).Profile.Name.equals('Integration Profile')
                            
                        ) {
                            if(mapOfAccount.containsKey(opp.AccountId) && mapOfAccount.get(opp.AccountId).Country__c != null) {
                                if(mapOfAccount.get(opp.AccountId).Country__c.equals('Singapore')) {
                                    opp.subsidiary__c = mapOfSubsidiary.get(label.SG_SUBSIDIARY_NAME).Id;
                                    opp.currencyIsoCode = 'SGD';
                                }
                                else if(mapOfAccount.get(opp.AccountId).Country__c.equals('Malaysia')) {
                                    opp.currencyIsoCode = 'MYR';
                                    if(
                                        mapOfAccount.get(opp.AccountId).Subsidiary_Type__c != null &&
                                        mapOfAccount.get(opp.AccountId).Subsidiary_Type__c.equals('MPD')
                                    ) {
                                        opp.subsidiary__c = mapOfSubsidiary.get(label.MY_SUBSIDIARY_MPD_NAME).Id;
                                    } else {
                                        System.debug('@@@##'+mapOfSubsidiary);
                                        opp.subsidiary__c = mapOfSubsidiary.get(label.MY_SUBSIDIARY_NAME).Id;
                                        
                                    }
                                    
                                }
                                else if (mapOfAccount.get(opp.AccountId).Country__c.equals('Thailand')) {
                                    if(mapOfSubsidiary.containsKey(label.TH_SUBSIDIARY_NAME_HO) &&
                                       SubsId == mapOfSubsidiary.get(label.TH_SUBSIDIARY_NAME_HO).Id) {
                                           opp.subsidiary__c = mapOfSubsidiary.get(label.TH_SUBSIDIARY_NAME_HO).Id;
                                       } else if(mapOfSubsidiary.containsKey(label.TH_SUBSIDIARY_NAME)){
                                           opp.subsidiary__c = mapOfSubsidiary.get(label.TH_SUBSIDIARY_NAME).Id;
                                       }
                                    opp.currencyIsoCode = 'THB';
                                } 
                                else if (mapOfAccount.get(opp.AccountId).Country__c.equals('Indonesia')) {
                                    opp.subsidiary__c = mapOfSubsidiary.get(label.IDR_SUBSIDIARY_NAME).Id;
                                    opp.currencyIsoCode = 'IDR';
                                }
                                system.debug('????'+opp.Subsidiary_Type__c);
                                    if(opp.Subsidiary_Type__c!= null && opp.Subsidiary_Type__c =='iPP'){
                                     opp.subsidiary__c = mapOfSubsidiary.get(label.MY_SUBSIDIARY_IPP_NAME).Id;  
                                        opp.currencyIsoCode = 'MYR';
                                    }
                            }
                        } else {
                              if(opp.Subsidiary_Type__c!= null && opp.Subsidiary_Type__c =='iPP'){
                                     opp.subsidiary__c = mapOfSubsidiary.get(label.MY_SUBSIDIARY_IPP_NAME).Id;
                                  opp.currencyIsoCode = 'MYR';
                              }else{
                                   opp.subsidiary__c = mapOfSubsidiary.get(OwnerSubsNameIdMap.get(opp.ownerId)).Id;
                            
                              }
                       }
                        if (
                            !Opp.isClone() && !SubsIdPBIdMap.isEmpty() &&
                            (opp.recordtypeId == directBooking ||
                             Opp.recordtypeId==b2b ||
                             Opp.recordtypeId==b2c ||
                             Opp.recordtypeId==b2cCloseLost)
                        ) {
                            opp.PriceBook2Id = SubsIdPBIdMap.get(mapOfSubsidiary.get(OwnerSubsNameIdMap.get(opp.ownerId)).Id);
                        }
                        
                        if (!Test.isRunningTest() && Opp.ownerId != null && mapOfUsers.containsKey(Opp.ownerId)) {
                            opp.User_Sales_Head__c = mapOfUsers.get(Opp.ownerId).Sales_Head__c;
                        }
                    }
                    PGOpportunityTriggerHandler.isFirstTimeSub=false;
                }
            }
        }
        
        if(!accountIdB2C.isEmpty()){
            Set<Id> eligibleContactIds = new Set<Id>();
            for(Account acc: [Select id,PersonContactId from Account where id in : accountIdB2C]){
                accIdVsContactId.put(acc.id, acc.PersonContactId);
            }
            String winbackCampaignIds = System.Label.PG_LABEL_Winback_Campaign_Ids;
            if(String.isNotBlank(winbackCampaignIds)){
                list<string> campaignIds = winbackCampaignIds.split(';');
                List<CampaignMember> cmList = [
                    Select id,ContactId,Status from CampaignMember where
                    (Status = 'Eligible' OR Status = 'Re-eligible') AND
                    CampaignId IN : campaignIds AND
                    ContactId IN : accIdVsContactId.values()
                ];
                for(CampaignMember cam: cmList){
                    eligibleContactIds.add(cam.ContactId);
                }
            }
            for(Opportunity opp : newList){
                if(
                    accountIdB2C.contains(opp.AccountId) &&
                    accIdVsContactId.containsKey(opp.AccountId) &&
                    eligibleContactIds.contains(accIdVsContactId.get(opp.AccountId))
                ){
                    opp.is_Testing__c = true;
                }
            }
        }
    }
    public static void RenewalOpptyPublishEvent(map<Id,Opportunity> newOppMap,map<Id,Opportunity> oldOppMap ){
        
        
        List<Renewal_Self_Serve_Oppty_update_insert__e > listOfEvents = new List<Renewal_Self_Serve_Oppty_update_insert__e >();
        if(oldOppMap != null){
            
            for(Opportunity opp : newOppMap.values() ){
                Opportunity oldOpp = oldOppMap.get(opp.id);
                if(( oldOpp.StageName != 'Pending Online payment' && oldOpp.StageName != 'Pending OMC Approval' && oldOpp.StageName != 'Closed Won') &&
                   (opp.StageName == 'Pending Online payment' || opp.StageName == 'Pending OMC Approval' || opp.StageName == 'Closed Won' ) 
                   && opp.Opportunity_Type__c  == 'B2C - Renewal' && opp.country__c == 'Singapore'){
                       listOfEvents.add(new Renewal_Self_Serve_Oppty_update_insert__e(
                           event__c  = 'ineligible',
                           // Agent_ID__c  = mapOfOppty.get(eachOppLineItme.OpportunityId).Account.PersonContactId,
                           Opportunity_Status__c  = opp.StageName,
                           Opportunity_Id__c = opp.Id
                       ));
                   }
                else if((oldOpp.StageName == 'Pending Online payment'  || oldOpp.StageName == 'Pending OMC Approval')  && opp.Opportunity_Type__c  == 'B2C - Renewal' 
                        && (opp.StageName == 'new'  || opp.StageName == 'proposal') && opp.country__c == 'Singapore'){
                     listOfEvents.add(new Renewal_Self_Serve_Oppty_update_insert__e(
                           event__c  = 'eligible',
                           // Agent_ID__c  = mapOfOppty.get(eachOppLineItme.OpportunityId).Account.PersonContactId,
                           Opportunity_Status__c  = opp.StageName,
                           Opportunity_Id__c = opp.Id
                       ));
                    
                }
            }
        }
        if(!listOfEvents.isEmpty()) {
            system.debug(listOfEvents);
        
            EventBus.publish(listOfEvents);
            system.debug('****EVents published');
        }
    }
    public static void primeCreditPublishEvent(map<Id,Opportunity> newOppMap,map<Id,Opportunity> oldOppMap ){
       // 
        List<String> oppIdList = new List<String>();
        list<Agent_purchase_prime_Credit__e> eventlist = new List<Agent_purchase_prime_Credit__e>();
        for(Opportunity opp : newOppMap.values()){
            Opportunity oldOpp = oldOppMap.get(opp.id);
            system.debug('oldOpp'+oldOpp.StageName);
            system.debug('newOpp'+opp.StageName);
            if(( oldOpp.StageName == 'Pending Online payment') &&  ( opp.StageName != 'Pending Online payment')
               && (opp.StageName =='Closed Won' || opp.StageName == 'Pending OMC Approval')
               && opp.country__c == 'Singapore'){
                   oppIdList.add(opp.id);
               }//if
        }//for
        List<String> contactID = new List<String>();
        if(oppIdList.size()>0){
            for(Opportunity opp : [Select id,account.agentnet_id__c,account.PersonContactID,account.uuid__c,(Select id,
                                                              product2.name,complimentary__c
                                                              from opportunitylineitems where opportunityid in: oppIdList 
                                                              and complimentary__c=false and product2.name like '%Prime Credit%') 
                                   from opportunity where id in: oppIdList]){
                                       if(opp.opportunitylineItems.size()>0){
                                           eventlist.add(new Agent_purchase_prime_Credit__e(
                                               UUid__c = opp.account.uuid__c,
                                               agentNet_id__c = opp.Account.AgentNet_id__c,
                                               Purchase_Time__c = system.now()));
                                           isPrimeCreditFirstTime=false;
                                           contactID.add(opp.Account.PersonContactID);
                                       }
                                   }
            if(!contactID.isEmpty()){
                list<CampaignMember> cmList = [Select id from campaignmember where contactid in: contactID and campaignID =: Label.PCSSCampaignID ];
                for(CampaignMember cm : cmList){
                    cm.status='Revoked';
                   
                }
                update cmList; 
            }
            if(!eventlist.isEmpty()){
                 EventBus.publish(eventlist);
                    system.debug( eventlist);
                    system.debug('published Agent_purchase_prime_Credit__e event');
            }//if
            }//if
    }
    
    public static void updateSubsidiary(List<Opportunity> newList, Map<Id,Opportunity> newOppMap, Map<Id,Opportunity> oldOppMap){
        
        String b2B =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        QuoteSyncHandler.isTriggerFire = false;
     
        Set<Id> allAccountId = new Set<id>();
            
            Map<String, Subsidiary__c> mapOfSubsidiary = PGOpportunityTriggerHandler.getSubsidiaryMap();
            Map<Id, String> OwnerSubsNameIdMap = PGOpportunityTriggerHandler.UserIdSubsIdMap();
            
            System.debug('MapOfSub'+mapOfSubsidiary.size());
            System.debug('MapOfSub'+OwnerSubsNameIdMap.size());
            
            for (Opportunity Opp: newList) {
                if(opp.AccountId != null && opp.RecordTypeId == b2B) {
                    allAccountId.add(opp.AccountId);
                }
            }
           
            //getting the account Info
            Map<String, Account> mapOfAccount = new Map<String, Account>();
            if(!allAccountId.isEmpty()) {
                mapOfAccount = new Map<String, Account>([
                    SELECT Id, Country__c, Subsidiary_Type__c FROM Account WHERE Id IN: allAccountId
                ]);
            }
            for(Opportunity Opp: newList) {
             
                System.debug('@@@Opp:::'+Opp);
                    if(newOppMap.get(Opp.Id).Subsidiary_Type__c != oldOppMap.get(Opp.Id).Subsidiary_Type__c)          
                    {
                        if(mapOfAccount.containsKey(opp.AccountId) && mapOfAccount.get(opp.AccountId).Country__c != null && mapOfAccount.get(opp.AccountId).Country__c.equals('Malaysia')) {
                            if(opp.Subsidiary_Type__c!= null && opp.Subsidiary_Type__c =='iPP') {  
                                opp.subsidiary__c = mapOfSubsidiary.get(label.MY_SUBSIDIARY_IPP_NAME).Id;   
                                
                            } else if(opp.Subsidiary_Type__c!= null && opp.Subsidiary_Type__c =='Property Guru'){
                                  opp.subsidiary__c = mapOfSubsidiary.get(label.MY_SUBSIDIARY_NAME).Id;   
                            }
                           
                        }
                    }
                  
            }
        
    }
    
    // Create Account in iPP Sandbox
    
    public static void createAccountInIPP(List<Opportunity> newList){
        Set<Id> accountIds = new Set<Id>();
        String endPoint;
        String destRecordType;
        String iPP_Sub = System.label.MY_SUBSIDIARY_IPP_NAME;
        String oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        String accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
       
        List<Search_and_tag_admin__c> sdList = new List<Search_and_tag_admin__c> ();
        sdList = [select id, Destination_Object_API__c , Client__c, ClientID__c, Destination_Recordtype_Id__c, 
                  Password__c, UserName__c, EndPoint__c,External_Field__c  , Source_Object_API__c 
                  from Search_and_tag_admin__c  where Source_Object_API__c  ='Account' and Active__c =true and
                  Source_RecordTypeID__c  =: accRectype];
        System.debug('Result%%%'+sdList);
        
        for(Opportunity op: newList){
            accountIds.add(op.AccountId);
         System.debug('**AccId'+op.AccountId);
        }
        
        map<Id,opportunity> oppties = new Map<Id,opportunity>();
        for(Opportunity opp :[Select id, account.B2B_external_Field__c, account.B2B_ipp_REA__c,Account.RecordTypeId,
                              Account.country__c,Account.name
                              From Opportunity Where accountid IN : accountIds]){
          oppties.put(opp.id,opp);  
        }
        
        if(!sdList.isEmpty()){
            
            Search_and_tag_admin__c  sd = sdList[0];
            destRecordType = sd.Destination_Recordtype_Id__c;
            
            endPoint= sd.EndPoint__c+'?grant_type=password&password='+sd.password__c+'&username='+
                +sd.UserName__c+'&client_id='+sd.ClientID__c+
                '&client_secret='+sd.Client__c;
        }
        System.debug('newList'+newList);
        System.debug('OppMap'+oppties);
        
        for(Opportunity opp : newList){
            System.debug('&&&Name'+oppties.get(opp.id).Account.Name);
            System.debug('%%%AccID'+oppties.get(opp.id).Account.Id);
           // System.debug('$$$Acc'+opp.Account.Name);
            System.debug('B2BReA'+oppties.get(opp.id).Account.B2B_ipp_REA__c);
            System.debug('OppSubCode'+opp.Subsidiary_Type__c);
            System.debug('@@@AccCountry'+oppties.get(opp.id).Account.country__c);
            if(opp.RecordTypeId == oppRectype && oppties.get(opp.id).Account.B2B_ipp_REA__c == null && oppties.get(opp.id).Account.RecordTypeId == accRectype 
               && opp.Subsidiary_Code__c == 'iPP' && oppties.get(opp.id).Account.B2B_external_Field__c == null
               ){
                   System.debug(oppties.get(opp.id));
                   Map<String,Object> JSONBody = new Map<String,Object>();
                   String code;
                  // code = '+60';
                  // code +=oppties.get(opp.id).Account.Mobile__c;
                   JSONBody.put('name',oppties.get(opp.id).Account.name);
                   JSONBody.put('Country__c','Malaysia');
                   JSONBody.put('B2B_External_Field__c',opp.AccountId);
                   JSONBody.put('RecordTypeId',destRecordType);
                   //JSONBody.put('BusinessEmail__c',oppties.get(opp.id).Account.email__c);
                  // JSONBody.put('Phone',code);
                   
                   
                   String reqBody = JSON.serialize(JSONBody);
                   createIPPAccount(reqBody,accRectype,endPoint,opp.AccountId);
               }
        }
        
    }
    
    @future (callout=true)
    public static void createIPPAccount(String reqBody,String accRectype,String endPoint,Id acc){
        
        String destRecordType;
        String error = null;
        Map<string,string> reqHeaders = new Map<string,string>();
        HTTPResponse response;
        reqHeaders.put('accept','*/*');
        
        
        if(!test.isRunningTest())
            response = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,endPoint,'','POST',false,false,null,null);
        else{
            response = new HTTPResponse();
            response.setStatusCode(200);
            // response.setBodyAsBlob(body)t
            response.setBody('{"access_token":"SESSION_ID_REMOVED",'+
                             +'"instance_url":"https://propertyguru--sandbox.my.salesforce.com",'+
                             +'"id":"https://test.salesforce.com/id/00D1y0000000ZO2EAM/0051y0000025iQLAAY",'+
                             +'"token_type":"Bearer","issued_at":"1639030881323","signature":"OIy288m89wyRhEGAZb0byh'+
                             +'DzTGJzf9bwK/BWMW/ozao="}');
        }
        if(response.getStatusCode() == 200) { 
            String resBody=response.getBody();
            //  system.debug(response.getBody());
            map<String, object> responseJson = (map<String, object>)JSON.deserializeUntyped(resBody);
            String token=(String) responseJSON.get('access_token');
            Map<String,String> res = new Map<String,String>();
            res.put('token',token);
            res.put('URL',(String) responseJSON.get('instance_url'));
            
            System.debug(res);
            if(!res.isempty()){
                endpoint=res.get('URL')+ '/services/data/v50.0/sobjects/Account/';
                
                reqHeaders.clear();
                //  reqHeaders.put('accept','*/*');
                reqHeaders.put('Authorization','Bearer '+token);
                reqHeaders.put('Content-Type','application/json');
                reqHeaders.put('accept','application/json');
                if(!test.isRunningTest())
                    response = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,endPoint,reqBody,'POST',true,false,
                                                                             null,null);
                else{
                    response = new HTTPResponse();
                    response.setStatusCode(201);
                    response.setBody('{"id":"0068G0000051G1oQAE","success":true,"errors":[]}');
                }
                system.debug('****'+response.getBody());
                if(response.getStatusCode() == 201) { 
                    String resBody2=response.getBody();
                    
                    Map<String,Object> objList = (Map<String,Object>) JSON.deserializeUntyped(resBody2);
                    system.debug(objList.get('id'));
                    list<object> d = new list<Object>();
                    d.add(objList);
                    
                }
                else  if(response.getStatusCode() == 204) { 
                    System.debug('error ');
                }
                else{
                    String resBody1=response.getBody();
                    List<Object> objList = (List<Object>) JSON.deserializeUntyped(resBody1);
                    system.debug(objList);
                    
                    Map<String, Object> obj = (Map<String, Object>)objList[0];
                    system.debug(obj);
                    
                    error = obj.get('errorCode') +': '+obj.get('message');
                    system.debug(obj.get('errorCode') +': '+obj.get('message'));
                }
            }
            
        }
        else{
            System.debug('connection failed' );
            error = 'connection failed';
        }
        if(error!=null){
           Account updateAcc = new Account();
               updateAcc.id = acc;
               updateAcc.iPP_Sync_Error__c = error;
               update updateAcc;
                
            } 
    }
    public static void populateRenewalType (List<Opportunity> newList,Map<Id,Opportunity> oldMap) {
        System.Debug('called###');
    }
}
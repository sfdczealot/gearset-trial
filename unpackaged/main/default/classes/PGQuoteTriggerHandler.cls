//TEST CLASS: PGQuoteTriggerHandler_Test
public class PGQuoteTriggerHandler implements PGTriggerInterface{
    
    
    List<Quote> listQuote = new List<Quote>();
    List<Quote> oldlistQuote = new List<Quote>();
    Map<Id,Quote> triggerOldMap = new Map<Id,Quote>();
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public void beforeInsert(List<sObject> newList) {
        
        for(Sobject quoObj : newList){
            Quote quo = (Quote)quoObj;
            listQuote.add(quo);
        }
        PGQuoteTriggerHandler.assignOpportunityOwner(listQuote);
        PGQuoteTriggerHandler.updateOppFieldsOnQuote(listQuote);
		PGQuoteTriggerHandler.updateQuoteAccount(listQuote);
        listQuote.clear();
    }
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        for(Sobject quoObj : newList){
            Quote quo = (Quote)quoObj;
            listQuote.add(quo);
        }  
        PGQuoteTriggerHandler.updateOppStage(listQuote);
        listQuote.clear();
    }
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        for(Sobject quoObj : newList){
            Quote quo = (Quote)quoObj;
            listQuote.add(quo);
        }  
        
        for(Sobject quoObj : oldMap.values()){
            Quote quo2 = (Quote)quoObj;
            triggerOldMap.put(quo2.Id,quo2);                  
        }
        
        PGQuoteTriggerHandler.updateOMCRejectedReason(listQuote,triggerOldMap);
        PGQuoteTriggerHandler.UpdateSGExpirationDate(listQuote,triggerOldMap);
        PGQuoteTriggerHandler.markUnsyncedQuotesAsInvalid(listQuote,triggerOldMap);
        listQuote.clear();
        triggerOldMap.clear();        
    }
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {        
        
        for(Sobject quoObj : newList){
            Quote quo = (Quote)quoObj;
            listQuote.add(quo);
        }  
        for(Sobject quoObj : oldMap.values()){
            Quote quo2 = (Quote)quoObj;
            triggerOldMap.put(quo2.Id,quo2);                  
        }
        
        Boolean isTrackEnabled = true;
        if(Trigger_Execute__c.getValues('Trigger_Quote')!=null){
            if(Trigger_Execute__c.getValues('Trigger_Quote').IsTrackingEnable__c != null)
                isTrackEnabled = Trigger_Execute__c.getValues('Trigger_Quote').IsTrackingEnable__c;  
        }
        
        If(!System.isBatch() && !System.isFuture() && !System.isQueueable()){
            PGQuoteTriggerHandler.updateQuoteStatus(listQuote,triggerOldMap);          
        }
        PGQuoteTriggerHandler.updateLoyaltyPromotionInQLI(listQuote,triggerOldMap);
        PGQuoteTriggerHandler.recallApprovalProcess(listQuote,triggerOldMap);
        PGQuoteTriggerHandler.changeCampaignMemberStatus(listQuote,triggerOldMap);
        PGQuoteTriggerHandler.closePaymentStatus(listQuote,triggerOldMap);     
        if(isTrackEnabled){
            QuoteHistoryHandler.trackHistory(listQuote, triggerOldMap);//History Tracking
        }
        listQuote.clear();
        triggerOldMap.clear(); 
    }
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {         
    }
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
        for(Sobject quoObj : oldList){
            Quote quo = (Quote)quoObj;
            oldlistQuote.add(quo);
        }  
        
        Boolean isTrackEnabled = true;
        if(Trigger_Execute__c.getValues('Trigger_Quote')!=null){
            if(Trigger_Execute__c.getValues('Trigger_Quote').IsTrackingEnable__c != null)
                isTrackEnabled = Trigger_Execute__c.getValues('Trigger_Quote').IsTrackingEnable__c;  
        }
        if(isTrackEnabled){
            QuoteHistoryHandler.DeletedQuote(oldlistQuote);//History Tracking
        }
        oldlistQuote.clear();        
    }
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {         
    }
    
    //Assign Default opp owner to Quote owner
    public static void assignOpportunityOwner(List<Quote> listAllQuote){
        Set<ID> opportunityID=new Set<ID>();
        Map<ID,Opportunity> mapOfOpportunity=new Map<ID,Opportunity>();
        For(Quote each : listAllQuote){
            If(each.OpportunityId!=null ){
                opportunityID.add(each.OpportunityId); 
            }
        }
        If(opportunityID.size()>0){
            Id B2CrecTypeId=Schema.SObjectType.Quote.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
            mapOfOpportunity=new Map<ID,Opportunity>([select id,ownerId,Account.Account_Rule_Code__c,Account.PersonMobilePhone,Account.PersonEmail,Account.Agency__r.Name,Opportunity_Type__c from Opportunity where ID In :opportunityID]);
            For(Quote each : listAllQuote){
                If(String.isNotBlank(mapOfOpportunity.get(each.OpportunityId).Opportunity_Type__c))
                {	
                    each.RecordTypeId=B2CrecTypeId;
                    each.OwnerId=mapOfOpportunity.get(each.OpportunityId).ownerId;
                    each.Quote_Type__c=mapOfOpportunity.get(each.OpportunityId).Opportunity_Type__c;
                    each.Account_Email__c=mapOfOpportunity.get(each.OpportunityId).Account.PersonEmail;
                    each.Agency_Name__c=mapOfOpportunity.get(each.OpportunityId).Account.Agency__r.Name;
                    each.Account_Phone__c=mapOfOpportunity.get(each.OpportunityId).Account.PersonMobilePhone;
                    each.Account_Rule_Code__c=mapOfOpportunity.get(each.OpportunityId).Account.Account_Rule_Code__c;
                    
                }
            }
        }
        
    }
	
	 // Update Quote's Celigo Account as opportunity's account for PGAUTO-3898 
    public static void updateQuoteAccount(List<Quote> lstQuote){
      
        Set<ID> setOfOpp=new Set<ID>();
         Map<ID,Opportunity> mapOfOpportunity=new Map<ID,Opportunity>();
        For(Quote each : lstQuote){
             setOfOpp.add(each.OpportunityId);
           
        }  
        If(setOfOpp.size()>0){
            
           mapOfOpportunity=PGQuoteOpportunityHelper.getAllOpp(setOfOpp);  
            
        For(Quote each : lstQuote){
           
            Opportunity op=mapOfOpportunity.get(each.OpportunityId); 
            each.Celigo_Account__c = op.accountid;
        }  
        }
    }
    
    //Update Renewal Opportunity Fields on Quote Creation
    public static void updateOppFieldsOnQuote(List<Quote> lstQuote){
        system.debug('-inside UpdateOppFieldsOnQuote-');
        Set<ID> setOfRenewableOpp=new Set<ID>();
        Map<ID,Opportunity> mapOfOpportunity=new Map<ID,Opportunity>();
        For(Quote each : lstQuote){
            system.debug('-each.Quote_Type__c-'+each.Quote_Type__c);
            If(each.Quote_Type__c=='B2C - Renewal'){
                setOfRenewableOpp.add(each.OpportunityId);
            }
        }
        If(setOfRenewableOpp.size()>0){
            mapOfOpportunity=PGQuoteOpportunityHelper.getAllOpp(setOfRenewableOpp);
            For(Quote qu : lstQuote){
                Opportunity op=mapOfOpportunity.get(qu.OpportunityId);
                qu=PGQuoteOpportunityHelper.getQuote(qu, op);
            }
        }
    }
    //Update Opportunity Stage and Synced for Renewable type on creation
    public static void updateOppStage(List<Quote> listAllQuote){
        system.debug('-updateOppStage-');
        Map<Id,Id> opportunityIdVsQuoteId = new Map<Id,Id>();
        Map<Id,Id> finalOppVsQuoteId = new Map<Id,Id>();
        For(Quote each: listAllQuote){
            IF(each.Quote_Type__c=='B2C - Renewal'){
                opportunityIdVsQuoteId.put(each.OpportunityId, each.Id);
            }
        }
        If(opportunityIdVsQuoteId.KeySet().size()>0){
            //TO Sync only First renwal Quote with Opportunity
            List<Opportunity> lstOpp=[select Id,(select Id from Quotes) from Opportunity where Id IN :opportunityIdVsQuoteId.KeySet()];
            For(Opportunity eachOpp:lstOpp){
                IF(eachOpp.Quotes.size()==1){
                    finalOppVsQuoteId.put(eachOpp.Id,opportunityIdVsQuoteId.get(eachOpp.Id));
                }
            }
            DataBase.executeBatch(new SychQuoteOppBatchClass(finalOppVsQuoteId),1);
        }
    }
    
    //Update Opportunity Stage with Quote Status on updation
    public static void updateQuoteStatus(List<Quote> listAllQuote,Map<Id,Quote> mapOldQuote){
        Set<ID> setOfAcceptedQuoteId=new Set<ID>();
        Set<ID> oppToCheck=new Set<ID>();
        Set<ID> allExpiredInvOpp=new Set<ID>();
        Map<ID,Opportunity> mapOfOpportunity=new Map<ID,Opportunity>();
        Map<Id,String> mapOfOppIdVsLossReason = new Map<Id,String>();
        List<Opportunity> lstOppToUpdate=new List<Opportunity>();
        For(Quote each : listAllQuote){
            IF(each.IsSyncing && each.Status!=mapOldQuote.get(each.Id).Status && (each.Status=='Pending Online Payment' || each.Status=='Pending OMC Approval' || each.Status=='Accepted') && String.isNotBlank(each.Quote_Type__c)){
                PGOpportunityTriggerHandler.allowOppstageChange = false;
                Opportunity objOpp=new Opportunity(Id=each.OpportunityId);
                objOpp.StageName=each.Status;
                objOpp.From_Button__c = each.From_Button__c;
                If(each.Status=='Accepted'){
                    objOpp.StageName='Closed Won';
                    objOpp.Approval_Status__c='OMC Approval Approved';
                    objOpp.Sync_To_NetSuite__c=true;
                    //Dynamically assign Opportunity fields from Quote using custom setting
                    Map<String, QuoteOppFliedMapping__c> mapQuoteToOpp = QuoteOppFliedMapping__c.getAll();
                    for(String mapkey : mapQuoteToOpp.keySet()){
                        objOpp.put(mapQuoteToOpp.get(mapkey).opportunityField__c,each.get(mapkey));
                    }       
                    
                    setOfAcceptedQuoteId.add(each.Id);
                }
                lstOppToUpdate.add(objOpp);
            }else IF(each.Status!=mapOldQuote.get(each.Id).Status && (each.Status=='Expired' || each.Status=='Invalid') && String.isNotBlank(each.Quote_Type__c)){
                system.debug('-inside exp inv--');
                // Singapore country check added for PGAUTO-6551
                // Restrict B2C functionality on b2c self serve for PGAAUTO-6925
                 IF(each.IsSyncing && ((each.Quote_Type__c=='B2C - Upgrade' && each.Country__c!= 'Singapore') || 
                                          (each.Quote_Type__c=='B2C - Renewal' ))&& each.loss_reason__c !='Transacted via Self-Serve'){//PGAUTO-1952
                    oppToCheck.add(each.OpportunityId);
                }else {
                    if(each.Quote_Type__c=='B2C - Upgrade' && each.Country__c== 'Singapore') {
                        mapOfOppIdVsLossReason.put(each.OpportunityId,each.Loss_Reason__c);
                    }
                    allExpiredInvOpp.add(each.OpportunityId);
                }               
            }
        }
        IF(oppToCheck.size()>0){
            PGQuoteOpportunityHelper.expireActiveRenUpgQuote(oppToCheck);
        }
        If(allExpiredInvOpp.size()>0){
            //call method
            PGQuoteOpportunityHelper.closeLostOppCondition(allExpiredInvOpp,mapOfOppIdVsLossReason);
        }
        If(lstOppToUpdate.size()>0){
            if(setOfAcceptedQuoteId.size()>0){
                PGQuoteOpportunityHelper.updateQliToOli(setOfAcceptedQuoteId);
            }
            Update lstOppToUpdate;
        }
        
    }
    
    //Recall approval Process when status is changed from proposal to expire PGAUTO-2158
    public static void recallApprovalProcess(List<Quote> listAllQuote,Map<Id,Quote> mapOldQuote){
        Set<Id> setOfRecalledQuoteId=new Set<Id>();
        List<Approval.ProcessWorkitemRequest> workItemsList = new List<Approval.ProcessWorkitemRequest>();
        For(Quote each: listAllQuote){
            IF(each.Status=='Expired' && mapOldQuote.get(each.Id).Status=='Proposal' && String.isNotBlank(each.Quote_Type__c)){
                setOfRecalledQuoteId.add(each.Id);
            }
        }
        If(setOfRecalledQuoteId.size()>0){
            ProcessInstanceWorkitem[] workItems = [SELECT Id
                                                   FROM ProcessInstanceWorkitem 
                                                   WHERE ProcessInstance.TargetObjectId In:setOfRecalledQuoteId
                                                   AND ProcessInstance.Status = 'Pending' ]; 
            for(ProcessInstanceWorkitem eachWordItem: workItems){
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();  
                pwr.setAction('Removed');
                pwr.setWorkItemId(eachWordItem.Id);
                pwr.setComments('Apex Recall Approval.');
                workItemsList.add(pwr);
            }
            Approval.process(workItemsList,false);
        }
    }
    //change Campaign Member Status according to Quote staus change
    public static void changeCampaignMemberStatus(List<Quote> quoteList,Map<Id,Quote> oldMap){
        system.debug('---quoteList--->>> '+quoteList);
        Map<Id,set<Id>> quoteIdsVsPromoMechanics = new Map<Id,set<Id>>();
        Set<Id> promoMechanicIds = new Set<Id>();
        Set<String> quoteIdsList = new Set<String>();
        map<id,id> pmIdVsCampId = new map<id,id>();
        map<id,List<CampaignMember>> cmpVsCampaignMember = new map<id,List<CampaignMember>>();
        set<id> allContactIds = new set<id>();
        for(Quote quo : quoteList){
            if(String.isNotBlank(quo.Quote_Type__c))
                quoteIdsList.add(quo.Id);
            system.debug('><><'+quo.Status+'    '+oldMap.get(quo.id).Status);
        }
        if(quoteIdsList.isEmpty())
            return;
        List<Quote> queryQuoteList = [Select Id,Status,Approval_Status__c,AccountId,Account.personcontactId from Quote where Id In : quoteIdsList];
        for(QuoteLineItem qli : [SELECT Id, QuoteId, Quote.Account.PersonContactId,Promo_Mechanic_Id__c FROM QuoteLineItem where QuoteId In : quoteIdsList order by QuoteId]){
            
            allContactIds.add(qli.Quote.Account.PersonContactId);
            if(String.isNotBlank(qli.Promo_Mechanic_Id__c)){
                
                set<Id> pmIds = new set<Id>();
                if(qli.Promo_Mechanic_Id__c.contains(',')){
                    list<Id> splitPMs = qli.Promo_Mechanic_Id__c.split(',');
                    pmIds.addAll(splitPMs);
                    if(quoteIdsVsPromoMechanics.containsKey(qli.QuoteId)){
                        quoteIdsVsPromoMechanics.get(qli.QuoteId).addAll(pmIds);
                    }else{
                        quoteIdsVsPromoMechanics.put(qli.QuoteId,pmIds);
                    }
                }else{
                    pmIds.add(qli.Promo_Mechanic_Id__c);
                    if(quoteIdsVsPromoMechanics.containsKey(qli.QuoteId)){
                        quoteIdsVsPromoMechanics.get(qli.QuoteId).addAll(pmIds);
                    }else{
                        quoteIdsVsPromoMechanics.put(qli.QuoteId,pmIds);
                    }
                    
                }
                promoMechanicIds.addAll(pmIds);
            }
        }
        if(!promoMechanicIds.isEmpty()){
            List<Promo_Mechanic__c> promoMechanicList = [SELECT Id,Discount_Reason__c, Name,Campaign_Eligibility__c,Campaign_Eligibility__r.Campaign__c,Campaign_Eligibility__r.Campaign__r.EndDate,Campaign_Eligibility__r.Campaign__r.isActive,Campaign_Eligibility__r.Campaign__r.ParentId FROM Promo_Mechanic__c where Id In : promoMechanicIds];
            for(Promo_Mechanic__c pm : promoMechanicList){
                if(String.isNotBlank(pm.Discount_Reason__c) && (pm.Discount_Reason__c.containsIgnoreCase('VIP') || pm.Discount_Reason__c.containsIgnoreCase('Renewal')) ){
                    if(String.isNotBlank(pm.Campaign_Eligibility__r.Campaign__r.ParentId))
                        pmIdVsCampId.put(pm.id, pm.Campaign_Eligibility__r.Campaign__r.ParentId);
                }else{
                    if(String.isNotBlank(pm.Campaign_Eligibility__r.Campaign__c))
                        pmIdVsCampId.put(pm.id, pm.Campaign_Eligibility__r.Campaign__c);
                }
                
            }  
        }
        
        if(!pmIdVsCampId.isEmpty()){
            list<Campaign> campaignList = [Select id, (SELECT Id, CampaignId,Campaign.Name,Campaign.isActive,Campaign.EndDate, Status,ContactId FROM CampaignMembers where ContactId in : allContactIds limit 50000) from Campaign where id In : pmIdVsCampId.values() limit 50000];
            for(Campaign cmp : campaignList){
                cmpVsCampaignMember.put(cmp.id,cmp.CampaignMembers);
            }
        }
        
        list<CampaignMember> updateCampaignMemberList = new list<CampaignMember>();
        Set<CampaignMember> SetToupdateCampaignMemberList = new Set<CampaignMember>();
        for(Quote quo : queryQuoteList){
            
            list<CampaignMember> CampaignMemberList = new list<CampaignMember>();
            Set<Id> pmIds = quoteIdsVsPromoMechanics.get(quo.id);
            if(pmIds != null && !pmIds.isEmpty()){
                for(string pmId :pmIds){
                    Id campaignId;
                    if(pmId != null){
                        campaignId = pmIdVsCampId.get(pmId);
                    }
                    if(campaignId != null) 
                        CampaignMemberList.addAll(cmpVsCampaignMember.get(campaignId));
                    
                }
            }
            
            
            for(CampaignMember cmp : CampaignMemberList){
                if(cmp.ContactId == quo.Account.PersonContactId){
                    
                    if(oldMap.get(quo.Id).Status == 'Proposal' && quo.Status == 'Pending Online Payment'){
                        if(cmp.Campaign.isActive == true){
                            cmp.Status = 'Responded';
                        }else if(cmp.Campaign.isActive == false && quo.Approval_Status__c == 'Discount Approval Approved'){
                            cmp.Status = 'Responded';
                            quo.AddError('ready for payment action should fail since Sales Person has missed the deadline to apply the promo');
                        }
                        SetToupdateCampaignMemberList.add(cmp);
                    }else if(oldMap.get(quo.Id).Status != quo.Status && quo.Status == 'Accepted'){
                        cmp.Status = 'Utilised';
                        SetToupdateCampaignMemberList.add(cmp);
                    }else if(oldMap.get(quo.Id).Status != quo.Status && quo.Status == 'Invalid'){
                        if(cmp.Campaign.isActive == true){
                            cmp.Status = 'Re-eligible';
                        }else if(cmp.Campaign.isActive == false){
                            cmp.Status = 'Expired';
                        }
                        SetToupdateCampaignMemberList.add(cmp);
                    }
                }    
            }
        }
        updateCampaignMemberList.addAll(SetToupdateCampaignMemberList);
        if(!updateCampaignMemberList.isEmpty())
            update updateCampaignMemberList;
    }
    
    public static void closePaymentStatus(list<Quote> quoteList, map<id,Quote> oldMap){
        
        set<id> quoteIds = new set<id>();   
        for(Quote quo : quoteList){
            if(String.isNotBlank(quo.Quote_Type__c) && ((quo.Status == 'Invalid' && oldMap.get(quo.id).Status == 'Pending online Payment') || (quo.Status == 'Expired'))){
                quoteIds.add(quo.id);            
            }else if(String.isNotBlank(quo.Quote_Type__c) && !quo.IsSyncing && oldMap.get(quo.id).IsSyncing && ((quo.Status == 'Pending Online Payment' && quo.Agent_Accepted_Time__c==null) || (quo.Status=='Pending OMC Approval' && (quo.Approval_Status__c=='OMC Approval Recalled' || quo.Approval_Status__c=='OMC Approval Rejected' ))  )){
                quoteIds.add(quo.id);
            }
                        
        }
        if(!quoteIds.isEmpty()){
            system.enqueueJob(new PGClosedWonToClosedLostQueue(quoteIds));
        }
    }
    
     /**
    *  Method to mark unsynced Quotes as Invalid after being rejected
    *  @param  List,Map
    *  @return 
    *  @reference PGAUTO-6551
    */
    public static void markUnsyncedQuotesAsInvalid(list<Quote> quoteList, map<id,Quote> oldMap) {
        Set<Id> unsyncedQuoteIds = new Set<Id>();
        for(Quote quo: quoteList) {
            if(quo.Quote_Type__c == 'B2C - Upgrade' &&
               quo.Country__c == 'Singapore' &&
               !quo.IsSyncing &&
               oldMap.get(quo.id).IsSyncing &&
               quo.Status=='Pending OMC Approval' &&
               quo.Approval_Status__c=='OMC Approval Rejected') {
                   unsyncedQuoteIds.add(quo.Id);
               }
            if(!unsyncedQuoteIds.isEmpty()) {
                quo.Status = 'Invalid';
                quo.Loss_Reason__c = 'Expired Offer';
            }
        }
    }
    
    //PGAUTO-5138
    public static void UpdateSGExpirationDate(list<Quote> quoteList, map<id,Quote> oldMap){
        
        Set<id> quoteId = new Set<id>();
        Map<Id,datetime> quoteToOpptyCloseDate = new Map<Id,datetime>();
        for(Quote quo : quoteList){
            if(quo.Payment_Link__c != null && oldMap.get(quo.Id).Payment_Link__c != quo.Payment_Link__c){
                quoteId.add(quo.id);   
            }   
        }
        if(!quoteId.isEmpty()) {
            for(Quote quo : [Select id, opportunity.closedate from quote where id IN :quoteId ]){
                DateTime oppClosedDate = datetime.newInstance(
                    quo.Opportunity.CloseDate.year(), 
                    quo.Opportunity.CloseDate.month(), 
                    quo.Opportunity.CloseDate.day(), 
                    23, 59, 59
                );
                quoteToOpptyCloseDate.put(quo.id, oppClosedDate);
            }
            for(Quote quo : quoteList){
                if(quo.Country__c=='Singapore' && quo.Quote_Type__c =='B2C - Renewal'){
                    quo.SG_Payment_Link_Expiry__c = quoteToOpptyCloseDate.get(quo.id);
                    if(((quo.Status == 'Invalid' && oldMap.get(quo.id).Status != 'Invalid') || (quo.Status == 'Expired' && oldMap.get(quo.id).Status != 'Expired'))){
                        quo.SG_Payment_Link_Expiry__c = System.today();  
                    }   
                }      
            }
        }
    }
    //Update Loyalty Discount on QLI when PG Tenure is updated on Quote
    public static void updateLoyaltyPromotionInQLI(List<Quote> listQuote, map<Id, Quote> mapQuoteOld) {
        list<Id> listQuoteId = new list<Id>();
        for (Quote row: listQuote) {
            system.debug('row.PG_Tenure__c:'+row.PG_Tenure__c);
            system.debug('mapQuoteOld.get(row.Id).PG_Tenure__c:'+mapQuoteOld.get(row.Id).PG_Tenure__c);
            if (row.PG_Tenure__c!=null && String.isNotBlank(row.Quote_Type__c) && row.Status=='Proposal' && (string.isBlank(row.Approval_Status__c) || row.Approval_Status__c=='Discount Approval Rejected') && row.PG_Tenure__c != mapQuoteOld.get(row.Id).PG_Tenure__c) {
                listQuoteId.add(row.Id);
            }
        }
        if (listQuoteId.size()>0) {
            map<string, set<decimal>> mapCountryTenure = new map<string, set<decimal>>();
            set<decimal> setTenure;
            list<decimal> listTenure;
            list<string> listCriteria = new list<string>();
            string stringTenure;
            integer idx = 0;
            map<string, list<integer>> mapOfQuoteIdx = new map<string, list<integer>>();
            list<integer> listOfQuoteIdx;
            list<QuoteLineItem> listQuoteLineItem = [select Id, Quote.PG_Tenure__c, Quote.Country__c, Discount__c from QuoteLineItem where QuoteId in :listQuoteId and Discount_Reason__c='Loyalty Discount'];
            
            if(listQuoteLineItem.size() > 0) {
                // Using Country + PG_Tenure as the index of mapOfQuoteIdx
                for (QuoteLineItem row: listQuoteLineItem) {
                    setTenure = new set<decimal>();
                    listOfQuoteIdx = new list<integer>();
                    if (mapCountryTenure.keySet().contains(row.Quote.Country__c)) {
                        setTenure = mapCountryTenure.get(row.Quote.Country__c);
                        listOfQuoteIdx = mapOfQuoteIdx.get(row.Quote.Country__c+string.valueOf(row.Quote.PG_Tenure__c));
                    }
                    setTenure.add(row.Quote.PG_Tenure__c);
                    mapCountryTenure.put(row.Quote.Country__c, setTenure);
                    listOfQuoteIdx.add(idx);
                    mapOfQuoteIdx.put(row.Quote.Country__c+string.valueOf(row.Quote.PG_Tenure__c), listOfQuoteIdx);
                    idx++;
                }
                
                for (string row: mapCountryTenure.keySet()) {
                    listTenure = new list<decimal>(setTenure);
                    stringTenure = string.join(listTenure, ',');
                    listCriteria.add('(Campaign__r.Country__c =\''+row+'\' and PG_Tenure__c in ('+stringTenure+'))');
                }
                system.debug(listCriteria);
                list<Loyalty__c> listLoyalty = database.query('select Name, Campaign__c, Campaign__r.Name, Campaign__r.Country__c, Discount_Percentage__c, PG_Tenure__c from Loyalty__c where Campaign__r.IsActive=true and '+(listCriteria.size()>1?'('+string.join(listCriteria, ' or ')+')':listCriteria[0]));
                if(listLoyalty.size() > 0) {
                    for (Loyalty__c row: listLoyalty) {
                        // Using Country + PG_Tenure as the index of mapOfQuoteIdx
                        if (mapOfQuoteIdx.keySet().contains(row.Campaign__r.Country__c+string.valueOf(row.PG_Tenure__c))) {
                            for (integer quoteLineIdx: mapOfQuoteIdx.get(row.Campaign__r.Country__c+string.valueOf(row.PG_Tenure__c))) {
                                listQuoteLineItem.get(quoteLineIdx).Discount__c = row.Discount_Percentage__c;
                            }
                        }
                    }
                    update listQuoteLineItem;
                }
                
            }
        }
    }
    
    //Update Omc rejected Reason on Quote
    public static void updateOMCRejectedReason (List<Quote> NewQuoteList, Map<Id, Quote> oldMapQuote) {
        system.debug('--inside updateOMCRejectedReason--');
        Map<Id,String> OppRejectReason = new Map<Id,String>();
        Set<Id> setOfRejectedQuoteId= new Set<Id>();
        List<Opportunity> oppToUpdateReason=new List<Opportunity>();
        for(Quote each : NewQuoteList){
            if (String.isNotBlank(each.Quote_Type__c) && each.Approval_Status__C <> oldMapQuote.get(each.id).Approval_Status__c && each.Approval_Status__C == 'OMC Approval Rejected' ) {
                setOfRejectedQuoteId.add(each.Id);
            } 
            
        }
        If(setOfRejectedQuoteId.size()>0){
            for (ProcessInstanceStep rowApproval : [SELECT ProcessInstance.TargetObjectId, StepStatus, comments  
                                                    FROM ProcessInstanceStep 
                                                    WHERE ProcessInstance.TargetObjectId IN:setOfRejectedQuoteId 
                                                    AND stepStatus='Rejected' order by CreatedDate desc limit 1]) {
                                                        OppRejectReason.put(rowApproval.ProcessInstance.TargetObjectId,rowApproval.comments);
                                                    }           
        }
        for(Quote each : NewQuoteList) {
            system.debug('handleOMCRejectReason !!'); 
            if (String.isNotBlank(each.Quote_Type__c) && each.Approval_Status__C <> oldMapQuote.get(each.id).Approval_Status__c && each.Approval_Status__C == 'OMC Approval Rejected' ) {
                each.OMC_Rejected_Reason__c = OppRejectReason.get(each.Id);
                Opportunity objOpp=new Opportunity(Id=each.OpportunityId,OMC_Rejected_Reason__c=OppRejectReason.get(each.Id));
                oppToUpdateReason.add(objOpp);
            } 
            
        } 
        If(oppToUpdateReason.size()>0){
            Update oppToUpdateReason;
        }
        
        
    }
    
    
}
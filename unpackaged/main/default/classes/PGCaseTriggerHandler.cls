// Test Class: PGCaseTriggerHandler_Test
public class PGCaseTriggerHandler implements PGTriggerInterface {
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public void beforeInsert(List<sObject> newList) {
        identifySpamEmail((List<Case>) newList);
        updateCase((List<Case>) newList);
    }
    
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        updateRelatedContact((List<Case>) newList, (Map<Id,Case>) oldMap);
        changeCampaignMemberStatus((List<Case>) newList,(Map<Id,Case>)newMap,(Map<Id,Case>) oldMap);
        updateCase((List<Case>) newList);
    }
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        
    }
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) { 
        
    }
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
        
    }

    /**
    *  Method to add the contact on the Case for agent type account
    *  @params trigger new list, old map of case
    *  @return Void
    *  @reference PGAUTO-5994
    */
    private static void updateRelatedContact(List<Case> triggerNew, Map<Id,Case> oldMap) {
        Map<Id, Id> mapAccountIds = new Map<Id, Id>();
        for(Case eachCase : triggerNew) {
            if(
                eachCase.AccountId != null &&
                eachCase.Type != null && eachCase.Type.equalsIgnoreCase('Campaign Support') &&
                eachCase.Case_Sub_Category__c != null && !eachCase.Case_Sub_Category__c.equalsIgnoreCase('Others') &&
                eachCase.Resolution__c != null && eachCase.Resolution__c != oldMap.get(eachCase.Id).Resolution__c && 
                eachCase.Resolution__c.equalsIgnoreCase('Resolved')
            ) {
                mapAccountIds.put(eachCase.Id, eachCase.AccountId);
            }
        }
        if(!mapAccountIds.isEmpty()) {
            Map<String, Account> mapOfPersonAccount = new Map<String, Account>([
                SELECT Id, PersonContactId
                FROM Account
                WHERE Id IN: mapAccountIds.values()
                AND isPersonAccount = true
            ]);
            for(Case eachCase : triggerNew) {
                if(mapAccountIds.containsKey(eachCase.Id) && mapOfPersonAccount.containsKey(eachCase.AccountId)) {
                    eachCase.contactId = mapOfPersonAccount.get(eachCase.AccountId).PersonContactId;
                }
            }
        }
    }
    
    /**
    *  Method to add/update Campaign Member
    *  @param  List,Map,Map
    *  @return 
    *  @reference PGAUTO-5601
    */
    private static void changeCampaignMemberStatus(List<Case> newListOfCase,Map<Id,Case> newMapOfCase,Map<Id,Case> oldMapOfCase) {
        Set<Id> caseRecords = new Set<Id> ();
        Map<Id,Id> mapOfCaseIdVsCampaign = new Map<Id,Id>();
        Map<Id,Id> mapOfCaseIdVsContactId = new Map<Id,Id>();
        Map<Id,CampaignMember> mapOfContactIdVsCampMem = new Map<Id,CampaignMember>();
        Map<String,String> mapOfConCampIdVsMsg = new Map<String,String>();
        Map<Id,CampaignMember> mapOfCMIdVsCM = new Map<Id,CampaignMember>();
        String errMsgOnAddingCM = System.Label.CASE_ERROR_ADD_CAMPMEMBER;
        String errMsgOnUpdatingCM = System.Label.CASE_ERROR_UPD_CAMPMEMBER;
        List<CampaignMember> CMList = new List<CampaignMember>();
        for(Case cs : newListOfCase) {
            if(cs.Type != null &&
               cs.Type.equalsIgnoreCase('Campaign Support') &&
               cs.Case_Sub_Category__c != null &&
               !cs.Case_Sub_Category__c.equalsIgnoreCase('Others') &&
               cs.Resolution__c != null &&
               cs.Resolution__c != oldMapOfCase.get(cs.Id).Resolution__c && 
               cs.Resolution__c.equalsIgnoreCase('Resolved')
              ) {
                  caseRecords.add(cs.Id);
                  if(cs.Campaign_Name__c!=null) {
                      mapOfCaseIdVsCampaign.put(cs.Id,cs.Campaign_Name__c);
                  }
                  if(cs.ContactId != null) {
                      mapOfCaseIdVsContactId.put(cs.Id,cs.ContactId);
                  }
              }
        }
        
        if(!mapOfCaseIdVsCampaign.isEmpty() && !mapOfCaseIdVsContactId.isEmpty()) {
            for(CampaignMember campMember : [Select Id,Status, 
                                             CampaignId,ContactId
                                             From CampaignMember
                                             Where CampaignId In:mapOfCaseIdVsCampaign.values()
                                             And ContactId In: mapOfCaseIdVsContactId.values()]
               ) {
                   if(campMember.ContactId != null) {
                       mapOfContactIdVsCampMem.put(campMember.ContactId,campMember);
                       mapOfCMIdVsCM.put(campMember.Id,campMember);
                   }
               }
        }
        
        for(Case caseObj : newListOfCase) {
            if(caseRecords.contains(caseObj.Id)){
                if(caseObj.Case_Sub_Category__c.equalsIgnoreCase('Add Campaign Member')) {
                    if(!mapOfContactIdVsCampMem.isEmpty() &&
                       mapOfContactIdVsCampMem.containsKey(caseObj.ContactId) &&
                       mapOfContactIdVsCampMem.get(caseObj.ContactId)!=null &&
                       mapOfContactIdVsCampMem.get(caseObj.ContactId).CampaignId == caseObj.Campaign_Name__c
                      ) {
                          caseObj.addError(errMsgOnAddingCM);
                      } else {
                          CampaignMember campMember = new CampaignMember();
                          campMember.ContactId = caseObj.ContactId;
                          campMember.CampaignId = caseObj.Campaign_Name__c;
                          campMember.Status = 'Eligible';
                          CMList.add(campMember);
                      }
                } else if(caseObj.Case_Sub_Category__c.equalsIgnoreCase('Reinstate Campaign Member')) {
                    if(!mapOfContactIdVsCampMem.isEmpty() &&
                       mapOfContactIdVsCampMem.containsKey(caseObj.ContactId) &&
                       mapOfContactIdVsCampMem.get(caseObj.ContactId)!=null &&
                       mapOfContactIdVsCampMem.get(caseObj.ContactId).CampaignId == caseObj.Campaign_Name__c
                      ) {
                          if(mapOfContactIdVsCampMem.get(caseObj.ContactId).Status != 'Re-eligible'
                            ) {
                                CampaignMember campMember = new CampaignMember();
                                campMember.Id = mapOfContactIdVsCampMem.get(caseObj.ContactId).Id;
                                campMember.Status = 'Re-eligible';
                                CMList.add(campMember);
                            }
                      } else {
                          caseObj.addError(errMsgOnUpdatingCM); 
                      }
                } else if(caseObj.Case_Sub_Category__c.equalsIgnoreCase('Revoke Campaign Member')) {
                    if(!mapOfContactIdVsCampMem.isEmpty() &&
                       mapOfContactIdVsCampMem.containsKey(caseObj.ContactId) &&
                       mapOfContactIdVsCampMem.get(caseObj.ContactId)!=null &&
                       mapOfContactIdVsCampMem.get(caseObj.ContactId).CampaignId == caseObj.Campaign_Name__c
                      ) {
                          if(mapOfContactIdVsCampMem.get(caseObj.ContactId).Status != 'Revoked'
                            ) {
                                CampaignMember campMember = new CampaignMember();
                                campMember.Id = mapOfContactIdVsCampMem.get(caseObj.ContactId).Id; 
                                campMember.Status = 'Revoked';
                                CMList.add(campMember);
                            }
                      } else {
                          caseObj.addError(errMsgOnUpdatingCM); 
                      }
                }
            }
        }
        
        if(!CMList.isEmpty()) {
            PGCampMemberTriggerHandler.Bypass = true;
            Database.upsertResult[] upsertResults = Database.upsert(CMList,false);
            for(Integer i=0;i< upsertResults.size();i++){
                String campId = '' ;
                if (upsertResults.get(i).isSuccess()){
                    if(CMList.get(i).ContactId != null && CMList.get(i).CampaignId != null) {
                        campId =  CMList.get(i).CampaignId;  
                        mapOfConCampIdVsMsg.put(CMList.get(i).ContactId + campId,'Success');
                        
                    } else if(!mapOfCMIdVsCM.isEmpty() && mapOfCMIdVsCM.containsKey(CMList.get(i).Id)) {
                        campId = mapOfCMIdVsCM.get(CMList.get(i).Id).CampaignId;  
                        mapOfConCampIdVsMsg.put(mapOfCMIdVsCM.get(CMList.get(i).Id).ContactId + campId,'Success'); 
                    }
                    
                }else if (!upsertResults.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = upsertResults.get(i).getErrors().get(0);
                    if(CMList.get(i).ContactId != null && CMList.get(i).CampaignId != null) {
                        campId = CMList.get(i).CampaignId;  
                        mapOfConCampIdVsMsg.put(CMList.get(i).ContactId + campId,error.getMessage());//failed records from the list
                        
                    } else if(!mapOfCMIdVsCM.isEmpty() && mapOfCMIdVsCM.containsKey(CMList.get(i).Id)){
                        campId = mapOfCMIdVsCM.get(CMList.get(i).Id).CampaignId;
                        mapOfConCampIdVsMsg.put(mapOfCMIdVsCM.get(CMList.get(i).Id).ContactId + campId,error.getMessage()); 
                    }
                }
                
            }
        }
        
        if(!mapOfConCampIdVsMsg.isEmpty()) {
            String successMsg = System.Label.CASE_SUCCESS_UPSERT_CAMPMEMBER;
            for(Case caseObj : newListOfCase) {
                String campIdOfCase = '';
                campIdOfCase = caseObj.Campaign_Name__c;
                if(mapOfConCampIdVsMsg.containsKey(caseObj.ContactId + campIdOfCase)) {
                    if(mapOfConCampIdVsMsg.get(caseObj.ContactId + campIdOfCase) == 'Success') {
                        caseObj.Status = 'Closed';    
                        caseObj.Campaign_Action_Message__c = successMsg + ' ' + caseObj.Case_Sub_Category__c;
                    } else {
                        caseObj.Campaign_Action_Message__c = mapOfConCampIdVsMsg.get(caseObj.ContactId + campIdOfCase);
                    }
                }
            }
        }
    }
    
    /**
*  Method to update account on Case if account is null but opp is not null
*  @params trigger new list
*  @return Void
*  @reference PGAUTO-6112
*/
    private static void updateCase(List<Case> newListOfCase) {
        String salesEnablementRecTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales_Enablement').getRecordTypeId();
        Map<Id,Case> mapOfOppIdVsCase = new Map<Id,Case>();
        for(Case caseObj : newListOfCase) {
            if(caseObj.AccountId == null && 
               caseObj.Opportunity__c!= null && 
               caseObj.recordTypeId == salesEnablementRecTypeId) {
                   mapOfOppIdVsCase.put(caseObj.Opportunity__c,caseObj);
               }
        }
        
        if(!mapOfOppIdVsCase.isEmpty()) {
            for(Opportunity opp: [SELECT Id, AccountId 
                                  FROM Opportunity 
                                  WHERE Id In: mapOfOppIdVsCase.keySet() 
                                  And AccountId!=null]
               ) {
                   if(mapOfOppIdVsCase.containsKey(opp.Id)) {
                       mapOfOppIdVsCase.get(opp.Id).AccountId = opp.AccountId;
                   }
               }
        }
    }
    /**
    *  Method to close case generated from spam email and updating case status,category,owner and sub category
    *  @params trigger new list
    *  @return Void
    *  @reference PGAUTO-6228
    */
    private static void identifySpamEmail(List<Case> newList){
        Map<String,Spam_Email_List__c> spamEmails = Spam_Email_List__c.getAll();
        List<Group> queueForOwner = [
            SELECT Id, Name 
            FROM Group 
            WHERE Type = 'Queue' 
            AND Name =:System.Label.LABEL_TO_STORE_QUEUE
        ];
        for(Case caseObj:newList){
            if(
                caseObj.Origin == 'Email' && 
                (!String.isBlank(caseObj.SuppliedEmail)) && 
                spamEmails.containsKey(caseObj.SuppliedEmail)
            ) {
                caseObj.Status = 'Closed';
                caseObj.Type = 'Others';
                caseObj.Case_Sub_Category__c = 'Spam';
                if(!queueForOwner.isEmpty()) {
                    caseObj.OwnerId = queueForOwner[0].Id;
                }
            }
        }
    }
}
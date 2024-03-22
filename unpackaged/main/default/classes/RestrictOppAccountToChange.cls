public class RestrictOppAccountToChange extends CS_ProcessBase{
    
    public static Boolean isExecuted = false;
    @TestVisible 
    Map<Id, Opportunity> applicableObjects;
    
    @TestVisible
    Map<Id, Opportunity> oldOpps;
    @TestVisible
    Map<Id, Opportunity> newOpps;  
    @TestVisible
    Set<String> accountIdList;  
    @TestVisible
    Set<String> contactIdList;
    
    public RestrictOppAccountToChange(Map<Id, Opportunity> oldOpps,Map<Id, Opportunity> newOpps) {
        super(CS_ProcessDefinition.UPDATE_OPPORTUNITY_ACCOUNT, 'CS_P_OpportunityNameChange');
        applicableObjects = new Map<Id, Opportunity>();
        this.oldOpps = oldOpps; 
        this.newOpps = newOpps; 
        accountIdList = new Set<String>();
        contactIdList = new Set<String>();
        isExecuted = true;
    }
    public override void isRecordEligible(SObject obj) {  
        Opportunity newOpp = (Opportunity) obj;
        Opportunity oldOpp ;
        if(trigger.isInsert){
            applicableObjects.put(newOpp.Id, newOpp);
            accountIdList.add(newOpp.AccountID);
            //accountIdList.add(oldOpp.AccountID);
            accountIdList.add(newOpp.Billing_entity__c);
            contactIdList.add(newOpp.b2b_Billing_Contact__c);
            // accountIdList.add(oldOpp.Billing_entity__c);
        } else if(trigger.isUpdate){
            oldOpp = oldOpps.get(newOpp.Id);
            if(oldOpp.AccountID !=  newOpp.AccountID || oldOpp.Billing_entity__c !=  newOpp.Billing_entity__c){
                applicableObjects.put(newOpp.Id, newOpp);
                accountIdList.add(newOpp.AccountID);
                accountIdList.add(oldOpp.AccountID);

                accountIdList.add(newOpp.Billing_entity__c);
                accountIdList.add(oldOpp.Billing_entity__c);
                
            }
            if(oldOpp.b2b_Billing_Contact__c !=  newOpp.b2b_Billing_Contact__c ){
                 applicableObjects.put(newOpp.Id, newOpp);
                contactIdList.add(newOpp.b2b_Billing_Contact__c);
                contactIdList.add(oldOpp.b2b_Billing_Contact__c);  
            }
        }
        
        this.runProcess = !applicableObjects.isEmpty();
    }
    public override void logic() {
        Map<Id,Account> accMap = new Map<Id,Account>([Select Id, Country__c,inactive__c From account Where id in: accountIdList]);
        Map<Id,Contact> contactMap = new Map<Id,Contact>([Select Id, accountid,inactive__c From Contact Where id in: contactIdList]);
        for(String oppID : applicableObjects.keySet()){
            Opportunity opp = applicableObjects.get(oppID);
            if(Trigger.isUpdate){
               
                
                Opportunity old = oldOpps.get(oppID);
                System.debug('&&&OPP'+opp);
                System.debug('+++oldOpp'+old);
                if(opp.stageName == 'Closed Won'){
                    applicableObjects.get(oppID).addError('Opportunity is already Closed');
                    return;                
                }
                if(opp.AccountID !=  old.AccountID ){
                    if(accMap.get(opp.AccountID).Country__c != accMap.get(old.AccountID).Country__c){
                        applicableObjects.get(oppID).addError('You can only change the Account within same country.');
                        return;
                    }
                      if(opp.AccountID != null ){
                    if(accMap.get(opp.AccountID).inactive__c){
                        applicableObjects.get(oppID).addError('You can only change to active account');
                        return;
                    }
                      }
                    
                    Boolean isAllowed = Print_ContractV2_cc.getChildHierarchy(opp.AccountID,
                                                                              old.AccountID);
                    if(!isAllowed){
                        applicableObjects.get(oppID).addError('You can only change the Account within Account hierarchy.');
                        return;
                    }
                }
                if(opp.Billing_entity__c !=  old.Billing_entity__c ){
                    if(opp.Billing_entity__c != null ){
                        if(accMap.get(opp.Billing_entity__c).inactive__c){
                            applicableObjects.get(oppID).addError('You can only change to active Billing Entity');
                            return;
                        }
                    }
                    Boolean isAllowed = Print_ContractV2_cc.getChildHierarchy(opp.Billing_entity__c,
                                                                              opp.Accountid);
                    if(!isAllowed){
                        applicableObjects.get(oppID).addError('You can only change the Billing Entity within hierarchy.');
                        return;
                    }
                }
                if(opp.b2b_Billing_Contact__c !=  old.b2b_Billing_Contact__c ){
                    
                    if(opp.b2b_Billing_Contact__c != null ){
                        if(contactMap.get(opp.b2b_Billing_Contact__c).inactive__c){
                            applicableObjects.get(oppID).addError('You can only change to active Contact');
                            return;
                        }
 
                        
                        Boolean isAllowed = Print_ContractV2_cc.getChildHierarchy(contactMap.get(opp.b2b_Billing_Contact__c).Accountid,
                                                                                  opp.Accountid);
                        if(!isAllowed){
                            applicableObjects.get(oppID).addError('You can only change the billing contact within account hierarchy.');
                            return;
                        }
                    }
                }
            }
            
            else if(Trigger.isInsert){
                system.debug(opp.AccountID);
                system.debug(accMap.get(opp.AccountID).inactive__c);
                if(accMap.get(opp.AccountID).inactive__c){
                    system.debug(accMap.get(opp.AccountID).inactive__c);
                    applicableObjects.get(oppID).addError('Opportunity can be created under active Account only.');
                    return;
                }
                if(opp.Billing_Entity__c != null){
                    if(accMap.get(opp.Billing_Entity__c).inactive__c){
                        applicableObjects.get(oppID).addError('Please select Active Billing Entity');
                        return;
                    }
                    Boolean isAllowed = Print_ContractV2_cc.getChildHierarchy(opp.Billing_entity__c,
                                                                              opp.Accountid);
                    System.debug('@@@relationship'+isAllowed);
                    if(!isAllowed){
                        applicableObjects.get(oppID).addError('You can only change the Billing Entity within hierarchy.');
                        return;
                    }
                    
                }
                
                if(opp.b2b_Billing_Contact__c !=  null ){
                    
                    if(contactMap.get(opp.b2b_Billing_Contact__c).inactive__c){
                        applicableObjects.get(oppID).addError('You can only select active Contact');
                        return;
                    }
                     Boolean isAllowed = Print_ContractV2_cc.getChildHierarchy(contactMap.get(opp.b2b_Billing_Contact__c).Accountid,
                                                                              opp.Accountid);
                    if(!isAllowed){
                        applicableObjects.get(oppID).addError('You can only change the billing contact within account hierarchy.');
                        return;
                    }
                    
                }
                
            }
        }
        // Print_ContractV2_cc
    }
}
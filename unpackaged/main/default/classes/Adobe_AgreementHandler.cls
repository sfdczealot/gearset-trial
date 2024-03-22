public class Adobe_AgreementHandler {
    public static boolean addRecipentsExecuted = false;
        public static boolean restrictSendingContractExecuted = false;

    public static void addRecipents(List<echosign_dev1__SIGN_Agreement__c> agreementList){
        
        Map<String,String> agreementIdVSOppId = new Map<String,String>();
        for(echosign_dev1__SIGN_Agreement__c agreement : agreementList){
            if(agreement.echosign_dev1__Status__c == 'Draft' || agreement.echosign_dev1__Status__c == 'Created' )
                agreementIdVSOppId.put(agreement.ID,agreement.echosign_dev1__Opportunity__c);
        }
        //   delete [select id from echosign_dev1__SIGN_Recipients__c where echosign_dev1__Agreement__c =: agreementIdVSOppId.keySet()];
        Map<String,Opportunity> oppMap = new Map<String,Opportunity>([Select Id, 
                                                                      (Select id,contactID 
                                                                       from OpportunitycontactRoles
                                                                       where role ='Client Signatory')
                                                                      from opportunity where Id in: agreementIdVSOppId.values()]); 
        List<echosign_dev1__SIGN_Recipients__c> recList = new List<echosign_dev1__SIGN_Recipients__c>();  
        for(echosign_dev1__SIGN_Agreement__c agreement : agreementList){
            Integer count=1;
            if(oppMap.containsKey(agreement.echosign_dev1__Opportunity__c)){
                for(OpportunitycontactRole ocr : oppMap.get(agreementIdVSOppId.get(agreement.Id)).OpportunitycontactRoles){
                    system.debug(ocr);
                    if(ocr.ContactID!=null){
                        recList.add(new echosign_dev1__SIGN_Recipients__c(echosign_dev1__Agreement__c = agreement.ID,
                                                                          echosign_dev1__Contact__c  = ocr.ContactID,
                                                                          echosign_dev1__Order_Number__c = Count,
                                                                          echosign_dev1__Signer_Verification_Method__c = 'Email',
                                                                          echosign_dev1__Recipient_Type__c ='Contact',
                                                                          echosign_dev1__Recipient_Role__c ='Signer'));
                        
                        count++;
                    }
                }
            }
        }
        insert recList;
        addRecipentsExecuted =true;
    }
    
    public static void restrictSendingContract(map<Id,echosign_dev1__SIGN_Agreement__c> agreementMap,Map<Id,echosign_dev1__SIGN_Agreement__c> oldAgreementMap){
        List<String> OppIdList = new List<String>();
         restrictSendingContractExecuted =true;
        for(String agreementID : agreementMap.keySet()){
            echosign_dev1__SIGN_Agreement__c agreement = agreementMap.get(agreementID);
            echosign_dev1__SIGN_Agreement__c oldAgreement = oldAgreementMap.get(agreementID);
            if(agreement.echosign_dev1__Status__c == 'Out for Signature')
                OppIdList.add(agreement.echosign_dev1__Opportunity__c);
        }
        Map<String,opportunity> oppMap = new Map<String,opportunity>([select id,(select id from echosign_dev1__R00N70000001hM2REAU__r 
                            where echosign_dev1__Status__c in ('Send in Progress',
                                                               'Out for Signature',
                                                               'Waiting for Counter-Approval',
                                                               'Waiting for Counter-Signature',
                                                               'Signed','Out for Approval',
                                                               'Approved')) 
                 from opportunity where id in :OppIdList]);

          for(String agreementID : agreementMap.keySet()){
              if(oppMap.ContainsKey(agreementMap.get(agreementID).echosign_dev1__Opportunity__c)){
                  agreementMap.get(agreementID).addError('Contract for this opportunity has been already sent');
              }
        }
    }
}
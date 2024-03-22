trigger Adobe_AgreementTrigger on echosign_dev1__SIGN_Agreement__c (after insert,before update) {
     //static Boolean isExecuted = false;
    if(!Adobe_AgreementHandler.addRecipentsExecuted){
         if(trigger.isAfter && trigger.isInsert)
        Adobe_AgreementHandler.addRecipents(trigger.new);
    }
   /* if(!Adobe_AgreementHandler.restrictSendingContractExecuted){
        if(trigger.isBefore && trigger.isUpdate)
          //  Adobe_AgreementHandler.restrictSendingContract(trigger.newMap,trigger.oldMap);
    }*/
    //isExecuted=true;
    system.debug('Adobe_AgreementTrigger');
  
}
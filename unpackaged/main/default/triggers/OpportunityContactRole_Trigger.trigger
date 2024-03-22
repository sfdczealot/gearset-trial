trigger OpportunityContactRole_Trigger on OpportunityContactRole (Before Insert,After Insert,After Update,Before Update,After Delete){
    
    if(Trigger.isInsert) {
        if(Trigger.isAfter){
            OpportunityContactRoleHandler.restrictRecordUpdate(Trigger.newMap,null);
            OpportunityContactRoleHandler.updateRePrintContractFlag(Trigger.newMap,null);
        }
        if(Trigger.isBefore){
            OpportunityContactRoleHandler.updateBillingAddress(Trigger.new);
            OpportunityContactRoleHandler.checkContactAccount(Trigger.New);
        }
    }
    if(Trigger.isUpdate) {
        if(Trigger.isAfter){
            OpportunityContactRoleHandler.restrictRecordUpdate(Trigger.newMap,Trigger.oldMap);
            OpportunityContactRoleHandler.updateRePrintContractFlag(Trigger.newMap,Trigger.oldMap);
        }
        if(Trigger.isBefore /*&& !PGAccountTriggerHandler.OCRTriggerRecursion*/){
            OpportunityContactRoleHandler.updateBillingAddress(Trigger.new);
        }
    }
    if(Trigger.isDelete){
        OpportunityContactRoleHandler.restrictRecordUpdate(Trigger.oldMap,null);
         OpportunityContactRoleHandler.updateRePrintContractFlag(Trigger.oldMap,null);
    }
}
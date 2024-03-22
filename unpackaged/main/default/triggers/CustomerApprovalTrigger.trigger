trigger CustomerApprovalTrigger on CSCAP__Customer_Approval__c (before insert, before update, before delete, after insert, after update, after delete) {
	if (!CS_TriggerHandler.GetTriggersEnabled() || CS_utl_User.isDeactivatedForDataMigration) {
		return;
	}

	if(CS_utl_User.isTriggerActiveForMe()) {
		if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)) {

			CS_ProcessDispatcher dispatcher = new CS_ProcessDispatcher();
			if (Trigger.isUpdate) {
				dispatcher.addProcesses(new List<CS_ProcessBase>{
						new CS_P_CustomerApprovalStatusChanged(Trigger.oldMap)
				});
			}

			dispatcher.dispatch();
		}
	}
}
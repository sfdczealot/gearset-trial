global without sharing class ButtonSORestore extends CS_ButtonBase {
	global override void init() {
		this.className = ButtonSORestore.class.getName();
		this.calloutType = 'ButtonSORestore';
		this.lastButtonClicked = 'Restore';
	}

	global override void doAction() {
		if(AttributeArchiveHelper.restoreSalesOrderConfigs(salesOrder.Id)) {
			returnMessage.setSuccessMessage(Label.SO_Restore_processed);
		}
		else {
			returnMessage.setAndPersistErrorMessage(Label.SO_Restore_failed);
		}
	}

	global override Boolean doAdditionalValidation() {
		if(salesOrder.Is_Archived__c == false) {
			returnMessage.setErrorMessage(Label.SO_Restore_Cannot_be_Processed);
			return false;
		}
		
		return true;
	}
}
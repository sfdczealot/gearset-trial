global without sharing class ButtonSOCancelDraft extends CS_ButtonBase {
	global override void init() {
		this.className = ButtonSOCancelDraft.class.getName();
		this.calloutType = 'ButtonSOCancelDraft';
		this.lastButtonClicked = 'Cancel Draft';
		this.isDfpAction = true;
		this.skipFulfilmentItemUpdate = true;
	}

	global override Boolean doAdditionalValidation() {
		if (!hasSolisEligibleForCancelRetract()) {
			return false;
		}
		return true;
	}

	private Boolean hasSolisEligibleForCancelRetract() {
		for (cscfga__Product_Configuration__c currConfiguration : this.configs.values()) {
			if (currConfiguration.Fulfilment_Item_Status__c != ''
					&& currConfiguration.Fulfilment_Item_Status__c != CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased) {
				return true;
			}
		}
		returnMessage.setErrorMessage(Label.SO_Cancel_Draft_Cannot_be_Processed_No_Lines);
		return false;
	}

	global override void doAction() {
		try {
			if (CS_RetractionService.cancelRetraction(salesOrder.Id, CS_const_SalesOrder.FILE_NAME_PROPOSAL_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_PROPOSAL_SCREENSHOT)) {
				returnMessage.setSuccessMessage('Cancel retraction successfully processed.');
			} else {
				returnMessage.setErrorMessage('Cancel retraction failed.');
			}
		} catch (Exception ex) {
			returnMessage.setAndPersistErrorMessage(ex.getMessage().escapeJava());
		}
	}
}
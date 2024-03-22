global without sharing class ButtonSOCustomerApprovalRecall extends CS_ButtonBase {

	global override void init() {
		this.className = ButtonSOCustomerApprovalRecall.class.getName();
		this.calloutType = 'ButtonSOCustomerApprovalRecall';
		this.lastButtonClicked = 'Recall';
		this.isDfpAction = false;
	}

	global override Boolean doAdditionalValidation() {
		if (!canBeRetractedInCurrentStatus()
				|| !isReasonForRetractionPopulated()){
			return false;
		}
		return true;
	}

	global override void doAction() {
		terminateOrchestratorProcesses();
		
		if (String.isBlank(String.valueOf(salesOrder.Last_Date_Booked__c))) {
			salesOrder.Recall_Retract_Counter__c += 1;
		}

		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_REJECTED;
		salesOrder.Comments__c = '';
		salesOrder.Order_Synced_before_final_approval__c = false;
		returnMessage.setSuccessMessage(Label.SO_Retract_request);
	}

	private Boolean hasSOAdServerLineItems() {
		return salesOrder.SO_Lines_Ad_Server_Items__c > 0;
	}

	private Boolean isReasonForRetractionPopulated() {
		if (salesOrder.Reason_for_Retraction__c == null
				&& (salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_BOOKED
				|| salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_RESERVED
				|| salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_RESERVE_REJECTED)) {
			returnMessage.setErrorMessage(Label.SO_Retract_Reason_For_Retraction_Are_Mandatory);
			return false;
		}
		return true;
	}

	private Boolean canBeRetractedInCurrentStatus() {
		if (salesOrder.csmso__Status__c != StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL_READY
				&& salesOrder.csmso__Status__c != StandardSalesOrderStateManager.SO_PENDING_BOOKING
				&& salesOrder.csmso__Status__c != StandardSalesOrderStateManager.SO_BOOKED
				&& salesOrder.csmso__Status__c != StandardSalesOrderStateManager.SO_RESERVED
				&& salesOrder.csmso__Status__c != StandardSalesOrderStateManager.SO_RESERVE_REJECTED
				&& salesOrder.csmso__Status__c != StandardSalesOrderStateManager.SO_PENDING_PUSH) {
			returnMessage.setErrorMessage(Label.SO_Retract_Cannot_be_Processed);
			return false;
		}
		return true;
	}

	private Boolean hasAllFulfilmentItemStatusInDraft() {
		Boolean hasAllDrafts = true;
		for (cscfga__Product_Configuration__c currConfiguration : this.configs.values()) {
			if (currConfiguration.Fulfilment_Item_Status__c != 'Draft') {
				hasAllDrafts = false;
				break;
			}
		}

		return hasAllDrafts;
	}
}
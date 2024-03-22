global without sharing class ButtonSOCustomerApprovalManual extends CS_ButtonBase {
	global override void init() {
		this.className = ButtonSOCustomerApprovalManual.class.getName();
		this.calloutType = 'ButtonSOCustomerApprovalManual';
		this.lastButtonClicked = 'Approve';
	}

	global override Boolean doAdditionalValidation() {
		if(salesOrder.csmso__Status__c != StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL_READY){
			returnMessage.setErrorMessage(Label.SO_Customer_Approval_Cannot_be_Processed);
			return false;
		}

		return true;
	}

	global override void doAction() {
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_PENDING_BOOKING;
		returnMessage.setSuccessMessage(Label.SO_Customer_Approval_Accept_request);
	}
}
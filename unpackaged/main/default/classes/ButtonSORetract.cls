global without sharing class ButtonSORetract extends CS_ButtonBase {

	global override void init() {
		this.calloutType = getCalloutType();
		this.lastButtonClicked = 'Retract';
		this.className = ButtonSORetract.class.getName();
		this.isDfpAction = isDfpAction();
		this.skipFulfilmentItemUpdate = true;
	}

	global override Boolean doAdditionalValidation() {
		if (!isRetractAvailable()
				|| !isReasonPopulated()) {
			return false;
		}
		return true;
	}

	global override void doAction() {
		if (String.isBlank(String.valueOf(salesOrder.Last_Date_Booked__c))) {
			salesOrder.Recall_Retract_Counter__c += 1;
		}

		if (soWasAlreadyBooked()) {
			if (!shouldBeRefreshedFromDFP()) {
				salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_RETRACTED;
				salesOrder.Last_Date_Retracted__c = System.now();
				salesOrder.Order_Synced_before_final_approval__c = false;
				salesOrder.Loading_Screen__c = 'Off';

				returnMessage.setSuccessMessage(Label.SO_Retract_request);
			}

			//Process for SOs with Ad Server integration
			if (shouldBeRefreshedFromDFP()) {
				returnMessage.setSuccessMessage(DigitalFulfilmentAdapterUtil.updateStatus(this.salesOrder.Id));
			}
		} else {
			//Process for retracting before booking/ rebooking
			salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_REJECTED;
			salesOrder.Last_Date_Retracted__c = System.now();
			salesOrder.Order_Synced_before_final_approval__c = false;

			returnMessage.setSuccessMessage(Label.SO_Retract_request);
		}
	}

	private Boolean shouldBeRefreshedFromDFP() {
		return salesOrder.SO_Lines_Ad_Server_Items__c > 0
				&& !hasAllFulfilmentItemStatusInDraft()
				&& !(salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_PENDING_BOOKING && salesOrder.In_Retraction__c)
				&& !(salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_RESERVE_REJECTED && salesOrder.In_Retraction__c);
	}

	private Boolean soWasAlreadyBooked() {
		return salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_BOOKED
				|| salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_RESERVED
				|| salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_RESERVE_REJECTED
				|| (salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_PENDING_BOOKING && salesOrder.In_Retraction__c);
	}

	private String getCalloutType() {
		if (shouldBeRefreshedFromDFP()) {
			return 'ButtonSORetract';
		} else {
			return '';
		}
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

	private Boolean isRetractAvailable() {
		//SO Retract is only available before Customer approval, when SO is Pending Booking or Booked or Reserved or Reservation Rejected
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

	private Boolean isReasonPopulated() {
		//User must set Reason for Retraction value before Retracting the Order from Ad Server
		if (salesOrder.Reason_for_Retraction__c == null
				&& (salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_BOOKED
				|| salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_RESERVED
				|| salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_RESERVE_REJECTED)) {
			returnMessage.setErrorMessage(Label.SO_Retract_Reason_For_Retraction_Are_Mandatory);
			return false;
		}
		return true;
	}

	private Boolean isDfpAction() {
		return soWasAlreadyBooked() && (shouldBeRefreshedFromDFP());
	}
}
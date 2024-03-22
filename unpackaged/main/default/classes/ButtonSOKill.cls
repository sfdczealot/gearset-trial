global without sharing class ButtonSOKill extends CS_ButtonBase {
	private List<CS_Billing_Schedule_Item__c> bScheduleItems {
		get {
			if (bScheduleItems == null) {
				bScheduleItems = [SELECT Id, Status__c, Billing_Schedule__c, Valid_for_Auto_Cancellation__c
				FROM CS_Billing_Schedule_Item__c
				WHERE Sales_Order__c = :salesOrder.Id];
			}
			return bScheduleItems;
		}
		set;
	}

	private List<CS_Revenue_Schedule_Item__c> rScheduleItems {
		get {
			if (rScheduleItems == null) {
				rScheduleItems = [SELECT Id, Status__c, Revenue_Schedule__c, Valid_for_Auto_Cancellation__c
				FROM CS_Revenue_Schedule_Item__c
				WHERE Sales_Order__c = :salesOrder.Id];
			}
			return rScheduleItems;
		}
		set;
	}

	private List<csdf__Fulfilment_Item__c> fulfilmentItems {
		get {
			if (fulfilmentItems == null) {
				fulfilmentItems = [SELECT Id, csdf__Status__c, Served_By__c, Status_Manual_Tracking__c
				FROM csdf__Fulfilment_Item__c
				WHERE Product_Configuration__c IN :this.configs.values()];
			}
			return fulfilmentItems;
		}
		set;
	}

	global override void init() {
		this.className = ButtonSOKill.class.getName();
		this.calloutType = 'ButtonSOKill';
		this.lastButtonClicked = 'Kill';
		this.isDfpAction = hasSOAdServerLineItems();
		this.skipFulfilmentItemUpdate = true;
	}

	global override Boolean doAdditionalValidation() {
		if (!isReasonForCancellationPopulated()
				|| !areBSIsInCorrectStatus()
				|| !hasLinesInInvoicingProcess() || !isUserProfileB2B()) {

			return false;
		}
		return true;
	}
    private Boolean isUserProfileB2B(){
        Id profileId=userinfo.getProfileId();
		String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        //Please write the logic check wheather the sales order is sold or not, because Kill button will be avaialble in different 
        //stages, but we just need to restrict the Sold SO to not kill
		//system.debug('ProfileName'+profileName);
        if(profileName != 'System Administrator' && salesOrder.Sold__c==true){
            returnMessage.setErrorMessage(Label.SO_Only_Admin_Can_Kill_Sold_SO);
            return false;
        }
        return true;
    }
	global override void doAction() {
		terminateOrchestratorProcesses();

		if (hasSOAdServerLineItems()) {
			returnMessage.setSuccessMessage(DigitalFulfilmentAdapterUtil.fulfilmentCancel(salesOrder.Id));
		}
		else {
			CS_utl_SalesOrder.killSalesOrder(salesOrder, this.configs, fulfilmentItems, bScheduleItems, rScheduleItems);
			returnMessage.setSuccessMessage(Label.SO_Kill_request);
		}
	}

	private Boolean hasSOAdServerLineItems() {
		Boolean hasNonPausedAdServedLines = false;
		for (cscfga__Product_Configuration__c pc : this.configs.values()) {
			if (!String.isBlank(pc.Order_Line_ID__c)
					&& pc.Fulfilment_Item_Status__c != CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased) {
				hasNonPausedAdServedLines = true;
				break;
			}
		}
		return hasNonPausedAdServedLines;
	}

	private Boolean isReasonForCancellationPopulated() {
		if (String.isBlank(salesOrder.Reason_for_Cancellation__c) && salesOrder.csmso__Opportunity__r.StageName!='Closed Lost') {
			returnMessage.setErrorMessage(Label.SO_Kill_Comments_Are_Mandatory);
			return false;
		}
		return true;
	}

	private Boolean areBSIsInCorrectStatus() {
		if (salesOrder.Last_Date_Booked__c != null && salesOrder.csmso__Opportunity__r.StageName!='Closed Lost') {
			for (CS_Billing_Schedule_Item__c bScheduleItem : [SELECT Id, Status__c, Billing_Schedule__c, Valid_for_Auto_Cancellation__c
			FROM CS_Billing_Schedule_Item__c
			WHERE Billing_Schedule__r.CS_Sales_Order_Schedule__r.Sales_Order__c = :salesOrder.Id]) {
				if (bScheduleItem.Status__c != CS_Constants.STATUS_CANCELLED
						&& !bScheduleItem.Valid_for_Auto_Cancellation__c) {

					returnMessage.setErrorMessage(Label.SO_Kill_Not_Possible);
					return false;
				}
			}
		}
		return true;
	}

	private Boolean hasLinesInInvoicingProcess() {
		if (salesOrder.Last_Date_Booked__c != null && this.configs.values().size() > 0 && salesOrder.csmso__Opportunity__r.StageName!='Closed Lost') {
			for (cscfga__Product_Configuration__c pc : this.configs.values()) {
				if (pc.Fulfilment_Item_Status__c != CS_const_SalesOrder.FulfilmentItemStatus_Draft &&
						pc.Fulfilment_Item_Status__c != CS_const_SalesOrder.FulfilmentItemStatus_Inactive &&
						pc.Fulfilment_Item_Status__c != CS_const_SalesOrder.FulfilmentItemStatus_Ready &&
						pc.Fulfilment_Item_Status__c != CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased &&
						pc.Fulfilment_Item_Status__c != CS_const_SalesOrder.FulfilmentItemStatus_Reserved &&
						pc.Fulfilment_Item_Status__c != CS_const_SalesOrder.FulfilmentItemStatus_NotReserved &&
						pc.Fulfilment_Item_Status__c != CS_const_SalesOrder.FulfilmentItemStatus_InventoryReleased &&
						(pc.Flight_Begin_Logged_User_Timezone__c < Datetime.now() || pc.Flight_End_Logged_User_Timezone__c < Datetime.now())) {
					returnMessage.setErrorMessage(Label.SO_Archive_Not_Possible);
					return false;
				}
			}
		}
		return true;
	}
}
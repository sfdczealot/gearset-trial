global without sharing class ButtonSOPush extends CS_ButtonBase {
    global override void init() {
        this.calloutType = 'ButtonSOPush';
        this.lastButtonClicked = 'Push SO';
        this.isDfpAction = hasSOAdServerLineItems();
        this.className = ButtonSOPush.class.getName();
    }

    global override Boolean doAdditionalValidation() {
        if (!areAllConfigurationStatusesValid()
            || isStartDateOfAnyLineInThePast()
            || hasAnyLineExpiredDigitalProduct()
            || !hasSOLineItems()
            || !isSOInProperStatusToBeBooked()) {
            return false;
        }
        return true;
    }

    global override void doAction() {
        if (hasSOAdServerLineItems()) {
            returnMessage.setSuccessMessage(DigitalFulfilmentAdapterUtil.pushToAdServer(this.salesOrder.Id));
        }
        else {
            returnMessage.setSuccessMessage(Label.SO_Book_request);
        }
    }

    private Boolean hasSOAdServerLineItems() {
        return salesOrder.SO_Lines_Ad_Server_Items__c > 0;
    }

    private Boolean isSOInProperStatusToBeBooked() {
        if (salesOrder.csmso__Status__c != StandardSalesOrderStateManager.SO_RESERVED
                && salesOrder.csmso__Status__c != StandardSalesOrderStateManager.SO_BOOKED) {
            returnMessage.setErrorMessage(Label.SO_Book_Cannot_be_Processed);
            return false;
        }
        return true;
    }
}
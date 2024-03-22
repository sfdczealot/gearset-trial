global without sharing class ButtonSORetractProposal extends CS_ButtonBase implements Database.AllowsCallouts {

    global override void init() {
        this.calloutType = 'ButtonSORetractProposal';
        this.lastButtonClicked = 'Retract Proposal';
        this.className = ButtonSORetractProposal.class.getName();
        this.isDfpAction = !shouldBeSoftRetracted();
        this.skipFulfilmentItemUpdate = true;
    }

    global override Boolean doAdditionalValidation() {
        if(!isReasonPopulated()){
            return false;
        }
        return true;
    }

    global override void doAction() {
        // soft-retract on the SFDC end only
        if (shouldBeSoftRetracted()) {
            salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_RETRACTED;
            returnMessage.setSuccessMessage(Label.SO_Retract_request);
        }
        else {
            if(!Test.isRunningTest()){
                returnMessage.setSuccessMessage(DigitalFulfilmentAdapterUtil.retractPGProposal(this.salesOrder.Id));
            }

            returnMessage.setSuccessMessage(DigitalFulfilmentAdapterUtil.updateStatus(this.salesOrder.Id));
        }
    }

    private Boolean shouldBeSoftRetracted() {
        return (salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_RESERVED
                || salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_REJECTED) && salesOrder.Negotiation_Status__c.equalsIgnoreCase('FINALIZED');
    }

    private Boolean isReasonPopulated() {
        //User must set Reason for Retraction value before Retracting the Order from Ad Server
        if (salesOrder.Reason_for_Retraction__c == null &&
                (salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_BOOKED
                        || salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL)) {
            returnMessage.setErrorMessage(Label.SO_Retract_Reason_For_Retraction_Are_Mandatory);
            return false;
        }
        return true;
    }
}
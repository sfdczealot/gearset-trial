global without sharing class ButtonSOCheckAvail extends CS_ButtonBase {
    global override void init() {
        this.calloutType = 'ButtonSOCheckAvail';
        this.lastButtonClicked = 'Check Availability';
        this.className = ButtonSOCheckAvail.class.getName();
        this.isDfpAction = hasSOAdServerLineItems();
    }

    global override Boolean doAdditionalValidation() {
        if (!areAllConfigurationStatusesValid()
            || isStartDateOfAnyLineInThePast()
            || hasAnyLineExpiredDigitalProduct()
            || !hasSOLineItems()) {
            return false;
        }

        return true;
    }

    global override void doAction() {
        try {
            if (hasSOAdServerLineItems()) {
                returnMessage.setSuccessMessage(DigitalFulfilmentAdapterUtil.doGlobalCheckAvails(configs));
            }
            else {
                salesOrder.Order_Synced_before_final_approval__c = true;
                salesOrder.Callout_Type__c = null;
                returnMessage.setSuccessMessage(Label.SO_Check_Avail_request);
            }
        }
        catch (Exception ex) {
            returnMessage.setAndPersistErrorMessage(ex.getMessage().escapeJava());
        }
    }

    private Boolean hasSOAdServerLineItems() {
        for(cscfga__Product_Configuration__c cfg : this.configs.values()) {
            if(cfg.Eligible_for_Check_Availability__c) return true;
        }

        return false;
    }
}
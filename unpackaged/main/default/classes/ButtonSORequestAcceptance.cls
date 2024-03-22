global without sharing class ButtonSORequestAcceptance extends CS_ButtonBase {

    global override void init() {
        this.calloutType = 'ButtonSORequestAcceptance';
        this.lastButtonClicked = 'Request Acceptance';
        this.className = ButtonSORequestAcceptance.class.getName();
        this.isDfpAction = true;
    }

    global override Boolean doAdditionalValidation() {
        if (!areAllConfigurationStatusesValid()
            || isStartDateOfAnyLineInThePast()
            || hasAnyLineExpiredDigitalProduct()
            || !hasSOLineItems()
            || !hasSOAllLineItemsReserved()) {
            return false;
        }
        return true;
    }

    global override void doAction() {
        String message = DigitalFulfilmentAdapterUtil.requestAcceptance(this.salesOrder.Id);
        returnMessage.setSuccessMessage(message);
    }

    private Boolean hasSOAllLineItemsReserved() {
        List<String> notReservedLineIds = new List<String>();
        for (cscfga__Product_Configuration__c pc : configs.values()) {
            if (pc.Fulfilment_Item_Status__c != 'Paused Inventory Released' && !CS_utl_ProductConfiguration.isReserved(pc)) {
                notReservedLineIds.add(pc.Line_ID__c);
            }
        }

        if (!notReservedLineIds.isEmpty()) {
            List<String> commaSeparatedLineIDs = new List<String>{
                    String.join(notReservedLineIds, ', ')
            };

            if (notReservedLineIds.size() < 10) {
                returnMessage.setErrorMessage(String.format(Label.SO_Has_Not_Reserved_Lines, commaSeparatedLineIDs));
            }
            else {
                returnMessage.setErrorMessage(Label.SO_Has_A_Lot_Of_Not_Reserved_Lines);
            }

            return false;
        }
        return true;
    }
}
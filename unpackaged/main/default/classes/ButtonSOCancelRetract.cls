global without sharing class ButtonSOCancelRetract extends CS_ButtonBase {
    global override void init() {
        this.className = ButtonSOCancelRetract.class.getName();
        this.calloutType = 'ButtonSOCancelRetract';
        this.lastButtonClicked = 'Revert to DFP';
        this.isDfpAction = true;
        this.skipFulfilmentItemUpdate = true;
    }

    global override Boolean doAdditionalValidation() {
        if (!isSOInRetraction()
                || !hasSolisEligibleForCancelRetract()
                || !isCancelRetractAvailable()) {
            return false;
        }
        return true;
    }

    private Boolean hasSolisEligibleForCancelRetract() {
        for (cscfga__Product_Configuration__c currConfiguration : this.configs.values()) {
            if(currConfiguration.Fulfilment_Item_Status__c != ''
                    && currConfiguration.Fulfilment_Item_Status__c != CS_const_SalesOrder.FulfilmentItemStatus_Draft
                    && currConfiguration.Fulfilment_Item_Status__c != CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased){
                return true;
            }
        }
        returnMessage.setErrorMessage(Label.SO_Cancel_Retract_Cannot_be_Processed_No_Lines);
        return false;
    }

    private Boolean isSOInRetraction() {
        if (salesOrder.In_Retraction__c) {
            return true;
        }
        returnMessage.setErrorMessage(Label.SO_Cancel_Retract_Cannot_be_Processed);
        return false;
    }

    private Boolean isCancelRetractAvailable() {
        Datetime cancelRetractionCutOffDate = CS_Custom_Settings__c.getInstance().Cancel_Retraction_cut_off_date__c;

        if(cancelRetractionCutOffDate != null) {
            Id basketId = [SELECT Id FROM cscfga__Product_Basket__c WHERE csmso__Sales_Order__c =:salesOrder.Id LIMIT 1].Id;

            List<Attachment> basketAttachments =
            [
                    SELECT Id, LastModifiedDate
                    FROM Attachment
                    WHERE (Name LIKE :CS_const_SalesOrder.FILE_NAME_SALES_ORDER_SCREENSHOT
                    OR Name LIKE :CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT)
                    AND LastModifiedDate > :cancelRetractionCutOffDate
                    AND ParentId =:basketId
            ];

            if(basketAttachments.isEmpty()) {
                returnMessage.setErrorMessage(Label.SO_Cancel_Retract_Unavailable_Reconfigure_Manually);
                return false;
            }
        }

        return true;
    }

    global override void doAction() {
        try {
            if (CS_RetractionService.cancelRetraction(salesOrder.Id, CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT)) {
                returnMessage.setSuccessMessage('Cancel retraction successfully processed.');
            }
            else {
                returnMessage.setErrorMessage('Cancel retraction failed.');
            }
        } catch (Exception ex) {
            returnMessage.setAndPersistErrorMessage(ex.getMessage().escapeJava());
        }
    }
}
global without sharing class ButtonSOBook extends CS_ButtonBase {

    private List<CS_Billing_Schedule_Item__c> billingScheduleItems {
        get {
            if (billingScheduleItems == null) {
                billingScheduleItems = [
                        SELECT Id, Name, Opportunity__c, Sales_Order__c, Status__c
                        FROM CS_Billing_Schedule_Item__c
                        WHERE Opportunity__c = :salesOrder.csmso__Opportunity__c
                ];
            }
            return billingScheduleItems;
        }
        set;
    }

    private List<csmso__Sales_Order__c> otherPrimaryPGSO {
        get {
            if (otherPrimaryPGSO == null) {
                otherPrimaryPGSO = [
                        SELECT Id
                        FROM csmso__Sales_Order__c
                        WHERE csmso__Opportunity__c = :salesOrder.csmso__Opportunity__c
                        AND Is_Programmatic__c = TRUE
                        AND Last_Date_Booked__c != NULL
                        AND Primary_Sales_Order__c = TRUE
                        AND Id != :salesOrder.Id
                ];
            }
            return otherPrimaryPGSO;
        }
        set;
    }

    global override void init() {
        this.calloutType = 'ButtonSOBook';
        this.lastButtonClicked = 'Book';
        this.isDfpAction = true;
        this.className = ButtonSOBook.class.getName();
    }

    global override Boolean doAdditionalValidation() {
        if (!areAllConfigurationStatusesValid()
            || isStartDateOfAnyLineInThePast()
            || hasAnyLineExpiredDigitalProduct()
            || !hasSOLineItems()
            || !isSOInProperStatusToBeBooked()
            || !isAgencyAdvertiserCorrect()
            || !areSchedulesValid()
            || hasOppAnotherOpenBillingScheduleItem()
            || isAnotherProgrammaticSOAlreadyPushedToDFP()
            || !areAllLinesItemsAvailable()
            || !isFinalCheckAvailsDone()){
            return false;
        }
        return true;
    }

    global override void doAction() {
        if(salesOrder.Order_Type__c == CS_Constants.ORDER_TYPE_HOUSE_GUARANTEED || salesOrder.Order_Type__c == CS_Constants.ORDER_TYPE_HOUSE_NON_GUARANTEED) {
            salesOrder.Counter_Sign_IO__c = 'Approved';
            salesOrder.Compliance_Check__c = 'Approved';
        }

        if(salesOrder.Order_Type__c == CS_Constants.ORDER_TYPE_LABELS_ADCREDIT){
            salesOrder.Counter_Sign_IO__c = 'Approved';
            salesOrder.Legal_Check__c = 'Approved';
            salesOrder.Compliance_Check__c = 'Approved';
        }

        //Approve Counter Sign IO check when User approval is skipped
        if(!salesOrder.Approval_Inventory_Required__c
            && !salesOrder.Approval_Sales_1_Required__c
            && !salesOrder.Approval_Sales_2_Required__c) {
            salesOrder.Counter_Sign_IO__c = 'Approved';
        }
        if(hasSOAdServerLineItems()) {
            if(salesOrder.Is_Programmatic__c){
                //returnMessage.setSuccessMessage(DigitalFulfilmentAdapterUtil.pushPGToAdServer(this.salesOrder.Id));
            } else {
                returnMessage.setSuccessMessage(DigitalFulfilmentAdapterUtil.pushToAdServer(this.salesOrder.Id));
            }
        }
        else {
            //CS_SO_PushCompletedWorker.prepareWork(salesOrder.Id);
        }
    }

    private Boolean hasSOAdServerLineItems() {
        return salesOrder.SO_Lines_Ad_Server_Items__c > 0;
    }

    private Boolean isAnotherProgrammaticSOAlreadyPushedToDFP() {
        if (!otherPrimaryPGSO.isEmpty()) {
            returnMessage.setErrorMessage(Label.SO_Primary_PG_Already_Pushed);
            return true;
        }
        return false;
    }

    private Boolean hasOppAnotherOpenBillingScheduleItem() {
        for (CS_Billing_Schedule_Item__c bsi : billingScheduleItems) {
            if (bsi.Status__c == CS_const_SalesOrder.ScheduleStatus_Open && bsi.Sales_Order__c != salesOrder.Id) {
                returnMessage.setErrorMessage(Label.Opp_Has_Another_SO_With_Open_BSI);
                return true;
            }
        }
        return false;
    }

/*    private Boolean isSalesPersonOrTraffickerAdServerSetAsGoogleAdManager() {
        if (salesOrder.csmso__Opportunity__r.Primary_Trafficker__r.csdf__Ad_Server__r.Name == 'DSM Integration'
            || salesOrder.csmso__Opportunity__r.Primary_Salesperson__r.csdf__Ad_Server__r.Name == 'DSM Integration') {
            returnMessage.setErrorMessage(Label.SO_Trafficker_Salesperson_Incorrect);
            return false;
        }
        return true;
    }*/

    private Boolean isAgencyAdvertiserCorrect() {
        if (salesOrder.Agency_Final__r.Type == 'Advertiser' || salesOrder.Advertiser_Final__r.Type != 'Advertiser') {
            returnMessage.setErrorMessage(Label.SO_Agency_Advertiser_Incorrect);
            return false;
        }
        return true;
    }

    private Boolean isSOInProperStatusToBeBooked() {
        if (salesOrder.csmso__Status__c != StandardSalesOrderStateManager.SO_PENDING_BOOKING
                && salesOrder.csmso__Status__c != StandardSalesOrderStateManager.SO_PENDING_PUSH
                && !(salesOrder.Is_Programmatic__c
                && (salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_IN_PROGRESS
                || salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_RESERVE_REJECTED
                || salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_RETRACTED
                || salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_REJECTED))) {
            returnMessage.setErrorMessage(Label.SO_Book_Cannot_be_Processed);
            return false;
        }
        return true;
    }

    private Boolean isFinalCheckAvailsDone() {
        if (salesOrder.SO_Lines_Ad_Server_Items__c >= 1 
            && (salesOrder.Order_Synced_before_final_approval__c == false || salesOrder.SO_Lines_Ad_Server_Items__c > salesOrder.SO_Lines_Ad_Server_Inventory_Avail_Ov__c)) {
            returnMessage.setErrorMessage(Label.SO_Final_Check_Avail_Not_Done);
            return false;
        }
        return true;
    }
}
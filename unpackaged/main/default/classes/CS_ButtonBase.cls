global without sharing virtual class CS_ButtonBase implements csmso.SalesOrderSupport.SalesOrderCustomAction, Callable {

    public csmso__Sales_Order__c salesOrder { get; set; }

    public Map<Id, cscfga__Product_Configuration__c> configs { get; set; }

    public CS_ButtonBase.ButtonReturnMessage returnMessage { get; set; }

    protected String calloutType { get; set; }

    protected String lastButtonClicked { get; set; }

    protected Boolean isDfpAction { get; set; }

    protected Boolean skipFulfilmentItemUpdate { get; set; }

    protected Boolean ignoreValidation { get; set; }

    protected String className { get; set; }

    protected Id currentUser = UserInfo.getUserId();

    protected String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()][0].Name;

    @TestVisible
    protected CS_Custom_Settings__c customSettings {
        get {
            if (customSettings == null) {
                customSettings = CS_Custom_Settings__c.getInstance();
            }
            return customSettings;
        }
        set;
    }

    public CS_ButtonBase() {
        returnMessage = new CS_ButtonBase.ButtonReturnMessage();
        ignoreValidation = false;
        isDfpAction = false;
        skipFulfilmentItemUpdate = false;
    }

    global Object call(String action, Map<String, Object> args) {
        this.salesOrder = getSalesOrder((Id) args.get('salesOrderId'));
        this.configs = new Map<Id, cscfga__Product_Configuration__c>(salesOrder.Product_Configurations__r);
        this.isDfpAction = true;

        this.doAction();
        this.persistSalesOrder();

        return null;
    }

    global virtual String performAction(String salesOrderId) {
        try {
            this.salesOrder = getSalesOrder(salesOrderId);
            this.configs = new Map<Id, cscfga__Product_Configuration__c>(this.salesOrder.Product_Configurations__r);

            init();

            CS_FulfilmentService.removeInvalidFulfilmentItems(this.salesOrder.Id);

            if (!ignoreValidation && !validate()) {
                persistSalesOrder();
                return getReturnMessage();
            }

            if(String.isNotBlank(lastButtonClicked)) {
                updateLastButtonClicked(lastButtonClicked);
            }

            initSalesOrder(calloutType);
            if (isDfpAction && !skipFulfilmentItemUpdate) {
                CS_FulfilmentUpsertWorker worker = new CS_FulfilmentUpsertWorker();
                List<csdf__Fulfilment_Item__c> fulfilmentItems = worker.createFulfilmentItems(new Map<String, Object>{'salesOrder' => this.salesOrder, 'action' => className});
                if (fulfilmentItems == null) {
                    persistSalesOrder();
                    return getReturnMessage();
                }
            }

            doAction();
            persistSalesOrder();
        } catch (Exception ex) {
            returnMessage.setAndPersistErrorMessage(ex.getMessage().escapeJava());
            persistSalesOrder();
        }

        return getReturnMessage();
    }

    global virtual Boolean validate() {
        return doAdditionalValidation();
    }

    global virtual void init() {
    }

    global virtual void doAction() {
    }

    global virtual Boolean doAdditionalValidation() {
        return true;
    }

    protected void initSalesOrder(String calloutType) {
        salesOrder.Loading_Screen__c = 'On';
        salesOrder.Error_Message__c = null;
        salesOrder.csmso__Process_Message__c = null;
        salesOrder.csmso__Process_Message_Type__c = null;
        salesOrder.Callout_Type__c = this.calloutType;
    }

    protected void updateLastButtonClicked(String lastButtonClicked) {
        salesOrder.Last_Button_Clicked__c = this.lastButtonClicked;
        update salesOrder;
    }

    protected void persistSalesOrder() {
        if (returnMessage.isError()) {
            if (returnMessage.shouldBePersisted) {
                salesOrder.csmso__Process_Message__c = returnMessage.getMessage();
                salesOrder.csmso__Process_Message_Type__c = returnMessage.getStatus();
            }
            salesOrder.Loading_Screen__c = 'Off';
        } else {
            salesOrder.csmso__Process_Message__c = null;
            salesOrder.csmso__Process_Message_Type__c = null;

            if (!isDfpAction) {
                salesOrder.Loading_Screen__c = 'Off';
            }
        }

        update salesOrder;
    }

    protected String getReturnMessage() {
        return JSON.serialize(returnMessage);
    }

    protected Boolean hasSOLineItems() {
        if (salesOrder.SO_Lines_Number_of_lines__c > 0) {
            return true;
        }

        returnMessage.setErrorMessage(Label.SO_Approval_No_Lines);
        return false;
    }

    protected Boolean areAllConfigurationStatusesValid() {
        List<String> invalidIds = new List<String>();
        for (cscfga__Product_Configuration__c cfg : configs.values()) {
            if (cfg.cscfga__Configuration_Status__c != 'Valid') {
                invalidIds.add(String.valueOf(cfg.Line_ID__c));
            }
        }

        if (!invalidIds.isEmpty()) {
            returnMessage.setErrorMessage(String.format(System.Label.SO_Approval_Invalid_Lines, new List<String>{
                    String.join(invalidIds, ', ')
            }));
            return false;
        }

        return true;
    }

    protected Boolean allowedForMigrationOrPrimarySOSynced() {
        if (isOppMigrationRecordType())  {
          return isUserAuthorizedForMigrationOpp();
        } else {
            return isPrimaryAndSyncedSO();
        }
    }

    protected Boolean isUserAuthorizedForMigrationOpp() {
        if  (FeatureManagement.checkPermission('Sales_Order_Migration_Book')) {
            return true;
        }
        else {
            returnMessage.setErrorMessage(System.Label.SO_Needs_Migration_Permission);
            return false;
        }
    }
        protected boolean checkDates(){
        List<String> invalidIds = new List<String>();
        for(cscfga__Product_Configuration__c cfg : [SELECT Id, Flight_Begin_Logged_User_Timezone__c, cscfga__Description__c  
        FROM cscfga__Product_Configuration__c 
                WHERE cscfga__Product_Basket__r.csmso__Sales_Order__c = :this.salesOrder.Id])  {
         if(cfg.Flight_Begin_Logged_User_Timezone__c == null){
            invalidIds.add(String.valueOf(cfg.cscfga__Description__c));
         }
         }
         if (!invalidIds.isEmpty()) {
         returnMessage.setErrorMessage(String.format(System.Label.SO_Start_Date_blank, new List<String>{
           String.join(invalidIds, ', ')
          }));
            return true;
        }
        return false; 
         
        }

    protected Boolean isOppMigrationRecordType() {
        if (this.salesOrder.csmso__Opportunity__r.RecordType.DeveloperName == 'DirectBooking') {
            return true;
        } else {
            return false;
        }
    }

    protected Boolean isPrimaryAndSyncedSO() {
        if  (this.salesOrder.Synchronized_with_Opportunity__c && this.salesOrder.Primary_Sales_Order__c) {
            return true;
        } else {
            returnMessage.setErrorMessage(System.Label.SO_Needs_Opp_Sync);
            return false;
        }

    }

    protected Boolean isPrimarySo() {
        
        if  (this.salesOrder.Primary_Sales_Order__c) {
            return true;
        } else {
            returnMessage.setErrorMessage('Please choose a Primary Sales Order to do the action.');
            return false;
        }

    }

    @TestVisible
    protected Boolean areAllLinesItemsAvailable() {
        List<String> invalidIds = new List<String>();
        for (cscfga__Product_Configuration__c cfg : configs.values()) {
            if (cfg.Fulfilment_Item_Status__c != 'Paused Inventory Released' && cfg.Served_By__c == 'DFP' &&
                    ( (String.isBlank(cfg.Inventory_Available__c) || !cfg.Inventory_Available__c.equalsIgnoreCase('Yes') ) && cfg.Overbook__c == false)) {
                invalidIds.add(String.valueOf(cfg.Line_ID__c));
            }
        }

        if (!invalidIds.isEmpty()) {
            returnMessage.setErrorMessage(String.format(System.Label.SO_Approval_Line_No_Inventory, new List<String>{
                    String.join(invalidIds, ', ')
            }));
            return false;
        }

        return true;
    }

    protected Boolean isStartDateOfAnyLineInThePast() {
        List<String> invalidIds = new List<String>();
        for (cscfga__Product_Configuration__c cfg : configs.values()) {
            if (isAdServedLineStartDateInThePast(cfg)
                    || isNonAdServedLineStartDateInThePast(cfg)) {
                invalidIds.add(String.valueOf(cfg.Line_ID__c));
            }
        }

        if (!invalidIds.isEmpty()) {
            returnMessage.setErrorMessage(String.format(System.Label.SO_Book_Past_Dates, new List<String>{
                    String.join(invalidIds, ', ')
            }));
            return true;
        }
        return false;
    }

    protected Boolean areSchedulesValid() {
        String validationResult = CS_ScheduleService.validateSchedules(new Set<Id>{
                this.salesOrder.Id
        }, null);
        if (String.isNotBlank(validationResult)) {
            returnMessage.setErrorMessage(validationResult);
            return false;
        }
        return true;
    }

    protected Boolean isThereNotKilledSoldSO() {
        List<csmso__Sales_Order__c> notKilledSoldSOs = [
                SELECT Id
                FROM csmso__Sales_Order__c
                WHERE csmso__Opportunity__c = :salesOrder.csmso__Opportunity__c
                AND Sold__c = TRUE
                AND csmso__Status__c != :CS_const_SalesOrder.Status_Killed
                AND Id != :this.salesOrder.Id
        ];

        if (notKilledSoldSOs.size() > 0) {
            returnMessage.setErrorMessage(Label.SO_Approval_Not_Killed_Sold_SO);
            return true;
        }

        return false;
    }

    protected void terminateOrchestratorProcesses() {
        try {
            List<CSPOFA__Orchestration_Process__c> processes = [
                    SELECT Id, CSPOFA__State__c, CSPOFA__Status__c
                    FROM CSPOFA__Orchestration_Process__c
                    WHERE Sales_Order__c = :this.salesOrder.Id
                    AND CSPOFA__State__c != :CS_const_SalesOrder.OrchestratorState_Terminated
            ];

            for(CSPOFA__Orchestration_Process__c process : processes) {
                process.CSPOFA__State__c = CS_const_SalesOrder.OrchestratorState_Terminated;
                process.CSPOFA__Status__c = CS_const_SalesOrder.OrchestratorStatus_Complete;
            }

            update processes;
        }
        catch (Exception e) {
            returnMessage.setErrorMessage('Please re-try the action.');
        }
    }

    private Boolean isNonAdServedLineStartDateInThePast(cscfga__Product_Configuration__c cfg) {
        return cfg.Flight_Begin_Logged_User_Timezone__c < System.now()
                && cfg.Served_By__c == 'Non-Ad Served'
                && cfg.Fulfilment_Item_Status__c != 'Ready'
                && cfg.Fulfilment_Item_Status__c != 'Completed'
                && cfg.Fulfilment_Item_Status__c != 'Paused Inventory Released'
                && cfg.Fulfilment_Item_Status__c != 'Draft';
    }

    private Boolean isAdServedLineStartDateInThePast(cscfga__Product_Configuration__c cfg) {
        return cfg.Served_By__c == 'DFP'
                && cfg.Flight_Begin_Logged_User_Timezone__c < System.now()
                && cfg.Fulfilment_Item_Status__c != 'Paused Inventory Released'
                && (cfg.Order_Line_ID__c == null || String.isBlank(cfg.Order_Line_ID__c));
    }

    protected Boolean hasAnyLineExpiredDigitalProduct() {
        List<String> invalidIds = new List<String>();
        //CR-775
        Boolean canBookExpiredNAAs = FeatureManagement.checkPermission('Sales_Order_Bypass_Expiration_Date_NAA');

        for (cscfga__Product_Configuration__c cfg : configs.values()) {
            if (cfg.Fulfilment_Item_Status__c != 'Paused Inventory Released' && cfg.Digital_Product__r.Expiration_Date__c != null && cfg.Digital_Product__r.Expiration_Date__c <= Date.today()) {
                if (!canBookExpiredNAAs) {
                    invalidIds.add(String.valueOf(cfg.Line_ID__c));
                }
            }
        }

        if (!invalidIds.isEmpty()) {
            returnMessage.setErrorMessage(String.format(System.Label.SO_Approval_Line_Expired, new List<String>{
                    String.join(invalidIds, ', ')
            }));
            return true;
        }

        return false;
    }

    global csmso__Sales_Order__c getSalesOrder(String salesOrderId) {
        salesOrder = CS_utl_SalesOrder.getSalesOrder(salesOrderId);

        return salesOrder;
    }

    global without sharing class ButtonReturnMessage {
        public String status = 'ok';
        public String message = '';
        public String redirectURL = '';
        private Boolean shouldBePersisted = false;

        public ButtonReturnMessage() {
        }

        public String getMessage() {
            return message;
        }

        public String getStatus() {
            return status;
        }

        public void setSuccessMessage(String msg) {
            message = msg;
            status = 'ok';
            shouldBePersisted = false;
        }

        public void setErrorMessage(String msg) {
            message = msg;
            status = 'error';
            shouldBePersisted = false;
        }

        public void setRedirectMessage(String redirectString) {
            redirectURL = redirectString;
            status = 'ok';
            shouldBePersisted = false;
        }

        public void setAndPersistErrorMessage(String msg) {
            message = msg;
            status = 'error';
            shouldBePersisted = true;
        }

        public Boolean isSuccess() {
            return status == 'ok';
        }

        public Boolean isError() {
            return status == 'error';
        }
    }
}
/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Common SO State Manager functionality 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Frano Vojvodic   <frano.vojvodic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            name@email.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text. 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public abstract class CS_SalesOrderStateManagerBase  {
    private static final String StateManagerDefinitionStaticResource = 'CS_StateManagerDefinition';

    public static final Set<String> StateManagerPropertyType = new Set<String> {
        'buttons',
        'fields'
    };

    public static final Set<String> MandatoryFields = new Set<String> {
        'Advertiser_Final__c',
        'Bill_To_Account_Final__c',
        'csmso__Opportunity__c',
        'Account_Tier_Final__c',
        'Billing_Calendar__c'
    };

    protected csmso__Sales_Order__c salesOrder {get; set;}

    protected String managerType {get; set;}

    protected Map<Id, cscfga__Product_Configuration__c> configs {
        get {
            if(configs == null) {
                configs = new Map<Id, cscfga__Product_Configuration__c>(
                            [SELECT
                                Id, Name, Ad_Server_Item__c,Developer_listing__c,DeveloperListing_Inventory_Available__c, Overbook__c, Inventory_Available__c, Line_Id__c, Order_Line_Id__c, cscfga__Configuration_Status__c,
                                Net_Cost__c, Gross_Cost__c, Net_Rate_Adjustment_Flat__c, Sales_Order__c, Eligible_for_Check_Availability__c,
                                csmso__Availability_Check_Status__c, Configuration_Status_Tmp__c, Market__c, Total_Price_before_Discount__c,
                                Flight_Begin__c, Flight_End__c, Net_Total_Before_IO_Volume_Discount__c, Reservation_Status__c, Can_Be_Cloned__c,
                                Ad_Server_Inventory_Available__c, Maximum_IO_Volume_Discount_Range__c, FLAG_Price_Recalculated__c,
                                Total_ProdCost__c, Total_CoR__c, Cost_Adjustment_Applied__c, Line_Item_Category__c, Reserve_Inventory__c, 
                                Agency_Commission_Amount__c, Flight_End_Logged_User_Timezone__c, Flight_Begin_Logged_User_Timezone__c, FLAG_Buyer_Acceptance_Required__c,
                                csmso__Flight_Begin__c, csmso__Flight_End__c, Digital_Product__r.Expiration_Date__c, Served_By__c, cscfga__package_guid__c, Fulfilment_Item_Status__c  
                            FROM
                                cscfga__Product_Configuration__c
                            WHERE
                                Sales_Order__c = :salesOrder.Id]);
            }

            return configs;
        }
        set;
    }

    protected List<csmso__Sales_Order__c> relatedSalesOrders {
        get {
            if(relatedSalesOrders == null) {
                relatedSalesOrders = [SELECT Id, csmso__Status__c, Primary_Sales_Order__c, Last_Date_Booked__c, In_Retraction__c,customer_approval__c
                                      FROM csmso__Sales_Order__c 
                                      WHERE csmso__Opportunity__c = :this.salesOrder.csmso__Opportunity__c];
            }

            return relatedSalesOrders;
        }
        set;
    }

    protected Map<String, GroupMember> groupMembership {
        get {
            if(groupMembership == null) {
                groupMembership = new Map<String, GroupMember>();
                for(GroupMember gm : [SELECT GroupId, Group.Name
                                      FROM GroupMember
                                      WHERE UserOrGroupId =: UserInfo.getUserId()]) {
                    groupMembership.put(gm.Group.Name, gm);
                }
            }

            return groupMembership;
        }
        set;
    }

    protected Profile profile {
        get {
            if(profile == null) {
                profile = [SELECT Id, Name
                           FROM Profile
                           WHERE Id = :Userinfo.getProfileId()];
            }

            return profile;
        }
        set;
    }

    protected List<CSPOFA__Orchestration_Process__c> orchestrationProcessitems {
        get {
            if(orchestrationProcessitems == null) {
                orchestrationProcessitems = [
                        SELECT Id, Sales_Order__c, CSPOFA__Status__c
                        FROM CSPOFA__Orchestration_Process__c
                        WHERE Sales_Order__c =:this.salesOrder.Id
                        AND CSPOFA__State__c != 'TERMINATED' AND CSPOFA__State__c != 'COMPLETED'
                                ORDER BY createddate DESC LIMIT 1
                ];
            }

            return orchestrationProcessitems;
        }
        set;
    }

    protected List<ProcessInstanceWorkitem> workItems {
        get {
            if(workItems == null) {
                workItems = [SELECT Id, ActorId
                            FROM ProcessInstanceWorkitem 
                            WHERE ProcessInstance.TargetObjectId = :this.salesOrder.Id
                            AND (ProcessInstance.Status = 'Submitted' OR ProcessInstance.Status = 'Pending')];
            }

            return workItems;
        }
        set;
    }

    protected CustomPermissionsReader cpr {
        get {
            if(cpr == null) {
                cpr = new CustomPermissionsReader();
            }

            return cpr;
        }
        set;
    }

    protected Map<String, SalesOrderProperty> salesOrderProperties {
        get {
            if(salesOrderProperties == null) {
                salesOrderProperties = new Map<String, SalesOrderProperty>();
            }

            return salesOrderProperties;
        }
        set;
    }

    protected Map<String, StateManagerType> stateManagerDefinition {
        get {
            if(stateManagerDefinition == null) {
                StaticResource smd = [SELECT Id, Body FROM StaticResource WHERE Name = 'CS_StateManagerDefinition' LIMIT 1];
                stateManagerDefinition = (Map<String, StateManagerType>) JSON.deserialize(smd.Body.toString(), Map<String, StateManagerType>.class);
            }

            return stateManagerDefinition;
        }
        set;
    }

    protected Map<String, Boolean> additionalProperties {
        get {
            if(additionalProperties == null) {
                additionalProperties = new Map<String, Boolean>{
                    'retracted' => isRetracted(),
                    'reserved' => isReserved(),
                    'adServed' => isAdServed(),
                    'mandatoryFields' => areMandatoryFieldsPopulated(),
                    'cloneable' => isCloneable(),
                    'started' => isStarted(),
                    'booked' => isBooked(),
                    'customerApproved' => isCustomerApproved(),
                    'OppClosedWon' => isOppClosedWon(),
                    'prereserve' => isPrereserve(),
                    'reserveRelease' => isReserveRelease(),
                    'inApproval' => isInApproval(),
                    'approver' => isApprover(),
                    'submitter' => isSubmitter(),
                    'orchestrated' => isInOrchestration()
                };
            }

            return additionalProperties;
        }
        set;
    }

    protected String getStatus() {
        return salesOrder.Loading_Screen__c == 'On' ? 'Pending' : salesOrder.csmso__Status__c;
    }

    protected Boolean isRetracted() {
        return String.isNotBlank(getStatus()) && this.salesOrder.Last_Date_Booked__c != null &&
                getStatus() != StandardSalesOrderStateManager.SO_BOOKED;
    }

    protected Boolean isReserved() {
        if(salesOrder.Last_Date_Booked__c != null) return false;
        for(cscfga__Product_Configuration__c cfg : configs.values()) {
            if(CS_utl_ProductConfiguration.isReserved(cfg)) {
                return true;
            }
        }

        return false;
    }

    protected Boolean isReserveRelease() {
        if(salesOrder.Last_Date_Booked__c != null) return false;

        for(cscfga__Product_Configuration__c cfg : configs.values()) {
            if(String.isNotBlank(cfg.Reservation_Status__c) &&
                ((cfg.Reserve_Inventory__c == true && !CS_utl_ProductConfiguration.isReserved(cfg)) ||
                (cfg.Reserve_Inventory__c == false && CS_utl_ProductConfiguration.isReserved(cfg)))) {
                return true;
            }
        }

        return false;
    }

    protected Boolean isPrereserve() {
        if(salesOrder.SO_Lines_Number_lines_RI__c == 0) return false;
        for(cscfga__Product_Configuration__c cfg : configs.values()) {
            if(String.isNotBlank(cfg.Reservation_Status__c)) return false;
        }

        return true;
    }

    protected Boolean isBooked() {
        return ((salesOrder.is_Programmatic__c && salesOrder.Last_Date_Approved__c != null) ||
                (!salesOrder.is_Programmatic__c && salesOrder.Last_Date_Booked__c != null));
    }
    protected Boolean isCustomerApproved(){
          return (salesOrder.Customer_Approval__c == 'Approved');
    }
    protected Boolean isOppClosedWon(){
        List<Opportunity> oppList = [Select Id, Name, StageName from Opportunity where Primary_Sales_Order__c =: salesOrder.Id];
        if(!oppList.isEmpty())
            return (oppList[0].StageName == 'Closed Won');
        else
            return false;
    }

    protected Boolean isAdServed() {
        return salesOrder.SO_Lines_Ad_Server_Items__c > 0;
    }

    protected Boolean areMandatoryFieldsPopulated() {
        for(String mField : MandatoryFields) {
            if(salesOrder.get(mField) == null) {
                return false;
            }
        }

        return true;
    }

    protected Boolean isCloneable() {
        for(cscfga__Product_Configuration__c cfg : this.configs.values()) {
            if(cfg.Can_Be_Cloned__c) return true;
        }

        return false;
    }

    protected Boolean isStarted() {
        return salesOrder.From_Date_Time_Calculated__c == null || salesOrder.From_Date_Time_Calculated__c >= Datetime.now();
    }

    protected Boolean isPrimaryEnabled() {
        if (salesOrder.Primary_Sales_Order__c == true) {
            return false;
        }
        return relatedSOsNotSubmitted();
    }

    protected Boolean isInApproval() {
        return !workItems.isEmpty();
    }

    protected Boolean isApprover() {
        if(isSysAdmin()) return true;

        for (ProcessInstanceWorkitem wi : workItems) {
            if (String.valueOf(wi.ActorId).startsWith('00G')) {
                List<GroupMember> groupMembers = [SELECT UserOrGroupId
                                                  FROM GroupMember
                                                  WHERE GroupId = :wi.ActorId AND UserOrGroupId = :UserInfo.getUserId()];
                if (!groupMembers.isEmpty()) {
                   return true;
                }
            }
            else if (UserInfo.getUserId() == wi.ActorId) {
                return true;
            }
        }

        return false;
    }

    protected Boolean isSubmitter() {
        return UserInfo.getUserId() == salesOrder.Submitted_By__c || isSysAdmin();
    }

    protected Boolean isGroupMember(String gName) {
        return groupMembership.containsKey(gName);
    }

    protected Boolean isSysAdmin() {
        return profile.Name == 'System Administrator' || profile.Name == 'Delegated System Administrator' || profile.Name == 'API User Profile'  || profile.Name == 'S: Systems Administrator';
    }

    protected Boolean isInOrchestration() {
        return !orchestrationProcessitems.isEmpty();
    }

    protected Map<String, StateManagerProperty> getStageProperties(String sType, String stage) {
        Map<String, StateManagerProperty> salesOrderProps = new Map<String, StateManagerProperty>();
        Map<String, List<StateManagerProperty>> stageProperties = stateManagerDefinition.get(sType).stages.get(stage);

        for(String smpt : StateManagerPropertyType) {
            for(StateManagerProperty smp : stageProperties.get(smpt)) {
                salesOrderProps.put(smp.name, smp);
            }
        }

        return salesOrderProps;
    }

    protected Map<String, StateManagerProperty> getPermissionProperties(String sType, String permission) {
        Map<String, StateManagerProperty> salesOrderProps = new Map<String, StateManagerProperty>();
        Map<String, List<StateManagerProperty>> permissionProperties = stateManagerDefinition.get(sType).permissions.get(permission);

        for(String smpt : StateManagerPropertyType) {
            for(StateManagerProperty smp : permissionProperties.get(smpt)) {
                salesOrderProps.put(smp.name, smp);
            }
        }

        return salesOrderProps;
    }

    protected Set<String> getPermissions(String sType) {
        return stateManagerDefinition.get(sType).permissions.keySet();
    }

    private void setDefaultProperties() {
        Map<String, StateManagerProperty> stageProperties = getStageProperties('base', 'default');
        Map<String, StateManagerProperty> permissionProperties = getPermissionProperties('base', 'default');

        for(String sp : stageProperties.keySet()) {
            salesOrderProperties.put(sp, new SalesOrderProperty(stageProperties.get(sp).status, permissionProperties.get(sp).status));
        }
    }

    public void setSalesOrderStageProperty(String property, String status) {
        salesOrderProperties.get(property).stageStatus = status;
    }

    public void setSalesOrderPermissionProperty(String property, String status) {
        salesOrderProperties.get(property).permissionStatus = status;
    }

    protected void setStageProperties(String sType, String stage) {
        Map<String, StateManagerProperty> stageProperties = getStageProperties(sType, stage);
        for(String stageProperty : stageProperties.keySet()) {
            if(stageProperties.get(stageProperty).isActive(this.additionalProperties)) {
                setSalesOrderStageProperty(stageProperty, stageProperties.get(stageProperty).status);
            }
        }
    }

    protected void setPermissionProperties(String sType) {
        for(String permission : getPermissions(sType)) {
            if(cpr.hasPermission(permission) || permission == 'default') {
                Map<String, StateManagerProperty> permissionProperties = getPermissionProperties(sType, permission);
                for(String permissionProperty : permissionProperties.keySet()) {
                    if(permissionProperties.get(permissionProperty).isActive(this.additionalProperties)) {
                       setSalesOrderPermissionProperty(permissionProperty, permissionProperties.get(permissionProperty).status);
                    }
                }
            }
        }
    }

    protected Map<String, String> getSalesOrderProperties() {
        Map<String, String> properties = new Map<String, String>();
        for(String prop : salesOrderProperties.keySet()) {
            properties.put(prop, salesOrderProperties.get(prop).getStatus());
        }

        return properties;
    }

    protected void setTypeProperties(String sType, String salesOrderStatus) {
        setStageProperties(sType, salesOrderStatus);
        setPermissionProperties(sType);
    }

    protected abstract void setAdditionalTypeProperties();

    /**
     * Needs to be called upon state manager object creation
     */
    public virtual void init(csmso__Sales_Order__c salesOrder) {
        this.salesOrder = salesOrder;
    }
    
    public virtual void validateChange() {

        csmso__Sales_Order__c oldSalesOrder = [
            SELECT Id, Primary_Sales_Order__c
                FROM csmso__Sales_Order__c
                WHERE Id = :salesOrder.Id
        ];

        checkPrimarySO(oldSalesOrder);
    }

    public class PrimarySOException extends Exception {}

    // SO to be submitted and progress in lifecycle should have been set as primary so checking other statuses
    // similarly to isPrimaryEnabled

    private Boolean relatedSOsNotSubmitted() {
        for(csmso__Sales_Order__c relatedSalesOrder : relatedSalesOrders) {
            if ((relatedSalesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_REJECTED && relatedSalesOrder.In_Retraction__c != false)
                    || (relatedSalesOrder.csmso__Status__c != StandardSalesOrderStateManager.SO_DRAFT
                    && relatedSalesOrder.csmso__Status__c != StandardSalesOrderStateManager.SO_IN_PROGRESS
                    && relatedSalesOrder.csmso__Status__c != StandardSalesOrderStateManager.SO_KILLED)) {
                return false;
            } else if (relatedSalesOrder.Last_Date_Booked__c != null && (relatedSalesOrder.Last_Date_Booked__c != null && relatedSalesOrder.csmso__Status__c != StandardSalesOrderStateManager.SO_KILLED)){
                return false;
            }
        }

        return true;
    }

    private void checkPrimarySO(csmso__Sales_Order__c oldSalesOrder) {
        if(!oldSalesOrder.Primary_Sales_Order__c && salesOrder.Primary_Sales_Order__c) {
            if ( !relatedSOsNotSubmitted() ) {
                throw new PrimarySOException(CS_const_SalesOrder.PRIMARY_SO_ALREADY_CHECKED);
            }
        }
    }

    public Map<String, String> getFieldProperties() {
        setDefaultProperties();
        setPermissionProperties('base');
        setAdditionalProperties();

        setTypeProperties(this.managerType, getStatus());
        setAdditionalTypeProperties();

        return getSalesOrderProperties();
    }

    protected void setAdditionalProperties() {
        if(salesOrder.Market__c == null) {
            setSalesOrderStageProperty('Rate_Card__c', 'D');
        }

        if(salesOrder.Agency_Final__c == null){
            setSalesOrderStageProperty('Media_Agency_Commission__c', 'D');
        }
    }

    public class SalesOrderProperty {
        public String stageStatus {get; set;}
        public String permissionStatus {get; set;}

        public SalesOrderProperty(String stageStatus, String permissionStatus) {
            this.stageStatus = stageStatus;
            this.permissionStatus = permissionStatus;
        }

        public String getStatus() {
            if(this.stageStatus == 'H' || this.permissionStatus == 'H') return 'H';
            else if(this.stageStatus == 'D' || this.permissionStatus == 'D') return 'D';
            else if(this.stageStatus == 'M' || this.permissionStatus == 'M') return 'M';
            else if(this.stageStatus == 'E' || this.permissionStatus == 'E') return 'E';
            else return 'H';
        }
    }

    public class StateManagerType {
        public Map<String, Map<String, List<StateManagerProperty>>> stages {get; set;}
        public Map<String, Map<String, List<StateManagerProperty>>> permissions {get; set;}

        public StateManagerType() {
            this.stages = new Map<String, Map<String, List<StateManagerProperty>>>();
            this.permissions = new Map<String, Map<String, List<StateManagerProperty>>>();
        }
    }

    public class StateManagerProperty {
        public String name {get; set;}
        public String status {get; set;}
        public Map<String, Boolean> additionalProperties {get; set;}

        public StateManagerProperty() {}

        public StateManagerProperty(String name, String status) {
            this.name = name;
            this.status = status;
            this.additionalProperties = new Map<String, Boolean>();
        }

        public Boolean isActive(Map<String, Boolean> additionalProperties) {
            if(this.additionalProperties == null || this.additionalProperties.isEmpty()) return true;

            Boolean isActive = true;
            for(String additionalProperty : additionalProperties.keySet()) {
                isActive = isActive && (this.additionalProperties.get(additionalProperty) == null || 
                            this.additionalProperties.get(additionalProperty) == additionalProperties.get(additionalProperty));
            }

            return isActive;
        }
    }
}
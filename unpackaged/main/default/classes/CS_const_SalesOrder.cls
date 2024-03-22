/**
 * @name CS_const_SalesOrder
 * @description Constants for Sales Order object
 */
public with sharing class CS_const_SalesOrder {
    /**
     * Picklist Values
     */
    public static final String ProcessMessageSeverity_Information = 'information';
    public static final String ProcessMessageSeverity_Warning = 'warning';
    public static final String ProcessMessageSeverity_Error = 'error';
    
    public static final String Status_Pending = 'Pending';
    public static final String Status_Draft = 'Draft';
    public static final String Status_InProgress = 'In Progress';
    public static final String Status_Rejected = 'Rejected';
    public static final String Status_PriceRecalculationRequired = 'Price Recalculation Required';
    public static final String Status_Retracted = 'Retracted';
    public static final String Status_Reserved = 'Reserved';
    public static final String Status_PendingBooking = 'Pending Booking';
    public static final String Status_Booked = 'Booked';
    public static final String Status_ReservationRejected = 'Reservation Rejected';
    public static final String Status_ReadyForCustomerApproval = 'Ready for Customer Approval';
    public static final string Status_UpdateProposalOrder = 'Update Proposal/Order';
    public static final String Status_PendingCustomerApproval = 'Pending Customer Approval';
    public static final String Status_PendingApprovals = 'Pending Approvals';
    public static final String Status_PendingLegalApproval = 'Pending Legal Approval';
    public static final String Status_PendingCountersignIOApproval = 'Pending Countersign IO Approval';
    public static final String Status_PendingComplianceApproval = 'Pending Compliance Approval';
    public static final String Status_AccountCheck = 'Account Check';
    public static final String Status_Killed = 'Killed';

    public static final String Status_PendingOMCApproval = 'Pending OMC Approval';
    
    public static final String OpportunityStatus_ClosedWon = 'Closed Won';
    public static final String OpportunityAgreement_OutForSignature = 'Out for Signature';
    public static final String OpportunityAgreement_Signed = 'Signed';
    public static final String OpportunityAgreement_Cancelled = 'Cancelled / Declined';
       
    public static final String ScheduleStatus_Open = 'Open';
    public static final String ScheduleStatus_Forecast = 'Forecast';
    public static final String ScheduleStatus_Locked = 'Locked';
    public static final String ScheduleStatus_Ready = 'Ready';
    public static final String ScheduleStatus_Closed = 'Closed';
    public static final String ScheduleStatus_PendingClosure = 'Pending Closure';
    public static final String ScheduleStatus_Pending = 'Pending';
    public static final String ScheduleStatus_Cancelled = 'Cancelled';
    
    public static final String ScheduleType_Billing = 'Billing';
    public static final String ScheduleType_Revenue = 'Revenue';
    
    public static final String BillingSource_DFPActuals = 'DFP Actuals';
    public static final String BillingSource_3rdPartyActuals = '3rd Party Actuals';
    public static final String BillingSource_Contracted = 'Contracted';
    public static final String BillingSource_Megaphone = 'Megaphone';
    
    public static final String ProductConfigurationStatus_Valid = 'Valid';
    public static final String ProductConfigurationStatus_Incomplete = 'Incomplete';
    
    public static final String FulfilmentItemStatus_PausedInventoryReleased = 'Paused Inventory Released';
    public static final String FulfilmentItemStatus_Paused = 'Paused';
    public static final String FulfilmentItemStatus_Draft = 'Draft';
    public static final String FulfilmentItemStatus_Inactive = 'Inactive';
    public static final String FulfilmentItemStatus_Ready = 'Ready';
    public static final String FulfilmentItemStatus_Reserved = 'Reserved';
    public static final String FulfilmentItemStatus_NotReserved = 'Not Reserved';
    public static final String FulfilmentItemStatus_InventoryReleased = 'Inventory Released';
    public static final String FulfilmentItemStatus_Delivering = 'Delivering';
    public static final String FulfilmentItemStatus_Completed = 'Completed';
    
    public static final String FulfilmentItemManualTrackingStatus_Cancelled = 'Cancelled';

    public static final String FulfilmentStatus_Draft = 'Draft';
    public static final String FulfilmentStatus_Completed = 'Completed';
    
    public static final String ApprovalStatus_Approved = 'Approved';
    public static final String ApprovalStatus_Rejected = 'Rejected';
    public static final String ApprovalStatus_Pending = 'Pending';
    
    public static final String InsertionType_CPM = 'CPM';
    public static final String InsertionType_CPCV = 'CPCV';
    public static final String InsertionType_CPCL = 'CPCL';

    public static final String OrchestratorStatus_Complete = 'Complete';
    public static final String OrchestratorState_Terminated = 'Terminated';
     
    /**
     * Messages
     */
	public static final String IO_VOLUME_APPLICABLE = 'Sales Order is applicable for an IO Volume Discount. Applying/removing IO Volume Discount will override Net Rate Adjustment value.';
	public static final String IO_VOLUME_APPLICABLE_TOOHIGH = 'Applied IO Volume Discount is higher than allowed IO Volume Discount. Please remove or recalculate the IO Volume discount.';
	public static final String IO_VOLUME_NOTAPPLICABLE = 'Sales Order is not applicable for an IO Volume Discount, but an IO Volume Discount has been previously applied. Please remove the IO Volume discount before continuing.';
	public static final String IO_VOLUME_TOTALAMOUNT = 'Please increase the Total Amount or remove the IO Volume Discount before continuing.';
	public static final String IO_VOLUME_MULTIMARKET = 'IO Volume Discount is not applicable on Multi Market deals.';

    public static final String PRIMARY_SO_ALREADY_CHECKED = 'Primary Sales Order already checked on this Opportunity.';

    /**
     * Attachment file names
     */
    public static final String FILE_NAME_SALES_ORDER_SCREENSHOT = 'SalesOrderScreenshot.json';
    public static final String FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT = 'Order_SalesOrderScreenshot.json';
    public static final String FILE_NAME_PROPOSAL_SALES_ORDER_SCREENSHOT = 'Proposal_SalesOrderScreenshot.json';

    public static final String FILE_NAME_ATTRIBUTES_AS_JSON = 'Attributes as JSON';
    public static final String FILE_NAME_ATTRIBUTES_AS_JSON_SCREENSHOT = 'Attributes as JSON - Screenshot';
    public static final String FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT = 'Attributes as JSON - Order Screenshot';
    public static final String FILE_NAME_ATTRIBUTES_AS_JSON_PROPOSAL_SCREENSHOT = 'Attributes as JSON - Proposal Screenshot';
}
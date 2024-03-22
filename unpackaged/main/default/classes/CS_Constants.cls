public class CS_Constants {

    public static final Pattern DYNAMIC_LOOKUP_STRING_PATTERN = Pattern.compile('\\{(\\$Lookup\\([^\\)]+\\))[^\\}]*\\}');

    // to be deprecated

    public static final String FILE_NAME_APPROVAL_SNAPSHOT = 'ApprovalSnapshot.json';

    // attachment file names
    public static final String FILE_NAME_INVENTORY_APPROVAL_SNAPSHOT = 'InventoryApprovalSnapshot.json';
    public static final String FILE_NAME_SALES1_APPROVAL_SNAPSHOT = 'Sales1ApprovalSnapshot.json';
    public static final String FILE_NAME_SALES2_APPROVAL_SNAPSHOT = 'Sales2ApprovalSnapshot.json';
    public static final String FILE_NAME_FINANCE_APPROVAL_SNAPSHOT = 'FinanceApprovalSnapshot.json';
    public static final String FILE_NAME_LEGAL_APPROVAL_SNAPSHOT = 'LegalApprovalSnapshot.json';
    public static final String FILE_NAME_COMPLIANCE_APPROVAL_SNAPSHOT = 'ComplianceApprovalSnapshot.json';
    public static final String FILE_NAME_CUSTOMER_APPROVAL_SNAPSHOT = 'CustomerApprovalSnapshot.json';
    public static final String FILE_NAME_SD_APPROVAL_SNAPSHOT = 'SDApprovalSnapshot.json';

    public static final String FILE_NAME_INVENTORY_APPROVAL_SNAPSHOT_RESULT = 'InventoryApprovalSnapshot_Result.json';
    public static final String FILE_NAME_SALES1_APPROVAL_SNAPSHOT_RESULT = 'Sales1ApprovalSnapshot_Result.json';
    public static final String FILE_NAME_SALES2_APPROVAL_SNAPSHOT_RESULT = 'Sales2ApprovalSnapshot_Result.json';
    public static final String FILE_NAME_FINANCE_APPROVAL_SNAPSHOT_RESULT = 'FinanceApprovalSnapshot_Result.json';
    public static final String FILE_NAME_LEGAL_APPROVAL_SNAPSHOT_RESULT = 'LegalApprovalSnapshot_Result.json';
    public static final String FILE_NAME_COMPLIANCE_APPROVAL_SNAPSHOT_RESULT = 'ComplianceApprovalSnapshot_Result.json';
    public static final String FILE_NAME_CUSTOMER_APPROVAL_SNAPSHOT_RESULT = 'CustomerApprovalSnapshot_Result.json';
    // attachment file names

    public static final String APPROVAL_INVENTORY = 'Inventory';
    public static final String APPROVAL_SALES_1 = 'Sales 1';
    public static final String APPROVAL_SALES_2 = 'Sales 2';
    public static final String APPROVAL_FINANCE = 'Finance';
    public static final String APPROVAL_LEGAL = 'Legal';
    public static final String APPROVAL_COMPLIANCE = 'Compliance';
    public static final String APPROVAL_CUSTOMER = 'Customer';

    public static final String STATUS_FORECAST = 'Forecast';
    public static final String STATUS_CANCELLED = 'Cancelled';
    public static final String STATUS_OPEN ='Open';
    public static final String STATUS_PAUSED_INVENTORY_RELEASED = 'Paused Inventory Released';

    public static final String ORDER_TYPE_HOUSE_GUARANTEED = 'House Guaranteed';
    public static final String ORDER_TYPE_HOUSE_NON_GUARANTEED = 'House Non-Guaranteed';
    public static final String ORDER_TYPE_LABELS_ADCREDIT = 'Labels AdCredit';

    public static final String CREATIVE_ROTATION_TYPE_MANUAL = 'Manual';
    public static final String CREATIVE_ROTATION_TYPE_WEIGHTED = 'Weighted';

    public static final String RESERVATION_STATUS_RESERVED = 'RESERVED';
    public static final String RESERVATION_STATUS_CHECK_LINE_ITEM_RESERVATION_STATUS = 'CHECK_LINE_ITEM_RESERVATION_STATUS';

    public static final String PROGRAMMATIC_GUARANTEED_QUALIFIED_API_NAME = 'Programmatic_Guaranteed';
    public static final String NON_AD_SERVED_QUALIFIED_API_NAME = 'Non_Ad_Served';
    public static final String AD_SERVED_QUALIFIED_API_NAME = 'Ad_Served';
    public static final String PODCAST_QUALIFIED_API_NAME = 'Podcast';

    public static final String EMAIL_TEMPLATE_CA_REMINDER_TEMPLATE = 'ClickApprove Reminder Template';
}
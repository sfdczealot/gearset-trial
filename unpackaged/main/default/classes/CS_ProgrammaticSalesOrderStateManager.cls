/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Programmatic SO-specific State Manager functionality
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Frano Vojvodic   <frano.vojvodic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            name@email.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text. 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_ProgrammaticSalesOrderStateManager extends CS_SalesOrderStateManagerBase {
    public static final Set<String> PG_STATUSES_TO_REFRESH = new Set<String> {
        StandardSalesOrderStateManager.SO_BOOKED,
        StandardSalesOrderStateManager.SO_PENDING_BOOKING,
        StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL_READY,
        StandardSalesOrderStateManager.SO_UPDATE_PROPOSAL,
        StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL
    };

    public static final Map<String, String> PG_DFP_TO_SO_STATUSES = new Map<String, String> {       
        'SELLER_INITIATED-DRAFT' => StandardSalesOrderStateManager.SO_RESERVED,
        'BUYER_INITIATED-APPROVED' => StandardSalesOrderStateManager.SO_IN_PROGRESS,
        'AWAITING_SELLER_REVIEW-APPROVED' => StandardSalesOrderStateManager.SO_CHANGED_BY_BUYER,
        'AWAITING_BUYER_REVIEW-APPROVED' => StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL,
        'ONLY_SELLER_ACCEPTED-APPROVED' => StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL,
        'FINALIZED-APPROVED' => StandardSalesOrderStateManager.SO_BOOKED,
        'FINALIZED-DRAFT' => StandardSalesOrderStateManager.SO_RETRACTED,
        'CANCELLED-APPROVED' => StandardSalesOrderStateManager.SO_KILLED
    };
            
    public CS_ProgrammaticSalesOrderStateManager() {
        this.managerType = 'programmatic';
    }
    
    protected override void setAdditionalTypeProperties() {
        if(!isPrimaryEnabled()){
            setSalesOrderStageProperty('Primary_Sales_Order__c', 'D');
        }
    }
}
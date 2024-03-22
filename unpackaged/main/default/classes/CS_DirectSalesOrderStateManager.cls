/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Direct SO-specific State Manager functionality 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Frano Vojvodic   <frano.vojvodic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            name@email.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text. 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_DirectSalesOrderStateManager extends CS_SalesOrderStateManagerBase {
    public CS_DirectSalesOrderStateManager() {
        this.managerType = 'direct';
    }
    
    protected override void setAdditionalTypeProperties() {
        if(!isPrimaryEnabled()){
            setSalesOrderStageProperty('Primary_Sales_Order__c', 'D');
        }
    }
}
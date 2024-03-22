/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update time SO spent in specific status ['Pending Inventory Approval', 'Pending Sales 
* Approval', 'Pending Customer Approval'].
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            aldo.topic@cloudsense.com
* 2019-06-05      Initial version 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_SOStatusCalculateTime extends CS_ProcessBase {
	@TestVisible 
    Map<Id, csmso__Sales_Order__c> applicableObjects;
    
    @TestVisible
    Map<Id, csmso__Sales_Order__c> oldObjects;

    private static final Map<String, String> SO_STATUS_TO_TOTAL_TIME_FILED = new Map<String, String> {
    	'Pending Inventory Approval' 	=> 'Pending_Inventory_Approval_Time__c',
    	'Pending Sales Approval' 		=> 'Pending_Sales_Approval_Time__c',
    	'Pending Finance Approval' 		=> 'Pending_Finance_Approval_Time__c'
    };

	public CS_P_SOStatusCalculateTime(Map<Id, csmso__Sales_Order__c> oldObjects) {
        super(CS_ProcessDefinition.SO_STATUSCALCULATETIME, 'CS_P_SOStatusCalculateTime');
        
        this.oldObjects = oldObjects;
        applicableObjects = new Map<Id, csmso__Sales_Order__c>();
    }

    public override void isRecordEligible(SObject obj) {
        csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
        csmso__Sales_Order__c oldSalesOrder = (csmso__Sales_Order__c) oldObjects.get(newSalesOrder.Id);

        if(oldSalesOrder.csmso__Status__c != newSalesOrder.csmso__Status__c 
        	&& (SO_STATUS_TO_TOTAL_TIME_FILED.containsKey(oldSalesOrder.csmso__Status__c) || SO_STATUS_TO_TOTAL_TIME_FILED.containsKey(newSalesOrder.csmso__Status__c))) {
        	applicableObjects.put(newSalesOrder.Id, newSalesOrder);
        }

        this.runProcess = !applicableObjects.isEmpty();
    }

    public override void logic() {
        for(csmso__Sales_Order__c salesOrder : applicableObjects.values()) {

        	if(salesOrder.Last_Status_Change__c == null) {
				salesOrder.Last_Status_Change__c = Datetime.now();
        	}
        	else {
        		Decimal currentDurationInStatus;
        		Datetime lastStatusChangeTime = Datetime.valueOf(salesOrder.Last_Status_Change__c);
        		salesOrder.Last_Status_Change__c = Datetime.now();
        		
        		if(SO_STATUS_TO_TOTAL_TIME_FILED.get(oldObjects.get(salesOrder.Id).csmso__Status__c) != null && CS_utl_SObject.getFieldValue(salesOrder, SO_STATUS_TO_TOTAL_TIME_FILED.get(oldObjects.get(salesOrder.Id).csmso__Status__c)) != null) {
        			currentDurationInStatus = Decimal.valueOf(CS_utl_SObject.getFieldValue(salesOrder, SO_STATUS_TO_TOTAL_TIME_FILED.get(oldObjects.get(salesOrder.Id).csmso__Status__c)));
					currentDurationInStatus += (Decimal) (salesOrder.Last_Status_Change__c.getTime() - lastStatusChangeTime.getTime())/3600000;
					salesOrder.put(SO_STATUS_TO_TOTAL_TIME_FILED.get(oldObjects.get(salesOrder.Id).csmso__Status__c), currentDurationInStatus);
        		}
        	}
        }
    }
}
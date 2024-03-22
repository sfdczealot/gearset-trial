/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used open quantity on RSI
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sasa Marjancic   <sasa.marjancic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_UpdateOpenQuantityRevenue extends CS_ProcessBase {      
	@TestVisible 
	Map<Id, CS_Revenue_Schedule_Item__c> applicableObjects;

    @TestVisible 
	Map<Id, CS_Revenue_Schedule_Item__c> oldObjects;

    @TestVisible
    Set<Id> revenueScheduleIds;

	public CS_P_UpdateOpenQuantityRevenue(Map<Id, CS_Revenue_Schedule_Item__c> oldObjects) {
		super(CS_ProcessDefinition.RSI_UPDATEOPENQUANTITY, 'CS_P_UpdateOpenQuantityRevenue');

		applicableObjects = new Map<Id, CS_Revenue_Schedule_Item__c>();
        revenueScheduleIds = new Set<Id>();
        this.oldObjects = oldObjects;
	}
 
	public override void isRecordEligible(SObject obj) {
		CS_Revenue_Schedule_Item__c revenueScheduleItem = (CS_Revenue_Schedule_Item__c) obj;
        CS_Revenue_Schedule_Item__c oldRevenueScheduleItem = oldObjects.get(revenueScheduleItem.Id);
		
		if(revenueScheduleItem.Total_Open_Qty__c != oldRevenueScheduleItem.Total_Open_Qty__c) {
			applicableObjects.put(revenueScheduleItem.Id, revenueScheduleItem);
            revenueScheduleIds.add(revenueScheduleItem.Revenue_Schedule__c);
		}

		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
        Map<Id, List<CS_Revenue_Schedule_Item__c>> revenueScheduleItems = new Map<Id, List<CS_Revenue_Schedule_Item__c>>();
        for(CS_Revenue_Schedule_Item__c rsi : [SELECT Id, Revenue_Schedule__c, Rev_Rec_Period_Start_Date__c
                                                FROM CS_Revenue_Schedule_Item__c
                                                WHERE Revenue_Schedule__c = :revenueScheduleIds
                                                AND Status__c = :CS_const_SalesOrder.ScheduleStatus_Open
                                                AND Id != :applicableObjects.keySet()]) {
            if(!revenueScheduleItems.containsKey(rsi.Revenue_Schedule__c)) {
                revenueScheduleItems.put(rsi.Revenue_Schedule__c, new List<CS_Revenue_Schedule_Item__c>());
            }
            revenueScheduleItems.get(rsi.Revenue_Schedule__c).add(rsi);
        }

        List<CS_Revenue_Schedule_Item__c> rsiToUpdate = new List<CS_Revenue_Schedule_Item__c>();
        for(CS_Revenue_Schedule_Item__c rsi : applicableObjects.values()) {
            List<CS_Revenue_Schedule_Item__c> currentRevenueScheduleItems = revenueScheduleItems.get(rsi.Revenue_Schedule__c);
            if(currentRevenueScheduleItems != null) {
                for(CS_Revenue_Schedule_Item__c currentRsi : currentRevenueScheduleItems) {
                    currentRsi.Total_Open_Qty_in_Previous_Period__c = rsi.Total_Open_Qty__c;
                    rsiToUpdate.add(currentRsi);
                }
            }
        }

        if(!rsiToUpdate.isEmpty()) {
            update rsiToUpdate;
        }
	}
}
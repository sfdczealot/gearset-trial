/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update handle update RSI logic after changes on following fields Advertiser__c, Agency__c, Bill_To_Account__c
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ivan Ravnjak   <ivan.ravnjak@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ivan.ravnjak@cloudsense.com
* 2019-04-15      Initial version 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_SOBillAdvertiserAgencyChange extends CS_ProcessBase {
	@TestVisible 
	Map<Id, csmso__Sales_Order__c> applicableObjects;
	
	@TestVisible
	Map<Id, csmso__Sales_Order__c> oldObjects;

	public CS_P_SOBillAdvertiserAgencyChange(Map<Id, csmso__Sales_Order__c> oldObjects) {
		super(CS_ProcessDefinition.SO_BILLADVERTISERAGENCYCHANGE, 'CS_P_SOBillAdvertiserAgencyChange');
		
		this.oldObjects = oldObjects;
		applicableObjects = new Map<Id, csmso__Sales_Order__c>();
	}
 
	public override void isRecordEligible(SObject obj) {
		csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
		csmso__Sales_Order__c oldSalesOrder = oldObjects != null ? (csmso__Sales_Order__c) oldObjects.get(newSalesOrder.Id) : null;

		if(oldSalesOrder.Bill_To_Account_Final__c !=  newSalesOrder.Bill_To_Account_Final__c){
            applicableObjects.put(newSalesOrder.Id, newSalesOrder);
        } 
        else if(oldSalesOrder.Advertiser_Final__c !=  newSalesOrder.Advertiser_Final__c){
            applicableObjects.put(newSalesOrder.Id, newSalesOrder);
        }
        else if(oldSalesOrder.Agency_Final__c != newSalesOrder.Agency_Final__c) {
        	applicableObjects.put(newSalesOrder.Id, newSalesOrder);
        }


		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		List<CS_Revenue_Schedule_Item__c> rScheduleItems  = new List<CS_Revenue_Schedule_Item__c>();
		List<CS_Revenue_Schedule_Item__c> updateRSchedules  = new List<CS_Revenue_Schedule_Item__c>();

		//Fetching Billing Schedules.
		rScheduleItems = [select id, Advertiser__c, Agency__c, Bill_To_Account__c, Sales_Order__c  FROM CS_Revenue_Schedule_Item__c
			                                                      WHERE Sales_Order__c IN :applicableObjects.keySet()
			                                                      AND (Status__c =:CS_const_SalesOrder.ScheduleStatus_Forecast OR 
			                                                      	   Status__c =:CS_const_SalesOrder.ScheduleStatus_Open)];

		if ( !rScheduleItems.isEmpty() ){
			for (CS_Revenue_Schedule_Item__c currRSchedule : rScheduleItems){
				csmso__Sales_Order__c currSO = applicableObjects.get(currRSchedule.Sales_Order__c);
				
				currRSchedule.Advertiser__c = currSO.Advertiser_Final__c;
				currRSchedule.Agency__c = currSO.Agency_Final__c;
				currRSchedule.Bill_To_Account__c = currSO.Bill_To_Account_Final__c;

				updateRSchedules.add(currRSchedule);
			}
		}
		
		if( !updateRSchedules.isEmpty() ){
			UPDATE updateRSchedules;
		}
	}
}
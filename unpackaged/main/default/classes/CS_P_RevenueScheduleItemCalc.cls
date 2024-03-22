/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to quantity and amount on RSI
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sasa Marjancic   <sasa.marjancic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            sasa.marjancic@cloudsense.com
* 2018-10-08      Initial version 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_RevenueScheduleItemCalc extends CS_ProcessBase {      
	@TestVisible 
	Map<Id, CS_Revenue_Schedule_Item__c> applicableObjects;

	public CS_P_RevenueScheduleItemCalc() {
		super(CS_ProcessDefinition.RSI_CALCULATION, 'CS_P_RevenueScheduleItemCalc');

		applicableObjects = new Map<Id, CS_Revenue_Schedule_Item__c>(); 
	}
 
	public override void isRecordEligible(SObject obj) {
		CS_Revenue_Schedule_Item__c revenueScheduleItem = (CS_Revenue_Schedule_Item__c) obj;
		
		if(String.isNotBlank(revenueScheduleItem.Status__c) && revenueScheduleItem.Status__c != CS_const_SalesOrder.ScheduleStatus_PendingClosure
			&& revenueScheduleItem.Status__c != CS_const_SalesOrder.ScheduleStatus_Closed) {
			applicableObjects.put(revenueScheduleItem.Id, revenueScheduleItem);
		}

		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		for(CS_Revenue_Schedule_Item__c revenueScheduleItem : applicableObjects.values()) {
			Integer decimalPlaces = CS_utl_Currency.getDecimalPlaces(revenueScheduleItem.CurrencyIsoCode);
			decimalPlaces = decimalPlaces == 0 ? 0 : 2;

			Decimal factor = String.isNotBlank(revenueScheduleItem.Insertion_Unit_Type__c) && (revenueScheduleItem.Insertion_Unit_Type__c == CS_const_SalesOrder.InsertionType_CPM
				|| revenueScheduleItem.Insertion_Unit_Type__c == CS_const_SalesOrder.InsertionType_CPCV || revenueScheduleItem.Insertion_Unit_Type__c == CS_const_SalesOrder.InsertionType_CPCL) ? 1000 : 1;
			revenueScheduleItem.Rev_Rec_Net_Amount__c = (CS_utl_SObject.getDecimalValue('Rev_Rec_Quantity__c', revenueScheduleItem)/factor) * CS_utl_SObject.getDecimalValue('Net_Rate__c', revenueScheduleItem);
            revenueScheduleItem.Rev_Rec_Net_Amount__c = revenueScheduleItem.Rev_Rec_Net_Amount__c.setScale(decimalPlaces, System.RoundingMode.DOWN);
            revenueScheduleItem.Rev_Rec_Gross_Amount__c = (CS_utl_SObject.getDecimalValue('Rev_Rec_Quantity__c', revenueScheduleItem)/factor) * CS_utl_SObject.getDecimalValue('Gross_Rate__c', revenueScheduleItem);
            revenueScheduleItem.Rev_Rec_Gross_Amount__c = revenueScheduleItem.Rev_Rec_Gross_Amount__c.setScale(decimalPlaces, System.RoundingMode.DOWN);
            revenueScheduleItem.Rev_Rec_Amount__c = revenueScheduleItem.Rev_Rec_Gross_Amount__c == null ? (revenueScheduleItem.Rev_Rec_Net_Amount__c + CS_utl_SObject.getDecimalValue('Revenue_Amount_Adjustment__c', revenueScheduleItem)) : revenueScheduleItem.Rev_Rec_Gross_Amount__c;          
            revenueScheduleItem.Rev_Rec_Amount__c = revenueScheduleItem.Rev_Rec_Amount__c.setScale(decimalPlaces, System.RoundingMode.DOWN);
			revenueScheduleItem.Booked_Gross_Amount__c = (CS_utl_SObject.getDecimalValue('Booked_Quantity__c', revenueScheduleItem)/factor) * CS_utl_SObject.getDecimalValue('Gross_Rate__c', revenueScheduleItem);
			revenueScheduleItem.Booked_Gross_Amount__c = revenueScheduleItem.Booked_Gross_Amount__c.setScale(decimalPlaces, System.RoundingMode.DOWN);
			revenueScheduleItem.Booked_Net_Amount__c = (CS_utl_SObject.getDecimalValue('Booked_Quantity__c', revenueScheduleItem)/factor) * CS_utl_SObject.getDecimalValue('Net_Rate__c', revenueScheduleItem);
			revenueScheduleItem.Booked_Net_Amount__c = revenueScheduleItem.Booked_Net_Amount__c.setScale(decimalPlaces, System.RoundingMode.DOWN);
		}
	}
}
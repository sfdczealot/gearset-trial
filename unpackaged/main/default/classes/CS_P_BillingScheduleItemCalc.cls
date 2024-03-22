/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to quantity and amount on BSI
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sasa Marjancic   <sasa.marjancic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            sasa.marjancic@cloudsense.com
* 2018-10-08      Initial version 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_BillingScheduleItemCalc extends CS_ProcessBase {      
	@TestVisible 
	Map<Id, CS_Billing_Schedule_Item__c> applicableObjects;

	public CS_P_BillingScheduleItemCalc() {
		super(CS_ProcessDefinition.BSI_CALCULATION, 'CS_P_BillingScheduleItemCalc');

		applicableObjects = new Map<Id, CS_Billing_Schedule_Item__c>(); 
	}
 
	public override void isRecordEligible(SObject obj) {
		CS_Billing_Schedule_Item__c billingScheduleItem = (CS_Billing_Schedule_Item__c) obj;
		
		if(String.isNotBlank(billingScheduleItem.Status__c) && billingScheduleItem.Status__c != CS_const_SalesOrder.ScheduleStatus_PendingClosure
			&& billingScheduleItem.Status__c != CS_const_SalesOrder.ScheduleStatus_Closed) {
			applicableObjects.put(billingScheduleItem.Id, billingScheduleItem);
		}

		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		for(CS_Billing_Schedule_Item__c billingScheduleItem : applicableObjects.values()) {
			Integer decimalPlaces = CS_utl_Currency.getDecimalPlaces(billingScheduleItem.CurrencyIsoCode);
			decimalPlaces = decimalPlaces == 0 ? 0 : 2;

			Decimal factor = String.isNotBlank(billingScheduleItem.Insertion_Unit_Type__c) && (billingScheduleItem.Insertion_Unit_Type__c == CS_const_SalesOrder.InsertionType_CPM
				|| billingScheduleItem.Insertion_Unit_Type__c == CS_const_SalesOrder.InsertionType_CPCV || billingScheduleItem.Insertion_Unit_Type__c == CS_const_SalesOrder.InsertionType_CPCL) ? 1000 : 1;
			billingScheduleItem.Billing_Net_Amount__c = (CS_utl_SObject.getDecimalValue('Billing_Quantity__c', billingScheduleItem)/factor) * CS_utl_SObject.getDecimalValue('Net_Rate__c', billingScheduleItem);
            billingScheduleItem.Billing_Net_Amount__c = billingScheduleItem.Billing_Net_Amount__c.setScale(decimalPlaces, System.RoundingMode.DOWN);
            billingScheduleItem.Billing_Gross_Amount__c = (CS_utl_SObject.getDecimalValue('Billing_Quantity__c', billingScheduleItem)/factor) * CS_utl_SObject.getDecimalValue('Gross_Rate__c', billingScheduleItem);
            billingScheduleItem.Billing_Gross_Amount__c = billingScheduleItem.Billing_Gross_Amount__c.setScale(decimalPlaces, System.RoundingMode.DOWN);
            billingScheduleItem.Billing_Amount__c = billingScheduleItem.Billing_Gross_Amount__c == null ? (billingScheduleItem.Billing_Net_Amount__c + CS_utl_SObject.getDecimalValue('Billing_Amount_Adjustment__c', billingScheduleItem)) : billingScheduleItem.Billing_Gross_Amount__c;  
            billingScheduleItem.Billing_Amount__c = billingScheduleItem.Billing_Amount__c.setScale(decimalPlaces, System.RoundingMode.DOWN);
			billingScheduleItem.Booked_Gross_Amount__c = (CS_utl_SObject.getDecimalValue('Booked_Quantity__c', billingScheduleItem)/factor) * CS_utl_SObject.getDecimalValue('Gross_Rate__c', billingScheduleItem);
			billingScheduleItem.Booked_Gross_Amount__c = billingScheduleItem.Booked_Gross_Amount__c.setScale(decimalPlaces, System.RoundingMode.DOWN);
			billingScheduleItem.Booked_Net_Amount__c = (CS_utl_SObject.getDecimalValue('Booked_Quantity__c', billingScheduleItem)/factor) * CS_utl_SObject.getDecimalValue('Net_Rate__c', billingScheduleItem);
			billingScheduleItem.Booked_Net_Amount__c = billingScheduleItem.Booked_Net_Amount__c.setScale(decimalPlaces, System.RoundingMode.DOWN);
		}
	}
}
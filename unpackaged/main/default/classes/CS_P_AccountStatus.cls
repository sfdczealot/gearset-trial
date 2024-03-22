/**
 * Created by ivan.ravnjak on 21.2.2020..
 */
public class CS_P_AccountStatus extends CS_ProcessBase {
	@TestVisible
	Map<Id, Account> applicableObjects;
	
	@TestVisible
	Map<Id, Account> oldObjects;
	
	public CS_P_AccountStatus(Map<Id, Account> oldObjects) {
		super(CS_ProcessDefinition.ACCOUNTSTATUS, 'CS_P_AccountStatus');
		
		this.oldObjects = oldObjects;
		applicableObjects = new Map<Id, Account>();
	}
	
	public override void isRecordEligible(SObject obj) {
		Account newAccount = (Account) obj;
		Account oldAccount = (Account) oldObjects.get(newAccount.Id);
		
		if( (oldAccount.Account_Status__c  == newAccount.Account_Status__c && newAccount.Account_Status__c == 'Approved')
				|| (oldAccount.CS_Approval_Status__c != newAccount.CS_Approval_Status__c && newAccount.CS_Approval_Status__c == 'Approved') ) {
			applicableObjects.put(newAccount.Id, newAccount);
		}
		this.runProcess = !applicableObjects.isEmpty();
	}
	
	public override void logic() {
		List<csmso__Sales_Order__c> salesOrders = [SELECT Id, Advertiser_Final__r.Account_Status__c,
																Advertiser_Final__r.CS_Approval_Status__c,
																Bill_To_Account_Final__r.Account_Status__c,
																Bill_To_Account_Final__r.CS_Approval_Status__c,
																csmso__Status__c, Account_Check_Approval__c, csmso__Opportunity__c
															FROM csmso__Sales_Order__c
															WHERE (Advertiser_Final__c IN :applicableObjects.keyset()
																OR Bill_To_Account_Final__c IN :applicableObjects.keyset() )
															AND csmso__Status__c IN ('Account Check')];
		if (salesOrders.size() > 0) {
			Set<Id> oppIds = new Set<Id>();
			for(csmso__Sales_Order__c salesOrder : salesOrders) {
				oppIds.add(salesOrder.csmso__Opportunity__c);
			}
			CSPOFA.Events.emit('update', oppIds);
		}
	}
}
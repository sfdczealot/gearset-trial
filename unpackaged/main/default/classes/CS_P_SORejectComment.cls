/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to handle logic for approving/rejecting Compliance and Legal checks
* Raises warning on SO if comment is empty on rejection or removes warning when it's not needed
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ivan Ravnjak   <ivan.ravnjak@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ivan.ravnjak@cloudsense.com
* 2019-3-14       Initial version 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_SORejectComment extends CS_ProcessBase {   
	@TestVisible 
	Map<Id, csmso__Sales_Order__c> applicableObjects;
	
	@TestVisible
	Map<Id, csmso__Sales_Order__c> oldObjects;

	public CS_P_SORejectComment(Map<Id, csmso__Sales_Order__c> oldObjects) {
		super(CS_ProcessDefinition.SO_REJECTCOMMENT, 'CS_P_SORejectComment');
		
		this.oldObjects = oldObjects;
		applicableObjects = new Map<Id, csmso__Sales_Order__c>(); 
	}
 
	public override void isRecordEligible(SObject obj) {
		csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
		csmso__Sales_Order__c oldSalesOrder = (csmso__Sales_Order__c) oldObjects.get(newSalesOrder.Id);
		//check if compliance or legal is changed and SO in status 'Reserved'
		if( (newSalesOrder.Compliance_Check__c != oldSalesOrder.Compliance_Check__c || newSalesOrder.Legal_Check__c != oldSalesOrder.Legal_Check__c) 
				&& (oldSalesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_RESERVED || oldSalesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_PENDING_BOOKING) ) {
			
			applicableObjects.put(newSalesOrder.Id, newSalesOrder);
		}
		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {	

		for(csmso__Sales_Order__c currentSO : applicableObjects.Values()){
			//system.debug('in logic '+JSON.serializePretty(currentSO));
			//When rejecting with blank comment, show warning to user
			if(currentSO.Compliance_Check__c == CS_const_SalesOrder.ApprovalStatus_Rejected){
				if(String.isBlank(currentSO.Comments__c)){
					currentSO.csmso__Process_Message_Type__c = 'warning';
					currentSO.csmso__Process_Message__c = Label.SO_Compliance_Legal_Reject_No_Comment;
					currentSO.Compliance_Check__c = CS_const_SalesOrder.ApprovalStatus_Pending;
					if ( currentSO.In_Retraction__c == true ){
						currentSO.csmso__Status__c = StandardSalesOrderStateManager.SO_PENDING_BOOKING;
					}
					else {
						currentSO.csmso__Status__c = StandardSalesOrderStateManager.SO_RESERVED;
					}
				} 
			}
			if(currentSO.Legal_Check__c == CS_const_SalesOrder.ApprovalStatus_Rejected){
				if(String.isBlank(currentSO.Comments__c)){
					currentSO.csmso__Process_Message_Type__c = 'warning';
					currentSO.csmso__Process_Message__c = Label.SO_Compliance_Legal_Reject_No_Comment;
					currentSO.Legal_Check__c = CS_const_SalesOrder.ApprovalStatus_Pending;
					if ( currentSO.In_Retraction__c == true ){
						currentSO.csmso__Status__c = StandardSalesOrderStateManager.SO_PENDING_BOOKING;
					}
					else {
						currentSO.csmso__Status__c = StandardSalesOrderStateManager.SO_RESERVED;
					}
				} 
			}

			//successfull approval or rejection, clear the warning msg
			if(currentSO.Compliance_Check__c == CS_const_SalesOrder.ApprovalStatus_Approved && currentSO.Legal_Check__c == CS_const_SalesOrder.ApprovalStatus_Approved){
				if( currentSO.csmso__Process_Message__c == Label.SO_Compliance_Legal_Reject_No_Comment){
					currentSO.csmso__Process_Message_Type__c = '';
					currentSO.csmso__Process_Message__c = '';
				}
			}
			if( currentSO.csmso__Status__c == StandardSalesOrderStateManager.SO_RESERVE_REJECTED 
					&& (currentSO.Compliance_Check__c == CS_const_SalesOrder.ApprovalStatus_Rejected || currentSO.Legal_Check__c == CS_const_SalesOrder.ApprovalStatus_Rejected) ){
				if( currentSO.csmso__Process_Message__c == Label.SO_Compliance_Legal_Reject_No_Comment){
					currentSO.csmso__Process_Message_Type__c = '';
					currentSO.csmso__Process_Message__c = '';
				}
			}
			//system.debug('in logic return '+JSON.serializePretty(currentSO));
		}
	}
}
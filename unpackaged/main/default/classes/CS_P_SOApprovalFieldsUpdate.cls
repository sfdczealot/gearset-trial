/**
 * Created by ivan.ravnjak on 10.3.2020..
 */

public class CS_P_SOApprovalFieldsUpdate extends CS_ProcessBase {
	@TestVisible
	Map<Id, csmso__Sales_Order__c> applicableObjects;

	@TestVisible
	Map<Id, csmso__Sales_Order__c> oldObjects;

	public csmso__Sales_Order__c salesOrder { get; set; }

	public CS_P_SOApprovalFieldsUpdate(Map<Id, csmso__Sales_Order__c> oldObjects) {
		super(CS_ProcessDefinition.SO_APPROVALFIELDSUPDATE, 'CS_P_SOApprovalFieldsUpdate');

		this.oldObjects = oldObjects;
		applicableObjects = new Map<Id, csmso__Sales_Order__c>();
	}

	public override void isRecordEligible(SObject obj) {
		csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
		csmso__Sales_Order__c oldSalesOrder = (csmso__Sales_Order__c) oldObjects.get(newSalesOrder.Id);

		//check field updates based on fields in custom metadata Approval Types
		Set<String> monitorFieldsLCsv = new Set<String>();
		for(String currApproval : CS_ApprovalService.approvalTypes.keySet()) {
			if(CS_ApprovalService.approvalTypes.get(currApproval).Monitor_Fields__c != null){
				monitorFieldsLCsv.addAll(CS_ApprovalService.approvalTypes.get(currApproval).Monitor_Fields__c.split(','));
			}
		}

		if(!monitorFieldsLCsv.isEmpty()){
			for(String currentField : monitorFieldsLCsv){
				if( oldSalesOrder.get(currentField) != newSalesOrder.get(currentField) ) {
					applicableObjects.put(newSalesOrder.Id, newSalesOrder);
				}
			}
		}

		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		CS_ApprovalService.checkApprovals(applicableObjects.keySet());
	}
}
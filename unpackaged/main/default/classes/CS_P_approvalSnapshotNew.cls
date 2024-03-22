/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used for creating snapshot json file and attach it to the sales order line.
* Snapshot file contains sales order, sales order line and attribute value data used to evaluate
* if sales order is eligible for re-triggering certain approval process flow.
* Process executes on updating csmso__Sales_Order__c.Snapshot_ApprovalName__c flag.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ivan Ravnjak   <ivan.ravnjak@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_approvalSnapshotNew extends CS_ProcessBase {

	@TestVisible
	Map<Id, csmso__Sales_Order__c> applicableObjects;

	@TestVisible
	Map<Id, csmso__Sales_Order__c> oldSalesOrders;

	CS_ApprovalService csApprovalService = new CS_ApprovalService();

	public CS_P_approvalSnapshotNew(Map<Id, csmso__Sales_Order__c> oldSalesOrders) {
		super(CS_ProcessDefinition.APPROVAL_SNAPSHOT_NEW, 'CS_P_approvalSnapshotNew');

		applicableObjects = new Map<Id, csmso__Sales_Order__c>();
		this.oldSalesOrders = oldSalesOrders;
	}

	public override void isRecordEligible(SObject obj) {

		csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
		csmso__Sales_Order__c oldSalesOrder = oldSalesOrders.get(newSalesOrder.Id);

		// used to identify which approval process is approved
		// used in order to create snapshot attachments separate for each approval ApprovalSOSnapshotFieldNames
		for(String approvalType : CS_ApprovalService.approvalDefinition.getApprovalTypes()) {
			if(CS_ApprovalService.approvalTypes.get(approvalType).Field_Name__c != null){
				String approvalFieldName = CS_ApprovalService.approvalTypes.get(approvalType).Field_Name__c;
				if( newSalesOrder.get(approvalFieldName) != oldSalesOrder.get(approvalFieldName)
						&& newSalesOrder.get(approvalFieldName) == 'Approved' && newSalesOrder.csmso__Status__c != 'In Progress' ){
					this.csApprovalService.approvalIndicators.put(approvalType, 'Approved');
					applicableObjects.put(newSalesOrder.Id, newSalesOrder);
				}
			}
		}
		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		CS_ApprovalService csApprovalService = new CS_ApprovalService();

		List<cscfga__Product_Configuration__c> productConfigurationList = getProductConfigurationData(applicableObjects.keySet());

		List<CS_ApprovalService.ApprovalSnapshot> csApprovalSnapshotList = csApprovalService.getSnapshotData(productConfigurationList).values();
		List<Attachment> attachmentList = new List<Attachment>();
		for(String approvalType : CS_ApprovalService.approvalDefinition.getApprovalTypes()) {
			for(CS_ApprovalService.ApprovalSnapshot currentApprovalSnapshot : csApprovalSnapshotList) {
				CS_ApprovalService.ApprovalSnapshot attachmentApprovalSnapshot = new CS_ApprovalService.ApprovalSnapshot();
				
				if (this.csApprovalService.approvalIndicators.get(approvalType) == 'Approved') {
					attachmentApprovalSnapshot.ProductConfigurationId = currentApprovalSnapshot.ProductConfigurationId;
					attachmentApprovalSnapshot.ProductBasketId = currentApprovalSnapshot.ProductBasketId;
					attachmentApprovalSnapshot.AttributeMap = new Map<String, String> ();
				}

				for (String currentAttributeKey : currentApprovalSnapshot.AttributeMap.keySet()) {
					if (this.csApprovalService.approvalIndicators.get(approvalType) == 'Approved') {
						attachmentApprovalSnapshot.AttributeMap.put(currentAttributeKey, currentApprovalSnapshot.AttributeMap.get(currentAttributeKey));
					}
				}

				if (this.csApprovalService.approvalIndicators.get(approvalType) == 'Approved') {
					Attachment attach = CS_Attachment.generateAttachment(JSON.serializePretty(attachmentApprovalSnapshot, true),
							attachmentApprovalSnapshot.ProductConfigurationId, CS_ApprovalService.approvalTypes.get(approvalType).Snapshot_Filename__c);
					attachmentList.add(attach);
				}
			}
		}
		CS_Attachment.createAttachments(attachmentList, true);
	}

	private List<cscfga__Product_Configuration__c> getProductConfigurationData(Set<Id> salesOrderIdSet) {

		List<cscfga__Product_Configuration__c> productConfigurationListToReturn =
		[
				SELECT  Id,
						cscfga__Product_Basket__c,
						Sales_Order__r.Id,
						Sales_Order__r.Name
				FROM    cscfga__Product_Configuration__c
				WHERE   Sales_Order__c = :salesOrderIdSet AND Fulfilment_Item_Status__c != 'Paused Inventory Released'
		];

		return productConfigurationListToReturn;
	}

}
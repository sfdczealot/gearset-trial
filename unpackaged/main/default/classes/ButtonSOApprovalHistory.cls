global without sharing class ButtonSOApprovalHistory extends CS_ButtonBase {
    private Id salesOrderId {get{return this.salesOrder.Id;} set;}

	global override void init() {
        this.calloutType = 'ButtonSOApprovalHistory';
		this.lastButtonClicked = 'Approvals';
        this.className = ButtonSOApprovalHistory.class.getName();
    }

	global override void doAction() {
		returnMessage.setRedirectMessage('javascript:window.open(\'/04h?rlid=RelatedProcessHistoryList&id='+salesOrder.Id+'\', \'_blank\');void(0);');
	}
}
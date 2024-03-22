global without sharing class ButtonSOHistory extends CS_ButtonBase {
	global override void init() {
        this.calloutType = 'ButtonSOHistory';
		this.lastButtonClicked = 'History';
        this.className = ButtonSOHistory.class.getName();
    }

	global override void doAction() {
	    returnMessage.setRedirectMessage('javascript:window.open(\'/_ui/common/history/ui/EntityHistoryFilterPage?id='+salesOrder.Id+'\', \'_blank\');void(0);');
	}
}
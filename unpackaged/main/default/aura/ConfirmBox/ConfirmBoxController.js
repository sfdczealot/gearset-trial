({
    doInit : function(component, event, helper) {
      alert('called');
      $A.get("e.force:closeQuickAction").fire();  
    },
	clickYes : function(component, event, helper) {
		alert('Yes');
	},
    clickNo : function(component, event, helper) {
		alert('No');
	}
})
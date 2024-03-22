({
	showToast : function(component, event, helper, title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
     close: function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                $A.get("e.force:closeQuickAction").fire();
            }), 200
        );
    }
})
({
    showtoast : function(component, event, helper,result,msg) {
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : result,
            message: msg,
            duration:' 5000',
            key: 'info_alt',
            type: result,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    closePopup : function(component, event, helper,result,msg) {
        window.setTimeout(
            $A.getCallback(function() {
                $A.get("e.force:closeQuickAction").fire();
            }), 200
        );
    }
})
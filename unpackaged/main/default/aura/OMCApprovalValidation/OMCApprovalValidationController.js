({
    doInit : function(component, event, helper) {
        helper.sendApproval(component);
    },
    closeModal : function(component, event, helper) { 
        // Close the action panel 
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        dismissActionPanel.fire(); 
        $A.get('e.force:refreshView').fire();    
        var sObectEvent = $A.get("e.force:navigateToSObject");

        sObectEvent .setParams({
            "recordId": component.get('v.recordId') ,
            "slideDevName": "detail"
        });
        sObectEvent.fire(); 
    
    }
})
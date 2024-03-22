({
    doInit : function(component, event, helper) {
        helper.getCampData(component, event);
    },
    
    yesBtn : function(component, event, helper) {
        component.set("v.showConfirmationMsg",false);
        component.set("v.Loader",true);
        helper.updateCampaignRec(component, event);
    },
    
    noBtn : function(component,event,helper) {
        helper.closeQuickActionModal(component,event);
    }
})
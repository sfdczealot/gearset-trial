({
    doInit : function(component, event, helper) {
        helper.construct(component, event, helper);
    },
    cancelBtn: function(component, event) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        dismissActionPanel.fire(); 
    },
    saveBtn: function(component, event, helper) {
        component.set('v.Spinner', true);
        helper.submitForm(component, event);
    },
    changeStartDate: function(component, event, helper) {
        var agentObj = component.get("v.agentObj");
        var upgradeStartDate = component.get("v.upgradeStartDate");
        var currentStartDate = new Date(agentObj.Subscription_Start_Date__c.substr(0, 4)*1, (agentObj.Subscription_Start_Date__c.substr(5, 2)*1)-1, agentObj.Subscription_Start_Date__c.substr(8)*1);//yyyy, mm, dd
        upgradeStartDate = new Date(upgradeStartDate.substr(0, 4)*1, (upgradeStartDate.substr(5, 2)*1)-1, upgradeStartDate.substr(8)*1);//yyyy, mm, dd
        var months = upgradeStartDate.getMonth() - currentStartDate.getMonth() + (12 * (upgradeStartDate.getFullYear() - currentStartDate.getFullYear()));
        
        var diff = Math.floor(upgradeStartDate.getTime() - currentStartDate.getTime());
        var day = 1000 * 60 * 60 * 24;
        
        var days = Math.floor(diff/day);
        
        if(upgradeStartDate.getDate() < currentStartDate.getDate()){
            months--;
        }
        component.set("v.dayUtilised", days);
        setTimeout(function() {helper.calculatePriceHelper(component);}, 500);
    },
    calculatePrice: function(component, event, helper) {
        helper.calculatePriceHelper(component);
    },
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    
})
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
        
        component.set("v.showErrorMsg",false);
        var agentObj = component.get("v.agentObj");
        var upgradeStartDate = component.get("v.upgradeStartDate");
        
        // Added validation on New Package Start Date Field
        var newUpgradeStartDate = new Date(upgradeStartDate);
        
        if(agentObj.Country__c == "Singapore"){
            
            var DateToday = new Date(
                helper.getToday().substr(0, 4) * 1,
                helper.getToday().substr(5, 2) * 1 - 1,
                helper.getToday().substr(8) * 1
            ); //yyyy, mm, dd
            var newPackageStartDate = component.get("v.newPackageStartDate");
            var cutOffDate = new Date(newPackageStartDate);
            
            // Getting temporary cutOffDate from custom label 
            var temporaryCutOffDate = $A.get("$Label.c.UPGRADE_OPP_CUTOFF_DATE");
            
              if(temporaryCutOffDate == "NULL") {
                var weekday = new Array(7);
                weekday[0] = 0;
                weekday[1] = 6;
                weekday[2] = 5;
                weekday[3] = 4;
                weekday[4] = 3;
                weekday[5] = 2;
                weekday[6] = 1;
                
                var noOfDaysAdded = weekday[cutOffDate.getDay()];
                
                cutOffDate.setDate(cutOffDate.getDate() + noOfDaysAdded);
                
           } else {
                
                cutOffDate = new Date(temporaryCutOffDate);
            }
            
            var subsEndDate = new Date(agentObj.Subscription_End_Date__c);
            
            if(subsEndDate < cutOffDate)
            {
                cutOffDate = subsEndDate;
            }
            
            if(newUpgradeStartDate > cutOffDate)
            {
                var errorMsgDate = cutOffDate;
                errorMsgDate.setDate(errorMsgDate.getDate()+1);
                component.set("v.showErrorMsg",true);
                component.set("v.errorMsg","Date should be before "+ (errorMsgDate.getDate())+"/"+(errorMsgDate.getMonth()+1)+"/"+errorMsgDate.getFullYear());
            }
            
            else if(newUpgradeStartDate < DateToday)
            {
                component.set("v.showErrorMsg",true);
                component.set("v.errorMsg","Backdated start of Upgrade not allowed.");
            }
            // For weekly calculation (Singapore)
            setTimeout(function() {helper.calculateProRateForSGHelper(component);}, 500);
        }
        
        else{
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
            component.set("v.monthUtilised", months);
            setTimeout(function() {helper.calculateProRateHelper(component);}, 500);
        }
        
        
    },
    calculateProRate: function(component, event, helper) {
        var agentObj = component.get("v.agentObj");
        
        // For weekly calculation (Singapore)
        if(agentObj.Country__c == 'Singapore')
        {
            helper.calculateProRateForSGHelper(component);
        }
        else{
            helper.calculateProRateHelper(component);
        }
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
    
    refreshAdCredit : function(component,event,helper) {
        component.set("v.showCalloutError",true);
        component.set("v.refreshStatus","(Fetching Ad Credit Info...)");
        var agentObj = component.get("v.agentObj");
        helper.getAdCredit(component,event,agentObj);
    },
    refreshPrimeCredit : function(component,event,helper) {
        component.set("v.showCalloutError",true);
        component.set("v.refreshStatus","(Fetching Prime Credit Info...)");
        var agentObj = component.get("v.agentObj");
        helper.getPrimeCredit(component,event,agentObj);
    }   
})
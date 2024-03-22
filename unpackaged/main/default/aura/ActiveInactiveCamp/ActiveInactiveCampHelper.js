({
    
    getCampData : function(component,event) {
        var recId = component.get("v.recordId")
        var action = component.get("c.getCampInfo");
        action.setParams({
            campId:recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                if(result!=null) {
                    var activeOrNot = '';
                    if(result.IsActive == true) {
                        activeOrNot = 'inactive';
                    }
                    else if(result.IsActive == false) {
                        activeOrNot = 'active';
                    }
                    component.set("v.activeOrInactive",activeOrNot);
                    component.set("v.campData",result);
                    component.set("v.showConfirmationMsg",true);
                }
                else{
                    var undetectedErrorMsg = $A.get("$Label.c.ADD_ERROR_UNDETECTED");
                    this.showToast('Error',undetectedErrorMsg);
                    this.closeQuickActionModal(component,event);
                }

            }
            else if(state == "ERROR"){
                var undetectedErrorMsg = $A.get("$Label.c.ADD_ERROR_UNDETECTED");
                this.showToast('Error',undetectedErrorMsg);
                this.closeQuickActionModal(component,event);
            }
        });
        $A.enqueueAction(action);
    },
    
    updateCampaignRec : function(component, event) {
        var recId = component.get("v.recordId")
        var action = component.get("c.getResponse");
        var camp = component.get("v.campData");
        action.setParams({
            campRec: JSON.stringify(camp) 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                var isSuccess = result.isSuccess;
                var titleOrType;
                if(isSuccess){
                    titleOrType ='Success';
                }else{
                    titleOrType ='Error';
                }
                var msg = result.message;
                if(msg == '' || msg == undefined) {
                    msg = $A.get("$Label.c.ADD_ERROR_UNDETECTED"); 
                }
                component.set("v.Loader",false);
                this.showToast(titleOrType,msg);
                this.refreshRecPage(component, event);
                this.closeQuickActionModal(component,event);
            }
            else if(state == "ERROR"){
                component.set("v.Loader",false);
                var undetectedErrorMsg = $A.get("$Label.c.ADD_ERROR_UNDETECTED");
                this.showToast('Error',undetectedErrorMsg);
                this.closeQuickActionModal(component,event);
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(titleOrType,msg) {
        var showToast = $A.get("e.force:showToast"); 
        showToast.setParams({ 
            'title' : titleOrType, 
            'message' : msg,
            'duration': '5000',
            'type': titleOrType
        }); 
        showToast.fire(); 
    },
    
    closeQuickActionModal : function(component,event){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    refreshRecPage: function(component, event) {
        $A.get('e.force:refreshView').fire();
    }
})
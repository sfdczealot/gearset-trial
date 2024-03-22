({
    doInit : function(component, event, helper) {
        var action = component.get("c.createAgencyLogo");
        action.setParams({
            accId : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            console.log('-apex called---');
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue()){
                    component.set("v.agencyLogoId",response.getReturnValue());
                    component.set("v.showFileUpload", true);
                }
                else{
                    alert('Something went wrong please contact Admin');
                }
            }
        });
        $A.enqueueAction(action);
    },
    handleUploadFinished : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        var action = component.get("c.notifyBiforst");
        action.setParams({
            accId : component.get("v.recordId"),
            mediaId : component.get("v.agencyLogoId")
        });
        action.setCallback(this,function(response){
            console.log('-apex called---');
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue()){
                    alert('Logo Uploaded Successfully!');
                    navEvt.fire();
                }
                else{
                    alert('Something went wrong please contact Admin');
                }
            }
        });
        $A.enqueueAction(action);
    },
    onCancel : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
    }
})
({
    doInit : function(component, event, helper) {
        var action = component.get("c.getActiveContentDoc");
        action.setParams({
            accId : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            console.log('-apex called---');
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue()){
                    component.set("v.contents", response.getReturnValue()); 
                }else{
                    component.set("v.showNoFile",true); 
                   console.log('--insideelse--');
                }
            }
        });
        $A.enqueueAction(action);
    },
    onUploadNewLogo : function(component, event, helper){
        component.set("v.showFileComp",true);
    }
})
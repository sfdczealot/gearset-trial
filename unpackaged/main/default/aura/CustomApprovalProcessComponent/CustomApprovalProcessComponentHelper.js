({
    checkApprovalProcessExists: function(component) {
        let action = component.get("c.beforeApprovalValidation");
        action.setParams({
            recordId : component.get("v.recordId"),
            objectName : component.get("v.sObjectName")
        });
        action.setCallback(this, function(resp){
            if(resp.getState() == "SUCCESS") {
                if(resp.getReturnValue() == 'SUCCESS') {
                    component.set("v.approvalProcessStatus", true);
                }
                else {
                    this.showToast(component,event,'ERROR', resp.getReturnValue());
                    component.set("v.approvalProcessStatus", false);
                }
            }
            else if(resp.getState() == "ERROR"){
                this.showToast(component,event,'ERROR', resp.getError()[0].message);
                component.set("v.approvalProcessStatus", false);
            }
            console.log("status: ",component.get("v.approvalProcessStatus"));
            if(component.get("v.approvalProcessStatus") == false) {
                $A.get("e.force:closeQuickAction").fire(); 
            }
        });
        $A.enqueueAction(action); 
    },
    CampaignName : function(component,event){
        
        let action = component.get('c.displayVIPCampaignName');
        action.setParams({
            recordId : component.get('v.recordId')
        });
        action.setCallback(this,result=>{
            let VIPCampaignName = result.getReturnValue();
            let lowerCase = VIPCampaignName.toLowerCase();
            component.set('v.VIPCampaignName',lowerCase);            
        });
        $A.enqueueAction(action);
        },
        showToast : function(component, event, title, message) {
            console.log("show toast");
            console.log("title: ",title);
            console.log("message: ",message);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": title,
                "title": title,
                "message": message
            });
            toastEvent.fire();
         },
         CampaignList : function(component,event){ 
             let action = component.get('c.fetchVIPCampaign');
             action.setCallback(this,result=>{
                 let resultList = result.getReturnValue();
                 let newArray = [];
                 for(let i=0;i<resultList.length;i++){
                 	resultList[i].isLabel = resultList[i].Name.toLowerCase();
                    newArray.push(resultList[i]);
             	 }
                 component.set('v.camp_list',newArray);
             });
             $A.enqueueAction(action);                   
        }
})
({
    fetchDetails : function(component, event, helper) { 
        component.set("v.showSelect",true);
        
        var det = component.get("c.fetchRecords");
        det.setParams({"objRecId":   component.get("v.recordId")});
        
        det.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var pageSize = component.get("v.pageSize");
                
                 component.set("v.isOverlappingAgent",response.getReturnValue().isOverlappingAgent);
                if(response.getReturnValue().sObjName=='Opportunity'){
                    component.set("v.agentOrOpp",'opporutnity');
                    component.set("v.isAcc",false);
                }else{
                    component.set("v.agentOrOpp",'agent');
                    component.set("v.isAcc",true)
                }
                var custs=[];
                for ( var key in response.getReturnValue().getSearchedLabels ) {
                    custs.push({value:response.getReturnValue().getSearchedLabels[key], key:key});
                }
                component.set("v.SearchFields",custs);
                component.set("v.showData",true);
                component.set("v.showSpinner",false);
                component.set("v.externalField",response.getReturnValue().destinationField);
                component.set("v.Labels",response.getReturnValue().getLabels);
                component.set("v.fmInnerList",response.getReturnValue().fmInnerList);
                component.set("v.displayFmList",response.getReturnValue().fmDisplayList);
                component.set("v.EndPoint",response.getReturnValue().EndPoint);
                component.set("v.AgentId",response.getReturnValue().AgentId);
                component.set("v.relatedFieldsAPI",response.getReturnValue().relatedFieldsAPI);
                console.log(response.getReturnValue().fmDisplayList);
                console.log(response.getReturnValue().fmInnerList);
                var innerdata = [];
                for(var key in response.getReturnValue().innerFields){
                    innerdata.push({value:response.getReturnValue().innerFields[key],key:key}); 
                }
               component.set("v.innerFields",innerdata);
                var relatedFieldsAPI = [];
                for(var key in response.getReturnValue().relatedFieldsAPI){
                    relatedFieldsAPI.push({value:response.getReturnValue().relatedFieldsAPI[key],key:key}); 
                }
               component.set("v.relatedFieldsAPI",relatedFieldsAPI);
               var innerfield =[];
              
                for(var key in response.getReturnValue().innerFieldsAPI){
                    innerfield.push({value:response.getReturnValue().innerFieldsAPI[key],key:key});  
                    
                }
               component.set("v.innerFieldsAPI",innerfield);
               
                var detailsfields = [];
                for(var key in response.getReturnValue().detailsFieldsAPI){
                    detailsfields.push({value:response.getReturnValue().detailsFieldsAPI[key],key:key});  
                    
                }
                 component.set("v.detailsfields",detailsfields);
               
            } else {

                component.set("v.showSpinner",false);
                console.log(component.get("v.showData"));
                if(response.getError()[0].message =='No records found')
                    helper.showToast(component, event, helper,'Info',response.getError()[0].message,'info');
                else
                    helper.showToast(component, event, helper,'Error',response.getError()[0].message,'error');
            }
        });
        $A.enqueueAction(det);
        
    },
    
    showToast : function(component, event, helper, title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        if(message == 'Overlapping Opportunity is already closed won'){
            component.set("v.disable",true);
        }
        if(message == 'There are no records found with given criteria'){
            component.set("v.disable",false);
        }
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
    
})
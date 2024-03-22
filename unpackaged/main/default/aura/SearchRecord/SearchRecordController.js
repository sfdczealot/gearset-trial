({
    doInit : function(component, event, helper) {
        component.set("v.ShowSpinner","true");
        let actionApi = component.find("quickActionAPI");
        actionApi.getSelectedActions().then(function(result){
            let actionNameValue = result.actions[0].actionName;
            
            //If my quick action api name is 'Custom_Edit', this returns the 
            //action name as CustomObject__c.Custom_Edit
            console.log('Action name with object api name is - '+actionNameValue);
            
            //To Split and get just the action api name, do the below.
            if(actionNameValue.includes('.')) {             
                let getActionName = actionNameValue.split('.')[1];
                //This returns value as 'Cutom_Edit'
                console.log('getActionName - '+getActionName);
                component.set('v.quickAction',getActionName);
            }
             var det = component.get("c.getObjFields");
        det.setParams({
            "recordId":   component.get("v.recordId") 
        });
        
        det.setCallback(this, function(response) { 
            if (response.getState() === "SUCCESS") {
                
                if(response.getReturnValue().ObjectName=='Opportunity'){
                    component.set("v.agentOrOpp",'opporutnity');
                    component.set("v.isAcc",false);
                    // component.set("v.sObjectData",response.getReturnValue().wc.keyValueMapList);
                    component.set("v.externalField",response.getReturnValue().wc.destinationField);
                    var custs=[];
                    for ( var key in response.getReturnValue().wc.getSearchedLabels ) {
                        custs.push({value:response.getReturnValue().wc.getSearchedLabels[key], key:key});
                    }
                    
                    var pageSize = component.get("v.pageSize");
                    component.set("v.showSelect",true);
                    component.set("v.sObjectType",response.getReturnValue().ObjectName);
                    component.set("v.SearchFields",custs);
                    component.set("v.Labels",response.getReturnValue().wc.getLabels);
                    component.set("v.displayFmList",response.getReturnValue().wc.fmDisplayList);
                    component.set("v.showData",true);
                    component.set("v.totalRecords", component.get("v.displayFmList").length);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    component.set("v.EndPoint",response.getReturnValue().wc.EndPoint);
                    
                    var PaginationList = [];
                    for(var i=0; i< pageSize; i++){
                        if(component.get("v.displayFmList").length> i)
                            PaginationList.push(response.getReturnValue().wc.fmDisplayList[i]);    
                    }
                    component.set('v.PaginationList', PaginationList);
                }
                else{
                    component.set("v.agentOrOpp",'agent');
                    component.set("v.fmList",response.getReturnValue().fwc.fmList);
                    component.set("v.isAcc",true);
                    component.set("v.sObjectType",response.getReturnValue().fwc.objName);
                    // component.set("v.Labels",response.getReturnValue().fwc.getLabels);
                    helper.searchData(component, event, helper);
                }
                component.set("v.disable",false);
            }
            else{
                helper.showToast(component, event, helper,'Error',response.getError()[0].message,'error');
                
            }
            component.set("v.ShowSpinner","false");
        });
        $A.enqueueAction(det);
        
            
        }).catch(function(error){
            console.log('Errors - '+error.errors);
             component.set("v.ShowSpinner","false");
        });
        
       
        
    },
    getSelectedValue:function(component, event, helper){
        // var selected = event.getSource().get("v.label").Id.from__c;
        var selected = event.getSource().get("v.label");
        console.log(selected);
        if(event.getSource().get("v.label")['Account.OwnerId'] != undefined){
            component.set("v.OwnerId",event.getSource().get("v.label")['Account.OwnerId'].from__c);
        }
        component.set("v.selectedAttribute",selected);
        
        
    },
    updateRecord:function(component, event, helper){
        component.set("v.ShowSpinner",true);
        component.set("v.disable",true);
        var det = component.get("c.updateRec");
        if(component.get("v.selectedAttribute") == undefined ){
            helper.showToast(component, event, helper,'Error','Please select record to tag','error');
            component.set("v.disable",false);
            return;
        }
        //component.set("v.disable",true);
        det.setParams({
            "externalField":JSON.stringify(component.get("v.selectedAttribute")),
            "recordId":   component.get("v.recordId"),
            "type": component.get("v.quickAction")
            //"details": 
        });
        
        det.setCallback(this, function(response) { 
            if (response.getState() === "SUCCESS") {
                if(component.get('v.sObjectType') == 'Account'){
                    console.log('updated');
                    helper.showToast(component, event, helper,'Success','Case '+response.getReturnValue()+' is created successfully','success');
                    
                }else{
                    console.log('updated');
                    helper.showToast(component, event, helper,'Success','Opportunity is tagged successfully','success');
                } 
            } else{
                helper.showToast(component, event, helper,'Error',response.getError()[0].message,'error');
                
            }
            component.set("v.ShowSpinner",false);
        });
        $A.enqueueAction(det);
        
    },
    createRecord:function(component, event, helper){
        component.set("v.ShowSpinner",true);
        component.set("v.disable",true);
        var det = component.get("c.createRec");
        det.setParams({
            "recordId":   component.get("v.recordId") ,
            "ownerid"  : component.get("v.OwnerId"),
            "quickAction": component.get("v.quickAction")
        });
        
        det.setCallback(this, function(response) { 
            if (response.getState() === "SUCCESS") {
                console.log('created');
                helper.showToast(component, event, helper,'Success','Record Created successfully','success');
                var fields = component.find("newFields");
                var temp=[];
                
                
                
                for(var f in fields){
                    if(fields[f].get("v.value") != '' && fields[f].get("v.value")!=null)
                        temp.push({value:fields[f].get("v.value"),
                                   key:fields[f].get("v.name").To__c,
                                   dataType:fields[f].get("v.type"),
                                   relatedObject:fields[f].get("v.name").related_Object_API__c});
                    console.log( fields[f].get("v.name")+' '+fields[f].get("v.value"));
                }  
                component.set("v.showSelect",false);
                
                helper.fetchDetails(component, event, helper,temp,false);
            } else{         
                helper.showToast(component, event, helper,'Error',response.getError()[0].message,'error');
            }
            component.set("v.ShowSpinner",false);
        });
        $A.enqueueAction(det);
    },
    
    next: function (component, event, helper) {
        helper.next(component, event);
    },
    previous: function (component, event, helper) {
        helper.previous(component, event);
    },
    unTagAccount :  function (component, event, helper) {
        component.set("v.ShowSpinner",true);
        var det = component.get("c.untagAccount");
        det.setParams({
            "recordId":   component.get("v.recordId"),
            "eventType": component.get("v.quickAction") 
        });
        
        det.setCallback(this, function(response) { 
            
            if (response.getState() === "SUCCESS") {
                console.log('untagged');
                if( component.get("v.agentOrOpp") == 'opporutnity')
                    helper.showToast(component, event, helper,'Success','Opportunity untagged successfully','success');
                
                else
                    helper.showToast(component, event, helper,'Success','Case '+response.getReturnValue() +' is created successfully','success');
            } else{         
                helper.showToast(component, event, helper,'Error',response.getError()[0].message,'error');
            }
            component.set("v.ShowSpinner",false);
        });
        $A.enqueueAction(det);
    },
    closeModel: function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
    },
})
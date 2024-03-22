({
    fetchDetails : function(component, event, helper,eventFields) {
        var det = component.get("c.fetchRecords");
        det.setParams({"objRecId":   component.get("v.recordId"),
                       "objData":JSON.stringify(eventFields)});
        
        det.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var pageSize = component.get("v.pageSize");
                
                console.log(response.getReturnValue());
                
                var custs=[];
                for ( var key in response.getReturnValue().getSearchedLabels ) {
                    custs.push({value:response.getReturnValue().getSearchedLabels[key], key:key});
                }
                // component.set("v.sObjectType",response.getReturnValue().ObjectName);
                component.set("v.SearchFields",custs);
                // component.set("v.Labels",response.getReturnValue().wc.getLabels);
                component.set("v.showData",true);
                
               // component.set("v.sObjectData",response.getReturnValue().keyValueMapList);
                component.set("v.externalField",response.getReturnValue().destinationField);
                //  component.set("v.SearchFields",response.getReturnValue().getSearchedLabels);
                component.set("v.Labels",response.getReturnValue().getLabels);
                component.set("v.showData",true);
                
                component.set("v.displayFmList",response.getReturnValue().fmDisplayList);
                component.set("v.totalRecords", component.get("v.displayFmList").length);
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize-1);
                component.set("v.EndPoint",response.getReturnValue().EndPoint);
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.displayFmList").length> i)
                        PaginationList.push(response.getReturnValue().fmDisplayList[i]);    
                }
                component.set('v.PaginationList', PaginationList);
                // component.set("v.str",str); 
            } else {
                component.set("v.showData",false);
                if(response.getError()[0].message =='No records found')
                    helper.showToast(component, event, helper,'Info',response.getError()[0].message,'info');
                 else if(response.getError()[0].message.includes('Case for')){
                    helper.showToast(component, event, helper,'Info',response.getError()[0].message,'info');
                component.set("v.disable",true);
                }else
                    helper.showToast(component, event, helper,'Error',response.getError()[0].message,'error');
            }
        });
        $A.enqueueAction(det);
    },
    showToast : function(component, event, helper, title,message,type) {
        component.set("v.ShowSpinner",false);
        var toastEvent = $A.get("e.force:showToast");
        if(message == 'Overlapping Opportunity is already closed won'){
            component.set("v.disable",true);
        }
          if(message == 'There are no records found with given criteria'){
            component.set("v.disable",false);
        }
        if(type=='success'){
             var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
         $A.get('e.force:refreshView').fire();
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
    next : function(component, event){
        var sObjectList = component.get("v.displayFmList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(sObjectList.length > i){
                Paginationlist.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    previous : function(component, event){
        var sObjectList = component.get("v.displayFmList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
     searchData : function(component, event, helper) {
        
      //  var fields = component.find("newFields");
      var fields =  component.get("v.fmList");
        var temp=[];
        
        
        
        for(var f in fields){
            if(fields[f].from__c  != '' && fields[f].from__c !=null)
                temp.push({value:fields[f].from__c ,
                           key:fields[f].To__c,
                           dataType:fields[f].DataType__c ,
                           relatedObject:fields[f].related_Object_API__c});
           // console.log( fields[f].get("v.name")+' '+fields[f].from__c );
        }     
        component.set("v.showSelect",true);
        helper.fetchDetails(component, event, helper,temp);
        
    }
    
})
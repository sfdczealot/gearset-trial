({
    doInit : function(component, event, helper) {
   
         helper.fetchDetails(component, event, helper);
        }, 
  
    editAgent : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": component.get("v.EndPoint")+'/'+component.get("v.AgentId") 
        });
        urlEvent.fire();
        
    }
})
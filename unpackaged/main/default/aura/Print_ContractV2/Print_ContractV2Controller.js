({
    
    init : function(cmp, event, helper) {

       var init0 = cmp.get("c.checkStatus");
       init0.setParams({"oppId": cmp.get("v.recordId")});
       init0.setCallback(this, function(response) {
           if (response.getState() === "SUCCESS") {
               cmp.set("v.headerText",'Template Selection');
               console.log('isDetailed*** '+response.getReturnValue().isDetailed)
               cmp.set("v.contractID",response.getReturnValue().contractId);
               if(response.getReturnValue().isDetailed == false){
                   var soType;
                   if(response.getReturnValue().isFinal == false){
                       soType = 'SimpleDraft';
                   }
                   else
                       soType = 'SimpleFinal';
                   var urlEvent = $A.get("e.force:navigateToURL");
                   //urlEvent.setParams({ "url":"/apex/echosign_dev1__AgreementTemplateProcess?masterId="+cmp.get("v.contractID")+"&templateID=a6N9D0000001jb6UAA"});
                   urlEvent.setParams({ "url":"/apex/Print_Contractv2?Id="+cmp.get("v.recordId")+"&SoType="+soType });
                   urlEvent.fire(); 
               }
               else{
               cmp.set("v.isFinal",response.getReturnValue().isFinal);
                   cmp.set("v.checkPass",true);
               }
           }
           else
           {
                var errors = response.getError();           
               var header = cmp.find("modalHeader");
               cmp.set("v.checkPass",false);
               $A.util.addClass(header, 'slds-theme_error slds-theme_alert-texture');
               cmp.set("v.headerText", "Failed to generate contract");                
               //show error meesage
              
               cmp.set("v.errorMessage", errors[0].message);   
                
           }
       });
       $A.enqueueAction(init0);
    },
   myAction : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
             // urlEvent.setParams({ "url":"/apex/echosign_dev1__AgreementTemplateProcess?masterId="+component.get("v.contractID")+"&templateID=a6N9D0000001jb6UAA"});

      urlEvent.setParams({ "url":"/apex/Print_Contractv2?Id="+component.get("v.recordId")+"&SoType="+component.get("v.SoType") });
       urlEvent.fire(); 
   },
    handleClose : function(component, event, helper) {
       $A.get("e.force:closeQuickAction").fire() 
   }
})
({
    doInit : function(component, event, helper) {
        
        helper.getAllMetaDataRecords(component,event);
        //helper.getAllObjects(component, event);
    },
    addRow : function(component, event, helper) {
        helper.getAllObjects(component, event);
        component.set("v.addRowStatus", true);
    },
    cancelBtnClicked : function(component, event, helper) {
        component.set('v.saveBtnStatus',false);
        component.set("v.addRowStatus", false);
        helper.getAllMetaDataRecords(component,event);
    },
    
    saveCustomDataRec : function(component, event, helper) {
        component.set('v.saveBtnStatus',false);
        let objId = event.getSource().get('v.name');
        console.log('Id ',objId);
        let ObjectName;
        let Enabled;
        if(component.get("v.addRowStatus")== true) {
            ObjectName = component.find('ObjectName').get('v.value');
            Enabled = component.find('Enabled').get('v.checked');
        }
        else{
            ObjectName = component.find('ObjectNameEdit').get('v.value');
            Enabled = component.find('checkboxId').get('v.checked');
        }
        let objectRec = { 'sobjectType': 'Object_Name__c',
                         'Name': ObjectName,
                         'Enabled__c' : Enabled,
                         'Id' : objId
                        };
        console.log('objectRec ',objectRec);
        helper.createCustomSettingDataRecord(component, event,objectRec);
        
    },
    DeleteRec : function(component, event, helper) {
        
        let meId = event.getSource().get('v.name');
        helper.deleteCustomSettingRecord(component, event, meId);
    },
    EditRec : function(component, event, helper) {
        let index = event.target.dataset.rowIndex;
        component.get("v.allMetaDataRecords")[index].edit = true;
        component.set("v.allMetaDataRecords",component.get("v.allMetaDataRecords"));
        console.log('data: ', JSON.stringify(component.get("v.allMetaDataRecords")));
        component.set('v.saveBtnStatus',true);
    },
    closedModal : function(component, event, helper) {
        
        component.set('v.isModal',false);
    }
})
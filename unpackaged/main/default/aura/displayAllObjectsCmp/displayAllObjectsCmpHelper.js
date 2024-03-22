({
    getAllMetaDataRecords : function(component, event) {
        let disabledList = [];
        let disabledVar = {};
        component.set('v.isLoading',true);
        let action = component.get('c.getCustomSettingRecords');
        action.setCallback(this,(result)=>{
        //console.log('Res ',JSON.stringify(result.getReturnValue()))
        component.set('v.allMetaDataRecords',result.getReturnValue());
        for(let i in result.getReturnValue()){
        let rec = JSON.stringify(component.get('v.allMetaDataRecords')[i]);
        console.log('rec:' ,rec);
        rec= rec.replace("{","");
        rec= rec.replace("}","");
        disabledVar[i] = "{"+rec+',"edit":false}';
        //console.log(disabledVar[i]);
        let jsonStr = JSON.parse(disabledVar[i]);
        disabledList.push(jsonStr);
        }
        component.set('v.allMetaDataRecords',disabledList);
        component.set('v.disabledArr',disabledList);
        console.log('init: ', JSON.stringify(component.get('v.disabledArr')));
        component.set('v.isLoading',false);
    });
    $A.enqueueAction(action);
    },
    getAllObjects : function(component, event) {
        component.set('v.isLoadingaddRow',true);
        let action = component.get('c.getObjectName');
        action.setCallback(this,(result)=>{
        console.log('AllObjects$$$ ',JSON.stringify(result.getReturnValue()));
        component.set('v.allObjectList',result.getReturnValue());
        component.set('v.isLoadingaddRow',false);
        });
    $A.enqueueAction(action);
    },
    createCustomSettingDataRecord : function(component, event,createCustomSettRec) {
    
        let action = component.get('c.saveCustomSettingRecord');
        action.setParams({
        obn : createCustomSettRec
        });
        action.setCallback(this,(result)=>{
        console.log('Record Id ',JSON.stringify(result.getReturnValue()));
        this.getAllMetaDataRecords(component, event);
        component.set("v.addRowStatus", false);
    });
    $A.enqueueAction(action);
    },
    deleteCustomSettingRecord : function(component, event,objectRec) {
    
        let action = component.get('c.DeleteCustomSettingRecord');
        action.setParams({
        obnId : objectRec
        });
        action.setCallback(this,(result)=>{
        console.log('Delete >>> ',JSON.stringify(result.getReturnValue()));
        this.getAllMetaDataRecords(component, event);
    });
    $A.enqueueAction(action);
    }
})
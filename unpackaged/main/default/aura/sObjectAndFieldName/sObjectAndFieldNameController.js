({
    doInit : function(component, helper) {
        var obj = component.get('v.object');
        var FieldName = component.get('v.fieldName');
        var outputText = component.find("outputTextId");
       
        if(obj[FieldName] != null && obj[FieldName]!='null'){
            if(obj[FieldName].Label__c == undefined ){
                var str='<table>';
                var a=obj[FieldName];
               
                
                for(var i in a){
                    str += '<tr><td style="border: 1px solid #ddd;padding: 8px;text-align: left;">' +obj[FieldName][i].Label__c+' </td><td style="border: 1px solid #ddd;padding: 8px;text-align: left;"> '+obj[FieldName][i].from__c+'</td></tr>';
                }
                str += '</table>'
                outputText.set("v.value",str);
                
            }
            else{
                if(obj[FieldName].from__c!=null && obj[FieldName].from__c!='null')
                {
                    if(FieldName == 'Id'){
                        component.set('v.isId',true);
                        component.set('v.referenceURL',component.get("v.endPoint")+'/'+obj[FieldName].from__c);
                        component.set('v.val',obj[FieldName].from__c);
                        
                    }
                    else {
                        outputText.set("v.value",obj[FieldName].from__c);
                    }
                }
            }
        }
    }
})
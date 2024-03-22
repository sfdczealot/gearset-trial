({
    doInit : function(component, event, helper) {
        var obj = component.get('v.object');
        var FieldName = component.get('v.fieldName');
        var innerFields = component.get('v.innerFields');
        var FieldsAPI = component.get('v.relatedFieldsAPI');
        var innerdata = [];
        var innerdataAPI = [];
        
        for(var key in innerFields){
            innerdata.push({value:innerFields[key].value,key:innerFields[key].key}); 
        }
        for(var key in FieldsAPI){
            innerdataAPI.push({value:FieldsAPI[key].value,key:FieldsAPI[key].key}); 
        }
        var data = [];
        if(obj[FieldName] != null && obj[FieldName]!='null'){
            if(obj[FieldName].Label__c == undefined ){
                component.set("v.isRelatedList",true);
                var a=obj[FieldName];
                
                for(var j in innerFields){
                    if(innerdata[j].key==FieldName){
                        var fields = [];
                        for(var k in innerdata[j].value){
                            fields.push({value:innerdata[j].value[k],key:k});                            
                        }
                        
                        component.set("v.fields",fields);
                        
                        break;
                    }
                }
                for(var j in FieldsAPI){
                    if(innerdataAPI[j].key==FieldName){
                        
                        var fieldsAPIList = [];
                        for(var k in innerdata[j].value){
                            fieldsAPIList.push({value:innerdataAPI[j].value[k],key:k});                            
                        }
                        
                        break;
                    }
                    
                }
                
                var data =[];
                
                var str='<table>';
                str += '<tr>';
                for(var key in fields){
                    str +='<th style="border: 1px solid #ddd;padding: 8px;text-align: left;">'+fields[key].value+'</th>'; 
                    
                }
                for(var i in a){
                    
                    str += '</tr>';
                    str += '<tr>';
                    
                    var innerData = [];
                    for(var key in fieldsAPIList){
                        var value = fieldsAPIList[key].value;
                        

                        if(value != 'Id'){
                         
                        if(obj[FieldName][i][value]==null||obj[FieldName][i][value]==''||obj[FieldName][i][value]=='undefined'){
                                  str += '<th style="border: 1px solid #ddd;padding: 8px;text-align: left;"> </th>';
                       
                        }else{
                           
                             str += '<th style="border: 1px solid #ddd;padding: 8px;text-align: left;"> '+obj[FieldName][i][value]+'</th>';
                       
                        }
                 
                        }
                       else{
                            var endpoint = component.get("v.endPoint")+'/'+obj[FieldName][i][value];
                            str += '<th style="border: 1px solid #ddd;padding: 8px;text-align: left;"><a href='+endpoint+' target="_blank">'+ obj[FieldName][i][value]+'</a></th>';
                            
                        }
                        
                    }            
                    str += '</tr>';
                    
                    
                }  
                str += '</table>'; 
                
                var outputText = component.find("outputTextId");
                outputText.set("v.value",str);
                
            }
            else{
               
                if(obj[FieldName].from__c=='null'||obj[FieldName].from__c==null||obj[FieldName].from__c==''||obj[FieldName].from__c=='undefined'){
                    data.push({value:'',key:obj[FieldName].Label__c});
                }else{
                   data.push({value:obj[FieldName].from__c,key:obj[FieldName].Label__c});  
                }
                    
                   
                
                
            }
            component.set("v.DataToDisplay",data);
            
        }
        
    }
})
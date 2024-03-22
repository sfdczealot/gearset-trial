/*
* TestClass : displayAllObjectsClass_Test
*/
public class displayAllObjectsClass {
    
    @AuraEnabled
    public static List<String> getObjectName(){
        List<String> metaDataNames = new List<String>();
        For(Object_Name__c metaDataRec: [select Name from Object_Name__c]){
            metaDataNames.add(metaDataRec.Name);
        }
        List<String> sobjectList = new List<String>();
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
            for(Schema.SObjectField sc : objTyp.getDescribe().fields.getMap().values()){
                if(!String.valueOf(objTyp.getDescribe().getSobjectType()).contains('ChangeEvent') && sc.getDescribe().getName() == 'Rule_Name__c' && !metaDataNames.contains(objTyp.getDescribe().getLabel()))
                    sobjectList.add(objTyp.getDescribe().getLabel());
            }
        }
        system.debug('sobjectList%%% '+sobjectList);
        return sobjectList;
    }
    @AuraEnabled
    public static List<Object_Name__c> getCustomSettingRecords(){
        
        return [Select Id,Name,Enabled__c from Object_Name__c];
    }
    @AuraEnabled
    public static String saveCustomSettingRecord(Object_Name__c obn){
        system.debug('obn '+obn);
        upsert obn;
        system.debug('-ID--'+obn.Id);
        return obn.Id;
    }
    @AuraEnabled
    public static String DeleteCustomSettingRecord(String obnId){
        
        delete [select Id from Object_Name__c where Id=:obnId];
        return 'success';
    }
}
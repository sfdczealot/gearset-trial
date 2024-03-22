@isTest
public class displayAllObjectsClass_Test {

    @isTest
    static void displayAllObjectsMethod(){
        
        Object_Name__c obj = new Object_Name__c();
        obj.Name = 'TestName';
        obj.Enabled__c = true;
        insert obj;
        Test.startTest();
        displayAllObjectsClass.getObjectName();
        displayAllObjectsClass.getCustomSettingRecords();
        displayAllObjectsClass.saveCustomSettingRecord(obj);
        displayAllObjectsClass.DeleteCustomSettingRecord(obj.Id);
        Test.stopTest();
    }
}
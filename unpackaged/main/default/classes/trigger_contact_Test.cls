@isTest
public class trigger_contact_Test {
    
    @isTest static void method1(){
        
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true); 
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        Contact con = PGTestDataFactory_v2.createContact('Test','Name','test@mail.com');
        
        Test.startTest();
        update con;
        delete con;
        Test.stopTest();
    }    
}
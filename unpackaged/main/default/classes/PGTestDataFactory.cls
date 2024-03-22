@isTest
public class PGTestDataFactory {
    public static Subsidiary__c createSubsidiary() {
        User runningUser = [Select id, Subsidiary__c,CurrencyIsoCode From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd'; //'PropertyGuru Pte Ltd'
        update runningUser;
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd'; //PropertyGuru Pte Ltd
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        return sb;
    }
    
    public static Subsidiary__c createMYSubsidiary() {
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru International (Malaysia) Sdn Bhd';
        update runningUser;
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru International (Malaysia) Sdn Bhd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'MYR';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Malaysia';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        return sb;
    }
    
    
}
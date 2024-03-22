@istest
public class TagUnTagCase_cc_Test {
    public static testmethod void TagUnTagCase() {
        
        Trigger_Execute__c TEAccMember = new Trigger_Execute__c();
        TEAccMember.Name = 'PGAccountTrigger';
        TEAccMember.Enable_del__c = true;
        insert TEAccMember;
        
        Trigger_Execute__c TECase = new Trigger_Execute__c();
        TECase.Name = 'PGCaseTrigger';
        TECase.Enable_del__c = true;
        insert TECase;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='syncorg@m.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',country ='Malaysia', 
                          LocaleSidKey='en_US', ProfileId = p.Id, Subsidiary__c ='PropertyGuru International (Malaysia) Sdn Bhd',
                          TimeZoneSidKey='America/Los_Angeles', UserName='syncorg@m.com');
        insert u;
        subsidiary__c sb = new Subsidiary__c();
        sb.Name = u.Subsidiary__c;
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Malaysia';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        System.runAs(u){
            Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Account',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Account',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c = accRectype,
                                                                      Destination_Recordtype_Id__c = accRectype,active__c=true);
            insert sd1;
            
            Field_Mapping__c fieldMap1 = new Field_Mapping__c();
            fieldMap1.CurrencyIsoCode = 'SGD';
            fieldMap1.isActive__c = True; 
            fieldMap1.Search_Data__c = sd1.id;
            fieldMap1.Instance_Name__c = 'Both';
            fieldMap1.Label__c = 'Name';    
            fieldMap1.from__c = 'name';
            fieldMap1.To__c = 'Name';
            fieldMap1.Sequennce__c = 50;
            fieldMap1.DataType__c = 'text'; 
            fieldMap1.recordCreation__c = True;
            insert fieldMap1;
            
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Malaysia';
            agency.Subsidiary__c = sb.Id;
            
            insert  agency;  
            
            Account a = new Account();
            a.RecordTypeId = accRectype;
            a.LastName = 'TestYuni';
            a.Agency__c = agency.Id;
            //a.Customer_Type__c = 'Agency';
            a.CurrencyIsoCode = 'SGD';
            a.AgentNet_ID__c = 'TestPurposeIdXX';
            a.Subscription_Start_Date__c = system.today().addMonths(-10);
            a.BillingStreet = 'test';
            a.BillingCity = 'test';
            a.BillingCountry = 'Malaysia';
            a.BillingPostalCode = '83173';
            // a.BillingState = 'test';
            a.Current_Subscription_Code__c = 'abc';
            a.account_rule_code__c = 'Standard';
            a.personemail = 'asd131sfaa@yaho.com';
            a.salutation = 'Mr.';
            a.firstname = 'aaaa';
            a.Country__c = 'Malaysia'; 
            a.Status__c = 'Active';
            a.NetSuite_Id__c = '6777';
            a.CEA_Salesperson_Number__c = 'W567653H';
            a.External_field__c = '867685777';
            a.Overlap_Agent__c = true;
            a.PersonBirthdate=system.today();
            a.Brickz_Agent__c = true;
            a.Mobile_Country__c='65';
            insert a;
             
            Case caseObj = new Case();
            caseObj.RecordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales_Enablement').getRecordTypeId();
            caseObj.Status = 'New';
            caseObj.Subject = 'Tag overlapping agent';
            caseObj.accountid = a.id;
            caseObj.Account_Temp_ExternalField__c = a.id;
            insert caseObj;
            
            Account a1 = new Account();
            a1.RecordTypeId = accRectype;
            a1.LastName = 'TestYuni';
            a1.Agency__c = agency.Id;
            //a.Customer_Type__c = 'Agency';
            a1.CurrencyIsoCode = 'SGD';
            a1.AgentNet_ID__c = 'estPurposeIdXX';
            a1.Subscription_Start_Date__c = system.today().addMonths(-10);
            a1.BillingStreet = 'test';
            a1.BillingCity = 'test';
            a1.BillingCountry = 'Malaysia';
            a1.BillingPostalCode = '80173';
            // a.BillingState = 'test';
            a1.Current_Subscription_Code__c = 'abc';
            a1.account_rule_code__c = 'Standard';
            a1.personemail = 'asd31sfaa@yaho.com';
            a1.salutation = 'Mr.';
            a1.firstname = 'aaaa';
            a1.Country__c = 'Malaysia';
            a1.Status__c = 'Active';
            a1.NetSuite_Id__c = '6779';
            a1.CEA_Salesperson_Number__c = 'W367653H';
            a1.External_field__c = '867680777';
            a1.Overlap_Agent__c = false;
            a1.PersonBirthdate=system.today();
            a1.Brickz_Agent__c = true;
             a1.Mobile_Country__c='65';
            insert a1;
            
            Case caseObj1 = new Case();
            caseObj1.RecordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales_Enablement').getRecordTypeId();
            caseObj1.Status = 'New';
            caseObj1.Subject = 'Tag Brickz Only agent';
            caseObj1.accountid = a1.id;
            caseObj1.Account_Temp_ExternalField__c = a1.id;
            insert caseObj1;
            
            Account a2 = new Account();
            a2.RecordTypeId = accRectype;
            a2.LastName = 'TestYuni';
            a2.Agency__c = agency.Id;
            //a.Customer_Type__c = 'Agency';
            a2.CurrencyIsoCode = 'SGD';
            a2.AgentNet_ID__c = 'TestPurposeIdX';
            a2.Subscription_Start_Date__c = system.today().addMonths(-10);
            a2.BillingStreet = 'test';
            a2.BillingCity = 'test';
            a2.BillingCountry = 'Malaysia';
            a2.BillingPostalCode = '83173';
            // a.BillingState = 'test';
            a2.Current_Subscription_Code__c = 'abc';
            a2.account_rule_code__c = 'Standard';
            a2.personemail = 'sd131sfaa@yaho.com';
            a2.salutation = 'Mr.';
            a2.firstname = 'aaaa';
            a2.Country__c = 'Malaysia';
            a2.Status__c = 'Active';
            a2.NetSuite_Id__c = '0777';
            a2.CEA_Salesperson_Number__c = 'W567643H';
            a2.External_field__c = '867685777';
            a2.Overlap_Agent__c = true;
            a2.PersonBirthdate=system.today();
            a2.Brickz_Agent__c = false;
             a2.Mobile_Country__c='65';
            insert a2;
            
            Case caseObj2 = new Case();
            caseObj2.RecordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales_Enablement').getRecordTypeId();
            caseObj2.Status = 'New';
            caseObj2.Subject = 'Un-Tag overlapping agent';
            caseObj2.accountid = a2.id;
            caseObj2.Account_Temp_ExternalField__c = a2.id;
            insert caseObj2;
            Case caseObj3 = new Case();
            caseObj3.RecordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales_Enablement').getRecordTypeId();
            caseObj3.Status = 'New';
            caseObj3.Subject = 'un-Tag Brickz Only agent';
            caseObj3.accountid = a1.id;
            caseObj3.Account_Temp_ExternalField__c = a1.id;
            insert caseObj3;
            Case caseObj4 = new Case();
            caseObj4.RecordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales_Enablement').getRecordTypeId();
            caseObj4.Status = 'New';
            caseObj4.Subject = ' Only agent';
            caseObj4.accountid = a1.id;
            caseObj4.Account_Temp_ExternalField__c = a1.id;
            insert caseObj4;
            
            test.startTest();
            TagUnTagCase_cc.updateCase(caseObj.id);
            TagUnTagCase_cc.updateCase(caseObj1.id);
            TagUnTagCase_cc.updateCase(caseObj2.id);
            TagUnTagCase_cc.updateCase(caseObj3.id);
            TagUnTagCase_cc.updateCase(caseObj4.id);
            test.stopTest();
        }
    }
}
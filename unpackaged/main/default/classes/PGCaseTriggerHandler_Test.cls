@isTest
public class PGCaseTriggerHandler_Test {
    
    public static testmethod void changeCampaignMemberStatusTest() {
        
        Trigger_Execute__c TEAccMember = new Trigger_Execute__c();
        TEAccMember.Name = 'PGAccountTrigger';
        TEAccMember.Enable_del__c = true;
        insert TEAccMember;
        
        Trigger_Execute__c TEOppMember = new Trigger_Execute__c();
        TEOppMember.Name = 'Trigger_OpportunitySplit';
        TEOppMember.Enable_del__c = true;
        insert TEOppMember;
        
        Trigger_Execute__c TECase = new Trigger_Execute__c();
        TECase.Name = 'PGCaseTrigger';
        TECase.Enable_del__c = true;
        insert TECase;
        
        Trigger_Execute__c TECampMember = new Trigger_Execute__c();
        TECampMember.Name = 'PGCampMemberTrigger';
        TECampMember.Enable_del__c = true;
        insert TECampMember;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'TestLName';
        con.Email = 'test@mail.com'; 
        insert con;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = '89953';
        a.Salutation = 'Mrs.';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        a.Current_Subscription_Code__c = 'abc';
        a.Current_Subscription_Spending_Amount__c = 50;
        a.Pro_Rate_Amount__c =10;
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.AgentKey__c = 'UT91919';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.PersonBirthdate = date.newInstance(1970, 1, 1);
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate=system.today();
        insert a;
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;
      
        
        Case caseObj = new Case();
        caseObj.RecordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales_Enablement').getRecordTypeId();
        caseObj.Status = 'New';
        caseObj.Subject = 'Testing';
        caseObj.Opportunity__c = opp.id;
        caseObj.Type = 'Campaign Support';
        caseObj.ContactId = con.Id;
        caseObj.Case_Sub_Category__c = 'Add Campaign Member';
        insert caseObj;
        
        Case caseObj1 = new Case();
        caseObj1.RecordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales_Enablement').getRecordTypeId();
        caseObj1.Status = 'New';
        caseObj1.Subject = 'Testing';
        caseObj1.Type = 'Campaign Support';
        caseObj1.ContactId = con.Id;
        caseObj1.Case_Sub_Category__c = 'Reinstate Campaign Member';
        insert caseObj1;
        
        Case caseObj2 = new Case();
        caseObj2.RecordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales_Enablement').getRecordTypeId();
        caseObj2.Status = 'New';
        caseObj2.Subject = 'Testing';
        caseObj2.Type = 'Campaign Support';
        caseObj2.ContactId = con.Id;
        caseObj2.Case_Sub_Category__c = 'Revoke Campaign Member';
        insert caseObj2;
        
        List<String> spamEmail = system.Label.SPAM_EMAIL_IDENTIFIER.split(',');
        Case caseObj3 = new Case();
        caseObj3.RecordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Care').getRecordTypeId();
        caseObj3.Status = 'New';
        caseObj3.Origin = 'Email';
        caseObj3.Subject = 'Testing';
        caseObj3.Type = 'Technical';
        caseObj3.ContactId = con.Id;
        caseObj3.Case_Sub_Category__c = 'PG Consumer';
        caseObj3.SuppliedEmail = spamEmail[0];
        insert caseObj3;
        
        Campaign camp = new Campaign();
        camp.Name = 'TestCampaign';
        camp.IsActive = true;
        camp.Country__c = 'Singapore';
        camp.CurrencyIsoCode = 'SGD';
        camp.Source_Campaign_Reference__c='camp1';
        camp.RecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Marketing_Promo').getRecordTypeId();
        camp.StartDate = system.today();
        camp.Campaign_Start_DateTime__c = system.now();
        camp.Campaign_End_DateTime__c = system.now().addDays(+1);
        camp.EndDate = system.today().addDays(+1);
        insert camp;
        
        CampaignMember campMem = new CampaignMember();
        campMem.ContactId = con.id;
        campMem.CampaignId = camp.Id;
        insert campMem;
        
        Test.startTest();
        caseObj.Resolution__c = 'Resolved';
        caseObj.Campaign_Name__c = camp.Id;
        update caseObj;
        
        caseObj1.Resolution__c = 'Resolved';
        caseObj1.Campaign_Name__c = camp.Id;
        update caseObj1;
        
        caseObj2.Resolution__c = 'Resolved';
        caseObj2.Campaign_Name__c = camp.Id;
        update caseObj2;
        Test.stopTest();
    }
}
@isTest
public class SG_RenewalOppty_SendEmailReminder_test {
    
     public static testMethod void unitTest(){
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true); 
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        string quoteRectype = Schema.SObjectType.quote.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Trigger_Execute__c tE = new Trigger_Execute__c();
        tE.Name = 'QuoteLineItemTrigger';
        insert tE;
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        QliToOliFieldMapping__c objcustomsetting=new QliToOliFieldMapping__c();
        objcustomsetting.Name='Start_Date__c';
        objcustomsetting.OliField__c='Start_Date__c';
        insert objcustomsetting;
        
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        objcustom.IsTrackingEnable__c = true;
        insert objcustom;
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        //a.Customer_Type__c = 'Agency';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.Billing_Street_new__c='TEst';
        opp.Billing_City_new__c='city';
        opp.Billing_Country_new__c='Singapore';
        opp.PG_Tenure__c = 1;
        opp.Stinger__c = true;
        opp.Opportunity_Type__c = 'B2C - Renewal';
        opp.Order_Type_Clone__c   = 'Contract - Renewal';
        
        insert opp;
        system.assertEquals(opp.Id,opp.Id,'1');
        
        Quote objquote=new Quote();
        objquote.name='Test';
        objquote.CreatedDate__c=system.today();
        objquote.OpportunityId=opp.Id;
        objquote.Subsidiary__c = sb.id;
        objquote.CurrencyIsoCode = 'SGD';
        objquote.RecordTypeId = quoteRectype;
        insert objquote;
        
        opp.SyncedQuoteId=objquote.Id;
        opp.OMC_Approved_Date__c=system.today();
        opp.stageName='Pending OMC Approval';
        opp.Submit_to_OMC_Manually__c =false;
        
        opp.Approval_Status__c='OMC Approval Approved';
        update opp;
        
        objquote.Status='Pending Online Payment';
        
        objquote.SG_Payment_Link_Expiry__c=system.today().AddDays(15);
        objquote.Guruland_Link_Created_Date__c =system.today().AddDays(10);
        objquote.Approval_Status__c='OMC Approval Approved';
        objquote.Agent_Accepted_Time__c =null;
        
        
        update objquote;
        
        Quote objquote1=new Quote();
        objquote1.name='Test';
        objquote1.CreatedDate__c=system.today();
        objquote1.OpportunityId=opp.Id;
        objquote1.Subsidiary__c = sb.id;
        objquote1.CurrencyIsoCode = 'SGD';
        objquote1.RecordTypeId = quoteRectype;
        insert objquote1;
        
        
        objquote1.Status='Pending Online Payment';
        
        objquote1.SG_Payment_Link_Expiry__c=system.today().AddDays(15);
        objquote1.Guruland_Link_Created_Date__c =system.today().AddDays(10);
        objquote1.Approval_Status__c='OMC Approval Approved';
        objquote1.Agent_Accepted_Time__c =null;
        objquote1.Payment_Next_Reminder_Date__c =system.today().AddDays(7);
        
        
        update objquote1;
        
        System.debug(objquote1.recordtype.name);
        list<quote> quotelist = [Select id  ,Guruland_Link_Created_Date__c,IsSyncing,country__c,Payment_Next_Reminder_Date__c,recordtype.name,SG_Payment_Link_Expiry__c,Quote_Type__c,Status,Agent_Accepted_Time__c from quote where id =:objquote.id OR id =:objquote1.id ];
        system.debug(quotelist[0].status+'--->>>'+quotelist[0].SG_Payment_Link_Expiry__c+'---->>'+quotelist[0].country__c+'---->>'+quotelist[0].IsSyncing+'---->>'+quotelist[0].recordtype.name+'--->>>'+quotelist[0].Quote_Type__c+'-->>'+quotelist[0].Agent_Accepted_Time__c);
        
        test.startTest();
        SG_RenewalOppty_SendEmailReminder obj = new SG_RenewalOppty_SendEmailReminder();
        //   database.executeBatch(obj);
        obj.start(null);
        obj.execute(null,quotelist);
        obj.finish(null);
        test.stoptest();
        
    }
}
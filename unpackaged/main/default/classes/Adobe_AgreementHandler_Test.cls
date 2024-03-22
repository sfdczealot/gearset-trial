@isTest
public class Adobe_AgreementHandler_Test {

    @isTest
    public static void unitTest(){
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;
        
        string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.Name = 'Unit Test Agency';
        a.Customer_Type__c = 'Developer';
 
        a.Phone = '2345';
        insert a;
        
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.email = 'b2b@unittest.com';
        c.Title = 'Mr.';
        c.LastName = 'Unit Test Last Name';
        c.FirstName = 'Unit Test First Name';
        insert c;
        Test.startTest();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        //  opp.Subsidiary__c = sb1.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = b2boppRectype;
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.Order_Type_Clone__c   = 'Contract - Renewal';
        opp.Opportunity_Type__c='B2C - Renewal';
        opp.Subsidiary_Type__c = 'iPP';
        insert opp;
        
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId=Opp.Id,ContactId=c.Id,Role='Client Signatory' );
        insert ocr;
        
        echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
        agreement.echosign_dev1__Recipient__c = c.Id;
        agreement.Name = 'test Agreement';
        agreement.echosign_dev1__Opportunity__c = opp.Id;
        agreement.echosign_dev1__Status__c = 'Draft';
        insert agreement;
        
        Map<id,echosign_dev1__SIGN_Agreement__c> agreementMap = new Map<id,echosign_dev1__SIGN_Agreement__c>();
        agreementMap.put(agreement.Id, agreement);
        
        Adobe_AgreementHandler.restrictSendingContract(agreementMap,agreementMap);
        
        Test.stopTest();
    }
}
@isTest
public class RestrictOppAccountToChangeTest {
    private static Account acc2;
    private static Opportunity opp;
    
    @testSetup
    public static void createTestData() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        List<Account> accs = TestDataSetupTargetables.createAccounts(2);
        
        Account acc = accs[0];
        acc.RecordTypeID = accRectype;
        
        
        acc.Phone = '2345';
        update acc;
        acc2 = accs[1];
       // acc2.parentID = acc.id;
        acc2.RecordTypeID = accRectype;

        acc2.Phone = '23456';
        update acc2;
        
        
        List<Account> accs1 = TestDataSetupTargetables.createAccounts(2);
        
        Account acc3 = accs1[0];
        acc3.RecordTypeID = accRectype;
        acc3.Country__c='Malaysia';

        acc3.Phone = '23451234';
        update acc3;
        
        account acc4 = accs1[1];
       // acc2.parentID = acc.id;
        acc4.RecordTypeID = accRectype;
        acc4.Country__c='Singapore';
        acc4.Phone = '234567890';
        update acc4;
        
        Account agency = TestDataSetupTargetables.createAccount();
        agency.Type = 'Media Agency';
        agency.RecordTypeID = accRectype;
        agency.Phone = '2345';
        insert agency;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Contact con1 = new Contact(FirstName = 'test123', LastName = 'Con123', AccountId = acc2.Id,email='test000111@gmail.com');
        insert con1;
        
        Contact con2 = new Contact(FirstName = 'vghvgv123456', LastName = 'cg123456', AccountId = acc4.Id,email='Restrict000111000@gmail.com');
        insert con2;
        
        
        opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.Name='Test1';
        opp.AccountId = acc.id;
        opp.Media_Agency2__c = agency.id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        opp.Billing_Entity__c = acc.Id;
        opp.b2b_Billing_Contact__c = con.Id;
        opp.Agency_Client_del__c = acc.id;
        opp.Subsidiary_Type__c = 'iPP';
        insert opp;
        
        opportunity opp1 = TestDataSetupTargetables.createOpportunity(acc, con);
        opp1.Name='Test2';
        opp1.AccountId = acc3.id;
        opp1.Media_Agency2__c = agency.id;
        opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        opp1.Billing_Entity__c = acc3.Id;
        opp1.b2b_Billing_Contact__c = con2.Id;
        opp1.Agency_Client_del__c = acc3.id;
        opp1.Subsidiary_Type__c = 'iPP';
       // insert opp1;
        
       
    }
    
    @isTest()
    public static void testBlockChanges() {
       // createTestData();
        
        Test.startTest();
        Map<Id, Opportunity> mapOld = new Map<Id, Opportunity>();
       // mapOld.put(opp.Id, opp);
      //  CS_P_OppBlockChanges process = new CS_P_OppBlockChanges(mapOld);
        
        String message;
        try {
            
            
            opp = 
                [
                    SELECT  Id, 
                    Name,
                    AccountId,
                    Media_Agency2__c,
                    Agency_Client_del__c
                    FROM    Opportunity 
                    LIMIT   1
                ];
            
            mapOld.put(opp.Id, opp);
            CS_P_OppBlockChanges process = new CS_P_OppBlockChanges(mapOld);
            System.debug('%%%'+opp);
            System.debug('###'+acc2.Id);
            
            opp.accountid = acc2.Id;
            update opp;
            
            process.isRecordEligible(opp);
           // process.logic();
        }
        catch (Exception e){
            message = e.getMessage();
            System.debug('%%%'+message);
        }
        Test.stopTest();
        
        // System.assert(message.contains('You can not change the Advertiser or Media Agency when a Sales Order is in an approval process. If you need to update this opportunity, recall your Sales Order.'), message);
    }
    
    @isTest
    public static void testBlockChanges1() {

        Test.startTest();
        Opportunity opp1 = [SELECT Id, Name, AccountId, Media_Agency2__c, Agency_Client_del__c FROM Opportunity where Name='Test1' LIMIT 1];
        Account a = [Select id, Name,Phone From Account Where Phone = '23456'];
        contact con1=[select id, Name, Email from contact where Email='test000111@gmail.com'];
        opp1.accountid = a.Id;
        opp1.Billing_Entity__c=a.Id;
        opp1.b2b_Billing_Contact__c=con1.id;
        try{
        update opp1;
        }catch(exception e){}
        Test.stopTest();
    }
    
     @isTest
    public static void testBlockChanges2() {

        Test.startTest();
        Opportunity opp1 = [SELECT Id, Name, AccountId, Media_Agency2__c, Agency_Client_del__c FROM Opportunity where Name='Test1' LIMIT 1];
        Account a = [Select id, Name,Phone From Account Where Phone = '234567890'];
        contact con1=[select id, Name, Email from contact where Email='Restrict000111000@gmail.com'];
        opp1.accountid = a.Id;
        opp1.b2b_Billing_Contact__c=con1.id;
        try{
        update opp1;
        }catch(exception e){}
        Test.stopTest();
    }
    
     @isTest
    public static void testBlockChanges3() {

        Test.startTest();
        Opportunity opp1 = [SELECT Id, Name, AccountId, Media_Agency2__c, Agency_Client_del__c FROM Opportunity where Name='Test1' LIMIT 1];
        Account a = [Select id, Name,Phone From Account Where Phone = '234567890'];
        contact con1=[select id, Name, Email from contact where Email='Restrict000111000@gmail.com'];
        opp1.accountid = a.Id;
        opp1.b2b_Billing_Contact__c=con1.id;
        opp1.StageName='Closed Won';
        try{
        update opp1;
        }catch(exception e){}
        Test.stopTest();
    }
    
     @isTest
    public static void testBlockChanges4() {

        Test.startTest();
        Opportunity opp1 = [SELECT Id, Name, AccountId, Media_Agency2__c, Agency_Client_del__c FROM Opportunity LIMIT 1];
        Account a = [Select id, Name,Phone From Account Where Phone = '234567890'];
        contact con1=[select id, Name, Email from contact where Email='test000111@gmail.com'];
       
        opp1.Billing_Entity__c=a.Id;
        opp1.b2b_Billing_Contact__c=con1.id;
        try{
        update opp1;
        }catch(exception e){}
        Test.stopTest();
    }
    
     @isTest
    public static void testBlockChanges5() {

        Test.startTest();
        Opportunity opp1 = [SELECT Id, Name, AccountId, Media_Agency2__c, Agency_Client_del__c FROM Opportunity LIMIT 1];
        Account a = [Select id, Name,Phone From Account Where Phone = '234567890'];
        contact con1=[select id, Name, Email from contact where Email='test000111@gmail.com'];
        opp1.b2b_Billing_Contact__c=con1.id;
        try{
        update opp1;
        }catch(exception e){}
        Test.stopTest();
    }
    
}
@isTest
public class PGAccountTrigger_Test_v2 {
    
    private static Account a  = null, ag = null;
    
    @isTest
    public static void testRunSG(){
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs (thisUser) {
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            a = PGTestDataFactory_v2.createB2CAccount('test@test.com','12321', thisUser, sb);
            //standard PB
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            
            opportunity opp =PGTestDataFactory_v2.createB2CSubscriptionOpty(a, thisUser, sb, standardPB, 'B2C - Renewal');
            quote q= PGTestDataFactory_v2.createQuote(opp, sb, a, StandardPB, 'B2C - Renewal', 'Proposal');
            
            Test.startTest();
            a.country__c='Thailand';
            a.PersonMobilePhone='45345454';
            a.Mobile_Country__c='Thailand';
            a.LastName = 'last';
            a.FirstName = 'first';
            try{
                update a;
            }catch(DMLException e){}
            Test.stopTest();  
            
        }
    }
    
    @isTest
    public static void testRunTH(){
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs (thisUser) {
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createIDSubsidiary(thisUser);
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            a = PGTestDataFactory_v2.createB2CAccount('test@test.com','12321', thisUser, sb);
            //standard PB
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            
            opportunity opp =PGTestDataFactory_v2.createB2CSubscriptionOpty(a, thisUser, sb, standardPB, 'B2C - Renewal');
            quote q= PGTestDataFactory_v2.createQuote(opp, sb, a, StandardPB, 'B2C - Renewal', 'Proposal');
            
            Test.startTest();
            a.country__c='Malaysia';
            a.PersonMobilePhone='45345454';
            a.Mobile_Country__c='Malaysia';
            a.LastName = 'last';
            a.FirstName = 'first';
            try{
                update a;
            }catch(DMLException e){}
            Test.stopTest();  
            
        }
    }
    
    @isTest
    public static void testRunMY(){
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs (thisUser) {
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createTHSubsidiary(thisUser);
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            a = PGTestDataFactory_v2.createB2CAccount('test@test.com','12321', thisUser, sb);
            //standard PB
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            
            opportunity opp =PGTestDataFactory_v2.createB2CSubscriptionOpty(a, thisUser, sb, standardPB, 'B2C - Renewal');
            quote q= PGTestDataFactory_v2.createQuote(opp, sb, a, StandardPB, 'B2C - Renewal', 'Proposal');


            Test.startTest();
            a.country__c='Malaysia';
            a.PersonMobilePhone='45345454';
            a.Mobile_Country__c='Malaysia';
            a.LastName = 'last';
            a.FirstName = 'first';
            try{
                update a;
            }catch(DMLException e){}
            Test.stopTest();  
             
        }
    }
    
    @isTest
    public static void testRunID(){
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs (thisUser) {
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createMYSubsidiary(thisUser);
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            a = PGTestDataFactory_v2.createB2CAccount('test@test.com','12321', thisUser, sb);
            //standard PB
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            
            opportunity opp =PGTestDataFactory_v2.createB2CSubscriptionOpty(a, thisUser, sb, standardPB, 'B2C - Renewal');
            quote q= PGTestDataFactory_v2.createQuote(opp, sb, a, StandardPB, 'B2C - Renewal', 'Proposal');


            Test.startTest();
            a.country__c='Indonesia';
            a.PersonMobilePhone='45345454';
            a.Mobile_Country__c='Indonesia';
            a.LastName = 'last';
            a.FirstName = 'first';
            try{
                update a;
            }catch(DMLException e){}
            Test.stopTest();  
             
        }
    }
    
    
  /*  @isTest
    public static void testRunMain(){
		Profile prof = [SELECT Id FROM Profile WHERE Name = 'TH B2C Sales User'];
        UserRole ur= [Select id from UserRole where name = 'TH - Renewal Sales Rep' ];
			
		User userManager = PGTestDataFactory_v2.createUser('gManager','giantestmanager@testorg.com','GianTestmanager',prof.id,ur.Id);
		User thisUser = PGTestDataFactory_v2.createUser('gUser','giantest@testorg.com','GianTest',prof.id,ur.Id);
        system.debug('userManager.Id:' + userManager.Id);
        system.debug('thisUser.Id:' + thisUser.Id);
        thisUser.ManagerId = userManager.Id;
        update thisUser;
        System.runAs (thisUser) {
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createMYSubsidiary(thisUser);
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            a = PGTestDataFactory_v2.createB2CAccount('te1234st@test.com','12321', thisUser, sb);
            
            ag = PGTestDataFactory_v2.createAgencyAccount('Test Agency','1232134', thisUser, sb);
            a.Agency__c = ag.Id;
            a.Status__c = 'Pending';
            update a;
            //standard PB
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            
            
            Test.startTest();
            
            System.runAs (thisUser) {
                a.country__c='Indonesia';
                a.PersonMobilePhone='45345454';
                a.Mobile_Country__c='Indonesia';
                a.LastName = 'last';
                a.FirstName = 'first';
                a.Status__c = 'Trial';
                try{
                    update a;
                }catch(DMLException e){}
            }
            Test.stopTest();  
             
        }
    }
    */
}
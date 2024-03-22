@isTest
    public class oppRejectionUpdate_Batch_Test {
        
        @isTest static void method1()
        {
            User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
            System.runAs (thisUser) {
                // Call method to insert test records
                PGTestDataFactory_v2.initSetupData();
                //data setup
                system.debug('DML TestDataFactory');
                Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
                Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
                Account acc=PGTestDataFactory_v2.createB2CAccount('test@test.com','12321', thisUser, sb);
                opportunity opp =PGTestDataFactory_v2.createB2CSubscriptionOpty(acc, thisUser, sb, standardPB, 'B2C - Renewal');
                opp.StageName='Closed Won';
                opp.OMC_Submitted_Time__c= system.today().AddDays(-30);
                opp.OMC_Rejected_Reason__c=   'test' ;
                update opp;
                quote q= PGTestDataFactory_v2.createQuote(opp, sb, acc, StandardPB, 'B2C - Renewal', 'Proposal');
                Test.startTest();
                oppRejectionUpdate_Batch obj = new oppRejectionUpdate_Batch();
                Database.executeBatch(obj);
                Test.stopTest();
                
                
                
            }
        }
    }
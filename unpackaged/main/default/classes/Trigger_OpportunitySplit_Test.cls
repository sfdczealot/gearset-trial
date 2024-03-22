@isTest
    public class Trigger_OpportunitySplit_Test {
        
        @isTest static void method1()
        { 
            Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
            TEOppSplit.Name = 'Trigger_OpportunitySplit';
            TEOppSplit.Enable_del__c = true;
            insert TEOppSplit;
            
            User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
            System.runAs (thisUser) {
                PGTestDataFactory_v2.initSetupData();
                Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
                Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
                Account acc=PGTestDataFactory_v2.createB2CAccount('test@test.com','12321', thisUser, sb);
                opportunity opp =PGTestDataFactory_v2.createB2CSubscriptionOpty(acc, thisUser, sb, standardPB, 'B2C - Renewal');
                opp.StageName='Closed Won';
                opp.OMC_Submitted_Time__c= system.today().AddDays(-30);
                update opp;
                try{
                OpportunitySplit ost = new OpportunitySplit();  
               ost.OpportunityId= opp.id;
                insert ost;
                }
                catch(Exception e )
                {
                    
                }
                
            }
                
        }
    }
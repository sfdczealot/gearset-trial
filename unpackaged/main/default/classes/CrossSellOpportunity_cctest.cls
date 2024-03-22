@isTest
public class CrossSellOpportunity_cctest {
     @isTest
    public static void test(){
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
         thisUser.Country ='Malaysia';
        update thisUser;
        System.runAs (thisUser) {
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createMYSubsidiary(thisUser);
            
            account   a = PGTestDataFactory_v2.createB2CAccount('test@test.com','12321', thisUser, sb);
            /* a.country__c='Malaysia';
update a;*/
            Test.startTest();
            
            Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            
            Opportunity  opp = PGTestDataFactory_v2.createB2CSubscriptionOpty(a,thisUser,sb,standardPB,'B2C - Standard');
            opp.External_field__c=opp.id;
            update opp;
            Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =opp.RecordTypeId,
                                                                      Destination_Recordtype_Id__c =opp.RecordTypeId,active__c=true);
            insert sd1;
            CrossSellOpportunity_cc.getCrossSellValue(opp.id);
            Test.stopTest();  
            
        }
        
    }
}
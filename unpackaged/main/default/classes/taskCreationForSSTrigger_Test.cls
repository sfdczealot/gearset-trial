@isTest
public class taskCreationForSSTrigger_Test {
   
    @isTest
    public static void test1(){
       
        
        UserRole ur =[select id,parentroleid from userrole where parentroleID!=null limit 1];
        User thisUser = [SELECT Id,Subsidiary__c,profileid FROM User WHERE Id =: UserInfo.getUserId()];
        thisUser.userroleid = ur.parentroleid;
        update thisUser;
        User oppowner =PGTestDataFactory_v2.createUser('qwe','qwerty@qwerty.com.stagingtest','test',thisUser.profileid,ur.id);
      oppowner.Subsidiary__c = thisUser.Subsidiary__c;
        oppowner.isactive=false;
        update oppowner;
            System.runAs (thisUser) {
                 Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
                // Call method to insert test records
                PGTestDataFactory_v2.initSetupData();
                PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            
            account   a = PGTestDataFactory_v2.createB2CAccount('test@test.com','12321', thisUser, sb);
            a.AgentKey__c='SG12321';
            update a;
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);

            opportunity opp2 = PGTestDataFactory_v2.createB2CSubscriptionOpty(a,oppowner,sb,standardPB,'B2C - renewal');
            Task_creation_for_Self_Serve__e tc = new Task_creation_for_Self_Serve__e(region__c='SG',
                                                                     AgentID__c='12321',
                                                                     preferred_slot_From_date__c=System.now(),
                                                                     preferred_slot_to_date__c=System.now());
            
            Test.startTest();
             
            // Publish test event
            Database.SaveResult sr = EventBus.publish(tc);
            
            Test.stopTest();
        }
        
        
    }
}
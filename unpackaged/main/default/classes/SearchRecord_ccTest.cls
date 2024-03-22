@istest
public class SearchRecord_ccTest {
    
    @isTest
    public static void test(){
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        thisUser.Country ='Malaysia';
        update thisUser;
        System.runAs (thisUser) {
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
            PGTestDataFactory_v2.CreateTriggerExecuteCS('PGCaseTrigger',true);
            Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
            PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
            PGTriggerOppSplit.Enable_del__c=true;
            insert PGTriggerOppSplit;
            
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createMYSubsidiary(thisUser);
            
            account   a = PGTestDataFactory_v2.createB2CAccount('test@test.com','12321', thisUser, sb);
            a.NetSuite_Id__c='123456';
            update a;
           // Test.startTest();
            system.debug(a.RecordTypeId);
            Search_and_tag_admin__c sd = new Search_and_tag_admin__c(Destination_Object_API__c ='sandbox',Client__c='test',ClientID__c='test',
                                                                     Source_Object_API__c ='Account',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                     EndPoint__c='test.com',Source_RecordTypeID__c =a.RecordTypeId,
                                                                     Destination_Recordtype_Id__c =a.RecordTypeId,active__c=true);
            insert sd;
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            
            Opportunity  opp = PGTestDataFactory_v2.createB2CSubscriptionOpty(a,thisUser,sb,standardPB,'B2C - Standard');
            Test.startTest();
            Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test'
                                                                      ,Search_Field__c='Name,Id,Country__c,Account.Name',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =opp.RecordTypeId,
                                                                      Destination_Recordtype_Id__c =opp.RecordTypeId,active__c=true);
            insert sd1;
            List<Field_Mapping__c> fmList = new List<Field_mapping__c>();
            fmList.add(new Field_Mapping__c(where_clause__c=true,label__c='qwer',Search_Data__c =sd.id,from__c='Name',to__c='Name',Search_List__c =true,Only_for_creation__c = true, isActive__c =true, related_Object_API__c='Account' ));
            fmList.add(new Field_Mapping__c(where_clause__c=true,label__c='qwer1',Search_Data__c =sd.id,from__c='Id',Search_List__c=true,to__c='Id',Only_for_creation__c = true,related_Object_API__c='Account', isActive__c =true ));
            fmList.add(new Field_Mapping__c(where_clause__c=true,label__c='qwer2',Search_Data__c =sd.id,from__c='Country__c',to__c='Country__c',Only_for_creation__c = true,Search_List__c=true,isActive__c =true ));
            fmList.add(new Field_Mapping__c(where_clause__c=true,Only_for_creation__c =true,label__c='Name',Search_Data__c =sd1.id,from__c='Name',to__c='Name',Search_List__c =true, isActive__c =true,datatype__c='Date' ));
            fmList.add(new Field_Mapping__c(where_clause__c=true,label__c='Id',Search_Data__c =sd1.id,from__c='Id',Search_List__c=true,to__c='Id',Only_for_creation__c = true,isActive__c =true ));
            fmList.add(new Field_Mapping__c(where_clause__c=false,label__c='Account.Name',Search_Data__c =sd1.id,from__c='Account.Name',Search_List__c=true,to__c='Account.Name',Only_for_creation__c = true,isActive__c =true ));
            fmList.add(new Field_Mapping__c(where_clause__c=true,Only_for_creation__c =true,label__c='Stage Name',Search_Data__c =sd1.id,from__c='StageName',to__c='StageName',Search_List__c =true, isActive__c =true,datatype__c='Text' ));
            fmList.add(new Field_Mapping__c(where_clause__c=true,Only_for_creation__c =true,label__c='PersonMobilePhone',Search_Data__c =sd.id,from__c='PersonMobilePhone',to__c='PersonMobilePhone',Search_List__c =true, isActive__c =true,datatype__c='Text' ));
             
            fmList.add(new Field_Mapping__c(where_clause__c=true,label__c='Country',Search_Data__c =sd1.id,from__c='Country__c',to__c='Country__c',Search_List__c=true,isActive__c =true ));
            
            insert fmList;
            
            
            try{
                SearchRecord_cc.updateRec('{ "FirstName": { "from__c": "Related1", "Label__c": "First Name", "To__c": "FirstName" }, "LastName": { "from__c": "Test", "Label__c": "Last Name", "To__c": "LastName" } }',a.id,'overlapping');
            }catch (exception e){}
            try{
                SearchRecord_cc.updateRec('{ "Id": { "from__c": "Related1", "Label__c": "First Name", "To__c": "FirstName" }, "LastName": { "from__c": "Test", "Label__c": "Last Name", "To__c": "LastName" } }',opp.id,'brickz');
            }catch (exception e){}
            try{
                SearchRecord_cc.fetchRecords(a.id,'[{"value":"Jest","key":"LastName","dataType":"text"},{"value":"Malaysia","key":"Country__pc","dataType":"text"},{"value":"Adela","key":"FirstName","dataType":"text"},{"value":"test@tqwer.com","key":"PersonEmail","dataType":"text"}]');
                // SearchRecord_cc.fetchRecords(opp.id,null);
                
            }catch (exception e){}
             
            try{
             SearchRecord_cc.createRec(a.id,null,'Brickz');
             SearchRecord_cc.createRec(a.id,null,'Overlapping');
             SearchRecord_cc.createRec(opp.id,thisuser.id,null);
             SearchRecord_cc.createRec(opp.id,null,null);
           
                 }catch (exception e){}
            opp.external_field__c = opp.id;
            update opp;
            a.External_field__c = a.id;
            update a;
            SearchRecord_cc.getObjFields(opp.id);
            SearchRecord_cc.getObjFields(a.id);
            try{
                 a.Brickz_agent__c = true;
            update a;
            SearchRecord_cc.untagAccount(opp.id,'overlapping');
            }catch(Exception e){
                
            } try{
            SearchRecord_cc.untagAccount(a.id,'brickz');
                 }catch(Exception e){
                
            }
            Test.stopTest();  
            
        }
        
    }
}
/*******************************************************************
 *	Author: Suraj Bisht
 *  Class Name: AccountActions_Test
 *  Description: Test Class of AccountActions
 ******************************************************************/
@isTest(seeAllData=false)
public class AccountActions_Test {
    private static FINAL INTEGER  RECORDLIMIT=101;
    private static String FIRST_NAME='TestAgent';
    private static String LAST_NAME='Account';
    private static String TEST_USER_PROFILE_NAME='Standard User';
    private static String SUSPENDED_AGENT_STATUS='Suspended';
    private static String AGENT_STATUS_API_NAME='Status__c';
    private static String TEST_USER_NAME=FIRST_NAME+'.'+LAST_NAME+'@'+UserInfo.getOrganizationId()+'.com';
    private static Id AGENTRECORDTYPEID =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agent').getRecordTypeId();
            
	@testSetup
    static void setup(){
        Profile p=[select id from Profile where Name=:TEST_USER_PROFILE_NAME];
        
        //Standard Profile User
        User standardUser=PGTestDataFactory_v2.createUser(p.Id,FIRST_NAME,LAST_NAME);
        insert standardUser;
        
        //creating Trigger_Execute__c record
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        
        list<Account> listOfAccountToInsert=new list<Account>();
        //Agent record construction
        for(Integer i=0;i<RECORDLIMIT;i++){
            Account objAccount=PGTestDataFactory_v2.constructAgentAccount(FIRST_NAME,LAST_NAME+'-'+i,AGENTRECORDTYPEID);
            objAccount.OwnerId=standardUser.Id;
            listOfAccountToInsert.add(objAccount);
        }
        //Agent record insertion
        if(!listOfAccountToInsert.isEmpty()){
            insert listOfAccountToInsert;
        }            
    }
/*******************************************************************
 *	Author: Suraj Bisht
 *  Method Name: updateAccountStatus_Positive
 *  Description: Positive test scenario test method
 ******************************************************************/
    @isTest
    static void updateAccountStatus_Positive(){
        User objUser= [select id from User where UserName=:TEST_USER_NAME ];
        list<AccountActions.InputParamCls> listOfInputParams=new list<AccountActions.InputParamCls>();
        for(Account objAccount:[select id,Status__c from Account where RecordTypeId=:AGENTRECORDTYPEID]){
            //Assert to verify agent account record is not suspended
            PGTestDataFactory_v2.verifyAssertCheck(objAccount,AGENT_STATUS_API_NAME,SUSPENDED_AGENT_STATUS,false);
            
            AccountActions.InputParamCls objInputParams=new AccountActions.InputParamCls();
            objInputParams.accountId=objAccount.Id;
            objInputParams.status=SUSPENDED_AGENT_STATUS;
            listOfInputParams.add(objInputParams);
        } 
        
        System.runAs(objUser){
            //Suspending agent record 
            AccountActions.updateAccountStatus(listOfInputParams);
            for(Account objAccount:[select id,Status__c from Account where RecordTypeId=:AGENTRECORDTYPEID]){
                //Assert to verify agent record is suspended
                PGTestDataFactory_v2.verifyAssertCheck(objAccount,AGENT_STATUS_API_NAME,SUSPENDED_AGENT_STATUS,true);
            }
        }
    }
}
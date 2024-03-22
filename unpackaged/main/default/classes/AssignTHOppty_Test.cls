@isTest
public class AssignTHOppty_Test {
    
    
    @testSetup
    public static void dataSetup(){
        UserRole ur= [Select id from 
                      UserRole where name = 'TH - Renewal Sales Rep' ];
        
        
        User runUsser = [Select id, Sales_Head__c,UserRoleId, Webuser_ID__c,Subsidiary__c From User where id =: UserInfo.getUserId()];
        runUsser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        runUsser.UserRoleId=ur.id;
       update runUsser;
     System.runAS(runUsser){ 
            Subsidiary__c sb = new Subsidiary__c();
            sb.Name = 'PropertyGuru Pte Ltd';
            sb.NS_Subsidiary_Internal_ID__c = '1';
            sb.CurrencyIsoCode = 'SGD';
            sb.Tax_Label__c = 'taxLabel';
            sb.Country__c = 'Singapore';
            sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
            
            insert sb;
            
            System.debug(runUsser.Subsidiary__c);
            string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
            PGTestDataFactory_v2.initSetupData();
            list<Account> accList=new List<account>();
            list<Opportunity> oppList=new List<opportunity>();
            for(Integer i=0;i<10;i++){
                Account a = new Account();
                a.RecordTypeId = accRectype;
                a.LastName = 'PGAccount'+i;
                a.salutation = 'Mr.';
                a.FirstName = 'abc';
                a.CEA_Salesperson_Number__c=i+'';
                a.CurrencyIsoCode = 'SGD';
                a.Subscription_Start_Date__c = system.today().addMonths(-10);
                a.BillingStreet = 'test';
                a.BillingCity = 'test';
                a.BillingCountry = 'Singapore';
                a.BillingPostalCode = '8373';
                //a.BillingState = 'test';
                a.PersonBirthdate=system.today();
                a.Current_Subscription_Code__c = 'abc';
                a.Account_Rule_Code__c = 'test';
                a.AgentNet_ID__c = '123'+i;
                a.PersonEmail = 'test121'+i+'@test.com';
                a.Country__c = sb.Country__c;
                a.Status__c = 'Active';
                a.OwnerId = runUsser.Id;
                accList.add(a);
            }
            insert accList;
            
            for(integer j=0;j<1;j++){
                Opportunity opp = new opportunity();
                opp.Name = 'Test Opp';
                opp.StageName = 'Proposal';
                opp.AccountId = accList[j].id;
                opp.CloseDate = system.today().AddDays(30);
                opp.Subsidiary__c = sb.id;
                opp.Total_Spending__c = 100;
                opp.RecordTypeId = oppRectype;
                opp.PG_Tenure__c = 1;
                opp.NetSuite_Sales_Order__c = 'Contract - Renewal';
                // insert opp;
                
                OppList.add(opp);
            }
            
            insert oppList;
        }
    }
    
    @isTest
    public static void test(){
         User runUsser = [Select id, Sales_Head__c,UserRoleId, Webuser_ID__c,Subsidiary__c From User where id =: UserInfo.getUserId()];
        System.runAS(runUsser){ 
        List<opportunity> oppList=[Select id from opportunity];
        Map<String, list<Opportunity>> ruleCodeMap  = new Map<String, list<Opportunity>>();
        ruleCodeMap.put('advance',oppList);
        test.starttest();
        AssignTHOppty.assignOppty(ruleCodeMap);
        test.stopTest();
        
        
        system.assertEquals(1,oppList.size(),'opp size does not match');
        }
    }
}
@isTest
public class AssignMY_SGRenewalOpp_test  {
    
    
    @testSetup
    public static void dataSetup(){
        
        UserRole ur= [Select id from 
                      UserRole where name = 'MY - Renewal Team Lead' ];
       // PGTestDataFactory_v2.initSetupData();
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
            sb.Country__c = 'Malaysia';
            sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
            
            insert sb;
          PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);   
            System.debug(runUsser.Subsidiary__c);
            string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
            
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
                a.BillingPostalCode = '83723';
                //a.BillingState = 'test';
                a.Account_Rule_Code__c='LITE';
                a.Current_Subscription_Code__c = 'abc';

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
                opp.Order_Type_Clone__c = 'Contract - Renewal';
                // insert opp;
                
                OppList.add(opp);
                
                
            }
            
            insert oppList;
         
          list<Upgrade_Package_Lookup__c> listUPL = new list<Upgrade_Package_Lookup__c>();
        Upgrade_Package_Lookup__c upl = new Upgrade_Package_Lookup__c();
        upl.Country__c = sb.Country__c;
        upl.Name = 'Lite - MY';
        upl.Level__c = 1;
        upl.Upgrade_SKU__c = 'abc';
        upl.Renewal_SKU__c = 'test';
       // listUPL.add(upl);
        insert upl;
        }
    }
    
    @isTest
    public static void test(){
         User runUsser = [Select id, Sales_Head__c,UserRoleId, Webuser_ID__c,Subsidiary__c From User where id =: UserInfo.getUserId()];
        System.runAS(runUsser){ 
        List<opportunity> oppList=[Select id from opportunity];
        Map<String, list<Opportunity>> ruleCodeMap  = new Map<String, list<Opportunity>>();
        ruleCodeMap.put('lite',oppList);
        test.starttest();
        AssignMY_SGRenewalOpp.assignMYRenewalOppty(ruleCodeMap);
        test.stopTest();
        
        
        system.assertEquals(1,oppList.size(),'opp size does not match');
        }
    }
}
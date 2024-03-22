@isTest
public class LSDUpdateTriggerHandler_Test {
    public static testmethod  void Method1(){
        
        Test.startTest();
        Trigger_Execute__c TE1 = new Trigger_Execute__c();
        TE1.Name = 'PGAccountTrigger';
        TE1.Enable_del__c = true;
        insert TE1;
        
        Map<Id,Id> accmap = new Map<Id,Id>();
        Account act =new Account();
        act.Name='HelloTest';
        act.Customer_Type__c='Agency';
        act.CurrencyIsoCode='EUR';
        insert act;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGLSDUpdateTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Map< Id,LSD_Update__c> lsdoldmap = new Map< Id,LSD_Update__c>();
        List< LSD_Update__c> lsdlist = new List< LSD_Update__c>();
        LSD_Update__c lsd = new LSD_Update__c();
        lsd.Approval_Status__c ='Submit for approval';
        lsd.Account__c =act.id;
        lsd.Loyalty_Start_Date__c = system.today();
        insert lsd;
        lsdlist.add(lsd);
        lsdoldmap.put(lsd.id,lsd);
        lsd.Loyalty_Start_Date__c =system.today().adddays(1);
        lsd.Approval_Status__c ='Approved';
        update lsd;
        test.stopTest();
    }    
}
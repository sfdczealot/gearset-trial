@isTest
public class OpportunityContactRoleTrigger_test {
    
    @testSetup
    public static void testData(){
      /* QliToOliFieldMapping__c objcustomsetting=new QliToOliFieldMapping__c();
        objcustomsetting.Name='Start_Date__c';
        objcustomsetting.OliField__c='Start_Date__c';
        insert objcustomsetting;*/
        
        Opportunity opp = null;
        Account acc_b2c  = null;
        Account acc_b2b  = null;
        
        // Avoid mixed DML
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        system.debug('@@@thisUser'+ thisUser);
        System.runAs (thisUser) {
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createMYSubsidiary(thisUser);
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            
            //acc_b2b=PGTestDataFactory_v2.createAgencyAccount('abc def','1232', thisUser, sb);
            //acc_b2c = PGTestDataFactory_v2.createB2CAccount('test@test.com','1232', thisUser, sb);
            /*acc_b2b.NetSuite_Id__c='123452';
            acc_b2b.BillingStreet='test';
            acc_b2b.BillingCity='test';
            acc_b2b.Country__c ='Malaysia';
            acc_b2b.Status__c = 'Pending';
            acc_b2b.Agency_Id__c = '3456789';
            update acc_b2b;*/
            acc_b2c = PGTestDataFactory_v2.createB2CAccount('test@test.com','1232', thisUser, sb);
            acc_b2c.NetSuite_Id__c='1234532';
            acc_b2c.BillingStreet='test1';
            acc_b2c.BillingCity='test2';
            acc_b2c.Country__c ='Malaysia';
            acc_b2c.Status__c = 'Active';
            acc_b2c.Agency_Id__c = '34567892';
            update acc_b2c;
            
            Id personConId = [Select Id, PersonContactId from Account where Id =: acc_b2c.Id].PersonContactId;
            /*contact con =PGTestDataFactory_v2.createContact('aaa','aaa','test@qwerty.com');
           // con.NetSuite_Id__c='1234';
            con.accountid=acc_b2c.id;
            update con;*/
             
            /*acc_b2c.NetSuite_Id__c='1234';
            update acc_b2c;*/
           
            test.Starttest();
            //  acc_b2c.NetSuite_Customer_Id__pc='test';
            //standard PB
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            //Discretionary Class
            Product_Class__c productClass = PGTestDataFactory_v2.createProductClass('Discretionary',sb);
            
            //item
            list<Product2> listProd = new list<Product2>();
            Product2 prod = PGTestDataFactory_v2.CreateProduct('Test Prod', 'B2C Only', 'Discretionary', 'abc', productClass, taxcode);
            listProd.add(prod);
            Product2 prod2 = PGTestDataFactory_v2.CreateProduct('Test Prod2', 'B2C Only', 'Discretionary', 'abc', productClass, taxcode);
            listProd.add(prod2);
            insert listProd;
            
            //sg pbe
            Id StdpricebookId = Test.getStandardPricebookId();
            list<PricebookEntry> listPBE = new list<PricebookEntry>();
            PricebookEntry pbe = PGTestDataFactory_v2.CreatePBE(StdpricebookId, prod, 100.0, sb,false);
            PricebookEntry pbe2 = PGTestDataFactory_v2.CreatePBE(standardPB.Id, prod, 100.0, sb,true);
            
            //opp = PGTestDataFactory_v2.createB2cSubscriptionOpty(acc_b2c,thisUser,sb,standardPB, 'B2C - Upgrade');
            opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Proposal';
            opp.AccountId = acc_b2c.id;
            opp.CloseDate = system.today().AddDays(-30);
            opp.Subsidiary__c = sb.id;
            opp.Opportunity_Type__c = 'B2C - Upgrade';
            opp.Months_Included__c = false;
            opp.Is_Current_Subscription__c = true;
            opp.RecordTypeId = PGtUtils.getRecordTypeId('B2C', 'Opportunity', null);
            opp.Include_Subscription_Ext__c = true;
            opp.OwnerId = thisUser.Id;
            opp.Pricebook2Id = standardPB.Id;
            // Disabled triggers
            CS_utl_User.disableAllTriggers(UserInfo.getUserId());
            insert opp;
            
            OpportunityLineItem oppLine = PGTestDataFactory_v2.CreateOppLineItem(opp,pbe2,prod);
            OpportunityContactRole ocr= PGTestDataFactory_v2.CreateOCR(opp.id,personConId,'others');
   
            //Enabled triggers
            CS_utl_User.enableAllTriggers(UserInfo.getUserId());
            insert ocr;
               OpportunityContactRole ocr1= PGTestDataFactory_v2.CreateOCR(opp.id,personConId,'Campaign contact');
            try{
            insert ocr1;
            }catch(exception e){}
            test.stopTest();
        }
    }
    public static testMethod void mainTest(){
        
        Account Billing_acc = new Account();
        Billing_acc.Name = 'Test Account';
        Billing_acc.NetSuite_Id__c ='1234';
        insert Billing_acc;
        
        Contact Billing_con = new Contact();
        Billing_con.FirstName ='Test';
        Billing_con.AccountId =Billing_acc.Id;
        Billing_con.LastName ='Contact';
        Billing_con.Email='test@qwerty.com';
        Billing_con.NetSuite_Id__c ='1234';
        insert Billing_con;
        
        opportunity opp =[select id from opportunity];
        contact c =[Select Name,NetSuite_Id__c,Account_s_NetSuite_Id__c From contact where email='test@qwerty.com'];
        system.debug('>>>> con'+c);
        
        test.startTest();
        OpportunityContactRole ocr1=[select id,role,contact.NetSuite_Id__c,contact.Account_s_NetSuite_Id__c from OpportunityContactRole where role='others'];
        system.debug('ocr '+ocr1);   
        ocr1.ContactId=c.id;
        ocr1.role='Billing contact';
        update ocr1;
       /*  OpportunityContactRole ocr2=[select id,role,contact.NetSuite_Id__c,contact.Account_s_NetSuite_Id__c from OpportunityContactRole where role='campaign contact'];
       ocr2.role='billing contact';*/
       
        opp.OMC_Approved_Date__c = system.today();
        opp.StageName = 'Closed Won';
        opp.Approval_Status__c = 'OMC Approval Approved';
        opp.Total_Spending_on_Discretionary_Prod_new__c = 300;
        opp.Re_print_Contract__c = true;
        opp.closedate=system.today().addMonths(-48);
        update opp;
        
        ocr1.role='Others';
        // update ocr1;
        try{
            
            update ocr1;
        }
        catch (Exception e){
        }
          try{
           //  update ocr2;
        } catch (exception e){
            
        }
        try{
            // delete ocr2;
        } catch (exception e){
            
        }
        try{
            delete ocr1;
        } catch (Exception e){
        }
        test.stopTest();
    }
    
}
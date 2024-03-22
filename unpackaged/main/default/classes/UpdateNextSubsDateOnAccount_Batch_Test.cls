@isTest
public class UpdateNextSubsDateOnAccount_Batch_Test {
    
    @isTest 
    public static void method1(){
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs (thisUser) {
            
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            Account acc=PGTestDataFactory_v2.createB2CAccount('test@test.com','12321', thisUser, sb);
            acc.Next_Subscription_Activation_Date__c = null;
            update acc;
            opportunity opp =PGTestDataFactory_v2.createB2CSubscriptionOpty(acc, thisUser, sb, standardPB, 'B2C - Renewal');
            opp.StageName='Closed Won';
            opp.OMC_Submitted_Time__c= system.today().AddDays(-30);
            opp.OMC_Rejected_Reason__c=   'test' ;
            opp.Count_of_subscription_item_new__c = 1;
            opp.OMC_Approved_Date__c = system.today().AddDays(1);
            update opp;
            
            //Subscription Class
            Product_Class__c productClass = PGTestDataFactory_v2.createProductClass('Subscription',sb);
            
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            
            //item
            list<Product2> listProd = new list<Product2>();
            Product2 prod = PGTestDataFactory_v2.CreateProduct('Test Prod', 'B2C Only', 'Subscription', 'abc', productClass, taxcode);
            listProd.add(prod);
            insert listProd;
            
            Id StdpricebookId = Test.getStandardPricebookId();
            list<PricebookEntry> listPBE = new list<PricebookEntry>();
            PricebookEntry pbe = PGTestDataFactory_v2.CreatePBE(StdpricebookId, prod, 100.0, sb,false);
            PricebookEntry pbe2 = PGTestDataFactory_v2.CreatePBE(standardPB.Id, prod, 100.0, sb,true);
            
            OpportunityLineItem oli = PGTestDataFactory_v2.CreateOppLineItem(opp,pbe2,prod);
            oli.SNo__c = 10;
            update oli;
            
            Test.startTest();
            
            UpdateNextSubsDateOnAccount_Batch obj = new UpdateNextSubsDateOnAccount_Batch();
            Database.executeBatch(obj);
            
            Test.stopTest();
        }
    }
    
    // case where oli start date is > OMC_Approved_Date__c
    @isTest 
    public static void method2(){
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs (thisUser) {
            
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            Account acc=PGTestDataFactory_v2.createB2CAccount('test@test.com','12321', thisUser, sb);
            acc.Next_Subscription_Activation_Date__c = null;
            update acc;
            opportunity opp =PGTestDataFactory_v2.createB2CSubscriptionOpty(acc, thisUser, sb, standardPB, 'B2C - Renewal');
            opp.StageName='Closed Won';
            opp.OMC_Submitted_Time__c= system.today().AddDays(-30);
            opp.OMC_Rejected_Reason__c=   'test' ;
            opp.Count_of_subscription_item_new__c = 1;
            opp.OMC_Approved_Date__c = system.today().AddDays(1);
            update opp;
            
            //Subscription Class
            Product_Class__c productClass = PGTestDataFactory_v2.createProductClass('Subscription',sb);
            
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            
            //item
            list<Product2> listProd = new list<Product2>();
            Product2 prod = PGTestDataFactory_v2.CreateProduct('Test Prod', 'B2C Only', 'Subscription', 'abc', productClass, taxcode);
            listProd.add(prod);
            insert listProd;
            
            Id StdpricebookId = Test.getStandardPricebookId();
            list<PricebookEntry> listPBE = new list<PricebookEntry>();
            PricebookEntry pbe = PGTestDataFactory_v2.CreatePBE(StdpricebookId, prod, 100.0, sb,false);
            PricebookEntry pbe2 = PGTestDataFactory_v2.CreatePBE(standardPB.Id, prod, 100.0, sb,true);
            
            OpportunityLineItem oli = PGTestDataFactory_v2.CreateOppLineItem(opp,pbe2,prod);
            oli.SNo__c = 10;
            oli.Start_Date__c = system.today().addDays(2);
            oli.End_Date__c = system.today().addDays(3);
            update oli;
            
            Test.startTest();
            
            UpdateNextSubsDateOnAccount_Batch obj = new UpdateNextSubsDateOnAccount_Batch();
            Database.executeBatch(obj);
            
            Test.stopTest();
        }
    }
        
    
    @isTest 
    public static void method3(){
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs (thisUser) {
            
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            Account acc=PGTestDataFactory_v2.createB2CAccount('test@test.com','12321', thisUser, sb);
            acc.Next_Subscription_Activation_Date__c = null;
            update acc;
            opportunity opp =PGTestDataFactory_v2.createB2CSubscriptionOpty(acc, thisUser, sb, standardPB, 'B2C - Renewal');
            opp.StageName='Closed Won';
            opp.OMC_Submitted_Time__c= system.today().AddDays(-30);
            opp.OMC_Rejected_Reason__c=   'test' ;
            opp.Count_of_subscription_item_new__c = 1;
            opp.OMC_Approved_Date__c = system.today().AddDays(1);
            update opp;
            
            //Subscription Class
            Product_Class__c productClass = PGTestDataFactory_v2.createProductClass('Subscription',sb);
            
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            
            //item
            list<Product2> listProd = new list<Product2>();
            Product2 prod = PGTestDataFactory_v2.CreateProduct('Test Prod', 'B2C Only', 'Subscription', 'abc', productClass, taxcode);
            listProd.add(prod);
            insert listProd;
            
            Id StdpricebookId = Test.getStandardPricebookId();
            list<PricebookEntry> listPBE = new list<PricebookEntry>();
            PricebookEntry pbe = PGTestDataFactory_v2.CreatePBE(StdpricebookId, prod, 100.0, sb,false);
            PricebookEntry pbe2 = PGTestDataFactory_v2.CreatePBE(standardPB.Id, prod, 100.0, sb,true);
            
            OpportunityLineItem oli = PGTestDataFactory_v2.CreateOppLineItem(opp,pbe2,prod);
            oli.SNo__c = 10;
            update oli;
            
            update opp;
            
            Test.startTest();
            
            UpdateNextSubsDateOnAccount_Batch obj = new UpdateNextSubsDateOnAccount_Batch();
            Database.executeBatch(obj);
            
            Test.stopTest();
        }
    }
}
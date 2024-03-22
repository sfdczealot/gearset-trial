@isTest
public class BatchToHardDelete_OLIHIstory_test {
    static testMethod void runTest() {
        
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs (thisUser) {
            Trigger_Execute__c TE2 = new Trigger_Execute__c();
            TE2.Name = 'Trigger_OpportunitySplit';
            TE2.Enable_del__c = true;
            insert TE2; 
            
            PGTestDataFactory_v2.initSetupData();
            test.startTest();
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            list<Account> listAcc = new list<Account>();
            Account a = PGTestDataFactory_v2.createB2CAccount('test@test.com','1232', thisUser, sb);
            //Discretionary Class
            Product_Class__c productClass = PGTestDataFactory_v2.createProductClass('Discretionary',sb);
            Opportunity opp =  PGTestDataFactory_v2.createB2cSubscriptionOpty(a,thisUser,sb,standardPB, 'B2C - Upgrade');
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            
            Product2 prod  = PGTestDataFactory_v2.CreateProduct('Test Prod', 'B2C Only', 'Discretionary', 'abc', productClass, taxcode);
            Id StdpricebookId = Test.getStandardPricebookId();
insert prod;            
            PricebookEntry pbe = PGTestDataFactory_v2.CreatePBE(StdpricebookId, prod, 100.0, sb,false);
            PricebookEntry pbe2 = PGTestDataFactory_v2.CreatePBE(standardPB.Id, prod, 100.0, sb,true);
            OLI_Field_History__c oli_hist_rec = new OLI_Field_History__c();
            oli_hist_rec.Field_Name__c = 'test';
            oli_hist_rec.Opportunity__c = opp.id;
           // oli_hist_rec.LineId__c  = oplineItem.id;
            oli_hist_rec.Old_Value__c = 'test';
            oli_hist_rec.New_Value__c = 'test';
            oli_hist_rec.Type__c = 'UPDATE';
            //oli_hist_rec.User__c  = ;
            insert oli_hist_rec;
            Database.executeBatch(new BatchToHardDelete_OLIHIstory());
        }
        
        
        Test.stopTest();
        
    }
}
@isTest
public class SendNotify_Test_v2 {
    
    static testMethod void mainTest(){
        // Avoid mixed DML
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs (thisUser) {
            PGTestDataFactory_v2.initSetupData();
            Trigger_Execute__c customsetting=new Trigger_Execute__c();
            customsetting.Name='Trigger_OpportunitySplit';
            customsetting.Enable_del__c=true;
            insert customsetting;
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            //acc_b2c = PGTestDataFactory_v2.createB2CAccount('test@test.com','1232134', thisUser, sb);
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Singapore';
            agency.Subsidiary__c = sb.id;
            listAccount1.add(agency);
            
            Media__c newMedia = new Media__c();
            newMedia.Account__c = listAccount1[0].id;
            newMedia.CurrencyIsoCode = 'SGD';
            newMedia.IsActive__c = True;
            insert newMedia;
            
            Blob bodyblob = Blob.valueOf('PG Agency default');
            Contentversion cv = new contentversion(title ='PG Agency default',PathOnClient ='PG Agency default.jpg',versiondata = bodyblob,origin ='H');
            insert cv;
            
            ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conVersion.ContentDocumentId;
            cdl.LinkedEntityId = newMedia.id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers'; 
            insert cdl;
            insert listAccount1;
            
            
            // Call method to insert test records
            
            
            
            string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
            //   a = PGTestDataFactory_v2.createB2CAccount('test1@test.com','123', thisUser, sb);
            Account a = new Account();
            a.RecordTypeId = accRectype;
            a.LastName = 'TestYuni';
            a.salutation = 'Mr.';
            a.FirstName = 'abc';
            a.CurrencyIsoCode = 'SGD';
            a.Subscription_Start_Date__c = system.today().addMonths(-10);
            a.BillingStreet = 'test';
            a.BillingCity = 'test';
            a.BillingCountry = 'Singapore';
            a.BillingPostalCode = '8373';
            //a.BillingState = 'test';
            a.Current_Subscription_Code__c = 'abc';
            a.Account_Rule_Code__c = 'test';
            a.AgentNet_ID__c = '123';
            a.PersonEmail = '12121assas@yahoo.com';
            a.Country__c = 'Singapore';
            a.Mobile_Country__c=PGTestDataFactory_v2.getActivePicklistValue('Account','Mobile_Country__c');
            a.CEA_Salesperson_Number__c='R564763K';
            a.PersonBirthdate=system.today();
            a.Status__c = 'Active';
            insert a;
            
            //standard PB
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            //Subscription Class
            Product_Class__c productClass = PGTestDataFactory_v2.createProductClass('Subscription',sb);
            
            //item
            list<Product2> listProd = new list<Product2>();
            Product2 prod = PGTestDataFactory_v2.CreateProduct('Test Prod', 'B2C Only', 'Subscription', 'abc', productClass, taxcode);
            listProd.add(prod);
            Product2 prod2 = PGTestDataFactory_v2.CreateProduct('Test Prod2', 'B2C Only', 'Subscription', 'abc', productClass, taxcode);
            listProd.add(prod2);
            insert listProd;
            
            //sg pbe
            Id StdpricebookId = Test.getStandardPricebookId();
            list<PricebookEntry> listPBE = new list<PricebookEntry>();
            PricebookEntry pbe = PGTestDataFactory_v2.CreatePBE(StdpricebookId, prod, 100.0, sb,false);
            PricebookEntry pbe2 = PGTestDataFactory_v2.CreatePBE(standardPB.Id, prod, 100.0, sb,true);
            
            string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Proposal';
            opp.AccountId = a.id;
            opp.CloseDate = system.today().AddDays(30);
            opp.Subsidiary__c = sb.id;
            opp.Total_Spending__c = 100;
            opp.RecordTypeId = oppRectype;
            opp.PG_Tenure__c = 1;
            opp.Stinger__c = true;
            opp.Opportunity_Type__c = 'B2C - Renewal';
            opp.Order_Type_Clone__c = 'Contract - Renewal';
            insert opp;
            
            list<id> oppId = new list<id>();
            oppId.add(opp.Id);
            
            OpportunityLineItem oppLine = PGTestDataFactory_v2.CreateOppLineItem(opp,pbe2,prod);
            
            
            map<Id,Account> OldMapAcc = new map<Id,Account>();
            OldMapAcc.put(a.id,a);
            Test.startTest();
            list<account> acc = new list<account>();
            acc.add(a);
            list<id> accIds = new list<id>();
            accIds.add(a.id);
            list<id> optyIds = new list<id>();
            optyIds.add(opp.id);
            SendNotify.afterInsert(accIds);
            SendNotify.updateAccountHandler(acc,OldMapAcc);
            SendNotify.insertAccountHandler(acc);
            SendNotify.agencyLogoSync(listAccount1);
            SendNotify.updateOpportunity(oppId);
            Test.stopTest();
        }
    }
    
}
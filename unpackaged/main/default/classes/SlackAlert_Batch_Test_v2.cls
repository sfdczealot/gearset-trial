@isTest
public class SlackAlert_Batch_Test_v2 {

    static testMethod void mainTest(){
        Opportunity opp = null;
        Account acc_b2c  = null;
		// Avoid mixed DML
		User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
		System.runAs (thisUser) {
			// Call method to insert test records
			PGTestDataFactory_v2.initSetupData();
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            acc_b2c = PGTestDataFactory_v2.createB2CAccount('test@test.com','1232134', thisUser, sb);
            
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

            opp = PGTestDataFactory_v2.createB2CSubscriptionOpty(acc_b2c,thisUser,sb,standardPB, 'B2C - Upgrade');
			OpportunityLineItem oppLine = PGTestDataFactory_v2.CreateOppLineItem(opp,pbe2,prod);
            
            opp.OMC_Approved_Date__c = system.today();
            opp.StageName = 'Closed Won';
            opp.Approval_Status__c = 'OMC Approval Approved';
            opp.Count_of_subscription_item_new__c = 1;
            opp.Attachment_Limit_Exceeded__c = true;
            update opp;
		}

		Test.startTest();
        
        database.executeBatch(new SlackAlert_Batch());
        system.schedule('SlackAlert_BatchSchedulable', '0 0 0 * * ? *', new SlackAlert_BatchSchedulable());
        
		Test.stopTest();
        //assert
        //system.assertEquals(null, null);
	}
    
}
@isTest
public class AccountCSSRefundCOVID_DF_Test_v2 {

    static testMethod void subscriptionTest(){
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
            opp.Summary_Of_Subscription_Item_new__c = 300;
            update opp;
            
		}

		Test.startTest();
        Database.executeBatch(new AccountCSSRefundCOVID_DF());
        Test.stopTest();
        
        //assert
        system.assertEquals(300, [select Current_Subscription_Spending_Amount__c from account where id = :acc_b2c.id].Current_Subscription_Spending_Amount__c);
	}
    
    static testMethod void discretinaryTest(){
        Opportunity opp = null, opp2 = null;
        Account acc_b2c  = null, acc_b2c_2 = null;
		// Avoid mixed DML
		User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
		System.runAs (thisUser) {
			// Call method to insert test records
			PGTestDataFactory_v2.initSetupData();
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            acc_b2c_2 = PGTestDataFactory_v2.createB2CAccount('test2@test.com','12321342', thisUser, sb);
            
            //standard PB
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            //Subscription Class
            Product_Class__c productClass = PGTestDataFactory_v2.createProductClass('Subscription',sb);
            //Discretionary Class
            Product_Class__c productClass_disc = PGTestDataFactory_v2.createProductClass('Discretionary',sb);
            
            //item
            list<Product2> listProd_2 = new list<Product2>();
            Product2 prod_2 = PGTestDataFactory_v2.CreateProduct('Test Prod disc', 'B2C Only', 'Discretionary', 'abc', productClass_disc, taxcode);
            listProd_2.add(prod_2);
            Product2 prod2_2 = PGTestDataFactory_v2.CreateProduct('Test Prod2 disc', 'B2C Only', 'Discretionary', 'abc', productClass_disc, taxcode);
            listProd_2.add(prod2_2);
            insert listProd_2;
            
            //sg pbe
            Id StdpricebookId = Test.getStandardPricebookId();
            PricebookEntry pbe_2 = PGTestDataFactory_v2.CreatePBE(StdpricebookId, prod_2, 100.0, sb,false);
            PricebookEntry pbe2_2 = PGTestDataFactory_v2.CreatePBE(standardPB.Id, prod_2, 100.0, sb,true);

            
            opp2 = PGTestDataFactory_v2.createB2CSubscriptionOpty(acc_b2c_2,thisUser,sb,standardPB,'B2C - Standard');
			OpportunityLineItem oppLine = PGTestDataFactory_v2.CreateOppLineItem(opp2,pbe2_2,prod_2);
            
            opp2.OMC_Approved_Date__c = system.today();
            opp2.StageName = 'Closed Won';
            opp2.Approval_Status__c = 'OMC Approval Approved';
            opp2.Count_of_subscription_item_new__c = 0;
            update opp2;
            system.debug('opp2 yey:' + [select Id, AccountId, Summary_Of_Subscription_Item_new__c,isWon,Is_Current_Subscription__c,Include_Subscription_Ext__c from Opportunity where AccountId =: acc_b2c_2.id   and isWon = true and (Is_Current_Subscription__c = true AND Include_Subscription_Ext__c  = true) ORDER BY OMC_Approved_Date__c DESC]);
		}

		Test.startTest();
        Database.executeBatch(new AccountCSSRefundCOVID_DF());
		Test.stopTest();
        
        //assert
        system.assertEquals(0.00, [select Current_Subscription_Spending_Amount__c from account where id = :acc_b2c_2.id].Current_Subscription_Spending_Amount__c);
        
	}
    
}
@isTest
public class IncorrectCSS_Alert_BatchTest {

    @isTest
    static void testIncorrectCSSAlert() {
        Trigger_Execute__c TE2 = new Trigger_Execute__c();
        TE2.Name = 'Trigger_OpportunitySplit';
        TE2.Enable_del__c = true;
        insert TE2;
        
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        
        
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;

        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;

        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();

        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        a.Current_Subscription_Code__c = 'abc';
        a.Current_Subscription_Spending_Amount__c = 50;
        a.Pro_Rate_Amount__c =10;
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.AgentKey__c = 'UT91919';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.PersonBirthdate = date.newInstance(1970, 1, 1);
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'E874592K';
        a.PersonBirthdate=system.today();
        insert a;

        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Closed Won';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.Summary_Of_Subscription_Item_new__c = 10.00;
        opp.OMC_Submitted_Time__c = system.today();
		opp.Approval_Status__c = 'OMC Approval Approved';
        opp.Opportunity_Type__c='B2C - Upgrade';
        opp.Pro_Rate__c=7;
        opp.OMC_Approved_Date__c= system.today();
        insert opp;

        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book',  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;

        Product_Class__c prodClass = New Product_Class__c(Name='Subscription',	CurrencyIsoCode='SGD');
        insert prodClass;

        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test',  Product_Type__c='PG',Description='DummyText'
                                      ,Is_Bundle__c=true,Product_Class__c = prodClass.id);
        insert prod;
        prod.Product_Category__c = 'Subscription';
        update prod;


        Id StdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id ,unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;

        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Quantity = 500;
        oli.Start_Date__c= system.today();
        oli.End_Date__c =system.today().adddays(1);
        oli.UnitPrice = 10000;
        oli.Product_Category__c = 'Subscription';
        oli.Complimentary__c = false;
        oli.Discount_Reason__c ='VIP (Relationship)';
        oli.Amount_Despite_VIP__c = 10;
        insert oli;
        oli.Product_Category__c = 'Subscription';
         oli.Push_to_NetSuite__c = true;
        update oli;
        listOppLine.add(oli);
        List<OpportunityLineItem> listAllLineItem = [
            SELECT id,Product_Category__c, Complimentary__c
            FROM OpportunityLineItem
            WHERE OpportunityId =: opp.Id
        ];

        opp.StageName = 'Closed Won';
        update opp;

        Test.startTest();

        IncorrectCSS_Alert_Batch Icss = new IncorrectCSS_Alert_Batch();
        Database.executeBatch(Icss);
        Test.stopTest();
    }
}
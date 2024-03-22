@isTest
public class BatchToUpdateOLIProdCategory_test {

    @testSetup
    public static void DataSetup(){
         Pricebook2 pricebookPGSG = new Pricebook2();
		pricebookPGSG.Name = 'PG SG';
		pricebookPGSG.IsActive = true;
		pricebookPGSG.CurrencyIsoCode = 'SGD';
		insert pricebookPGSG;
        Account acc = TestDataSetupBasic.createAccount();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
		insert acc;
        Contact con = TestDataSetupBasic.createContact(acc);
		insert con;

        	Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
		opp.Pricebook2Id = pricebookPGSG.Id;
		insert opp;
     
        	Product2 product2Awards = new Product2();
			product2Awards.Name = 'product2Name';
			product2Awards.CurrencyIsoCode = 'SGD';
			//product2sToInsert.add(product2Awards);
		
		insert product2Awards;
   
     cspmb__Price_Item__c priceItem = new cspmb__Price_Item__c ();
		priceItem.Name = 'Price Item test';
		//priceItem.Tax_Code__c = taxCode.Id;
		priceItem.Product_Category__c = 'Awards';
        //priceItem.Pr
		insert priceItem;

		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Name = 'Booking Time Zone test';
		insert bookingTimeZone;

		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = '236';
		insert businessUnit;

        		csmso__Product_Node__c productNode = new csmso__Product_Node__c();
		productNode.Name = 'Product Node';
		productNode.Unique_Id__c = '6567';
		productNode.csmso__Root_Node__c = true;
		productNode.csmso__Description__c = 'Test';
		productNode.NAA_supported_currency__c = 'THB';
		productNode.Served_By__c = 'Database Marketing';
		productNode.csmso__Media_Types__c = 'Classified';
		productNode.csmso__Business_Unit__c = businessUnit.Id;
		productNode.Sponsorship_Booking_Timezone__c = bookingTimeZone.Id;
		insert productNode;

		csmso__Rate_Card__c rateCard = new csmso__Rate_Card__c();
		rateCard.Type__c = 'Base';
		rateCard.Unique_Id__c = '654';
		rateCard.Order_Type__c = 'Reseller';
		rateCard.Short_Description__c = 'Test';
		rateCard.csmso__From_Date__c = System.today();
		rateCard.csmso__To_Date__c = System.today() + 3;
		rateCard.csmso__Product_Node__c = productNode.Id;
		insert rateCard;

		csmso__Node_Advert_Assignment__c nodeAdvertAssignment = new csmso__Node_Advert_Assignment__c();
		nodeAdvertAssignment.Name = 'Node Advert Assignment';
		nodeAdvertAssignment.Unique_Id__c = '75';
		nodeAdvertAssignment.Rate_Type__c = 'CPM';
		nodeAdvertAssignment.Rate_Type_Display__c = 'CPCV';
		nodeAdvertAssignment.Product_Name__c = 'Product';
		nodeAdvertAssignment.Product_Family__c = 'Audio';
		nodeAdvertAssignment.Served_by__c = 'Megaphone';
		nodeAdvertAssignment.Product_Group__c = 'Audio';
		nodeAdvertAssignment.Line_Item_Type__c = 'Podcast';
		nodeAdvertAssignment.Line_Item_Category__c = 'Other';
		nodeAdvertAssignment.Ad_Location_Description__c = 'Mobile';
		insert nodeAdvertAssignment;

		csmso__Rate_Card_Item_Price__c rateCardItemPrice = new csmso__Rate_Card_Item_Price__c();
		rateCardItemPrice.csmso__Rate_Card__c = rateCard.Id;
		rateCardItemPrice.csmso__Product_Node__c = productNode.Id;
		rateCardItemPrice.csmso__Advert_Assignment__c = nodeAdvertAssignment.Id;
		rateCardItemPrice.Unique_Id__c = '76';
		rateCardItemPrice.Account_Tier__c = 'Tier 1';
		rateCardItemPrice.csmso__Price_Per_Unit__c = 34;
        	Id stdPriceBook = Test.getStandardPricebookId();
       PricebookEntry pricebookEntryStandard = new PricebookEntry();
			pricebookEntryStandard.UnitPrice = 20;
			pricebookEntryStandard.IsActive = true;
			pricebookEntryStandard.CurrencyIsoCode = 'SGD';
			pricebookEntryStandard.Product2Id = product2Awards.Id;
			pricebookEntryStandard.Pricebook2Id = stdPriceBook;
			insert pricebookEntryStandard;

			PricebookEntry pricebookEntryPGSG = new PricebookEntry();
			pricebookEntryPGSG.UnitPrice = 40;
			pricebookEntryPGSG.IsActive = true;
			pricebookEntryPGSG.CurrencyIsoCode = 'SGD';
			pricebookEntryPGSG.Product2Id = product2Awards.Id;
			pricebookEntryPGSG.Pricebook2Id = pricebookPGSG.Id;
			insert pricebookEntryPGSG;
		insert rateCardItemPrice;
          OpportunityLineItem oli = new OpportunityLineItem(Product_Configuration__c='wertyui'+'',pricebookentryid=pricebookEntryPGSG.id,product2id=product2Awards.id,Opportunityid=Opp.id,commercial_product__c=priceItem.id+'');
        insert oli;
        OpportunityLineItem oli1 = new OpportunityLineItem(Product_Configuration__c='wertyui'+'',pricebookentryid=pricebookEntryPGSG.id,product2id=product2Awards.id,Opportunityid=Opp.id,Rate_card__c=rateCardItemPrice.id+'');
         insert oli1;
    }
    @isTest
    public static void test1(){
        Database.executeBatch(new BatchToUpdateOLIProdCategory());
    }
}
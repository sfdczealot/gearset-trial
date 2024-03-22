@isTest
public class BatchUpsertOffersToMasterTable_Test {
    
    @isTest
    static void unitTest(){
        
        List<cscfga__Configuration_Offer__c> offers = new List<cscfga__Configuration_Offer__c>();
        
        csmso__Business_Unit__c bu = new csmso__Business_Unit__c();
        bu.Name = 'Test BU';
        bu.csmso__Sales_Ledger_Code__c = '001';
        Insert bu;
        
        Booking_Time_Zone__c btz = new Booking_Time_Zone__c();
        btz.Name = 'Asia/Singapore';
        Insert btz;
        
        csmso__Product_Node__c pn = new csmso__Product_Node__c();
        pn.Name = 'Test product';
        pn.csmso__Description__c = 'CommercialGuru Market News';
        pn.Unique_Id__c = 'CGSG - Market News';
        pn.csmso__Business_Unit__c = bu.Id;
        pn.Sponsorship_Booking_Timezone__c = btz.Id;
        pn.NAA_supported_currency__c = 'SGD;THB;MYR';
        pn.csmso__Media_Types__c = 'Digital;Insert;Classified;Print';
        Insert pn;
        
        csmso__Rate_Card__c rateCard = new csmso__Rate_Card__c();
        rateCard.Short_Description__c = 'SG Rate Card';
        rateCard.Type__c = 'Base';
        rateCard.Order_Type__c = 'Direct Commercial';
        rateCard.csmso__From_Date__c = System.today();
        rateCard.csmso__To_Date__c = System.today().addDays(365);
        rateCard.Unique_Id__c = 'SG_BASE_2020';
        rateCard.csmso__Product_Node__c = pn.Id;
        rateCard.CurrencyIsoCode = 'SGD';
        Insert rateCard;
        
        cscfga__Date_Range__c dr = new cscfga__Date_Range__c();
        dr.cscfga__Start__c = System.today();
        dr.cscfga__End__c = System.today().addDays(365);
        Insert dr;
        
        csmso__Node_Advert_Assignment__c naa = new csmso__Node_Advert_Assignment__c();
        naa.Name = 'Test NAA';
        naa.Product_Name__c = 'Test prod';
        naa.Bundle_Only__c = false; 
        naa.Ad_Location_Description__c = 'Desktop';
        naa.Line_Item_Category__c= 'Sponsorship	';
        naa.Product_Family__c = 'Display';
        naa.Product_Group__c = 'Leaderboard';
        naa.Line_Item_Type__c = 'Network';
        naa.Rate_Type__c = 'CPM';
        naa.Priority__c = '11';
        naa.Rate_Type_Display__c = 'CPM';
        naa.Served_by__c = 'DFP';
        naa.Unique_Id__c = 'DDprop ROS MPU 01';
        insert naa;
        
        Tax_Code__c taxCode = new Tax_Code__c();
        taxCode.Name = 'AJP';
        taxCode.Tax_Rate__c = 6.6;
        taxCode.Country__c = 'Malaysia';
        taxCode.Active__c = true;
        taxCode.Description__c = 'Test Description';
        taxCode.NS_Tax_Internal_ID__c = '4904';
        Insert taxCode;
        
        csmso__Rate_Card_Item_Price__c rcItemprice = new csmso__Rate_Card_Item_Price__c();
        rcItemprice.csmso__Price_Per_Unit__c = 101;
        rcItemprice.Income_Account__c = '1374';
        //rcItemprice.Deferred_Revenue_Account__c = '1427';
        rcItemprice.Tax_Code__c = taxCode.Id;
        rcItemprice.Product_Category__c = 'Developer Listings';
        rcItemprice.Product_Class__c = 'Developer Listings : Listings';
        rcItemprice.Product_Subclass__c = '773';
        rcItemprice.csmso__Rate_Card__c = rateCard.Id;
        rcItemprice.CurrencyIsoCode = rateCard.CurrencyIsoCode;
        rcItemprice.csmso__Advert_Assignment__c = naa.Id;
        rcItemprice.csmso__Product_Node__c = pn.Id;
        rcItemprice.Unique_Id__c = 'test NAA rate crd item';
        Insert rcItemprice;
        
        cscfga__Configuration_Offer__c offer1 = new cscfga__Configuration_Offer__c();
        offer1.Name = 'Test offer';
        offer1.cscfga__Description__c = 'Test Description';
        offer1.Product_Node__c = pn.Id;
        offer1.Order_Type__c = 'Direct Commercial';
        offer1.Rate_Card__c = rateCard.Id;
        offer1.Account_Tier__c = 'Tier 1';
        offer1.cscfga__Active__c = true;
        offer1.cscfga__Date_Range__c = dr.Id;
        offers.add(offer1);
        
        Insert offers;
        
        cspmb__Price_Item__c comProd = new cspmb__Price_Item__c();
        comprod.Name = 'Test prod';
        comprod.cspmb__Is_Active__c = true;
        comprod.Bundle_Only__c = false;
        comprod.SKU__c = 'CGhjhgGHFDGFD';
        comprod.Income_Account__c = '1374';
        //comprod.Deferred_Revenue_Account__c = '1427';
        comprod.Tax_Code__c = taxCode.Id;
        comprod.Product_Category__c = 'Developer Listings';
        comprod.Product_Class__c = 'Developer Listings : Listings';
        comprod.Product_Subclass__c = '773';
        comprod.cspmb__Effective_Start_Date__c = System.today();
        comprod.cspmb__Effective_End_Date__c = System.today().adddays(10);
        comprod.cspmb__One_Off_Charge__c = 500.05;
        insert comprod;        
        
        List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c();
        pc1.Name = 'Test Prod';
        pc1.cscfga__Quantity__c = 5;
        pc1.cscfga__Configuration_Offer__c = offer1.Id;
        pcList.add(pc1);
        
        cscfga__Product_Configuration__c pc2 = new cscfga__Product_Configuration__c();
        pc2.Name = 'Test Prod';
        pc2.cscfga__Quantity__c = 5;
        pc2.cscfga__Configuration_Offer__c = offer1.Id;
        pc2.Digital_Product__c = naa.Id;
        pcList.add(pc2);
        
        Insert pcList;
        
        cscfga__Attribute__c att = new cscfga__Attribute__c();
        att.Name = 'Commercial Product';
        att.cscfga__Is_Line_Item__c = true;
        att.cscfga__Line_Item_Description__c = 'Test description';
        att.cscfga__List_Price__c = 500.5;
        att.cscfga__Value__c = comprod.Id;
        att.cscfga__Product_Configuration__c = pc1.Id;
        Insert att;
        
        List<Product_Master_Table__c> pmList = new List<Product_Master_Table__c>();
        
        Product_Master_Table__c pm1 = new Product_Master_Table__c();
        pm1.Actual_Record_Id__c = comprod.Id;
        pmList.add(pm1);
        
        Product_Master_Table__c pm2 = new Product_Master_Table__c();
        pm2.Actual_Record_Id__c = naa.Id;
        pmList.add(pm2);
        Insert pmList;
        
        Test.startTest();
        BatchUpsertOffersToMasterTable objBatch = new BatchUpsertOffersToMasterTable();
        Database.executeBatch(objBatch);
        objBatch.execute(null, offers);
        Test.stopTest();
    }
}
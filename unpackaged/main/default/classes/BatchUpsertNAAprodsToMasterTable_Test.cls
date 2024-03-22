@isTest
public class BatchUpsertNAAprodsToMasterTable_Test {
    public static testmethod void unitTest(){
        
        List<csmso__Node_Advert_Assignment__c> naaProdsList = new List<csmso__Node_Advert_Assignment__c>();
        
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
        naaProdsList.add(naa);
        insert naaProdsList;
        
        Tax_Code__c taxCode = new Tax_Code__c();
        taxCode.Name = 'AJP';
        taxCode.Tax_Rate__c = 6.6;
        taxCode.Country__c = 'Malaysia';
        taxCode.Active__c = true;
        taxCode.Description__c = 'Test Description';
        taxCode.NS_Tax_Internal_ID__c = '4904';
        Insert taxCode;
        
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
        
        Test.startTest();
        BatchUpsertNAAprodsToMasterTable objBatch = new BatchUpsertNAAprodsToMasterTable();
        Database.executeBatch(objBatch);
        objBatch.execute(null, naaProdsList);
        Test.stopTest();
        
    }
}
@isTest(seeAllData=false)
private class CS_BatchUpdateBillingSchedulesTest {
    

    @isTest static void testUpdateBillingSchedules() {
        
       insert new CSSX__No_Triggers__c(cssx__Flag__c = true, setupownerid = Userinfo.getOrganizationId());
       CS_utl_User.disableAllTriggers(Userinfo.getOrganizationId());
       CS_th_Worker.create();
        
       //Account Creation.    
       List<Account> Acc = TestDataSetupSO.createAccounts(1);
       //insert Acc;
       
       //Contact Creation.
       List<Contact> con = TestDataSetupSO.createContacts(1,Acc);
       //insert con;
       
       //Opportunity Creation.
       List<Opportunity> opp = TestDataSetupSO.createOpportunities(1,Acc,con);
       //insert opp;
       
       //SalesOrder Creation.
       List<csmso__Sales_Order__c> salesOrders = TestDataSetupSO.createSalesOrders(1,Acc,opp);
       //insert salesorder;
       
       //Product Definition Creation.
       List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);
       
       //Attribute definition Creation.
       List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1,prodDef);
        
       //Product Baskets  Creation.
       List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1,salesorders);
       
       //Product Configs creation.
       List<cscfga__Product_Configuration__c> ProdConfigs = TestDataSetupSO.createProdConfigs(1,prodBaskets,prodDef);
       
       //Fulfilment Creation.
       
       List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,salesorders,Acc);
       Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
       Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();
       
       for(cscfga__product_Configuration__c pConfig: ProdConfigs){
           if(salesOrders.size()>0)
               pConfig.Sales_Order__c = salesOrders[0].id;
               pConfig.Billing_Schedule_Rule__c = bScheduleRule.id;
               pConfig.Revenue_Schedule_Rule__c = rScheduleRule.id;
               pConfig.Requires_Rescheduling__c= true;
               pConfig.cscfga__Configuration_Status__c ='Valid';
       }
       update ProdConfigs;
       List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,ProdConfigs);
      //system.assertequals(fulfilmentItem,null);
       //List<Billing_Schedule__c> bSchedules = testDataSetupBilling.createBillingSchedules(3,salesOrders,fulfilmentItem,prodConfigs);
       //List<Revenue_Recognition_Schedule__c> rSchedules = testDataSetupBilling.createRevenueSchedules(3,salesOrders,fulfilmentItem,prodConfigs);
      
      /*
       for(Billing_Schedule__c bs : bSchedules){
          bs.status__c='Open';
          //COMMENTED TO CHANGE BILLING QUANTITY TO FORMULA
          //BEGIN
         // bs.billing_quantity__c=10;
         //END
       }

      
       for(Billing_Schedule__c bs : bSchedules){
          bs.status__c='Pending Closure';
          bs.Exported_to_Integration__c = true;
          bs.total_billed__c=0;
          break;
       }
       */
      /*
       for(Revenue_Recognition_Schedule__c rs : rSchedules){
          rs.status__c='Open';
          //rs.Rev_Rec_Quantity__c=10;
       }
      
      for(Revenue_Recognition_Schedule__c rs : rSchedules){
          rs.status__c='Pending Closure';
          rs.Exported_to_Integration__c = true;
          rs.total_recognised__c=0;
          
          break;
      }
      */
      
      //update bSchedules;
      //update rSchedules;
       
       // NEW METHOD TO MAKE Property Maps and Custom Settings - CS
       MakePropertyMaps();
       /*
       bSchedules = [SELECT 
                                Id, Product_Configuration__c, Product_Configuration__r.id, Requires_Recalculation__c, 
                                Status__c, Exported_to_Integration__c, Total_Billed_To_Date__c 
                            FROM 
                                Billing_Schedule__c];
      */

      /*
        rSchedules = [SELECT 
                                Id, Product_Configuration__c, Product_Configuration__r.id, Requires_Recalculation__c, 
                                Status__c, Exported_to_Integration__c, Total_Recognised_To_Date__c
                            FROM 
                                Revenue_Recognition_Schedule__c];
    */

       Test.startTest();

       CS_BatchUpdateBillingSchedules batch = new CS_BatchUpdateBillingSchedules();
       batch.salesOrderScheduleBatches = new List<Sales_Order_Schedule_Batch__mdt>();
       batch.doWork(salesOrders);
       batch.onFinish();
       
       Test.stopTest();
       
       //system.assert(DoIHaveSchedules());
    }


    
    /// NEW FROM CPS - TEST PROPERTY MAPS
    private static void MakePropertyMaps()
    {


         Property_Map__c newMap1 = new Property_Map__c();
             newMap1.Attribute_Mapping_Direction__c = '';
             newMap1.Unique_Name__c = 'hdr';
         insert newMap1;

         Property_Map__c newMap2 = new Property_Map__c();
             newMap2.Attribute_Mapping_Direction__c = '';
             newmap2.Unique_Name__c = 'line';
         insert newMap2;

        
         /*
        cscfga__Object_Mapping__c OM1 = new cscfga__Object_Mapping__c(Name = 'SO To BS',
                                                        cscfga__From_Type__c = 'csmso__Sales_Order__c',
                                                        cscfga__To_Type__c = 'Billing_Schedule__c',
                                                        Property_map__c = newMap1.Id);
        insert OM1;


          
        cscfga__Field_Mapping__c FM1 = new cscfga__Field_Mapping__c(Name = 'OwnderId',
                                                        cscfga__Object_Mapping__c = OM1.id,
                                                        cscfga__From_Field__c = 'OwnerId',
                                                        cscfga__To_Field__c = 'OwnerId');
        insert FM1;  
        
        cscfga__Object_Mapping__c OM2 = new cscfga__Object_Mapping__c(Name = 'SO To RS',
                                                        cscfga__From_Type__c = 'csmso__Sales_Order__c',
                                                        cscfga__To_Type__c = 'Revenue_Recognition_Schedule__c',
                                                        Property_map__c = newMap1.Id);


        insert OM2;


         cscfga__Field_Mapping__c FM2 = new cscfga__Field_Mapping__c(Name = 'OwnderId',
                                                        cscfga__Object_Mapping__c = OM2.id,
                                                        cscfga__From_Field__c = 'OwnerId',
                                                        cscfga__To_Field__c = 'OwnerId');
        insert FM2; 
    

        cscfga__Object_Mapping__c OM3 = new cscfga__Object_Mapping__c(Name = 'Config To RS',
                                                        cscfga__From_Type__c = 'cscfga__Product_Configuration__c',
                                                        cscfga__To_Type__c = 'Revenue_Recognition_Schedule__c',
                                                        Property_map__c = newMap2.Id);
        insert OM3;


           cscfga__Field_Mapping__c FM3 = new cscfga__Field_Mapping__c(Name = 'OwnderId',
                                                        cscfga__Object_Mapping__c = OM3.id,
                                                        cscfga__From_Field__c = 'OwnerId',
                                                        cscfga__To_Field__c = 'OwnerId');
        insert FM3; 
    

        
            cscfga__Object_Mapping__c OM4 = new cscfga__Object_Mapping__c(Name = 'Config To BS',
                                                        cscfga__From_Type__c = 'cscfga__Product_Configuration__c',
                                                        cscfga__To_Type__c = 'Billing_Schedule__c',
                                                        Property_map__c = newMap2.Id);
        insert OM4;

         cscfga__Field_Mapping__c FM4 = new cscfga__Field_Mapping__c(Name = 'OwnderId',
                                                        cscfga__Object_Mapping__c = OM4.id,
                                                        cscfga__From_Field__c = 'OwnerId',
                                                        cscfga__To_Field__c = 'OwnerId');
        insert FM4; 
        */


        CS_Custom_Settings__c cs = new CS_Custom_Settings__c();
        cs.SO_Billing_Rev_Schedule_Property_Map__c = 'hdr';
        cs.SOLI_Billing_Rev_Schedule_Property_Map__c = 'line';

        insert cs;

    }

    /*
    /// NEW CPS - Method just to show we at least have some schedules created
    /// This needs to be extended to be more rigorous.
    private static boolean DoIHaveSchedules()
    {
        Billing_Schedule__c[] bcs = [select Id from Billing_Schedule__c];
        Revenue_Recognition_Schedule__c[] rs = [select Id from Revenue_Recognition_Schedule__c];

        return ( rs.Size() > 0);


    }
    */
}
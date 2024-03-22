public class testDataSetupBilling  {
    
    /*method to create a test Fulfilment*/
    public static List<csdf__Fulfilment__c> createFulfilment(Integer count,List<csmso__Sales_Order__c> so, List<Account> Acc){   
        
         List<csdf__Fulfilment__c> testFulfilments = new List<csdf__Fulfilment__c>();
        for(Integer i = 0; i < count; i++){
            csdf__Fulfilment__c testFulfilment = new csdf__Fulfilment__c();
            testFulfilment.Sales_Order__c = so[i].id;
            testFulfilment.csdf__Advertiser__c = Acc[i].id;
            testFulfilment.csdf__Name__c = Acc[i].id;
            
            testFulfilments.add(testFulfilment);
        }
        if(!testFulfilments.isEmpty()){
            insert testFulfilments;
        }
        
        return testFulfilments;        
    }
    
     /*method to create a test Fulfilment*/
    public static List<csdf__Fulfilment_Item__c> createFulfilmentItem(Integer count, List<csdf__Fulfilment__c> testFulfilments,List<cscfga__Product_Configuration__c> pconfigs){   
        
        List<csdf__Fulfilment_Item__c> testFulfilmentItems = new List<csdf__Fulfilment_Item__c>();   
        for(Integer i = 0; i < count; i++){
            csdf__Fulfilment_Item__c testFulfilmentItem = new csdf__Fulfilment_Item__c();
            testFulfilmentItem.csdf__Fulfilment__c = testFulfilments[i].id;
            testFulfilmentItem.product_configuration__c = pconfigs[i].id;
            //testFulfilmentItem.Sales_Order__c =  testFulfilments[i].sales_order__c;
            testFulfilmentItem.csdf__Flight_Beginning__c = DateTime.valueof(System.now()-30);
            testFulfilmentItem.csdf__Flight_End__c = DateTime.valueof(System.now()+30);
            testFulfilmentItem.csdf__Name__c = testFulfilments[i].id;
            testFulfilmentItem.Insertion_Quantity__c = 1600;
            testFulfilmentItem.csdf__Quantity__c = 1600;
            testFulfilmentItems.add(testFulfilmentItem);
        }
        if(!testFulfilmentItems.isEmpty()){
            insert testFulfilmentItems;
        }
     
        return testFulfilmentItems;        
    }
 
    /* public static List<Billing_Rule_Class__c> createBillingRuleClass(){
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Digital_Rule').getRecordTypeId();
        List<Billing_Rule_Class__c> bClasses = new List<Billing_Rule_Class__c>();
        
        Billing_Rule_Class__c bClass = new Billing_Rule_Class__c();
        bClass.recordTypeId = RecordTypeIdContact;
        bClass.name ='Bill monthly Pro Rata';
        bClass.Rule_Type__c ='Digital Date Strategy';
        bClass.Apex_class_Name__c ='BillingDateStrategyRules.MonthlyProRataDateBillingPeriodStrategy';
        bclasses.add(bClass);    
        
        Billing_Rule_Class__c bClass1 = new Billing_Rule_Class__c();
        bClass1.recordTypeId = RecordTypeIdContact;
        bClass1.name ='Default Digital Billing Rule';
        bClass1.Rule_Type__c ='Digital Calculation Rule';
        bClass1.Apex_class_Name__c ='BillingDigitalRules.DefaultDigitalBillingRule';
        bclasses.add(bClass1);    
        
        insert bclasses;
        return bClasses;
    }*/
    
    public static Billing_Schedule_Rule__c createBillingScheduleRule(){
        
        Billing_Rule_Class__c bClass = new Billing_Rule_Class__c();
        RecordType RecordTypeIdBillingClass = [Select Id From RecordType  Where SobjectType = 'Billing_Rule_Class__c' and DeveloperName = 'Digital_Rule'];
        
        bClass.recordTypeId = RecordTypeIdBillingClass.id;
        bClass.name ='Bill monthly Pro Rata';
        bClass.Rule_Type__c ='Digital Date Strategy';
        bClass.Apex_class_Name__c ='CS_DefaultScheduleRule';
        insert bClass;   
        
        Billing_Rule_Class__c bClass1 = new Billing_Rule_Class__c();
        bClass1.recordTypeId = RecordTypeIdBillingClass.id;
        bClass1.name ='Default Digital Billing Rule';
        bClass1.Rule_Type__c ='Digital Calculation Rule';
        bClass1.Apex_class_Name__c ='CS_DefaultScheduleRule';
        insert bClass1;

        Billing_Rule_Class__c bClass2 = new Billing_Rule_Class__c();
        bClass2.recordTypeId = RecordTypeIdBillingClass.id;
        bClass2.name ='Default Digital Date Strategy';
        bClass2.Rule_Type__c ='Digital Date Strategy';
        bClass2.Apex_class_Name__c ='CS_StandardDateStrategy';
        insert bClass2;
        
        Billing_Schedule_Rule__c bScheduleRule = new Billing_Schedule_Rule__c();
        RecordType RecordTypeIdBillingScheduleRule = [Select Id From RecordType  Where SobjectType = 'Billing_Schedule_Rule__c' and DeveloperName = 'Digital_Billing_Rule'];
        
        bScheduleRule.recordTypeId = RecordTypeIdBillingScheduleRule.id ;
        bScheduleRule.Name = 'Monthly Pro-Rata Capped Cumulative';
        bScheduleRule.Digital_Billing_Calculation_Rule__c = bClass1.id;
        bScheduleRule.Digital_Billing_Date_Strategy__c = bClass2.id;
        insert bScheduleRule;
       
        return bScheduleRule;
    }
    
    
    public static Billing_Schedule_Rule__c createRevenueScheduleRule(){
        
        Billing_Rule_Class__c bClass = new Billing_Rule_Class__c();
        RecordType RecordTypeIdBillingClass = [Select Id From RecordType  Where SobjectType = 'Billing_Rule_Class__c' and DeveloperName = 'Digital_Rule'];
        
        bClass.recordTypeId = RecordTypeIdBillingClass.id;
        bClass.name ='Bill monthly Pro Rata';
        bClass.Rule_Type__c ='Digital Date Strategy';
        bClass.Apex_class_Name__c ='CS_StandardDateStrategy';
        insert bClass;   
        
        Billing_Rule_Class__c bClass1 = new Billing_Rule_Class__c();
        bClass1.recordTypeId = RecordTypeIdBillingClass.id;
        bClass1.name ='Default Digital Billing Rule';
        bClass1.Rule_Type__c ='Digital Calculation Rule';
        bClass1.Apex_class_Name__c ='CS_DefaultScheduleRule';
        insert bClass1;
        
        Billing_Schedule_Rule__c bScheduleRule = new Billing_Schedule_Rule__c();
        RecordType RecordTypeIdBillingScheduleRule = [Select Id From RecordType  Where SobjectType = 'Billing_Schedule_Rule__c' and DeveloperName = 'Revenue_Recognition_Rule'];
        
        bScheduleRule.recordTypeId = RecordTypeIdBillingScheduleRule.id ;
        bScheduleRule.Name = 'Monthly Pro-Rata Capped Cumulative';
        bScheduleRule.Digital_Billing_Date_Strategy__c = bClass.id;
        bScheduleRule.Digital_Billing_Calculation_Rule__c = bClass1.id;
        
        
        
        insert bScheduleRule;
        return bScheduleRule;
    }
    
        public static Billing_Schedule_Rule__c createBroadcastScheduleRule(){
        
        Billing_Rule_Class__c bClass = new Billing_Rule_Class__c();
        RecordType RecordTypeIdBillingClass = [Select Id From RecordType  Where SobjectType = 'Billing_Rule_Class__c' and DeveloperName = 'Digital_Rule'];
        
        bClass.recordTypeId = RecordTypeIdBillingClass.id;
        bClass.name ='Bill monthly Pro Rata - Broadcast Calendar';
        bClass.Rule_Type__c ='Digital Date Strategy';
        bClass.Apex_class_Name__c ='BillingDateStrategyRules.BroadCastMonthlyProRataDateBillingPeriodStrategy';
        insert bClass;   
        
        Billing_Rule_Class__c bClass1 = new Billing_Rule_Class__c();
        bClass1.recordTypeId = RecordTypeIdBillingClass.id;
        bClass1.name ='Default Digital Billing Rule';
        bClass1.Rule_Type__c ='Digital Calculation Rule';
        bClass1.Apex_class_Name__c ='BillingDigitalRules.DefaultDigitalBillingRule';
        insert bClass1;
        
        Billing_Schedule_Rule__c bScheduleRule = new Billing_Schedule_Rule__c();
        RecordType RecordTypeIdBillingScheduleRule = [Select Id From RecordType  Where SobjectType = 'Billing_Schedule_Rule__c' and DeveloperName = 'Digital_Billing_Rule'];
        
        bScheduleRule.recordTypeId = RecordTypeIdBillingScheduleRule.id ;
        bScheduleRule.Name = 'Monthly Pro Rata based on Broadcast Calendar';
        bScheduleRule.Digital_Billing_Date_Strategy__c = bClass.id;
        bScheduleRule.Digital_Billing_Calculation_Rule__c = bClass1.id;
        
        
        
        insert bScheduleRule;
        
        Broadcast_Calendar__c bc = new Broadcast_Calendar__c();
        bc.Start_Date__c =Date.valueOf(system.now()-30);
        bc.End_Date__c =Date.valueOf(system.now()+30);
        
        insert bc;
        
        return bScheduleRule;
    }
    
    /*
    public static List<Billing_Schedule__c> createBillingSchedules(Integer count, List<csmso__Sales_Order__c> sO,List<csdf__Fulfilment_Item__c> fI,List<cscfga__Product_Configuration__c> pC){
        List<Billing_Schedule__c> bSchedules = new List<Billing_Schedule__c>();
        
        for(Integer i =0; i<count;i++){
            Billing_Schedule__c bschedule = new Billing_Schedule__c();
            for(csmso__Sales_Order__c sorder: so)
                bSchedule.sales_order__c = sorder.id;
            for(csdf__Fulfilment_Item__c fItem: fI)
                bSchedule.Fulfilment_Item__c = fItem.id;
            for(cscfga__Product_Configuration__c pConfig: pC)
                bSchedule.product_configuration__c = pConfig.id;
            bSchedule.status__c='Locked';
            bSchedule.Scheduled_Quantity__c = 100;
            bSchedule.billing_Amount__c =1.0;
            bSchedule.Billing_Period_Start_Date__c = Date.valueOf(system.now()+i);
            bSchedule.Billing_Period_End_Date__c = Date.valueOf(system.now()+i+1);
            bSchedules.add(bSchedule);
                
        }
        
        for(Integer i =0; i<count;i++){
            Billing_Schedule__c bschedule = new Billing_Schedule__c();
            for(csmso__Sales_Order__c sorder: so)
                bSchedule.sales_order__c = sorder.id;
            for(csdf__Fulfilment_Item__c fItem: fI)
                bSchedule.Fulfilment_Item__c = fItem.id;
            for(cscfga__Product_Configuration__c pConfig: pC)
                bSchedule.product_configuration__c = pConfig.id;
            bSchedule.status__c='Open';
            bSchedule.Scheduled_Quantity__c =100;
            bSchedule.billing_Amount__c =1.0;
            
            bSchedules.add(bSchedule);
                
        }
        
        
                
        insert bSchedules;
        
        
        return bSchedules;
    }
    */
    
    /*
    public static List<Revenue_Recognition_Schedule__c> createRevenueSchedules(Integer count, List<csmso__Sales_Order__c> sO,List<csdf__Fulfilment_Item__c> fI,List<cscfga__Product_Configuration__c> pC){
        List<Revenue_Recognition_Schedule__c> rschedules = new List<Revenue_Recognition_Schedule__c>();
        
        for(Integer i =0; i<count;i++){
            Revenue_Recognition_Schedule__c rschedule = new Revenue_Recognition_Schedule__c();
            for(csmso__Sales_Order__c sorder: so)
                rschedule.sales_order__c = sorder.id;
            for(csdf__Fulfilment_Item__c fItem: fI)
                rschedule.Fulfilment_Item__c = fItem.id;
            for(cscfga__Product_Configuration__c pConfig: pC)
                rschedule.product_configuration__c = pConfig.id;
            rschedule.status__c='Locked';
            rschedule.Scheduled_Quantity__c = 100;
            rschedule.rev_rec_amount__c=1.0;
            rschedules.add(rschedule);
                
        }
        
        
        for(Integer i =0; i<count;i++){
            Revenue_Recognition_Schedule__c rschedule = new Revenue_Recognition_Schedule__c();
            for(csmso__Sales_Order__c sorder: so)
                rschedule.sales_order__c = sorder.id;
            for(csdf__Fulfilment_Item__c fItem: fI)
                rschedule.Fulfilment_Item__c = fItem.id;
            for(cscfga__Product_Configuration__c pConfig: pC)
                rschedule.product_configuration__c = pConfig.id;
            rschedule.status__c='Open';
            rschedule.Scheduled_Quantity__c =100;
            rschedule.rev_rec_amount__c=1.0;
            
            rschedules.add(rschedule);
                
        }
                
        insert rschedules;
        
        return rschedules;
    }
    */
}
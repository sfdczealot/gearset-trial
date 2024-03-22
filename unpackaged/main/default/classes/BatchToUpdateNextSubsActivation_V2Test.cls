@isTest
public class BatchToUpdateNextSubsActivation_V2Test {
    @isTest
    static void UpdateNextSAD(){
          PGTestDataFactory_v2.initSetupData();    
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'PGAccount';
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
        a.PersonEmail = 'test@test.com';
        a.Country__c = 'Singapore';
        a.Status__c = 'Active';
        a.Next_Subscription_Activation_Date__c=System.todAY()-9;
        a.CEA_Salesperson_Number__c = 'CEACHECK1';
        a.PersonBirthdate = system.today();
        try{
            insert a;
        }catch(Exception e){
            system.debug('### '+e.getMessage());
        }
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today();
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        //opp.Payment_Time__c = system.now();
        //opp.Agent_Accepted_Time__c = system.now();
        opp.Subsidiary__c = PGTestDataFactory.createSubsidiary().Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        insert opp;
         Product_Class__c productClass = new Product_Class__c(Name = 'Subscription', CurrencyIsoCode = 'SGD'/*, NS_Internal_ID__c ='1234567890'*/);
        insert productClass;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        List<Product2> prodList=new List<Product2>();
        for(Integer i =0 ; i<2; i++){
            Product2 prod = new Product2(Name = 'Test Prod'+i, IsActive = true,
                                         Segment__c = 'B2B Only', Product_Category__c = 'Subscription',
                                         SKU_Code__c = 'abc', Is_Bundle__c= true, CurrencyIsoCode = 'SGD',
                                        Product_class__c=productclass.id);
            prodList.add(prod);
        }
        insert ProdList;
        //     system.debug('***prod  '+ProdList);
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        for(Product2 prod: ProdList){
            PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, 
                                                    isActive=true, CurrencyIsoCode = 'SGD');
            pbeList.add(pbe);
        }
        insert pbeList;
        
        List<OpportunityLineItem> oliList=new List<OpportunityLineItem>();
        integer i=0;
        Test.startTest();
        for(Product2 prod: ProdList){
            OpportunityLineItem oplineItem = new OpportunityLineItem();
            oplineItem.OpportunityId = opp.id;
            oplineItem.Product2Id = prod.id;
            oplineItem.PricebookEntryId = pbeList[i].id;
            oplineItem.Quantity = 2;
            oplineItem.Product_Category__c	='Subscription';
            oplineItem.UnitPrice = 1200;
            opLineItem.Start_date__c = System.Today()+1;
             opLineItem.end_Date__c =system.today()+8;
            oplineItem.SNo__c = i+1;
            oplineItem.Discount_Reason__c = 'Agent Referral: Referee';
            oliList.add(opLineItem);
            i++;
           //insert oplineItem;
        }
       insert oliList;
       
         opp.Approval_Status__c='OMC Approval Approved';
        opp.OMC_Approved_Date__c=system.today();
        opp.Count_of_Subscription_Item_new__c=2;
        opp.StageName='Closed Won';
        update opp;
         list<OpportunityLineItem> o=[select id, SNO__c, Actual_Start_date__c from OpportunityLineItem where Actual_Start_date__c != null 
                                AND SNO__c != null AND Product2.Product_Category__c='Subscription' Order By SNO__c ASC];
        system.debug('**********'+o);
        
        DataBase.executeBatch(new BatchToUpdateNextSubsActivation_V2(),12);
        Test.stopTest();
    }
}
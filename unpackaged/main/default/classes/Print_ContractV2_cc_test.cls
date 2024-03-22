@istest
public class Print_ContractV2_cc_test {
    
    @testSetup
    public static void testData(){
          opportunityTriggerHandler.TriggerDisabled=true;
            Trigger_Execute__c TEOpp = new Trigger_Execute__c();
        TEOpp.Name = 'PGOpportunityTrigger';
        TEOpp.Enable_del__c = false;
        insert TEOpp;
        
        CS_utl_User.isTriggerDeactivationEnabledForAllTriggers = true;
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs (thisUser) {
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            Trigger_Execute__c TE2 = new Trigger_Execute__c();
            TE2.Name = 'Trigger_OpportunitySplit';
            TE2.Enable_del__c = false;
            insert TE2;
            Trigger_Execute__c TE = new Trigger_Execute__c();
            TE.Name = 'PGAddressTrigger';
            TE.Enable_del__c = false;
            TE.IsTrackingEnable__c = false;
            TE.Sub_Enable__c = false;
            insert TE;
            //data setup
            system.debug('DML TestDataFactory');
            Id StdpricebookId = Test.getStandardPricebookId();

            Account acc = new Account();
            acc.Name= 'Test Acc';
            acc.BillingStreet = 'test';
            acc.BillingCity = 'test';
            // a.BillingCountry = 'SG';
            acc.billingcountryCode='SG';
            acc.BillingPostalCode = '83737';
            acc.NetSuite_Id__c ='656576';
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
            acc.Phone = '2345';
            Test.startTest();
            insert acc;
            Account childAcc = TestDataSetupTargetables.createAccount();
            childAcc.name='child acc';
            childAcc.Tax_Reg_Number__c ='tyg';
            childAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
            childAcc.NetSuite_Id__c = 'CUSTOMED';
            childAcc.ParentId = acc.id;
            childAcc.Phone = '2345';
            insert childAcc;
            Contact con = new Contact();
            con.LastName = 'Test Contact';
            con.Email = 'test@gmail.com';
            con.AccountId = acc.Id;
            con.NetSuite_Id__c ='56557';
            con.MobilePhone = '654567';
            insert con;
            
            Address__c	add = new Address__c();
            add.Billing_City__c = 'city';
            add.BillingCountry__c = 'Malaysia';
            add.Billing_Postal_Code__c = '777878';
            add.Billing_State__c = 'city';
            add.Billing_Street__c = 'city';
            add.isActive__c = true;
            add.Account__c = acc.id;
            insert add;
            
            
            opportunity  b2bopp = TestDataSetupTargetables.createOpportunity(acc, con);
            b2bopp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
            b2bopp.Re_print_Contract__c = false;
            b2bopp.Product_category__c='Discretionary';
            b2bopp.billing_entity__c = childAcc.id;
            b2bopp.Subsidiary_Type__c = 'iPP';
            insert b2bopp;
            b2bopp.StageName = 'Prospecting';
            b2bopp.b2b_Billing_Contact__c = con.Id;
            b2bopp.Billing_Address__c = add.id;
            update b2bopp;
            
            
            
            Opportunity opp2 = TestDataSetupTargetables.createOpportunity(acc, con);
            opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
            opp2.stagename = 'Prospecting';
            opp2.Product_category__c='Discretionary';
            opp2.billing_entity__c = childAcc.id;
            opp2.Loss_Reason__c = 'test';
            opp2.Loss_Reason_Detail__c='test';
            opp2.b2b_Billing_Contact__c = con.Id;
            opp2.Subsidiary_Type__c = 'iPP';
            opp2.Billing_Address__c = add.id;
            //          insert opp2;
            //          opp2.stagename = 'closed lost';
            //          update opp2;
            Test.stopTest();
            list<OpportunityContactRole> ocrlist = new list<OpportunityContactRole>();
            OpportunityContactRole ocr = new OpportunityContactRole();
            ocr.opportunityId = b2bopp.id;
            ocr.ContactId = con.Id;
            ocr.IsPrimary = true;
            ocr.Role = 'Billing Contact';
            ocrlist.add(ocr);
            
            OpportunityContactRole ocr1 = new OpportunityContactRole();
            ocr1.opportunityId = b2bopp.id;
            ocr1.ContactId = con.Id;
            ocr1.Role = 'Client Signatory';
            ocrlist.add(ocr1);
            insert ocrlist;
            
            csmso__Sales_Order__c testSO = TestDatasetupSO.createSalesOrder(acc, opp2);
            testSO.SO_Start_Date__c = system.today();
            testSO.csmso__Status__c = 'Ready for Customer Approval';
            //       insert testSO;
            
            
            Payment_Term__c paymentTerm = new Payment_Term__c(name = 'test',  NS_Payment_Term_ID__c = 65);
            insert paymentTerm;
            csmso__Sales_Order__c so = new csmso__Sales_Order__c(Advertiser_Final__c = acc.id,Primary_Sales_Order__c = true,
                                                                 csmso__Opportunity__c = b2bopp.Id, Sale_type__c = 'Sales', csmso__Advertiser__c = acc.Id, Billing_Email__c = 'test@abc.com', 
                                                                 Bill_To_Account_Final__c = acc.Id, Bill_To_Account__c = acc.Id, Bill_To_Account_Filter__c = acc.Id, 
                                                                 NetSuite_Payment_Term__c = paymentTerm.Id,csmso__Status__c='Ready for Customer Approval',Customer_Approval__c = 'Approved');
            insert so;
            b2bopp.Primary_Sales_Order__c=so.id;
            update b2bopp;
            
            cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(csmso__Sales_Order__c = so.id, Name = 'test basket', cscfga__Total_Price__c = 100, Payment_Amount__c = 2, Appr_Code__c = '2', Payment_Date__c = system.today(), Payment_Reference__c = 'PayPal', Payment_Gateway__c = 'PayPal', Payment_Mode__c = 'PayPal', EcomReference__c  = 'test');
            insert basket;
            
            cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(cscfga__Product_Basket__c = basket.Id, name = 'Awards', cscfga__Quantity__c = 2, Start_Date__c = system.today(), cscfga__Unit_Price__c = 20, End_Date__c = system.today()+3, cscfga__Product_Family__c = 'Ad Served', cscfga__Parent_Configuration__c = null);
            pc1.cscfga__Description__c = 'description';
            insert pc1;
           /* cscfga__Product_Configuration__c pc3 = new cscfga__Product_Configuration__c(cscfga__Product_Basket__c = basket.Id, name = 'Awards', cscfga__Quantity__c = 2, Start_Date__c = system.today(), cscfga__Unit_Price__c = 20, End_Date__c = system.today()+3, cscfga__Product_Family__c = 'Awards', cscfga__Parent_Configuration__c = null);
            pc3.cscfga__Description__c = 'description';
            insert pc3;
            cscfga__Product_Configuration__c pc2 = new cscfga__Product_Configuration__c(cscfga__Product_Basket__c = basket.Id, name = 'child pc', cscfga__Quantity__c = 2, Start_Date__c = system.today(), cscfga__Unit_Price__c = 20, End_Date__c = system.today()+3, cscfga__Product_Family__c = 'EVENTS', cscfga__Parent_Configuration__c = pc1.Id);
            pc2.cscfga__Description__c = 'description';
            insert pc2;*/
            
            blob b1  = blob.ValueOf('{'+
                                    '"productConfigurationId":"'+pc1.id+'",'+
                                    '"attributesByAttrDefId":{'+
                                    '"a1X9D000000XHXqUAO":{'+
                                    '"attributes":{'+
                                    '    "type":"cscfga__Attribute__c"'+
                                    ' },'+
                                    ' "cscfga__Key__c":null,'+
                                    ' "cscfga__Is_Required__c":false,'+
                                    ' "cscfga__Price__c":0.0,'+
                                    ' "cscfga__Display_Value__c":"0069D0000056AP7QAM",'+
                                    ' "Name":"CSMSO Opportunity Id",'+
                                    ' "cscfga__Recurring__c":false,'+
                                    '"cscfga__Is_Line_Item__c":false,'+
                                    ' "cscfga__Is_Read_Only__c":false,'+
                                    '"cscfga__is_active__c":true,'+
                                    ' "cscfga__Attribute_Definition__c":"a1X9D000000XHXqUAO",'+
                                    ' "cscfga__Value__c":"0069D0000056AP7QAM",'+
                                    ' "cscfga__Attribute_Definition__r":null,'+
                                    ' "cscfga__List_Price__c":null,'+
                                    ' "cscfga__Line_Item_Sequence__c":null,'+
                                    '"cscfga__Product_Configuration__r":null'+
                                    '},'+
                                    '"a1X9D000000XHXsUAO":{'+
                                    ' "attributes":{'+
                                    '    "type":"cscfga__Attribute__c"'+
                                    ' },'+
                                    ' "cscfga__Key__c":null,'+
                                    ' "cscfga__Is_Required__c":false,'+
                                    ' "cscfga__Price__c":0.0,'+
                                    ' "cscfga__Display_Value__c":"2021-02-01 00:002022-01-31 23:59a2c9D000000DacmQAC01/02/202131/01/2022",'+
                                    ' "Name":"FLAG Attributes Changed OLD",'+
                                    ' "cscfga__Recurring__c":false,'+
                                    ' "cscfga__Is_Line_Item__c":false,'+
                                    ' "cscfga__Is_Read_Only__c":false,'+
                                    ' "cscfga__is_active__c":true,'+
                                    ' "cscfga__Attribute_Definition__c":"a1X9D000000XHXsUAO",'+
                                    '"cscfga__Value__c":"2021-02-01 00:002022-01-31 23:59a2c9D000000DacmQAC01/02/202131/01/2022",'+
                                    ' "cscfga__Attribute_Definition__r":null,'+
                                    ' "cscfga__List_Price__c":null,'+
                                    ' "cscfga__Line_Item_Sequence__c":null,'+
                                    ' "cscfga__Product_Configuration__r":null'+
                                    ' }'+
                                    ' }'+
                                    '}');
            
            Attachment attachment = new Attachment();
            attachment.ParentId = pc1.id;
            attachment.Name = 'Attributes as JSON';
            attachment.Body = b1;
            
            insert(attachment);
            
        }
        
    }
    @isTest
    public static void testMethod1(){
        Test.startTest();
        List<Opportunity> opp=[select id,stageName,(Select id,Account_s_Billing_Address__c,contact.Email,Attention__c,IsPrimary,Remarks__c,Role from OpportunityContactRoles where Role = 'Billing Contact'),Order_date__c,Primary_Sales_Order__r.csmso__Status__c from opportunity];
        // Test.startTest();
        try{
            opp[0].Primary_Sales_Order__c = null;
            opp[0].OpportunityContactRoles[0].Account_s_Billing_Address__c = null;
            opp[0].b2b_Billing_Contact__c = null;
            update opp[0];
            Print_ContractV2_cc.checkStatus(opp[0].id);
            
        }
        catch(AuraHandledException  e){}
        Test.stopTest();      
        
    }
    @isTest
    public static void testMethod3(){
        Test.startTest();
        List<csmso__Sales_Order__c> SO=[select id,csmso__Opportunity__c from csmso__Sales_Order__c];
        try{  
            Print_ContractV2_cc.checkStatus(SO[0].csmso__Opportunity__c);
            so[0].csmso__Status__c ='Draft';
            update so;
            Print_ContractV2_cc.checkStatus(SO[0].csmso__Opportunity__c);
        }
        catch(AuraHandledException  e){}
        Test.stopTest();         
    }
    @isTest
    public static void testMethod4(){
        Test.startTest();
        List<Opportunity> opp=[select id from opportunity where stagename='Prospecting'];
        
        try{
            
            Print_ContractV2_cc.checkStatus(opp[0].id);
        }
        catch(AuraHandledException  e){}
        Test.stopTest();      
        
    }
    @isTest
    public static void testMethod5(){
        Test.startTest();
        Account a = [Select id , Name From Account Where Name ='Test Acc'];
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGAddressTrigger';
        TE.Enable_del__c = false;
        TE.IsTrackingEnable__c = false;
        TE.Sub_Enable__c = false;
        insert TE;
        
        Address__c Addr = new Address__c();
        Addr.Name ='Test Address';
        Addr.Account__c = a.Id;
        Addr.isActive__c = true;
        Addr.Billing_City__c = 'test';
        Addr.BillingCountry__c ='Singapore';
        Addr.Billing_Postal_Code__c ='83736';
        Addr.Billing_State__c = 'state';
        Addr.Billing_Street__c ='street';
        Addr.CurrencyIsoCode ='SGD';   
        insert Addr;
        
        
        List<Opportunity> opp=[select id from opportunity ];
        
        //  opp[0].stagename = 'Prospecting';
        opp[0].Billing_Entity__c = a.Id;
        opp[0].Billing_Address__c = Addr.Id;
        //      update opp;
        
        try{
            
            Print_ContractV2_cc.checkStatus(opp[0].id);
        }
        catch(AuraHandledException  e){}
        Test.stopTest();  
        
    }
   /*  @isTest
   public static void testMethodValidation(){
        Test.startTest();
        List<Opportunity> opp=[select id from opportunity ];
        opp[0].stageName='closed lost';
        opp[0].Loss_Reason_Detail__c='test';
        opp[0].Loss_Reason__c ='No Payment';
        update opp;  
        try{
            
            Print_ContractV2_cc.checkStatus(opp[0].id);
        }
        catch(AuraHandledException  e){}
        opp[0].Billing_Address__c=null;
        update opp; 
        try{
            
            Print_ContractV2_cc.checkStatus(opp[0].id);
        }
        catch(AuraHandledException  e){}
        contact con = [select id from contact limit 1];
        echosign_dev1__SIGN_Agreement__c a = new echosign_dev1__SIGN_Agreement__c ();
        a.Name = 'Test agreement 6'+system.now();
        a.echosign_dev1__Message__c = 'ABCD';
        a.echosign_dev1__Recipient__c = con.id;
        a.echosign_dev1__SignatureOrder__c = 'Recipient signs, then I sign';
        a.echosign_dev1__SignatureType__c = 'e-Signature';
        a.echosign_dev1__Signature_Flow__c = 'Order Entered';
        a.echosign_dev1__Status__c = 'Out for Signature';
        a.echosign_dev1__SenderSigns__c = true;
        a.echosign_dev1__Recipient_Addresses__c = 'xxxxxxxxxxxxxxxxx@gmail.com,';
        a.echosign_dev1__Opportunity__c = opp[0].id;
        insert a;

 try{
            
            Print_ContractV2_cc.checkStatus(opp[0].id);
        }
        catch(AuraHandledException  e){}
        
        Test.stopTest();      
        
    }*/
    
}
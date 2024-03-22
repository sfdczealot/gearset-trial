@isTest
public class ContractControllerV2_Test { 
    private static final String FAKE_RESPONSE_JSON = '{' +
        'status:ok' +
        '}';
    @testSetup
    public static void testData(){
        CS_utl_User.isTriggerDeactivationEnabledForAllTriggers = true;
            Echosign_dev1__Agreement_Template__c adobeat = new Echosign_dev1__Agreement_Template__c();
     adobeat.Name                                   = 'Final Detailed';
     adobeat.Echosign_dev1__Auto_Send__c            = TRUE;
     adobeat.Echosign_dev1__Name__c                 = 'Adobe Sign Agreement';
     adobeat.Echosign_dev1__Signature_Type__c       = 'e-Signature';
     adobeat.Echosign_dev1__Language__c             = 'English (United States)';
     //adobeat.Echosign_dev1__Merge_Mapping__c        = adobemm.id;
     insert adobeat;
        string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGOpportunityTrigger';
        customsetting.Enable_del__c=false;
        insert customsetting;
             PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAddressTrigger',false);
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',false);
        PGTestDataFactory_v2.CreateTriggerExecuteCS('Trigger_OpportunitySplit',false);
        //  Opportunity opp = null;
        //Account acc_b2c  = null;
        Account acc_b2b  = new Account();
        // Avoid mixed DML
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        system.debug('@@@thisUser'+ thisUser);
        System.runAs (thisUser) {
            // Call method to insert test records
           // PGTestDataFactory_v2.initSetupData();
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createMYSubsidiary(thisUser);
            sb.Include_B2B_country_manager__c = true;
            sb.Payment_Clause__c = 'test';
            sb.Agreement_Clause__c = 'tets';
           // test.startTest();
            update sb;
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
           
            //Account acc = new Account();
            acc_b2b.Name = 'Acc Dunning';
            acc_b2b.Country__c = 'Malaysia';
            acc_b2b.RecordTypeId = b2baccRectype;
            
            //acc_b2c = PGTestDataFactory_v2.createB2CAccount('test@test.com','1232', thisUser, sb);
            acc_b2b.NetSuite_Id__c='123452';
            acc_b2b.BillingStreet='test';
            acc_b2b.BillingCity='test';
            acc_b2b.Billingcountry='Malaysia';
            insert acc_b2b;
            /*  acc_b2c = PGTestDataFactory_v2.createB2CAccount('test@test.com','1232', thisUser, sb);
acc_b2c.NetSuite_Id__c='1234532';
acc_b2c.BillingStreet='test1';
acc_b2c.BillingCity='test2';
acc_b2c.Country__c ='Malaysia';
acc_b2c.Status__c = 'Active';
acc_b2c.Agency_Id__c = '34567892';
acc_b2c.RecordTypeId = b2baccRectype;
update acc_b2c;*/
             Address__c add = new Address__c (Account__c  = acc_b2b.id,Billing_City__c =' Billing_City__c ',Billing_State__c=' Billing_State__c',
                                            Billing_Postal_Code__c =' 1111 ',Billing_Street__c='Billing_Street__c ',BillingCountry__c='Malaysia');
            insert add;
            contact con = PGTestDataFactory_v2.createContact('FirstName','LastName','Email@test.com');
            con.AccountId = acc_b2b.id;
            update con;
            Id personConId = con.id;
            
            //standard PB
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            //Discretionary Class
            Product_Class__c productClass = PGTestDataFactory_v2.createProductClass('Discretionary',sb);
            
            //item
            list<Product2> listProd = new list<Product2>();
            Product2 prod = PGTestDataFactory_v2.CreateProduct('Test Prod', 'B2C Only', 'Discretionary', 'abc', productClass, taxcode);
            prod.Is_Bundle__c=true;
            listProd.add(prod);
            Product2 prod2 = PGTestDataFactory_v2.CreateProduct('Test Prod2', 'B2C Only', 'Discretionary', 'abc', productClass, taxcode);
            prod2.Is_Bundle__c=true;
            listProd.add(prod2);
            insert listProd;
            
            //sg pbe
            Id StdpricebookId = Test.getStandardPricebookId();
            list<PricebookEntry> listPBE = new list<PricebookEntry>();
            PricebookEntry pbe = PGTestDataFactory_v2.CreatePBE(StdpricebookId, prod, 100.0, sb,false);
            PricebookEntry pbe2 = PGTestDataFactory_v2.CreatePBE(standardPB.Id, prod, 100.0, sb,true);
            
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Prospecting';
            opp.AccountId = acc_b2b.id;
            opp.CloseDate = system.today().AddDays(30);
            opp.Subsidiary__c = sb.id;
            opp.Total_Spending__c = 100;
            opp.RecordTypeId = b2boppRectype;
            opp.PG_Tenure__c = 1;
            opp.b2b_Billing_Contact__c=con.id;
            opp.count_of_subscription_item_new__c = 100.0;
            opp.Billing_Address__c = add.id;
            opp.Order_Date__c=system.today();
            //opp.Order_Type_Clone__c   = 'Contract - Renewal';
            // opp.Opportunity_Type__c='B2C - Renewal';
            opp.Subsidiary_Type__c = 'Property Guru';
            
            insert opp;
            
            //system.debug('opp  '+oli[0].Opportunityid);
            OpportunityContactRole ocr= PGTestDataFactory_v2.CreateOCR(opp.id,personConId,'Client Signatory');
            insert ocr;
            OpportunityContactRole ocr1= PGTestDataFactory_v2.CreateOCR(opp.id,personConId,'Campaign contact');
            ocr1.IsPrimary=true;
            //  insert ocr1;
           // test.stopTest();
           //   string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        //string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        Account acc = new Account();
        acc.name='abc def';
        
        acc.RecordTypeId = b2baccRectype;
        acc.Phone = '2345';
        insert acc;
        // Test.startTest();
      
        Payment_Term__c paymentTerm = new Payment_Term__c(name = 'test',  NS_Payment_Term_ID__c = 65);
        insert paymentTerm;
        csmso__Sales_Order__c so = new csmso__Sales_Order__c(Advertiser_Final__c = acc_b2b.id,Primary_Sales_Order__c = true,
                                                             csmso__Opportunity__c = opp.Id, Sale_type__c = 'Sales', csmso__Advertiser__c = acc_b2b.Id, Billing_Email__c = 'test@abc.com', 
                                                             Bill_To_Account_Final__c = acc_b2b.Id, Bill_To_Account__c = acc_b2b.Id, Bill_To_Account_Filter__c = acc_b2b.Id, 
                                                             NetSuite_Payment_Term__c = paymentTerm.Id, billing_schedule__c = '12 months');
        
        insert so;
        opp.Primary_Sales_Order__c = so.id;
        update opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(csmso__Sales_Order__c = so.id, Name = 'test basket', cscfga__Total_Price__c = 100, Payment_Amount__c = 2, Appr_Code__c = '2', Payment_Date__c = system.today(), Payment_Reference__c = 'PayPal', Payment_Gateway__c = 'PayPal', Payment_Mode__c = 'PayPal', EcomReference__c  = 'test');
        insert basket;
        
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(cscfga__Product_Basket__c = basket.Id, name = 'Awards', cscfga__Quantity__c = 2, Start_Date__c = system.today(), cscfga__Unit_Price__c = 20, End_Date__c = system.today()+3, cscfga__Product_Family__c = 'Ad Served', cscfga__Parent_Configuration__c = null);
        pc1.cscfga__Description__c = 'description';
        insert pc1;
        cscfga__Product_Configuration__c pc3 = new cscfga__Product_Configuration__c(cscfga__Product_Basket__c = basket.Id, name = 'Awards', cscfga__Quantity__c = 2, Start_Date__c = system.today(), cscfga__Unit_Price__c = 20, End_Date__c = system.today()+3, cscfga__Product_Family__c = 'Awards', cscfga__Parent_Configuration__c = null);
        pc3.cscfga__Description__c = 'description';
        insert pc3;
        cscfga__Product_Configuration__c pc2 = new cscfga__Product_Configuration__c(cscfga__Product_Basket__c = basket.Id, name = 'child pc', cscfga__Quantity__c = 2, Start_Date__c = system.today(), cscfga__Unit_Price__c = 20, End_Date__c = system.today()+3, cscfga__Product_Family__c = 'EVENTS', cscfga__Parent_Configuration__c = pc1.Id);
        pc2.cscfga__Description__c = 'description';
        insert pc2;
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
        blob b2  = blob.ValueOf('{'+
                                '"productConfigurationId":"'+pc2.id+'",'+
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
        Attachment attachment2 = new Attachment();
        attachment2.ParentId = pc3.id;
        attachment2.Name = 'Attributes as JSON';
        attachment2.Body = b1;
        
        insert(attachment2);
        Attachment attachment1 = new Attachment();
        attachment1.ParentId = pc2.id;
        attachment1.Name = 'Attributes as JSON';
        attachment1.Body = b2;
        
        insert(attachment1);
        
        Tax_Code__c tax = new Tax_Code__c(Name = 'test', Active__c = true, NS_Tax_Internal_ID__c = '20', Tax_Rate__c = 20);
        insert tax;
        Booking_Time_Zone__c booking = new Booking_Time_Zone__c(name = 'test booking');
        insert booking;
        
        csmso__Business_Unit__c business = new csmso__Business_Unit__c(csmso__Sales_Ledger_Code__c = '236', Name = 'business unit');
        insert business;
        csmso__Product_Node__c productNode = new csmso__Product_Node__c(name = 'node', csmso__Description__c = 'test', csmso__Business_Unit__c = business.Id, Sponsorship_Booking_Timezone__c = booking.Id, Unique_Id__c = '6567', NAA_supported_currency__c = 'THB', Served_By__c = 'Database Marketing', csmso__Root_Node__c = true, csmso__Media_Types__c = 'Classified');
        insert productNode;
        csmso__Rate_Card__c rateCard = new csmso__Rate_Card__c(Short_Description__c = 'test', csmso__From_Date__c = system.today(), csmso__To_Date__c = system.today() + 3, Unique_Id__c = '654', Type__c = 'Base', csmso__Product_Node__c = productNode.Id, Order_Type__c = 'Reseller');
        insert rateCard;
        cspmb__Price_Item__c  priceItem = new cspmb__Price_Item__c (name = 'test', Tax_Code__c = tax.Id,Product_Category__c  = 'Awards',Revenue_Recognition_Rules__c = '6',
                                                                    Rev_Rec_Forecast_Rules__c = '2',Create_Revenue_based_on__c = '-2');
        insert priceItem;
        cspmb__Price_Item__c  priceItem1 = new cspmb__Price_Item__c (name = 'test2', Tax_Code__c = tax.Id,Product_Category__c  = 'Awards',cspmb__Master_Price_item__c=priceitem.id,Amortisation_Percent__c=100,Revenue_Recognition_Rules__c = '6',
                                                                     Rev_Rec_Forecast_Rules__c = '2',Create_Revenue_based_on__c = '-2');
        
        insert priceItem1;
        
        cscfga__Attribute__c attr1 = new cscfga__Attribute__c (name = 'CommercialProduct', cscfga__Is_Line_Item__c = true, cscfga__Value__c = string.valueOf(priceItem.Id), cscfga__Price__c = 10, cscfga__List_Price__c = 20, cscfga__Product_Configuration__c = pc1.Id);
        insert attr1;
        
        
        cscfga__Attribute__c attr7 = new cscfga__Attribute__c (name = 'CommercialProduct', cscfga__Is_Line_Item__c = true, cscfga__Value__c = string.valueOf(priceItem.Id), cscfga__Price__c = 10, cscfga__List_Price__c = 20, cscfga__Product_Configuration__c = pc3.Id);
        insert attr7;
        
        cscfga__Attribute__c attr2 = new cscfga__Attribute__c (name = 'Rate Card', cscfga__Is_Line_Item__c = true, cscfga__Value__c = string.valueOf(rateCard.Id), cscfga__Price__c = 10, cscfga__List_Price__c = 20, cscfga__Product_Configuration__c = pc3.Id);
        insert attr2;
        
        cscfga__Attribute__c attr3 = new cscfga__Attribute__c (name = 'CommercialProduct', cscfga__Is_Line_Item__c = true, cscfga__Value__c = string.valueOf(priceItem.Id), cscfga__Price__c = 5, cscfga__List_Price__c = 10, cscfga__Product_Configuration__c = pc2.Id);
        insert attr3;
        cscfga__Attribute__c attr4 = new cscfga__Attribute__c (name = 'Database Marketing', cscfga__Is_Line_Item__c = true, cscfga__Value__c = string.valueOf(priceItem.Id), cscfga__Price__c = 10, cscfga__List_Price__c = 20, cscfga__Product_Configuration__c = pc1.Id);
        insert attr4;
        
        cscfga__Attribute__c attr5 = new cscfga__Attribute__c (name = 'Description', cscfga__Is_Line_Item__c = true, cscfga__Value__c = string.valueOf(rateCard.Id), cscfga__Price__c = 10, cscfga__List_Price__c = 20, cscfga__Product_Configuration__c = pc1.Id);
        insert attr5;
        
        cscfga__Attribute__c attr6 = new cscfga__Attribute__c (name = 'Rate Card Item Price', cscfga__Is_Line_Item__c = true, cscfga__Value__c = '123', cscfga__Price__c = 5, cscfga__List_Price__c = 10, cscfga__Product_Configuration__c = pc1.Id);
        insert attr6;
        }
    }
    @isTest
    public static void testMethod1(){
        test.startTest();
        opportunity opp=[select id from opportunity];
        account acc_b2b=[select id from account where name='abc def'];
        
        Test.setMock(HttpCalloutMock.class, new Mock());
        ApexPages.CurrentPage().getParameters().put('Id',opp.Id);
        ApexPages.CurrentPage().getParameters().put('SoType','DetailedDraft');
        ContractControllerV2 CC = new ContractControllerV2();
        ContractController contractcont = new ContractController();
        
        contractcont.generateContractPDF();
        CC.generateContractPDF();
        CC.updateOppRePrintFalse();
    
        ApexPages.CurrentPage().getParameters().put('Id',opp.Id);
        ApexPages.CurrentPage().getParameters().put('SoType','DetailedFinal');
        ContractControllerV2 CC1 = new ContractControllerV2(opp.Id,'DetailedFinal');
        CC1.generateContractPDF();
             Test.stopTest();
    }
    private class Mock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(FAKE_RESPONSE_JSON);
            res.setStatusCode(200);
            return res;
        }
    }
}
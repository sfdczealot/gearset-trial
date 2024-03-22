// PGTestData Factory Class
@isTest
public class PGTestDataFactory_v2 {
    
    public static Subsidiary__c createSubsidiary(User RunUser) {
        RunUser.Subsidiary__c = 'PropertyGuru Pte Ltd'; //'PropertyGuru Pte Ltd'
        update RunUser;
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd'; //PropertyGuru Pte Ltd
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        return sb;
    }
    
    public static Subsidiary__c createMYSubsidiary(User RunUser) {
        RunUser.Subsidiary__c = 'PropertyGuru International (Malaysia) Sdn Bhd';
        update RunUser;
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru International (Malaysia) Sdn Bhd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'MYR';
        sb.Subsidiary_code__c = 'ipp';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Malaysia';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        return sb;
    }

    public static Subsidiary__c createTHSubsidiary(User RunUser) {
        RunUser.Subsidiary__c = 'AllProperty Media Co., Ltd. (Head Office)';
        update RunUser;
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'AllProperty Media Co., Ltd. (Head Office)';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'THB';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Thailand';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        return sb;
    }
    
    public static Subsidiary__c createIDSubsidiary(User RunUser) {
        RunUser.Subsidiary__c = 'PT. AllProperty Media';
        update RunUser;
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PT. AllProperty Media';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'IDR';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Indonesia';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        return sb;
    }
    
    public static Account createB2CAccount(String email, String AgentnetId, User RunUser, Subsidiary__c sb){
        Account a = new Account();
        a.RecordTypeId = PGtUtils.getRecordTypeId('Agent', 'Account', null);
        a.LastName = 'PGAccount';
        a.salutation = 'Mr.';
        a.FirstName = 'abc';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
       // a.BillingCountry = 'SG';
        a.billingcountryCode='SG';
        a.BillingPostalCode = '83737';
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'STANDARD';
        a.AgentNet_ID__c = AgentnetId;
        a.PersonEmail = email;
        a.Country__c = sb.Country__c;
        a.Mobile_Country__c = '65';
        a.PersonMobilePhone ='9876543210';
         a.et4ae5__Mobile_Country_Code__pc = 'US';   
        a.Status__c = 'Active';
        if(RunUser!=null){
            a.OwnerId = RunUser.id;
        }
        a.CEA_Salesperson_Number__c = 'G1234567H';
        a.PersonBirthdate = system.today();
        a.Next_Subscription_Activation_Date__c = Date.today().addDays(-1);
        insert a;
        system.debug('@@@'+a);
        return a;
    }
    
    public static Account createAgencyAccount(String AgencyName, String CEALC, User RunUser, Subsidiary__c sb){
        Account a = new Account();
        a.RecordTypeId = PGtUtils.getRecordTypeId('Agency', 'Account', null);
        a.Name = AgencyName;
        a.CurrencyIsoCode = sb.CurrencyIsoCode;
        a.Customer_Type__c = 'Agency';
        a.CEA_License__c = CEALC;
        a.Agency_Id__c = 'Test Agency Id';
        a.Country__c = sb.Country__c;
        if(RunUser!=null){
            a.Commandos_Team_Lead__c = RunUser.id;
        }
        insert a;
        return a;
    }
    
    public static Media__c createAgencyMedia(Account acc, User RunUser){
        Media__c m = new Media__c();
        m.Account__c = acc.Id;
        m.OwnerId = RunUser.Id;
        m.isActive__c = true;
        insert m;
        return m;
    }
    
    public static ContentDocumentLink createCDL(Id id){
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        return cdl;
    }
    
    public static Account createB2CVIPAccount(String email, String AgentnetId, User RunUser, Subsidiary__c sb){
        Account a = new Account();
        a.RecordTypeId = PGtUtils.getRecordTypeId('Agent', 'Account', null);
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
        a.Account_Rule_Code__c = 'STANDARD';
        a.AgentNet_ID__c = AgentnetId;
        a.PersonEmail = email;
        a.Country__c = sb.Country__c;
        a.Status__c = 'Active';
        if(RunUser!=null){
            a.OwnerId = RunUser.id;
        }
        a.CEA_Salesperson_Number__c = '85638';
        a.PersonBirthdate = system.today();
        a.VIP__c = true;
        insert a;
        system.debug(a);
        return a;
    }
    
    public static Opportunity createB2CSubscriptionOpty(Account acc, User RunUser, Subsidiary__c sb, Pricebook2 pb, String OppType){
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today().AddDays(-30);
        opp.Subsidiary__c = sb.id;
        opp.Opportunity_Type__c = OppType;
        opp.Months_Included__c = false;
        opp.Is_Current_Subscription__c = true;
        opp.RecordTypeId = PGtUtils.getRecordTypeId('B2C', 'Opportunity', null);
        opp.Include_Subscription_Ext__c = true;
        opp.OwnerId = RunUser.Id;
        opp.Pricebook2Id = pb.Id;
        insert opp;
        return opp;
    }
    
    public static Quote createQuote(Opportunity opp, Subsidiary__c sb, Account acc, Pricebook2 StandardPB, String QuType, String Status){
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = Status;
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = sb.CurrencyIsoCode;
        qu.Quote_Type__c = QuType;
        qu.PriceBook2Id = standardPB.Id;
        qu.ContactId = [select Id,PersonContactId from Account where Id =: acc.Id].PersonContactId;
        insert qu;
        return qu;
    }
    
    public static QuoteLineItem createQuoteLineItem(Product2 prod, Quote qu, PriceBookEntry pbe2, String DiscountReason){
        QuoteLineItem oli = new QuoteLineItem();
        oli.Product2Id = prod.Id;
        oli.QuoteId = qu.Id;
        oli.Quantity =1;
        oli.PricebookEntryId = pbe2.Id;
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        if(DiscountReason != ''){ 
            oli.Discount_Reason__c = DiscountReason;
        }
        oli.UnitPrice = 2;
        insert oli;
        return oli;
    }
    
    public static contact createContact(String FirstName, String LastName, String Email){
        Contact con = new Contact();
        con.FirstName = FirstName;
        con.LastName = LastName;
        con.Email = Email;
        insert con;
        return con;
    }
    
    public static Opportunity createB2CVIPSubscriptionOpty(Account acc, User RunUser, Subsidiary__c sb, Pricebook2 pb, String OppType){
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Closed Won';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today().AddDays(-30);
        opp.Subsidiary__c = sb.id;
        opp.Opportunity_Type__c = OppType;
        opp.Months_Included__c = false;
        opp.Is_Current_Subscription__c = true;
        opp.RecordTypeId = PGtUtils.getRecordTypeId('B2C', 'Opportunity', null);
        opp.Include_Subscription_Ext__c = true;
        opp.OwnerId = RunUser.Id;
        opp.Pricebook2Id = pb.Id;
        insert opp;
        return opp;
    }
    
    public static Pricebook2 CreateStandardPricebook(Subsidiary__c sb){
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = sb.CurrencyIsoCode);
        insert standardPB;
        return standardPB;
    }
    
    public static Product_Class__c CreateProductClass(String PCName, Subsidiary__c sb){
        Product_Class__c productClass = new Product_Class__c(Name = PCName, CurrencyIsoCode = sb.CurrencyIsoCode);
        insert productClass;
        return productClass;
    }
    
    public static Product2 CreateProduct(String ProdName, String Segment, String ProductCategory, String SKU, Product_Class__c productClass, Tax_Code__c taxcode){
        Product2 prod = new Product2(Name = ProdName, IsActive = true, Segment__c = Segment, Product_Category__c = ProductCategory, SKU_Code__c = SKU, Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id);
        return prod;
    }
    
    
    public static PriceBookEntry CreatePBE(Id StdpricebookId, product2 prod, Decimal UnitPrice, Subsidiary__c sb, Boolean SP){
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true,CurrencyIsoCode = sb.CurrencyIsoCode, UseStandardPrice = SP);
        insert pbe;
        return pbe;
    }
    
    public static OpportunityLineItem CreateOppLineItem(Opportunity opp, PriceBookEntry pbe2, Product2 prod){
        OpportunityLineItem oppLine = New OpportunityLineItem();
        oppLine.OpportunityId = opp.Id;
        oppLine.PricebookEntryId = pbe2.Id;
        oppLine.Product2Id = prod.Id;
        oppLine.UnitPrice = 300;
        oppLine.Quantity = 2;
        oppLine.Start_Date__c = system.today();
        oppLine.End_Date__c = system.today();
        oppLine.Amount_Despite_VIP__c = 300;
        oppLine.Pro_Rate_Amount__c = 2;
        oppLine.unitPrice = 2;
        insert oppLine;
        return oppLine;
    }
    
    public static User createUser(String UAlias, String UEmail, String ULastName,Id ProfileId,Id RoleId){
        User userrec = new User();
        userrec.Alias = UAlias;
        userrec.Email=UEmail;
        userrec.EmailEncodingKey='UTF-8';
        userrec.LastName=ULastName;
        userrec.LanguageLocaleKey='en_US';
        userrec.LocaleSidKey='en_US';
        if(ProfileId!=null){
            userrec.ProfileId = ProfileId;
        }
        if(RoleId!=null){
            userrec.UserRoleId = RoleId;
        }
        userrec.TimeZoneSidKey='America/Los_Angeles';
        userrec.UserName=UEmail;
        insert userrec;
        return userrec;

    }
    
    public static Tax_Code__c createSGTaxCode(){
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        return taxcode;
    }
    
    public static Campaign CreateCampaign(Date Enddate){
        Campaign cpn = new Campaign();
        cpn.Name = 'Test Campaign';
        cpn.IsActive = true;
        cpn.EndDate = Enddate;
        insert cpn;
        return cpn;
    }
    public static CampaignMember CreateCampaignMember(String contactId, String campaignId){
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = contactId;
        cmp.Status = 'Sent';
        cmp.CampaignId = campaignId;
        insert cmp;
        return cmp;
    }
    public static Promo_Mechanic__c CreatePromoMechanic(String prodId, String ceId){
        Promo_Mechanic__c prm = new Promo_Mechanic__c();
        prm.Name = 'TestName';
        prm.Eligible_Product__c = prodId;
        prm.Campaign_Eligibility__c = ceId;
        prm.Usage__c = 1;
        insert prm;
        return prm;
    }
    public static Entitlement_Promotion__c CreateEntitlementPromotion(String promoId){
        Entitlement_Promotion__c ep = new Entitlement_Promotion__c();
        ep.Name = 'TestEP';
        ep.Discounted_amt__c = 20;
        ep.Promo_Mechanic__c = promoId;
        insert ep;
        return ep;
    }
    public static Loyalty__c CreateLoyalty(String Name, Integer Ten, Campaign ca, Integer per){
        Loyalty__c lyt = new Loyalty__c();
        lyt.Name=Name;
        lyt.PG_Tenure__c = ten;
        lyt.Campaign__c = ca.Id;
        lyt.Discount_Percentage__c = per;
        insert lyt;
        return lyt;
    }
    
    public static Payment_Method__c createPaymentMethod(String Name, Subsidiary__c sb){
        Payment_Method__c paymethod = new Payment_Method__c();
        paymethod.NS_Internal_ID__c = '1';
        paymethod.Name = Name;
        paymethod.CurrencyIsoCode = sb.CurrencyIsoCode;
        insert paymethod;
        return paymethod;
    }
    
    public static Payment__c createPayment(Id OptyId, Id QuoteId, String Refno, Payment_Method__c pmethod, Decimal amt){
        Payment__c payment = new Payment__c(); 
        payment.Quote_Record__c = QuoteId;
        payment.Opportunity_Record__c = OptyId;
        payment.Reference_Number__c = Refno;
        payment.Payment_Gateway__c = 'Adyen';
        payment.Payment_Mode__c = 'Paypal';
        payment.Amount2__c = 4;
        payment.Payment_Date__c = system.today();
        payment.Payment_Method__c = pmethod.Id;
        insert payment;
        return payment;
    }
    public static Campaign_Eligibility__c CreateCampaignEligibility(String campId){
        Campaign_Eligibility__c ce = new Campaign_Eligibility__c(status__c='Active',Next_run_scheduled__c=system.now(),Run_Frequency__c='Daily',Name='test1',Rule_Name_Extension__c='Select Id From Contact where Account.RecordType.developerName = \'Agency\'',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c = campId );
        return ce;
    }   
    
    public static AWS_Credential__c CreateAwsCredentialCS(){
        AWS_Credential__c customsetting=new AWS_Credential__c();
        customsetting.Name='AwsCredential';
        customsetting.Key__c='TESSTEE';
        customsetting.Secret__c='ESSWTEST';
        customsetting.BucketName__c='aws-test';
        customsetting.Host__c='s3.test.com';
        customsetting.Folder__c='/test/';
        insert customsetting;
        return customsetting;
    }
    
    public static Trigger_Execute__c CreateTriggerExecuteCS(String TriggerName, Boolean Enabled){
        Trigger_Execute__c objcustomsett=new Trigger_Execute__c();
        objcustomsett.Name=TriggerName;
        objcustomsett.Enable_del__c=Enabled;
        insert objcustomsett;
        return objcustomsett;
    }
    
    public static void executeDML_Main(User RunUser){
        
        initSetupData();
        //data setup
        system.debug('DML TestDataFactory');
        Subsidiary__c sb = createSubsidiary(RunUser);
        Account acc_b2c = createB2CAccount('test@test.com','1232134', RunUser, sb);
        system.debug(sb);
        system.debug(acc_b2c);
        
    }
       public static OpportunityContactRole CreateOCR(String OppId,String conId,String role){
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId=OppId,ContactId=conId,Role=role );
        return ocr;
    } 
    
    //Initializes setup data
    public static void initSetupData() {
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        list<PGtUtils.OneRT> lstRTs = new list<PGtUtils.OneRT>();
        lstRTs.add(new PGtUtils.OneRT('Agency', 'Account', null));
        lstRTs.add(new PGtUtils.OneRT('Agent', 'Account', null));
        lstRTs.add(new PGtUtils.OneRT('B2C', 'Opportunity', null));
        PGtUtils.retrieveRecordTypes(lstRTs);

        list<PGtUtils.OneUser> lstOUs = new list<PGtUtils.OneUser>();
        lstOUs.add(new PGtUtils.OneUser('Celigo Integration', 'celigoi@propertyguru.com.sg', 'System Administrator', 'CEO'));
        lstOUs.add(new PGtUtils.OneUser('Noor Azwina Abu Taib', 'azwina', 'OMC User', 'OMC'));
        lstOUs.add(new PGtUtils.OneUser('Fanny Koay', 'fanny', 'OMC User', 'OMC'));
        lstOUs.add(new PGtUtils.OneUser('Gabriel Toh', 'Gabriel', 'B2C Sales Head', 'SG_Commandos_Team_Lead_Team2'));
        lstOUs.add(new PGtUtils.OneUser('Grace Lee', 'Grace', 'B2C Sales User', 'SG_Commandos_Sales_Rep_Team2'));
        lstOUs.add(new PGtUtils.OneUser('Jesel Neo', 'Jesel', 'B2C Sales User', 'SG_Renewal_Sales_Rep_Team2'));
        lstOUs.add(new PGtUtils.OneUser('Kelly Leow', 'Kelly', 'B2C Sales User', 'SG_Commandos_Sales_Rep_Team2'));
        lstOUs.add(new PGtUtils.OneUser('Reeve Tan', 'Reeve', 'B2C Sales Head', 'SG_Commandos_Team_Lead'));
        lstOUs.add(new PGtUtils.OneUser('Vanessa Seet', 'vanessaseet', 'B2C Sales Head', 'SG_Commandos_Sales_Head'));
        lstOUs.add(new PGtUtils.OneUser('Edfer Medina', 'edfer', 'System Administrator', 'C_level_Mgt'));
        lstOUs.add(new PGtUtils.OneUser('Alvin Tang', 'alvin', 'B2C Sales Head', 'SG_CustCare_NBT_Renewal_Head'));
        lstOUs.add(new PGtUtils.OneUser('Jeremy Williams', 'jeremy', 'B2B Sales User', 'C_level_Mgt'));
        PGtUtils.retrieveUserInfo(lstOUs, '["Exact Match"]');
        CutomSettingFieldCreation();
        //PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        
    }
    
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_Amount_Despite_VIP_c = null;	// Amount_Despite_VIP__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_Campaign_c = null;	// Campaign__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_Complimentary_c = null;	// Complimentary__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_Discount_Amount_c = null;	// Discount_Amount__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_Discount_c = null;	// Discount__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_Discount_Reason_c = null;	// Discount_Reason__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_End_Date_c = null;	// End_Date__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_GST_VAT_Code1_c = null;	// GST_VAT_Code1__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_GST_VAT_Rate_c = null;	// GST_VAT_Rate__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_Line_Description2_c = null;	// Line_Description2__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_netsuite_conn_Discount = null;	// netsuite_conn__Discount_Item__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_PO_c = null;	// PO__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_Product_Category_c = null;	// Product_Category__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_Promo_Mechanic_Id_c = null;	// Promo_Mechanic_Id__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_Pro_Rate_Amount_c = null;	// Pro_Rate_Amount__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_Push_To_NetSuite_c = null;	// Push_To_NetSuite__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_Record_Type_c = null;	// Record_Type__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_SNo_c = null;	// SNo__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_Start_Date_c = null;	// Start_Date__c
    public static QliToOliFieldMapping__c CRG_QliToOliFieldMapping_cust_WHT_Rate_c = null;	// WHT_Rate__c
    
    // Main call method to perform inserts and updates of project records
    public static void CutomSettingFieldCreation(){
        CRG_QliToOliFieldMapping_cust_Amount_Despite_VIP_c = CRM_QliToOliFieldMapping_cust_Amount_Despite_VIP_c();
        CRG_QliToOliFieldMapping_cust_Campaign_c = CRM_QliToOliFieldMapping_cust_Campaign_c();
        CRG_QliToOliFieldMapping_cust_Complimentary_c = CRM_QliToOliFieldMapping_cust_Complimentary_c();
        CRG_QliToOliFieldMapping_cust_Discount_Amount_c = CRM_QliToOliFieldMapping_cust_Discount_Amount_c();
        CRG_QliToOliFieldMapping_cust_Discount_c = CRM_QliToOliFieldMapping_cust_Discount_c();
        CRG_QliToOliFieldMapping_cust_Discount_Reason_c = CRM_QliToOliFieldMapping_cust_Discount_Reason_c();
        CRG_QliToOliFieldMapping_cust_End_Date_c = CRM_QliToOliFieldMapping_cust_End_Date_c();
        CRG_QliToOliFieldMapping_cust_GST_VAT_Code1_c = CRM_QliToOliFieldMapping_cust_GST_VAT_Code1_c();
        CRG_QliToOliFieldMapping_cust_GST_VAT_Rate_c = CRM_QliToOliFieldMapping_cust_GST_VAT_Rate_c();
        CRG_QliToOliFieldMapping_cust_Line_Description2_c = CRM_QliToOliFieldMapping_cust_Line_Description2_c();
        CRG_QliToOliFieldMapping_cust_netsuite_conn_Discount = CRM_QliToOliFieldMapping_cust_netsuite_conn_Discount();
        CRG_QliToOliFieldMapping_cust_PO_c = CRM_QliToOliFieldMapping_cust_PO_c();
        CRG_QliToOliFieldMapping_cust_Product_Category_c = CRM_QliToOliFieldMapping_cust_Product_Category_c();
        CRG_QliToOliFieldMapping_cust_Promo_Mechanic_Id_c = CRM_QliToOliFieldMapping_cust_Promo_Mechanic_Id_c();
        CRG_QliToOliFieldMapping_cust_Pro_Rate_Amount_c = CRM_QliToOliFieldMapping_cust_Pro_Rate_Amount_c();
        CRG_QliToOliFieldMapping_cust_Push_To_NetSuite_c = CRM_QliToOliFieldMapping_cust_Push_To_NetSuite_c();
        CRG_QliToOliFieldMapping_cust_Record_Type_c = CRM_QliToOliFieldMapping_cust_Record_Type_c();
        CRG_QliToOliFieldMapping_cust_SNo_c = CRM_QliToOliFieldMapping_cust_SNo_c();
        CRG_QliToOliFieldMapping_cust_Start_Date_c = CRM_QliToOliFieldMapping_cust_Start_Date_c();
        CRG_QliToOliFieldMapping_cust_WHT_Rate_c = CRM_QliToOliFieldMapping_cust_WHT_Rate_c();
        list<QliToOliFieldMapping__c> lstQlitoolifieldmapping = new list<QliToOliFieldMapping__c>();
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_Amount_Despite_VIP_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_Campaign_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_Complimentary_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_Discount_Amount_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_Discount_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_Discount_Reason_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_End_Date_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_GST_VAT_Code1_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_GST_VAT_Rate_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_Line_Description2_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_netsuite_conn_Discount);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_PO_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_Product_Category_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_Promo_Mechanic_Id_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_Pro_Rate_Amount_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_Push_To_NetSuite_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_Record_Type_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_SNo_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_Start_Date_c);
        lstQlitoolifieldmapping.add(CRG_QliToOliFieldMapping_cust_WHT_Rate_c);
        insert lstQlitoolifieldmapping;
        
    }
    
    // Create the QliToOliFieldMapping__c record for "Amount_Despite_VIP__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_Amount_Despite_VIP_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,46,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,46,0);
        theQliToOliFieldMapping.Name = 'Amount_Despite_VIP__c';
        theQliToOliFieldMapping.OliField__c = 'Amount_Despite_VIP__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "Campaign__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_Campaign_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,13,06,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,13,06,0);
        theQliToOliFieldMapping.Name = 'Campaign__c';
        theQliToOliFieldMapping.OliField__c = 'Campaign__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "Complimentary__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_Complimentary_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,47,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,47,0);
        theQliToOliFieldMapping.Name = 'Complimentary__c';
        theQliToOliFieldMapping.OliField__c = 'Complimentary__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "Discount_Amount__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_Discount_Amount_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,47,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,47,0);
        theQliToOliFieldMapping.Name = 'Discount_Amount__c';
        theQliToOliFieldMapping.OliField__c = 'Discount_Amount__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "Discount__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_Discount_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,48,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,48,0);
        theQliToOliFieldMapping.Name = 'Discount__c';
        theQliToOliFieldMapping.OliField__c = 'Discount__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "Discount_Reason__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_Discount_Reason_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,51,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,51,0);
        theQliToOliFieldMapping.Name = 'Discount_Reason__c';
        theQliToOliFieldMapping.OliField__c = 'Discount_Reason__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "End_Date__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_End_Date_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,48,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,48,0);
        theQliToOliFieldMapping.Name = 'End_Date__c';
        theQliToOliFieldMapping.OliField__c = 'End_Date__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "GST_VAT_Code1__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_GST_VAT_Code1_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,54,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,16,11,02,0);
        theQliToOliFieldMapping.Name = 'GST_VAT_Code1__c';
        theQliToOliFieldMapping.OliField__c = 'GST_VAT_Code__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "GST_VAT_Rate__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_GST_VAT_Rate_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,48,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,48,0);
        theQliToOliFieldMapping.Name = 'GST_VAT_Rate__c';
        theQliToOliFieldMapping.OliField__c = 'GST_VAT_Rate__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "Line_Description2__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_Line_Description2_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,49,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,49,0);
        theQliToOliFieldMapping.Name = 'Line_Description2__c';
        theQliToOliFieldMapping.OliField__c = 'Line_Description2__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "netsuite_conn__Discount_Item__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_netsuite_conn_Discount() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,51,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,51,0);
        theQliToOliFieldMapping.Name = 'netsuite_conn__Discount_Item__c';
        theQliToOliFieldMapping.OliField__c = 'netsuite_conn__Discount_Item__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "PO__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_PO_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,49,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,49,0);
        theQliToOliFieldMapping.Name = 'PO__c';
        theQliToOliFieldMapping.OliField__c = 'PO__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "Product_Category__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_Product_Category_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,52,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,52,0);
        theQliToOliFieldMapping.Name = 'Product_Category__c';
        theQliToOliFieldMapping.OliField__c = 'Product_Category__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "Promo_Mechanic_Id__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_Promo_Mechanic_Id_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,54,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,54,0);
        theQliToOliFieldMapping.Name = 'Promo_Mechanic_Id__c';
        theQliToOliFieldMapping.OliField__c = 'Promo_Mechanic_Id__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "Pro_Rate_Amount__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_Pro_Rate_Amount_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,49,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,49,0);
        theQliToOliFieldMapping.Name = 'Pro_Rate_Amount__c';
        theQliToOliFieldMapping.OliField__c = 'Pro_Rate_Amount__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "Push_To_NetSuite__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_Push_To_NetSuite_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,49,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,49,0);
        theQliToOliFieldMapping.Name = 'Push_To_NetSuite__c';
        theQliToOliFieldMapping.OliField__c = 'Push_To_NetSuite__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "Record_Type__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_Record_Type_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,50,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,50,0);
        theQliToOliFieldMapping.Name = 'Record_Type__c';
        theQliToOliFieldMapping.OliField__c = 'Record_Type__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "SNo__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_SNo_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,50,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,50,0);
        theQliToOliFieldMapping.Name = 'SNo__c';
        theQliToOliFieldMapping.OliField__c = 'SNo__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "Start_Date__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_Start_Date_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,12,51,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,12,51,0);
        theQliToOliFieldMapping.Name = 'Start_Date__c';
        theQliToOliFieldMapping.OliField__c = 'Start_Date__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
    
    // Create the QliToOliFieldMapping__c record for "WHT_Rate__c"
    public static QliToOliFieldMapping__c CRM_QliToOliFieldMapping_cust_WHT_Rate_c() {
        QliToOliFieldMapping__c theQliToOliFieldMapping = new QliToOliFieldMapping__c();
        theQliToOliFieldMapping.CreatedDate = Datetime.newInstanceGmt(2020,09,14,13,07,0);
        theQliToOliFieldMapping.CurrencyIsoCode = 'SGD';
        theQliToOliFieldMapping.LastModifiedDate = Datetime.newInstanceGmt(2020,09,14,13,07,0);
        theQliToOliFieldMapping.Name = 'WHT_Rate__c';
        theQliToOliFieldMapping.OliField__c = 'WHT_Rate__c';
        theQliToOliFieldMapping.SetupOwnerId = null;	// Referenced record not included in project. Original value: 00D1m0000008aSXEAY
        return theQliToOliFieldMapping;
    }
/*********************************************************************************
 * 	Author: Suraj Bisht
 *  Method Name: createAccount
 * 	Parameters: String firstName,String lastName,Id agentRecordTypeId
 *  Description: constructs an agent account record for unit test
***********************************************************************************/
    public static Account constructAgentAccount(String firstName,String lastName,Id agentRecordTypeId){
        Account objAccount =new Account(FirstName=firstName,LastName=lastName);
        objAccount.Status__c='Trial';
        objAccount.RecordTypeId=agentRecordTypeId;
        objAccount.PersonBirthdate=System.today().addYears(-30);
        objAccount.CEA_Salesperson_Number__c='A123456A';
        objAccount.PersonEmail=objAccount.FirstName?.replaceAll( '\\s+', '')+'.'+objAccount.LastName?.replaceAll( '\\s+', '')+'@agent.com';
        objAccount.Mobile_Country__c='92';
        objAccount.Salutation='Mr';
        objAccount.Country__c='Malaysia';
        return objAccount;
    }
/*********************************************************************************
 * 	Author: Suraj Bisht
 *  Method Name: createUser
 * 	Parameters: Id userProfileId,String firstName,String lastName
 *  Description: constructs an user record for unit test
***********************************************************************************/
     public static User createUser(Id userProfileId,String firstName,String lastName) {
        User objUser = new User(Alias = 'testUser', Email='user@test.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = userProfileId, 
            TimeZoneSidKey='America/Los_Angeles', UserName=firstName?.replaceAll('\\s+','')+'.'+lastName?.replaceAll('\\s+','')+'@'+UserInfo.getOrganizationId()+'.com',country='Malaysia');
		return objUser;
    }
/*********************************************************************************
 * 	Author: Suraj Bisht
 *  Method Name: verifyAssertCheck
 * 	Parameters: sObject record,string fieldApiName,String expectedResult,Boolean assertEqualsCheck
 *  Description: method to verify code is working expected using assert statement 
***********************************************************************************/
    public static void verifyAssertCheck(sObject record,string fieldApiName,String expectedResult,Boolean assertEqualsCheck){
        if(assertEqualsCheck) System.assertEquals(record.get(fieldApiName),expectedResult);
        else System.assertNotEquals(record.get(fieldApiName),expectedResult);
    }
/*********************************************************************************
 * 	Author: Suraj Bisht
 *  Method Name: getActivePicklistValue
 * 	Parameters:  String objectName,string fieldApiName
 *  Description: get 1st active picklist value 
***********************************************************************************/
    public static String getActivePicklistValue(String objectName,string fieldApiName){
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        if(results != null && !results.isEmpty()){
            for(Schema.DescribeSobjectResult res : results) {
                for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldApiName).getDescribe().getPicklistValues()) {
                    if (entry.isActive()) {
                        return entry.getValue();
                    }
                }
            }
        }
        return '';
    }
}
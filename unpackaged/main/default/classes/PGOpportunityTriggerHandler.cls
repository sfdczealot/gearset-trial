public class PGOpportunityTriggerHandler {
    /*------------------------------------------------------------
Author      : Whisnu Satriya Wardhana
Company     : Viseo Asia PTE LTD
Description : to get all Subsidiary record.
input       : 
History     : Version change
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/  
    public static Boolean isFirstTime = true;
    public static Boolean isownerFirstTime = true;  
    public static Boolean allowOppstageChange = true;
    public static Boolean isFirstTimeSOKill =true;
    public static Boolean isFirstTimeSub =true;
    
    public static Map<String, Subsidiary__c> getSubsidiaryMap() {
        Map<String, Subsidiary__c> SubsMap = new Map<String, Subsidiary__c>();
        List<Subsidiary__c> SubsList = [SELECT Id, Name, Country__c FROM Subsidiary__c WHERE Id!=null];
        if(SubsList!=null && SubsList.size()>0) {
            for(Subsidiary__c s: SubsList) {
                SubsMap.put(s.Name, s);
            }
        }
        return SubsMap;
    }
    
    public static Map<String,Id> SubsidiaryNameIdMap() {
        
        Map<String,Id> SubsNameIdMap = new Map<String,Id>();
        
        List<Subsidiary__c> SubsList = [SELECT Id,Name FROM Subsidiary__c WHERE Id!=null];
        if(SubsList!=null && SubsList.size()>0) {
            for(Subsidiary__c s:SubsList) {
                SubsNameIdMap.put(s.Name,s.Id);
            }
        }
        
        return SubsNameIdMap;
        
    }
    
    public static Map<Id,Id> SubsidiaryIdPricebookIdMap() {
        
        Map<Id,Id> SubsIdPBIdMap = new Map<Id,Id>();
        
        List<PriceBook2> CustomPBList = [SELECT Id, Subsidiary__c,IsStandard FROM PriceBook2 WHERE Subsidiary__c!=NULL AND IsStandard = FALSE];
        if(CustomPBList!=null && CustomPBList.size()>0) {    
            for(PriceBook2 pb : CustomPBList) {
                SubsIdPBIdMap.put(pb.Subsidiary__c,pb.Id);
            }
        }      
        
        return SubsIdPBIdMap;  
        
    }
    
    public static Map<Id,String> UserIdSubsIdMap() {
        
        Map<Id,String> OwnerSubsNameIdMap = new Map<Id,String>();
        
        List<User> UserList= [SELECT Id,Subsidiary__c FROM User];
        if(UserList!=null && UserList.size()>0) {
            for(User u:UserList) {
                OwnerSubsNameIdMap.put(u.Id,u.Subsidiary__c);
            }
        }
        
        return OwnerSubsNameIdMap;
        
    }
    
    /*------------------------------------------------------------
Author      : Thinh Ho
Company     : Viseo Asia PTE LTD
Description : to prevent recursive call.
input       : Opportunity Create
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/   
    private static boolean firstRun = true;
    public static boolean isFirstRun() {
        if (firstRun) {
            firstRun = false;
            return true;
        } else {
            return firstRun;
        }
    }
    
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : to set "Immediate" payment term as default value of B2C Opportunity
input       : Opportunity Create
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/    
    public static void insertHandler(List<Opportunity> listOpp) {
        Map<String,String> MapOppRT = new Map<String,String>();
        list<Recordtype> Rc = new list<recordtype>([SELECT Id,Name FROM RecordType WHERE SObjectType='Opportunity' and Name='B2C']);
        for (RecordType rt : Rc) {
            MapOppRT.put(rt.Name,rt.Id);
        }
        list<Payment_Term__c> rowPaymentTerms = new list<Payment_Term__c>([SELECT Id FROM Payment_Term__c WHERE name = 'Immediate' LIMIT 1]);
        if(rowPaymentTerms.size()>0) {
            for(Opportunity Op : listOpp) {
                if(Op.RecordTypeId == mapOppRT.get('B2C')) {   
                    Op.Payment_Term__c = rowPaymentTerms[0].Id;    
                }
            }        
        }
    }
    
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : To handle VIP checkbox in account upon opportunity closed won. 
input       : Opportunity Create
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/ 
    
    public static void updateAgentVIP (List<Opportunity> listOpp, Map<Id, Opportunity> oldMapOpp) {
        map<id,Boolean> AcctoUpdate = new map<id,Boolean>();
        map<id,String> AccRuletoUpdate = new map<id,String>();
        map<id,double> AccProRatetoUpdate = new map<id,double>();
        list<Account> Acc = new list<Account>();
        map<String,String> MapOppRT = new Map<String,String>();
        list<OpportunityLineItem> Opl;
        set<id> isUpgrade = new set<id>();
        
        for(RecordType rt : [SELECT Id,Name FROM RecordType WHERE SObjectType='Opportunity']) {
            MapOppRT.put(rt.Name,rt.Id);
        }
        for(opportunity opp : listOpp){
            if(Opp.RecordTypeId == MapOppRT.get('B2C')) {
                if (Opp.StageName <> oldMapOpp.get(Opp.id).StageName) {
                    if(Opp.StageName == 'Closed Won') {
                        if(Opp.count_of_subscription_item_new__c > 0) {
                            AccRuletoUpdate.put(Opp.AccountId,Opp.Subscription_Code__c);
                            AccProRatetoUpdate.put(Opp.AccountId,Opp.Pro_Rate__c);
                            if(!isUpgrade.contains(Opp.id) || Opp.count_of_vip_subscription_new__c > 0) {
                                AcctoUpdate.put(Opp.AccountId,Opp.count_of_vip_subscription_new__c > 0);
                            }
                        }
                    }
                }
            }
        }
        if (AccRuletoUpdate.size() > 0) {
            Opl = new list<opportunityLineItem>([Select id,opportunityid,order_type__c from OpportunityLineItem where opportunityid in: listOpp]);
            for(OpportunityLineItem rowOpl : Opl) {
                if(rowOpl.order_type__c == 'Upgrade Outside Renewal Window' || rowOpl.order_type__c == 'Upgrade Inside Renewal Window' ){
                    isUpgrade.add(rowOpl.opportunityId);
                }
            }
            for(opportunity opp : listOpp){
                if(Opp.RecordTypeId == MapOppRT.get('B2C') && Opp.StageName <> oldMapOpp.get(Opp.id).StageName && Opp.StageName == 'Closed Won' && Opp.count_of_subscription_item_new__c > 0 && (!isUpgrade.contains(Opp.id) || Opp.count_of_vip_subscription_new__c > 0)) {
                    AcctoUpdate.put(Opp.AccountId,Opp.count_of_vip_subscription_new__c > 0);
                }
            }
            
            Acc = [select id,vip__c,Pro_Rate_Amount__c,updated_from_API__c,Current_Subscription_Code__c from account where id in:AccRuletoUpdate.keyset()];
            if(Acc.size()>0) {
                try {
                    for (Account TempAcc :Acc) {
                        TempAcc.Current_Subscription_Code__c = AccRuletoUpdate.get(TempAcc.id);
                        TempAcc.Pro_Rate_Amount__c = AccProRatetoUpdate.get(TempAcc.id);
                        TempAcc.vip__c = AcctoUpdate.keyset().contains(TempAcc.id)?AcctoUpdate.get(TempAcc.id):TempAcc.vip__c;
                        TempAcc.updated_from_API__c = !TempAcc.updated_from_API__c;
                    }
                    update Acc;
                } catch(DmlException e) {
                    system.debug(e.getMessage());
                }
            }
        }       
    }
    
    /*------------------------------------------------------------
Author      : Lailatul Izza
Company     : Viseo Asia PTE LTD
Description : to reset Payment Time, Payment Reference, Payment Amount when cloning the opportunity
input       : Opportunity Create
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/    
    public static void resetField(List<Opportunity> listOpp) {
        String b2cCloseLost =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Closed Lost').getRecordTypeId();
        String b2b=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        String b2c =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        for (Opportunity op : listOpp) {
            if(op.IsClone__c != null && (op.recordtypeId==b2b || op.recordtypeId==b2c || op.recordtypeId==b2cCloseLost)) {
                op.Payment_Time__c = null;
                op.Payment_Reference__c = '';
                op.Payment_Amount__c = null;
                op.Allowed_Payment_Type__c = 'All';
            }
        }
    }
    
    /*------------------------------------------------------------
Author      : Lailatul Izza
Company     : Viseo Asia PTE LTD
Description : to set IsClone field
input       : Opportunity Create
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/    
    public static void setIsClone(List<Opportunity> listOpp) {
        String b2cCloseLost =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Closed Lost').getRecordTypeId();
        String b2b=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        String b2c =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        for (Opportunity op : listOpp) {
            if(op.IsClone__c == null && (op.recordtypeId==b2b || op.recordtypeId==b2c || op.recordtypeId==b2cCloseLost)) {
                op.IsClone__c = 'NO';
            } else {
                op.IsClone__c = 'YES';
            }
        }
    }
    
    /*------------------------------------------------------------
Author      : Whisnu Satriya Wardhana
Company     : Viseo Asia PTE LTD
Description : To set Agent Is Qualify Agent Referral Program upon close won
input       : mapOppOld <map<Id, Opportunity>>
listOpp <list<Opportunity>>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/    
    public static void setAgentQualifyReferral(map<Id, Opportunity> mapOppOld, list<Opportunity> listOpp) {
        list<Id> listAccId = new list<Id>();
        list<Account> listAcc = new list<Account>();
        for (Opportunity row : listOpp) {
            if (row.StageName == 'Closed Won' && row.StageName != mapOppOld.get(row.Id).StageName) {
                listAccId.add(row.AccountId);
            }
        }
        if (listAccId.size() > 0) {
            for (Account row: [select Id, FirstName, LastName, Updated_From_API__c, Is_Qualify_Agent_Referral_Program__c from Account where Id in :listAccId]) {
                if (row.Is_Qualify_Agent_Referral_Program__c) {
                    row.Is_Qualify_Agent_Referral_Program__c = false;
                    row.Updated_From_API__c = !row.Updated_From_API__c;
                    listAcc.add(row);
                }
            }
            if (listAcc.size() > 0) {
                update listAcc;
            }
        }
    }
    
    /*
The following section is for enabling Opportunity Sync from SF to NS
*/
    private static integer ctrRun = 1;
    static string errorResponse = '' ;
    static string errorLimit = '';
    
    public class SOUpdNSPayload {
        String type;
        SOUpdNS record;
    }
    
    public class SOUpdNS {
        String optynumber_ns;
        SONSitem optylineitem;
        OptySplitList RecordSplit;
        OptyRecord NewRecord;
        String OMCApprovalDate;
        String status;
        String action;
    }
    
    public class OptyDeposit {
        String refnum;
        String paymentGateway;
        Decimal amount;
        Datetime paydate;
    }
    
    public class OptyBillingAddress {
        String BillCity;
        String BillStreet;
        String BillState;
        String BillCountry;
        String BillPostal;
        String BillAddressee;
        String AdditionalCity;
        String AdditionalStreet;
        String AdditionalState;
        String AdditionalCountry;
        String AdditionalPostal;
        String AdditionalAddressee;
    }
    
    public class OptyRecord {
        OptyItemList line;
        OptyAttList att;
        OptyOffPayList offpaylist;
        String Memo;
        String SendToSF = 'F';
        String CurrencyIsoCode;
        String UserId;
        Date OrderDate;
        String StageName;
        String RecordTypeId;
        String SubId;
        String PONo;
        String Remarks;
        String Id;
        String AccountId;
        Decimal PaymentTermId;
        Decimal TotalWHT;
        String SyncToAN = 'T';
        Decimal TotalDiscAmt;
        String RelatedSO;
        String OptyNumber;
        String ContactId;
        OptyDeposit deposit;
        String AutoActivation;
        String SalesPeriod;
        String InvoiceId;
        String QuoteNumber;
        OptyBillingAddress address;
        BusinessAccountPayload AccRec;
    }
    
    public class OptySplitList {
        list<OptySplit> EntryList = new list<OptySplit>();
    }
    
    public class OptyItemList {
        list<OptyItem> EntryList = new list<OptyItem>();
    }
    
    public class OptyAttList {
        Integer count = 0;
        list<OptyAtt> EntryList = new list<OptyAtt>();
    }
    
    public class OptyOffPayList {
        list<OptyOffPay> EntryList = new list<OptyOffPay>();
    }
    
    public class OptyAtt {
        String att;
        String name;
        String atttype;
    }
    
    public class OptyOffPay {
        String PaymentMethod;
        String refnum;
        Decimal amount;
        Date paydate;
        String PayNum;
    }
    
    public class OptySplit {
        String Employee;
        Decimal Contribution;
        Decimal Amount;
    }
    
    public class OptyItem {
        String SFLineId;
        String ItemId;
        String Descr;
        Decimal UnitPrice;
        Decimal Quantity;
        Decimal GrossAmt;
        String DiscItemId;
        Decimal DiscRate;
        Decimal GSTVatRate;
        Date StartDate;
        Date EndDate;
        Decimal ItmAmt;
        Decimal RemDisc;
        String TaxCode;
        Decimal SNO;
        Boolean Comp;
        Decimal WHTRate;
        Decimal WHTAmount;
        String Duration;
        Decimal DiscRateNumber;
        String AutoActivation;
    }
    
    public class SONSitem {
        String SFlineId;
    }
    
    public class BusinessAccountPayload {
        String type;
        BusinessAccount record;
    }
    
    public class BusinessAccount {
        String AccountId;
        String CompanyName;
        String Individual = 'F';
        String Website;
        String ParentCompany;
        String Fax;
        String Phone;
        String Description;
        String PushToSF = 'F';
        String Email;
        String Industry;
        String CustomerType;
        String VatReg;
        String BranchId;
        String AccountCurrency;
        String Subsidiary;
        String BillCity;
        String BillStreet;
        String BillState;
        String BillCountry;
        String BillPostal;
        String BillAddressee;
        String ShipCity;
        String ShipStreet;
        String ShipState;
        String ShipCountry;
        String ShipPostal;
        String ShipAddressee;
        String NetSuiteId;
        BusinessAccountContactsList RecordContact;
    }
    
    public class BusinessAccountContactsList {
        list<BusinessAccountContacts> EntryList = new list<BusinessAccountContacts>();
    }
    
    public class BusinessAccountContacts {
        String ContactId;
        String PushToSF = 'F';
        String Title;
        String MobilePhone;
        String WorkPhone;
        String MobilePhone2;
        String LastName;
        String FirstName;
        String Fax;
        String Email;
        String Comments;
        String Company;
        String Subsidiary;
        String BillCountry;
        String BillPostal;
        String BillState;
        String BillCity;
        String BillStreet;
        String NetSuiteId;
    }
    
    public static void UpdateSONS(list<opportunity> opty, map<id,Opportunity> OldMapOpty) {
        boolean GoOpty = false;  
        list<id> OptyIDB2BClosed = new list<id>();
        list<id> OptyIDNewSync = new list<id>();
        
        for(Opportunity optyrec : [select id,RecordTypeId,StageName,Approval_Status__c,Current_Sales_Order_Id__c,billing_OMC_Approved__c, Sync_To_NetSuite__c from opportunity where id in: opty]) {
            if(optyrec.Current_Sales_Order_Id__c != null && optyrec.StageName == 'Closed Lost') {
                GoOpty = true;
                OptyIDB2BClosed.add(optyrec.id);
            }
            
            if(optyrec.Sync_To_NetSuite__c == true && (((optyrec.StageName == 'Closed Won') && optyrec.RecordTypeId == '0127F000000K50eQAC') || (optyrec.RecordTypeId == '0127F0000005401QAA' && optyrec.StageName == 'Closed Won'))) {
                GoOpty = true;
                OptyIDNewSync.add(optyrec.id);
            }
        }
        if(OptyIDB2BClosed.size()>0) {
            if(GoOpty == true) {
                afterInsertClosedOpty(OptyIDB2BClosed);
            }
        }
        if(OptyIDNewSync.size()>0){
            if(GoOpty == true){
                addItemToNSQueueManager(OptyIDNewSync);
            }
        }
    }
    
    @future(callout = true)
    public static void afterInsertClosedOpty(list<id> OptyClosed) {
        
        Map<string,string> reqHeaders = new Map<string,string>();
        HttpResponse res;
        
        errorResponse = '';
        
        String RootEndpoint, RootEndpoint_Key;
        
        if (runningInASandbox()) {
            RootEndpoint = label.PG_LABEL_PG_NetSuite_Billing_Sync_SB; 
            RootEndpoint_Key = label.PG_LABEL_PG_NetSuite_Billing_Sync_Cred_SB;
        }
        else{
            RootEndpoint = label.PG_LABEL_PG_NetSuite_Billing_Sync;
            RootEndpoint_Key = label.PG_LABEL_PG_NetSuite_Billing_Sync_Cred; 
        }
        try {
            //req.setEndpoint(RootEndpoint);
            //req.setMethod('POST');
            reqHeaders.put('Cache-Control', 'no-cache');
            reqHeaders.put('Content-Type', 'application/json');
            reqHeaders.put('Authorization', RootEndpoint_Key);
            List <Opportunity> OptyRec = [
                select 
                id, Current_Sales_Order_Id__c, StageName
                from 
                Opportunity
                where 
                id  =: OptyClosed
            ];
            SOUpdNSPayload SONSPayload = new SOUpdNSPayload();
            SOUpdNS OC = new SOUpdNS();
            OptyRecord OPR = new OptyRecord();
            
            for(Opportunity row : OptyRec) {
                OC.optynumber_ns = row.Current_Sales_Order_Id__c;
                OPR.StageName = row.StageName;
                OPR.Id = row.id;
            }
            OC.NewRecord = OPR;
            OC.action = 'ClosedLost';
            
            SONSPayload.type = 'OpptySync';
            SONSPayload.record = OC;
            string request = system.JSON.serialize(SONSPayload);
            
            
            Integer retryCount = 0;
            do{
                res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,request,'POST',true,false,null,null);
                if(!Test.isRunningTest() && res.getStatusCode() <> 200) {
                    errorResponse = res.getBody();
                }  
                retryCount += 1;
            }while(!Test.isRunningTest() && res.getStatusCode() <> 200 && retryCount <3);
            
        } catch(DmlException e) {
            errorResponse =  e.getMessage();
            system.debug(errorResponse);
        }
    }
    
    @future(callout = true)
    public static void addItemToNSQueueManager(list<id> OptyId) {
        
        Map<string,string> reqHeaders = new Map<string,string>();
        HttpResponse res;
        
        errorResponse = '';
        errorLimit = '';
        
        String RootEndpoint, RootEndpoint_Key, NSId = '', AccId = '', Rtype = '';
        
        RootEndpoint = label.PG_LABEL_PG_NetSuite_Billing_Sync;
        RootEndpoint_Key = label.PG_LABEL_PG_NetSuite_Billing_Sync_Cred; 
        if (runningInASandbox()) {
            RootEndpoint = label.PG_LABEL_PG_NetSuite_Billing_Sync_SB; 
            RootEndpoint_Key = label.PG_LABEL_PG_NetSuite_Billing_Sync_Cred_SB;
        }   
        
        try {
            System.debug('Opty NS ID' + OptyId);
            
            reqHeaders.put('Cache-Control', 'no-cache');
            reqHeaders.put('Content-Type', 'application/json');
            reqHeaders.put('Authorization', RootEndpoint_Key);
            
            OptySplitList OSL = new OptySplitList();
            OptyRecord OPR = new OptyRecord();
            OptyDeposit OD = new OptyDeposit();
            OptyItemList OIL = new OptyItemList();
            OptyAttList OAL = new OptyAttList();
            OptyOffPayList OFPL = new OptyOffPayList();
            OptyBillingAddress OAD = new OptyBillingAddress();
            BusinessAccountPayload BAPayload = new BusinessAccountPayload();
            BusinessAccount BA = new BusinessAccount();
            BusinessAccountContactsList BACL = new BusinessAccountContactsList();
            Integer attcount = 0;
            Boolean skipatt = false;
            Boolean isB2B = true;
            
            
            List <Opportunity> OptyRec = [
                select
                RecordTypeId, Memo__c, CurrencyIsoCode, Owner.NS_Internal_ID__c, Order_Date__c, StageName, 
                Subsidiary__r.NS_Subsidiary_Internal_ID__c, Customer_PO__c, Remarks__c, Id, 
                Account.NetSuite_Id__c, Billing_Contact__r.NetSuite_Id__c, Payment_Term__r.NS_Payment_Term_ID__c, 
                Total_Discounted_Amount__c, Related_Opportunity__r.Current_Sales_Order_Id__c, 
                Opportunity_Number__c, Current_Sales_Order_Id__c, OMC_Approved_Date__c,SyncedQuoteId,
                Payment_Reference__c, Payment_Amount__c, Payment_Time__c, Sales_Period__r.Name, Attachment_Limit_Exceeded__c,
                Billing_City_new__c, Billing_Street_new__c, Billing_State_Province_new__c, Billing_Country_new__c, Billing_Zip_Postal_Code_new__c, Billing_Contact__c,
                Account.Name, AccountId, Payment_Gateway__c,Total_WHT_Amount__c
                from
                opportunity
                where
                id =: OptyId
                LIMIT 1
            ];
            
            List <OpportunityLineItem> OptyRecLineItem = [
                select 
                Id, Product2.NetSuite_Id__c, Line_Description2__c, UnitPrice, Quantity,
                Gross_Amount__c, Discounted__c,
                GST_VAT_Rate__c, Actual_Start_Date__c, Start_Date__c, End_Date__c, Discounted_Amount__c, GST_VAT_Code_NS_InternalID__c,
                SNo__c, Complimentary__c, Discounted_10dp__c, Product_Duration__c, PO__c, Pro_Rate_Amount__c,Opportunity.RecordTypeId,
                Opportunity.Order_Type_Clone__c,Opportunity.Opportunity_Type__c, Opportunity.Country__c,
                WHT_Amount__c,WHT_Rate__c
                from
                OpportunityLineItem 
                where
                OpportunityId =: OptyId
            ];
            
            List <OpportunitySplit> OptyRecLineSplit = [
                select 
                id, OpportunityId, Split, SplitAmount, SplitNote, SplitOwnerId, SplitPercentage,
                SplitTypeId ,Email__c,NS_Internal_ID__c from OpportunitySplit
                where
                OpportunityId  =: OptyId and (SplitTypeId = '149N0000000008aIAA' or SplitTypeId = '1497F0000004rmjQAA')
            ];
            
            List <Attachment> OptyAttachment = [
                select
                id, Body, ContentType, Name from Attachment
                where
                parentid =: OptyId
            ];
            
            List <ContentDocumentLink> OptyAttachmentDocumentLink = [
                SELECT
                ContentDocumentId
                FROM
                ContentDocumentLink
                WHERE
                LinkedEntityId =: OptyId
            ];
            
            List <Payment__c> OptyRecOfflinePayment = [
                select 
                Name, Amount__c, Payment_Method__r.NS_Internal_ID__c, Reference_Number__c, Payment_Date__c from Payment__c
                where
                Opportunity_Record__c  =: OptyId
            ];
            
            List <Quote> QuoteRecord = [
                select 
                id, Quote_Number__c from Quote
                where 
                OpportunityId =: OptyId and Status = 'Accepted'
            ];
            
            SOUpdNSPayload SONSPayload = new SOUpdNSPayload();
            SOUpdNS OC = new SOUpdNS();
            
            //For setting auto activation
            OPR.AutoActivation = 'F';
            for(OpportunityLineItem rowsitem : OptyRecLineItem) {
                if(rowsitem.PO__c) {
                    OPR.AutoActivation = 'T';
                    break;
                }
            }
            Map<Id,Quote> SyncedQuotes = new  Map<Id,Quote>();
            Set<Id> SyncnedQuoteid = new Set<Id>();
            
            for(Opportunity opp : OptyRec){
                if(String.isNotBlank(opp.SyncedQuoteId))
                    SyncnedQuoteid.add(opp.SyncedQuoteId);
            }
            
            for(Quote quo : [Select id,AdditionalStreet,AdditionalCity,AdditionalState,AdditionalPostalCode,AdditionalCountry,AdditionalName,
                             BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry, BillingName from Quote where Id IN : SyncnedQuoteid]){
                                 SyncedQuotes.put(quo.id,quo);      
                             }
            
            
            for(Opportunity row : OptyRec) {
                OPR.Memo = row.Memo__c;
                OPR.SendToSF = 'F';
                OPR.CurrencyIsoCode = row.CurrencyIsoCode;
                OPR.UserId = row.Owner.NS_Internal_ID__c;
                OPR.OrderDate = row.Order_Date__c;
                OPR.StageName = row.StageName;
                OPR.RecordTypeId = row.RecordTypeId;
                Rtype = row.RecordTypeId;
                OPR.SubId = row.Subsidiary__r.NS_Subsidiary_Internal_ID__c;
                OPR.PONo = row.Customer_PO__c;
                OPR.Remarks = row.Remarks__c;
                OPR.Id = row.Id;
                OPR.AccountId = row.Account.NetSuite_Id__c;
                AccId = row.AccountId;
                NSId = row.Account.NetSuite_Id__c;
                OPR.PaymentTermId = row.Payment_Term__r.NS_Payment_Term_ID__c;
                OPR.SyncToAN = 'T';
                OPR.TotalDiscAmt = row.Total_Discounted_Amount__c;
                OPR.RelatedSO = row.Related_Opportunity__r.Current_Sales_Order_Id__c;
                OPR.OptyNumber = row.Opportunity_Number__c;
                if( row.Total_WHT_Amount__c != null && row.Total_WHT_Amount__c > 0){
                    OPR.TotalWHT = row.Total_WHT_Amount__c;
                }
                OC.optynumber_ns = row.Current_Sales_Order_Id__c;
                OC.status = row.StageName;
                if(row.OMC_Approved_Date__c != null){
                    OC.OMCApprovalDate = row.OMC_Approved_Date__c.year()+'-'+row.OMC_Approved_Date__c.month()+'-'+row.OMC_Approved_Date__c.day()+' '+row.OMC_Approved_Date__c.hour()+':'+row.OMC_Approved_Date__c.minute()+':'+row.OMC_Approved_Date__c.second();
                }else{
                    OC.OMCApprovalDate = '';
                }
                OPR.ContactId = row.Billing_Contact__r.NetSuite_Id__c;
                OPR.SalesPeriod = row.Sales_Period__r.Name;
                OD.refnum = row.Payment_Reference__c;
                OD.paymentGateway = row.Payment_Gateway__c;
                OD.amount = row.Payment_Amount__c;
                OD.paydate = row.Payment_Time__c;
                If(row.RecordTypeId=='0127F0000005401QAA' ){
                    OAD.BillCity = row.Billing_City_new__c;
                    OAD.BillStreet = row.Billing_Street_new__c;
                    OAD.BillState = row.Billing_State_Province_new__c;
                    OAD.BillCountry = row.Billing_Country_new__c;
                    OAD.BillPostal = row.Billing_Zip_Postal_Code_new__c;
                    OAD.BillAddressee = row.Account.Name;
                }else{
                    OAD.BillCity = SyncedQuotes.get(row.SyncedQuoteId).BillingCity;
                    OAD.BillStreet = SyncedQuotes.get(row.SyncedQuoteId).BillingStreet;
                    OAD.BillState = SyncedQuotes.get(row.SyncedQuoteId).BillingState;
                    OAD.BillCountry = SyncedQuotes.get(row.SyncedQuoteId).BillingCountry;
                    OAD.BillPostal = SyncedQuotes.get(row.SyncedQuoteId).BillingPostalCode;
                    OAD.BillAddressee = SyncedQuotes.get(row.SyncedQuoteId).BillingName;
                    OAD.AdditionalCity = SyncedQuotes.get(row.SyncedQuoteId).AdditionalCity;
                    OAD.AdditionalStreet = SyncedQuotes.get(row.SyncedQuoteId).AdditionalStreet;
                    OAD.AdditionalState = SyncedQuotes.get(row.SyncedQuoteId).AdditionalState;
                    OAD.AdditionalCountry = SyncedQuotes.get(row.SyncedQuoteId).AdditionalCountry;
                    OAD.AdditionalPostal = SyncedQuotes.get(row.SyncedQuoteId).AdditionalPostalCode;
                    OAD.AdditionalAddressee = SyncedQuotes.get(row.SyncedQuoteId).AdditionalName;
                    
                }
                OPR.address = OAD;
                skipatt = row.Attachment_Limit_Exceeded__c;
            }
            
            for(Quote rowQuote : QuoteRecord){
                OPR.QuoteNumber = rowQuote.Quote_Number__c;
            }
            
            for(OpportunitySplit rowsplit : OptyRecLineSplit) {
                OptySplit OS = new OptySplit();
                OS.Employee = rowsplit.NS_Internal_ID__c;
                OS.Contribution = rowsplit.SplitPercentage;
                OS.Amount = rowsplit.SplitAmount;
                OSL.EntryList.add(OS);
            }
            
            for(OpportunityLineItem rowsitem : OptyRecLineItem) {
                if(rowsitem.Opportunity.RecordTypeId == '0127F000000K50eQAC'){
                    if(rowsitem.SNo__c==Math.ceil(rowsitem.SNo__c)){
                        OptyItem OI = new OptyItem();
                        OI.SFLineId = rowsitem.Id;
                        OI.ItemId = rowsitem.Product2.NetSuite_Id__c;
                        OI.Descr = rowsitem.Line_Description2__c;
                        OI.UnitPrice = rowsitem.UnitPrice;
                        OI.Quantity = rowsitem.Quantity;
                        OI.GrossAmt = rowsitem.Gross_Amount__c;
                        OI.DiscRate = rowsitem.Discounted__c;
                        OI.GSTVatRate = rowsitem.GST_VAT_Rate__c;
                        
                        //if not project x
                        OI.StartDate = rowsitem.Actual_Start_Date__c;
                        if((rowsItem.Opportunity.Order_Type_Clone__c == 'Contract - Upgrade' || rowsItem.Opportunity.Opportunity_Type__c == 'B2C - Upgrade') && rowsItem.Opportunity.country__c == 'Malaysia') {
                            //if MY upgrade
                            OI.EndDate = rowsitem.End_Date__c;
                        } else { 
                            //for other b2c cases
                            OI.EndDate = rowsitem.Start_Date__c == rowsitem.Actual_Start_Date__c ? rowsitem.End_Date__c : rowsitem.Actual_Start_Date__c.addDays(rowsitem.Start_Date__c.daysBetween(rowsitem.End_Date__c));
                        }
                        
                        if(rowsitem.Pro_Rate_Amount__c > 0){
                            OI.ItmAmt = rowsitem.Discounted_Amount__c + rowsitem.Pro_Rate_Amount__c;
                        }
                        else{
                            OI.ItmAmt = rowsitem.Discounted_Amount__c;
                        }
                        OI.RemDisc = rowsitem.Discounted_Amount__c;
                        OI.TaxCode = rowsitem.GST_VAT_Code_NS_InternalID__c;
                        OI.SNO = rowsitem.SNo__c;
                        OI.Duration = rowsitem.Product_Duration__c;
                        OI.Comp = rowsitem.Complimentary__c;
                        OI.DiscRateNumber = rowsitem.Discounted_10dp__c;
                        if(rowsitem.WHT_Rate__c!=null && rowsitem.WHT_Rate__c > 0){
                            OI.WHTRate = rowsitem.WHT_Rate__c;
                        }
                        if(rowsitem.WHT_Amount__c!=null && rowsitem.WHT_Amount__c > 0){
                            OI.WHTAmount = rowsitem.WHT_Amount__c;
                        }
                        OI.AutoActivation = rowsitem.PO__c ? 'T' : 'F';
                        OIL.EntryList.add(OI);
                    }
                }
                else{
                    OptyItem OI = new OptyItem();
                    OI.SFLineId = rowsitem.Id;
                    OI.ItemId = rowsitem.Product2.NetSuite_Id__c;
                    OI.Descr = rowsitem.Line_Description2__c;
                    OI.UnitPrice = rowsitem.UnitPrice;
                    OI.Quantity = rowsitem.Quantity;
                    OI.GrossAmt = rowsitem.Gross_Amount__c;
                    OI.DiscRate = rowsitem.Discounted__c;
                    OI.GSTVatRate = rowsitem.GST_VAT_Rate__c;
                    
                    //b2b
                    OI.StartDate = rowsitem.Start_Date__c;
                    OI.EndDate = rowsitem.End_Date__c;
                    
                    if(rowsitem.Pro_Rate_Amount__c > 0){
                        OI.ItmAmt = rowsitem.Discounted_Amount__c + rowsitem.Pro_Rate_Amount__c;
                    }
                    else{
                        OI.ItmAmt = rowsitem.Discounted_Amount__c;
                    }
                    OI.RemDisc = rowsitem.Discounted_Amount__c;
                    OI.TaxCode = rowsitem.GST_VAT_Code_NS_InternalID__c;
                    OI.SNO = rowsitem.SNo__c;
                    OI.Duration = rowsitem.Product_Duration__c;
                    OI.Comp = rowsitem.Complimentary__c;
                    OI.DiscRateNumber = rowsitem.Discounted_10dp__c;
                    if(rowsitem.WHT_Rate__c!=null && rowsitem.WHT_Rate__c > 0){
                        OI.WHTRate = rowsitem.WHT_Rate__c;
                    }
                    if(rowsitem.WHT_Amount__c!=null && rowsitem.WHT_Amount__c > 0){
                        OI.WHTAmount = rowsitem.WHT_Amount__c;
                    }
                    OI.AutoActivation = rowsitem.PO__c ? 'T' : 'F';
                    OIL.EntryList.add(OI);
                }
            }
            
            
            if(skipatt == false){
                for(ContentDocumentLink rowsattDL : OptyAttachmentDocumentLink) {
                    List <ContentVersion> OptyAttachmentContentVersion = [
                        SELECT
                        ContentModifiedById,ContentDocumentId,FileExtension,
                        FileType,ContentSize,ContentUrl,Id,VersionData,
                        VersionNumber,Title
                        FROM
                        ContentVersion
                        where
                        ContentDocumentId =: rowsattDL.ContentDocumentId
                    ];
                    for(ContentVersion rowsattCV : OptyAttachmentContentVersion) {
                        
                        attcount++;
                        OptyAtt OA = new OptyAtt();
                        OA.name = rowsattCV.Title;
                        OA.att = EncodingUtil.base64Encode(rowsattCV.VersionData);
                        OA.atttype = rowsattCV.FileType;
                        OAL.EntryList.add(OA);
                    }
                }
            }
            
            for(Payment__c rowpayment : OptyRecOfflinePayment) {
                OptyOffPay OFP = new OptyOffPay();
                OFP.refnum = rowpayment.Reference_Number__c;
                OFP.PaymentMethod = rowpayment.Payment_Method__r.NS_Internal_ID__c;
                OFP.amount = rowpayment.Amount__c;
                OFP.paydate = rowpayment.Payment_Date__c;
                OFP.PayNum = rowpayment.Name;
                OFPL.EntryList.add(OFP);
            }
            
            if((NSId == '' || NSId == null) && Rtype == '0127F0000005401QAA'){
                List <Account> B2BAccount = [
                    select 
                    id, name, Email__c, Website, ParentId, Fax, Phone, Description, 
                    Industry, Customer_Type__c , Tax_Reg_Number__c, Branch_ID__c,
                    CurrencyIsoCode, Subsidiary__r.NS_Subsidiary_Internal_ID__c, BillingStreet, BillingCity, 
                    BillingState, BillingPostalCode, BillingCountry, ShippingStreet,
                    ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, NetSuite_Id__c
                    from 
                    account
                    where 
                    id  =: AccId
                ];
                List <Contact> B2BContacts = [
                    select
                    id,Title,MobilePhone,Phone,HomePhone,LastName,FirstName,Fax,Email,Description,Subsidiary__r.NS_Subsidiary_Internal_ID__c,
                    MailingCountry,MailingPostalCode,MailingCity,MailingState,MailingStreet,accountid, NetSuite_Id__c
                    from
                    contact
                    where
                    accountid =: AccId
                ];
                
                for(Account row : B2BAccount){
                    BA.AccountId = row.id;
                    BA.CompanyName = row.name;
                    BA.Email = row.Email__c;
                    BA.Website = row.Website;
                    BA.ParentCompany = row.ParentId;
                    BA.Fax = row.Fax;
                    BA.Phone = row.Phone;
                    BA.Description = row.Description;
                    BA.Industry = row.Industry;
                    BA.CustomerType = row.Customer_Type__c;
                    BA.VatReg = row.Tax_Reg_Number__c;
                    BA.BranchId = row.Branch_ID__c;
                    BA.AccountCurrency = row.CurrencyIsoCode;
                    BA.Subsidiary = row.Subsidiary__r.NS_Subsidiary_Internal_ID__c;
                    BA.BillStreet = row.BillingStreet;
                    BA.BillCity = row.BillingCity;
                    BA.BillState = row.BillingState;
                    BA.BillPostal = row.BillingPostalCode;
                    BA.BillCountry = row.BillingCountry;
                    BA.ShipStreet = row.ShippingStreet;
                    BA.ShipCity = row.ShippingCity;
                    BA.ShipState = row.ShippingState;
                    BA.ShipPostal = row.ShippingPostalCode;
                    BA.ShipCountry = row.ShippingCountry;
                    BA.BillAddressee = row.name;
                    BA.ShipAddressee = row.name;
                    if(String.isNotBlank(row.NetSuite_Id__c))
                        BA.NetSuiteId = row.NetSuite_Id__c;
                }
                //BusinessAccountContacts[] BAC = new BusinessAccountContacts[] {};
                for(Contact rowc : B2BContacts){
                    BusinessAccountContacts BAC = new BusinessAccountContacts();
                    BAC.ContactId = rowc.id;
                    BAC.Title = rowc.Title;
                    BAC.MobilePhone = rowc.MobilePhone;
                    BAC.WorkPhone = rowc.Phone;
                    BAC.MobilePhone2 = rowc.HomePhone;
                    BAC.LastName = rowc.LastName;
                    BAC.FirstName = rowc.FirstName;
                    BAC.Fax = rowc.Fax;
                    BAC.Email = rowc.Email;
                    BAC.Comments = rowc.Description;
                    BAC.Company = rowc.accountid;
                    BAC.Subsidiary = rowc.Subsidiary__r.NS_Subsidiary_Internal_ID__c;
                    BAC.BillCountry = rowc.MailingCountry;
                    BAC.BillPostal = rowc.MailingPostalCode;
                    BAC.BillState = rowc.MailingState;
                    BAC.BillCity = rowc.MailingCity;
                    BAC.BillStreet = rowc.MailingStreet;
                    BAC.NetSuiteId = rowc.NetSuite_Id__c;
                    BACL.EntryList.add(BAC); 
                }
                BA.RecordContact = BACL;
                BAPayload.type = 'B2BAccount';
                BAPayload.record = BA;
            }
            
            OAL.count = attcount;
            OPR.AccRec = BAPayload;
            OPR.deposit = OD;
            OPR.line = OIL;
            OPR.att = OAL;
            OPR.offpaylist = OFPL;
            OC.NewRecord = OPR;
            OC.RecordSplit = OSL;
            OC.action = 'OptyRec';
            SONSPayload.type = 'OpptySync';
            SONSPayload.record = OC;
            if(Limits.getHeapSize() > Limits.getLimitHeapSize()){
                throw new applicationException('Heap Size Exceeded');
            }
            string request = system.JSON.serialize(SONSPayload);
            
            Integer retryCount = 0;
            do{
                res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,request,'POST',true,false,null,null);
                if(!Test.isRunningTest() && res.getStatusCode() <> 200) {
                    errorResponse = res.getBody();
                }  
                retryCount += 1;
            }while(res.getStatusCode() <> 200 && retryCount <3);
            
            
            Opportunity OptyRec_error = [Select id, NetSuite_Sync_Error__c,Outbound_Sync_Error__c  from Opportunity where id =:OptyId];    
            if(errorResponse != ''){
                OptyRec_error.NetSuite_Sync_Error__c = errorResponse;
                OptyRec_error.Sync_To_NetSuite__c = false; 
            }
            else{
                OptyRec_error.NetSuite_Sync_Error__c = '';
                OptyRec_error.Sync_To_NetSuite__c = false;
            }
            update OptyRec_error;
        } catch(Exception e) {
            errorResponse =  e.getMessage();
            
            if(errorResponse != ''){
                Opportunity OptyRec_error = [Select id, NetSuite_Sync_Error__c,Sync_To_NetSuite__c, Attachment_Limit_Exceeded__c from Opportunity where id =:OptyId];
                OptyRec_error.NetSuite_Sync_Error__c = errorResponse;
                if(errorResponse == 'Heap Size Exceeded'){
                    OptyRec_error.Attachment_Limit_Exceeded__c = true;
                }
                OptyRec_error.Sync_To_NetSuite__c = false;
                update OptyRec_error;
            }
            system.debug('error' + errorResponse + ' at ' + e.getLineNumber());
        }
    }
    
    public static integer RunCtr() {
        if(ctrRun == 1){
            ctrRun = ctrRun + 1;
            return ctrRun;
        }
        else{
            ctrRun = ctrRun + 1;
            return ctrRun;
        }
    }
    
    private static boolean firstNSCall = true;
    public static boolean isFirstNSCall() {
        if (firstNSCall) {
            firstNSCall = false;
            return true;
        } else {
            return firstNSCall;
        }
    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    public class applicationException extends Exception {}
    
    /*------------------------------------------------------------
Author      : Whisnu Satriya Wardhana
Company     : Viseo Asia PTE LTD
Description : to update Discount accordingly to the new PG Tenure
input       : List<Opportunity> listOpp, map<Id, Opportunity> mapOppOld
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/    
    public static void updatePgTenureBonus(List<Opportunity> listOpp, map<Id, Opportunity> mapOppOld) {
        list<Id> listOppId = new list<Id>();
        for (Opportunity row: listOpp) {
            if (row.PG_Tenure__c!=null && row.StageName=='Proposal' && (string.isBlank(row.Approval_Status__c) || row.Approval_Status__c=='Discount Approval Rejected') && row.PG_Tenure__c != mapOppOld.get(row.Id).PG_Tenure__c) {
                listOppId.add(row.Id);
            }
        }
        if (listOppId.size()>0) {
            map<string, set<decimal>> mapCountryTenure = new map<string, set<decimal>>();
            set<decimal> setTenure;
            list<decimal> listTenure;
            list<string> listCriteria = new list<string>();
            string stringTenure;
            integer idx = 0;
            map<string, list<integer>> mapOfOppIdx = new map<string, list<integer>>();
            list<integer> listOfOppIdx;
            list<OpportunityLineItem> listOppLineItem = [select Id, Opportunity.PG_Tenure__c, Opportunity.Country__c, Discount__c from OpportunityLineItem where OpportunityId in :listOppId and Discount_Reason__c='Loyalty Discount'];
            
            if(listOppLineItem.size() > 0) {
                // Using Country + PG_Tenure as the index of mapOfOppIdx
                for (OpportunityLineItem row: listOppLineItem) {
                    setTenure = new set<decimal>();
                    listOfOppIdx = new list<integer>();
                    if (mapCountryTenure.keySet().contains(row.Opportunity.Country__c)) {
                        setTenure = mapCountryTenure.get(row.Opportunity.Country__c);
                        listOfOppIdx = mapOfOppIdx.get(row.Opportunity.Country__c+string.valueOf(row.Opportunity.PG_Tenure__c));
                    }
                    setTenure.add(row.Opportunity.PG_Tenure__c);
                    mapCountryTenure.put(row.Opportunity.Country__c, setTenure);
                    listOfOppIdx.add(idx);
                    mapOfOppIdx.put(row.Opportunity.Country__c+string.valueOf(row.Opportunity.PG_Tenure__c), listOfOppIdx);
                    idx++;
                }
                
                for (string row: mapCountryTenure.keySet()) {
                    listTenure = new list<decimal>(setTenure);
                    stringTenure = string.join(listTenure, ',');
                    listCriteria.add('(Campaign__r.Country__c =\''+row+'\' and PG_Tenure__c in ('+stringTenure+'))');
                }
                system.debug(listCriteria);
                list<Loyalty__c> listLoyalty = database.query('select Name, Campaign__c, Campaign__r.Name, Campaign__r.Country__c, Discount_Percentage__c, PG_Tenure__c from Loyalty__c where Campaign__r.IsActive=true and '+(listCriteria.size()>1?'('+string.join(listCriteria, ' or ')+')':listCriteria[0]));
                if(listLoyalty.size() > 0) {
                    for (Loyalty__c row: listLoyalty) {
                        // Using Country + PG_Tenure as the index of mapOfOppIdx
                        if (mapOfOppIdx.keySet().contains(row.Campaign__r.Country__c+string.valueOf(row.PG_Tenure__c))) {
                            for (integer oppLineIdx: mapOfOppIdx.get(row.Campaign__r.Country__c+string.valueOf(row.PG_Tenure__c))) {
                                listOppLineItem.get(oppLineIdx).Discount__c = row.Discount_Percentage__c;
                            }
                        }
                    }
                    update listOppLineItem;
                }
                
            }
        }
    }
    public static void updateAgentProRate(Opportunity opp){
        /*if(opp.Order_Type_Clone__c  == 'Contract - Upgrade'){
Account acc = new Account(id = opp.AccountId, Pro_Rate_Amount__c = opp.Pro_Rate__c);
update acc;
}else */
        if(opp.Count_of_Subscription_Item_new__c >0){
            Account acc = new Account(id = opp.AccountId, Pro_Rate_Amount__c = opp.Pro_Rate__c);
            update acc;
        }
    }
    public static void submitB2BApproval(Opportunity newOpp,Opportunity oldOpp){
        if((newOpp.Approval_Status__c=='Product Owner Approved' || newOpp.Approval_Status__c=='Director Approved' ||newOpp.Approval_Status__c=='Country Manager Approved')&& newOpp.Approval_Status__c != oldOpp.Approval_Status__c){
            // Create an approval request for the Opportunity
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval automatically using Trigger');
            req1.setObjectId(newOpp.id);
            req1.setSubmitterId(newOpp.OwnerId);
            // Submit the approval request for the Opportunity
            try{
                Approval.ProcessResult result = Approval.process(req1);
            }catch(Exception exp){ 
                system.debug('-exp-'+exp);
            }
        }
    }
    
    public static void updateAccountnextSubsDate (Opportunity oldOpp, Opportunity newOpp) {
        Date startDate;
        Date approvedDate;
        
        //To check if stageName is changed to Closed Won 
        if( newOpp.stageName == 'closed won' || newOpp.StageName == 'Converted')//oldOpp.stageName != 'closed won' &&
        { 
            if(newOpp.stageName == 'closed won' && newOpp.OMC_Approved_Date__c!=null) {
                approvedDate =date.newInstance(newOpp.OMC_Approved_Date__c.year(),newOpp.OMC_Approved_Date__c.Month(),
                                               newOpp.OMC_Approved_Date__c.Day());
            } else if (newOpp.StageName == 'Converted' && newOpp.OMC_Approved_Date__c == null) {
                approvedDate =newOpp.CloseDate;
            }
            
            Opportunity opp = [select id,Name,OMC_Approved_Date__c,AccountId,
                               (select id, SNo__c, OpportunityId,Start_date__c 
                                from OpportunityLineItems where  SNO__c != null AND
                                Product2.Product_Category__c='Subscription' Order By SNO__c ASC) 
                               from Opportunity where id =: newOpp.id];
            
            if(opp.OpportunityLineItems.size() > 1){
                //check for lowest Integer SNO
                OpportunityLineItem oli = BatchToUpdateNextSubscriptionActivation.getOLIwithLowestSnoWhole(opp.OpportunityLineItems);
                //DEPENDENY of field Actual start date (Actual_Start_Date__c on OLI)
                //Please update logic below if there is any change in Actual_Start_Date__c.
                if(oli != null){
                    if(oli.Start_Date__c > approvedDate ){
                        startDate=  oli.Start_date__c; 
                    }
                    else {
                        startDate=  approvedDate;
                    }
                }
            }
            if(startDate !=null){       
                //set Next Subscription Activation Date for all the accounts whose oppty is closed won with above conditions.
                Account acc = [select id,Next_Subscription_Activation_Date__c
                               from Account where Id =: newOpp.AccountId 
                               and RecordType.developerName = 'Agent' ];
                if(acc.Next_Subscription_Activation_Date__c == null || (acc.Next_Subscription_Activation_Date__c != null && acc.Next_Subscription_Activation_Date__c < startDate)) {
                    acc.Next_Subscription_Activation_Date__c = startDate;
                    update acc;
                }
            }
        }
    }
    public static void changeCampaignMemberStatus(List<Opportunity> opportunityList,Map<Id,Opportunity> oldMap){
        Map<Id,Set<Id>> oppIdsVsPromoMechanics = new Map<Id,Set<Id>>();
        Set<Id>  promoMechanicIds = new Set<Id>();
        Set<String> opportunityIdsList = new Set<String>();
        map<id,id> pmIdVsCampId = new map<id,id>();
        map<id,List<CampaignMember>> cmpVsCampaignMember = new map<id,List<CampaignMember>>();
        list<Id> syncedQuoteIds = new list<id>();
        for(Opportunity op : opportunityList){
            opportunityIdsList.add(op.Id);
            if(op.StageName == 'Closed Lost' && oldMap.get(op.id).stageName == 'Closed Won' && String.isNotBlank(op.Opportunity_Type__c) && String.isNotBlank(op.SyncedQuoteId)){
                syncedQuoteIds.add(op.SyncedQuoteId);
            }
        }
        set<id> contactIds = new set<Id>();
        List<Opportunity> queryOpportunityList = [Select Id,StageName,Approval_Status__c,AccountId,Account.personcontactId from Opportunity where Id In : opportunityIdsList];
        for(OpportunityLineItem oli : [SELECT Id, OpportunityId, Opportunity.Account.PersonContactId,Promo_Mechanic_Id__c FROM OpportunityLineItem where OpportunityId In : opportunityIdsList order by OpportunityId]){
            if(String.isNotBlank(oli.Promo_Mechanic_Id__c)){
                set<Id> pmIds = new set<Id>();
                if(oli.Promo_Mechanic_Id__c.contains(',')){
                    list<Id> splitPMs = oli.Promo_Mechanic_Id__c.split(',');
                    pmIds.addAll(splitPMs);
                    if(oppIdsVsPromoMechanics.containsKey(oli.OpportunityId)){
                        oppIdsVsPromoMechanics.get(oli.OpportunityId).addAll(pmIds);
                    }else{
                        oppIdsVsPromoMechanics.put(oli.OpportunityId,pmIds);
                    }
                }else{
                    pmIds.add(oli.Promo_Mechanic_Id__c);
                    if(oppIdsVsPromoMechanics.containsKey(oli.OpportunityId)){
                        oppIdsVsPromoMechanics.get(oli.OpportunityId).addAll(pmIds);
                    }else{
                        oppIdsVsPromoMechanics.put(oli.OpportunityId,pmIds);
                    }
                    
                }
                promoMechanicIds.addAll(pmIds);
                contactIds.add(oli.Opportunity.Account.PersonContactId);
            }
        }
        List<Promo_Mechanic__c> promoMechanicList = [SELECT Id,Discount_Reason__c, Name,Campaign_Eligibility__c,Campaign_Eligibility__r.Campaign__c,Campaign_Eligibility__r.Campaign__r.EndDate,Campaign_Eligibility__r.Campaign__r.isActive,Campaign_Eligibility__r.Campaign__r.ParentId FROM Promo_Mechanic__c where Id In : promoMechanicIds];
        for(Promo_Mechanic__c pm : promoMechanicList){
            if(String.isNotBlank(pm.Discount_Reason__c) && pm.Discount_Reason__c.containsIgnoreCase('VIP')){
                if(String.isNotBlank(pm.Campaign_Eligibility__r.Campaign__r.ParentId))
                    pmIdVsCampId.put(pm.id, pm.Campaign_Eligibility__r.Campaign__r.ParentId);
            }else{
                if(String.isNotBlank(pm.Campaign_Eligibility__r.Campaign__c))
                    pmIdVsCampId.put(pm.id, pm.Campaign_Eligibility__r.Campaign__c);
            }
            
        }
        
        list<Campaign> campaignList = [Select id, (SELECT Id, CampaignId,Campaign.Name,Campaign.isActive,Campaign.EndDate, Status,ContactId FROM CampaignMembers where ContactId IN: contactIds) from Campaign where id In : pmIdVsCampId.values()];
        for(Campaign cmp : campaignList){
            cmpVsCampaignMember.put(cmp.id,cmp.CampaignMembers);
        }
        
        list<CampaignMember> CampaignMemberList = new list<CampaignMember>();
        list<CampaignMember> updateCampaignMemberList = new list<CampaignMember>();
        Set<CampaignMember> setTOupdateCampaignMemberList = new Set<CampaignMember>();
        for(Opportunity op : queryOpportunityList){
            
            
            Set<Id> pmIds = oppIdsVsPromoMechanics.get(op.id);
            if(pmIds != null && !pmIds.isEmpty()){
                for(string pmId :pmIds){
                    Id campaignId;
                    if(pmId != null){
                        campaignId = pmIdVsCampId.get(pmId);
                    }
                    if(campaignId != null) 
                        CampaignMemberList.addAll(cmpVsCampaignMember.get(campaignId));
                    
                }
            }
            
            for(CampaignMember cmp : CampaignMemberList){
                if(cmp.ContactId == op.Account.PersonContactId){
                    if(oldMap.get(op.Id).StageName == 'Proposal' && op.StageName == 'Pending Online Payment'){
                        if(cmp.Campaign.isActive == true){
                            cmp.Status = 'Responded';
                        }else if(cmp.Campaign.isActive == false && op.Approval_Status__c == 'Discount Approval Approved'){
                            cmp.Status = 'Responded';
                            op.AddError('ready for payment action should fail since Sales Person has missed the deadline to apply the promo');
                        }
                        setTOupdateCampaignMemberList.add(cmp);
                    }else if(oldMap.get(op.Id).StageName != op.StageName && op.StageName == 'Closed Won'){
                        cmp.Status = 'Utilised';
                        setTOupdateCampaignMemberList.add(cmp);
                    }else if(oldMap.get(op.Id).StageName != op.StageName && op.StageName == 'Closed Lost'){
                        if(cmp.Campaign.isActive == true){
                            cmp.Status = 'Re-eligible';
                        }else if(cmp.Campaign.isActive == false){
                            cmp.Status = 'Expired';
                        }
                        setTOupdateCampaignMemberList.add(cmp);
                    }
                }    
            }
        }
        updateCampaignMemberList.addAll(setTOupdateCampaignMemberList);
        if(!updateCampaignMemberList.isEmpty()){
            update updateCampaignMemberList;
        }
        
        if(!syncedQuoteIds.isEmpty()){
            changeCMStatusForQuote(syncedQuoteIds);
        }
    }
    public static void createCampaignInfluenceRecords(List<Opportunity> opportunityList,Map<Id,Opportunity> oldMap){
        Map<Id,Promo_Mechanic__c> idVsPromoMechanic = new Map<Id,Promo_Mechanic__c>();
        map<id,decimal> oppIdVsTotalCI = new map<id,decimal>();
        Map<Id,set<Id>> oppIdsVsPromoMechanics = new Map<Id,set<Id>>();
        Set<String> oppIdsToDeleteCIRecord = new Set<String>();
        Set<Id> promoMechanicIds = new Set<Id>();
        Set<String> opportunityIdsList = new Set<String>();
        map<id,list<CampaignMember>> CampaignIdVsCMs = new map<id,list<CampaignMember>>();
        map<id,set<id>> CampaignIdVsContacts = new map<id,set<id>>();
        list<CampaignMember> campaignMemberList = new List<CampaignMember>();
        list<CampaignMember> campaignMemberListToDelete = new List<CampaignMember>();
        set<id> contactSet = new set<id>();
        for(Opportunity op : opportunityList){
            opportunityIdsList.add(op.Id);
        }
        List<Opportunity> queryOpportunityList = [Select Id,StageName,AccountId,Account.personcontactId from Opportunity where Id In : opportunityIdsList];
        for(OpportunityLineItem oli : [SELECT Id, OpportunityId, Promo_Mechanic_Id__c FROM OpportunityLineItem where OpportunityId In : opportunityIdsList order by OpportunityId]){
            if(String.isNotBlank(oli.Promo_Mechanic_Id__c)){
                set<Id> pmIds = new set<Id>();
                if(oli.Promo_Mechanic_Id__c.contains(',')){
                    list<Id> splitPMs = oli.Promo_Mechanic_Id__c.split(',');
                    pmIds.addAll(splitPMs);
                    if(oppIdsVsPromoMechanics.containsKey(oli.OpportunityId)){
                        oppIdsVsPromoMechanics.get(oli.OpportunityId).addAll(pmIds);
                    }else{
                        oppIdsVsPromoMechanics.put(oli.OpportunityId,pmIds);
                    }
                }else{
                    pmIds.add(oli.Promo_Mechanic_Id__c);
                    if(oppIdsVsPromoMechanics.containsKey(oli.OpportunityId)){
                        oppIdsVsPromoMechanics.get(oli.OpportunityId).addAll(pmIds);
                    }else{
                        oppIdsVsPromoMechanics.put(oli.OpportunityId,pmIds);
                    }
                    
                }
                promoMechanicIds.addAll(pmIds);
            }
        }
        if(promoMechanicIds.isEmpty())
            return ;
        List<Promo_Mechanic__c> promoMechanicList = [SELECT Id, Name,Campaign_Eligibility__c,Campaign_Eligibility__r.Campaign__c,Campaign_Eligibility__r.Campaign__r.EndDate,Campaign_Eligibility__r.Campaign__r.isActive FROM Promo_Mechanic__c where Id In : promoMechanicIds];
        if(promoMechanicList.isEmpty())
            return;
        
        for(Promo_Mechanic__c pm : promoMechanicList){
            idVsPromoMechanic.put(pm.id, pm);
        }
        List<CampaignMember> createCampaignMember = new List<CampaignMember>();
        List<CampaignInfluence> createCampaignInfluence = new List<CampaignInfluence>();
        String modeId = [SELECT Id, DeveloperName FROM CampaignInfluenceModel where DeveloperName = 'primaryModel'].Id;
        for(Opportunity op : queryOpportunityList){
            if(oppIdsVsPromoMechanics.containsKey(op.id)){
                for(Id pmID : oppIdsVsPromoMechanics.get(op.Id)){
                    if(idVsPromoMechanic.containsKey(pmID)){
                        decimal totalInfluenceToBeCreated = (50/idVsPromoMechanic.values().size());
                        Promo_Mechanic__c pm = idVsPromoMechanic.get(pmID);
                        if(oldMap.get(op.Id).StageName != op.StageName && op.StageName == 'Closed Won'){
                            if(oppIdVsTotalCI.containsKey(op.id)){
                                oppIdVsTotalCI.put(op.id,oppIdVsTotalCI.get(op.id)+1);
                                createCampaignMember.add(New CampaignMember(CampaignId=pm.Campaign_Eligibility__r.Campaign__c, ContactId= op.Account.personcontactId, Status='Utilised'));
                                createCampaignInfluence.add(new CampaignInfluence(OpportunityId=op.Id,CampaignId=pm.Campaign_Eligibility__r.Campaign__c,ModelId=modeId));
                            }else{
                                createCampaignMember.add(New CampaignMember(CampaignId=pm.Campaign_Eligibility__r.Campaign__c, ContactId= op.Account.personcontactId, Status='Utilised'));
                                createCampaignInfluence.add(new CampaignInfluence(OpportunityId=op.Id,CampaignId=pm.Campaign_Eligibility__r.Campaign__c,ModelId=modeId));
                                oppIdVsTotalCI.put(op.id, 1);
                            }
                            
                            
                        }else if(oldMap.get(op.Id).StageName == 'Closed Won' && op.StageName == 'Closed Lost'){
                            oppIdsToDeleteCIRecord.add(op.Id); 
                        }
                    }
                }
            }
        }
        for(CampaignInfluence CI : createCampaignInfluence){
            decimal size = oppIdVsTotalCI.get(CI.OpportunityId);
            CI.Influence = 50/Size;
        }
        
        if(!createCampaignMember.isEmpty())
            Database.insert(createCampaignMember,false);
        
        if(!createCampaignInfluence.isEmpty())
            system.enqueueJob(new createCampaignInfluenceClass(createCampaignInfluence));
        
        
        if(!oppIdsToDeleteCIRecord.isEmpty()){
            List<CampaignInfluence> deleteCampaignInfluenceList = [SELECT Id, OpportunityId,Opportunity.Account.PersonContactId,CampaignId FROM CampaignInfluence where OpportunityId In :oppIdsToDeleteCIRecord];
            for(CampaignInfluence CI : deleteCampaignInfluenceList){
                if(CampaignIdVsContacts.containsKey(CI.campaignId)){
                    CampaignIdVsContacts.get(CI.campaignId).add(CI.Opportunity.Account.PersonContactId);
                }else{
                    CampaignIdVsContacts.put(CI.campaignId,new set<id>{CI.Opportunity.Account.PersonContactId});
                    contactSet.add(CI.Opportunity.Account.PersonContactId);
                }
            }
            
            if(!deleteCampaignInfluenceList.isEmpty() && deleteCampaignInfluenceList != null)
                delete deleteCampaignInfluenceList;
        }
        campaignMemberList = [Select id,ContactId,CampaignId,Status from CampaignMember where CampaignId in: CampaignIdVsContacts.keySet() and ContactId in : contactSet AND Status = 'Utilised'];
        for(CampaignMember CM : campaignMemberList){
            if(CampaignIdVsContacts.containsKey(CM.campaignId) && CampaignIdVsContacts.get(CM.campaignId).contains(CM.contactId)){
                campaignMemberListToDelete.add(CM);
            }
        }
        if(!campaignMemberListToDelete.isEmpty()){
            Delete campaignMemberListToDelete;
        }
        
    }
    public static void closeTaskStatus(List<Opportunity> opportunityList,Map<Id,Opportunity> oldMap){
        
        Set<String> opportunityidsSet = new Set<String>();
        for(Opportunity ts : opportunityList){
            opportunityidsSet.add(ts.Id);
        }
        
        List<Task> updateTask = new List<Task>();
        for(Opportunity op : [Select Id,Name,StageName,Order_Type_Clone__c ,Opportunity_Type__c,(Select Id, Subject, Status FROM Tasks where Subject Like 'Followup VIP Package' AND Status = 'Open') from Opportunity where Id IN : opportunityidsSet AND (Order_Type_Clone__c  = 'Contract - Renewal' OR Opportunity_Type__c = 'B2C - Renewal')]){
            if(!op.Tasks.isEmpty() && op.Tasks != null)
                for(Task ts : op.Tasks){
                    if(oldMap.get(op.Id).StageName != op.StageName && (op.StageName == 'Closed Won' || op.StageName == 'Closed Lost'))
                        updateTask.add(new Task(Id = ts.Id,Status='Completed'));    
                }
        }
        if(!updateTask.isEmpty())
            update updateTask;
    }
    //Method having criteria to implement primary B2B campaign Logic   
    public static void updatePrimCampB2B(List<Opportunity> newOpp,Map<Id,Opportunity> oldOpp){  
        Map<ID,ID> mapOppIdAccId=new Map<Id,ID>();  
        Id B2BrecTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();  
        For(Opportunity each : newOpp){  
            If(each.RecordTypeId ==B2BrecTypeId && each.StageName!=oldOpp.get(each.id).stageName && each.StageName=='Pending Client Signatory' && (each.CampaignId==null || each.CampaignId=='')){  
                mapOppIdAccId.put(each.ID,each.AccountId);  
            }  
        }  
        if(mapOppIdAccId.size()>0){  
            //calling future method for update  
            B2BPrimaryCampUpdateLogic.methodB2BCampaign(mapOppIdAccId);  
        }  
    }
    public static void validateDelete(list<opportunity> deleteOpportunityList){
        String b2b=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        String b2c =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        for(opportunity opp :deleteOpportunityList ){
            if(opp.RecordTypeId ==B2C && opp.StageName=='Closed Won' ){
                Trigger.oldMap.get(opp.Id).adderror('Cannot delete the Closed Won opportunity');
            }
            if(opp.RecordTypeId == b2b){
                Trigger.oldMap.get(opp.Id).adderror('Cannot delete B2B opportunity');
                
            }
            
        }
        
    }
    public static void updateOMCRejectedReason (List<Opportunity> NewOppList, Map<Id, Opportunity> oldMapOpp) {
        Map<Id,String> OppRejectReason = new Map<Id,String>();
        String b2cCloseLost =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Closed Lost').getRecordTypeId();
        String b2b=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        String b2c =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        for (ProcessInstanceStep rowApproval : [SELECT ProcessInstance.TargetObjectId, StepStatus, comments  
                                                FROM ProcessInstanceStep 
                                                WHERE ProcessInstance.TargetObjectId =:oldMapOpp.KeySet() 
                                                AND stepStatus='Rejected' order by CreatedDate desc limit 1]) {
                                                    OppRejectReason.put(rowApproval.ProcessInstance.TargetObjectId,rowApproval.comments);
                                                }           
        for(Opportunity Op : NewOppList) {
            system.debug('handleOMCRejectReason !!'); 
            if (Op.Approval_Status__C <> oldMapOpp.get(Op.id).Approval_Status__c && Op.Approval_Status__C == 'OMC Approval Rejected' && (op.recordtypeId==b2b || op.recordtypeId==b2c || op.recordtypeId==b2cCloseLost)) {
                Op.OMC_Rejected_Reason__c = OppRejectReason.get(Op.Id);
            } 
        }     
    }
    
    public static void changeCMStatusForQuote(list<id> syncedQuoteIds){
        
        list<Quote> quoteList = [Select id from Quote where Id IN : syncedQuoteIds];
        Map<Id,string> quoteIdsVsPromoMechanics = new Map<Id,string>();
        Set<String> promoMechanicIds = new Set<String>();
        Set<String> quoteIdsList = new Set<String>();
        Set<Id> personContactId = new Set<Id>();
        map<id,id> pmIdVsCampId = new map<id,id>();
        map<id,List<CampaignMember>> cmpVsCampaignMember = new map<id,List<CampaignMember>>();
        for(Quote quo : quoteList){
            quoteIdsList.add(quo.Id);
        }
        List<Quote> queryQuoteList = [Select Id,Status,Approval_Status__c,AccountId,Account.personcontactId from Quote where Id In : quoteIdsList];
        for(QuoteLineItem qli : [SELECT Id, QuoteId, Quote.Account.PersonContactId, Promo_Mechanic_Id__c FROM QuoteLineItem where QuoteId In : quoteIdsList order by QuoteId]){
            
            personContactId.add(qli.Quote.Account.PersonContactId);
            if(String.isNotBlank(qli.Promo_Mechanic_Id__c) && !quoteIdsVsPromoMechanics.containsKey(qli.QuoteId)){
                promoMechanicIds.add(qli.Promo_Mechanic_Id__c);
                quoteIdsVsPromoMechanics.put(qli.QuoteId,qli.Promo_Mechanic_Id__c);
                continue;
                
            }
        }
        
        List<Promo_Mechanic__c> promoMechanicList = [SELECT Id,Discount_Reason__c, Name,Campaign_Eligibility__c,Campaign_Eligibility__r.Campaign__c,Campaign_Eligibility__r.Campaign__r.EndDate,Campaign_Eligibility__r.Campaign__r.isActive,Campaign_Eligibility__r.Campaign__r.ParentId FROM Promo_Mechanic__c where Id In : promoMechanicIds];
        for(Promo_Mechanic__c pm : promoMechanicList){
            if(String.isNotBlank(pm.Discount_Reason__c) && pm.Discount_Reason__c.containsIgnoreCase('VIP')){
                if(String.isNotBlank(pm.Campaign_Eligibility__r.Campaign__r.ParentId))
                    pmIdVsCampId.put(pm.id, pm.Campaign_Eligibility__r.Campaign__r.ParentId);
            }else{
                if(String.isNotBlank(pm.Campaign_Eligibility__r.Campaign__c))
                    pmIdVsCampId.put(pm.id, pm.Campaign_Eligibility__r.Campaign__c);
            }
            
        }
        
        list<Campaign> campaignList = [Select id, (SELECT Id, CampaignId,Campaign.Name,Campaign.isActive,Campaign.EndDate, Status,ContactId FROM CampaignMembers where ContactId In : personContactId limit 50000) from Campaign where id In : pmIdVsCampId.values()];
        for(Campaign cmp : campaignList){
            cmpVsCampaignMember.put(cmp.id,cmp.CampaignMembers);
        }
        
        list<CampaignMember> CampaignMemberList = new list<CampaignMember>();
        list<CampaignMember> updateCampaignMemberList = new list<CampaignMember>();
        for(Quote quo : queryQuoteList){
            
            
            Id pmId = quoteIdsVsPromoMechanics.get(quo.id);
            Id campaignId;
            if(pmId != null)
                campaignId = pmIdVsCampId.get(pmId);
            
            if(campaignId != null) 
                CampaignMemberList = cmpVsCampaignMember.get(campaignId);
            
            for(CampaignMember cmp : CampaignMemberList){
                if(cmp.ContactId == quo.Account.PersonContactId){
                    
                    if(cmp.Campaign.isActive == true){
                        cmp.Status = 'Re-eligible';
                    }else if(cmp.Campaign.isActive == false){
                        cmp.Status = 'Expired';
                    }
                    updateCampaignMemberList.add(cmp);
                    
                }    
            }
        }
        if(!updateCampaignMemberList.isEmpty())
            update updateCampaignMemberList;
        
    }
    
    // to check if owner is updated from users with same role or it's sub-ordinates in the role hierarchy
    public static void checkOwnerUpdate(Map<id,Opportunity> newMap,Map<id,Opportunity> oldMap){
        string b2cRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        set<String> ownerIDList = new set<String>();
        set<String> parentIdList = new set<String>();
        for(String OppId: newMap.keySet()){
            ownerIDList.add(newMap.get(OppId).ownerId);
        }
        
        // map contains child role id and parent role id
        Map<String,String> roleHierarchy = new  Map<String,String>();
        List<String> allowUser = new List<String>();
        if(Label.PG_LABEL_AllowOpptyOwnerChange != null && !String.isBlank(Label.PG_LABEL_AllowOpptyOwnerChange)){
            
            allowUser.addAll(Label.PG_LABEL_AllowOpptyOwnerChange.split(';'));
        }
        
        if(!allowUser.contains(userInfo.getUserId())){
            for( UserRole ur : [SELECT Id, Name, ParentRoleId FROM userrole where parentRoleID!= null]){
                roleHierarchy.put(ur.id,ur.parentRoleId);
                parentIdList.add(ur.ParentRoleId);
            }
            //current user role id
            String currUserRole = UserInfo.getUserRoleId();
            Boolean inHierarchy= false;
            ownerIDList.add(userInfo.getUserId());
            
            //map contains opp owner id and roleid
            Map<String,User> ownerMap=new map<String,User>([select id,userroleid,profile.name ,UserRole.DeveloperName  from user where id in: ownerIDList]);
            List<String> listOfRolesNames = new List<String>();
            
            if(Label.ALLOW_OPP_OWNER_UPDATE != null){
                listOfRolesNames.addAll(Label.ALLOW_OPP_OWNER_UPDATE.split(';'));
            }
            if(!listOfRolesNames.contains(ownerMap.get(userInfo.getUserId()).UserRole.DeveloperName )){
                
                for(String Oppid: newMap.keySet() ){
                    //check if oppty is b2c
                    if(newMap.get(oppId).recordtypeId == b2cRectype 
                       && ownerMap.get(userInfo.getUserId()).Profile.name != 'System Administrator'
                       && ownerMap.get(userInfo.getUserId()).Profile.name != 'Delegated System Administrator'
                       && ownerMap.get(userInfo.getUserId()).Profile.name != 'API User Profile') {
                           //check if owner is changed
                           if( newMap.get(oppid).ownerid !=  oldMap.get(oppid).ownerid){
                               //check if currentUser is parent
                               if(parentIdList.contains(currUserRole)){
                                   //check if current user's role and assigned owner role is different
                                   if(ownerMap.get(newMap.get(oppId).ownerId).userroleid != currUserRole){
                                       String newOwner =ownerMap.get(newMap.get(oppId).ownerId).userroleid;
                                       
                                       while(roleHierarchy.containsKey(newOwner)){
                                           if(newOwner == currUserRole){
                                               inHierarchy= true;
                                               break;
                                           }
                                           newOwner=roleHierarchy.get(newOwner);
                                           
                                       }
                                       if(!inHierarchy){
                                           Trigger.newMap.get(oppId).adderror('You don\'t have access to update the owner');
                                       }
                                   }
                               }
                               else {
                                   Trigger.newMap.get(oppId).adderror('You don\'t have access to update the owner');
                               }
                           }
                       }
                }
            }
        }
    }
    
    // to check B2C Opportunity stage Name is changed by User
    public static void restrictB2CStageName(List<Opportunity> newOpp,Map<id,Opportunity> oldMap){
        string b2cRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId(); 
        List<String> allowUser = new List<String>();
        if(Label.PG_LABEL_AllowedB2COppStageChange   != null && !String.isBlank(Label.PG_LABEL_AllowedB2COppStageChange )){
            allowUser.addAll(Label.PG_LABEL_AllowedB2COppStageChange.split(';'));
        }
        if(!allowUser.contains(userInfo.getUserId()) && PGOpportunityTriggerHandler.allowOppstageChange){
            for(Opportunity each: newOpp){
                if(each.RecordTypeId==b2cRectype && !each.isBulkUpdate__c && each.StageName != oldMap.get(each.Id).StageName && (each.StageName=='Pending Online Payment' || each.StageName=='Pending Client Signatory' ||each.StageName=='Closed Won')){
                    each.adderror('You are not allowed to directly change Opportunity Stage.');
                }
            }
        }
        
    }
    
    public static void killSO(Map<Id,Opportunity> newOppMap,Map<Id,Opportunity> oldOppMap){
        // isFirstTimeSOKill = false
        Map<id,Opportunity> killSOOpp = new Map<id,Opportunity>();
        Id B2BrecTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();  
        for( String oppId: newOppMap.keySet()){
            if(newOppMap.get(oppId).RecordtypeId == B2BrecTypeId)
                if(newOppMap.get(oppId).stageName == 'Closed Lost' && oldOppMap.get(oppId).stageName != 'Closed Lost'){
                    killSOOpp.put(oppId,newOppMap.get(oppId));
                }
        }
        List<csmso__Sales_Order__c> soList = new List<csmso__Sales_Order__c>();
        List<csmso__Sales_Order__c> soPrimaryList = new List<csmso__Sales_Order__c>();
        if(!killSOOpp.isEmpty()){
            for(csmso__Sales_Order__c so: [Select id,Primary_Sales_Order__c from csmso__Sales_Order__c 
                                           where csmso__opportunity__c in: killSOOpp.keySet()]){
                                               if(so.Primary_Sales_Order__c){
                                                   soPrimaryList.add(so);
                                               }
                                               so.Reason_for_Cancellation__c = 'Others';
                                               update so;
                                               //soList.add(so);
                                               ButtonSOKill button = new ButtonSOKill();
                                               button.performAction(so.id);
                                               
                                           } 
        }
        
    }
    
    public static void validationOnBillingAddress(list<Opportunity> newOpp, Map<Id,Opportunity> newOppMap, Map<Id,Opportunity> oldOppMap){
        Boolean isFamily;
        Map<Id,Id> BillingToAccMap = new Map<Id,Id>();
        Set<Id> billingAddress = new Set<Id>();
        for(Opportunity op: newOpp){
            billingAddress.add(op.Billing_Address__c);   
        }
        Id B2BrecTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();  
        
        list<Address__c> AddList =[Select id,Account__c From Address__c WHERE ID IN : billingAddress];
        for(Address__c addr: AddList){
            BillingToAccMap.put(addr.id,addr.Account__c);
        }
        for(Opportunity op: newOpp){
            if(newOppMap != null && oldOppMap != null){
                // Check Billing Address
                if(op.RecordTypeId == B2BrecTypeId && op.Billing_Address__c != null && oldOppMap.get(op.Id).Billing_Address__c != newOppMap.get(op.Id).Billing_Address__c){
                    isFamily = Print_ContractV2_cc.getChildHierarchy(BillingToAccMap.get(op.Billing_Address__c) ,op.AccountId);
                    
                    if(op.StageName == 'Closed Won'){
                        op.StageName.addError(System.label.Update_Billing_Address_with_Stage);
                    }
                    if(isFamily==False){
                        op.Billing_Address__c.addError(System.label.Opportunity_s_Billing_Address_Account_Family);
                    }
                }
                
                // Check b2b Billing Contact
               /* if(op.RecordTypeId == B2BrecTypeId && op.b2b_Billing_Contact__c != null && oldOppMap.get(op.Id).b2b_Billing_Contact__c != newOppMap.get(op.Id).b2b_Billing_Contact__c){
                    if(op.StageName == 'Closed Won'){
                        op.b2b_Billing_Contact__c.addError(System.label.Update_b2b_Billing_Contact_with_Stage);
                    }
                }
                // Check Billing Entity
                if(op.RecordTypeId == B2BrecTypeId && op.Billing_Entity__c != null && oldOppMap.get(op.Id).Billing_Entity__c != newOppMap.get(op.Id).Billing_Entity__c){
                    if(op.StageName == 'Closed Won'){
                        op.Billing_Entity__c.addError(System.label.Update_Billing_Entity);
                    }
                }*/
                
                // Check Billing Entity Suffix
                if(op.RecordTypeId == B2BrecTypeId && op.Billing_Entity_Suffix__c != null && oldOppMap.get(op.Id).Billing_Entity_Suffix__c != newOppMap.get(op.Id).Billing_Entity_Suffix__c){
                    if(op.StageName == 'Closed Won'){
                        op.Billing_Entity_Suffix__c.addError(System.label.Update_Billing_Entity_Suffix_with_Stage);
                    }
                }
            }
            else{
                if(op.RecordTypeId == B2BrecTypeId && op.Billing_Address__c != null){
                    isFamily = Print_ContractV2_cc.getChildHierarchy(BillingToAccMap.get(op.Billing_Address__c),op.AccountId);
                    System.debug('$$$$'+isFamily);
                    if(isFamily==False){
                        op.Billing_Address__c.addError(System.label.Opportunity_s_Billing_Address_Account_Family);
                    }
                }
            }
            
        }
    }
    
}
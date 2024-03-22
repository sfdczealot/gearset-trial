public class PGAccountSync {
    
    static string errorResponse = '' ;
    
    public String status;
    public String ns_internalid;
    
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
    
    public static void updateAccountNS(list<account> acc, map<id,Account> OldMapAcc){
        boolean GoB2B = false, GoB2C = false;  
        system.debug('UPDATES NS ACCOUNT');
        list<id> AccIDB2B = new list<id>();
        Map<String,String> MapAccRT = new Map<String,String>();    
        for (RecordType rt : [SELECT Id,Name FROM RecordType WHERE SObjectType='Account']){
            MapAccRT.put(rt.Name,rt.Id);
        }
        for(Account ac : [select id,name,recordtype.id,NetSuite_Id__pc,AgentNet_ID__c from account where id in: Acc]){
            if(ac.RecordTypeid == MapAccRT.get('Agency') || ac.RecordTypeid == MapAccRT.get('B2B - Account')){
                if(Test.isRunningTest() && ac.name.containsIgnoreCase('Unit Test Agency') ) {
                    System.debug('Skipping trigger as this is created by tests');
                } else {
                    GoB2B = true;
                    AccIDB2B.add(ac.id);
                }
            }
        }
        if(AccIDB2B.size()>0){
            if(GoB2B == true){
                afterInsertB2B(AccIDB2B);
                System.debug('User B2B Found');
            }
        }
    }
    
    public static void insertAccountNS(list<account> acc){
        boolean GoB2B = false, GoB2C = false;  
        system.debug('CREATE NS ACCOUNT');
        list<id> AccIDB2B = new list<id>();
        list<id> AccIDB2C = new list<id>();
        Map<String,String> MapAccRT = new Map<String,String>();    
        for (RecordType rt : [SELECT Id,Name FROM RecordType WHERE SObjectType='Account']){
            MapAccRT.put(rt.Name,rt.Id);
        }
        for(Account ac : [select id,name,recordtype.id,NetSuite_Id__pc,AgentNet_ID__c from account where id in: Acc]){
            if(ac.NetSuite_Id__pc == null ){
                if(ac.RecordTypeid== MapAccRT.get('Agency') || ac.RecordTypeid == MapAccRT.get('B2B - Account')){
                    if(Test.isRunningTest() && ac.name.containsIgnoreCase('Unit Test Agency') ) {
                        System.debug('Skipping trigger as this is created by tests');
                    } else {
                        GoB2B = true;
                        AccIDB2B.add(ac.id);
                    }
                }
            }
        }
        if(AccIDB2B.size()>0){
            if(GoB2B == true){
                afterInsertB2B(AccIDB2B);
                System.debug('User B2B Found');
            }
        }
    }

    @future(callout = true)
    public static void afterInsertB2B(list<id> Acc){
        
        errorResponse='';
        map<string,string> reqHeaders = new map<string,string>();
        HttpResponse res;
        String RootEndpoint, RootEndpoint_Key;
        
        if (runningInASandbox()) {
            RootEndpoint = label.PG_LABEL_PG_NetSuite_Billing_Sync_SB; 
            RootEndpoint_Key = label.PG_LABEL_PG_NetSuite_Billing_Sync_Cred_SB;
        }
        else{
            RootEndpoint = label.PG_LABEL_PG_NetSuite_Billing_Sync;
            RootEndpoint_Key = label.PG_LABEL_PG_NetSuite_Billing_Sync_Cred; 
        }

        try{
            
            reqHeaders.put('Content-Type', 'application/json');
            reqHeaders.put('Cache-Control', 'no-cache');
            reqHeaders.put('Authorization', RootEndpoint_Key);
            
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
                                                    id  =: Acc
                                        ];
            List <Contact> B2BContacts = [
                                            select
                                                    id,Title,MobilePhone,Phone,HomePhone,LastName,FirstName,Fax,Email,Description,Subsidiary__r.NS_Subsidiary_Internal_ID__c,
                                                    MailingCountry,MailingPostalCode,MailingCity,MailingState,MailingStreet,accountid, NetSuite_Id__c
                                            from
                                                    contact
                                            where
                                                    accountid =: Acc
                                        ];
            BusinessAccountPayload BAPayload = new BusinessAccountPayload();
            BusinessAccount BA = new BusinessAccount();
            BusinessAccountContactsList BACL = new BusinessAccountContactsList();
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
            string request = system.JSON.serialize(BAPayload);
            
            res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,request,'POST',true,false,null,null);
            if(Test.isRunningTest()){
                res = new HttpResponse();
                res.setStatusCode(212);
                res.setBody('This is just a test');
            }else{
                if(res!=null){
                    if(res.getStatusCode() <> 200){
                        errorResponse = res.getBody();
                    }
                } 
            }    
        }catch(DmlException e){
            errorResponse =  e.getMessage();
            system.debug(errorResponse);
            updateSFAccount(Acc,null);   
        }
    }
    
    public static void updateSFAccount(list<id> AccID, String NSId){
        system.debug(NSId);
        system.debug(errorResponse);
        list<account> acc = [select id,last_outbound_sync__c,Outbound_Sync_Error__c,NetSuite_Sync_Error__c,NetSuite_Id__c from account where id in: AccID] ; 
        for(Account row : acc){          
            row.Last_Outbound_Sync__c = system.now();
            if(errorResponse <> ''){
                row.Outbound_Sync_Error__c = errorResponse;
                row.NetSuite_Sync_Error__c = errorResponse;
            }
            if(String.isNotBlank(NSId))
            row.NetSuite_Id__c = NSId;
        }    
        update acc;
    }
    
    public static PGAccountSync parse(String json) {
        return (PGAccountSync) System.JSON.deserialize(json, PGAccountSync.class);
    }

    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    private static boolean firstRun = true;
    public static boolean isFirstRun() {
        if (firstRun) {
            firstRun = false;
            return true;
        } else {
            return firstRun;
        }
    }
}
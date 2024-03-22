/**
@name			AmountRollUpHandler
@Description	Helper class to update the field on accoutn and oppty after closed won.
@Version 		1.0
@reference 		SF-6204
**/
public without sharing class AmountRollUpHandler {
    public final static string B2C_OPP_RECORDTYPEiD = RecordTypeSelector.getRecordTypeId('Opportunity', 'B2C');
    public final static string B2C_SS_OPP_RECORDTYPEiD = RecordTypeSelector.getRecordTypeId('Opportunity', 'B2C Self-Serve');
    
    /**
*  method to return the latest closed opportunity from accountid
*  @name fetchLatestOppty
*  @param set of accountid
*  @return map of account id to opportnity Id
*/
    public static Map<String, String> fetchLatestOppty(Set<Id> setOfAccountIds,Boolean isUpgrade) {
        List<Opportunity> listAllOpp = new List<Opportunity>();
        if(isUpgrade){
            listAllOpp = [SELECT Id, AccountId,OMC_Approved_Date__c,RecordTypeId,CloseDate,
                          (SELECT Id, Push_to_NetSuite__c FROM OpportunityLineItems WHERE
                          Product_Category__c ='Subscription' AND Complimentary__c = false AND Push_to_NetSuite__c = true)
                          FROM Opportunity
                          WHERE AccountId IN: setOfAccountIds
                          AND IsWon = true
                          AND RecordTypeId =: B2C_OPP_RECORDTYPEiD 
                          ORDER BY OMC_Approved_Date__c Desc
                         ]; 
        } else {
            listAllOpp =  fetchOpportunities(setOfAccountIds);
        }
        
        Map<String, String> mapOfResponse = new Map<String, String>();
        if(!listAllOpp.isEmpty()) {
            for(Opportunity eachOpp : listAllOpp) {
                if(!eachOpp.OpportunityLineItems.isEmpty() && !mapOfResponse.containsKey(eachOpp.AccountId)) {
                    mapOfResponse.put(eachOpp.AccountId, eachOpp.Id);
                }
            }
        }
        return mapOfResponse;
    }
    
    /**
*  method to return the Prod SKU Code of latest closed opportunity from accountid
*  @name fetchLatestOppProdSKUCode
*  @param set of accountid
*  @return map of account id to SKU Code
*/
    public static Map<String,String> fetchLatestOppProdSKUCode(Set<Id> setOfAccountIds) {
        List<Opportunity> listAllOpp = fetchOpportunities(setOfAccountIds);
        Map<String, String> mapOfResponse = new Map<String, String>();
        if(!listAllOpp.isEmpty()) {
            for(Opportunity eachOpp : listAllOpp) {
                if(!eachOpp.OpportunityLineItems.isEmpty() && !mapOfResponse.containsKey(eachOpp.AccountId)) {
                    mapOfResponse.put(eachOpp.AccountId, eachOpp.OpportunityLineItems[0].Product2.SKU_Code__c);
                }
            }
        }
        return mapOfResponse;
    }
    
    
    /**
*  update the field on account and oppty after closed won and synced to NS
*  @name populateClosedWonFields
*  @param account Id
*  @return wrapper of account and opportunity
*  @reference SF-6204
*/
    public static void populateClosedWonFields(Id accountId , Id opportunityId) {
        Id activeOppId;
        if(opportunityId != null) {
            activeOppId = opportunityId;
        } else {
            Map<String, String> mapOfActiveSubscirption = fetchLatestOppty(new Set<Id> {accountId},true);
            if(mapOfActiveSubscirption.containsKey(accountId)) {
                activeOppId = mapOfActiveSubscirption.get(accountId);
            }
        }
        
        if(activeOppId == null) {
            return;
        }
        
        Opportunity objOpp = new Opportunity();
        objOpp.Id = activeOppId;
        
        Map<Id, Opportunity> mapUpdateOpp = new Map<Id, Opportunity>();
        
        Account objAccount = new Account();
        objAccount.Id = accountId;
        
        calcualteRollUp(objOpp);
        populateIncludeSubscription(objOpp, accountId, activeOppId, mapUpdateOpp);
        calculateCSSAmount(objOpp, objAccount);
        
        //update related records
        List<Error_Log__c> listOfErrors = new List<Error_Log__c>();
        mapUpdateOpp.put(objOpp.Id, objOpp);
        
        Database.SaveResult[] saveResults = Database.update(mapUpdateOpp.values(), false);
        for (Database.SaveResult eachResult : saveResults) {
            if (!eachResult.isSuccess()) {
                String strErrorMsg = '';
                for(Database.Error err : eachResult.getErrors()) {
                    strErrorMsg += err.getStatusCode() + ': ' + err.getMessage();
                }
                if(mapUpdateOpp.containsKey(eachResult.getId())) {
                    Opportunity errorOppty = mapUpdateOpp.get(eachResult.getId());
                    Error_Log__c newError = createErrorLog(eachResult.getId(), JSON.serialize(errorOppty), strErrorMsg);
                    listOfErrors.add(newError);
                }
            }
        }
        
        try {
            update objAccount;
        } catch(Exception ex) {
            Error_Log__c newError = createErrorLog(objAccount.Id, JSON.serialize(objAccount), ex.getMessage());
            listOfErrors.add(newError);
        }
        if(!listOfErrors.isEmpty()) {
            insert listOfErrors;
        }
    }
    
    /**
*  custom roll up from the OLI tagged on the opportunity
*  @name calcualteRollUp
*  @param opportunity object
*  @return void
*  @reference OptyRollUpFieldUpd_Batch
*/
    public static void calcualteRollUp(Opportunity objOpp) {
        List<OpportunityLineItem> listAllLineItem = [
            SELECT id,Discount_Reason__c,Amount_Despite_VIP__c, Product_Category__c, Amount__c,Product_Duration__c,
            Start_Date__c,Complimentary__c, Push_to_NetSuite__c, Product2.Product_Category__c
            FROM OpportunityLineItem
            WHERE OpportunityId =: objOpp.Id
        ];
        
        
        Integer countFirstPromo = 0, countSubItems = 0, countVipRel = 0, countVipSpending = 0, countVipSubs = 0;
        Decimal summarySubsItem = 0.00, summaryDiscItem = 0.00;
        Date activationDate = null;
        for(OpportunityLineItem eachLineItem : listAllLineItem) {
            if(eachLineItem.Discount_Reason__c == 'First-Timer Discount'){
                ++countFirstPromo;
            }
            if(eachLineItem.Product2.Product_Category__c == 'Subscription' && eachLineItem.Push_to_NetSuite__c){
                ++countSubItems;
                if(eachLineItem.Amount__c != null && !eachLineItem.Complimentary__c) {
                    summarySubsItem = eachLineItem.Amount__c;
                }
                if(eachLineItem.Product_Duration__c != null && Integer.valueOf(eachLineItem.Product_Duration__c)>=180 && eachLineItem.Complimentary__c == false){
                    activationDate = (eachLineItem.Start_Date__c!=null)?eachLineItem.Start_Date__c:null;
                }
            }
            if(eachLineItem.Discount_Reason__c == 'VIP (Relationship)'){
                ++countVipRel;
            }
            if(eachLineItem.Discount_Reason__c == 'VIP (Spending)'){
                ++countVipSpending;
            }
            if(
                eachLineItem.Product_Category__c == 'Subscription' &&
                eachLineItem.Push_to_NetSuite__c &&
                (eachLineItem.Discount_Reason__c == 'VIP (Relationship)' ||
                 eachLineItem.Discount_Reason__c == 'VIP (Spending)' ||
                 eachLineItem.Discount_Reason__c == 'VIP (migration)')
            ){
                ++countVipSubs;
                if(Integer.valueOf(eachLineItem.Product_Duration__c)>=180 && eachLineItem.Complimentary__c == true && activationDate == null){
                    activationDate = (eachLineItem.Start_Date__c!=null)?eachLineItem.Start_Date__c:null;
                }
                if(eachLineItem.Amount_Despite_VIP__c != null) {
                    summarySubsItem = eachLineItem.Amount_Despite_VIP__c;
                }
            }
            if(eachLineItem.Product_Category__c == 'Discretionary'){
                summaryDiscItem += (eachLineItem.Amount__c!=null && eachLineItem.Amount__c>0)?eachLineItem.Amount__c:0.00;
            }
        }
        
        objOpp.Count_of_First_Timer_Promotion_new__c = countFirstPromo;
        objOpp.Count_of_Subscription_Item_new__c = countSubItems;
        objOpp.Summary_Of_Subscription_Item_new__c = summarySubsItem;
        objOpp.Count_of_VIP_Relation_Request_new__c = countVipRel;
        objOpp.Count_of_VIP_Spending_Request_new__c = countVipSpending;
        objOpp.Count_of_VIP_Subscription_new__c = countVipSubs;
        objOpp.Total_Spending_on_Discretionary_Prod_new__c = summaryDiscItem;
        objOpp.Subscription_Activation_Date__c = activationDate;
    }
    
    /**

*  @name populateConvertedSSFields
*  @param OpportunityId
*  @return void
*  @reference PGAUTO-6994
*/
    public static void populateConvertedSSFields(Id OpportunityId) {
        Map<Id,Opportunity> mapOfOppIdVsOpp = new Map<Id,Opportunity>([
            SELECT id,Total_Gross_Amount__c,AccountId,Total_Amount__c,
            IsWon,CloseDate,OMC_Approved_Date__c,Subscription_Activation_Date__c
            FROM Opportunity
            WHERE Id =: OpportunityId AND (Opportunity_Type__c = 'B2C - Renewal' OR Opportunity_Type__c = 'Self-Serve Renewal')
        ]);
        
        //PGAUTO-8057
        Account objAcc = new Account();
        objAcc.Id = mapOfOppIdVsOpp.get(OpportunityId).AccountId;
        
        calcualteRollUp(mapOfOppIdVsOpp.get(OpportunityId));  
        calculateCSSAmount(mapOfOppIdVsOpp.get(OpportunityId), objAcc);
        
        List<Error_Log__c> listOfErrors = new List<Error_Log__c>();
        try {
            update objAcc;
        } catch(Exception ex) {
            Error_Log__c newError = createErrorLog(objAcc.Id, JSON.serialize(objAcc), ex.getMessage());
            listOfErrors.add(newError);
        }
        if(!listOfErrors.isEmpty()) {
            insert listOfErrors;
        }
    }
    
    
    
    /**
*  populate the current oppty include subsciption checkbox on all oppty
*  @name populateIncludeSubscription
*  @param opportunity object, realted accountid, active oppty and list of oppty to update
*  @return void
*  @reference ExcludeFromSpending_Batch, OppIncludeSubscription_Batch
*/
    public static void populateIncludeSubscription(Opportunity objOpp, Id accountId, Id activeOpp, Map<Id, Opportunity> mapUpdateOpp) {
        objOpp.Is_Current_Subscription__c  = true;
        if (objOpp.Include_Subscription_Ext__c != objOpp.Include_Subscription__c) {
            objOpp.Include_Subscription_Ext__c = objOpp.Include_Subscription__c;
            objOpp.ByAuto__c = true;
        }
        for (Opportunity eachOpp: [
            SELECT Id, Name, AccountId, Include_Subscription__c, Include_Subscription_Ext__c, ByAuto__c, CloseDate,
            Is_Current_Subscription__c,OMC_Approved_Date__c, Months_Included__c, Exclude_from_Spending_at__c
            FROM Opportunity
            WHERE RecordType.Name='B2C'
            AND IsWon=true
            AND AccountId =: accountId
            ORDER BY OMC_Approved_Date__c desc
        ]) {
            if(eachOpp.Id != activeOpp) {
                //from OppIncludeSubscription_Batch
                Opportunity updateOpp = new Opportunity();
                updateOpp.Id = eachOpp.Id;
                updateOpp.Is_Current_Subscription__c  = false;
                if (eachOpp.Include_Subscription_Ext__c != eachOpp.Include_Subscription__c) {
                    updateOpp.Include_Subscription_Ext__c = eachOpp.Include_Subscription__c;
                    updateOpp.ByAuto__c = true;
                }
                //from ExcludeFromSpending_Batch
                if(eachOpp.Exclude_from_Spending_at__c < system.today() && eachOpp.Months_Included__c) {
                    updateOpp.Months_Included__c = false;
                }
                mapUpdateOpp.put(updateOpp.Id, updateOpp);
                
                if(eachOpp.Id == objOpp.Id && !eachOpp.Months_Included__c && eachOpp.Exclude_from_Spending_at__c >= system.today()) {
                    objOpp.Months_Included__c = true;
                }
            }
        }
    }
    
    /**
*  custom css and pro rate amount
*  @name calculateCSSAmount
*  @param opportunity and account object
*  @return void
*  @reference OptyRollUpFieldUpd_Batch
*/
    public static void calculateCSSAmount(Opportunity objOpp, Account objAccount) {
        //css amount
        objAccount.Current_Subscription_Spending_Amount__c = objOpp.Summary_Of_Subscription_Item_new__c;
        //for pro rate
        Map<String, Opportunity> mapOfData = new Map<String, Opportunity>([
            SELECT Id, Pro_rate__c, Opportunity_Type__c FROM Opportunity WHERE Id =: objOpp.Id
        ]);
        if(!mapOfData.isEmpty() && mapOfData.containsKey(objOpp.Id)) {
            if(
                mapOfData.get(objOpp.Id).Opportunity_Type__c != null &&
                mapOfData.get(objOpp.Id).Opportunity_Type__c.equals('B2C - Upgrade') &&
                mapOfData.get(objOpp.Id).Pro_rate__c != null
            ) {
                objAccount.Pro_Rate_Amount__c = mapOfData.get(objOpp.Id).Pro_rate__c;
            } else {
                objAccount.Pro_Rate_Amount__c = 0;
            }
        }
    }
    
    public static Error_Log__c createErrorLog(String recordId, String strData, String strErrorMsg) {
        Error_Log__c newError = new Error_Log__c();
        newError.Related_Record_Id__c = recordId;
        if(strData.length() > 100000) {
            strData = strData.substring(0, 100000);
        }
        newError.Data_To_Update__c = strData;
        if(strErrorMsg.length() > 100000) {
            strErrorMsg = strErrorMsg.substring(0, 100000);
        }
        newError.Error_Message__c = strErrorMsg;
        return newError;
    }
    
    public static List<Opportunity> fetchOpportunities(Set<Id> accountIds){
        List<Opportunity> listAllOpp = new List<Opportunity>();
        List<Opportunity> listOfAllOpties = [SELECT Id, AccountId,OMC_Approved_Date__c,RecordTypeId,CloseDate,
                                             (SELECT Id, Push_to_NetSuite__c,Start_Date__c FROM OpportunityLineItems WHERE
                                              Product_Category__c ='Subscription' AND Complimentary__c = false 
                                              AND Push_to_NetSuite__c = true)
                                             FROM Opportunity
                                             WHERE AccountId IN: accountIds
                                             AND IsWon = true
                                             AND (RecordTypeId =: B2C_OPP_RECORDTYPEiD OR RecordTypeId =: B2C_SS_OPP_RECORDTYPEiD)
                                            ];
        String fieldName;
        Date approvedDate;
        String query = '';
        
        for(Opportunity newOpp :listOfAllOpties){
            if(newOpp.OMC_Approved_Date__c != null && newOpp.RecordTypeId == B2C_OPP_RECORDTYPEiD) {
                approvedDate =date.newInstance(newOpp.OMC_Approved_Date__c.year(),newOpp.OMC_Approved_Date__c.Month(),
                                               newOpp.OMC_Approved_Date__c.Day());
                if(approvedDate>newOpp.CloseDate){
                    fieldName = 'OMC_Approved_Date__c';
                }else{
                    fieldName = 'CloseDate';   
                }
            } else {
                fieldName = 'CloseDate';
            }
        }
        if(fieldName!= null){
        query = 'SELECT Id, AccountId,OMC_Approved_Date__c,CloseDate,StageName,(SELECT Id, Push_to_NetSuite__c,Product2Id,Product2.SKU_Code__c,Start_Date__c FROM OpportunityLineItems WHERE ' + 
            'Product2.Product_Category__c = \'Subscription\' AND Complimentary__c = false AND Push_to_NetSuite__c = true) '+
            'FROM Opportunity WHERE AccountId IN: accountIds AND IsWon = true AND ' +
            '(RecordTypeId =: B2C_OPP_RECORDTYPEiD OR RecordTypeId =: B2C_SS_OPP_RECORDTYPEiD) ORDER BY ' +fieldName+ ' desc ';
        
        listAllOpp = Database.query(query);
        }   
        
        return listAllOpp;
    }
}
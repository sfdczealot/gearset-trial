public class oppLineItemTriggerHelper {
    
    public static void updateOppLineItem (List<OpportunityLineItem> oppLineItemList){
        
        Map<Id,String> checkRecordType = checkOppRecordType(oppLineItemList);
        
        QuoteSyncHandler.isOLITriggerFire = false;
        
        Set<Id> OppmainId=new Set<Id>();
        Set<Id> prodId=new Set<Id>();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        
        for(OpportunityLineItem eacholi : oppLineItemList){
            if(eacholi.OpportunityId!=null &&
               checkRecordType.containsKey(eacholi.OpportunityId) &&
               checkRecordType.get(eacholi.OpportunityId) == 'B2C')
            {
                OppmainId.add(eacholi.OpportunityId);
                prodId.add(eacholi.Product2id);
                oliList.add(eacholi);
            }
        }
        Map<ID,Opportunity> mapofopp=new Map<ID,Opportunity>([select Id, Name, Subscription_Code__c,Opportunity_Type__c, RecordType.Name from Opportunity where Id IN:OppmainId]);
        Map<Id,product2> mapofProd=new Map<Id,product2>([select Product_Category__c from product2 where id In:prodId]);
        for(OpportunityLineItem oppitem : oliList){
            String discount_reason = null;
            String ItemSubscription = null;
            String OpportunityType = null;
            Decimal AmountDVIP = 0.00;
            Decimal AmountDisc = 0.00;
            System.debug('oppid ' + oppitem);
            //OppmainId = oppitem.OpportunityId;
            ItemSubscription = mapofProd.get(oppitem.Product2id).Product_Category__c;
            OpportunityType = mapofopp.get(oppitem.OpportunityId).Opportunity_Type__c;
            if (oppitem.OpportunityId!=null) {
                System.debug('ItemSubscription' + ItemSubscription);
                System.debug('RecordTypeName' + mapofopp.get(oppitem.OpportunityId).RecordType.Name);
                oppitem.Record_Type__c = mapofopp.get(oppitem.OpportunityId).RecordType.Name;
                oppitem.Product_Category__c = ItemSubscription;
                
                
                if(ItemSubscription == 'Subscription' && mapofopp.get(oppitem.OpportunityId).RecordType.Name == 'B2C' && String.isBlank(OpportunityType)){
                    if(oppitem.Discount__c != null){
                        if(oppitem.Discount__c > 0){
                            AmountDisc = (oppitem.UnitPrice * oppitem.Quantity) * (oppitem.Discount__c/100);
                        }
                    }
                    if (oppitem.Discount_Amount__c != null){
                        if(oppitem.Discount_Amount__c > 0){
                            AmountDisc = oppitem.Discount_Amount__c;
                        }
                    }
                    
                    if(oppitem.Complimentary__c == true){
                        if(mapofopp.get(oppitem.OpportunityId).RecordType.Name == 'B2C'){
                            system.debug('oppitem.UnitPrice:' + oppitem.UnitPrice);
                            system.debug('oppitem.Quantity:' + oppitem.Quantity);
                            system.debug('oppitem.TotalPrice:' + oppitem.TotalPrice);
                            AmountDVIP = (oppitem.UnitPrice * oppitem.Quantity);
                        }
                        else{
                            AmountDVIP = (oppitem.UnitPrice * oppitem.Quantity);
                        }
                    }
                    else{
                        if(mapofopp.get(oppitem.OpportunityId).RecordType.Name == 'B2C'){
                            system.debug('noncomp');
                            system.debug('oppitem.UnitPrice:' + oppitem.UnitPrice);
                            system.debug('oppitem.Quantity:' + oppitem.Quantity);
                            system.debug('oppitem.AmountDisc:' + AmountDisc);
                            system.debug('oppitem.Pro_Rate_Amount__c:' + oppitem.Pro_Rate_Amount__c);
                            AmountDVIP = (oppitem.UnitPrice * oppitem.Quantity) - AmountDisc - ((oppitem.Pro_Rate_Amount__c!=null)?oppitem.Pro_Rate_Amount__c:0.00);
                        }
                        else{
                            AmountDVIP = (oppitem.UnitPrice * oppitem.Quantity) - AmountDisc;
                        }
                    }
                    
                    system.debug('oppitem.AmountDVIP:' + AmountDVIP);
                    System.debug('Discount check: X');
                    //Update Amount For VIP
                    if(oppitem.Discount_Reason__c != null){
                        discount_reason = oppitem.Discount_Reason__c;
                        System.debug('Discount Reason:' + discount_reason);
                        if(discount_reason.contains('VIP')){
                            oppitem.Amount_Despite_VIP__c = oppitem.UnitPrice;
                        }
                    }
                    //Update Amount For Non-VIP
                    if(oppitem.Discount_Reason__c != 'VIP (Lifetime FOC)' && oppitem.Discount_Reason__c != 'VIP (Relationship)' && oppitem.Discount_Reason__c != 'VIP (Spending)' && oppitem.Discount_Reason__c != 'VIP (migration)'){
                        //oppitem.Amount_Despite_VIP__c = oppitem.Amount__c;
                        oppitem.Amount_Despite_VIP__c = AmountDVIP;
                    }
                    
                    //Update Opportunity Subscription Code
                    mapofopp.get(oppitem.OpportunityId).Subscription_Code__c = oppitem.Product2.SKU_code__c;
                }
            }
        }
    }
    
    public static void trackHistoryAndCheckValidation(List<OpportunityLineItem> oldList ,Map<Id,OpportunityLineItem> oldMap){
        
        Map<Id,String> checkRecordType = checkOppRecordType(oldList);
        if(subEnabled())
        {
            Map<Id,OpportunityLineItem> oldMapForB2BOrB2C = new Map<Id,OpportunityLineItem>();
            for(OpportunityLineItem oli : oldList )
            {
                if(oli.OpportunityId!=null &&
                   checkRecordType.containsKey(oli.OpportunityId) &&
                   (checkRecordType.get(oli.OpportunityId) == 'B2C' || checkRecordType.get(oli.OpportunityId) == 'B2B'))
                {
                    oldMapForB2BOrB2C.put(oli.Id,oli);
                }
            }
            
            if(!oldMapForB2BOrB2C.isEmpty())
                PGOpportunityLineItemTriggerHandler.oli_history(null, oldMapForB2BOrB2C, 'DELETE');
        }
        
        String AllowAccess = System.Label.PG_LABEL_Profile_access_to_delete_Opptys;
        system.debug(UserInfo.getProfileId() +' current');
        system.debug(allowaccess+ 'label ');
        if(!AllowAccess.contains(UserInfo.getProfileId())){
            List<OpportunityLineItem> B2COLI=[select id,OpportunityId,Opportunity.Stagename,Opportunity.recordType.Name  from OpportunityLineItem where Id In:oldList and Opportunity.recordType.Name ='B2C' and Opportunity.Stagename ='Closed Won'];
            system.debug('--B2COLI--'+B2COLI);
            If(B2COLI.size()>0){
                for(OpportunityLineItem eachOli : B2COLI){
                    oldMap.get(eachOli.Id).adderror('You can not delete OLI of Closed Won opportunity');
                }
            }
        }
        
        QuoteSyncHandler.isOLITriggerFire = false;
    }
    
    public static void trackHistoryAndSummarizeLineItem(List<OpportunityLineItem> newList, Map<Id,OpportunityLineItem> newMap){
        
        Map<Id,String> checkRecordType = checkOppRecordType(newList);
        
        Map<Id,OpportunityLineItem> newMapForB2BOrB2C = new Map<Id,OpportunityLineItem>();
        List<OpportunityLineItem> newListForB2C = new List<OpportunityLineItem>();
        
        for(OpportunityLineItem oli: newList){
            
            if(oli.OpportunityId!= null &&
               checkRecordType.containsKey(oli.OpportunityId) &&
               (checkRecordType.get(oli.OpportunityId) == 'B2C' ||
                checkRecordType.get(oli.OpportunityId) == 'B2B'))
            {
                newMapForB2BOrB2C.put(oli.Id,oli);
            }
            
            if(oli.OpportunityId!= null &&
               checkRecordType.containsKey(oli.OpportunityId) &&
               (checkRecordType.get(oli.OpportunityId) == 'B2C'))
                
            {
                newListForB2C.add(oli);
            }
        }
        
        if(!newMapForB2BOrB2C.isEmpty() && subEnabled())
            PGOpportunityLineItemTriggerHandler.oli_history(newMapForB2BOrB2C, null, 'CREATE');
        
        // Only proceed B2C Opportunity
        
        if(newListForB2C!=null && !system.isBatch() && !system.isFuture())
            PGOpportunityLineItemTriggerHandler.summarizeLineItem(newListForB2C);
        
    }
    public static void trackHisSummarizeOLISyncQLI(List<OpportunityLineItem> newList,List<OpportunityLineItem> oldList, Map<Id,OpportunityLineItem> newMap,Map<Id,OpportunityLineItem> oldMap){
        
        Map<Id,String> checkRecordType = checkOppRecordType(newList);
        Map<Id,OpportunityLineItem> newMapForB2BOrB2C = new Map<Id,OpportunityLineItem>();
        Map<Id,OpportunityLineItem> oldMapForB2BOrB2C = new Map<Id,OpportunityLineItem>();
        List<OpportunityLineItem> newOliList = new List<OpportunityLineItem>();
        Map<Id,OpportunityLineItem> newMapforB2C = new Map<Id,OpportunityLineItem>();
        
        
        for(OpportunityLineItem oli: newList)
        {
            if(oli.OpportunityId!=null &&
               checkRecordType.containsKey(oli.OpportunityId) &&
               (checkRecordType.get(oli.OpportunityId) == 'B2B' ||
                checkRecordType.get(oli.OpportunityId) == 'B2C'))
            {
                newMapForB2BOrB2C.put(oli.Id,oli);
                
                if(oldMap.containsKey(oli.Id) && oldMap.get(oli.Id)!=null)
                    oldMapForB2BOrB2C.put(oli.Id,oldMap.get(oli.Id));
            }
            
            if(oli.OpportunityId!=null &&
               checkRecordType.containsKey(oli.OpportunityId) &&
               (checkRecordType.get(oli.OpportunityId) == 'B2C'))
            {
                newMapforB2C.put(oli.Id,oli);
                newOliList.add(oli);
            }
        }
        
        if(subEnabled())
            PGOpportunityLineItemTriggerHandler.oli_history(newMapForB2BOrB2C, oldMapForB2BOrB2C, 'UPDATE');
        
        
        //to sync QuoteLineItem
        if((!Test.isRunningTest()) && (!newMapforB2C.isEmpty()) && (QuoteSyncHandler.isQLITriggerFire))
        {
            QuoteSyncHandler.isQLITriggerFire = false;
            Set<Id> oliIds = newMapforB2C.keyset();
            QuoteSyncHandler.sync(oliIds);
        }
        // Only proceed B2C Opportunity
        if ((newOliList!=null) && (!system.isBatch() && !system.isFuture())) {
            PGOpportunityLineItemTriggerHandler.summarizeLineItem(newOliList);
        }
    }
    
    public static void summarizeOppLineItem(List<OpportunityLineItem> oldList){
        
        // Only proceed B2C Opportunity
        Map<Id,String> checkRecordType = checkOppRecordType(oldList);
        List<OpportunityLineItem> oldListForB2C = new List<OpportunityLineItem>();
        for(OpportunityLineItem oli: oldList)
        {
            if(oli.OpportunityId!=null &&
               checkRecordType.containsKey(oli.OpportunityId) &&
               checkRecordType.get(oli.OpportunityId) == 'B2C')
                
            {
                oldListForB2C.add(oli);
            }
        }
        
        if(oldListForB2C!=null && !system.isBatch() && !system.isFuture())
            PGOpportunityLineItemTriggerHandler.summarizeLineItem(oldListForB2C);
    }
    
    public static Boolean subEnabled(){
        Boolean subEnabled = true;
        if(!Test.isRunningTest()) {
            Trigger_Execute__c TE = Trigger_Execute__c.getValues('Trigger_OpportunityLineItem');
            subEnabled = TE.Sub_Enable__c;
        }
        return subEnabled;
    }
    
    //For common code to check recordType
    public static Map<Id,String> checkOppRecordType(List<OpportunityLineItem> oliList){
        Map<Id,String> checkOpportunityRecordType = new Map<Id,String>();
        
        Set<Id> OpportunityId = new Set<Id>();
        
        for(OpportunityLineItem oli: oliList){
            if(oli.OpportunityId!=null)
                OpportunityId.add(oli.OpportunityId);
        }
        if (OpportunityId!=null) {
            for (Opportunity opp: [select Id, Name, RecordType.Name,Subsidiary__c from Opportunity where Id In :OpportunityId]) {
                if (opp.RecordType.Name=='B2C' || opp.RecordType.Name=='B2C Closed Lost') {
                    checkOpportunityRecordType.put(opp.Id,'B2C');
                }
                else if(opp.RecordType.Name=='B2B'){
                    checkOpportunityRecordType.put(opp.Id,'B2B');
                }
            }
        }
        
        return checkOpportunityRecordType;
    }
    /***method to update totalprice with price after discount value for PGAUTO-6239 ****/
    public static void updateOLIStandardDiscount(List<OpportunityLineItem> newList,Map<Id, OpportunityLineItem> oldMap){
        Map<Id,String> checkRecordType = checkOppRecordType(newList);
        
        for(OpportunityLineItem oliObj:newList){
            if(oliObj.OpportunityId!=null &&  checkRecordType.containsKey(oliObj.OpportunityId) && checkRecordType.get(oliObj.OpportunityId) == 'B2B'){
                if((oldMap != null &&  oldMap.get(oliObj.Id).Amount__c!= null && oliObj.Amount__c !=null && oliObj.Amount__c != oldMap.get(oliObj.Id).Amount__c) || oldMap == null){
                    Decimal discount = 0;
                    if(oliObj.Price_before_discount__c!=0 && oliObj.Amount__c !=null && oliObj.Price_before_discount__c!=null){
                        discount = (oliObj.Price_before_discount__c - oliObj.Amount__c)/oliObj.Price_before_discount__c;
                        oliObj.discount = discount * 100;
                    }
                }
            }
        }
    }
    
    /**
*  method to send notification to workato for creatio of CI
*  @name selfServeNotification
*  @param trigger new
*  @reference PGAUTO-6316
*/
    public static void selfServeNotification(List<OpportunityLineItem> triggerNew) {
        set<Id> setOfOpptyId = new set<Id>();
        for(OpportunityLineItem eachOppLineItme: triggerNew) {
            if(String.isNotBlank(eachOppLineItme.Record_Type__c) && eachOppLineItme.Record_Type__c.equals('B2C Self Serve')) {
                setOfOpptyId.add(eachOppLineItme.OpportunityId);
            }
        }
        if(!setOfOpptyId.isEmpty()) {
            map<String, Opportunity> mapOfOppty = new map<String, Opportunity>([
                SELECT Id, Country__c, AccountId, Account.PersonContactId, Account.AgentNet_ID__c, BasketId__c
                FROM Opportunity
                WHERE Id IN: setOfOpptyId
                AND BasketId__c != null
                AND Account.AgentNet_ID__c != null
            ]);
            List<Self_Serve_Opportunity_Sync__e> listOfEvents = new List<Self_Serve_Opportunity_Sync__e>();
            for(OpportunityLineItem eachOppLineItme: triggerNew) {
                if(
                    String.isNotBlank(eachOppLineItme.Record_Type__c) &&
                    eachOppLineItme.Record_Type__c.equals('B2C Self Serve') &&
                    mapOfOppty.containsKey(eachOppLineItme.OpportunityId)
                ) {
                    listOfEvents.add(new Self_Serve_Opportunity_Sync__e(
                        AgentNet_Id__c = mapOfOppty.get(eachOppLineItme.OpportunityId).Account.AgentNet_ID__c,
                        Agent_Contact_Id__c = mapOfOppty.get(eachOppLineItme.OpportunityId).Account.PersonContactId,
                        Basket_Id__c = mapOfOppty.get(eachOppLineItme.OpportunityId).BasketId__c,
                        Country__c = mapOfOppty.get(eachOppLineItme.OpportunityId).Country__c,
                        Opportunity_Id__c = mapOfOppty.get(eachOppLineItme.OpportunityId).Id,
                        Opportunity_LineItem_Id__c = eachOppLineItme.Id
                    ));
                }
            }
            if(!listOfEvents.isEmpty()) {
                EventBus.publish(listOfEvents);
            }
        }
    }
}
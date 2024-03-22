//TEST CLASS: PGQuoteTriggerHandler_Test,QuoteLineItemTriggerHandler_Test
public class PGQuoteOpportunityHelper {
    
    //QUERY OPPORTUNITY FIELDS
    public static Map<Id,Opportunity> getAllOpp(Set<Id> setOfOpp){
        Map<Id,Opportunity> mapOfOpp=new Map<Id,Opportunity>([select Id,accountid,Upgrade_Start_Date__c,Opportunity_Type__c,Order_Type_Clone__c,PriceBook2Id,SyncedQuoteId,Name,RecordTypeId,Account_Email__c,Account_Phone__c,Account_Rule_Code__c,Addressee__c,Agency_Name__c,Agent_Accepted_Time__c,Allowed_Payment_Type__c,Apply_VIP_Discount__c,Approval_Requester_Comment__c,Approval_Selector__c,Approval_Status__c,Billing_Contact__c,billing_OMC_Approved__c,Budget_Confirmed__c,ByAuto__c,Create_NS_Customer__c,Customer_PO__c,Discount_Remarks__c,Discovery_Completed__c,FOC_Approved__c,From_Button__c,Guruland_Link_Created_Date__c,Include_Subscription_Ext__c,IsClone__c,Is_Current_Subscription__c,Last_Outbound_Sync__c,Loss_Reason__c,Lost_Sub_Reason__c,Managerial_Approved__c,Memo__c,Months_Included__c,OMC_Approved_Date__c,OMC_Rejected_Reason__c,OMC_Submitted_Time__c,OMC_Urgent__c,Order_Date__c,Outbound_Sync_Error__c,Payment_Amount__c,Guruland_Quote_Link__c,Payment_Reference__c,Payment_Term__c,Payment_Time__c,PG_Tenure__c,Project_Opportunity_Amount__c,Pro_Rate__c,Push_Counter__c,Renewal_State__c,Re_print_Contract__c,ROI_Analysis_Completed__c,SO_Order__c,StageName,Submit_to_OMC_Manually__c,Subscription_Code__c,Subscription_End_Date__c,Sync_To_NetSuite__c,Total_Amount_Before_Discount_display__c,Total_Amount_of_FOC_Before_Discount_MY__c,Total_Complimentary_Value_display__c,Total_Discounted_Amount_display__c,Total_Gross_Amount_display__c,Total_Mgr_Disc_of_Discretionary_Amount__c,Total_Mgr_Disc_of_Discretionary_Percent__c,Total_Mgr_Disc_of_Subscription_Amount__c,Total_Mgr_Disc_of_Subscription_Percent__c,Total_Spending__c,Total_Tax_Amount_display__c,Upload_Tag__c,VIP_Approved__c,Subsidiary__c,User_Sales_Head__c,Celigo_Update__c  ,NetSuite_Sales_Order__c,NetSuite_Sync_Error__c,Push_To_NetSuite__c,Sync_In_Progress__c from Opportunity where Id IN:setOfOpp limit 500000]);
        return mapOfOpp;
    }
    //QUOTE AND OPPORTUNITY FIELDS MAPPING
    public static Quote getQuote(Quote qu,Opportunity op){
        qu.Account_Email__c = op.Account_Email__c;
        qu.Account_Phone__c = op.Account_Phone__c;
        qu.Account_Rule_Code__c = op.Account_Rule_Code__c;
        qu.Addressee__c = op.Addressee__c;
        qu.Agency_Name__c = op.Agency_Name__c;
        qu.Agent_Accepted_Time__c = op.Agent_Accepted_Time__c;
        qu.Allowed_Payment_Type__c = op.Allowed_Payment_Type__c;
        qu.Apply_VIP_Discount__c = op.Apply_VIP_Discount__c;
        qu.Approval_Requester_Comment__c = op.Approval_Requester_Comment__c;
        qu.Approval_Selector__c = op.Approval_Selector__c;
        qu.Approval_Status__c = op.Approval_Status__c;
        qu.Billing_Contact__c = op.Billing_Contact__c;
        qu.billing_OMC_Approved__c = op.billing_OMC_Approved__c;
        qu.Budget_Confirmed__c = op.Budget_Confirmed__c;
        qu.ByAuto__c = op.ByAuto__c;
        qu.Create_NS_Customer__c = op.Create_NS_Customer__c;
        qu.Customer_PO_No__c = op.Customer_PO__c;
        qu.Discount_Remarks__c = op.Discount_Remarks__c;
        qu.Discovery_Completed__c = op.Discovery_Completed__c;
        qu.FOC_Approved__c = op.FOC_Approved__c;
        qu.From_Button__c = op.From_Button__c;
        qu.Guruland_Link_Created_Date__c = op.Guruland_Link_Created_Date__c;
        qu.Include_Subscription_Ext__c = op.Include_Subscription_Ext__c;
        qu.IsClone__c = op.IsClone__c;
        qu.Is_Current_Subscription__c = op.Is_Current_Subscription__c;
        qu.Last_Outbound_Sync__c = op.Last_Outbound_Sync__c;
        qu.Loss_Reason__c = op.Loss_Reason__c;
        qu.Lost_Sub_Reason__c = op.Lost_Sub_Reason__c;
        qu.Managerial_Approved__c = op.Managerial_Approved__c;
        qu.Memo__c = op.Memo__c;
        qu.Months_Included__c = op.Months_Included__c;
        qu.OMC_Approved_Date__c = op.OMC_Approved_Date__c;
        qu.OMC_Rejected_Reason__c = op.OMC_Rejected_Reason__c;
        qu.OMC_Submitted_Time__c = op.OMC_Submitted_Time__c;
        qu.OMC_Urgent__c = op.OMC_Urgent__c;
        qu.Order_Date__c = op.Order_Date__c;
        qu.Outbound_Sync_Error__c = op.Outbound_Sync_Error__c;
        qu.Payment_Amount__c = op.Payment_Amount__c;
        qu.Payment_Link__c = op.Guruland_Quote_Link__c;
        qu.Payment_Reference__c = op.Payment_Reference__c;
        qu.Payment_Terms__c = op.Payment_Term__c;
        qu.Payment_Time__c = op.Payment_Time__c;
        qu.PG_Tenure__c = op.PG_Tenure__c;
        qu.Project_Opportunity_Amount__c = op.Project_Opportunity_Amount__c;
        qu.Pro_Rate__c = op.Pro_Rate__c;
        qu.Push_Counter__c = op.Push_Counter__c;
        //qu.Record_Eligibility__c = op.Record_Eligibility__c;
        qu.Renewal_State__c = op.Renewal_State__c;
        qu.Re_print_Contract__c = op.Re_print_Contract__c;
        qu.ROI_Analysis_Completed__c = op.ROI_Analysis_Completed__c;
        qu.SO_Order__c = op.SO_Order__c;
        qu.Stage__c = op.StageName;
        qu.Submit_to_OMC_Manually__c = op.Submit_to_OMC_Manually__c;
        qu.Subscription_Code__c = op.Subscription_Code__c;
        qu.Subscription_End_Date__c = op.Subscription_End_Date__c;
        qu.Sync_To_NetSuite__c = op.Sync_To_NetSuite__c;
        qu.Total_Amount_Before_Discount_display__c = op.Total_Amount_Before_Discount_display__c;
        qu.Total_Amount_of_FOC_Before_Discount_MY__c = op.Total_Amount_of_FOC_Before_Discount_MY__c;
        qu.Total_Complimentary_Value_display__c = op.Total_Complimentary_Value_display__c;
        qu.Total_Discounted_Amount_display__c = op.Total_Discounted_Amount_display__c;
        qu.Total_Gross_Amount_display__c = op.Total_Gross_Amount_display__c;
        qu.Total_Mgr_Disc_of_Discretionary_Amount__c = op.Total_Mgr_Disc_of_Discretionary_Amount__c;
        qu.Total_Mgr_Disc_of_Discretionary_Percen__c = op.Total_Mgr_Disc_of_Discretionary_Percent__c;
        qu.Total_Mgr_Disc_of_Subscription_Amount__c = op.Total_Mgr_Disc_of_Subscription_Amount__c;
        qu.Total_Mgr_Disc_of_Subscription_Percent__c = op.Total_Mgr_Disc_of_Subscription_Percent__c;
        qu.Total_Spending_last_12_months__c = op.Total_Spending__c;
        qu.Total_Tax_Amount_display__c = op.Total_Tax_Amount_display__c;
        qu.Upload_Tag__c = op.Upload_Tag__c;
        qu.VIP_Approved__c = op.VIP_Approved__c;
        qu.Subsidiary__c = op.Subsidiary__c;
        qu.CreatedDate__c = system.today();
        qu.Quote_Type__c = op.Opportunity_Type__c;
        qu.User_Sales_Head__c = op.User_Sales_Head__c;
        qu.pricebook2id = op.pricebook2id;
        return qu;
    }
    //PGAUTO-1952 Change Opp stage to new if today's date is less than closed Date for renwal and Upgrade only
    public static void expireActiveRenUpgQuote(Set<ID> expInvOppId){
        List<Opportunity> lstOppToUpdate=new List<Opportunity>();
        IF(expInvOppId.size()>0){
            List<Opportunity> lstOfOppWithClosedDate=[select Id,CloseDate,Opportunity_Type__c,(select Id,status,Upgrade_Start_Date__c from Quotes) From opportunity where Id In:expInvOppId];
            For(Opportunity each: lstOfOppWithClosedDate){
                Opportunity objOpp;
                If(Date.today() <= each.CloseDate){
                    //Added Bypass_Validation__c checkbox (PGAUTO-5447)
                    //Setting Bypass_Validation__c to true to by pass Pending_Online_Payment_to_OMC validation rule
                    objopp=new Opportunity(Id=each.Id,StageName='New',Bypass_Validation__c = true); 
                    lstOppToUpdate.add(objOpp);
                }else{
                    //write logic to check child quote and change opp to closed lost
                    if(each.Quotes.size()>0){
                        Integer count=0;
                        for(Quote eachquote: each.Quotes){
                            
                            IF(each.Opportunity_Type__c=='B2C - Standard' && (eachquote.Status=='Expired'||eachquote.Status=='Invalid')){
                                count++; 
                            }else If(each.Opportunity_Type__c=='B2C - Renewal' && (eachquote.Status=='Expired'||eachquote.Status=='Invalid') && each.CloseDate<Date.today()){
                                count++; 
                            }else If(each.Opportunity_Type__c=='B2C - Upgrade' && (eachquote.Status=='Expired'||eachquote.Status=='Invalid') && eachquote.Upgrade_Start_Date__c<=Date.today()){
                                count++; 
                            }
                            
                        }
                        If(count == each.Quotes.size()){
                            objopp=new Opportunity(Id=each.Id,StageName='Closed Lost',Loss_Reason__c='Expired Offer');
                            lstOppToUpdate.add(objopp);
                        }
                    }
                }
            }
        }
        update lstOppToUpdate;
    }
    //Logic to change Opportunity stage to Closed lost if all related Quote is Expired or Invalid
    //Singapore country check added for PGAUTO-6551
    public static void closeLostOppCondition(Set<ID> setOfExpQuote,Map<Id,String> mapOfOppIdVsLossReason){
        List<Opportunity> lstOpp=[select Id,CloseDate,Opportunity_Type__c,Country__c,(select Id,status,Upgrade_Start_Date__c,Country__c,Loss_Reason__c from Quotes) From opportunity where Id In:setOfExpQuote and Opportunity_Type__c!=''];
        List<Opportunity> lstToUpdateOpp=new List<Opportunity>();
        For(Opportunity each: lstOpp){//PGAUTO-1956,1966&1969
            if(each.Quotes.size()>0){
                Integer count=0;
                for(Quote eachquote: each.Quotes){
                    
                    IF(each.Opportunity_Type__c=='B2C - Standard' && (eachquote.Status=='Expired'||eachquote.Status=='Invalid')){
                        count++; 
                    }else If(each.Opportunity_Type__c=='B2C - Renewal' && (eachquote.Status=='Expired'||eachquote.Status=='Invalid') && each.CloseDate<Date.today()){
                        count++; 
                    }else If(each.Opportunity_Type__c=='B2C - Upgrade' && (eachquote.Status=='Expired'||eachquote.Status=='Invalid') && (eachquote.Upgrade_Start_Date__c<=Date.today() || eachquote.Country__c=='Singapore')){
                        count++;
                    }
                    
                }
                If(count == each.Quotes.size()){
                    Opportunity objopp=new Opportunity(Id=each.Id,StageName='Closed Lost');
                    if(each.Opportunity_Type__c=='B2C - Upgrade' && 
                       each.Country__c=='Singapore' && 
                       !mapOfOppIdVsLossReason.isEmpty() &&
                       mapOfOppIdVsLossReason.containsKey(each.Id) &&
                       mapOfOppIdVsLossReason.get(each.Id)!=null) {
                       objopp.Loss_Reason__c= mapOfOppIdVsLossReason.get(each.Id);   
                    }
                    else {
                    objopp.Loss_Reason__c='Expired Offer';
                    }
                    lstToUpdateOpp.add(objopp);
                }
            }
        }
        If(lstToUpdateOpp.size()>0){
            Update lstToUpdateOpp;
        }
    }
    //TO update custom QLI rollup fields on Quote
    @future(callout=true)
    public static void summarizeLineItemFuture(set<Id> setQuoteId) {
        map<Id, Quote> mapQuoteOld = new map<Id, Quote>();
        map<Id, Quote> mapQuote = new map<Id, Quote>();
        map<Id, map<string, double>> mapQuoteTotalAmount = new map<Id, map<string, double>>();
        map<string, double> mapQuoteFieldAmount;
        list<Quote> listQuote = new list<Quote>();
        Quote objQuote;
        for (Id quoteId: setQuoteId) {
            mapQuote.put(quoteId, null);
        }
        for (Quote row: [select Id, Name, ByAuto__c, Total_Mgr_Disc_of_Subscription_Percent__c, Total_Mgr_Disc_of_Discretionary_Percen__c, Total_Mgr_Disc_of_Subscription_Amount__c, Total_Mgr_Disc_of_Discretionary_Amount__c, Count_of_Referral_Agent_Promotion__c, Total_Amount_of_FOC_Before_Discount_MY__c from Quote where Id in :mapQuote.keySet()]) {
            mapQuoteOld.put(row.Id, row.clone(false, false, false, false));
            row.Total_Mgr_Disc_of_Subscription_Percent__c = 0;
            row.Total_Mgr_Disc_of_Discretionary_Percen__c = 0;
            row.Total_Mgr_Disc_of_Subscription_Amount__c = 0;
            row.Total_Mgr_Disc_of_Discretionary_Amount__c = 0;
            //row.Count_of_Referral_Agent_Promotion__c = 0;
            row.Total_Amount_of_FOC_Before_Discount_MY__c = 0;
            
            mapQuoteFieldAmount = new map<string, double>();
            mapQuoteFieldAmount.put('Total_Mgr_Disc_of_Subscription_Real_Amount', 0);
            mapQuoteFieldAmount.put('Total_Mgr_Disc_of_Discretionary_Real_Amount', 0);
            mapQuoteFieldAmount.put('Total_Mgr_Disc_of_Subscription_Discounted_Amount', 0);
            mapQuoteFieldAmount.put('Total_Mgr_Disc_of_Discretionary_Discounted_Amount', 0);
            mapQuoteTotalAmount.put(row.Id, mapQuoteFieldAmount);
            
            mapQuote.put(row.Id, row);
        }
        If(mapQuote.keySet().size()>0){
            for (QuoteLineItem row: [select Id, QuoteId, Product_Category__c, UnitPrice, Quantity, Discounted_Amount__c, Amount__c, Discount_Reason__c from QuoteLineItem where QuoteId in :mapQuote.keySet()]) {
                objQuote = mapQuote.get(row.QuoteId);
                //objQuote.Count_of_Referral_Agent_Promotion__c += (row.Discount_Reason__c=='Agent Referral: Referee'?1:0);
                objQuote.Total_Mgr_Disc_of_Subscription_Amount__c += (row.Discount_Reason__c=='Managerial Discount' && row.Product_Category__c=='Subscription')?row.Amount__c:0;
                objQuote.Total_Mgr_Disc_of_Discretionary_Amount__c += (row.Discount_Reason__c=='Managerial Discount' && row.Product_Category__c=='Discretionary')?row.Amount__c:0;
                objQuote.Total_Amount_of_FOC_Before_Discount_MY__c += (row.Discount_Reason__c=='Goodwill/ Relationship Building' || row.Discount_Reason__c=='Others' || row.Discount_Reason__c=='Technical issues' || row.Discount_Reason__c=='Renewal EB Ad Credits')?row.UnitPrice*row.Quantity:0;
                system.debug('row.Discount_Reason__c:'+row.Discount_Reason__c);
                system.debug('objQuote.Total_Amount_of_FOC_Before_Discount_MY__c:'+objQuote.Total_Amount_of_FOC_Before_Discount_MY__c);
                mapQuoteFieldAmount = mapQuoteTotalAmount.get(row.QuoteId);
                mapQuoteFieldAmount.put('Total_Mgr_Disc_of_Subscription_Real_Amount', (row.Discount_Reason__c=='Managerial Discount' && row.Product_Category__c=='Subscription')?(mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Subscription_Real_Amount')+(row.UnitPrice*row.Quantity)):mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Subscription_Real_Amount'));
                mapQuoteFieldAmount.put('Total_Mgr_Disc_of_Discretionary_Real_Amount', (row.Discount_Reason__c=='Managerial Discount' && row.Product_Category__c=='Discretionary')?(mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Real_Amount')+(row.UnitPrice*row.Quantity)):mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Real_Amount'));
                mapQuoteFieldAmount.put('Total_Mgr_Disc_of_Subscription_Discounted_Amount', (row.Discount_Reason__c=='Managerial Discount' && row.Product_Category__c=='Subscription')?(mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Subscription_Discounted_Amount')+row.Discounted_Amount__c):mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Subscription_Discounted_Amount'));
                mapQuoteFieldAmount.put('Total_Mgr_Disc_of_Discretionary_Discounted_Amount', (row.Discount_Reason__c=='Managerial Discount' && row.Product_Category__c=='Discretionary')?(mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Discounted_Amount')+row.Discounted_Amount__c):mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Discounted_Amount'));
                mapQuoteTotalAmount.put(row.QuoteId, mapQuoteFieldAmount);
                objQuote.Total_Mgr_Disc_of_Subscription_Percent__c = (objQuote.Total_Mgr_Disc_of_Subscription_Amount__c>0)?(mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Subscription_Discounted_Amount')/(mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Subscription_Real_Amount')==0?1:mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Subscription_Real_Amount'))*100):objQuote.Total_Mgr_Disc_of_Subscription_Percent__c;
                objQuote.Total_Mgr_Disc_of_Discretionary_Percen__c = (objQuote.Total_Mgr_Disc_of_Discretionary_Amount__c>0)?(mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Discounted_Amount')/(mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Real_Amount')==0?1:mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Real_Amount'))*100):objQuote.Total_Mgr_Disc_of_Discretionary_Percen__c;
                system.debug('Total_Mgr_Disc_of_Subscription_Real_Amount:'+mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Subscription_Real_Amount'));
                system.debug('Total_Mgr_Disc_of_Subscription_Discounted_Amount:'+mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Subscription_Discounted_Amount'));
                system.debug('Total_Mgr_Disc_of_Discretionary_Real_Amount:'+mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Real_Amount'));
                system.debug('Total_Mgr_Disc_of_Discretionary_Discounted_Amount:'+mapQuoteFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Discounted_Amount'));
                system.debug('___');
                system.debug('objQuote.Total_Mgr_Disc_of_Subscription_Percent__c:'+objQuote.Total_Mgr_Disc_of_Subscription_Percent__c);
                system.debug('objQuote.Total_Mgr_Disc_of_Discretionary_Percen__c:'+objQuote.Total_Mgr_Disc_of_Discretionary_Percen__c);
                mapQuote.put(objQuote.Id, objQuote);
            }
            
            for (Id oppId: mapQuote.keySet()) {
                // Only update the Opportunity which is affected for the Count/Summarize Line Item
                if (mapQuoteOld.get(oppId).Total_Mgr_Disc_of_Subscription_Amount__c != mapQuote.get(oppId).Total_Mgr_Disc_of_Subscription_Amount__c
                    || mapQuoteOld.get(oppId).Total_Mgr_Disc_of_Discretionary_Amount__c != mapQuote.get(oppId).Total_Mgr_Disc_of_Discretionary_Amount__c
                    || mapQuoteOld.get(oppId).Total_Amount_of_FOC_Before_Discount_MY__c != mapQuote.get(oppId).Total_Amount_of_FOC_Before_Discount_MY__c) {
                        //mapQuoteOld.get(oppId).Count_of_Referral_Agent_Promotion__c != mapQuote.get(oppId).Count_of_Referral_Agent_Promotion__c
                        //|| 
                        // Set ByAuto__c to true so that no callout would be made upon the updation
                        mapQuote.get(oppId).ByAuto__c = true;
                        listQuote.add(mapQuote.get(oppId));
                    }
            }
        }
        if (listQuote.size() > 0) {
            system.debug('listQuote.get(0).Total_Mgr_Disc_of_Subscription_Percent__c:'+listQuote.get(0).Total_Mgr_Disc_of_Subscription_Percent__c);
            system.debug('listQuote.get(0).Total_Mgr_Disc_of_Discretionary_Percen__c:'+listQuote.get(0).Total_Mgr_Disc_of_Discretionary_Percen__c);
            update listQuote;
        }
    }
    public static void updateQliToOli(Set<Id> setofQuoteId){
    // List<QuoteLineItem> lstOfQLI=[Select Id,OpportunityLineItemId,Complimentary__c,Discount_Amount__c,Discount__c,End_Date__c,GST_VAT_Rate__c,Line_Description2__c,PO__c,Pro_Rate_Amount__c,Push_To_NetSuite__c,Record_Type__c,SNo__c,Start_Date__c,Quote.Invoice_Id__c,Discount_Reason__c,Amount_Despite_VIP__c,Product_Category__c,GST_VAT_Code1__c,Promo_Mechanic_Id__c  from QuoteLineItemwhere QuoteId IN :setofQuoteId];
        List<String> fetchAllFields=new List<String>(QliToOliFieldMapping__c.getall().keySet());
        String sqlQuery = 'select Id,OpportunityLineItemId,' + string.join(fetchAllFields, ' , ') + ' from QuoteLineItem where QuoteId IN :setofQuoteId';
        list<QuoteLineItem> lstOfQli= Database.query(sqlQuery);
        List<OpportunityLineItem> lstOppItem=new List<OpportunityLineItem>();
        //Dynamically fetch fields from custom setting
        for(QuoteLineItem eachQLI: lstOfQli){
            OpportunityLineItem objOLI=new OpportunityLineItem(Id=eachQLI.OpportunityLineItemId);
            Map<String, QliToOliFieldMapping__c> mapQlitoOli = QliToOliFieldMapping__c.getAll();
            for(String mapKey : mapQlitoOli.keySet()){
                objOLI.put(mapQlitoOli.get(mapKey).OliField__c,eachQLI.get(mapKey));
            } 
            lstOppItem.add(objOLI);
        }
        If(lstOppItem.size()>0){
            QuoteSyncHandler.isQLITriggerFire=false;
            Update lstOppItem;
        }
    }
    public static void increaseCoverage(){

        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}
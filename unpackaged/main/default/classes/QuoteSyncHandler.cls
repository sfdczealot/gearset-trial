/*
Test Class -QuoteSyncHandlerTest, QuoteSyncHandler_Test_v2
*/
public class QuoteSyncHandler {
    
    public static Boolean isTriggerFire = true;
    public static Boolean isOLITriggerFire = true;
    public static Boolean isOppFire = true;
    public static Boolean isQLITriggerFire = true;
    
    public static void createQuote(List<Opportunity> oppList){
        
        Boolean runBatch = true;
        system.debug('--IsStringer--'+oppList[0].Opportunity_Type__c);
        for(Opportunity opp : oppList){
            if((opp.Order_Type_Clone__c == 'Contract - Renewal'|| opp.Order_Type_Clone__c == 'Contract - Upgrade' || opp.Opportunity_Type__c=='B2C - Renewal'|| opp.isBulkUpdate__c == true) ){//Dependency Stinger
                runBatch = false;
                break;
            }
        }
        system.debug('oppList@@ '+oppList);
        Map<Id,Id> OpportunityIdVsQuoteId = new Map<Id,Id>();
        List<Quote> createQuoteList = new List<Quote>();
        if(oppList[0].Opportunity_Type__c!='B2C - Renewal'){
            createQuoteList=quoteData(oppList,false);//Dependency Stinger
        }
        
        if(!createQuoteList.isEmpty())
            insert createQuoteList ;
        
        system.debug('createQuoteList@@@ '+createQuoteList);
        for(Quote qu : createQuoteList){
            // need to make change here
            if(qu.id != null){
                OpportunityIdVsQuoteId.put(qu.OpportunityId,qu.Id);
            }
        }
            
        if(!OpportunityIdVsQuoteId.IsEmpty() && runBatch )
            DataBase.executeBatch(new SychQuoteOppBatchClass(OpportunityIdVsQuoteId),1);
    }
    @InvocableMethod
    public static void updateQuoteCustomFields(List<Id> listOpId){
        
        List<Opportunity> opportunityRecord = queryOpportunities(listOpId);
        List<Quote> creteQuoteList = quoteData(opportunityRecord,true);
        
        if(!creteQuoteList.isEmpty()){
            update creteQuoteList;
            
        }
        
        
    }
    
    
    public static List<Quote> quoteData(List<Opportunity> oppList, Boolean isUpdate){
        List<Quote> quoteList = new List<Quote>();
        for(Opportunity op : oppList){
            
            if(op.RecordTypeId == '0127F000000K50eQAC' || op.RecordTypeId == '0127F000000K50jQAC'){
                
                Quote qu = new Quote();
                if(op.SyncedQuoteId != null)
                    qu.id = op.SyncedQuoteId;
                qu.OpportunityId = op.Id;
                qu.Name = op.Name;
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
                if(op.SyncedQuoteId == null)
                    qu.CreatedDate__c = system.today();
                qu.Quote_Type__c = op.Opportunity_Type__c;
                qu.User_Sales_Head__c = op.User_Sales_Head__c;
                qu.pricebook2id = op.pricebook2id;
                
                
                if(!isUpdate){
                    //qu.Sync_To_Opportunity__c = true;
                    quoteList.add(qu);
                }else if(op.SyncedQuoteId != null){
                    quoteList.add(qu);
                }
                
            }   
        }
        system.debug('quoteList >> '+quoteList);
        return quoteList;
    }
    public static List<Opportunity> queryOpportunities(List<Id> listOpId){
        
        return [select Id,Opportunity_Type__c,Order_Type_Clone__c  ,PriceBook2Id,SyncedQuoteId,Name,RecordTypeId,Account_Email__c,Account_Phone__c,Account_Rule_Code__c,Addressee__c,Agency_Name__c,Agent_Accepted_Time__c,Allowed_Payment_Type__c,Apply_VIP_Discount__c,Approval_Requester_Comment__c,Approval_Selector__c,Approval_Status__c,Billing_Contact__c,billing_OMC_Approved__c,Budget_Confirmed__c,ByAuto__c,Create_NS_Customer__c,Customer_PO__c,Discount_Remarks__c,Discovery_Completed__c,FOC_Approved__c,From_Button__c,Guruland_Link_Created_Date__c,Include_Subscription_Ext__c,IsClone__c,Is_Current_Subscription__c,Last_Outbound_Sync__c,Loss_Reason__c,Lost_Sub_Reason__c,Managerial_Approved__c,Memo__c,Months_Included__c,OMC_Approved_Date__c,OMC_Rejected_Reason__c,OMC_Submitted_Time__c,OMC_Urgent__c,Order_Date__c,Outbound_Sync_Error__c,Payment_Amount__c,Guruland_Quote_Link__c,Payment_Reference__c,Payment_Term__c,Payment_Time__c,PG_Tenure__c,Project_Opportunity_Amount__c,Pro_Rate__c,Push_Counter__c,Renewal_State__c,Re_print_Contract__c,ROI_Analysis_Completed__c,SO_Order__c,StageName,Submit_to_OMC_Manually__c,Subscription_Code__c,Subscription_End_Date__c,Sync_To_NetSuite__c,Total_Amount_Before_Discount_display__c,Total_Amount_of_FOC_Before_Discount_MY__c,Total_Complimentary_Value_display__c,Total_Discounted_Amount_display__c,Total_Gross_Amount_display__c,Total_Mgr_Disc_of_Discretionary_Amount__c,Total_Mgr_Disc_of_Discretionary_Percent__c,Total_Mgr_Disc_of_Subscription_Amount__c,Total_Mgr_Disc_of_Subscription_Percent__c,Total_Spending__c,Total_Tax_Amount_display__c,Upload_Tag__c,VIP_Approved__c,Subsidiary__c,User_Sales_Head__c,Celigo_Update__c,NetSuite_Sales_Order__c,NetSuite_Sync_Error__c,Push_To_NetSuite__c,Sync_In_Progress__c from Opportunity where Id=:listOpId limit 500000];
    }
    
    public static void sync(Set<Id> oliIds ){
                
        Map<String,String> mapOfOliIdVsQliIds = new Map<String,String>();
        for(QuoteLineItem qli: [Select id, Opportunity_Line_Item_ID__c from QuoteLineItem WHERE Opportunity_Line_Item_ID__c= :oliIds]){
            mapOfOliIdVsQliIds.put(qli.Opportunity_Line_Item_ID__c,qli.Id);
        }
        List<QuoteLineItem> updateQuoteLineItemList = new List<QuoteLineItem>();
        for(OpportunityLineItem oli : [select Id,Opportunity.StageName,Amount_Despite_VIP__c,PO__c,Child_Category__c,Complimentary__c,Discount__c,Discount_Amount__c,Discount_Reason__c,Discount_Remarks__c,End_Date__c,GST_VAT_Rate__c,Income_Account_Name__c,Line_Description2__c,Order_Type__c,Original_Price__c,Parent__c,Parent_Aggregated_Amount__c,Product_Category__c,Product_Type__c,Push_to_NetSuite__c,Record_Type__c,Rev_Terms_in_months__c,SNo__c,Start_Date__c from OpportunityLineItem where Id In : oliIds]){
            if(oli.Opportunity.StageName == 'Closed Lost' || oli.Opportunity.StageName == 'Closed Won'){
                QuoteLineItem qli = new QuoteLineItem();
                qli.Id = mapOfOliIdVsQliIds.get(oli.Id);
                qli.Amount_Despite_VIP__c = oli.Amount_Despite_VIP__c;
                qli.PO__c = oli.PO__c;
                qli.Child_Category__c = oli.Child_Category__c;
                qli.Complimentary__c = oli.Complimentary__c;
                qli.Discount__c = oli.Discount__c;
                qli.Discount_Amount__c = oli.Discount_Amount__c;
                qli.Discount_Reason__c = oli.Discount_Reason__c;
                qli.Discount_Remarks__c = oli.Discount_Remarks__c;
                qli.End_Date__c = oli.End_Date__c;
                qli.GST_VAT_Rate__c = oli.GST_VAT_Rate__c;
                qli.Income_Account_Name__c = oli.Income_Account_Name__c;
                qli.Line_Description2__c = oli.Line_Description2__c;
                qli.Order_Type__c = oli.Order_Type__c;
                qli.Original_Price__c = oli.Original_Price__c;
                qli.Parent__c = oli.Parent__c;
                qli.Parent_Aggregated_Amount__c = oli.Parent_Aggregated_Amount__c;
                qli.Product_Category__c = oli.Product_Category__c;
                qli.Product_Type__c = oli.Product_Type__c;
                qli.Push_to_NetSuite__c = oli.Push_to_NetSuite__c;
                qli.Record_Type__c = oli.Record_Type__c;
                qli.Rev_Terms_in_months__c = oli.Rev_Terms_in_months__c;
                qli.SNo__c = oli.SNo__c;
                qli.Start_Date__c = oli.Start_Date__c;
                if(mapOfOliIdVsQliIds.get(oli.Id) != null)
                  updateQuoteLineItemList.add(qli);
            }
        }
        if(!updateQuoteLineItemList.isEmpty())
            update updateQuoteLineItemList;
    }
    public static void syncQuoteToOpp(List<Id> oppId){
        
        system.debug('oppId<<<$$$ '+oppId);
        List<Opportunity> updateOppList = new List<Opportunity>();
        for(Quote qu : [select Id,OpportunityId from Quote where OpportunityId=: oppId]){
            
            updateOppList.add(new Opportunity(Id=qu.OpportunityId,syncedQuoteId=qu.Id));
        }
        if(!updateOppList.isEmpty())
            update updateOppList;
        system.debug('updateOppList)))$$$ '+updateOppList);
    }
    
}
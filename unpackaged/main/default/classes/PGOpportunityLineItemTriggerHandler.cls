/*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Apex class to handle DML of Opportunity Line Item
Inputs:        

Test Class: PGOpportunityLinItemTriggerHandler_Test
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
public class PGOpportunityLineItemTriggerHandler {
    //Static Variable to populate PGI IN OLI
    Public static Boolean isB2BPGI=false;
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to initialize page data 
Inputs:        oppId <string>: id of specified Opportunity

Return: OppTmpConstruct
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    
    public static void summarizeLineItem(list<OpportunityLineItem> listOppLineItem) {
        set<Id> setOppId = new set<Id>();
        set<Id> setOppLineIdDebug = new set<Id>();
        for (OpportunityLineItem row: listOppLineItem) {
            setOppId.add(row.OpportunityId);
            setOppLineIdDebug.add(row.Id);
        }
        system.debug('beforeFuture:'+setOppLineIdDebug);
        summarizeLineItemFuture(setOppId);
    }
    //Update Approved B2B Opportunity Approval Status to blank when OLI is deleted
    Public static Void B2BOpportunityStatus(List<OpportunityLineItem> listOppLineItem){
        system.debug('--inside B2BOpportunityStatus--'+listOppLineItem);
        Set<ID> OppId=new Set<ID>();
        List<Opportunity> lstOppToUpdate=new List<Opportunity>();
        if(listOppLineItem!=null && listOppLineItem.size()>0){
            For(OpportunityLineItem eacholi:listOppLineItem){
                OppId.add(eacholi.OpportunityId);
            }
            if(OppId.size()>0){
                List<Opportunity> lstOpp=[select Id,Approval_Status__c,recordType.Name from Opportunity where Id IN :OppId and recordType.Name='B2B'];
                if(lstOpp!=null && lstOpp.size()>0){
                    for(Opportunity eachopp:lstOpp){
                        if(eachopp.Approval_Status__c=='Director Approved'||eachopp.Approval_Status__c=='Country Manager Approved'||eachopp.Approval_Status__c=='CBO Approved'){
                            Opportunity obj=new Opportunity(ID=eachopp.Id);
                            obj.Approval_Status__c='';
                            lstOppToUpdate.add(obj);
                        }
                    }
                    if(lstOppToUpdate.size()>0){
                        try{
                            update lstOppToUpdate;
                        }catch(exception exp){
                            system.debug(exp.getMessage());
                        }
                    }
                }
            }
        }
    }
    
    
    
    @future(callout=true)
    public static void summarizeLineItemFuture(set<Id> setOppId) {
        map<Id, Opportunity> mapOpportunityOld = new map<Id, Opportunity>();
        map<Id, Opportunity> mapOpportunity = new map<Id, Opportunity>();
        map<Id, map<string, double>> mapOppTotalAmount = new map<Id, map<string, double>>();
        map<string, double> mapOppFieldAmount;
        list<Opportunity> listOpp = new list<Opportunity>();
        Opportunity opp;
        for (Id oppId: setOppId) {
            mapOpportunity.put(oppId, null);
        }
        for (Opportunity row: [select Id, Name, ByAuto__c, Total_Mgr_Disc_of_Subscription_Percent__c, Total_Mgr_Disc_of_Discretionary_Percent__c, Total_Mgr_Disc_of_Subscription_Amount__c, Total_Mgr_Disc_of_Discretionary_Amount__c, Count_of_Referral_Agent_Promotion__c, Total_Amount_of_FOC_Before_Discount_MY__c from Opportunity where Id in :mapOpportunity.keySet()]) {
            mapOpportunityOld.put(row.Id, row.clone(false, false, false, false));
            row.Total_Mgr_Disc_of_Subscription_Percent__c = 0;
            row.Total_Mgr_Disc_of_Discretionary_Percent__c = 0;
            row.Total_Mgr_Disc_of_Subscription_Amount__c = 0;
            row.Total_Mgr_Disc_of_Discretionary_Amount__c = 0;
            row.Count_of_Referral_Agent_Promotion__c = 0;
            row.Total_Amount_of_FOC_Before_Discount_MY__c = 0;
            
            mapOppFieldAmount = new map<string, double>();
            mapOppFieldAmount.put('Total_Mgr_Disc_of_Subscription_Real_Amount', 0);
            mapOppFieldAmount.put('Total_Mgr_Disc_of_Discretionary_Real_Amount', 0);
            mapOppFieldAmount.put('Total_Mgr_Disc_of_Subscription_Discounted_Amount', 0);
            mapOppFieldAmount.put('Total_Mgr_Disc_of_Discretionary_Discounted_Amount', 0);
            mapOppTotalAmount.put(row.Id, mapOppFieldAmount);
            
            mapOpportunity.put(row.Id, row);
        }
        
        for (OpportunityLineItem row: [select Id, OpportunityId, Name, Product_Category__c, UnitPrice, Quantity, Discounted_Amount__c, Amount__c, Discount_Reason__c from OpportunityLineItem where OpportunityId in :mapOpportunity.keySet()]) {
            opp = mapOpportunity.get(row.OpportunityId);
            opp.Count_of_Referral_Agent_Promotion__c += (row.Discount_Reason__c=='Agent Referral: Referee'?1:0);
            opp.Total_Mgr_Disc_of_Subscription_Amount__c += (row.Discount_Reason__c=='Managerial Discount' && row.Product_Category__c=='Subscription')?row.Amount__c:0;
            opp.Total_Mgr_Disc_of_Discretionary_Amount__c += (row.Discount_Reason__c=='Managerial Discount' && row.Product_Category__c=='Discretionary')?row.Amount__c:0;
            opp.Total_Amount_of_FOC_Before_Discount_MY__c += (row.Discount_Reason__c=='Goodwill/ Relationship Building' || row.Discount_Reason__c=='Others' || row.Discount_Reason__c=='Technical issues' || row.Discount_Reason__c=='Renewal EB Ad Credits')?row.UnitPrice*row.Quantity:0;
            system.debug('row.Discount_Reason__c:'+row.Discount_Reason__c);
            system.debug('opp.Total_Amount_of_FOC_Before_Discount_MY__c:'+opp.Total_Amount_of_FOC_Before_Discount_MY__c);
            mapOppFieldAmount = mapOppTotalAmount.get(row.OpportunityId);
            mapOppFieldAmount.put('Total_Mgr_Disc_of_Subscription_Real_Amount', (row.Discount_Reason__c=='Managerial Discount' && row.Product_Category__c=='Subscription')?(mapOppFieldAmount.get('Total_Mgr_Disc_of_Subscription_Real_Amount')+(row.UnitPrice*row.Quantity)):mapOppFieldAmount.get('Total_Mgr_Disc_of_Subscription_Real_Amount'));
            mapOppFieldAmount.put('Total_Mgr_Disc_of_Discretionary_Real_Amount', (row.Discount_Reason__c=='Managerial Discount' && row.Product_Category__c=='Discretionary')?(mapOppFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Real_Amount')+(row.UnitPrice*row.Quantity)):mapOppFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Real_Amount'));
            mapOppFieldAmount.put('Total_Mgr_Disc_of_Subscription_Discounted_Amount', (row.Discount_Reason__c=='Managerial Discount' && row.Product_Category__c=='Subscription')?(mapOppFieldAmount.get('Total_Mgr_Disc_of_Subscription_Discounted_Amount')+row.Discounted_Amount__c):mapOppFieldAmount.get('Total_Mgr_Disc_of_Subscription_Discounted_Amount'));
            mapOppFieldAmount.put('Total_Mgr_Disc_of_Discretionary_Discounted_Amount', (row.Discount_Reason__c=='Managerial Discount' && row.Product_Category__c=='Discretionary')?(mapOppFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Discounted_Amount')+row.Discounted_Amount__c):mapOppFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Discounted_Amount'));
            mapOppTotalAmount.put(row.OpportunityId, mapOppFieldAmount);
            opp.Total_Mgr_Disc_of_Subscription_Percent__c = (opp.Total_Mgr_Disc_of_Subscription_Amount__c>0)?(mapOppFieldAmount.get('Total_Mgr_Disc_of_Subscription_Discounted_Amount')/(mapOppFieldAmount.get('Total_Mgr_Disc_of_Subscription_Real_Amount')==0?1:mapOppFieldAmount.get('Total_Mgr_Disc_of_Subscription_Real_Amount'))*100):opp.Total_Mgr_Disc_of_Subscription_Percent__c;
            opp.Total_Mgr_Disc_of_Discretionary_Percent__c = (opp.Total_Mgr_Disc_of_Discretionary_Amount__c>0)?(mapOppFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Discounted_Amount')/(mapOppFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Real_Amount')==0?1:mapOppFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Real_Amount'))*100):opp.Total_Mgr_Disc_of_Discretionary_Percent__c;
            system.debug('Total_Mgr_Disc_of_Subscription_Real_Amount:'+mapOppFieldAmount.get('Total_Mgr_Disc_of_Subscription_Real_Amount'));
            system.debug('Total_Mgr_Disc_of_Subscription_Discounted_Amount:'+mapOppFieldAmount.get('Total_Mgr_Disc_of_Subscription_Discounted_Amount'));
            system.debug('---');
            system.debug('Total_Mgr_Disc_of_Discretionary_Real_Amount:'+mapOppFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Real_Amount'));
            system.debug('Total_Mgr_Disc_of_Discretionary_Discounted_Amount:'+mapOppFieldAmount.get('Total_Mgr_Disc_of_Discretionary_Discounted_Amount'));
            system.debug('___');
            system.debug('opp.Total_Mgr_Disc_of_Subscription_Percent__c:'+opp.Total_Mgr_Disc_of_Subscription_Percent__c);
            system.debug('opp.Total_Mgr_Disc_of_Discretionary_Percent__c:'+opp.Total_Mgr_Disc_of_Discretionary_Percent__c);
            system.debug('===');
            mapOpportunity.put(opp.Id, opp);
        }
        
        for (Id oppId: mapOpportunity.keySet()) {
            // Only update the Opportunity which is affected for the Count/Summarize Line Item
            if (mapOpportunityOld.get(oppId).Count_of_Referral_Agent_Promotion__c != mapOpportunity.get(oppId).Count_of_Referral_Agent_Promotion__c
                || mapOpportunityOld.get(oppId).Total_Mgr_Disc_of_Subscription_Amount__c != mapOpportunity.get(oppId).Total_Mgr_Disc_of_Subscription_Amount__c
                || mapOpportunityOld.get(oppId).Total_Mgr_Disc_of_Discretionary_Amount__c != mapOpportunity.get(oppId).Total_Mgr_Disc_of_Discretionary_Amount__c
                || mapOpportunityOld.get(oppId).Total_Amount_of_FOC_Before_Discount_MY__c != mapOpportunity.get(oppId).Total_Amount_of_FOC_Before_Discount_MY__c) {
                    // Set ByAuto__c to true so that no callout would be made upon the updation
                    mapOpportunity.get(oppId).ByAuto__c = true;
                    listOpp.add(mapOpportunity.get(oppId));
                }
        }
        if (listOpp.size() > 0) {
            system.debug('listOpp.get(0).Total_Mgr_Disc_of_Subscription_Percent__c:'+listOpp.get(0).Total_Mgr_Disc_of_Subscription_Percent__c);
            system.debug('listOpp.get(0).Total_Mgr_Disc_of_Discretionary_Percent__c:'+listOpp.get(0).Total_Mgr_Disc_of_Discretionary_Percent__c);
            update listOpp;
        }
    }
    
    public static void oli_history(Map<Id,OpportunityLineItem> newMap, Map<Id,OpportunityLineItem> oldMap, String actionType) {
        
        Schema.SObjectType OptyLineItemMap = Schema.getGlobalDescribe().get('OpportunityLineItem');
        Map<String, Schema.SObjectField> OptyLineItemFieldMap = OptyLineItemMap.getDescribe().fields.getMap();
        if(actionType == 'CREATE'){
            List<OLI_Field_History__c> oli_hist = new List< OLI_Field_History__c>();
            for(OpportunityLineItem oli : newMap.values()){
                Map<String, Object> newfieldsToValue = oli.getPopulatedFieldsAsMap();
                
                for (String fieldNamenew : newfieldsToValue.keySet()){
                    if(fieldNamenew != 'SystemModstamp' && fieldNamenew != 'LastModifiedDate' && fieldNamenew != 'LastModifiedById' && fieldNamenew != 'CreatedById'){
                        OLI_Field_History__c oli_hist_rec = new OLI_Field_History__c();
                        oli_hist_rec.Field_Name__c = OptyLineItemFieldMap.get(String.valueOf(fieldNamenew)).getDescribe().getLabel();
                        oli_hist_rec.Opportunity__c = String.valueOf(newfieldsToValue.get('OpportunityId'));
                        oli_hist_rec.LineId__c  = String.valueOf(newfieldsToValue.get('Id'));
                        oli_hist_rec.New_Value__c = String.valueOf(newfieldsToValue.get(fieldNamenew));
                        oli_hist_rec.Type__c = 'UPDATE';
                        oli_hist_rec.User__c  = String.valueOf(newfieldsToValue.get('CreatedById'));
                        oli_hist.add(oli_hist_rec);
                        
                    }
                }
            }
            
            if(oli_hist.size() > 0){
                insert oli_hist;
            }
            
        }
        if(actionType == 'UPDATE'){
            List<OLI_Field_History__c> oli_hist = new List< OLI_Field_History__c>();
            for(OpportunityLineItem newItem : newMap.values()){
                OpportunityLineItem olditem = oldMap.get(newItem.Id);
                Map<String, Object> newfieldsToValue = newitem.getPopulatedFieldsAsMap();
                Map<String, Object> oldfieldsToValue = olditem.getPopulatedFieldsAsMap();
                system.debug('fields:' + newfieldsToValue);
                
                for (String fieldNameold : oldfieldsToValue.keySet()){
                    for (String fieldNamenew : newfieldsToValue.keySet()){
                        if(fieldNameold == fieldNamenew && fieldNameold != 'SystemModstamp' && fieldNameold != 'LastModifiedDate'){
                            if(oldfieldsToValue.get(fieldNameold) != newfieldsToValue.get(fieldNamenew)){
                                OLI_Field_History__c oli_hist_rec = new OLI_Field_History__c();
                                oli_hist_rec.Field_Name__c = OptyLineItemFieldMap.get(String.valueOf(fieldNamenew)).getDescribe().getLabel();
                                oli_hist_rec.Opportunity__c = String.valueOf(newfieldsToValue.get('OpportunityId'));
                                oli_hist_rec.LineId__c  = String.valueOf(newfieldsToValue.get('Id'));
                                oli_hist_rec.Old_Value__c = String.valueOf(oldfieldsToValue.get(fieldNameold));
                                oli_hist_rec.New_Value__c = String.valueOf(newfieldsToValue.get(fieldNamenew));
                                oli_hist_rec.Type__c = 'UPDATE';
                                oli_hist_rec.User__c  = String.valueOf(newfieldsToValue.get('LastModifiedById'));
                                oli_hist.add(oli_hist_rec);
                            }
                        }
                    }
                }
            }
            if(oli_hist.size() > 0){
                insert oli_hist;
            }
        }
        
        if(actionType == 'DELETE'){
            List<OLI_Field_History__c> oli_hist = new List< OLI_Field_History__c>();
            for(OpportunityLineItem oli : oldMap.values()){
                OLI_Field_History__c oli_hist_rec = new OLI_Field_History__c();
                oli_hist_rec.Opportunity__c = String.valueOf(oli.OpportunityId);
                oli_hist_rec.LineId__c  = oli.Id;
                oli_hist_rec.Old_Value__c = String.valueOf(oli);
                oli_hist_rec.Type__c = 'DELETE';
                oli_hist_rec.User__c  = String.valueOf(oli.LastModifiedById);
                oli_hist.add(oli_hist_rec);
                
            }
            if(oli_hist.size() > 0){
                insert oli_hist;
            }
        }
    }
    
}
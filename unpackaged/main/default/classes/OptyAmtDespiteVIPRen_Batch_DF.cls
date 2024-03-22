global class OptyAmtDespiteVIPRen_Batch_DF implements Database.Batchable<sObject>{
    
    String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        
        String def_query = label.PG_LABEL_OptyAmtDespiteVIPRen_Batch_DF_q;
        if(def_query != ''){
          query = def_query;
        }
        else{
          query = 'select id from Account where (Status__c != \'Cancelled\' AND Status__c != \'Suspended\' AND Status__c != \'Expired\') and Customer_Type__c = \'Agent\'';
        }
        //query = select id from Account where (Status__c != 'Cancelled' AND Status__c != 'Suspended' AND Status__c != 'Expired');
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Account> AccList) {
        Integer amt_d_vip = 0;
        
        system.debug('size ren:'+AccList.size());
        if(AccList.size() > 0){
            for(Account acct: AccList){
                system.debug('acct ren: ' + acct.id);
                for(Opportunity OptyUpd: [select Id,Pro_Rate__c,Payment_Amount__c from Opportunity where AccountId = :acct.id and Order_Type_Clone__c  = 'Contract - Renewal' and StageName = 'Closed Won' Order By OMC_Approved_Date__c DESC NULLS LAST LIMIT 1]){
                    system.debug('OptyUpd:' + OptyUpd);
                    for(OpportunityLineItem OptyUpdAmt: [Select id, Push_to_NetSuite__c, Amount_Despite_VIP__c, Discount_Reason__c, Pro_Rate_Amount__c, UnitPrice, Amount__c   from OpportunityLineItem where Opportunityid =: OptyUpd.Id and Product_Category__c = 'Subscription' AND Complimentary__c = false and Push_to_NetSuite__c =true]){
                        /*system.debug('OptyUpd:' + OptyUpdAmt);
                        Decimal PAmount = 0.00;
                        if(OptyUpd.Payment_Amount__c > 0){
                            if(OptyUpd.Payment_Amount__c < OptyUpdAmt.UnitPrice){
                                if(OptyUpd.Pro_Rate__c > 0){
                                    OptyUpdAmt.Discount_Amount__c  = ((OptyUpdAmt.UnitPrice-OptyUpd.Pro_Rate__c) - OptyUpd.Payment_Amount__c);
                                }
                                else{
                                    OptyUpdAmt.Discount_Amount__c  = (OptyUpdAmt.UnitPrice - OptyUpd.Payment_Amount__c);
                                }
                            }
                        }
                        else{
                            for(Payment__c paymentrec:[Select id, Amount2__c from Payment__c where Opportunity_Record__c = :OptyUpd.Id]){
                                PAmount += paymentrec.Amount2__c;
                            }
                            system.debug('PAmount:' + PAmount);
                            if(PAmount > 0){
                                if(PAmount < OptyUpdAmt.UnitPrice){
                                    if(OptyUpd.Pro_Rate__c > 0){
                                        OptyUpdAmt.Discount_Amount__c  = ((OptyUpdAmt.UnitPrice-OptyUpd.Pro_Rate__c) - PAmount);
                                    }
                                    else{
                                        OptyUpdAmt.Discount_Amount__c  = (OptyUpdAmt.UnitPrice - PAmount);
                                    }
                                }
                            }
                        }
                        OptyUpdAmt.Push_to_NetSuite__c = true;
                        OptyUpdAmt.SNo__c  = 1.00;
                        for(OpportunityLineItem OptyCheck: [Select id,Start_Date__c,End_Date__c,PO__c from OpportunityLineItem where id != :OptyUpdAmt.id and Opportunityid =: OptyUpd.Id LIMIT 1]){
                            system.debug('OptyCheck:' + OptyCheck);
                            OptyUpdAmt.Start_Date__c = OptyCheck.Start_Date__c;
                            OptyUpdAmt.End_Date__c = OptyCheck.End_Date__c ;
                            OptyUpdAmt.PO__c  = OptyCheck.PO__c;
                        }
                        system.debug('OptyUpdAmt Upd:' + OptyUpdAmt);
                        update OptyUpdAmt;*/
                        
                        if((OptyUpdAmt.Discount_Reason__c != '' && OptyUpdAmt.Discount_Reason__c != null)){
                            if((OptyUpdAmt.Discount_Reason__c).contains('VIP')){
                                OptyUpdAmt.Amount_Despite_VIP__c = OptyUpdAmt.UnitPrice;
                                OptyUpdAmt.Pro_Rate_Amount__c = 0;
                            }
                        }
                        else{
                            OptyUpdAmt.Amount_Despite_VIP__c = OptyUpdAmt.Amount__c;
                            OptyUpdAmt.Pro_Rate_Amount__c = 0;
                        }
                        update OptyUpdAmt;
                    }
                }
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
            
    }
    
}
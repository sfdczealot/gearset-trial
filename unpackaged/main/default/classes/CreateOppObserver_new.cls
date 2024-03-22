global class CreateOppObserver_new  extends CS_QueueableWorker {
    public List<Id> basketIds;
    // params new Map<String, Object>
    global CreateOppObserver_new (Object params) {
        super('CreateOppObserver_new', params);
    }
    
    
    public override void doWork() {
        Map<String, Object> paramsType = (Map<String, Object>) this.params;
        List<Id> bids  = (List<Id>) paramsType.get('basketIds');
        this.basketIds = bIds;
        
        List<cscfga__Product_Basket__c> allBaskets = new List<cscfga__Product_Basket__c>();
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>();
        Map<Id, Opportunity> basketIdToOpp =  new Map<Id, Opportunity>();
        Map<String, Decimal> basketPrice =  new Map<String, Decimal>();
        Map<String, cscfga__Product_Basket__c> basketToOpp =  new Map<String, cscfga__Product_Basket__c>();
        Set<String> paymentMethodNames = new Set<String>();
        List<Opportunity> OppList =  new List<Opportunity>();
        List<Payment__c> paymentList = new List<Payment__c>();
        Map<String, Id> paymentMap = new Map<String, Id>();
        List<Payment_Method__c> paymentMethodList = new List<Payment_Method__c>();
        List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>();
        List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
        Set<Id> commIds = new Set<Id>();
        Map<Id, cspmb__Price_Item__c> commProdGstId = new Map<Id, cspmb__Price_Item__c>();
        Map<Id, cscfga__Attribute__c> pcAttrMap = new Map<Id, cscfga__Attribute__c>();
        List<csb2c__Inbound_Ecommerce_Order_Request__c> ecomm = new List<csb2c__Inbound_Ecommerce_Order_Request__c>();
        Map<String,String> commprodMap = new  Map<String,String>();
         Map<String,String> PromoIDMap = new  Map<String,String>();
        List<Updates_On_Closed_Won__e> listOfEvents = new List<Updates_On_Closed_Won__e>();
        String accCountry = '';
        
        // to store all existing Opp with basket uniqueID.
        Map<String,Opportunity> existingOppMap = new Map<String,Opportunity>();
        //to store basket unique id and SF basketID.
        Map<String,Id> BasketAPIMap = new Map<String,Id>();
        // to store all existing Opp with basket.MarketAutomation
        Map<String,String> marketAutomationAgentCamp= new Map<String,String>();
        // to store all agents with opp
        Map<String,Opportunity> existingAgentOppMap = new Map<String,Opportunity>();
        // Map<String,String> oppCampMap = new Map<String,String>();
        //Map<String,String> contactCampIDMap = new Map<String,String>();
        Set<String> existingOppList = new Set<String>();
        List<CampaignInfluence> campInfluenceList = new List<CampaignInfluence>();
        Savepoint sp = Database.setSavepoint();
        Set<String> promoIDs = new Set<String>();
        String contactid;
        //ensures basket totals are calculated
        cscfga.ProductConfigurationBulkActions.calculateTotals(new Set<Id>(this.basketIds));
        Boolean isRenewal = false;
        allBaskets = [SELECT Id, Name, OwnerId, cscfga__Total_Price__c, Payment_Amount__c, Appr_Code__c,Bank_Name__c,Installment_Period__c,
                      Payment_Date__c, Payment_Reference__c, Payment_Gateway__c, cscfga__Opportunity__c,promotion_ids__c,
                      cscfga__Opportunity__r.StageName,cscfga__Opportunity__r.Opportunity_type__c,Marketing_Automation_Identifier__c,
                      cscfga__Opportunity__r.recordTypeId,cscfga__Opportunity__r.BasketId__c,Payment_Mode__c, EcomReference__c,
                      (SELECT Id, Name, csb2c__Account__c, csb2c__API_Basket_ID__c,csb2c__Account__r.Country__c,csb2c__Account__r.OwnerId, 
                       csb2c__E_Commerce_Customer_Id__c,csb2c__Account__r.agentkey__c,csb2c__Account__r.PersonContactId,csb2c__Account__r.UUId__c, 
                       csb2c__Account__r.agentNet_id__c 
                       FROM csb2c__Inbound_Ecommerce_Order_Requests1__r),
                      (SELECT id, cscfga__Unit_Price__c FROM cscfga__Product_Configurations__r) ,cscfga__Products_In_Basket__c
                      FROM cscfga__Product_Basket__c WHERE Id IN: basketIds];
        try { 
            contactid = allBaskets[0].csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__Account__r.PersonContactId;
            if(allBaskets[0].promotion_ids__c!=null){
            promoIDs.addAll(allBaskets[0].promotion_ids__c.split(','));
            }
            Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Self-Serve').getRecordTypeId();
            String modelId = [SELECT Id, DeveloperName FROM CampaignInfluenceModel where DeveloperName = 'Observer_Model'].Id;
            for (cscfga__Product_Basket__c basket : allBaskets) {
                basketAPIMap.put(basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__API_Basket_ID__c,basket.Id);
                if(basket.Marketing_Automation_Identifier__c != null){
                    marketAutomationAgentCamp.put(basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__Account__r.AgentKey__c,
                                                  basket.Marketing_Automation_Identifier__c);
                }
            }
            if(!basketAPIMap.IsEmpty() && basketAPIMap.size() > 0){
                if(allBaskets[0].cscfga__Products_In_Basket__c.contains('[B2C subscription]') ){
                    isRenewal = true;
                    for(Opportunity opp : [select id,basketId__c,name,ownerid,SyncedQuoteId ,(select id from quotes),
                                           (Select id from opportunityLineItems) from opportunity where 
                                           stageName  in ('Proposal','New','Pending Online Payment') and
                                           Agent_Accepted_Time__c=null
                                           and Accountid =: allBaskets[0].csb2c__Inbound_Ecommerce_Order_Requests1__r[0]
                                           .csb2c__Account__c 
                                           and renewal_state__c != null]){
                                               existingOppMap.put(allBaskets[0].csb2c__Inbound_Ecommerce_Order_Requests1__r[0]
                                                                  .csb2c__API_Basket_ID__c,opp);
                                           }
                }
                else {
                    for(Opportunity opp : [select id,basketId__c,name,ownerid from opportunity where
                                           basketId__c in : BasketAPIMap.keySet()]){
                                               existingOppMap.put(opp.BasketId__c,opp);
                                           }
                }
            }
            system.debug('marketAutomationAgentCamp'+marketAutomationAgentCamp);
            if(!marketAutomationAgentCamp.IsEmpty() && marketAutomationAgentCamp.size() > 0){
                for(Opportunity opp : [select id,campaignId,Account.AgentKey__c,Name,Account.PersonContactId,ownerid
                                       /*, (select id,CampaignId,opportunityid,contactId from campaignInfluences)*/
                                       from opportunity where
                                       stageName = 'New' and RecordTypeId = :devRecordTypeId and
                                       CampaignId in :marketAutomationAgentCamp.Values() and
                                       Account.AgentKey__c in : marketAutomationAgentCamp.keySet()
                                      ]){
                                          
                                          if(opp.CampaignId == marketAutomationAgentCamp.get(opp.Account.AgentKey__c)){
                                              existingAgentOppMap.put(opp.Account.AgentKey__c,opp);
                                              
                                          }
                                      }
            }
            
            Product2 Product = [SELECT Id, Name FROM Product2 WHERE name = 'PGSG Ad Credit (1 Credit)' LIMIT 1];
           Product2 primeCred = [SELECT Id, Name FROM Product2 WHERE name = 'PGSG Prime Credit' limit 1];
            Product2 discountProduct = [SELECT Id, Name FROM Product2 WHERE name = 'Rounding Adjustment' LIMIT 1];
            PriceBook2 priceBook = [SELECT Id, Name FROM PriceBook2 WHERE name = 'PG SG' LIMIT 1];          
            PricebookEntry ProdEntry = [SELECT  Id, Name FROM PricebookEntry WHERE Product2Id =: Product.Id and pricebook2Id =: priceBook.Id LIMIT 1];
            PricebookEntry primeCredEntry = [SELECT  Id, Name FROM PricebookEntry WHERE Product2Id =: primeCred.Id and pricebook2Id =: priceBook.Id LIMIT 1];
            PricebookEntry discountProdEntry = [SELECT  Id, Name FROM PricebookEntry WHERE Product2Id =: discountProduct.Id and pricebook2Id =: priceBook.Id LIMIT 1];
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            for (cscfga__Product_Basket__c basket : allBaskets) {
                
                ecomm = basket.csb2c__Inbound_Ecommerce_Order_Requests1__r;
                accCountry = ecomm[0].csb2c__Account__r.Country__c;
                pcList = basket.cscfga__Product_Configurations__r;
                decimal totalPrice = basket.cscfga__Total_Price__c != null? basket.cscfga__Total_Price__c: 0.0;
                Boolean oppExist = false;
                
                if(!existingAgentOppMap.isEmpty() && existingAgentOppMap.size() > 0){
                    if(basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__Account__c!=null){
                        if(existingAgentOppMap.containsKey(basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__Account__r.AgentKey__c)){
                            Opportunity opp = existingAgentOppMap.get(basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__Account__r.AgentKey__c);
                            if(opp.CampaignId == basket.Marketing_Automation_Identifier__c){
                                oppExist = true;
                                opp.stageName='Converted';
                                opp.Sync_To_NetSuite__c=true;
                                opp.CloseDate = Date.today();
                                opp.invoice_id__c= basket.EcomReference__c;
                                // opp.OMC_Approved_Date__c = system.now();
                                opp.Order_date__c=basket.Payment_Date__c;
                                opp.OwnerId = basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__Account__r.OwnerId;
                                opp.BasketId__c=basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__API_Basket_ID__c;
                                
                                OppList.add(opp); 
                                existingOppList.add(opp.id);
                                basketIdToOpp.put(basket.Id, opp);
                                basketPrice.put(opp.Name, basket.cscfga__Total_Price__c);
                                basketToOpp.put(opp.Name, basket);
                                listOfEvents.add(new Updates_On_Closed_Won__e(
                                    Is_Self_Serve__c = true,
                                    Opportunity_Id__c = opp.Id
                                ));
                                
                                
                                
                            }
                        }
                    }
                }
                //check if existingOppMap is not Null
                if(!existingOppMap.isEmpty()  && existingOppMap.size() > 0 && !oppExist){
                    //check if Opp with basketId matches with basketAPIID
                    if(existingOppMap.containsKey(basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__API_Basket_ID__c)){
                        oppExist = true;
                        Opportunity opp = existingOppMap.get(basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__API_Basket_ID__c);
                        opp.stageName =  'Converted';
                        opp.Sync_To_NetSuite__c=true;
                        opp.CloseDate = Date.today();
                        opp.invoice_id__c= basket.EcomReference__c;
                        if(isrenewal){
                            opp.SyncedQuoteId =null;
                            opp.RecordTypeId = devRecordTypeId;
                            opp.BasketId__c=basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__API_Basket_ID__c;
                        }
                        //opp.OMC_Approved_Date__c = system.now();
                        opp.Order_date__c=basket.Payment_Date__c;
                        OppList.add(opp); 
                        basketIdToOpp.put(basket.Id, opp);
                        basketPrice.put(opp.Name, basket.cscfga__Total_Price__c);
                        basketToOpp.put(opp.Name, basket);
                        listOfEvents.add(new Updates_On_Closed_Won__e(
                            Is_Self_Serve__c = true,
                            Opportunity_Id__c = opp.Id
                        ));
                    }
                } 
                
                if(!oppExist) {
                    String oppType = 'Self-Serve Standard';
                    if(isRenewal){
                        oppType = 'Self-Serve Renewal';
                    }
                    Opportunity newOpp = new Opportunity (
                        AccountId = basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__Account__c,
                        Description = 'Opportunity',
                        Name = basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__E_Commerce_Customer_Id__c + ' purchased ' +
                        + basket.EcomReference__c + ' @  S$' + totalPrice,
                        StageName ='Converted',
                        invoice_id__c= basket.EcomReference__c,
                        BasketId__c = basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__API_Basket_ID__c,
                        CloseDate = Date.today(),
                        // OMC_Approved_Date__c = system.now(),
                        recordtypeId = devRecordTypeId,
                        Order_date__c=basket.Payment_Date__c,
                        OwnerId = basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__Account__r.OwnerId,
                        pricebook2Id = priceBook.Id,
                        Opportunity_Type__c=oppType,
                        Sync_To_NetSuite__c=true);
                    
                    OppList.add(newOpp);
                    basketIdToOpp.put(basket.Id, newOpp);
                    basketPrice.put(newOpp.Name, basket.cscfga__Total_Price__c);
                    basketToOpp.put(newOpp.Name, basket);
                    listOfEvents.add(new Updates_On_Closed_Won__e(
                        Is_Self_Serve__c = true,
                        Opportunity_Id__c = newOpp.Id
                    ));
                }
            }
            upsert OppList;
            system.debug('****'+oppList);
            List<Quote> invalidateQuote = new List<Quote>();
            List<OpportunityLineItem> delOLI = new List<OpportunityLineItem>();
            for(Opportunity o : oppList){
                if(existingOppMap.containsKey(o.BasketId__c)){
                    if(existingOppMap.get(o.BasketId__c).Quotes!=null){
                        invalidateQuote.addAll(existingOppMap.get(o.BasketId__c).Quotes);
                        delOLI.addAll(o.OpportunitylineItems);
                    }
                }
            }
            for(Quote q : invalidateQuote){
                q.loss_reason__c ='Transacted via Self-Serve';
                q.status='Invalid';
            //    q.IsSyncing=false;
            }
            update invalidateQuote;
            delete  delOLI;
            for(opportunity opp : oppList){
                batchInputs.add( postChatter(opp,isRenewal));
            }
            if(!test.isRunningTest() && batchInputs.size() > 0){
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
            }
            // List<CampaignMember> cmList = new List<CampaignMember>();
            /* if(!contactCampIDMap.isEmpty() && contactCampIDMap.size() > 0){
for(CampaignMember cm: [Select id,CampaignId,ContactId,status from campaignMember 
where CampaignId in :contactCampIDMap.values()
and ContactID in: contactCampIDMap.keySet()]){
if(contactCampIDMap.containsKey(cm.contactId)){
if(contactCampIDMap.get(cm.contactId) == cm.CampaignId){
cm.status='Converted';
cmList.add(cm);
}
}
}
} */
            /*if(!cmList.isEmpty() && cmList.size() > 0){
update cmList;
}*/
            
            List<task> taskList = [select id from task where status != 'Completed' and Whatid in: existingOppList and 
                                   subject in ('Marketing Automation Failed Payment Follow-up','Marketing Automation Inactive Basket Follow-up')];
            for(Task t : taskList){
                t.status ='Complete';
            }
            if (!taskList.isEmpty() && taskList.size() > 0){
                update taskList;
            }
            List<cscfga__Product_Configuration__c> pcAttrList = [Select Id, name, cscfga__Quantity__c, Start_Date__c, cscfga__Unit_Price__c,
                                                                 End_Date__c,cscfga__Product_Family__c, 
                                                                 cscfga__Parent_Configuration__c,flight_end__c,flight_begin__c,
                                                                 cscfga__Product_Basket__r.cscfga__Opportunity__c,
                                                                 cscfga__Product_Basket__r.cscfga__Opportunity__r.Name,
                                                                 (Select Id, name, cscfga__Price__c, cscfga__List_Price__c, 
                                                                  cscfga__Value__c, cscfga__Is_Line_Item__c from 
                                                                  cscfga__Attributes__r order by name desc) 
                                                                 from cscfga__Product_Configuration__c where 
                                                                 Id IN: pcList];
            system.debug('pcList===' + pcList + '---size---' + pcList.size());
            //helper map to caclualate OLI quantiy via included_unit X quantity, so expecting 2 entries
            Map<Id,Decimal> pcQuantitySetMap = new Map<Id, Decimal>();
            list<String> commSKU = new List<String>();
            for(cscfga__Product_Configuration__c pc : pcAttrList){
                pcQuantitySetMap.put(pc.Id,1);
                
                for(cscfga__Attribute__c att : pc.cscfga__Attributes__r){
                    if((att.name == 'Offering' || att.Name == 'Related product') && att.cscfga__Is_Line_Item__c ){
                        commIds.add(att.cscfga__Value__c);
                    }
                      if(att.Name == '__SKU__') {
                          commSKU.add(att.cscfga__Value__c);
                      }
                    if(att.Name == 'Included Units') {
                        pcQuantitySetMap.put(pc.Id, (pc.cscfga__Quantity__c * Decimal.valueOf(att.cscfga__Value__c) ) );
                    }
                    if(att.Name == 'Count') {
                        pcQuantitySetMap.put(pc.Id,  Decimal.valueOf(att.cscfga__Value__c)  );
                    }
                    if(att.Name == 'Promotion Ids' && String.isNotBlank(att.cscfga__Value__c) ) {
                        promoIDs.addAll(att.cscfga__Value__c.split(','));
                    }
                }
            }
            
            for(cspmb__Price_Item__c commProdList : [Select id, Tax_Code__c, Tax_Code__r.Tax_Rate__c,  Income_Account__c, cspmb__Price_Item_Code__c,SKU_Code__c,
                                                     Product_Category__c from cspmb__Price_Item__c where Id In: commIds]){
                                                         commProdGstId.put(commProdList.id, commProdList);
                                                         commprodMap.put(commProdList.id,commProdList.SKU_Code__c);
                                                     }
            system.debug(commprodMap.values());
            List<Product2> SubsProduct =[Select id,Name,SKU_Code__c from product2 
                                         where SKU_Code__c in: commprodMap.values()];
            Map<String,STring> prodSKUMap = new   Map<String,STring> ();
            Map<String,STring> priceBookSKUMap = new   Map<String,STring> ();
            for(Product2 prod : SubsProduct) {
                prodSKUMap.put(prod.SKU_Code__c,prod.id);
            }
            for(PricebookEntry pbe : [SELECT  Id, Name,Product2Id FROM PricebookEntry 
                                      WHERE Product2Id in: prodSKUMap.values() 
                                      and pricebook2Id =: priceBook.Id]){
                                          priceBookSKUMap.put(pbe.Product2Id+'',pbe.id+'');
                                      }  
            paymentMethodList = [Select id, name from Payment_Method__c];
            for(Payment_Method__c payment : paymentMethodList){
                paymentMap.put(payment.Name, payment.Id);
            }
            
            if(!OppList.isEmpty() && OppList.size() > 0){
                for(Opportunity opp: OppList){
                    cscfga__Product_Basket__c basket = basketToOpp.get(opp.Name);
                    if(basket.Payment_Amount__c != 0){
                        Payment__c pay = new Payment__c();
                        pay.Opportunity_Record__c = opp.Id;
                        pay.Amount2__c = basket.Payment_Amount__c;
                        pay.Appr_Code__c = basket.Appr_Code__c;
                        pay.Payment_Date__c = basket.Payment_Date__c;
                        pay.Payment_Gateway__c = basket.Payment_Gateway__c;
                        pay.Reference_Number__c = basket.Payment_Reference__c;
                        if(basket.Payment_Gateway__c == 'Adyen'){
                            if(accCountry == 'Singapore' && paymentMap.containsKey('Adyen (SG)')){
                                pay.Payment_Method__c = paymentMap.get('Adyen (SG)');
                            }else if(accCountry == 'Malaysia' && paymentMap.containsKey('Adyen (MY)')){
                                pay.Payment_Method__c = paymentMap.get('Adyen (MY)');
                            }else if(accCountry == 'Indonesia' && paymentMap.containsKey('Adyen (ID)')){
                                pay.Payment_Method__c = paymentMap.get('Adyen (ID)');
                            }else if(accCountry == 'Thailand' && paymentMap.containsKey('Adyen (TH)')){
                                pay.Payment_Method__c = paymentMap.get('Adyen (TH)');
                            }
                        }
                        if(basket.Payment_Gateway__c == 'Braintree' && paymentMap.containsKey('Braintree')){
                            pay.Payment_Method__c = paymentMap.get('Braintree');
                        }
                        if(basket.Payment_Gateway__c == 'Paypal' && paymentMap.containsKey('Paypal')){
                            pay.Payment_Method__c = paymentMap.get('Paypal');
                        }
                        if(basket.Payment_Gateway__c == '2c2p') {
                            if (basket.Bank_Name__c.contains('UOB') && basket.Installment_Period__c == '6') {
                                pay.Payment_Method__c = paymentMap.get('UOB 6 Month Installment_Online');
                            } else if (basket.Bank_Name__c.contains('UOB') && basket.Installment_Period__c== '12') {
                                pay.Payment_Method__c = paymentMap.get('UOB 12 Month Installment_Online');
                            }
                        }
                        if(basket.Payment_Gateway__c == 'enets') {
                            if (basket.Bank_Name__c.contains('DBS') && basket.Installment_Period__c == '6') {
                                pay.Payment_Method__c = paymentMap.get('DBS 6 Month Installment');
                            } else if (basket.Bank_Name__c.contains('DBS') && basket.Installment_Period__c == '12') {
                                pay.Payment_Method__c = paymentMap.get('DBS 12 Month Installment');
                            }
                        }
                        pay.Payment_Mode__c = basket.Payment_Mode__c;
                        paymentList.add(pay);    
                    }
                }
            }
            if(!paymentList.isEmpty() && paymentList.size() > 0){
                insert paymentList;
            }
            
            for (cscfga__Product_Basket__c basket : allBaskets) {
                basket.cscfga__Opportunity__c = basketIdToOpp.get(basket.Id).Id;
                if(basket.cscfga__Product_Configurations__r.size() > 0)
                    basket.PC_Count__c = basket.cscfga__Product_Configurations__r.size();
            }
            update allBaskets;
            
            basketList = [SELECT Id, Name, cscfga__Opportunity__c, cscfga__Opportunity__r.Name,
                          (SELECT id, Name, cscfga__Quantity__c, cscfga__Unit_Price__c, End_Date__c, Start_Date__c 
                           FROM cscfga__Product_Configurations__r) 
                          FROM  cscfga__Product_Basket__c
                          WHERE Id IN: basketIds];
            
            Decimal sno = 0;
            List<OpportunityLineItem> allOLIs = new List<OpportunityLineItem>();
            
            for(cscfga__Product_Configuration__c pc : pcAttrList){
                Decimal discountMultiplier;
                for(cscfga__Attribute__c attr : pc.cscfga__Attributes__r){

                    if( pc.cscfga__Parent_Configuration__c != null &&
                       attr.Name == 'Sno.' && attr.cscfga__Value__c!=null){
                          sno = decimal.valueOf(attr.cscfga__Value__c); 
                       }
                    //  system.debug('** '+attr.name);
                        if(attr.name == 'Adjustment' && attr.cscfga__Value__c != null){
                            system.debug('adjustment ***');
                           discountMultiplier = Decimal.valueOf(attr.cscfga__Value__c);
                        }
                       
                    if(attr.cscfga__Is_Line_Item__c){
                        if( pc.cscfga__Parent_Configuration__c == null)
                            sno = sno + 1;
                        OpportunityLineItem oli = new OpportunityLineItem ();
                        if(pc.Name== 'Discount'){
                            oli.Product2Id = discountProduct.Id;
                            oli.PricebookEntryId = discountProdEntry.Id;
                        } else if(isrenewal){
                            system.debug(ProdSKUMap);
                            system.debug(commProdMap);
                            system.debug(priceBookSKUMap);
                            system.debug(attr.cscfga__Value__c);
                            oli.Product2Id = ProdSKUMap.get(commProdMap.get(attr.cscfga__Value__c));
                            oli.PricebookEntryId = priceBookSKUMap.get(oli.product2Id);
                        } else if(pc.name.toLowerCase().contains('prime credit')){
                            oli.Product2Id = primeCred.id;
                            oli.PricebookEntryId = primeCredEntry.id;
                        }
                        else{
                            oli.Product2Id = Product.Id;
                            oli.PricebookEntryId = ProdEntry.Id;
                        }
                        //oli.TotalPrice = basketPrice.get(pc.cscfga__Product_Basket__r.cscfga__Opportunity__r.Name);
                        oli.OpportunityId = OppList[0].Id;
                        oli.Quantity = pcQuantitySetMap.get(pc.Id);
                        oli.UnitPrice = (pc.cscfga__Unit_Price__c * pc.cscfga__Quantity__c / oli.Quantity );
                       
                        if(pc.Start_Date__c==null)
                            oli.start_date__c=pc.flight_begin__c;
                        else
                            oli.Start_Date__c = pc.Start_Date__c;
                        if(pc.End_Date__c==null)
                            oli.End_Date__c = pc.flight_end__c;
                        else
                            oli.End_Date__c = pc.End_Date__c;
                      oli.Commercial_Product__c = attr.cscfga__Value__c;
                        if(commProdGstId.containsKey(attr.cscfga__Value__c)){
                            cspmb__Price_Item__c price = commProdGstId.get(attr.cscfga__Value__c);
                            if(Label.Allow_Tax_Code_for_GST_SS  == 'Yes')
                                oli.GST_VAT_Code__c = Label.Tax_Code_for_GST_SS ;// price.Tax_Code__c;
                            else
                                oli.GST_VAT_Code__c = price.Tax_Code__c;
                            oli.Income_Account_Name__c = price.Income_Account__c;
                            oli.GST_VAT_Rate__c = price.Tax_Code__r.Tax_Rate__c;
                            oli.Product_Category__c = price.Product_Category__c;
                        }
                        //  }
                        if(attr.cscfga__Price__c != null && attr.cscfga__List_Price__c != null
                           && attr.cscfga__Price__c != attr.cscfga__List_Price__c){
                               oli.Discount_Amount__c = (attr.cscfga__List_Price__c - attr.cscfga__Price__c) 
                                   * pc.cscfga__Quantity__c;
                               oli.UnitPrice = (attr.cscfga__List_Price__c* pc.cscfga__Quantity__c / oli.Quantity );
                               //oli.UnitPrice = attr.cscfga__List_Price__c;
                           }
                         if(discountMultiplier != null ){
                            system.debug(oli.UnitPrice );
                            oli.Discount_Amount__c = oli.UnitPrice - ( oli.UnitPrice * discountMultiplier);
                         }
                        if( pc.cscfga__Parent_Configuration__c != null){
                            oli.Complimentary__c = True;
                        } else {
                            oli.Complimentary__c = false;
                        }
                        oli.Product_Configuration__c = pc.Id;
                        oli.Record_Type__c = 'B2C Self Serve';
                        oli.SNo__c = sno;
                       allOLIs.add(oli);
                    }
                  
                }
            }
            system.debug('opp line items===' + allOLIs);
            
            insert allOLIs;
               List<String> contactIDList = new List<String>();
            Boolean isfirstTimePC = false;
            for(Opportunitylineitem o : allOLIs){
                if(!o.Complimentary__c && o.product2id == primeCred.id){
                    Agent_purchase_prime_Credit__e  appc = new Agent_purchase_prime_Credit__e (
                    UUID__c = allBaskets[0].csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__Account__r.uuid__c,
                         AgentNet_id__c = allBaskets[0].csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__Account__r.AgentNet_id__c,       
                        Purchase_Time__c = system.now()
                    );
                   
                     EventBus.publish(appc);
                    system.debug(commSKU);
                    //system.debug(appc.sku__c);
                    if(commSKU.contains(label.PCSS_SKUCode)){
                    isfirstTimePC=true;
                    }
                    system.debug( appc);
                      contactIDList.add(allBaskets[0].csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__Account__r.PersonContactID);
                    system.debug('published Agent_purchase_prime_Credit__e event');
                    break;
                }
            }
             if(!contactIDList.isEmpty()){
                list<CampaignMember> cmList = [Select id from campaignmember where contactid in: contactIDList and campaignID =: Label.PCSSCampaignID ];
                for(CampaignMember cm : cmList){
                   // if(commSKU.contains())
                    if(isfirstTimePC){
                         cm.status='Utilised';
                    }else{
                    cm.status='Revoked';
                    }
                }
                update cmList;
            }
            system.debug('promoIds '+promoIds);
            if(!promoIds.isEmpty() ){
                List<Promo_mechanic__c> pmList = [select id,campaign_eligibility__r.campaign__c 
                                                  from promo_mechanic__c where id in: promoIds];
                Set<String> campIds = new Set<String> ();
                for(Promo_mechanic__c pm : pmList){
                    
                    campIds.add(pm.campaign_eligibility__r.campaign__c);
                }
                system.debug('campIds'+campIds);
                for(String cid : campIds){
                    campInfluenceList.add(new campaignInfluence (opportunityid=OppList[0].Id,
                                                                 campaignId=cid,
                                                                 Influence =100,
                                                                 modelid=modelid,
                                                                contactid = contactid) );  
                }
                insert campInfluenceList;
                system.debug(campInfluenceList);
                List<CampaignMember> cmList = [select id,campaignid from CampaignMember 
                                               where contactid=:contactId and campaignid in: campIds];
                for(campaignMember cm :cmList ){
                    cm.status='Utilised';
                }
                update cmlist;
            }
            system.debug('opp line items===' + allOLIs);
            if(!listOfEvents.isEmpty()) {
                EventBus.publish(listOfEvents);
            }
        }
        catch (Exception e) {
            system.debug('exception====' + e.getMessage() + '---line no---' + e.getLineNumber());
            this.nextWorker = null;
            
            Database.rollback(sp);
            
            for (Object bId : this.basketIds) {
                log.addMessage(e,String.valueOf(bId));
                if(!test.isRunningTest())
                    log.save('CreateOppObserver_new', CS_const_ApexJob.JobType_Queueable, getJobId(), false);
            }
            
            
        }
    } 
    public static ConnectApi.BatchInput postChatter(Opportunity opp,Boolean isRenewal){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        textSegmentInput.text = 'Hey';
        messageBodyInput.messageSegments.add(textSegmentInput);
        mentionSegmentInput.id = Opp.OwnerId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        textSegmentInput = new ConnectApi.TextSegmentInput();
        if(isRenewal){
            textSegmentInput.text = '\n  please note that agent has transacted via Self-Serve';
            
        }else 
            textSegmentInput.text = '\n please note that you have been assigned '+ Opp.name +' in Stage '+opp.StageName;
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = Opp.Id;
        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
        return batchInput;
    }
    public class ECommerceObserverException extends Exception{}
}
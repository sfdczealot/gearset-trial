global class CreateOppObserver  extends CS_QueueableWorker {
    public List<Id> basketIds;
    // params new Map<String, Object>
    global CreateOppObserver (Object params) {
        super('CreateOppObserver', params);
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
        String accCountry = '';
        Savepoint sp = Database.setSavepoint();

        //ensures basket totals are calculated
        cscfga.ProductConfigurationBulkActions.calculateTotals(new Set<Id>(this.basketIds));

            allBaskets = [SELECT Id, Name, OwnerId, cscfga__Total_Price__c, Payment_Amount__c, Appr_Code__c,
                          Payment_Date__c, Payment_Reference__c, Payment_Gateway__c, cscfga__Opportunity__c,
                          Payment_Mode__c, EcomReference__c,
                          (SELECT Id, Name, csb2c__Account__c, csb2c__API_Basket_ID__c,csb2c__Account__r.Country__c,csb2c__Account__r.OwnerId, csb2c__E_Commerce_Customer_Id__c
                           FROM csb2c__Inbound_Ecommerce_Order_Requests1__r),
                          (SELECT id, cscfga__Unit_Price__c FROM cscfga__Product_Configurations__r) 
                          FROM cscfga__Product_Basket__c WHERE Id IN: basketIds];
        try {
            Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Self-Serve').getRecordTypeId();


            Product2 Product = [SELECT Id, Name FROM Product2 WHERE name = 'PGSG Ad Credit (1 Credit)' LIMIT 1];
            PriceBook2 priceBook = [SELECT Id, Name FROM PriceBook2 WHERE name = 'PG SG' LIMIT 1];			
            PricebookEntry ProdEntry = [SELECT  Id, Name FROM PricebookEntry WHERE Product2Id =: Product.Id and pricebook2Id =: priceBook.Id LIMIT 1];
            
            for (cscfga__Product_Basket__c basket : allBaskets) {



                ecomm = basket.csb2c__Inbound_Ecommerce_Order_Requests1__r;
                accCountry = ecomm[0].csb2c__Account__r.Country__c;
                pcList = basket.cscfga__Product_Configurations__r;
                decimal totalPrice = basket.cscfga__Total_Price__c != null? basket.cscfga__Total_Price__c: 0.0;
                Opportunity newOpp = new Opportunity (
                    AccountId = basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__Account__c,
                    Description = 'Opportunity',
                    Name = basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__E_Commerce_Customer_Id__c + ' purchased ' + basket.EcomReference__c + ' @  S$' + totalPrice,
                    StageName ='Converted',
                    BasketId__c = basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__API_Basket_ID__c,
                    CloseDate = Date.today(),
                    recordtypeId = devRecordTypeId,
                    OwnerId = basket.csb2c__Inbound_Ecommerce_Order_Requests1__r[0].csb2c__Account__r.OwnerId,
                    pricebook2Id = priceBook.Id);
                OppList.add(newOpp);
                basketIdToOpp.put(basket.Id, newOpp);
                basketPrice.put(newOpp.Name, basket.cscfga__Total_Price__c);
                basketToOpp.put(newOpp.Name, basket);
            }
            insert OppList;
            
            List<cscfga__Product_Configuration__c> pcAttrList = [Select Id, name, cscfga__Quantity__c, Start_Date__c, cscfga__Unit_Price__c,
                                                                 End_Date__c,cscfga__Product_Family__c, 
                                                                 cscfga__Parent_Configuration__c,
                                                                 cscfga__Product_Basket__r.cscfga__Opportunity__c,
                                                                 cscfga__Product_Basket__r.cscfga__Opportunity__r.Name,
                                                                 (Select Id, name, cscfga__Price__c, cscfga__List_Price__c, 
                                                                  cscfga__Value__c, cscfga__Is_Line_Item__c from 
                                                                  cscfga__Attributes__r) 
                                                                 from cscfga__Product_Configuration__c where 
                                                                 Id IN: pcList];
            system.debug('pcList===' + pcList + '---size---' + pcList.size());
            //helper map to caclualate OLI quantiy via included_unit X quantity, so expecting 2 entries
            Map<Id,Decimal> pcQuantitySetMap = new Map<Id, Decimal>();

            for(cscfga__Product_Configuration__c pc : pcAttrList){
                pcQuantitySetMap.put(pc.Id,1);

                for(cscfga__Attribute__c att : pc.cscfga__Attributes__r){
                    if(att.name == 'Offering'){
                        commIds.add(att.cscfga__Value__c);
                    }

                    if(att.Name == 'Included Units') {
                        pcQuantitySetMap.put(pc.Id, (pc.cscfga__Quantity__c * Decimal.valueOf(att.cscfga__Value__c) ) );
                    }
                }
            }
            
            for(cspmb__Price_Item__c commProdList : [Select id, Tax_Code__c, Tax_Code__r.Tax_Rate__c,  Income_Account__c, 
                                                     Product_Category__c from cspmb__Price_Item__c where Id In: commIds]){
                                                         commProdGstId.put(commProdList.id, commProdList);
                                                     }
            
            paymentMethodList = [Select id, name from Payment_Method__c];
            for(Payment_Method__c payment : paymentMethodList){
                paymentMap.put(payment.Name, payment.Id);
            }
            
            if(!OppList.isEmpty() && OppList.size() > 0){
                for(Opportunity opp: OppList){
                    cscfga__Product_Basket__c basket = basketToOpp.get(opp.Name);
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
                    pay.Payment_Mode__c = basket.Payment_Mode__c;
                    paymentList.add(pay);                    
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
            
            Integer sno = 0;
            List<OpportunityLineItem> allOLIs = new List<OpportunityLineItem>();

            for(cscfga__Product_Configuration__c pc : pcAttrList){
                for(cscfga__Attribute__c attr : pc.cscfga__Attributes__r){
                    if(attr.cscfga__Is_Line_Item__c){
                        sno = sno + 1;
                        OpportunityLineItem oli = new OpportunityLineItem ();
                        oli.Product2Id = Product.Id;
                        oli.TotalPrice = basketPrice.get(pc.cscfga__Product_Basket__r.cscfga__Opportunity__r.Name);
                        oli.OpportunityId = OppList[0].Id;
                        oli.Quantity = pcQuantitySetMap.get(pc.Id);
                        oli.UnitPrice = (pc.cscfga__Unit_Price__c / oli.Quantity );
                        oli.Start_Date__c = pc.Start_Date__c;
                        oli.End_Date__c = pc.End_Date__c;
                        oli.PricebookEntryId = ProdEntry.Id;
                        if(pc.cscfga__Product_Family__c == 'Ad Credits'){
                            oli.Commercial_Product__c = attr.cscfga__Value__c;
                            if(commProdGstId.containsKey(attr.cscfga__Value__c)){
                                cspmb__Price_Item__c price = commProdGstId.get(attr.cscfga__Value__c);
                                oli.GST_VAT_Code__c = price.Tax_Code__c;
                                oli.Income_Account_Name__c = price.Income_Account__c;
                                oli.GST_VAT_Rate__c = price.Tax_Code__r.Tax_Rate__c;
                                oli.Product_Category__c = price.Product_Category__c;
                            }
                        }
                        if(attr.cscfga__Price__c != null && attr.cscfga__List_Price__c != null && attr.cscfga__Price__c != attr.cscfga__List_Price__c){
                            oli.Discount_Amount__c = attr.cscfga__List_Price__c - attr.cscfga__Price__c;
                        }
                        oli.Product_Configuration__c = pc.Id;
                        oli.Record_Type__c = 'B2B';
                        oli.SNo__c = sno;
                        allOLIs.add(oli);
                    }
                }
            }
            insert allOLIs;
            system.debug('opp line items===' + allOLIs);

        }
        catch (Exception e) {
        system.debug('exception====' + e.getMessage() + '---line no---' + e.getLineNumber());
            this.nextWorker = null;

            Database.rollback(sp);

            for (Object bId : this.basketIds) {
                log.addMessage(e,String.valueOf(bId));
                log.save('CreateOppObserver', CS_const_ApexJob.JobType_Queueable, getJobId(), false);
            }


        }
    }

    public class ECommerceObserverException extends Exception{}
}
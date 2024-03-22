@RestResource(urlMapping='/api/processorder/')
global class processorderiOSAPI {
    
    @HttpPost
    global static void upsertOpporunity(){
        Savepoint sp = Database.setSavepoint();    
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        List<Object> paramsList;
        Map<String,Object> params;
        List<object> items=new List<object> ();
        List<object> payment=new List<object> ();
        List<String> productNSId = new List<String>();
        List<String> nullParams = new List<String>();
        List<OpportunityLineItem> oliList = new list<opportunityLineItem>();
        Map<String,Object> pay;
        Opportunity opp;
        Account acc;
        String accCountry ;
        Set<String> paymentMethodNames = new Set<String>();
        List<Opportunity> OppList =  new List<Opportunity>();
        List<Payment__c> paymentList = new List<Payment__c>();
        Map<String, Id> paymentMap = new Map<String, Id>();
        List<Payment_Method__c> paymentMethodList = new List<Payment_Method__c>();
        try{
            Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Self-Serve').getRecordTypeId();
            if(request != null && String.isNotBlank(request.requestBody.toString())){
                system.debug('---<<<req>>>--- '+request.requestBody.toString());
              //  paramsList = ( List<Object>)JSON.deserializeUntyped(request.requestBody.toString());
                params = (Map<String,Object>)JSON.deserializeUntyped(request.requestBody.toString());
            } 
            
            
            if(params == null){
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('status', 'failure');
                gen.writeStringField('message', 'Params are not present.');
                gen.writeEndObject();
                String jsonData = gen.getAsString();
                res.statusCode = 200;
                res.responseBody =Blob.valueOf(gen.getAsString());
                return; 
            }
            
            
            if(params != null){
                if (params.get('agentKey') == '' || params.get('agentKey') == null){
                    nullParams.add('Agent Key');
                }
                if (params.get('orderNumber') == '' || params.get('orderNumber') == null){
                    nullParams.add('Order Number');
                }
                if (params.get('totalPrice') == '' || params.get('totalPrice') == null){
                    nullParams.add('Total price');
                }
                if (params.get('items') == '' || params.get('items') == null){
                    nullParams.add('Items');
                }else
                { 
                    items = ( List<object> )params.get('items');
                    for(integer i =0; i<items.size();i++){
                        Map<String,Object> item = (Map<String,Object>) items[i];
                        productNSId.add((String)item.get('externalId'));
                        system.debug((String)item.get('productCode'));
                        system.debug((String)item.get('productCode') == '' || (String)item.get('productCode')==null);
                        if((String)item.get('externalId') == '' || (String)item.get('externalId')==null){
                            nullParams.add('externalId');
                        }
                        
                        if((String)item.get('startDate') == '' || (String)item.get('startDate')==null){
                            nullParams.add('Start Date');
                        }
                        if((String)item.get('endDate') == '' || (String)item.get('endDate')==null){
                            nullParams.add('End Date');
                        }
                      
                        if( !item.containsKey('qty')){
                            nullParams.add('Quantity');
                        }
                        
                    }
                }
                if (params.get('payment') == '' || params.get('payment') == null){
                    nullParams.add('Payment Details');
                }else
                {
                    payment = (List<object> )params.get('payment');
                    for(integer i =0; i<payment.size();i++){
                        Map<String,Object> item = (Map<String,Object>) payment[i];
                        system.debug(payment);
                        system.debug(item);
                        if( !item.containsKey('paymentDate') || (String)item.get('paymentDate') == '' || (String)item.get('paymentDate')==null){
                            nullParams.add('Payment Date');
                        }
                        if((String)item.get('paymentGateway ') == '' || (String)item.get('paymentGateway')==null){
                            nullParams.add('Payment Gateway');
                        }
                        if((String)item.get('paymentMode') == '' || (String)item.get('paymentMode')==null){
                            nullParams.add('Payment Mode');
                        }
                        if( (Decimal)item.get('paymentAmount')==null){
                            nullParams.add('Payment Amount');
                        }
                        if((String)item.get('paymentReference') == '' || (String)item.get('paymentReference')==null){
                            nullParams.add('Payment Reference');
                        }
                    }
                }
                
            }
            if(!nullParams.isEmpty()){
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('status', 'failure');
                gen.writeStringField('message', String.join(nullParams,', ')+ ' is Empty.');
                gen.writeEndObject();
                String jsonData = gen.getAsString();
                res.statusCode = 200;
                res.responseBody =Blob.valueOf(gen.getAsString());
                return;
                
            }
            pay = (Map<String,Object>) Payment[0];
            //Product2 Product = [SELECT Id, Name FROM Product2 WHERE NetSuite_Id__c =: productNSId];
            String priceBookId;
            Map<String,PricebookEntry> externalIDVsPbe = new  Map<String,PricebookEntry>();
            for(PricebookEntry pbe : [select Id, pricebook2Id, product2Id, Pricebook2.CurrencyIsoCode, 
                                      product2.netsuite_id__c, CurrencyIsoCode, product2.Tax_Code__c 
                                      from pricebookentry where product2.netsuite_id__c in : productNSId 
                                      and Pricebook2.Name!='Standard Price Book' and IsActive=true]){
                                          if(pbe.Pricebook2.CurrencyIsoCode == pbe.CurrencyIsoCode){
                                              priceBookId = pbe.pricebook2Id;
                                              externalIDVsPbe.put(pbe.product2.netsuite_id__c,pbe); 
                                          } 
                                      }
            system.debug('****'+productNSId);
            system.debug(externalIDVsPbe);
            //Product2 primeCred = [SELECT Id, Name FROM Product2 WHERE name = 'PGSG Prime Credit' limit 1];
            //  PriceBook2 priceBook = [SELECT Id, Name FROM PriceBook2 WHERE name = 'PG SG' LIMIT 1]; 
            //  PricebookEntry ProdEntry = [SELECT  Id, Name FROM PricebookEntry WHERE Product2Id =: Product.Id and pricebook2Id =: priceBook.Id LIMIT 1];
            //PricebookEntry primeCredEntry = [SELECT  Id, Name FROM PricebookEntry WHERE Product2Id =: primeCred.Id and pricebook2Id =: priceBook.Id LIMIT 1];
            
            String agentKey = (String) params.get('agentKey');
            acc = [select id,ownerid,country__c,agentKey__c from Account where AgentKey__c = :agentKey];
            accCountry = acc.country__c;
            opp = new Opportunity();
            opp.ownerID	= acc.OwnerID;
            opp.AccountID = acc.id;
            opp.Name = acc.AgentKey__c +' Purchased '+(String) params.get('orderNumber') +' @ $'+(Decimal) pay.get('paymentAmount');
            opp.stageName = 'Converted';
            opp.CloseDate = system.today();
            opp.Invoice_Id__c = (String) params.get('orderNumber');
            opp.Opportunity_Type__c = 'Self-Serve Standard';
            opp.Order_Date__c = date.valueOf((String)pay.get('paymentDate'));
            opp.recordtypeid = devRecordTypeId;
            opp.pricebook2id = priceBookId;
            opp.Sync_To_NetSuite__c = true;	
            insert opp;
            paymentMethodList = [Select id, name from Payment_Method__c];
            for(Payment_Method__c p : paymentMethodList){
                paymentMap.put(p.Name, p.Id);
            }
            if(pay.get('paymentAmount')!=0){
                Payment__c oPayment = new Payment__c();
                oPayment.Opportunity_Record__c = opp.Id;
                oPayment.Amount2__c =  (Decimal) pay.get('paymentAmount');
                oPayment.Appr_Code__c = (String)  pay.get('apprCode');
                oPayment.Payment_Date__c = date.valueOf((String)pay.get('paymentDate'));
                oPayment.Payment_Gateway__c = (String) pay.get('paymentGateway');
                oPayment.Reference_Number__c = (String) pay.get('paymentReference');
                if((String) pay.get('paymentGateway') == 'Adyen'){
                    if(accCountry == 'Singapore' && paymentMap.containsKey('Adyen (SG)')){
                        oPayment.Payment_Method__c = paymentMap.get('Adyen (SG)');
                    }else if(accCountry == 'Malaysia' && paymentMap.containsKey('Adyen (MY)')){
                        oPayment.Payment_Method__c = paymentMap.get('Adyen (MY)');
                    }else if(accCountry == 'Indonesia' && paymentMap.containsKey('Adyen (ID)')){
                        oPayment.Payment_Method__c = paymentMap.get('Adyen (ID)');
                    }else if(accCountry == 'Thailand' && paymentMap.containsKey('Adyen (TH)')){
                        oPayment.Payment_Method__c = paymentMap.get('Adyen (TH)');
                    }
                }
                if((String) pay.get('paymentGateway') == 'Braintree' && paymentMap.containsKey('Braintree')){
                    oPayment.Payment_Method__c = paymentMap.get('Braintree');
                }
                if((String) pay.get('paymentGateway') == 'Paypal' && paymentMap.containsKey('Paypal')){
                    oPayment.Payment_Method__c = paymentMap.get('Paypal');
                }
                if((String) pay.get('paymentGateway') == '2c2p') {
                    if (((String) pay.get('BankName')).contains('UOB') && (Decimal) pay.get('installmentPeriod') == 6) {
                        oPayment.Payment_Method__c = paymentMap.get('UOB 6 Month Installment_Online');
                    } else if (((String) pay.get('BankName')).contains('UOB') && (Decimal) pay.get('installmentPeriod')== 12) {
                        oPayment.Payment_Method__c = paymentMap.get('UOB 12 Month Installment_Online');
                    }
                }
                if((String) pay.get('paymentGateway') == 'enets') {
                    if (((String) pay.get('BankName')).contains('DBS') &&(Decimal) pay.get('installmentPeriod') == 6) {
                        oPayment.Payment_Method__c = paymentMap.get('DBS 6 Month Installment');
                    } else if (((String) pay.get('BankName')).contains('DBS') && (Decimal) pay.get('installmentPeriod') == 12) {
                        oPayment.Payment_Method__c = paymentMap.get('DBS 12 Month Installment');
                    }
                }
                if((String) pay.get('paymentGateway') == 'Apple'){
                    oPayment.Payment_Method__c = paymentMap.get('Apple');
                }
                oPayment.Payment_Mode__c = (String) pay.get('paymentMode');
                paymentList.add(oPayment);    
            }
            insert paymentList;
            Integer count =1;
            for(integer i =0; i<items.size();i++){
                Map<String,Object> item = (Map<String,Object>) items[i];
                OpportunityLineItem oli = new OpportunityLineItem();
                if(externalIDVsPbe.containsKey((String)item.get('externalId'))){
                   
                    oli.Product2Id =  externalIDVsPbe.get((String)item.get('externalId')).Product2Id;
                    oli.PricebookEntryId =  externalIDVsPbe.get((String)item.get('externalId')).Id;
                }
               
                oli.OpportunityID = opp.id;
                oli.UnitPrice  = (Decimal) item.get('unitPrice');
                oli.Quantity  =(Decimal)  item.get('qty');
                if(item.containsKey('discountType')){
                    if(item.get('discountType') == 'Amount'){
                        oli.Discount_Amount__c  = (Decimal)item.get('discount');
                    } else if(item.get('discountType') =='Percent'){
                        oli.Discount__c = (Decimal)item.get('discount');
                    }
                }
                oli.Start_Date__c  = date.valueOf((String)item.get('startDate'));
                oli.End_Date__c = date.valueOf((String)item.get('endDate'));
                oli.SNo__c = count;
                count++;
                if(Label.Allow_Tax_Code_for_GST_SS  == 'Yes')
                    oli.GST_VAT_Code__c = externalIDVsPbe.get((String)item.get('externalId')).product2.Tax_Code__c ;
                OliList.add(oli);
            }
            
            insert oliList;
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('status', 'Success');
            gen.writeStringField('message', 'Opportunity, Line Items and payment is created');
            gen.writeEndObject();
            String jsonData = gen.getAsString();
            res.statusCode = 200;
            res.responseBody =Blob.valueOf(gen.getAsString());
            return;
            
        }
        catch(Exception e){
            Database.rollback(sp);
            system.debug('Error ::: at line '+e.getLineNumber()+' -- '+e.getMessage());
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('status', 'failure');
            gen.writeStringField('message', 'Error ::: at line '+e.getLineNumber()+' -- '+e.getMessage());
            gen.writeEndObject();
            String jsonData = gen.getAsString();
            res.statusCode = 200;
            res.responseBody =Blob.valueOf(gen.getAsString());
            return; 
        }
    }
}
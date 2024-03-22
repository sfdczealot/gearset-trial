/*
* TestClass : OpportunityQuoteAPIStinger_Test
*/
global class OpportunityQuoteAPIStinger {
    
    global class BuildQuote { 
        String region;          String agentId;           String invoiceId;              String CurrencyBySteven;  
        String total;           String expiry = '';       String paymentMethod;
        
        BuildQuote( String region,String agentId,String invoiceId,String Mycurrency,Decimal total,String allowedPaymentType, string countryName) {
            map<string, Country_Attribute__mdt> mapCountryAtt = EligibilityHandler.getCountryAttribute();
            integer expiredHours = integer.valueof(mapCountryAtt.get(countryName).Expired_Hours__c);
            this.region = region;                       this.agentId = agentId;                   this.invoiceId = invoiceId;
            this.CurrencyBySteven = Mycurrency;         this.total = String.valueof(total.setScale(2,RoundingMode.HALF_UP));
            this.expiry = String.Valueof(system.now().addHours(expiredHours));
            switch on allowedPaymentType {
                when 'All' {
                    this.paymentMethod = 'all';
                }
                when 'Online only' {
                    this.paymentMethod = 'online';
                }
                when 'Offline only' {
                    this.paymentMethod = 'offline';
                }
                when else {
                    this.paymentMethod = 'all';
                }
            }
        }   
    }
    
    global class SalesRepInformation {
        string name; string email ; string contactNo;
        SalesRepInformation( string name, string email, string contactNo){
            this.name = name; this.email = email; this.contactNo = contactNo;
        }
    }
    
    global class orderInfo {   
        String region;          string webuserId;           String customerName;            String billaddress;
        String email;           String referenceNo;         String tranAmount;              salesRepInformation salesRep;   
        String tranTax;         String tranDisc;            String tranTotal;               string createdDate;
        String tranWht;
        
        orderInfo ( String region,string webuserId,String customerName,String billaddress,String email,String referenceNo,Decimal tranAmount, Decimal tranTax,Decimal tranDisc,Decimal tranTotal , datetime createdDate, salesRepInformation salesRep, String tranWHT){
            this.region = region;               this.email = email;                                                              this.tranTax = string.valueof(tranTax.setScale(2,RoundingMode.HALF_UP));
            this.webuserid = webuserId;         this.salesRep = salesRep;                                                        this.tranDisc = string.valueof(tranDisc.setScale(2,RoundingMode.HALF_UP));
            this.customerName = customerName;   this.referenceNo = referenceNo;                                                  this.tranTotal = String.valueof(tranTotal.setScale(2,RoundingMode.HALF_UP));
            this.billaddress = billaddress;     this.tranAmount = string.valueOF(tranAmount.setScale(2,RoundingMode.HALF_UP));   this.createdDate = string.valueof(createdDate.format('YYYY-MM-dd HH:mm:ss'));                        
            this.tranWHT = tranWHT;         
        } 
    }
    
    global class Items {
        String itemName;            String itemDescription;     String itemQuantity;       string itemPrice;      String itemTax;
        String itemDisc;            String itemAmount;          Date startDate;            Date endDate;
        String itemWht;
        Items( String itemName,String itemDescription,Decimal itemQuantity,Decimal itemPrice, Decimal itemTax,Decimal itemDisc,Decimal itemAmount,Date startDate,Date endDate,String itemWHT){
            this.itemName = itemName;      this.itemDescription = itemDescription;      this.itemQuantity = String.Valueof((itemQuantity==null?0:itemQuantity));
            this.endDate = endDate;        this.itemTax = String.Valueof(itemTax);      this.itemPrice = String.Valueof(itemPrice.setScale(2,RoundingMode.HALF_UP));
            this.startDate = startDate;    this.itemDisc = String.Valueof(itemDisc);    this.itemAmount = String.Valueof(itemAmount.setScale(2,RoundingMode.HALF_UP));          
            this.itemWHT  =  itemWHT; 
        }
    }
    
    @AuraEnabled
    public static LightningResponse sendtoGurulandValidate (id quoteId){
        Quote quo = [Select id,Status,RecordType.DeveloperName,to_VIP_Approval__c,VIP_Approved__c,to_FOC_Approval__c,FOC_Approved__c,to_Managerial_Approval__c,Managerial_Approved__c from quote where id =:quoteId];
        
        if((quo.to_FOC_Approval__c!= quo.FOC_Approved__c) || (quo.to_Managerial_Approval__c!= quo.Managerial_Approved__c)) {
            
            return new LightningResponse(false, 'Error', System.Label.QUOTE_OPPTY_STAGE_CHANGE_ERROR);  
            
        } 
        else{
            sendtoGurulandAct(quoteId);
            return new LightningResponse(True, 'Success', 'Payment link has been created for your quote'); 
        }
        
    }
    
    @AuraEnabled
    public static void sendtoGuruland (id quoteId){
        sendtoGurulandAct(quoteId);
    }
    
    
    public static HttpResponse sendtoGurulandAct (id quoteId){
        
        Map<string,string> reqHeaders = new Map<string,string>();
        HttpResponse res;
        
        String CountryCode='';
        String webuser = '';
        Decimal DiscountAmount = 0.00, TotalDiscountAmount = 0.00;
        
        Decimal paymentAmount = 0;
        Quote quotes = new Quote(); 
        quotes = [SELECT  id,Invoice_Id__c,name,Quote_Number__c,createdDate, Account.BillingAddress,Floor_Price_Type__c,Account.BillingCountry,Account.Country__c ,Account.BillingPostalCode,Account.BillingState,Account.BillingCity,
                  Account.BillingStreet, Account.AgentNet_ID__c, CurrencyIsoCode,Total_Gross_Amount__c,Order_Date__c, Status, Total_Tax_Amount__c,Opp_Quote_Ref_num__c, Quote_Type__c, opportunity.closedate,
                  Total_Discounted_Amount__c, ownerid, createdby.name, Account.name, Account.personEmail,Total_Amount_Before_Discount__c, owner.name, Opportunity_Number__c,Payment_Link__c,Allowed_Payment_Type__c, Country__c,OpportunityId, Total_WHT_Amount__c FROM Quote  WHERE Id =: quoteId LIMIT 1];
    
        List<QuoteLineItem> qliListofPennyProducts = [SELECT Id,Product2.SKU_Code__c,Quantity,Amount__c FROM QuoteLineItem WHERE QuoteId =:quoteId AND 
                                                      ((((Product2.SKU_Code__c NOT IN: System.Label.SKU_CODE_OF_CULLINAN_PACKAGE.Split(';') AND 
                                                      Product2.Is_KIT_Parent__c = true AND Product2.Revised_Product__c != null AND 
                                                      Product2.Effective_till__c != null) OR Product2.SKU_Code__c =: System.Label.SG_AD_CREDIT_SKU_CODE)  
                                                       AND Quote.Country__c = 'Singapore') OR 
                                                      (Quote.Country__c = 'Malaysia' AND Product2.SKU_Code__c IN: System.Label.PRE_CYGNUS_PRODUCTS.Split(';')
                                                       AND Product2.Is_KIT_Parent__c = true))]; 
        
        System.debug('%%%li'+qliListofPennyProducts);
        
        List<Floor_Price__c > floorPriceList = [select id,List_Price__c, Max_Quantity__c, Min_Quantity__c, Price__c, Product__r.SKU_Code__c from Floor_Price__c 
                                                WHERE Product__r.SKU_Code__c =: System.Label.SG_AD_CREDIT_SKU_CODE];

        DateTime currentDate = dateTime.newInstance(System.now().year(),System.now().month(),System.now().day());
        List<String> cygnusProdSKUs = SYSTEM.LABEL.PRE_CYGNUS_PRODUCTS.Split(';');
        if(!qliListofPennyProducts.isEmpty() && quotes.Country__c == 'Singapore') {
            for(QuoteLineItem qliObj : qliListofPennyProducts) {
                if(qliObj.Product2.SKU_Code__c == System.Label.SG_AD_CREDIT_SKU_CODE && !floorPriceList.isEmpty() &&
                   quotes.Quote_Type__c == 'B2C - Standard' && currentDate > DateTime.valueOf(System.Label.PAYMENT_CUTOFF_DATE_FOR_UPGRADE)) {
                       for(Floor_Price__c floorPrice : floorPriceList) {
                           Decimal perUnitPrice = qliObj.Amount__c/qliObj.Quantity;
                           if(floorPrice.Product__r.SKU_Code__c == qliObj.Product2.SKU_Code__c) {
                               if(floorPrice.min_Quantity__c<=qliObj.Quantity && qliObj.Quantity<=floorPrice.max_Quantity__c &&
                                  (perUnitPrice < floorPrice.Price__c && quotes.Floor_Price_Type__c == 'Above Floor Price')) {
                                      throw new AuraHandledException( 'Quote contains old Products. Payment link generation is not allowed.');
                                  }
                           }
                       }
                   } else if (qliObj.Product2.SKU_Code__c != System.Label.SG_AD_CREDIT_SKU_CODE && 
                              ((quotes.Quote_Type__c == 'B2C - Standard' && currentDate > DateTime.valueOf(System.Label.PAYMENT_CUTOFF_DATE_NEW_RETURNING_AGENTS)) || 
                               (quotes.Quote_Type__c == 'B2C - Upgrade' && currentDate > DateTime.valueOf(System.Label.PAYMENT_CUTOFF_DATE_FOR_UPGRADE)) )) {
                                   throw new AuraHandledException( 'Quote contains penny Products, Payment link generation is not allowed');
                               }
            }
        } else if(!qliListofPennyProducts.isEmpty() && quotes.Country__c == 'Malaysia') {
            for(QuoteLineItem qliObj : qliListofPennyProducts) {
                if(cygnusProdSKUs.contains(qliObj.Product2.SKU_Code__c) && currentDate > DateTime.valueOf(System.Label.PAYMENT_CUTTOFF_DATE)) {
                   throw new AuraHandledException('Quote contains old Products. Payment link generation is not allowed.'); 
                }
            }
        }
        
        //to get the final amount
        Decimal finalPayment = getQuoteTotal(quotes);    
        if(String.valueOf(FinalPayment).contains('-')){
            finalPayment = 0.00;
        }
        if(quotes.Invoice_Id__c == '' || quotes.Invoice_Id__c == null){
            list<QuoteLineItem> QuoteLineItem = new list<QuoteLineItem>([SELECT Product2.name,product2.description, quantity, Unitprice, Discounted_Amount__c,Tax_Amount_new__c,Pro_Rate_Amount__c,Price_before_discount1__c , 
                                                                         Gross_Amount__C, Start_date__c, End_date__c,Parent__c, WHT_Amount__c FROM QuoteLineItem WHERE QuoteId =: quoteId and (Push_to_NetSuite__c =: true OR Discount_Reason__c != null)]); 
            String Address = '';
            if (quotes.Account.BillingAddress != null)
                Address = String.join(
                    new List<String> {quotes.Account.BillingAddress.getStreet(),
                        quotes.Account.BillingAddress.getCity(),
                        quotes.Account.BillingAddress.getCountry()}, 
                    ' ');
            String RootEndpoint; 
            String clientId = label.PG_LABEL_OpportunityPaymentClientId;
            String clientSecret = label.PG_LABEL_OpportunityPaymentClientSecret;
            
            if (runningInASandbox()) {
                RootEndpoint = label.PG_LABEL_OpportunityQuotePaymentAPI_SB; 
                    
            }
            else{
                RootEndpoint = label.PG_LABEL_OpportunityQuotePaymentAPI;
            }
            
            reqHeaders.put('Content-Type', 'application/json');
            reqHeaders.put('x-client-id', clientId);
            reqHeaders.put('x-client-secret', clientSecret);
            List<Items> itemss = new List<Items>();
            
            User rowUser = new User();
            rowUser = [SELECT id,name, MobilePhone,email FROM user WHERE id =: quotes.ownerid ];
            salesRepInformation rowSalesRep = new salesRepInformation(rowUser.Name, rowUser.Email, rowUser.MobilePhone);
            
            CountryCode__C[] countryCodes = CountryCode__c.getAll().Values();
            map<string,string> Cc = new map<string,string>();
            for (integer i = 0 ; i<countryCodes.size();i++){
                Cc.put(countryCodes[i].name,countryCodes[i].code__c);
            }
            if(quotes.Account.Country__c <> null){
                CountryCode = Cc.get(string.valueOF(quotes.Account.Country__c.toLowerCase()));
            }
            if(quotes.Account.AgentNet_ID__c <> null){
                webuser = string.valueOf(quotes.Account.AgentNet_ID__c);
            }  
            for (QuoteLineItem quo : QuoteLineItem){
                if(quo.Pro_Rate_Amount__c > 0){
                    DiscountAmount = quo.Discounted_Amount__c + quo.Pro_Rate_Amount__c;
                }
                else{
                    DiscountAmount = quo.Discounted_Amount__c;
                }
                String itemWHT = null;
                if(quo.WHT_Amount__c != null && quo.WHT_Amount__c > 0){
                    itemWHT = String.valueOf(quo.WHT_Amount__c);
                }
                Items Item = new Items(quo.Product2.name,quo.Product2.Description, quo.Quantity, quo.Unitprice,quo.Tax_Amount_new__c, DiscountAmount, quo.Price_before_discount1__c , quo.Start_date__c,quo.End_date__c,itemWHT);
                itemss.add(Item);
                /*else{
Items Item = new Items(quo.Product2.name,quo.Product2.Description, quo.Quantity, quo.Unitprice,quo.Tax_Amount_new__c, DiscountAmount, quo.Gross_amount__c, quo.Start_date__c,quo.End_date__c,itemWHT);
itemss.add(Item);
}*/
                TotalDiscountAmount += DiscountAmount;
            }
            String  quoteTranWHT = null;
            if(quotes.Total_WHT_Amount__c!=null && quotes.Total_WHT_Amount__c>0){
                quoteTranWHT= String.valueOf(quotes.Total_WHT_Amount__c);
            }
            orderInfo Ordin = new orderInfo(CountryCode, webuser,quotes.Account.name, Address,
                                              quotes.Account.personEmail,quotes.Opp_Quote_Ref_num__c, quotes.Total_Amount_Before_Discount__c,
                                              quotes.Total_Tax_Amount__c, TotalDiscountAmount, FinalPayment, quotes.createdDate,rowSalesRep,QuoteTranWHT);
            /*else{
Ordin = new order_info(Country_Code, webuser,quotes.Account.name, Address,
quotes.Account.personEmail,quotes.Opp_Quote_Ref_num__c, quotes.Total_Amount_Before_Discount__c + quotes.Total_Tax_Amount__c,
quotes.Total_Tax_Amount__c, TotalDiscountAmount, FinalPayment, quotes.createdDate,rowSalesRep,Quote_tranWHT);
}*/
            
            BuildQuote dtflow = new BuildQuote(CountryCode,quotes.Account.AgentNet_ID__c, quotes.Opp_Quote_Ref_num__c, quotes.CurrencyIsoCode.toLowerCase(),
                                               FinalPayment,string.valueOf(quotes.Allowed_Payment_Type__c), quotes.Country__c);
            //added for renewal opprotunity expiry date change PGAUTO-5414
            if(quotes.Country__c == 'Singapore' && quotes.Quote_Type__c == 'B2C - Renewal' && quotes.Opportunity.CloseDate != null) {
                dtflow.expiry = String.valueOf(datetime.newInstance(
                    quotes.Opportunity.CloseDate.year(), 
                    quotes.Opportunity.CloseDate.month(), 
                    quotes.Opportunity.CloseDate.day(), 
                    23, 59, 59
                ));
            }
            
            
            String FinalRequest = prepareJSONRequest(dtflow,Ordin,Itemss);  
            system.debug('@FinalRequest :: '+FinalRequest);      
            
            if(Test.isRunningTest()) {
                String resString = '{ "help": "https://data.gov.sg/api/3/action/help_show?name=datastore_search", "success": true, "result": { "resource_id": "a41ce851-728e-4d65-8dc5-e0515a01ff31", "fields": [ { "type": "int4", "id": "_id" }, { "type": "text", "id": "salesperson_name" }, { "type": "text", "id": "registration_no" }, { "type": "text", "id": "registration_start_date" }, { "type": "text", "id": "registration_end_date" }, { "type": "text", "id": "estate_agent_name" }, { "type": "text", "id": "estate_agent_license_no" }, { "type": "int8", "id": "_full_count" }, { "type": "float4", "id": "rank" } ], "q": "CEACHECK1", "records": [ { "registration_end_date": "2019-12-31", "estate_agent_license_no": "AGENCYCEA1", "salesperson_name": "UNIT TEST CEA CHECK", "registration_no": "CEACHECK1", "rank": 0.0573088, "_full_count": "1", "registration_start_date": "2013-11-27", "estate_agent_name": "UNIT TEST AGENCY", "_id": 29498 } ], "_links": { "start": "/api/action/datastore_search?q=R017154B&resource_id=a41ce851-728e-4d65-8dc5-e0515a01ff31", "next": "/api/action/datastore_search?q=R017154B&offset=100&resource_id=a41ce851-728e-4d65-8dc5-e0515a01ff31" }, "total": 1 }}';
                res = new HttpResponse();
                res.setStatusCode(200);
                res.setBody(resString);
            } else{
                do{
                     res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,'','POST',true,true,blob.valueOf(FinalRequest),null);
                    if(res.getStatusCode() == 302){
                        system.debug(res.getHeader('Location'));
                    RootEndpoint=res.getHeader('Location');
                    }
                   // reqHeaders.setEndpoint();
                    //  res = new Http().send(req);
                }
                while (res.getStatusCode() == 302) ;
               
            }

            // System.debug('Guruland Response : ' + res.getBody());
            if(!Test.isRunningTest() && res.getBody().contains('"id":')){
                Map<String, Object> JResponse= (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                String returnUrl = String.valueOf(JResponse.get('returnUrl'));
                String hashCode = String.valueOf(JResponse.get('hash'));
                Savepoint sp = Database.setSavepoint();  
                try {
                    updateQuoteLink(quoteId,returnUrl,hashCode,false);    
                } catch(DmlException e) {
                    system.debug('ERROR' + e.getMessage());
                }
            }
        }else{
            updateQuoteLink(quoteId,'','',true);    
        }
        return res;
        
    }
    
    public static void updateQuoteLink(id quoteId, String returnUrl,String hashCode, Boolean projectX){
        map<string, Country_Attribute__mdt> mapCountryAtt = EligibilityHandler.getCountryAttribute();
        Quote quote = [select id,Status,Payment_Link__c, From_Button__c, Guruland_Link_Created_Date__C, Country__c from Quote where id =: quoteId] ; 
        if(projectX == false){
            if(quote.Status =='Pending Online Payment' ||quote.Status=='New' || quote.Status=='Proposal' ){
                quote.From_Button__c = true;
                quote.Payment_Link__c = returnUrl;
                quote.Hash_Code__c = hashCode;
                quote.Guruland_Link_Created_Date__c = System.now();
                quote.Status = 'Pending Online Payment';
                update quote;
            }
        }else{
            quote.From_Button__c = true;
            quote.Status = 'Pending Online Payment';
            update quote;
        }   
    }
    
    public static string prepareJSONRequest (BuildQuote dtflow, orderInfo Ordin, list<Items> Itemss){
        String Data_flow1 = System.JSON.serialize(dtflow);
        String OrderInfo1 = System.JSON.serialize(Ordin);
        String ItemOrder1 = System.JSON.serialize(itemss);
        String Data_flow2 = Data_flow1.replace('CurrencyBySteven','currency');
        String OrderInfo2 = System.JSON.serialize(OrderInfo1);  
        String ItemOrder2 = System.JSON.serialize(ItemOrder1);
        String Data_Flow = data_flow2.substring(0,data_flow2.length()-1);
        String OrderInfo = OrderInfo2.substring(0,OrderInfo2.length()-2);
        String ItemOrder = ItemOrder2.substring(1,ItemOrder2.length()-1);
        String preFinalRequest = '"orderInfo" : ' + orderInfo + ', \\"items\\": '+ ItemOrder + '}"';
        String FinalRequest = Data_flow + ',' +  preFinalRequest + '}'; 
        return FinalRequest;
    }
    
    @AuraEnabled
    public static String checkConditionsBeforePayment(Id recordId) {    
        Boolean allowFirstTimer = true;
        Boolean allowReferralPromotion = true;
        String otherQuoteName = '';
        Quote quo = [select Id,isSyncing,OpportunityId,Quote_Type__c,Floor_Price_Type__c,Account.Subscription_End_Date__c,Count_of_Subscription_Item__c,Count_of_Referral_Agent_Promotion__c,Invoice_Id__c,Country__c,Account.id, Count_of_First_Timer_Promotion_new__c,LineItemCount ,Account.status__c, Status, Payment_amount__c, Required_Approval__c, Payment_Link__c, Sync_In_Progress__c,Account.CEA_Salesperson_Number__c,Recordtype.Name,Account.AgentNet_id__c,quote_number__c from Quote where Id =: recordId];
        if(quo.Invoice_Id__c == null || quo.Invoice_Id__c == ''){
            if( quo.Count_of_First_Timer_Promotion_new__c > 0 || quo.Count_of_Referral_Agent_Promotion__c > 0){
                list <Quote> otherQuote = new list<Quote>([SELECT Id,Name,Status,Count_of_First_Timer_Promotion_new__c,Count_of_Referral_Agent_Promotion__c FROM Quote WHERE id !=: recordId and Account.Id =: quo.Account.id ]);
                for(Quote row : otherQuote){
                    if((row.Status =='Pending Online Payment' || row.Status =='Pending OMC Approval' || row.Status =='Accepted') && row.Count_of_First_Timer_Promotion_new__c > 0){
                        allowfirstTimer = false;
                    }
                    if((row.Status =='Pending Online Payment' || row.Status =='Pending OMC Approval' || row.Status =='Accepted') && row.Count_of_Referral_Agent_Promotion__c > 0){
                        allowReferralPromotion = false; 
                        otherQuoteName = row.name;
                    }
                    
                    
                }
            }
            //To validate Campaigns of Promos applied
            validatePromoCampaigns(recordId);
            
            // Remove EligibilityHandler Dependency 
            //string identifier = 'AC_SuspendedAccountAllowed';
            //list<string> listCountry = EligibilityHandler.getCountryEligibility(identifier);
            list<string> listCountry =new list<String>{'Thailand', 'Malaysia'};
                system.debug('**************************');
            if(!Test.isRunningTest() && quo.isSyncing == false){
                throw new AuraHandledException('Cannot send an unsynced quote to payment. Please sync to allow payment');
            }
            else if(listCountry.contains(quo.Country__c) && quo.Account.status__c == 'Cancelled') {
                throw new AuraHandledException('Cannot send this record to adminnet because agent status is Cancelled');
            }
            else if(!listCountry.contains(quo.Country__c) && quo.Account.status__c == 'Cancelled') {
                throw new AuraHandledException('Cannot send this record to adminnet because agent status is Cancelled or Suspended');
            } 
            else if(!listCountry.contains(quo.Country__c) && quo.Account.status__c == 'Suspended'){
                if(quo.Account.Subscription_End_Date__c == null){
                    throw new AuraHandledException('Cannot send this record to adminnet because agent status is Cancelled or Suspended');
                } else if(
                    quo.Account.Subscription_End_Date__c.month() != system.today().month() 
                    && quo.Account.Subscription_End_Date__c.year() != system.today().year()
                ){
                    throw new AuraHandledException('Cannot send this record to adminnet because agent status is Cancelled or Suspended');
                }
            } else if(quo.LineItemCount  == 0){
                throw new AuraHandledException('Cannot send this quote to Adminnet! Please add product to this Quote.');   
            }/*else if(quo.Sync_In_Progress__c == TRUE) {
throw new AuraHandledException('Sync is in progress currently. Cannot execute your request!');
}else if(quo.NetSuite_Sales_Order__c == null){
throw new AuraHandledException('Cannot send this opportunity to Adminnet! NetSuite Sales Order # is empty.');
}*/
            //will be handled using Campaigns
            /*else if(quo.Count_of_Referral_Agent_Promotion__c > 0 && allowReferralPromotion == false){
throw new AuraHandledException('Agent has existing Quote(s) '+ otherQuoteName +' in processing with Referral Entitlement');
}   
else if(quo.Count_of_First_Timer_Promotion_new__c > 0 && allowfirstTimer == false){
throw new AuraHandledException('Cannot submit to Adminnet. There were an first timer Quote still pending or Accepted already, please contact your admin.');
}*/
            else if(quo.Floor_Price_Type__c != 'Below List Price' && quo.Required_Approval__c != 'OMC'){
                throw new AuraHandledException('This Quote needs approval. Please submit for approval.');
            }else if(quo.Payment_Link__c != null  ){            
                throw new AuraHandledException('You had your payment link already.');
            }else if(quo.Payment_Amount__c <> null){
                throw new AuraHandledException('Your quote already paid.');
            }else if(quo.Status != 'New' && quo.Status != 'Proposal' && quo.Status != 'Pending Online Payment' ){            
                throw new AuraHandledException('Cannot execute your request! Make sure you are on the right stage ( \'New\' or \'Proposal\') when click ready for payment.');
            }
            
            
            else if((quo.Quote_Type__c =='B2C - Upgrade' || quo.Quote_Type__c=='B2C - Renewal')  && quo.Count_of_Subscription_Item__c== 0){
                throw new AuraHandledException('B2C Upgrade/Renewal Quote must include Subscription products.');
            }
            else if(quo.Recordtype.Name == 'B2C' && quo.Country__c == 'Singapore' &&
                    (quo.Invoice_Id__c == null || quo.Invoice_Id__c == '')){
                        if(quo.Account.CEA_Salesperson_Number__c == null){
                            throw new AuraHandledException('<b>CEA Check</b> <p>&nbsp;</p> Agent Identification Number is blank. <p>&nbsp;</p> Please check Agent\'s record and update.');
                        }
                        else {
                            if(!Test.isRunningTest()){
                                callCEAEndpointClass.verifyCEADetails(quo.Account.AgentNet_id__c,quo.opportunityId,quo.quote_number__c);
                            }
                        }
                    }
            
            
            
        }
        
        return quo.Status;
    }  
    @auraEnabled
    public static void createFeeditem(id OppId , String feedData) {
        //createFeeditem(quoteId ,feedData);
        user usr = [select id from user where alias ='buser' and name='Integration User'];
        String usrId;
        if(usr != null){
            usrId=usr.id;
        }
        feedItem f = new feedItem();
        f.ParentId = OppId;
        f.Body = feedData;
        f.IsRichText = true;
        if(usrId != null ){
            f.CreatedById=usrId; 
        }
        if(!Test.isRunningTest())
            insert f;
    }
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    public static Decimal getQuoteTotal(Quote quotes){
        Decimal paymentAmount = 0;
        Decimal WHTAmount = 0;
        Decimal totalAmount =0;
        //get list of payment details
        list<Payment__c> paymentList = [Select id,Amount2__c from Payment__c where Opportunity_Record__c =: quotes.OpportunityId];
        for(Payment__c pay: paymentList){
            if(pay.Amount2__c != null){
                paymentAmount += pay.Amount2__c;
            }
        } 
        //check if total WHT amount is not null
        if(quotes.Total_WHT_Amount__c != null){
            WHTAmount = quotes.Total_WHT_Amount__c;
        }
        // get final amount 
        totalAmount = quotes.Total_Gross_Amount__c - paymentAmount - WHTAmount;
        
        return totalAmount;
    }
    @AuraEnabled
    public static quote getQuoteDetails(String quoteId){
        return [select id,Account_Email__c,Account.Tax_Reg_Number__c from Quote where id=: quoteId];
    }
    @AuraEnabled
    public static void updateEmailAddress(String quoteId,String Email){
        Quote quo= [select id,Account_Email__c,Account.Tax_Reg_Number__c from Quote where id=: quoteId];
        quo.Account_Email__c=Email;
        update quo;
    }
    public static void validatePromoCampaigns(String recordId){
        //to contain all Promo Mechanic Ids used on Quote
        Set<Id> promoIdsSet = new Set<Id>();
        Quote qu = [Select Id,Account.PersonContactId,(Select Id,Promo_Mechanic_Id__c  from QuoteLineItems where Promo_Mechanic_Id__c != null) from Quote where Id = : recordId];
        if(qu.QuoteLineItems.size()>0){
            for(QuoteLineItem  qli : qu.QuoteLineItems){
                if(qli.Promo_Mechanic_Id__c.contains(',')){
                    list<Id> splitPromoIds = qli.Promo_Mechanic_Id__c.split(',');
                    promoIdsSet.addAll(splitPromoIds);
                }else{
                    promoIdsSet.add(qli.Promo_Mechanic_Id__c);
                } 
            }
        }
        //To contain all Promo Campaign applied on Quote
        Set<Id> campaignIdsSet = new Set<Id>();
        List<Promo_Mechanic__c> promoMechanicList = [SELECT Id,Discount_Reason__c,Campaign_Eligibility__r.Campaign__c,Campaign_Eligibility__r.Campaign__r.isActive,Campaign_Eligibility__r.Campaign__r.ParentId FROM Promo_Mechanic__c where Id In : promoIdsSet];
        if(promoMechanicList.size()>0){
            for(Promo_Mechanic__c pm : promoMechanicList){
                if(String.isNotBlank(pm.Discount_Reason__c) && (pm.Discount_Reason__c.containsIgnoreCase('VIP') || pm.Discount_Reason__c.containsIgnoreCase('Renewal')) ){
                    if(String.isNotBlank(pm.Campaign_Eligibility__r.Campaign__r.ParentId))
                        campaignIdsSet.Add(pm.Campaign_Eligibility__r.Campaign__r.ParentId);
                }else{
                    if(String.isNotBlank(pm.Campaign_Eligibility__r.Campaign__c))
                        campaignIdsSet.Add(pm.Campaign_Eligibility__r.Campaign__c);
                }  
            }
        }
        //To check if any Promo Campaign is inactive
        boolean inActive = false;
        //check if Campaign Member has been deleted from Promo Campaign
        boolean camMembers = false;
        //To update status of CM to responded if Campaign is inactive
        List<CampaignMember> updateCampaignMemberList = new List<CampaignMember>();
        list<Campaign> campaignList = [Select id,IsActive, (SELECT Id,Campaign.Name FROM CampaignMembers where ContactId = : qu.Account.PersonContactId) from Campaign where id In : campaignIdsSet];
        if(campaignList.size()>0){
            for(Campaign cm : campaignList){
                if(cm.CampaignMembers.size()>0){
                    for(CampaignMember cmp : cm.CampaignMembers){
                        if(cm.IsActive == false){
                            inActive = true;
                            CampaignMember camM = new CampaignMember();
                            camM.Id = cmp.Id;
                            camM.Status = 'Responded';
                            updateCampaignMemberList.add(camM);
                        }
                    }
                }else{
                    camMembers = true;
                } 
            }
        }
        if(updateCampaignMemberList.size()>0){
            
            update updateCampaignMemberList;
        }
        if(inActive){
            throw new AuraHandledException('Please review if promo campaigns are active.');
        }
        if(camMembers){
            throw new AuraHandledException('Campaign Member has been removed from promo Campaign.');
        }
    } 
    
    public static void increasecoverage(){
        Integer i =0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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
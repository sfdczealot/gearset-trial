/*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Send Salesforce Opportunity record to Property Guru Endpoint
Inputs      : Salesforce Opportunity Id
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
global class OpportunityQuoteAPI {
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Wrapper Class to map Salesforce fields into quote Dataflow fields.
Inputs      : JSON Request
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    global class Dataflow { 
        String region;          String agent_id;           String invoice_id;              String CurrencyBySteven;  
        String total;           String created;            String status ;                 String expiry = '';
        String payment_method;
        
        Dataflow( String region,String Agent_iD,String invoice_id,String Mycurrency,Decimal total,String created, string status, String allowedPaymentType, string countryName) {
            map<string, Country_Attribute__mdt> mapCountryAtt = EligibilityHandler.getCountryAttribute();
            integer expiredHours = integer.valueOf(mapCountryAtt.get(countryName).Expired_Hours__c);
            this.region = region;                       this.Agent_iD = Agent_iD;                   this.created = created;   
            this.invoice_id = invoice_id;               this.CurrencyBySteven = Mycurrency;         this.total = String.valueOF(total.setScale(2));
            this.expiry = String.ValueOf(system.now().addHours(expiredHours));
            this.status = (status=='Pending Online Payment'|| status=='New' || status=='Proposal')?'open':'close';
            switch on allowedPaymentType {
                when 'All' {
                    this.payment_method = 'all';
                }
                when 'Online only' {
                    this.payment_method = 'online';
                }
                when 'Offline only' {
                    this.payment_method = 'offline';
                }
                when else {
                    this.payment_method = 'all';
                }
            }
        }   
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Wrapper Class to map Salesforce fields into quote salesRep fields.
Inputs      : JSON Request
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    global class SalesRepInformation {
        string name; string email ; string contactNo;
        SalesRepInformation( string name, string email, string contactNo){
            this.name = name; this.email = email; this.contactNo = contactNo;
        }
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Wrapper Class to map Salesforce fields into quote Order_Info fields.
Inputs      : JSON Request
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    global class Order_Info {   
        String region;          string webuserId;           String customerName;            String billaddress;
        String email;           String referenceNo;         String tranAmount;              salesRepInformation salesRep;   
        String tranTax;         String tranDisc;            String tranTotal;               string createdDate;
        
        Order_Info ( String region,string webuserId,String customerName,String billaddress,String email,String referenceNo,Decimal tranAmount, Decimal tranTax,Decimal tranDisc,Decimal tranTotal , datetime createdDate, salesRepInformation salesRep){
            this.region = region;               this.email = email;                                         this.tranTax = string.valueOF(tranTax.setScale(2));
            this.webuserid = webuserId;         this.salesRep = salesRep;                                   this.tranDisc = string.valueOF(tranDisc.setScale(2));
            this.customerName = customerName;   this.referenceNo = referenceNo;                             this.tranTotal = string.valueOF(tranTotal.setScale(2));
            this.billaddress = billaddress;     this.tranAmount = string.valueOF(tranAmount.setScale(2));   this.createdDate = string.valueOF(createdDate.format('YYYY-MM-dd HH:mm:ss'));                        
        } 
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Wrapper Class to map Salesforce fields into quote Items fields.
Inputs      : JSON Request
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    global class Items {
        String itemName;            String itemDescription;     String itemQuantity;       string itemPrice;      String itemTax;
        String itemDisc;            String itemAmount;          Date startDate;            Date endDate;
        
        Items( String itemName,String itemDescription,Decimal itemQuantity,Decimal itemPrice, Decimal itemTax,Decimal itemDisc,Decimal itemAmount,Date startDate,Date endDate){
            this.itemName = itemName;      this.itemDescription = itemDescription;      this.itemQuantity = String.ValueOF((itemQuantity==null?0:itemQuantity));
            this.endDate = endDate;        this.itemTax = String.ValueOF(itemTax);      this.itemPrice = String.ValueOF(itemPrice.setScale(2));
            this.startDate = startDate;    this.itemDisc = String.ValueOF(itemDisc);    this.itemAmount = String.ValueOF(itemAmount.setScale(2));          
        }
    }
    
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : To enable sendtoGurulandAct to be called from Aura page
Inputs      : Salesforce Opportunity Id.
Output      : null
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static void sendtoGuruland (id OppID){
        OpportunityQuoteAPI.sendtoGurulandAct(OppID);
    }
    
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : to store Salesforce fields in Guruland fields format and preparing Salesforce JSON request. 
Inputs      : Salesforce Opportunity Id.
Output      : HttpResponse.
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    public static HttpResponse sendtoGurulandAct (id OppID){
        String Country_Code='';
        String webuser = '';
        Decimal DiscountAmount = 0.00, TotalDiscountAmount = 0.00;
        HttpResponse res;
        Http http = new Http();       
        HttpRequest req = new HttpRequest();
        
        Opportunity Opportunities = new Opportunity(); 
        Opportunities = [SELECT  id,name,createdDate, Account.BillingAddress,Account.BillingCountry,Account.Country__c ,Account.BillingPostalCode,Account.BillingState,Account.BillingCity,
                         Account.BillingStreet, Account.AgentNet_ID__c, CurrencyIsoCode,Total_Gross_Amount__c,Order_Date__c, StageName,Amount, Total_Tax_Amount__c,
                         Total_Discounted_Amount__c, ownerid, createdby.name, Account.name, Account.personEmail,Total_Amount_Before_Discount__c, owner.name,owner.Webuser_ID__c, Opportunity_Number__c,Guruland_Quote_Link__c,Allowed_Payment_Type__c, Country__c FROM Opportunity  WHERE Id =: OppID LIMIT 1];
            list<OpportunityLineItem> OpprtunityLineItem = new list<OpportunityLineItem>([SELECT Product2.name,product2.description, quantity, Unitprice, Discounted_Amount__c,tax_amount__c,Pro_Rate_Amount__c, 
                                                                                          Gross_Amount__C, Start_date__c, End_date__c,Parent__c FROM OpportunityLineItem WHERE OpportunityID =: OppID and Push_to_NetSuite__c =: true]); 
            String Address = '';
            if (Opportunities.Account.BillingAddress != null)
                Address = String.join(
                    new List<String> {Opportunities.Account.BillingAddress.getStreet(),
                        Opportunities.Account.BillingAddress.getCity(),
                        Opportunities.Account.BillingAddress.getCountry()}, 
                    ' ');
            String RootEndpoint, RootEndpoint_Key;
        
            if (runningInASandbox()) {
                RootEndpoint = label.PG_LABEL_OpportunityQuotePaymentAPI_SB; 
                RootEndpoint_Key = label.PG_LABEL_OpportunityPaymentKey_SB;
            }
            else{
                RootEndpoint = label.PG_LABEL_OpportunityQuotePaymentAPI;
                RootEndpoint_Key = label.PG_LABEL_OpportunityPaymentKey; 
            }

            req.setEndpoint(RootEndpoint);
            req.setMethod('POST');
            req.setHeader('x-api-key', RootEndpoint_Key);
            req.setHeader('Content-Type', 'application/json');
            
            List<Items> itemss = new List<Items>();
            
            User rowUser = new User();
            rowUser = [SELECT id,name, MobilePhone,email FROM user WHERE id =: opportunities.ownerid ];
            salesRepInformation rowSalesRep = new salesRepInformation(rowUser.Name, rowUser.Email, rowUser.MobilePhone);
            
            CountryCode__C[] countrycode = CountryCode__c.getAll().Values();
            map<string,string> Cc = new map<string,string>();
            for (integer i = 0 ; i<countrycode.size();i++){
                Cc.put(countrycode[i].name,countrycode[i].code__c);
            }
            if(Opportunities.Account.Country__c <> null){
                Country_Code = Cc.get(string.valueOF(Opportunities.Account.Country__c.toLowerCase()));
            }
            if(Opportunities.Account.AgentNet_ID__c <> null){
                webuser = string.valueOf(Opportunities.Account.AgentNet_ID__c);
            }  
            for (OpportunityLineItem opp : OpprtunityLineItem){
                if(opp.Pro_Rate_Amount__c > 0){
                    DiscountAmount = opp.Discounted_Amount__c + opp.Pro_Rate_Amount__c;
                }
                else{
                    DiscountAmount = opp.Discounted_Amount__c;
                }
                Items Item = new Items(opp.Product2.name,opp.Product2.Description, opp.Quantity, opp.Unitprice,opp.Tax_Amount__c, DiscountAmount, opp.Gross_amount__c, opp.Start_date__c,opp.End_date__c);
                itemss.add(Item);
                TotalDiscountAmount += DiscountAmount;
            }
            
            Order_Info Ordin = new order_info(Country_Code, webuser,Opportunities.Account.name, Address,
                                              Opportunities.Account.personEmail,Opportunities.Opportunity_Number__c, Opportunities.Total_Amount_Before_Discount__c + Opportunities.Total_Tax_Amount__c,
                                              Opportunities.Total_Tax_Amount__c, TotalDiscountAmount, Opportunities.Total_Gross_Amount__c, Opportunities.createdDate,rowSalesRep);
            
            Dataflow dtflow = new Dataflow(Country_Code,Opportunities.Account.AgentNet_ID__c, Opportunities.Opportunity_Number__c, Opportunities.CurrencyIsoCode.toLowerCase(),
                                           Opportunities.Total_Gross_Amount__c, String.Valueof(system.now()), string.ValueOF(Opportunities.stageName), string.valueOf(Opportunities.Allowed_Payment_Type__c), Opportunities.Country__c);
            
            String FinalRequest = prepareJSONRequest(dtflow,Ordin,Itemss);        
            req.setBodyAsBlob(blob.valueOf(FinalRequest));
            system.debug('Request : ' + req.getBody());
            
            
            res = http.send(req);
            System.debug('Guruland Response : ' + res.getBody());
            if(res.getBody().contains('"id":')){
                Map<String, Object> JResponse= (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                String Hash64 = String.valueOf(JResponse.get('hash_base64'));
                Savepoint sp = Database.setSavepoint();  
                try {
                    updateOpportunityLink(OppID,Hash64,false);    
                } catch(DmlException e) {
                    system.debug('ERROR' + e.getMessage());
                }
            }
        
        return res;
        
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Generate payment link with formula ('https://agentnet.integration.propertyguru.com.sg/payment/form?i=' + Hash64) and Guruland Link Created Date.
Inputs      : Salesforce Opportunity Id and Hash_64 from Guruland response.
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    public static void updateOpportunityLink(id OppID, String Hash64, Boolean projectX){
        map<string, Country_Attribute__mdt> mapCountryAtt = EligibilityHandler.getCountryAttribute();
        Opportunity Opp = [select id,stageName,Guruland_quote_link__c, From_Button__c, Guruland_Link_Created_Date__C, Country__c from Opportunity where id =: OppID] ; 
        if(projectX == false){
            if(Opp.stageName =='Pending Online Payment' ||Opp.stageName=='New' || Opp.stageName=='Proposal' ){
                Opp.From_Button__c = true;
                Opp.Guruland_quote_link__c = String.valueOF(mapCountryAtt.get(Opp.Country__c).Payment_Link__c + Hash64);
                Opp.Guruland_Link_Created_Date__c = System.now();
                Opp.stageName = 'Pending Online Payment';
                update Opp;
            }
        }else{
            Opp.From_Button__c = true;
            Opp.stageName = 'Pending Online Payment';
            update Opp;
        }        
    }
    
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : This method is to preparing the JSON request.
<rename CurrencyBySteven into currency (Because variable with name currency is not allowed by Salesforce)>
<And also stringify order info and items>        
Inputs      : Class Dataflow,  Class Order_Info, and List<Items>.
Return      : String Salesforce final JSON request.
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    
    public static string prepareJSONRequest (Dataflow dtflow, Order_Info Ordin, list<Items> Itemss){
        String Data_flow1 = System.JSON.serialize(dtflow);
        String OrderInfo1 = System.JSON.serialize(Ordin);
        String ItemOrder1 = System.JSON.serialize(itemss);
        String Data_flow2 = Data_flow1.replace('CurrencyBySteven','currency');
        String OrderInfo2 = System.JSON.serialize(OrderInfo1);  
        String ItemOrder2 = System.JSON.serialize(ItemOrder1);
        String Data_Flow = data_flow2.substring(0,data_flow2.length()-1);
        String OrderInfo = OrderInfo2.substring(0,OrderInfo2.length()-2);
        String ItemOrder = ItemOrder2.substring(1,ItemOrder2.length()-1);
        String preFinalRequest = '"order_info" : ' + OrderInfo + ', \\"items\\": '+ ItemOrder + '}"';
        String FinalRequest = Data_flow + ',' +  preFinalRequest + '}'; 
        return FinalRequest;
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : to setup validation and error message upon clicking button Ready for Payment.
Inputs      : Salesforce Opportunity Id 
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
   @AuraEnabled
    public static String getOpportunityStage(Id recordId) {    
        Boolean allowFirstTimer = true;
        Boolean allowReferralPromotion = true;
        String otherOppName = '';
        Opportunity Opp = [select Id,Count_of_Referral_Agent_Promotion__c,Country__c,Account.id, Count_of_First_Timer_Promotion_new__c,HasOpportunityLineItem,Account.status__c, StageName, Payment_amount__c,NetSuite_Sales_Order__c, Required_Approval__c, Guruland_Quote_link__c, Sync_In_Progress__c,Account.CEA_Salesperson_Number__c,Recordtype.Name,Account.AgentNet_ID__c from Opportunity where Id =: recordId];
        if( Opp.Count_of_First_Timer_Promotion_new__c > 0 || Opp.Count_of_Referral_Agent_Promotion__c > 0){
            list <Opportunity> otherOpp = new list<Opportunity>([SELECT Id,Name,StageName, Count_of_First_Timer_Promotion_new__c,Count_of_Referral_Agent_Promotion__c FROM Opportunity WHERE id !=: recordId and Account.Id =: Opp.Account.id ]);
            for(Opportunity row : otherOpp){
                if((row.StageName =='Pending Online Payment' || row.StageName =='Pending OMC Approval' || row.StageName =='Closed Won') && row.Count_of_First_Timer_Promotion_new__c > 0){
                    allowfirstTimer = false;
                }
                if((row.StageName =='Pending Online Payment' || row.StageName =='Pending OMC Approval' || row.StageName =='Closed Won') && row.Count_of_Referral_Agent_Promotion__c > 0){
                    allowReferralPromotion = false; 
                    otherOppName = row.name;
                }  
                
            }
        }
        
        // Remove EligibilityHandler Dependency 
        //string identifier = 'AC_SuspendedAccountAllowed';
        //list<string> listCountry = EligibilityHandler.getCountryEligibility(identifier);
        list<string> listCountry =new list<String>{'Thailand', 'Malaysia'};
            system.debug('**************************');

        if(listCountry.contains(opp.Country__c) && Opp.Account.status__c == 'Cancelled') {
            throw new AuraHandledException('Cannot send this record to adminnet because agent status is Cancelled');
        }
        else if(!listCountry.contains(opp.Country__c) && (Opp.Account.status__c == 'Suspended' || Opp.Account.status__c == 'Cancelled')) {
            throw new AuraHandledException('Cannot send this record to adminnet because agent status is Cancelled or Suspended');
        }else if(Opp.HasOpportunityLineItem == false){
            throw new AuraHandledException('Cannot send this opportunity to Adminnet! Please add product to this opportunity.');   
        }/*else if(Opp.Sync_In_Progress__c == TRUE) {
        throw new AuraHandledException('Sync is in progress currently. Cannot execute your request!');
        }else if(Opp.NetSuite_Sales_Order__c == null){
        throw new AuraHandledException('Cannot send this opportunity to Adminnet! NetSuite Sales Order # is empty.');
        }*/
        else if(opp.Count_of_Referral_Agent_Promotion__c > 0 && allowReferralPromotion == false){
            throw new AuraHandledException('Agent has existing Opty(s) '+ otherOppName +' in processing with Referral Entitlement');
        }	
        else if(opp.Count_of_First_Timer_Promotion_new__c > 0 && allowfirstTimer == false){
            throw new AuraHandledException('Cannot submit to Adminnet. There were an first timer opportunity still pending or closed won already, please contact your admin.');
        }
        else if(opp.Required_Approval__c != 'OMC'){
            throw new AuraHandledException('This opportunity needs approval. Please submit for approval.');
        }else if(Opp.Guruland_Quote_Link__c != null  ){            
            throw new AuraHandledException('You had your payment link already.');
        }else if(Opp.Payment_Amount__c <> null){
            throw new AuraHandledException('Your opportunity already paid.');
        }else if(Opp.StageName != 'New' && Opp.StageName != 'Proposal' && Opp.StageName != 'Pending Online Payment' ){            
            throw new AuraHandledException('Cannot execute your request! Make sure you are on the right stage ( \'New\' or \'Proposal\') when click ready for payment.');
        }
        else if(opp.Recordtype.Name == 'B2C' && opp.Country__c == 'Singapore'){
            if(opp.Account.CEA_Salesperson_Number__c == null){
                throw new AuraHandledException('<b>CEA Check</b> <p>&nbsp;</p> Agent Identification Number is blank. <p>&nbsp;</p> Please check Agent\'s record and update.');
            }
            else { 
                if(!Test.isRunningTest()){
                    callCEAEndpointClass.verifyCEADetails(Opp.Account.AgentNet_id__c,opp.id,null);
                }
            }
        }
            
        
        return Opp.StageName;
        
    }
    
    @auraEnabled
public static void createFeeditem(id oppid , String feedData) {
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
    
}
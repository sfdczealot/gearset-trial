/*------------------------------------------------------------
Author      : Thinh Ho
Company     : Viseo Asia PTE LTD
Description : Endpoint to handle integration between Guruland (Quote) and Salesforce (Opportunity).
Inputs      : JSON Request
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
@RestResource(urlMapping='/api/quote/*')
global with sharing class QuotesAPI {
    /*------------------------------------------------------------
Author      : Thinh Ho
Company     : Viseo Asia PTE LTD
Description : GET method. To send requested salesforce opportunity record by Guruland. Guruland must include <id>Salesforce Id to get the Opportunity data.
Inputs      : JSON <id>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @HttpGet
    global static void readQuote() {
        restResponse res = restContext.response;
        string result;
        String opptyId = RestContext.request.params.get('id');
        List<Opportunity> oppties = [SELECT Id, Name, Account.AgentNet_Id__c, Account.Name, 
                                     Account.BillingAddress, Account.Email__c, Opportunity_Number__c, 
                                     Amount, CreatedDate, StageName, Owner.Name,Account.Country__c,
                                     CreatedBy.Name,Total_Tax_Amount__c, Total_Gross_Amount__c,
                                     Total_Amount_Before_Discount__c, Total_Discounted_Amount__c,Owner.Webuser_ID__c,Guruland_Link_Expiry_Date__c, Account.personEmail,
                                     (SELECT Id, Product2.Name, Description, Quantity, UnitPrice,
                                      Tax_Amount__c, Discount_Amount__c, Amount__c,Gross_amount__c,
                                      Start_Date__c, End_Date__c
                                      FROM OpportunityLineItems where Push_to_NetSuite__c =: true)
                                     FROM Opportunity 
                                     WHERE ID=:opptyId];
        
        Quote quote = new Quote(); 
        if (oppties.size()>0){
            quote = new Quote(oppties[0]) ;
            res.statusCode = 200;
            result = system.JSON.serialize(quote);
            res.responseBody = blob.valueOf(result);
        }else{
            res.statusCode = 400;
            result = 'Opportunity requested by Guruland is not found';
            res.responseBody = blob.valueOf(result);
        }
        
    }
    /*------------------------------------------------------------
Author      : Thinh Ho
Company     : Viseo Asia PTE LTD
Description : Post Method to Update Salesforce Opportunty record <Payment Time, Payment Type, and Agent Accepted Time> with data from Guruland. Guruland must include <id>Salesforce Id.
Inputs      : JSON request
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/    
    @HttpPost
    global static void updateQuote() {
        Quote quote = new Quote();
        Savepoint sp = Database.setSavepoint();   
        try {
            List<String> updatedFields = new List<String>();
            Opportunity requestData = (Opportunity) System.JSON.deserialize(RestContext.request.requestBody.tostring(), Opportunity.class);   
            Opportunity existingOppty = [SELECT Id, Name, Payment_Type__c, Payment_Time__c, Agent_Accepted_Time__c ,
                                         Account.AgentNet_Id__c, Account.Name, 
                                         Account.BillingAddress, Account.Email__c, Opportunity_Number__c, 
                                         Amount, CreatedDate, StageName, Owner.Name,Total_Tax_Amount__c,
                                         CreatedBy.Name,
                                         Payment_Amount__c, Payment_Reference__c,Account.Country__c,Total_Gross_Amount__c,Payment_Gateway__c,
                                         Total_Amount_Before_Discount__c,Owner.Webuser_ID__c,Guruland_Link_Expiry_Date__c, Account.personEmail,
                                         (SELECT Id, Product2.Name, Description, Quantity, UnitPrice,
                                          Tax_Amount__c, Discount_Amount__c, Amount__c,Gross_amount__c,
                                          Start_Date__c, End_Date__c
                                          FROM OpportunityLineItems)
                                         FROM Opportunity 
                                         WHERE Opportunity_Number__c = :requestData.Id];
            
            if (existingOppty.Payment_Time__c == null && requestData.Payment_Time__c != null) {
                existingOppty.Payment_Time__c = requestData.Payment_Time__c;
            }
            
            if (existingOppty.Agent_Accepted_Time__c == null && requestData.Agent_Accepted_Time__c != null) {
                existingOppty.Agent_Accepted_Time__c = requestData.Agent_Accepted_Time__c;
            }
            
            existingOppty.Payment_Type__c = requestData.Payment_Type__c;
            existingOppty.Payment_Amount__c = requestData.Payment_Amount__c;
            existingOppty.Payment_Reference__c = requestData.Payment_Reference__c;
            existingOppty.Payment_Gateway__c = requestData.Payment_Gateway__c;
            
            update existingOppty;
            
            quote = new Quote(existingOppty);
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(quote));
            
        } catch (Exception ex) {
            Database.rollback(sp);
            system.debug('ERROR' + ex.getMessage() + ' ' + ex.getLineNumber());
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf(ex.getMessage() + ' ' + ex.getLineNumber());
        }
    }
    /*------------------------------------------------------------
Author      : Thinh Ho
Company     : Viseo Asia PTE LTD
Description : Wrapper class to map salesforce field into guruland quote JSON request.
Inputs      : String Opportunity <StageName>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/    
    global class Quote {
        String region;
        String agent_id;
        String invoice_id;
        String total;
        OrderInfo order_info;
        String created;
        String status; 
        String expiry;
        public Quote() {
            
        }
        
        public Quote(Opportunity oppty) {
            String countryCode='';
            CountryCode__C[] country_Code = CountryCode__c.getAll().Values();
            map<string,string> Cc = new map<string,string>();
            for (integer i = 0 ; i<country_Code.size();i++){
                Cc.put(country_Code[i].name,country_Code[i].code__c);
            }
            if(oppty.Account.Country__c <> null){
                countryCode = Cc.get(string.valueOF(oppty.Account.Country__c.toLowerCase()));
            }
            this.region = countryCode;
            this.agent_id = oppty.Account.AgentNet_Id__c;
            this.invoice_id = oppty.Opportunity_Number__c;
            this.total = String.valueOf(oppty.Total_Gross_Amount__c.setScale(2));   
            this.created = String.valueOf(oppty.CreatedDate);
            this.status = translateStage(oppty.StageName);
            this.order_info = new OrderInfo(oppty);
            
            this.expiry = string.valueOF(oppty.Guruland_Link_Expiry_Date__c.format('YYYY-MM-dd HH:mm:ss'));
        }
        
        /*------------------------------------------------------------
Author      : Thinh Ho
Company     : Viseo Asia PTE LTD
Description : This method translates opportunity stage to guruland quote status.
Inputs      : String Opportunity <StageName>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
        private String translateStage(String opptyStage) {
            Map<String, String> statusMap = new Map<String, String> {
                'new'                       => 'close',
                    'proposal'                  => 'close',
                    'pending online payment'    => 'open',  
                    'pending omc approval'      => 'close',
                    'closed won'                => 'close',
                    'closed lost'               => 'close'
                    };
                        opptyStage = opptyStage.toLowerCase();
            String quoteStatus = opptyStage; 
            if (statusMap.containsKey(opptyStage))
                quoteStatus = statusMap.get(opptyStage);
            else
                quoteStatus = opptyStage;
            return quoteStatus;
        }
    } 
    /*------------------------------------------------------------
Author      : Thinh Ho
Company     : Viseo Asia PTE LTD
Description : Wrapper class to map Salesforce fields into guruland quote (order_info) JSON request.
Inputs      : String Opportunity <StageName>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/  
    global class OrderInfo {
        String region;          String webuserId;   	String customerName;    String billaddress;
        String email;           String referenceNo;     String createdDate;		SalesRepInformation salesRep; 
        List<Item> items;   	String tranAmount;      String tranTax;
        String tranDisc;        String tranTotal;
        
        public OrderInfo(Opportunity oppty) {
            String countryCode='';
            String webuser='';
            User rowUser = new User();
            rowUser = [SELECT id,name, MobilePhone,email FROM user WHERE id =: oppty.ownerid ];
            salesRepInformation rowSalesRep = new salesRepInformation(rowUser.Name, rowUser.Email, rowUser.MobilePhone);
            if(oppty.Account.AgentNet_Id__c <> null){
                webuser = string.valueOF(oppty.Account.AgentNet_Id__c);
            }
            CountryCode__C[] country_Code = CountryCode__c.getAll().Values();
            map<string,string> Cc = new map<string,string>();
            for (integer i = 0 ; i<country_Code.size();i++){
                Cc.put(country_Code[i].name,country_Code[i].code__c);
            }
            if(oppty.Account.Country__c <> null){
                countryCode = Cc.get(string.valueOF(oppty.Account.Country__c.toLowerCase()));
            }
            
            this.region = countryCode;
            this.webuserId = webuser;
            this.customerName = oppty.Account.Name;
            if (oppty.Account.BillingAddress != null)
                this.billaddress = String.join(
                    new List<String> {oppty.Account.BillingAddress.getStreet(),
                        oppty.Account.BillingAddress.getCity(),
                        oppty.Account.BillingAddress.getCountry()}, 
                    ' ');
            this.email = oppty.Account.personEmail;
            this.referenceNo = oppty.Opportunity_Number__c;
            this.createdDate = String.valueOf(oppty.CreatedDate);
            this.tranAmount = String.valueOf((oppty.Total_Amount_Before_Discount__c + oppty.Total_Tax_Amount__c.setScale(2)));
            this.tranTax = String.valueOf(oppty.Total_Tax_Amount__c.setScale(2));
            this.tranDisc = String.valueOf(oppty.Total_Discounted_Amount__c);
            this.tranTotal = String.valueOf(oppty.Total_Gross_Amount__c.setScale(2));
            this.salesRep = rowSalesRep;
            
            this.items = new List<Item>();
            for (OpportunityLineItem opptyItem : oppty.OpportunityLineItems) {
                items.add(new Item(opptyItem));
            }
        }
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Wrapper class to map Salesforce fields into guruland quote(salesRep) JSON request.
Inputs      : String Opportunity <StageName>
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
Author      : Thinh Ho
Company     : Viseo Asia PTE LTD
Description : Wrapper class to map Salesforce fields into guruland quote(item) JSON request.
Inputs      : String Opportunity <StageName>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/  
    global class Item {
        String itemName;        String itemDescription;     String itemQuantity;    String itemPrice;       String itemTax;
        String itemDisc;        String itemAmount;          String startDate;       String endDate;
        
        public Item(OpportunityLineItem opptyItem) {
            this.itemName = opptyItem.Product2.Name;
            this.itemDescription = opptyItem.Description;
            this.itemQuantity = String.valueOf(opptyItem.Quantity);
            this.itemPrice = String.valueOf(opptyItem.UnitPrice.setScale(2));
            this.itemTax = String.valueOf(opptyItem.Tax_Amount__c);
            this.itemDisc = String.valueOf(opptyItem.Discount_Amount__c);
            this.itemAmount = String.valueOf(opptyItem.Gross_amount__c.setScale(2));
            this.startDate = String.valueOf(opptyItem.Start_Date__c);
            this.endDate = String.valueOf(opptyItem.End_Date__c);
        }
    }
    /*------------------------------------------------------------
Author      : Thinh Ho
Company     : Viseo Asia PTE LTD
Description : Wrapper class to store Salesforce fields in Quote data_flow JSON request.
Inputs      : String Opportunity <StageName>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/  
    global class OpptyInterface {
        String opportunityId;
        String paymentTime;
        String paymentMethod;
        String agentAcceptedTime;
    }
}
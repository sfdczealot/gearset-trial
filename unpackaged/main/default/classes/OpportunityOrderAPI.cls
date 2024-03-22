/*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Opportunity Order Endpoint
Inputs      :
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
@RestResource(urlMapping='/api/order/*')
global class OpportunityOrderAPI {

    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Wrapper class to map salesforce opportunity fields into order PurchasedProducts fields.
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    global class PurchasedProducts {
        String internalId;              String autoActivate;              String externalProductId;
        integer salesPersonId;          String validityPeriod;
        String chargeCurrency;          String durationPeriod;            String startDate;
        String chargeValue;             String statusCode;                String expiryDate;
        String netAmount;               Integer createdBy;                String parent;
        String quantity;                String standardProduct;           String parentInternalId;
        list<purchasedProductFunctions> purchasedProductFunctions;

        PurchasedProducts   (String internalId,String autoActivate,String externalProductId,integer salesPersonId,String validityPeriod,
                             String chargeCurrency,String durationPeriod,String startDate,String chargeValue,String statusCode,String expiryDate,String netAmount,
                             Integer createdBy, String parent, String quantity, String standardProduct,String parentInternalId,list<purchasedProductFunctions> ppf){

                                 This.internalId = internalId;              This.parentInternalId = parentInternalId;       This.externalProductId = externalProductId;
                                 This.salesPersonId = salesPersonId;        This.validityPeriod = validityPeriod;           This.chargeCurrency = chargeCurrency.toUpperCase();
                                 This.durationPeriod = durationPeriod;      This.startDate = startDate + ' 00:00:00';       This.autoActivate = autoActivate.substring(0,1).toUpperCase();
                                 This.chargeValue = chargeValue;            This.statusCode = statusCode;                   This.expiryDate = expiryDate + ' 00:00:00';
                                 This.netAmount = netAmount;                This.createdBy = createdBy;                     This.parent = parent;
                                 This.quantity = quantity;                  This.standardProduct = standardProduct;
                                 this.purchasedProductFunctions = ppf;
                             }
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Wrapper class to map salesforce opportunity fields into order Dataflow fields.
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    global class Data_Flow {
        String totalAmount;             integer webuserId;             Integer createdBy;
        String invoiceId;               integer billingSourceId;       String source;
        String purchasedDate;           String externalId;             list<purchasedProducts> purchasedProducts;

        Data_Flow(  Decimal totalAmount,string webuserId,integer createdBy,id invoiceId,integer billingSourceId,String source,
                  String purchasedDate,string externalId,  list<purchasedProducts> pp){

                      This.totalAmount = String.Valueof(totalAmount);                   This.webuserId = Integer.valueOf(webuserId);    This.createdBy = createdBy;
                      This.invoiceId = invoiceId;                                       This.billingSourceId = billingSourceId;         This.source = source;
                      This.externalId = String.Valueof(externalId);                     this.purchasedProducts = pp;
                      This.purchasedDate = purchasedDate;
                  }
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Wrapper class to map salesforce opportunity fields into order PurchasedProductFunctions fields.
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    global class PurchasedProductFunctions{
        String code; String value = '0';
        PurchasedProductFunctions(string code){
            this.code = code;
        }
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : GET Method, send requested salesforce opportunity data to Property Guru
Inputs      : Salesforce Opportunity Id and Hash_64 from Guruland response
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @HttpGet
    global static void getOpportunity() {
        String OppID = RestContext.request.params.get('id');    String result;      String internalID='';
        String Parentid;                                        Date startDate;     Date dueDate;
        Integer numberDaysDue;                                  String comma ;      String SNo_c;
        String Sno;                                             Date actualEndDate;
        RestResponse res = RestContext.response;
        String oppQuoteNum;
        system.debug(OppID +'  OppID ');
        list<Opportunity> Opportunitiess = new list<Opportunity>( [SELECT id,name, Account.BillingCountry ,Account.BillingPostalCode,Account.BillingState,Account.BillingCity,
                                                                   Account.BillingStreet, Account.AgentNet_ID__c, CurrencyIsoCode,Total_Gross_Amount__c,Order_Date__c,
                                                                   StageName,Amount, Total_Tax_Amount__c, Total_Discounted_Amount__c, ownerid, createdby.name, Account.name,
                                                                   Account.personEmail, owner.name, Opportunity_Number__c,Guruland_Quote_Link__c, owner.Webuser_ID__c,
                                                                   Country__c, Total_Amount__c,
                                                                   (SELECT Id,Opp_Quote_Ref_num__c from Quotes WHERE isSyncing =true limit 1)
                                                                   FROM Opportunity  WHERE Id =: OppID LIMIT 1]);
        if(Opportunitiess.size()>0){
            String ValidityPeriod;
            String DurationPeriod;
            String Standard_Product='';
            Opportunity Opportunities = new Opportunity();
            Opportunities = Opportunitiess.get(0);
             //PGAUTO-2694
             if(Opportunities.quotes.size()>0){
            oppQuoteNum=Opportunities.quotes[0].Opp_Quote_Ref_num__c;
             }
             else{
             oppQuoteNum=Opportunities.Opportunity_Number__c;
             }
            list<OpportunityLineItem> Opl = new list<OpportunityLineItem>([SELECT SNo__c,Product2.name,product2.product_function__c,product2.description, quantity, Unitprice,
                                                                           Discount_Amount__c,tax_amount__c, Createdby.name,Product2.NetSuite_Id__c,
                                                                           Opportunity.OwnerID,Opportunity.CurrencyIsoCode,Gross_Amount__C, Start_date__c, End_date__c,PO__c,
                                                                           Product2.CustItem_Validity_Value__c, Product2.CustItem_Validity_Unit__c, Product2.CustItem_Duration_Value__c,
                                                                           Product2.CustItem_Duration_Unit__c,opportunity.Opportunity_Number__c,Actual_Start_Date__c,
                                                                           opportunity.owner.Webuser_ID__c, Opportunity.Order_Type_Clone__c,Opportunity.Opportunity_Type__c,
                                                                           Opportunity.Country__c, Opportunity.RecordTypeId, Amount_Despite_VIP__c, Amount__c
                                                                           FROM OpportunityLineItem WHERE OpportunityID =: OppID ]);

            List<purchasedProducts> pP = new List<purchasedProducts>();
            //Matching Salesforce fields with Guruland fields format
            for (OpportunityLineItem opp : Opl){
                String internalIdForLineItems = oppQuoteNum;
                system.debug('opp.Actual_Start_Date__c ' +opp.Actual_Start_Date__c );
                if(opp.Opportunity.RecordTypeId == '0127F000000K50eQAC'){
                    //If b2c
                    //if not project x
                    startDate = opp.Actual_Start_Date__c;
                    if((opp.Opportunity.Order_Type_Clone__c  == 'Contract - Upgrade' || opp.Opportunity.Opportunity_Type__c == 'B2C - Upgrade') && opp.Opportunity.country__c == 'Malaysia') {
                        //if MY upgrade
                        actualEndDate = opp.End_Date__c;
                    } else {
                        //for other b2c cases
                        actualEndDate = opp.Start_Date__c == opp.Actual_Start_Date__c ? opp.End_Date__c : opp.Actual_Start_Date__c.addDays(opp.Start_Date__c.daysBetween(opp.End_Date__c));
                    }

                }
                else{
                    //b2b
                    startDate = opp.Start_Date__c;
                    actualEndDate = opp.End_Date__c;
                }
                ValidityPeriod = opp.Product2.CustItem_Validity_Value__c + ' ' +  opp.Product2.CustItem_Validity_Unit__c;
                DurationPeriod =  opp.Product2.CustItem_Duration_Value__c + ' ' + opp.Product2.CustItem_Duration_Unit__c;


                if(opp.SNo__c <> null){
                    SNo = string.valueof(opp.SNo__c);
                    comma = Sno.substring(Sno.length()-2, Sno.length());
                    if( comma == '00'){
                        internalID = internalIdForLineItems + '_' + Sno.substring(0,Sno.length()-3);
                        ParentID = internalID;
                        Standard_Product = '1';
                    }else{
                        SNo_c = string.valueof(opp.SNo__c);
                        Standard_Product = '0';
                        if(comma.substring(0,1) == '0'){
                            internalID = internalIdForLineItems + '_' + Sno.substring(0,1) + '_' + comma.substring(1,comma.length()) ;

                        }else{
                            internalID = internalIdForLineItems + '_' + String.valueOf(opp.SNo__c).replace('.', '_');
                        }
                        OpportunityLineItem OppLine = new OpportunityLineItem();
                        OppLine = [SELECT id,opportunityid, Opportunity.Opportunity_Number__c
                                   FROM OpportunityLineItem
                                   WHERE opportunityid =: OppID and Sno__c =: Decimal.valueOF(Sno_c.substring(0,1) + '.00')];
                        parentid = oppQuoteNum + '_' + Sno_c.substring(0,Sno_c.length()-3);
                    }
                }
                list<purchasedProductFunctions> ppp = new list<purchasedProductFunctions>();
                if(opp.product2.product_function__c <> null){
                    purchasedProductFunctions pf = new  PurchasedProductFunctions(opp.product2.product_function__c);
                    ppp.add(pf);
                }

                //added for PGAUTO-6980 (gst implemetation)
                Decimal decNetAmount = opp.Gross_Amount__c;
                if(String.isNotBlank(Opportunities.Country__c) && Opportunities.Country__c.equals('Singapore')) {
                    decNetAmount = opp.Amount__c;
                }

                purchasedProducts prod = new purchasedProducts( internalID,string.valueof(opp.PO__c), opp.Product2.NetSuite_Id__c,
                                                               integer.valueOf(opp.opportunity.owner.Webuser_ID__c), ValidityPeriod, opp.Opportunity.CurrencyIsoCode,DurationPeriod,
                                                               string.valueof(startDate), string.valueof(opp.UnitPrice), 'ACTIVE', string.valueof(actualEndDate),
                                                               string.valueof(decNetAmount), integer.valueOf(opp.opportunity.owner.Webuser_ID__c),
                                                               opp.Product2.NetSuite_Id__c, string.valueof(opp.quantity), Standard_Product, parentid, ppp) ;
                pP.add(prod);
            }

            //added for PGAUTO-6980 (gst implemetation)
            Decimal decTotalAmount = Opportunities.Total_Gross_Amount__c;
            if(String.isNotBlank(Opportunities.Country__c) && Opportunities.Country__c.equals('Singapore')) {
                decTotalAmount = Opportunities.Total_Amount__c;
            }
            Data_Flow df = new Data_Flow(decTotalAmount, Opportunities.Account.AgentNet_id__c, integer.valueOf(Opportunities.owner.Webuser_ID__c), Opportunities.id, 3,
                                         'offline', String.Valueof(system.now()), (oppQuoteNum), pp);
            if (df <> null){
                res.statusCode = 200;
                result =   system.JSON.serialize(df);
                res.responseBody = blob.valueOf(result);
                system.debug('OrderAPI Response' + result );
            }
        }else{
            res.statusCode = 400;
            result =  'Opportunity requested by Guruland does not exist in Salesforce.';
            res.responseBody = blob.valueOf(result);
        }

    }
}
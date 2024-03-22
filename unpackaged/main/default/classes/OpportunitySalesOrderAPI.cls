@RestResource(urlMapping='/api/nsorder/*')
global class OpportunitySalesOrderAPI {
    
    global class SOUpdNSPayload {
        String type;
        SOUpdNS record;
    }
    
    global class SOUpdNS {
        String optynumber_ns;
        SONSitem optylineitem;
        OptySplitList RecordSplit;
        OptyRecord NewRecord;
        String OMCApprovalDate;
        String status;
        String action;
    }
    
    global class OptyDeposit {
        String refnum;
        Decimal amount;
        Datetime paydate;
    }
    
     global class OptyRecord {
        OptyItemList line;
        OptyAttList att;
        OptyOffPayList offpaylist;
        String Memo;
        String SendToSF = 'F';
        String CurrencyIsoCode;
        String UserId;
        Date OrderDate;
        String StageName;
        String RecordTypeId;
        String SubId;
        String PONo;
        String Remarks;
        String Id;
        String AccountId;
        Decimal PaymentTermId;
        String SyncToAN = 'T';
        Decimal TotalDiscAmt;
        String RelatedSO;
        String OptyNumber;
        String ContactId;
        OptyDeposit deposit;
        String AutoActivation;
        String SalesPeriod;
        String InvoiceId;
    }
    
    global class OptySplitList {
        list<OptySplit> EntryList = new list<OptySplit>();
    }
    
    global class OptyItemList {
        list<OptyItem> EntryList = new list<OptyItem>();
    }
    
    global class OptyAttList {
        Integer count = 0;
        list<OptyAtt> EntryList = new list<OptyAtt>();
    }
    
    global class OptyOffPayList {
        list<OptyOffPay> EntryList = new list<OptyOffPay>();
    }
    
    global class OptyAtt {
        String att;
        String name;
        String atttype;
    }
    
    global class OptyOffPay {
        String PaymentMethod;
        String refnum;
        Decimal amount;
        Date paydate;
    }
    
    global class OptySplit {
        String Employee;
        Decimal Contribution;
        Decimal Amount;
    }
    
    global class OptyItem {
        String SFLineId;
        String ItemId;
        String Descr;
        Decimal UnitPrice;
        Decimal Quantity;
        Decimal GrossAmt;
        String DiscItemId;
        Decimal DiscRate;
        Decimal GSTVatRate;
        Date StartDate;
        Date EndDate;
        Decimal ItmAmt;
        Decimal RemDisc;
        String TaxCode;
        Decimal SNO;
        Boolean Comp;
        String Duration;
        Decimal DiscRateNumber;
        String AutoActivation;
    }
    
    global class SONSitem {
        String SFlineId;
    }
    
    @HttpGet
    global static void getOpportunity() {
        String OptyId = RestContext.request.params.get('id');
        String result;
        RestResponse res = RestContext.response;
        
        OptySplitList OSL = new OptySplitList();
        OptyRecord OPR = new OptyRecord();
        OptyDeposit OD = new OptyDeposit();
        OptyItemList OIL = new OptyItemList();
        OptyAttList OAL = new OptyAttList();
        OptyOffPayList OFPL = new OptyOffPayList();
        Integer attcount = 0;
        Boolean skipatt = false;
        
        List <Opportunity> OptyRec = [
            select
            RecordTypeId, Memo__c, CurrencyIsoCode, Owner.NS_Internal_ID__c, Order_Date__c, StageName, 
            Subsidiary__r.NS_Subsidiary_Internal_ID__c, Customer_PO__c, Remarks__c, Id, 
            Account.NetSuite_Id__c, Billing_Contact__r.NetSuite_Id__c, Payment_Term__r.NS_Payment_Term_ID__c, 
            Total_Discounted_Amount__c, Related_Opportunity__r.Current_Sales_Order_Id__c, 
            Opportunity_Number__c, Current_Sales_Order_Id__c, OMC_Approved_Date__c,
            Payment_Reference__c, Payment_Amount__c, Payment_Time__c, Sales_Period__r.Name, Attachment_Limit_Exceeded__c
            from
            opportunity
            where
            id =: OptyId
            LIMIT 1
        ];
        
        List <OpportunityLineItem> OptyRecLineItem = [
            select 
            Id, Product2.NetSuite_Id__c, Line_Description2__c, UnitPrice, Quantity,
            Gross_Amount__c, Discounted__c,
            GST_VAT_Rate__c, Actual_Start_Date__c, Start_Date__c, End_Date__c, Discounted_Amount__c, GST_VAT_Code_NS_InternalID__c,
            SNo__c, Complimentary__c, Discounted_10dp__c, Product_Duration__c, PO__c, Pro_Rate_Amount__c,Opportunity.RecordTypeId,
            Opportunity.Order_Type_Clone__c  , Opportunity.Country__c
            from
            OpportunityLineItem 
            where
            OpportunityId =: OptyId and Push_To_NetSuite__c = true
        ];
        
        List <OpportunitySplit> OptyRecLineSplit = [
            select 
            id, OpportunityId, Split, SplitAmount, SplitNote, SplitOwnerId, SplitPercentage,
            SplitTypeId ,Email__c,NS_Internal_ID__c from OpportunitySplit
            where
            OpportunityId  =: OptyId and (SplitTypeId = '149N0000000008aIAA' or SplitTypeId = '1497F0000004rmjQAA')
        ];
        
        List <Attachment> OptyAttachment = [
            select
            id, Body, ContentType, Name from Attachment
            where
            parentid =: OptyId
        ];
        
        List <ContentDocumentLink> OptyAttachmentDocumentLink = [
            SELECT
            ContentDocumentId
            FROM
            ContentDocumentLink
            WHERE
            LinkedEntityId =: OptyId
        ];
        
        List <Payment__c> OptyRecOfflinePayment = [
            select 
            Name, Amount__c, Payment_Method__r.NS_Internal_ID__c, Reference_Number__c, Payment_Date__c from Payment__c
            where
            Opportunity_Record__c  =: OptyId
        ];
        
        SOUpdNSPayload SONSPayload = new SOUpdNSPayload();
        SOUpdNS OC = new SOUpdNS();
        
        //For setting auto activation
        OPR.AutoActivation = 'F';
        for(OpportunityLineItem rowsitem : OptyRecLineItem) {
            if(rowsitem.PO__c) {
                OPR.AutoActivation = 'T';
                break;
            }
        }
        
        for(Opportunity row : OptyRec) {
            OPR.Memo = row.Memo__c;
            OPR.SendToSF = 'F';
            OPR.CurrencyIsoCode = row.CurrencyIsoCode;
            OPR.UserId = row.Owner.NS_Internal_ID__c;
            OPR.OrderDate = row.Order_Date__c;
            OPR.StageName = row.StageName;
            OPR.RecordTypeId = row.RecordTypeId;
            OPR.SubId = row.Subsidiary__r.NS_Subsidiary_Internal_ID__c;
            OPR.PONo = row.Customer_PO__c;
            OPR.Remarks = row.Remarks__c;
            OPR.Id = row.Id;
            OPR.AccountId = row.Account.NetSuite_Id__c;
            OPR.PaymentTermId = row.Payment_Term__r.NS_Payment_Term_ID__c;
            OPR.SyncToAN = 'T';
            OPR.TotalDiscAmt = row.Total_Discounted_Amount__c;
            OPR.RelatedSO = row.Related_Opportunity__r.Current_Sales_Order_Id__c;
            OPR.OptyNumber = row.Opportunity_Number__c;
            OC.optynumber_ns = row.Current_Sales_Order_Id__c;
            OC.status = row.StageName;
            OC.OMCApprovalDate = row.OMC_Approved_Date__c<>null?string.valueof(row.OMC_Approved_Date__c.format('YYYY-MM-dd HH:mm:ss')):'';
            OPR.ContactId = row.Billing_Contact__r.NetSuite_Id__c;
            OPR.SalesPeriod = row.Sales_Period__r.Name;
            OD.refnum = row.Payment_Reference__c;
            OD.amount = row.Payment_Amount__c;
            OD.paydate = row.Payment_Time__c;
            skipatt = row.Attachment_Limit_Exceeded__c;
        }
        
        for(OpportunitySplit rowsplit : OptyRecLineSplit) {
            OptySplit OS = new OptySplit();
            OS.Employee = rowsplit.NS_Internal_ID__c;
            OS.Contribution = rowsplit.SplitPercentage;
            OS.Amount = rowsplit.SplitAmount;
            OSL.EntryList.add(OS);
        }
        
        for(OpportunityLineItem rowsitem : OptyRecLineItem) {
            OptyItem OI = new OptyItem();
            OI.SFLineId = rowsitem.Id;
            OI.ItemId = rowsitem.Product2.NetSuite_Id__c;
            OI.Descr = rowsitem.Line_Description2__c;
            OI.UnitPrice = rowsitem.UnitPrice;
            OI.Quantity = rowsitem.Quantity;
            OI.GrossAmt = rowsitem.Gross_Amount__c;
            OI.DiscRate = rowsitem.Discounted__c;
            OI.GSTVatRate = rowsitem.GST_VAT_Rate__c;
            if(rowsitem.Opportunity.RecordTypeId == '0127F000000K50eQAC'){
                //If b2c
                //if not project x
                OI.StartDate = rowsitem.Actual_Start_Date__c;
                if(rowsItem.Opportunity.Order_Type_Clone__c   == 'Contract - Upgrade' && rowsItem.Opportunity.country__c == 'Malaysia') {
                    //if MY upgrade
                    OI.EndDate = rowsitem.End_Date__c;
                } else {
                    System.debug('@@'+ rowsitem);
                    //for other b2c cases
                    OI.EndDate = rowsitem.Start_Date__c == rowsitem.Actual_Start_Date__c ? rowsitem.End_Date__c : rowsitem.Actual_Start_Date__c.addDays(rowsitem.Start_Date__c.daysBetween(rowsitem.End_Date__c));
                }
                
            }
            else{
                //b2b
                OI.StartDate = rowsitem.Start_Date__c;
                OI.EndDate = rowsitem.End_Date__c;
            }
            if(rowsitem.Pro_Rate_Amount__c > 0){
                OI.ItmAmt = rowsitem.Discounted_Amount__c + rowsitem.Pro_Rate_Amount__c;
            }
            else{
                OI.ItmAmt = rowsitem.Discounted_Amount__c;
            }
            OI.RemDisc = rowsitem.Discounted_Amount__c;
            OI.TaxCode = rowsitem.GST_VAT_Code_NS_InternalID__c;
            OI.SNO = rowsitem.SNo__c;
            OI.Duration = rowsitem.Product_Duration__c;
            OI.Comp = rowsitem.Complimentary__c;
            OI.DiscRateNumber = rowsitem.Discounted_10dp__c;
            OI.AutoActivation = rowsitem.PO__c ? 'T' : 'F';
            OIL.EntryList.add(OI);
        }
        
        if(skipatt == false){
            for(ContentDocumentLink rowsattDL : OptyAttachmentDocumentLink) {
                List <ContentVersion> OptyAttachmentContentVersion = [
                    SELECT
                    ContentModifiedById,ContentDocumentId,FileExtension,
                    FileType,ContentSize,ContentUrl,Id,VersionData,
                    VersionNumber,Title
                    FROM
                    ContentVersion
                    where
                    ContentDocumentId =: rowsattDL.ContentDocumentId
                ];
                for(ContentVersion rowsattCV : OptyAttachmentContentVersion) {
                    
                    attcount++;
                    OptyAtt OA = new OptyAtt();
                    OA.name = rowsattCV.Title;
                    OA.att = EncodingUtil.base64Encode(rowsattCV.VersionData);
                    OA.atttype = rowsattCV.FileType;
                    OAL.EntryList.add(OA);
                }
            }
        }
        
        for(Payment__c rowpayment : OptyRecOfflinePayment) {
            OptyOffPay OFP = new OptyOffPay();
            OFP.refnum = rowpayment.Reference_Number__c;
            OFP.PaymentMethod = rowpayment.Payment_Method__r.NS_Internal_ID__c;
            OFP.amount = rowpayment.Amount__c;
            OFP.paydate = rowpayment.Payment_Date__c;
            OFPL.EntryList.add(OFP);
        }
        
        OAL.count = attcount;
        OPR.deposit = OD;
        OPR.line = OIL;
        OPR.att = OAL;
        OPR.offpaylist = OFPL;
        OC.NewRecord = OPR;
        OC.RecordSplit = OSL;
        OC.action = 'OptyRec';
        SONSPayload.type = 'OpptySync';
        SONSPayload.record = OC;
        
        if(OptyRec.size()>0){
                                  
            if (OptyId <> null){
                res.statusCode = 200;
                result = system.JSON.serialize(SONSPayload);
                res.responseBody = blob.valueOf(result);
                system.debug('NSOrderAPI Response' + result );
            }
        } else{
            res.statusCode = 400;
            result =  'Opportunity does not exist in Salesforce.';
            res.responseBody = blob.valueOf(result);              
        }      
    }   
}
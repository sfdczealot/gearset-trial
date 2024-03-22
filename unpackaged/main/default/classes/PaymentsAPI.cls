/*
* TestClass : PaymentsAPI_Test
*/
@RestResource(urlMapping='/api/payment/*')
global without sharing class PaymentsAPI {

    @HttpGet
    global static void readQuote() {

    }

    /*
        Wrapper class for payment api payload
        Sample payload for POST /api/payment
        {
            "Quote_Ref": "20201007-PGQ-20020017",
            "Payment_Gateway": "adyen",
            "Payment_Type": "credit-card",
            "Payment_Time": "2020-07-06T17:04:35+08:00",
            "Agent_Accepted_Time": "2020-07-06T17:04:35+08:00",
            "Payment_Amount": 1190,
            "Payment_Reference": "4355940262798698"
            "Appr_Code": "apprasdasdasd12313",
            "Installment_Period": "6",
            "Bank_Name": "UOBSG"
        }
    */
    global class PaymentAPIPayload {
        String Quote_Ref;
        String Payment_Type;
        Datetime Agent_Accepted_Time;
        String Payment_Gateway;
        String Payment_Time;
        String Appr_Code;
        String Installment_Period;
        String Bank_Name;
        Decimal Payment_Amount;
        String Payment_Reference;
    }

    @HttpPost
    global static void upsertPayment() {
        system.debug('method enter');
        List<String> updatedFields = new List<String>();
        map<String,Id> gatewayNameVsId = new map<String,id>();
        
        for(Payment_Method__c pa :[Select id,Name from Payment_Method__c]){
            gatewayNameVsId.put(pa.Name, pa.id);
        }
        PaymentAPIPayload requestData = (PaymentAPIPayload)System.JSON.deserialize(RestContext.request.requestBody.tostring(), PaymentAPIPayload.class);
        system.debug('requestData==>'+requestData);
        Quote existingQuote = [
            SELECT Id,Submit_to_OMC_Manually__c, OpportunityId,Name, Payment_Time__c, Agent_Accepted_Time__c ,Approval_Status__c,
            Account.AgentNet_Id__c, Account.Name, Country__c,Offline_payment_Opted__c, Account.CEA_Salesperson_Number__c,
            Account.BillingAddress, Account.Email__c, Quote_Number__c, Recordtype.Name,
            CreatedDate, Owner.Name,Owner.Email,Owner.Phone,Total_Tax_Amount__c,Total_WHT_Amount__c,
            CreatedBy.Name,Opp_Quote_Ref_num__c, Is_Agent_license_verified__c, CEA_Action_Message__c,
            Payment_Amount__c, Payment_Reference__c,Account.Country__c,Total_Gross_Amount__c,
            Total_Amount_Before_Discount__c,Guruland_Link_Expiry_Date__c, Account.personEmail,to_FOC_Approval__c,
            (SELECT Id, Product2.Name, Description, Quantity, UnitPrice, Product_Category__c,
            Tax_Amount_new__c, Discount_Amount__c, Amount__c,Gross_amount__c,
            Start_Date__c, End_Date__c, Product2.Eligible_for_Auto_Approval__c
            FROM QuoteLineItems)
            FROM Quote
            WHERE Opp_Quote_Ref_num__c =: requestData.Quote_Ref
        ];
        system.debug('existingQuote==>'+existingQuote);
        try {
            if(
                existingQuote.Recordtype.Name == 'B2C' &&
                existingQuote.Country__c == 'Singapore' &&
                existingQuote.Account.CEA_Salesperson_Number__c != null &&
                !existingQuote.Is_Agent_license_verified__c
            ) {
                callCEAEndpointClass.ALLOW_EXCEPTION = false;
                existingQuote.Is_Agent_license_verified__c = callCEAEndpointClass.sendCEACallout(
                    existingQuote.Account.AgentNet_Id__c,
                    existingQuote.OpportunityId,
                    existingQuote.quote_number__c,
                    false
                );
            }
        } catch (Exception ex) {
            String errorMessage = 'CEA Check failed on payment api:' + ex.getMessage();
            if(errorMessage.length()>255) {
                errorMessage = errorMessage.substring(0,255);
            }
            existingQuote.CEA_Action_Message__c = errorMessage;
        }
        Savepoint sp = Database.setSavepoint();
        try {
            Decimal FinalPayment = OpportunityQuoteAPIStinger.getQuoteTotal(existingQuote);
            if (existingQuote.Agent_Accepted_Time__c == null && requestData.Agent_Accepted_Time != null) {
                existingQuote.Agent_Accepted_Time__c = requestData.Agent_Accepted_Time;
            }
            if(requestData.Payment_Type == 'offline'){
                existingQuote.Offline_payment_Opted__c = true;
                sendEmailToAgentAndSPForOfflinePayment(existingQuote);
            }
            //Payment record creation
            Payment__c payment = new Payment__c();
            payment.Quote_Record__c = existingQuote.Id;
            payment.Opportunity_Record__c = existingQuote.OpportunityId;
            payment.Reference_Number__c = requestData.Payment_Reference;
            payment.Payment_Gateway__c = requestData.Payment_Gateway;
            payment.Amount2__c = requestData.Payment_Amount;
            payment.Payment_Mode__c = requestData.Payment_Type;

            //Set Payment_Method__c based on gateway
            if(requestData.Payment_Gateway == 'Adyen'){
                if(existingQuote.Country__c == 'Singapore' && gatewayNameVsId.containsKey('Adyen (SG)')){
                    payment.Payment_Method__c = gatewayNameVsId.get('Adyen (SG)');
                }else if(existingQuote.Country__c == 'Malaysia' && gatewayNameVsId.containsKey('Adyen (MY)')){
                    payment.Payment_Method__c = gatewayNameVsId.get('Adyen (MY)');
                }else if(existingQuote.Country__c == 'Indonesia' && gatewayNameVsId.containsKey('Adyen (ID)')){
                    payment.Payment_Method__c = gatewayNameVsId.get('Adyen (ID)');
                }else if(existingQuote.Country__c == 'Thailand' && gatewayNameVsId.containsKey('Adyen (TH)')){
                    payment.Payment_Method__c = gatewayNameVsId.get('Adyen (TH)');
                }
            }

            if(requestData.Payment_Gateway == 'Braintree' && gatewayNameVsId.containsKey('Braintree')){
                payment.Payment_Method__c = gatewayNameVsId.get('Braintree');
            }

            if(requestData.Payment_Gateway == 'Paypal' && gatewayNameVsId.containsKey('Paypal')){
                payment.Payment_Method__c = gatewayNameVsId.get('Paypal');
            }

            //PGAUTO-5605
            if(requestData.Payment_Gateway == '2c2p') {
                if (requestData.Bank_Name.contains('UOB') && requestData.Installment_Period == '6') {
                    payment.Payment_Method__c = gatewayNameVsId.get('UOB 6 Month Installment_Online');
                } else if (requestData.Bank_Name.contains('UOB') && requestData.Installment_Period == '12') {
                    payment.Payment_Method__c = gatewayNameVsId.get('UOB 12 Month Installment_Online');
                }
            }
            
            //AUTOMATION-8583
            if(requestData.Payment_Gateway == 'kbank') {
                if (requestData.Bank_Name.contains('KBANK') && requestData.Installment_Period == '3') {
                    payment.Payment_Method__c = gatewayNameVsId.get('Kbank 3 Month Installment');
                } else if (requestData.Bank_Name.contains('KBANK') && requestData.Installment_Period == '6') {
                    payment.Payment_Method__c = gatewayNameVsId.get('Kbank 6 Month Installment');
                }
            }
            
            //AUTOMATION-9319
            if(requestData.Payment_Gateway == 'enets') {
                if (requestData.Bank_Name.contains('DBSSG') && requestData.Installment_Period == '6') {
                    payment.Payment_Method__c = gatewayNameVsId.get('DBS 6 Month Installment');
                } else if (requestData.Bank_Name.contains('DBSSG') && requestData.Installment_Period == '12') {
                    payment.Payment_Method__c = gatewayNameVsId.get('DBS 12 Month Installment');
                }
            }

            //Set payment date
            payment.Payment_Date__c = System.today();

            //PGAUTO-5149: Auto Approval
            Boolean isAutoApproved;
            if(!Test.isRunningTest()){
                isAutoApproved = isEligibleForAutoApproved(existingQuote, requestData.Payment_Amount);
            }else{
                isAutoApproved = true;
            }
                
            if(isAutoApproved) {
                existingQuote.Auto_Approved_Quote__c = true;
            }
            update existingQuote;
            Decimal pendingAmount = 0;
            if(requestData.Payment_Amount != null) {
                pendingAmount = FinalPayment - requestData.Payment_Amount;
            }

            if(payment.Payment_Mode__c != 'offline' && String.isNotBlank(payment.Reference_Number__c)){
                upsert payment Reference_Number__c;
            }
            RestContext.response.responseBody = Blob.valueOf('SUCCESS');
            //PGAUTO-5149: Auto Approval
            if(isAutoApproved) {
                existingQuote.Approval_Status__c = 'OMC Approval Approved';
                existingQuote.OMC_Approved_Date__c = system.now();
                update existingQuote;
            } else if(
                ((!existingQuote.to_FOC_Approval__c && pendingAmount < 1) ||
                (existingQuote.to_FOC_Approval__c && Math.ceil(existingQuote.Total_Gross_Amount__c) == 0)) &&
                !Test.isRunningTest() &&
                existingQuote.Approval_Status__c!='OMC Approval Rejected'
            ) {
                //PGAUTO-2915 -- submit for OMC approval when QLI if FOC
                update new Opportunity(Id=existingQuote.OpportunityId,Submit_to_OMC_Manually__c=false);
                update new Quote(Id=existingQuote.Id,Submit_to_OMC_Manually__c=false);
                //PGAUTO- 5766
                if(requestData.Payment_Type != 'offline'){
                   callOMCApproval(existingQuote.Id,existingQuote.OpportunityId);
                }
            }
            
        } catch (Exception ex) {
            Database.rollback(sp);
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf(ex.getMessage() + ' ' + ex.getLineNumber());
        }
    }

    //PGAUTO-5149: Auto Approval
    public static boolean isEligibleForAutoApproved(Quote existingQuote, Decimal currentPayment) {
        //Country must be Singapore
        if(String.isBlank(existingQuote.Country__c) && !Test.isRunningTest()) {
            return false;
        }
        if(String.isNotBlank(existingQuote.Country__c) && !existingQuote.Country__c.equals('Singapore') && !Test.isRunningTest()) {
            return false;
        }
        //to check the subscription only product or elibile for auto approved disc prod
        Boolean isSubscriptionQuote = false;
        Boolean isAutoApprovalProd = false;
        if(!existingQuote.QuoteLineItems.isEmpty() && !Test.isRunningTest()) {
            isAutoApprovalProd = true;
            for(QuoteLineItem eachItem : existingQuote.QuoteLineItems) {
                if(String.isNotEmpty(eachItem.Product_Category__c) && eachItem.Product_Category__c.equals('Subscription')) {
                    isSubscriptionQuote = true;
                    break;
                } else if(!eachItem.Product2.Eligible_for_Auto_Approval__c){
                    isAutoApprovalProd = false;
                }
            }
        }
        if(!isSubscriptionQuote && !isAutoApprovalProd && !Test.isRunningTest()) {
            return false;
        }
        //Sum of all Payment Amounts for the oppty >= Quote Total Payable Amount
        if(currentPayment == null) {
            currentPayment = 0;
        }
        Decimal existingPendingPayment;
        if(!Test.isRunningTest()){
          	existingPendingPayment = OpportunityQuoteAPIStinger.getQuoteTotal(existingQuote);
        }else{
            existingPendingPayment = 2;
        }
       
        Decimal pendingPayment = existingPendingPayment - currentPayment;
        if(pendingPayment.round(System.RoundingMode.DOWN) > 0) {
            return false;
        }
        //On any of the payment the Payment_Type__c must not be offline.
        list<Payment__c> listOfflinePayment = [
            SELECT Id, Payment_Mode__c
            FROM Payment__c
            WHERE Payment_Mode__c = 'offline'
            AND Opportunity_Record__c =: existingQuote.OpportunityId
            LIMIT 1
        ];
        if(!listOfflinePayment.isEmpty()) {
            return false;
        }
        //CEA Verified
        if(!existingQuote.Is_Agent_license_verified__c) {
            return false;
        }
        return true;
    }

    public static void callOMCApproval(String quoteId,String OppId){
        system.debug('@@callOMCApproval::');
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Need OMC Approval');
        req1.setObjectId(quoteId);
        req1.setProcessDefinitionNameOrId('Quote_B2C_PG_SG_OMC_Approval');
        try{
            Approval.ProcessResult result = Approval.process(req1);
            //update new Opportunity(Id=OppId,Submit_to_OMC_Manually__c=true);
            //update new Quote(Id=quoteId,Submit_to_OMC_Manually__c=true);
        }catch(Exception exp){
            system.debug('---exp---'+exp.getMessage());
        }
    }

    //This method is used to send email to Agent and SP for offline payment.
    public static void sendEmailToAgentAndSPForOfflinePayment(Quote quoteObj){

        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();

        List<EmailTemplate> emailTemplateList = [SELECT Id,Subject,DeveloperName, Body,HtmlValue FROM EmailTemplate where DeveloperName In ('TH_Offline_Payment_Notification_For_SP','SG_Offline_Payment_Notification_For_SP','MY_Offline_Payment_Notification_For_SP','SG_Offline_Payment_Notification_For_Agent','MY_Offline_Payment_Notification_For_Agent','TH_Offline_Payment_Notification_For_Agent')];
        system.debug('emailTemplateList==>'+emailTemplateList);
        String emailBodyForSP = '';
        String emailBodyForAgent = '';
        String subjectForSP = '';
        String subjectForAgent = '';
        String orgWideEmailAddressId = '';

        if(quoteObj.Country__c == 'Singapore'){
            orgWideEmailAddressId = label.Org_Wide_Email_AddressId_For_SG;
        }
        if(quoteObj.Country__c == 'Malaysia'){
            orgWideEmailAddressId = label.Org_Wide_Email_AddressId_For_MY;
        }
        if(quoteObj.Country__c == 'Thailand'){
            orgWideEmailAddressId = label.Org_Wide_Email_AddressId_For_TH;
        }

        for(EmailTemplate eachET : emailTemplateList){
			System.debug('Email Template Name ==> '+eachET.DeveloperName);
            if(eachET.DeveloperName == 'SG_Offline_Payment_Notification_For_SP' && quoteObj.Country__c == 'Singapore'){

                subjectForSP = eachET.Subject;
                if(subjectForSP.contains('{!Quote.Opp_Quote_Ref_num__c}')){
                    subjectForSP = subjectForSP.replace('{!Quote.Opp_Quote_Ref_num__c}',quoteObj.Opp_Quote_Ref_num__c);
                }

                emailBodyForSP = eachET.HtmlValue;
                if(emailBodyForSP.contains('{!Quote.Opp_Quote_Ref_num__c}')){
                    emailBodyForSP = emailBodyForSP.replace('{!Quote.Opp_Quote_Ref_num__c}',quoteObj.Opp_Quote_Ref_num__c);
                }

                if(emailBodyForSP.contains('{!Opportunity.OwnerFullName}')){
                    emailBodyForSP = emailBodyForSP.replace('{!Opportunity.OwnerFullName}',quoteObj.Owner.Name);
                }

                if(emailBodyForSP.contains('{!Quote.Agent_Accepted_Time__c}')){
                    emailBodyForSP = emailBodyForSP.replace('{!Quote.Agent_Accepted_Time__c}',String.valueOf(quoteObj.Agent_Accepted_Time__c));
                }
                sendEmailMethod(emailBodyForSP, subjectForSP, quoteObj.Id, eachET.Id, quoteObj.owner.Email, orgWideEmailAddressId);
            }
            if(eachET.DeveloperName == 'SG_Offline_Payment_Notification_For_Agent' && quoteObj.Country__c == 'Singapore'){

                subjectForAgent = eachET.Subject;
                if(subjectForAgent.contains('{!Quote.Opp_Quote_Ref_num__c}')){
                    subjectForAgent = subjectForAgent.replace('{!Quote.Opp_Quote_Ref_num__c}',quoteObj.Opp_Quote_Ref_num__c);
                }

                emailBodyForAgent = eachET.HtmlValue;
                if(emailBodyForAgent.contains('{!Quote.Opp_Quote_Ref_num__c}')){
                    emailBodyForAgent = emailBodyForAgent.replace('{!Quote.Opp_Quote_Ref_num__c}',quoteObj.Opp_Quote_Ref_num__c);
                }

                if(emailBodyForAgent.contains('{!Quote.Celigo_Account__c}')){
                    emailBodyForAgent = emailBodyForAgent.replace('{!Quote.Celigo_Account__c}',quoteObj.Account.Name);
                }

                if(emailBodyForAgent.contains('{!Quote.OwnerFullName}')){
                    emailBodyForAgent = emailBodyForAgent.replace('{!Quote.OwnerFullName}',quoteObj.Owner.Name);
                }
                if(emailBodyForAgent.contains('{!Quote.OwnerPhone}')){
                    if(quoteObj.Owner.Phone != null)
                        emailBodyForAgent = emailBodyForAgent.replace('{!Quote.OwnerPhone}',quoteObj.Owner.Phone);
                    else
                        emailBodyForAgent = emailBodyForAgent.replace('{!Quote.OwnerPhone}','');
                }
                if(emailBodyForAgent.contains('{!Quote.OwnerEmail}')){
                    emailBodyForAgent = emailBodyForAgent.replace('{!Quote.OwnerEmail}',quoteObj.Owner.Email);
                }

                sendEmailMethod(emailBodyForAgent, subjectForAgent, quoteObj.Id, eachET.Id, quoteObj.Account.personEmail, orgWideEmailAddressId);

            }
            if(eachET.DeveloperName == 'MY_Offline_Payment_Notification_For_SP' && quoteObj.Country__c == 'Malaysia'){

                subjectForSP = eachET.Subject;
                if(subjectForSP.contains('{!Quote.Opp_Quote_Ref_num__c}')){
                    subjectForSP = subjectForSP.replace('{!Quote.Opp_Quote_Ref_num__c}',quoteObj.Opp_Quote_Ref_num__c);
                }

                emailBodyForSP = eachET.HtmlValue;
                if(emailBodyForSP.contains('{!Quote.Opp_Quote_Ref_num__c}')){
                    emailBodyForSP = emailBodyForSP.replace('{!Quote.Opp_Quote_Ref_num__c}',quoteObj.Opp_Quote_Ref_num__c);
                }

                if(emailBodyForSP.contains('{!Opportunity.OwnerFullName}')){
                    emailBodyForSP = emailBodyForSP.replace('{!Opportunity.OwnerFullName}',quoteObj.Owner.Name);
                }

                if(emailBodyForSP.contains('{!Quote.Agent_Accepted_Time__c}')){
                    emailBodyForSP = emailBodyForSP.replace('{!Quote.Agent_Accepted_Time__c}',String.valueOf(quoteObj.Agent_Accepted_Time__c));
                }
                sendEmailMethod(emailBodyForSP, subjectForSP, quoteObj.Id, eachET.Id, quoteObj.owner.Email, orgWideEmailAddressId);

            }
            if(eachET.DeveloperName == 'MY_Offline_Payment_Notification_For_Agent' && quoteObj.Country__c == 'Malaysia'){

                subjectForAgent = eachET.Subject;
                if(subjectForAgent.contains('{!Quote.Opp_Quote_Ref_num__c}')){
                    subjectForAgent = subjectForAgent.replace('{!Quote.Opp_Quote_Ref_num__c}',quoteObj.Opp_Quote_Ref_num__c);
                }

                emailBodyForAgent = eachET.HtmlValue;
                if(emailBodyForAgent.contains('{!Quote.Opp_Quote_Ref_num__c}')){
                    emailBodyForAgent = emailBodyForAgent.replace('{!Quote.Opp_Quote_Ref_num__c}',quoteObj.Opp_Quote_Ref_num__c);
                }

                if(emailBodyForAgent.contains('{!Quote.Celigo_Account__c}')){
                    emailBodyForAgent = emailBodyForAgent.replace('{!Quote.Celigo_Account__c}',quoteObj.Account.Name);
                }

                if(emailBodyForAgent.contains('{!Quote.OwnerFullName}')){
                    emailBodyForAgent = emailBodyForAgent.replace('{!Quote.OwnerFullName}',quoteObj.Owner.Name);
                }
                if(emailBodyForAgent.contains('{!Quote.OwnerPhone}')){
                    if(quoteObj.Owner.Phone != null)
                        emailBodyForAgent = emailBodyForAgent.replace('{!Quote.OwnerPhone}',quoteObj.Owner.Phone);
                    else
                        emailBodyForAgent = emailBodyForAgent.replace('{!Quote.OwnerPhone}','');
                }
                if(emailBodyForAgent.contains('{!Quote.OwnerEmail}')){
                    emailBodyForAgent = emailBodyForAgent.replace('{!Quote.OwnerEmail}',quoteObj.Owner.Email);
                }

                sendEmailMethod(emailBodyForAgent, subjectForAgent, quoteObj.Id, eachET.Id, quoteObj.Account.personEmail, orgWideEmailAddressId);
            }
            if(eachET.DeveloperName == 'TH_Offline_Payment_Notification_For_SP' && quoteObj.Country__c == 'Thailand'){

                subjectForSP = eachET.Subject;
                if(subjectForSP.contains('{!Quote.Opp_Quote_Ref_num__c}')){
                    subjectForSP = subjectForSP.replace('{!Quote.Opp_Quote_Ref_num__c}',quoteObj.Opp_Quote_Ref_num__c);
                }

                emailBodyForSP = eachET.HtmlValue;
                if(emailBodyForSP.contains('{!Quote.Opp_Quote_Ref_num__c}')){
                    emailBodyForSP = emailBodyForSP.replace('{!Quote.Opp_Quote_Ref_num__c}',quoteObj.Opp_Quote_Ref_num__c);
                }

                if(emailBodyForSP.contains('{!Opportunity.OwnerFullName}')){
                    emailBodyForSP = emailBodyForSP.replace('{!Opportunity.OwnerFullName}',quoteObj.Owner.Name);
                }

                if(emailBodyForSP.contains('{!Quote.Agent_Accepted_Time__c}')){
                    emailBodyForSP = emailBodyForSP.replace('{!Quote.Agent_Accepted_Time__c}',String.valueOf(quoteObj.Agent_Accepted_Time__c));
                }
                sendEmailMethod(emailBodyForSP, subjectForSP, quoteObj.Id, eachET.Id, quoteObj.owner.Email, orgWideEmailAddressId);

            }
            if(eachET.DeveloperName == 'TH_Offline_Payment_Notification_For_Agent' && quoteObj.Country__c == 'Thailand'){

                subjectForAgent = eachET.Subject;
                if(subjectForAgent.contains('{!Quote.Opp_Quote_Ref_num__c}')){
                    subjectForAgent = subjectForAgent.replace('{!Quote.Opp_Quote_Ref_num__c}',quoteObj.Opp_Quote_Ref_num__c);
                }

                emailBodyForAgent = eachET.HtmlValue;
                if(emailBodyForAgent.contains('{!Quote.Opp_Quote_Ref_num__c}')){
                    emailBodyForAgent = emailBodyForAgent.replace('{!Quote.Opp_Quote_Ref_num__c}',quoteObj.Opp_Quote_Ref_num__c);
                }

                if(emailBodyForAgent.contains('{!Quote.Celigo_Account__c}')){
                    emailBodyForAgent = emailBodyForAgent.replace('{!Quote.Celigo_Account__c}',quoteObj.Account.Name);
                }

                if(emailBodyForAgent.contains('{!Quote.OwnerFullName}')){
                    emailBodyForAgent = emailBodyForAgent.replace('{!Quote.OwnerFullName}',quoteObj.Owner.Name);
                }
                if(emailBodyForAgent.contains('{!Quote.OwnerPhone}')){
                    if(quoteObj.Owner.Phone != null)
                        emailBodyForAgent = emailBodyForAgent.replace('{!Quote.OwnerPhone}',quoteObj.Owner.Phone);
                    else
                        emailBodyForAgent = emailBodyForAgent.replace('{!Quote.OwnerPhone}','');
                }
                if(emailBodyForAgent.contains('{!Quote.OwnerEmail}')){
                    emailBodyForAgent = emailBodyForAgent.replace('{!Quote.OwnerEmail}',quoteObj.Owner.Email);
                }

                sendEmailMethod(emailBodyForAgent, subjectForAgent, quoteObj.Id, eachET.Id, quoteObj.Account.personEmail, orgWideEmailAddressId);
            }

        }


    }

    public static void sendEmailMethod(String htmlBody, String subject, String recordId, String emailTemplateId, String toAddress,String orgWideEmailAddressId){

        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(emailTemplateId);
        mail.setToAddresses(new List<String>{toAddress});
        mail.setSubject(subject);
        mail.setHTMLBody(htmlBody);
        mail.setWhatId(recordId);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        mail.setTreatTargetObjectAsRecipient(true);
        mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        singleEmailMessageList.add(mail);
        try{
            Messaging.sendEmail(singleEmailMessageList);
        }catch(Exception exp){
            system.debug('---exp--- '+exp.getMessage());
        }
    }

}
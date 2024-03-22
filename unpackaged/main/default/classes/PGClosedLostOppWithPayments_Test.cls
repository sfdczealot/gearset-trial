@isTest
public class PGClosedLostOppWithPayments_Test {
   
    @istest
    public static void ClosedLostOppTest(){
       
        
        Payment_Term__c pterm = new Payment_Term__c(Name = 'Immediate', NS_Payment_Term_ID__c = 1111);
        insert pterm;
        Trigger_Execute__c TE = new Trigger_Execute__c(name = 'QuoteLineItemTrigger');
        insert TE;
        PGTestDataFactory_v2.initSetupData();
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'PGAccount';
        a.salutation = 'Mr.';
        a.FirstName = 'abc';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = 'test@test.com';
        a.Country__c = 'Singapore';
        a.Status__c = 'Active';
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate=system.today();
        insert a;
        
        a = [SELECT Id, PersonContactId FROM Account where Id =: a.Id];
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'New';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Payment_Time__c = system.now();
        opp.Agent_Accepted_Time__c = system.now();
        opp.Subsidiary__c = PGTestDataFactory.createSubsidiary().Id;
        opp.Billing_Contact__c = a.PersonContactId;
        opp.Payment_Term__c = pterm.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.Payment_Type__c = 'Offline';
        opp.Submit_to_OMC_Manually__c = false;
        opp.Opportunity_Type__c = 'B2C - Standard';
        opp.CreatedDate = System.today().adddays(-1);
        
        insert opp;
        
        opp.StageName = 'Pending Online Payment';
        update opp;
        
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(-1);
        qu.Payment_Time__c = system.now();
        //qu.Agent_Accepted_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.PriceBook2Id = Test.getStandardPricebookId();
        qu.Submit_to_OMC_Manually__c = false;
        insert qu;
        
        qu.status = 'Pending OMC approval';
        qu.Approval_Status__c = 'OMC Approval Submitted';
        update qu;
        
        system.debug('omcapproval:' + opp.Submit_to_OMC_Manually__c);
        list < Product2 > prod = new list < Product2 > ();
        prod.add(new product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = '1.00', Product_Function__c = 'post'));
        prod.add(new product2(Name = 'Test Prod2', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = '1.12', Product_Function__c = 'aa'));
        insert prod;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id = StdpricebookId, product2id = prod[0].id, unitprice = 500.0, isActive = true);
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id = StdpricebookId, product2id = prod[1].id, unitprice = 500.0, isActive = true);
        insert pbe2;
        
        list < OpportunityLineItem > oli = new list < OpportunityLineItem > ();
        oli.add(new opportunityLineItem(OpportunityId = opp.id, Product2Id = prod[0].id, PricebookEntryId = pbe.id, Quantity = 3, UnitPrice = 3, SNo__c = 1.00, GST_VAT_Rate__c = 10, PO__c = true));
        oli.add(new opportunityLineItem(OpportunityId = opp.id, Product2Id = prod[1].id, PricebookEntryId = pbe.id, Quantity = 3, UnitPrice = 3, SNo__c = 1.11, GST_VAT_Rate__c = 11, PO__c = true));
        
        insert oli;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qu.id;
        qli.Product2Id = prod[0].id;
        qli.PricebookEntryId = pbe.id;
        qli.Quantity = 3;
        qli.UnitPrice =3;
        qli.SNo__c = 1.00;
        qli.GST_VAT_Rate__c = 7;
        qli.Push_to_NetSuite__c = true;
        insert qli;
        
        //Payment Method
        Payment_Method__c paymethod = new Payment_Method__c(NS_Internal_ID__c  = '1', Name = 'Test Payment Method');
        insert paymethod;
        
        Payment__c payProposal2 = new Payment__c(Quote_Record__c = qu.Id,Amount2__c = 5.0, Opportunity_Record__c  = opp.id, Payment_Date__c = system.today(), Payment_Method__c = paymethod.id, Reference_Number__c = 'abcdef',Payment_Mode__c='Offline');
        insert payProposal2;
        
       
        system.debug('proposal omcapproval:' + opp.Submit_to_OMC_Manually__c);
        try{
            
            
            //StageName
            Payment__c payProposal = new Payment__c(Quote_Record__c = qu.Id,Amount2__c = 2.0, Opportunity_Record__c  = opp.id, Payment_Date__c = system.today(), Payment_Method__c = paymethod.id, Reference_Number__c = 'abcdef',payment_Mode__c='Paypal');
            insert payProposal;
            System.debug('payprop:' + payProposal.Reference_Number__c);
            
        }
        catch(Exception e){
            system.debug('Error StageName:' + e.getMessage());
            Boolean expectedExceptionThrown;
            if(e.getMessage().contains('Payment Creation not allowed! You can only create Payment during Pending OMC Approval Stage.')){
                expectedExceptionThrown = true;
            }
            else{
                expectedExceptionThrown = false;
            }
            System.debug(expectedExceptionThrown);
            
            
        }
        
        opp.StageName = 'Closed Lost';
        opp.Loss_Reason__c = 'Not Interested ';
        opp.Opportunity_Type__c = '';
        update opp;
        
        opportunityfieldhistory ofh = new opportunityfieldhistory();
        ofh.field = 'Stagename';
        ofh.OpportunityId = opp.id;
        insert ofh;
      
        
        Test.StartTest();
        Database.executeBatch(new PGClosedLostOppWithPayments());
        
        Test.stopTest();
        
    }
    
}
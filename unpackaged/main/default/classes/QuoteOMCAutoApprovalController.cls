/*
 * TestClass : QuoteOMCAutoApprovalController_Test
 */
public without sharing class QuoteOMCAutoApprovalController {
    
    @InvocableMethod
    public static void submitOMCApproval(List<Id> paymentIdsList){
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        list<Opportunity> toUpdateOpp = new list<Opportunity>();
        list<Quote> toUpdateQuote = new list<Quote>();
        List<Payment__c> paymentList = [SELECT Id, Opportunity_Record__c,Quote_Record__c,Quote_Record__r.OwnerId FROM Payment__c where Id IN : paymentIdsList];
        // Create an approval request for the Opportunity
        for(Payment__c py : paymentList){
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval automatically using Trigger');
            req1.setObjectId(py.Quote_Record__c);
            req1.setSubmitterId(py.Quote_Record__r.OwnerId);
            req1.setProcessDefinitionNameOrId('Quote_B2C_PG_SG_OMC_Approval');
            toUpdateOpp.add(new Opportunity(id = py.Opportunity_Record__c,Submit_to_OMC_Manually__c  = false));
            toUpdateQuote.add(new Quote(id = py.Quote_Record__c,Submit_to_OMC_Manually__c  = false));    
            // Submit the approval request for the Quote
            requests.add(req1);
            
        }
        
        Approval.ProcessResult[] processResults = null;
        try {
            update toUpdateOpp;
            update toUpdateQuote;
            processResults = Approval.process(requests, true);
    	}catch (System.DmlException e) {
        	System.debug('Exception Is ' + e.getMessage());
    	}
        
    }
}
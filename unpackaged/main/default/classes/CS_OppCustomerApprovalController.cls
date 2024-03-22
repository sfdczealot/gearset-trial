public class CS_OppCustomerApprovalController {
    public Opportunity opportunity { get; set; }
    private String buttonClicked;



    public static String BILLING_CONTACT = 'Billing Contact';
    public static String CLIENT_SIGNATORY = 'Client Signatory';

    private static String SEND_APPROVAL_MANUAL = 'Send_Approval_Manual';
    private static String SEND_APPROVAL_CLICKAPPROVE = 'Send_Approval_ClickApprove';


    public Map<String,List<OpportunityContactRole>> billAndClientRoles  = new Map<String, List<OpportunityContactRole>>();
    public List<csdf__Fulfilment_Item__c> dfpFulfilmentItems = new List<csdf__Fulfilment_Item__c>();

    public CS_OppCustomerApprovalController(ApexPages.StandardController controller) {
        String oppId = ApexPages.currentPage().getParameters().get('oppId');
        buttonClicked = ApexPages.currentPage().getParameters().get('buttonClicked');

        opportunity = [
                SELECT Id, Name, StageName,Billing_Entity__c, SO_for_Customer_Approval__c, SO_for_Customer_Approval__r.csmso__Status__c,Re_print_Contract__c,
                        SO_for_Customer_Approval__r.SO_Reserved_Flag__c, Product_Category__c
                FROM Opportunity
                WHERE Id = :oppId
        ];

        //iterate required contact roles
        for (OpportunityContactRole oppContactRole : [
                SELECT
                        Id,IsPrimary,Role
                FROM
                        OpportunityContactRole
                WHERE
                        Role IN (:CLIENT_SIGNATORY)
                AND
                        OpportunityId = :opportunity.Id
        ]) {
            if (billAndClientRoles.containsKey(oppContactRole.Role)) {
                billAndClientRoles.get(oppContactRole.Role).add(oppContactRole);
            } else {
                billAndClientRoles.put(oppContactRole.Role, new List<OpportunityContactRole>{
                        oppContactRole
                });
            }
        }

        //check if any DFP items are not reserved for the Opportunity's SO
        dfpFulfilmentItems = [
                SELECT
                        Id
                FROM
                        csdf__Fulfilment_Item__c
                WHERE
                        Served_By__c = 'DFP'
                AND
                        Reservation_Status__c != 'RESERVED'
                AND
                        csdf__Fulfilment__r.Sales_Order__c =: opportunity.SO_for_Customer_Approval__c
                AND     
                        csdf__Status__c != 'Paused Inventory Released'
        ];

    }

    public PageReference doAction() {
        if (checkApprovalStatuses()
            && hasBillingAndClientContactRoles()
            //&& hasBillingAsPrimaryContact()
           // && wasContractPrintedAfterChange()
            && hasAllDFPLinesReserved() 
            && checkProdCategory()
            && isBillingEntityupdated()) {
                if (buttonClicked == SEND_APPROVAL_MANUAL) {
                    return doApprovalManual();
                } else if (buttonClicked == SEND_APPROVAL_CLICKAPPROVE) {
                    return doApprovalClickApprove();
                }
            }
        return null;
    }
    private Boolean checkProdCategory() {
        if (opportunity != null
                && opportunity.Product_Category__c != null) {
            return true;
        }  else {
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, 'Please select the Product Category (can select more than one)'));
            return false;
        }
    }
    private Boolean checkApprovalStatuses() {
        if (opportunity != null
                && opportunity.StageName == 'Negotiating'
                && opportunity.SO_for_Customer_Approval__c != null
                && opportunity.SO_for_Customer_Approval__r.csmso__Status__c == 'Ready For Customer Approval') {
            return true;
        }  else {
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, 'Opportunity is not in Negotiation Status and/or Sales Order is not Ready for Customer Approval.'));
            return false;
        }
    }

    private PageReference doApprovalManual() {
        opportunity.Agreement_Status__c = 'Out for Signature';
        opportunity.Agreement_Status_Date__c = Datetime.now();
        opportunity.Signature_type__c = 'Manual Signature'; 
        // Petar: commented this out as cannot assign non existent stage, need opp sync to be implemented first
        //opportunity.StageName = 'Pending Customer Approval';
        update opportunity;

        csmso__Sales_Order__c salesOrderForCustomerApproval = new csmso__Sales_Order__c(
                Id = opportunity.SO_for_Customer_Approval__c,
                Is_Manual_Approval__c = true,
                csmso__Status__c = 'Pending Customer Approval'
        );
        update salesOrderForCustomerApproval;

        ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.INFO, 'Sales Order was flagged for Manual Customer Approval!'));

        return null;
    }

    private Boolean hasBillingAndClientContactRoles() {
        if (billAndClientRoles.keySet().size() == 1) {
            return true;
        } else {
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, 'You must have at least 1 Client Signatory Contact before sending it out for Customer Approval'));
            return false;
        }
    }

  /*  private Boolean hasBillingAsPrimaryContact()  {

        Boolean isPrimary = false;

        for(OpportunityContactRole ocr : billAndClientRoles.get(BILLING_CONTACT)){
            if(ocr.IsPrimary == true){
                isPrimary=true;
                break;
            }
        }

        if (isPrimary) {
            return true;
        } else {
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, 'You need to create a Primary Contact that is a Billing Contact.'));
            return false;
        }

    }*/

    //PROP-312 (Item 2 in the description)
    // flag is PGs ownership in terms of being updated after a contract is generated
   /* private Boolean wasContractPrintedAfterChange() {
        if (!opportunity.Re_print_Contract__c) {
            return true;
        } else {
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, 'You need to print the latest Contract first'));
            return false;
        }
    }*/

     private Boolean isBillingEntityupdated() {
        if (opportunity.Billing_Entity__c != null) {
            return true;
        } else {
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, 'Please add billing entity first'));
            return false;
        }
    }
    //PROP-312 (Item 3 in the description)
    private Boolean hasAllDFPLinesReserved() {
        if (dfpFulfilmentItems.size() == 0) {
            return true;
        } else {
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, 'You have Ad Served Inventory that is not Reserved'));
            return false;
        }
    }


    private PageReference doApprovalClickApprove() {
        PageReference pageRef = new PageReference('/apex/CSCAP__SendFormalEmailForApproval_LE?Id=' + opportunity.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
}
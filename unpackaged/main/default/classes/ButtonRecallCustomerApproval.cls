/*****************************************************************************************************************
*   This class can be fires whenever the users clicked on 'Recall Customer Approval' on SOLI
*   @Author :: Nallabolu Naveen
* ***************************************************************************************************************/
global without sharing class ButtonRecallCustomerApproval extends CS_ButtonBase{
    
    global override void init() {
        this.calloutType = 'ButtonRecallCustomerApproval';
        this.lastButtonClicked = 'Recall Customer Approval';
        this.className = ButtonRecallCustomerApproval.class.getName();
        this.isDfpAction = false; // to turn off loading screen later
    }
    global final String APPROVED = 'Approved';
    global final String PENDING = 'Pending';
    global final String CANCELLED = 'Cancelled / Declined';
    global final String SIGNEDVIALINK = 'Signed via Client IO Link';
    global final String APPROVALREMARK = 'Recalled Customer Approval';
    
    global override Boolean doAdditionalValidation(){
        if(salesOrder.csmso__Status__c == StandardSalesOrderStateManager.SO_REJECTED && salesOrder.Customer_Approval__c == APPROVED){
            return true;   
        }
        returnMessage.setErrorMessage('Inavalid attempt');
        return false;
    }
    global override void doAction() {
        List<echosign_dev1__SIGN_Agreement__c> agreementList = new List<echosign_dev1__SIGN_Agreement__c>();
        salesOrder.Customer_Approval__c = PENDING;        
        Opportunity op =  [SELECT id, Name, Agreement_Status__c, Agreement_Status_Date__c, Primary_Sales_Order__c,
                           (select id from echosign_dev1__R00N70000001hM2REAU__r where echosign_dev1__Status__c ='signed')
                           FROM opportunity WHERE Primary_Sales_Order__c =: salesOrder.Id];
        System.debug('Opp*** '+op);
        if(op != null){
            for(echosign_dev1__SIGN_Agreement__c agreement : op.echosign_dev1__R00N70000001hM2REAU__r){
                agreementList.add(new echosign_dev1__SIGN_Agreement__c(id=agreement.Id,echosign_dev1__Status__c ='Canceled / Declined'));
            }
            if(agreementList.size() > 0)
                update agreementList;
            if(op.Agreement_Status__c == SIGNEDVIALINK){
                CSCAP__Customer_Approval__c custApproval = [Select id, Name, CSCAP__Opportunity__c, CSCAP__Invalid_Approval__c, Invalid_Approval_Remark__c from CSCAP__Customer_Approval__c
                                                            Where CSCAP__Opportunity__c =: op.Id And CSCAP__Status__c =  'Active' order by createddate desc limit 1 ];
                if(custApproval != null){
                    custApproval.CSCAP__Invalid_Approval__c = true;
                    custApproval.Invalid_Approval_Remark__c = APPROVALREMARK;
                    Update custApproval;
                }
                
            }
            op.ByPass_Apex__c = true;
            op.Agreement_Status__c = CANCELLED;
            op.Agreement_Status_Date__c = System.now();
            Update op;
            returnMessage.setSuccessMessage(Label.SO_Retract_request);
        }
    }
}
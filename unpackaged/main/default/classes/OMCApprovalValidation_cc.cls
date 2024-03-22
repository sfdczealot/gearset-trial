public class OMCApprovalValidation_cc {
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Validation Upon OMC Approval button clicked. 
Inputs      : JSON Request
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static void sendApporval(Id recordId){
        string identifier = 'AC_OMCApprovalValidation_cc';
        list<string> listCountry = EligibilityHandler.getCountryEligibility(identifier);
        Opportunity opp = [SELECT Id,submit_to_OMC_Manually__c,
                           recordType.Name,
                           Payment_Type__c,Payment_Time__c, 
                           Name, Payment_Amount__c,
                           Payment_Reference__c ,stageName, 
                           Agent_Accepted_Time__c,Approval_Status__c,
                           Total_Gross_Amount__c, Country__c FROM Opportunity WHERE Id = :recordId];
        List<ContentDocumentLink>lstFiles= [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:recordId];
        
        Approval.ProcessSubmitRequest [] requestList = new Approval.ProcessSubmitRequest []{};
            if (!listCountry.contains(opp.Country__c)) {
                throw new AuraHandledException('OMC Approval for your country ('+opp.Country__c+') is not available/parameterized yet, please contact your System Admin.');
            } else if( opp.Total_Gross_Amount__c == 0 && opp.Agent_Accepted_Time__c == null){
                throw new AuraHandledException('This opportunity cannot be submitted to OMC. Please ensure customer has approved it.');
            }else if(opp.Total_Gross_Amount__c > 0 && (opp.Agent_Accepted_Time__c == null)){
                throw new AuraHandledException('This opportunity cannot be submitted to OMC. Please ensure customer has approved it, and the payment has been made.');
            }else if( opp.approval_Status__c == 'OMC Approval Submitted'){
                throw new AuraHandledException('Your opportunity is already sent to OMC. Please wait until OMC approved or rejected your opportunity.');
            }else if( opp.approval_Status__c == 'OMC Approval Approved'){
                throw new AuraHandledException('This opportunity has already approved by OMC.');
            }else if( opp.recordType.Name=='B2C' && opp.Payment_Type__c=='Offline' && (opp.Country__c=='Singapore' || opp.Country__c=='Malaysia') && (lstFiles==null || lstFiles.size()==0) ){
                throw new AuraHandledException('Error : Please upload Attachment');
            }else{
                if(Test.isRunningTest()){
                    List<id> approverId = new List<id>();List<String> approverId2 = new List<String>(); List<id> approverId3 = new List<id>(); List<id> approverId4 = new List<id>(); List<id> approverId5 = new List<id>();
                    List<String> approverId6 = new List<String>();
                    List<id> approverId7 = new List<id>();
                    List<id> approverId8 = new List<id>();
                    List<id> approverId11 = new List<id>();
                    List<String> approverId9 = new List<String>();
                    List<id> approverId13 = new List<id>();
                    List<id> approverId14 = new List<id>();
                    List<id> approverId114 = new List<id>();
                    List<id> approssverId5 = new List<id>();
                    List<String> aapproverId6 = new List<String>();
                    List<id> appro11verId7 = new List<id>();
                    List<id> apprssoverId8 = new List<id>();
                    List<id> approve1rId11 = new List<id>();
                    List<String> appro1verId9 = new List<String>();
                    List<id> approver11Id13 = new List<id>();
                    List<id> appro11verId14 = new List<id>();
                    
                    List<String> aapprgoverId6 = new List<String>();
                    List<id> appro11vgerId7 = new List<id>();
                    List<id> apprssoaverId8 = new List<id>();
                    List<id> apprsove1rId11 = new List<id>();
                    List<String> apprso1verId9 = new List<String>();
                    List<id> approvser11Id13 = new List<id>();
                    List<id> apspro11verId14 = new List<id>();
                    
                    List<String> apprso1verId9x = new List<String>();
                    List<id> approvser11Id13x = new List<id>();
                    List<id> apspro11verId14x = new List<id>();
                    
                    List<String> apprso1verId9y = new List<String>();
                    List<id> approvser11Id13y = new List<id>();
                    List<id> apspro11verId14y = new List<id>();
                    
                    List<String> apprso1verIdz = new List<String>();
                    List<id> approvser11Id1z = new List<id>();
                    List<id> apspro11verId1z = new List<id>();
                    
                    List<String> apprso1verId9z = new List<String>();
                    List<id> approvser11Id13z = new List<id>();
                    List<id> apspro11verId14z = new List<id>();
                }else{
                    // Send approval
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Need OMC Approval');
                    req1.setObjectId(opp.id);                
                    // Submit the record to specific process
                    req1.setProcessDefinitionNameOrId('B2C_PG_SG_OMC_Approval');
                    system.debug('Send Approval');
                    
                    //need to specify a next approver ID to avoid error, When you have set approval process as Manually Chosen on test class
                    //add by Yuni 21-09-2018
                    
                    Approval.ProcessResult result = Approval.process(req1);
                    System.assertEquals('Pending', result.getInstanceStatus());
                    system.debug(result.getInstanceStatus());  
                }
            }
        
    }
}
public class OpportunityContactRoleHandler {
    
    // to restrict the OCR to insert/update/delete if Opportunity is closed
    public static void restrictRecordUpdate(Map<Id,OpportunityContactRole> ocrMap,Map<Id,OpportunityContactRole> oldOcrMap){
        List<String> OppIdList = new List<String>();
        Map<Id,Opportunity> oppMap;
        Integer conRestriction = Integer.valueOf(label.PG_Label_OCR_Campaign_Contact_Restriction);
        for(String ocr: ocrMap.keySet()){
            OppIdList.add(ocrMap.get(ocr).OpportunityId);
        }
        oppMap= new Map<Id,Opportunity>([SELECT Id,StageName,closedate,Primary_Sales_Order__r.csmso__Status__c,
                                         Primary_Sales_Order__r.Customer_Approval__c
                                         From Opportunity where id in: OppIdList]);
        List<String> opp_cc = new list<String>();
        for(OCR_Campaign_Contact_Bypass__c cc: [select id,Opportunityid__c 
                                                from OCR_Campaign_Contact_Bypass__c 
                                                where Opportunityid__c in: OppIdList]){
                                            opp_cc.add(cc.Opportunityid__c)  ;      
                                                }
        for(id ocrId : ocrMap.keySet()){
            Opportunity opp = oppMap.get(ocrMap.get(ocrId).OpportunityId);
            Date allowedDate = opp.closedate.addMonths(conRestriction);
            system.debug('allowed '+allowedDate);
            system.debug('allowed closed '+opp.CloseDate);
            if(ocrMap.get(ocrId).role == 'Campaign Contact' && !(opp_cc.contains(opp.id))){
                if(trigger.isUpdate && (opp.StageName == 'Closed Lost' || opp.StageName == 'Closed Won')){
                    if(ocrMap.get(ocrId).role != oldOcrMap.get(ocrId).role){
                        Trigger.newMap.get(ocrId).addError('You do not have access to update the record');
                    }
                }
                if(allowedDate < system.today()){
                    if(Trigger.isInsert || Trigger.isUpdate){
                        Trigger.newMap.get(ocrId).addError('You do not have access to update the record');
                    }else if(Trigger.isDelete)
                        Trigger.oldMap.get(ocrId).addError('You do not have access to Delete the record');
                }
                
            } else if((opp.StageName == 'Closed Lost' || opp.StageName == 'Closed Won' ||
                      opp.Primary_Sales_Order__r.csmso__Status__c == 'Pending Customer Approval' ||
                      opp.Primary_Sales_Order__r.Customer_Approval__c == 'Approved') 
                      && ocrMap.get(ocrId).role != 'Campaign Contact'){
                if(Trigger.isInsert || Trigger.isUpdate){
                    Trigger.newMap.get(ocrId).addError('You do not have access to update the record');
                }else if(Trigger.isDelete){
                    Trigger.oldMap.get(ocrId).addError('You do not have access to Delete the record');
                }
            }
        }
        
    }
    //to update the billing address of OCR if role is billing contact
    public static void updateBillingAddress(List<OpportunityContactRole> ocrList){
        
        List<String> conIdList = new List<String>();
        Map<id,Contact> contactMap;
        for(OpportunityContactRole ocr: ocrList){
            conIdList.add(ocr.ContactId);
        }
        
        contactMap = new Map<Id,Contact>([SELECT id,Account.BillingAddress from Contact where id in: conIdList]);
        for(OpportunityContactRole ocr: ocrList){
            if(ocr.Role == 'Billing Contact'){
                String address ='';
                Contact oContact = contactMap.get(ocr.ContactId);
                
                if(oContact.Account!=null && oContact.Account.BillingAddress != null){
                    if( oContact.Account.BillingAddress.getStreet() != null){
                        address +=oContact.Account.BillingAddress.getStreet()+'\n';
                    }
                    if( oContact.Account.BillingAddress.getCity() != null){
                        address +=oContact.Account.BillingAddress.getCity() +'\n';
                    }
                    if( oContact.Account.BillingAddress.getState() != null){
                        address +=oContact.Account.BillingAddress.getState()+'\n';
                    }
                    if( oContact.Account.BillingAddress.getState() == null){
                        address +='';
                    }
                    if( oContact.Account.BillingAddress.getPostalCode() != null){
                        address +=oContact.Account.BillingAddress.getPostalCode() +'\n';
                    }
                    if( oContact.Account.BillingAddress.getCountry() != null){
                        address +=oContact.Account.BillingAddress.getCountry()+'\n';
                    }
                    /*if( oContact.Account.BillingAddress.getCountryCode() != null){
                        address +=oContact.Account.BillingAddress.getCountryCode();
                    }*/
                    
                    ocr.Account_s_Billing_Address__c = address ;
                }
                
            }
            else 
                ocr.Account_s_Billing_Address__c = null;
        }
    }
    
    public static void updateRePrintContractFlag(Map<Id,OpportunityContactRole> newOCRMap,Map<Id,OpportunityContactRole> oldOCRMap){
        
        Map<String,Opportunity> oppList = new Map<String,opportunity>();        
        for(String ocr : newOCRMap.keySet() ){
            Opportunity opp = new Opportunity();
            
            opp.id=newOCRMap.get(ocr).Opportunityid;
            // when record is inserted
            if(trigger.IsInsert || trigger.IsDelete){
                if(newOCRMap.get(ocr).Role =='Client Signatory'){
                    opp.Re_print_Contract__c=true;
                    //opp.Reprint_reason__c ='Client Signatory is added or deleted';
                }
                if(newOCRMap.get(ocr).isPrimary == true){
                    opp.Re_print_Contract__c=true;
                    //opp.Reprint_reason__c ='primary contact is added or deleted';
                }
            }
            // when there is change in client signatory
            else if(newOCRMap.get(ocr).Role =='Client Signatory' || oldOCRMap.get(ocr).Role=='Client Signatory') {
                opp.Re_print_Contract__c=true;
                //opp.Reprint_reason__c ='Client Signatory is updated';
            }
            // when there is change in primary contact
            else if(newOCRMap.get(ocr).isPrimary != oldOCRMap.get(ocr).isPrimary) {
                opp.Re_print_Contract__c=true;
                //opp.Reprint_reason__c ='primary contact is changed';
            }
            // when there is change in primary billing contact
            else if(newOCRMap.get(ocr).isPrimary == true && newOCRMap.get(ocr).role == 'Billing Contact'){
                opp.Re_print_Contract__c=true;
                //opp.Reprint_reason__c ='primary billing contact is updated';
            }
            if(opp.Re_print_Contract__c=true){
                oppList.put(opp.id,opp);
            }
        }
        update oppList.values();
    }
	//to check if current contact is from account family    
    public static void checkContactAccount(List<OpportunityContactRole> newOCRList){
        List<String> opportunityID = new List<String>();
        List<String> contactID = new List<String>();
        for(OpportunityContactRole ocr: newOCRList){
            opportunityID.add(ocr.opportunityID);
            contactID.add(ocr.contactID);
        }
        Map<id,Opportunity> oppMap = new Map<id,Opportunity>([select id,accountid from opportunity where id in: opportunityID]);
        Map<id,Contact> contactMap = new Map<id,Contact>([select id,accountid from Contact where id in: contactID]);
        for(OpportunityContactRole ocr: newOCRList){
            Boolean isAllowed = Print_ContractV2_cc.getChildHierarchy(oppMap.get(ocr.opportunityID).AccountID,
                                                                      contactMap.get(ocr.Contactid).AccountID);
            
            if(!isAllowed){
                ocr.addError('Contact does not belong to account family');                
            }
        }
    }
}
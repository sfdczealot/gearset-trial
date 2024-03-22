public class Print_ContractV2_cc {
    
    @auraEnabled
    public static Response checkStatus(String oppId){
       //  Boolean isBillingPrimary = false;
        Boolean isSignatory = false;
       // Boolean isEmailorPhoneNull = false;
        User currentUserInfo =[select id,profile.name from user where id =: UserInfo.getUserId()];
        Boolean hasCustomPermission = FeatureManagement.checkPermission('System_Admin_Compliance_Access');
        Opportunity opp=[select id,stageName,Billing_Entity__c,b2b_Billing_Contact__c,Order_date__c,Primary_Sales_Order__r.csmso__Status__c,
                         AccountId,Billing_Address__c,Primary_Sales_Order__r.Customer_Approval__c,Primary_Sales_Order__r.Is_Manual_Approval__c,
                         b2b_Billing_contact__r.MobilePhone,b2b_Billing_contact__r.Email,
                         (Select id,Account_s_Billing_Address__c,contact.Name,contact.Email,contact.MobilePhone,Attention__c,
                          IsPrimary,Remarks__c,Role,Opportunity.Subscription_Code__c from OpportunityContactRoles where role = 'Client Signatory')
                         from Opportunity where id=: oppId];
        system.debug('opp@@'+opp);
        List<cscfga__Product_Configuration__c> configs =[SELECT Id, Name,Fulfilment_Item_Status__c
                                                         FROM cscfga__Product_Configuration__c
                                                         WHERE cscfga__Product_Basket__r.csmso__Sales_Order__c =: opp.Primary_Sales_Order__c and Fulfilment_Item_Status__c='Inventory Released'];
        List<cscfga__Product_Configuration__c> offerOriginatingConfigs =[SELECT Id, Name,Fulfilment_Item_Status__c, cscfga__originating_offer__r.Disallow_Detailed_S_O_Print_Out__c
                                                                         FROM cscfga__Product_Configuration__c
                                                                         WHERE cscfga__Product_Basket__r.csmso__Sales_Order__c =: opp.Primary_Sales_Order__c and cscfga__originating_offer__r.Disallow_Detailed_S_O_Print_Out__c=true];
        
        List<cscfga__Product_Configuration__c> naaConfigs = [SELECT Id, Name,Fulfilment_Item_Status__c, Digital_Product__c, Digital_Product__r.Disallow_Detailed_S_O_Print_Out__c
                                                             FROM cscfga__Product_Configuration__c
                                                             WHERE cscfga__Product_Basket__r.csmso__Sales_Order__c =: opp.Primary_Sales_Order__c 
                                                             AND Digital_Product__r.Disallow_Detailed_S_O_Print_Out__c=true
                                                             AND Digital_Product__c != null];
        List<cscfga__Attribute__c> attributes = [SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Value__c, cscfga__Is_Line_Item__c FROM cscfga__Attribute__c 
                                                 WHERE cscfga__Product_Configuration__r.Sales_Order__c =: opp.Primary_Sales_Order__c
                                                 AND cscfga__Is_Line_Item__c = true];  
        if(opp.Primary_Sales_Order__r.Customer_Approval__c != 'Pending'){
        List<echosign_dev1__SIGN_Agreement__c> agreement =[select id from echosign_dev1__SIGN_Agreement__c
                                                           where echosign_dev1__Status__c in ('Out for Signature','Signed',
                                                                                              'Out for Approval','Approved',
                                                                                              'Accepted','Out for Delivery')
                                                          and echosign_dev1__Opportunity__c =: oppId];
        system.debug('agreement@@'+agreement);
        if(agreement.size() > 0){
             throw new AuraHandledException('Agreement has been Signed already or sent for Signature');
        }
        }
        List<String> ocrValidFields = new List<String>();
        Response res = new Response();
        List<String> commercialProdIds = new List<String>();
        List<cspmb__Price_Item__c> commercialDisallowProds = new List<cspmb__Price_Item__c>();
        if(!attributes.isEmpty()){
            for(cscfga__Attribute__c att : attributes){
                system.debug(att.name);
                if(att.cscfga__Value__c != null){
                if((att.cscfga__Value__c).StartsWith('a4d')){
                    commercialProdIds.add(att.cscfga__Value__c);
                }
                }
            }
        }        
        commercialDisallowProds = [Select Id , Name, Disallow_Detailed_S_O_Print_Out__c from cspmb__Price_Item__c Where id =: commercialProdIds and Disallow_Detailed_S_O_Print_Out__c = true];        
        if(!offerOriginatingConfigs.isEmpty() || !naaConfigs.isEmpty() || !commercialDisallowProds.isEmpty()){
            res.isDetailed = false;
        }
        else
            res.isDetailed = true;
        if(opp.stageName=='Closed Won' || opp.StageName == 'Closed Lost'){
            throw new AuraHandledException('Cannot generate contract for closed Oppty');
        }
       if(opp.Primary_Sales_Order__r.csmso__Status__c == 'Pending OMC Approval' || (opp.Primary_Sales_Order__r.csmso__Status__c== 'Pending Customer Approval'  &&  opp.Primary_Sales_Order__r.Is_Manual_Approval__c == false)){
            throw new AuraHandledException('Sales Order is pending for customer approval/OMC approval');
       }
        else if(opp.Billing_Entity__c ==null){
            throw new AuraHandledException('Please add Billing Entity');
        }
         else if(opp.b2b_Billing_Contact__c == null){
            throw new AuraHandledException('Please add Billing Contact');
        }
        else if(opp.Billing_Entity__c != opp.AccountID){
            // list<String>
            Boolean isFamily = getChildHierarchy(opp.Billing_Entity__c,opp.AccountID);
            if(!isFamily){
                 throw new AuraHandledException('Please select Billing Entity from Account hierarchy');
            }
        }
         if(opp.Billing_Address__c ==null){
            throw new AuraHandledException('Please add Billing Address');
        }
         if(opp.OpportunityContactRoles.size()==0){
                throw new AuraHandledException('You must have at least 1 Client Signatory to print your S/O contract');
                
            }
        if(currentUserInfo.Profile.Name !='B2B Sales User' && currentUserInfo.Profile.Name  != 'B2C Sales Head' &&
                currentUserInfo.Profile.Name !='CST User'  && currentUserInfo.Profile.Name  != 'TH B2C Sales User' &&
                currentUserInfo.Profile.Name !='Sales Enablement User' && currentUserInfo.Profile.Name  != 'B2C Sales User' &&
                !hasCustomPermission
               ){
                   throw new AuraHandledException('You are not allowed to Print Sales Orders');
               }
        
        else if(opp.Primary_Sales_Order__c == null ){
            throw new AuraHandledException('Please add primary sales order to proceed');
        }
        else if(configs.size()<0){
            // return false if SOLI have fulfilment item status as 'inventory released' then only Draft contract can be selected
            res.isFinal = false;
        }
        else if(opp.Primary_Sales_Order__r.csmso__Status__c == 'Ready for Customer Approval' || opp.Primary_Sales_Order__r.csmso__Status__c== 'Pending Customer Approval' ){
            if(opp.OpportunityContactRoles.size()==0){
                throw new AuraHandledException('You must have at least 1 Client Signatory to print your S/O contract');
                
            }
            if((opp.b2b_Billing_Contact__r.Email == null || opp.b2b_Billing_Contact__r.MobilePhone ==null)){
                   // isEmailorPhoneNull = true;
                    throw new AuraHandledException('Billing Contact must have Email and Mobile to print your S/O contract');
                }
            
            for(OpportunityContactRole OCR : opp.OpportunityContactRoles){
                /*if(OCR.Isprimary ==true && OCR.Role == 'Billing Contact'){
                    isBillingPrimary = true;
                    if(OCR.Account_s_Billing_Address__c == null){
                        ocrValidFields.add('Account\'s Billing Address');
                    }
                    if(OCR.contact.Email == null)
                        ocrValidFields.add('Contact\'s Email');
                    
                }*/
                if(OCR.Role == null){
                    ocrValidFields.add('Role');
                }
                if(OCR.Role == 'Client Signatory'){
                    isSignatory = true;
                }
              /*  if(OCR.Role == 'Client Signatory' && (OCR.contact.Email == null || OCR.contact.MobilePhone ==null)){
                   // isEmailorPhoneNull = true;
                    throw new AuraHandledException('Contact must have Email and Mobile to print your S/O contract');
                }*/
                //  if()
            }
            if(!isSignatory ){
                throw new AuraHandledException('You must have at least 1 Client Signatory to print your S/O contract');
            }
            else if(ocrValidFields.size() >0){
                throw new AuraHandledException('Please update contact information : '+ String.join(ocrValidFields, (',')));
                
            }
            
            // return true if only final contract can be selected
            res.isFinal = true;
        }
        else{
            // return false if only Draft contract can be selected
            res.isFinal = false;
        }   
     
        ContractControllerV2 CC = new ContractControllerV2(opp.Id,'DetailedDraft');
        cc.generateContractPDF();
        SO_Contract_opp__c  sco = [select id from SO_Contract_opp__c  where Opportunity__c =: opp.Id];
        res.contractId =sco.id;
        return res;
    } 
    
    public class Response{
        @auraEnabled
        public boolean isDetailed;
        @auraEnabled
        public boolean isFinal;
        @auraEnabled
        public String contractId;
    }
    
    
    public static Boolean getChildHierarchy(String billingEntity,String oppAccID){
        List<String> allHierarchy = new List<String>();
        set<String> name = new Set<String>();
        boolean newAdded = false;
        do{
              newAdded = false;
            List<Account> accList = new List<Account>();
            if(allHierarchy.isEmpty())
                accList = [select id,name,parentid,parent.name,
                           (Select id,name from ChildAccounts) from account where id =: billingEntity];
            else
                accList = [select id,name,parentid,parent.name,(Select id,name from ChildAccounts) from account where id in: allHierarchy];
            for(Account acc : accList){
              
                if(allHierarchy.contains(acc.id)){
                    
                }else{
                   
                    allHierarchy.add(acc.id);
                    name.add(acc.name);
                    newAdded= true;
                }
                if(allHierarchy.contains(acc.parentid)){
                    
                }else{
                    if(acc.ParentId!=null){
                    allHierarchy.add(acc.parentid);
                     name.add(acc.parent.name);
                    newAdded= true;
                    }
                }
                for(Account ca : acc.ChildAccounts){
                    if(allHierarchy.contains(ca.id)){
                        
                    }else{
                        allHierarchy.add(ca.id);
                        name.add(ca.name);
                        newAdded= true;
                    }
                }
            }
            system.debug(name);
            
            if(allHierarchy.contains(oppAccID)){
                return true;
             }
        }while(newAdded);
        return false;
    }
}
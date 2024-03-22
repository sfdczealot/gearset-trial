public class SalesOrderEmailActivity_cc {
    public Id orderID {get;set;}
    public Integer expired {get;set;}
     public boolean oct1stCheck {get;set;}
    public String soStartDate {get;set;}
    public String soEndDate {get;set;}
    public user sender {get;set;}
    public csmso__Sales_order__c salesOrder ;
    public    List<csdf__Fulfilment_Item__c> fiListEmail  {get;set;}
    public  csmso__Sales_order__c getsalesOrder(){
        salesOrder = [select id,csmso__Opportunity__r.Opportunity_Number__c,csmso__Advertiser__r.Name,
                      SO_Start_Date_Manual__c,
                      SO_Start_Date__c,SO_End_Date__c from csmso__Sales_order__c WHERE Id =: orderId];
        fiListEmail =  [SELECT Id,Name,Quantity_CPD__c,csdf__Billing_Category__c,
                        Description__c,Flight_Beginning_Date_YYYY_MM_DD__c,
                        Flight_End_Date_YYYY_MM_DD__c,
                        csdf__Name__c FROM csdf__Fulfilment_Item__c 
                        WHERE csdf__Fulfilment__r.Sales_Order__c =: orderID and
                        Aggregated_Status__c != 'Completed' and 
                        Aggregated_Status__c != 'Paused Inventory Released' and 
                        Aggregated_Status__c != 'Delivering' and
                        Product_Configuration__r.cscfga__Product_Family__c in ('Ad Served', 'Standard Products',
                                                                               'Developer Listings','Database Marketing')
                       ];
        sender=[select name,title from user where id=: UserInfo.getUserId()];
        
        Date endDate = salesOrder.SO_End_Date__c;
        Date today = System.today();
        expired = today.monthsBetween(endDate);
        if (endDate.day() > today.day()) expired++;
        System.debug(expired);
        
        String dateFormatString = 'yyyy-MM-dd';
        
        Date d = salesOrder.SO_Start_Date__c;
        Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
        soStartDate = dt.format(dateFormatString);
        Date d1 = salesOrder.SO_End_Date__c;
        Datetime dt1 = Datetime.newInstance(d1.year(), d1.month(),d1.day());
        soEndDate = dt1.format(dateFormatString);
        
        oct1stCheck = salesOrder.SO_Start_Date_Manual__c>= Date.newInstance(2021, 10,1);
        // soStartDate= .format('YYYY-MM-DD');
        
        return salesOrder;
        
    }
    
    public class wrapperClass{
        @AuraEnabled public List<OpportunityContactRole> OCRList;
        @AuraEnabled public List<OpportunityTeamMember> OTMList;
        @AuraEnabled public List<AccountTeamMember> ATMList;
        @AuraEnabled public List<csdf__Fulfilment_Item__c> fiList;
        @AuraEnabled public csmso__Sales_Order__c soDetails;
        // @AuraEnabled public String endDate;
    }
    @AuraEnabled
    public static wrapperClass getDetails(String salesOrderId){
        Map<String,String> conEmail = new  Map<String,String>();
        csmso__Sales_Order__c soDetails = [SELECT id,csmso__Opportunity__r.Opportunity_Number__c,csmso__Advertiser__r.Name,SO_expiring_in__c,
                                           SO_Start_Date__c,SO_End_Date__c 
                                           FROM csmso__Sales_order__c 
                                           WHERE id =: salesOrderId ];
	  if((soDetails.SO_expiring_in__c>= 16 && soDetails.SO_expiring_in__c <=51) ||
           (soDetails.SO_expiring_in__c>= 76 && soDetails.SO_expiring_in__c <=111) ||
           (soDetails.SO_expiring_in__c>= 166 && soDetails.SO_expiring_in__c <=201 )){
               
               
        List<OpportunityContactRole> OCRList = [SELECT id,Contact.Name,Contact.Email
                                                FROM OpportunityContactRole
                                                WHERE Opportunity.Primary_Sales_Order__c =: salesOrderId];
        List<OpportunityTeamMember> OTMList = [SELECT Id,Opportunity.Name,UserId,Name,User.Email FROM OpportunityTeamMember
                                               WHERE Opportunity.Primary_Sales_Order__c =: salesOrderId];
        List<AccountTeamMember> ATMList = [SELECT Id,Account.Name,UserId,user.name,User.Email  FROM AccountTeamMember where AccountId IN 
                                           (SELECT csmso__Advertiser__c FROM csmso__Sales_Order__c where Id =:salesOrderId)];
        system.debug('opp team' +OCRList);
                
        system.debug('account team' +ATMList);
        system.debug('opp team' +OTMList);
        List<csdf__Fulfilment_Item__c> fiList = [SELECT Id,Name,Quantity_CPD__c,csdf__Billing_Category__c,
                                                        Description__c,Flight_Beginning_Date_YYYY_MM_DD__c,
                                                        Flight_End_Date_YYYY_MM_DD__c,
                                                        csdf__Name__c FROM csdf__Fulfilment_Item__c 
                                                        WHERE csdf__Fulfilment__r.Sales_Order__c =: salesOrderId and
                                                        Aggregated_Status__c != 'Completed' and 
                                                        Aggregated_Status__c != 'Paused Inventory Released' and 
                                                        Aggregated_Status__c != 'Delivering' and
                                                        Product_Configuration__r.cscfga__Product_Family__c in ('Ad Served',
                                                                                                               'Standard Products',
                                                                                                               'Developer Listings',
                                                                                                               'Database Marketing')
                                                 
                                                       ];
               wrapperClass wrap = new wrapperClass();
               wrap.OCRList = OCRList;
               wrap.OTMList = OTMList;
               wrap.ATMList = ATMList;
               wrap.fiList = fiList;
               wrap.soDetails = soDetails;
               
               system.debug(filist);
               return wrap;
           }
        else
            return null;
    }
    
    @auraEnabled
    public static void sendRemMail(String SOId,List<String> conId,List<String> ccRecipient,String language){
        try{
            String OrgWideEmailId = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName =  'CST users'].Id;
         String emailTemplateId;
            if(Language == 'English'){
                 emailTemplateId = 'Sales_order_email_activity';
            }else if(Language == 'Thai'){
                 emailTemplateId = 'Sales_order_email_activity_Thai';
            }else if(Language == 'Bahasa'){
                 emailTemplateId = 'Sales_order_email_activity_Bahasa';
            }
            //email template selection based on language
            String EmailTem = [SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body
                                                                    FROM EmailTemplate where
                                                                    DeveloperName =: emailTemplateId].id;
            
            csmso__sales_order__c so = [select id,owner.email,csmso__opportunity__r.owner.email from csmso__sales_order__c where id=: SOId];
            List<Contact> contactList = [select id,Name,Email from contact where id in: conId];
List<String> conEmailList =new List<String>();
            
            for(contact con : contactList){
                conEmailList.add(con.email);
            }
            system.debug('ccid==' +ccRecipient);
         //  List<user> userList = [select email from user where id IN:ccRecipient];

          /* system.debug('userList' +userList);
            for(User u:userList){
                emailList.add(u.email);
            }*/
            List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           
            mail.setTemplateId(EmailTem);
            mail.setToAddresses(conEmailList);
            
            // mail.setHTMLBody(htmlBody);
            mail.setWhatId(SOId);
           mail.setTargetobjectid(contactList[0].id);
            mail.setSaveAsActivity(true);
            mail.setUseSignature(false); 
            mail.setCcAddresses(ccRecipient);
            //mail.setCcAddresses(new List<String>{so.csmso__opportunity__r.owner.email});
            mail.setTreatTargetObjectAsRecipient(true);
            mail.setOrgWideEmailAddressId(OrgWideEmailId);
            singleEmailMessageList.add(mail);
          //  mail.set
          //  mail.setHtmlBody('param1'+mail.getHtmlBody());
            if(!Test.isRunningTest()){
            Messaging.sendEmail(singleEmailMessageList);
            }
        }catch(Exception exp){
            system.debug('---exp--- '+exp.getMessage()+language);
            throw new AuraHandledException('Error: '+exp.getMessage()+language);            
        }
    }
      @auraEnabled
    public static void sendTestMail(String SOId,String language){
        try{
            String OrgWideEmailId = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName =  'CST users'].Id;
         String emailTemplateId;
            if(Language == 'English'){
                 emailTemplateId = 'Sales_order_email_activity';
            }else if(Language == 'Thai'){
                 emailTemplateId = 'Sales_order_email_activity_Thai';
            }else if(Language == 'Bahasa'){
                 emailTemplateId = 'Sales_order_email_activity_Bahasa';
            }
            //email template selection based on language
            String EmailTem = [SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body
                                                                    FROM EmailTemplate where
                                                                    DeveloperName =: emailTemplateId].id;
            
            csmso__sales_order__c so = [select id,owner.email,csmso__opportunity__r.owner.email from csmso__sales_order__c where id=: SOId];
            
            
            List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           
            mail.setTemplateId(EmailTem);
            mail.setWhatId(SOId);
            mail.setTargetobjectid(UserInfo.getUserId());
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false); 
            mail.setTreatTargetObjectAsRecipient(true);
            mail.setOrgWideEmailAddressId(OrgWideEmailId);
            singleEmailMessageList.add(mail);
            if(!Test.isRunningTest()){
            Messaging.sendEmail(singleEmailMessageList);
            }
        }catch(Exception exp){
            system.debug('---exp--- '+exp.getMessage()+language);
            throw new AuraHandledException('Error: '+exp.getMessage()+language);            
        }
    }
}
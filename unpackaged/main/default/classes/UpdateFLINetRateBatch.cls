//TEST CLASS:UpdateFLINetRateBatch_Test
global class UpdateFLINetRateBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    
    Map<csdf__Fulfilment_Item__c, String> failedFLIMap = new Map<csdf__Fulfilment_Item__c, String>();
    static String hostVal  = URL.getSalesforceBaseUrl().toExternalForm();
    
    public void execute(SchedulableContext sc){  
        DataBase.executeBatch(new UpdateFLINetRateBatch(), 50);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bC) {
        string query='Select id, Name, New_Line_ID__c, Product_Configuration__r.Name, csdf__Rate__c, csdf__Quantity__c from csdf__Fulfilment_Item__c where csdf__Flight_Beginning__c > 2021-01-01T00:00:00.000+0000 and Product_Configuration__r.Sales_Order__r.csmso__Status__c != \'Killed\' and Product_Configuration__r.Name like \'%Developer%\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bC, List<csdf__Fulfilment_Item__c> recordList){
        try{
            Map<String,csdf__Fulfilment_Item__c> lineToFLIMap = new Map<String,csdf__Fulfilment_Item__c>();
            for(csdf__Fulfilment_Item__c fli : recordList){
                lineToFLIMap.put(fli.New_Line_ID__c, fli);
            }
            Map<String, cscfga__Product_Configuration__c> lineToPcMap = new Map<String, cscfga__Product_Configuration__c>();
            List<cscfga__Product_Configuration__c> pcList = [select Id, Name, cscfga__Description__c, Line_ID__c, cscfga__One_Off_Charge__c, (select id,name,cscfga__Value__c, cscfga__Price__c from cscfga__Attributes__r Where cscfga__Is_Line_Item__c = true) from cscfga__Product_Configuration__c where Line_ID__c =: lineToFLIMap.keyset()];
            for(cscfga__Product_Configuration__c pc : pcList){
                lineToPcMap.put(pc.Line_ID__c, pc);
            }
            List<csdf__Fulfilment_Item__c> fliToUpdateList = new List<csdf__Fulfilment_Item__c>();
            for(csdf__Fulfilment_Item__c fli :lineToFLIMap.values()){
                if(lineToPcMap.containskey(fli.New_Line_ID__c)
                   && lineToPcMap.get(fli.New_Line_ID__c).cscfga__Attributes__r.size() > 0
                   && lineToPcMap.get(fli.New_Line_ID__c).cscfga__Attributes__r[0].cscfga__Price__c != null 
                   && fli.csdf__Rate__c != lineToPcMap.get(fli.New_Line_ID__c).cscfga__Attributes__r[0].cscfga__Price__c)
                {
                    //System.debug('**** **** '+fli.csdf__Rate__c+ ' : '+lineToPcMap.get(fli.New_Line_ID__c).cscfga__Attributes__r[0].cscfga__Price__c);
                    //System.debug('*** '+lineToPcMap.get(fli.New_Line_ID__c));
                    fli.csdf__Rate__c = lineToPcMap.get(fli.New_Line_ID__c).cscfga__Attributes__r[0].cscfga__Price__c;
                    fliToUpdateList.add(fli);
                }
            }
            if(!fliToUpdateList.isEmpty()){
                Database.DMLOptions dmlUpdateFLI = new Database.DMLOptions(); 
                Database.SaveResult[] srUpdateList = Database.update(fliToUpdateList, dmlUpdateFLI);
                for(Integer i = 0; i < srUpdateList.size(); i++) {
                    if (!srUpdateList[i].isSuccess()){
                        for(Database.Error err : srUpdateList[i].getErrors()) {
                            System.debug(err.getStatusCode() + ' - ' + err.getFields() +' - ' + err.getMessage());
                            failedFLIMap.put(fliToUpdateList[i], err.getStatusCode() + ' - ' + err.getFields() +' - ' + err.getMessage());
                        }
                    }
                }
            }
        }catch(Exception ex){
            System.debug('Exception in update FLI Batch *** ' + ex + ' - ' + ex.getMessage());
            PrepareAndSendEmail(null, ex);
        }
        
    }
    global void finish(Database.BatchableContext bC) {
        System.debug('failedFLIMap.size() '+failedFLIMap.size());
        if(!failedFLIMap.isEmpty()){
            PrepareAndSendEmail(failedFLIMap, null);
        }
    }
    /***************************************************************************
    * 
    * Method to prepare and send Emails on errors
    * 
    * *************************************************************************/            
    public static void PrepareAndSendEmail(Map<csdf__Fulfilment_Item__c, String> failedFLIMap, Exception ex){
        Emails_FLI_failure__mdt metaData = [Select Id, Email_Ids__c From Emails_FLI_failure__mdt LIMIT 1];
        //Get metadata and the email
        List<Messaging.SingleEmailMessage> singleEmailList = new List<Messaging.SingleEmailMessage>();
        
        String[] toAddresses;
        if(metaData.Email_Ids__c != null){
            toAddresses = metaData.Email_Ids__c.split('\n');
        }
        if(toAddresses.isEmpty()) {toAddresses.add('allen@propertyguru.com.sg');}
        
        string emailSubject = 'Fulfilment Item NetRate update failure: ';        
        String emailBody = 'Dear Team,<br/><br/>';
        
        emailBody += 'Fulfilment Item NetRate update failed, see below for details:<br/><br/>';
        emailBody += '<table border="1" style="border-collapse: collapse">'//uk
            +'<tr>'
            +'<th><b>S NO.</b></th>'
            +'<th><b>Fulfilment Item Name</b></th>'
            +'<th><b>NetRate to Update</b></th>'
            +'<th><b>Error Details</b></th>'
            +'</tr>';//uk
        Integer loopCount = 1;
        if(failedFLIMap != null){
            for(csdf__Fulfilment_Item__c fli : failedFLIMap.keySet()){
                emailBody += '<tr><td>' + loopCount+ '</td>'; 
                emailBody += '<td><a href="'+hostVal+'/'+fli.Id+'">'+ fli.Name+'</a></td>'; 
                emailBody += '<td> ' + fli.csdf__Rate__c + '</td>';
                emailBody += '<td> ' + failedFLIMap.get(fli) + '</td></tr>';
                loopCount++;
            }   
        }else{
            emailBody += '<b>Error Details:</b> ' + ex.getMessage() + '<br/>';
            System.debug('emailBody ' +emailBody);
        }
        emailBody += '</table>';//uk
        emailBody += '<br/><br/>';
        emailBody += 'Thanks!<br/>';
        emailBody += 'Have a great day!'; 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        mail.setToAddresses(toAddresses);
        System.debug('toAddresses ' +toAddresses);
        mail.setSubject(emailSubject);
        System.debug('emailSubject ' +emailSubject);
        mail.setHtmlBody(emailBody);
        System.debug('emailBody ' +emailBody);
        singleEmailList.add(mail);
        System.debug('mail ' +mail);
        try{
            Messaging.sendEmail(singleEmailList);
        }
        catch(Exception e){
            System.debug('Exception in PrepareAndSendEmail()**** ' + e.getMessage());
        }
    }
}
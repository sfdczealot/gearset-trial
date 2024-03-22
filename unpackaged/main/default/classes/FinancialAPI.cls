@RestResource(urlMapping='/api/financial/*')
global class FinancialAPI {
    
    @HttpPost
    global static void Attachment(){
        string errorResponse = '' ;
        try{
            RestRequest req = RestContext.request;           
            String jsonInput= req.requestBody.toString();
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInput); 
            Id record = String.valueOf(jsonMap.get('record')) ;    
            String attachment_file = String.valueOf(jsonMap.get('attachment_file')) ;    
            
            if(record <> null){
                for (Financial__c row: [select id, Document_Id__c,Type__c,Name from Financial__c where id =:record]){
                    Document attach = new Document();
                    attach.ContentType = 'application/pdf';
                    attach.name = row.Type__c + '_' + row.Name + '.pdf';
                    attach.body = EncodingUtil.base64Decode(attachment_file);
                    attach.folderId = '00l7F0000011fcq';
                    insert attach;
                    if(attach.Id <> null){
                        System.debug('Document Id:' + attach.Id);
                        row.Document_Id__c = attach.Id;
                        update row;
                        RestContext.response.responseBody = Blob.valueOf('{"Status":"SUCCESS", "Id":"'+row.id+'", "Record":"'+row.Name+'", "AttachmentId":"'+attach.Id+'"}');
                    }
                    else{
                        RestContext.response.responseBody = Blob.valueOf('{"Status":"FAILED""}');
                    }
                }
            }
        }
        catch(Exception e) {
            errorResponse =  e.getMessage();
            system.debug(errorResponse);
        }
    }
}
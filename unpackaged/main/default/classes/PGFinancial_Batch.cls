global class PGFinancial_Batch implements Database.Batchable <sObject>, Schedulable , Database.AllowsCallouts {

    List <Financial__c> recList = new List < Financial__c > ();
    static string errorResponse = '';
    Integer ctrRun = 0;

    public class DR {
        String type;
        DRData rec;
    }

    public class DRData {
        String rectype;
        String id;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        //List<id> Idquery = new List<id>{'a0F7F00000DdK6O','a0F7F00000CZD1X','a0F7F00000DdNyZUAV'};
        //Date Startdate = label.;
        //Date Enddate = system.today();
        String query = label.PG_LABEL_PGFinancial_BatchJob_q;
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List <Financial__c> recList) {
		try {
            ctrRun = 1;
            Integer ctr = 1;
            Map<id, string> attachmentInput = new Map<id, string>();
            // process each batch of records
            system.debug('data:'+ recList);
            for (Financial__c recupd: recList) {
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                String endpoint, auth;
        
                if (runningInASandbox()) {
                    endpoint = label.PG_LABEL_PG_NetSuite_Billing_Sync_SB;
                    auth = label.PG_LABEL_PG_NetSuite_Billing_Sync_Cred_SB;
                } else {
                    endpoint = label.PG_LABEL_PG_NetSuite_Billing_Sync;
                    auth = label.PG_LABEL_PG_NetSuite_Billing_Sync_Cred;
                }
                req.setEndpoint(endpoint);
                req.setMethod('POST');
                req.setHeader('Cache-Control', 'no-cache');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', auth);
                System.debug('ep' + endpoint);
                System.debug('auth' + auth);
                system.debug(ctr + ':' + recupd.Id);
                ctr = ctr + 1;
                errorResponse = '';
    
                DR DRPayload = new DR();
                DRData DRDataPayload = new DRData();
    
                DRDataPayload.rectype = recupd.Type__c;
                DRDataPayload.id = recupd.NetSuite_Id__c;
    
                DRPayload.type = 'RetrievePDF';
                DRPayload.rec = DRDataPayload;
                string request = system.JSON.serialize(DRPayload);
                req.setBody(request);
                req.setTimeout(60000);
                System.debug('Document Payload : ' + req.getBody());
                HttpResponse res = h.send(req);
                System.debug('Res : ' + res);
                system.debug('Response Body : ' + res.getBody());
                if (res.getStatusCode() <> 200) {
                    errorResponse = res.getBody();
                } else {
                    system.debug('res.getBody():' +res.getBody());
                    if (res.getBody() != 'null' && res.getBody() != null && res.getBody() != '') {
                        String attach_data = res.getBody();
                        system.debug('attach_data:' +attach_data);
                        if(attach_data != 'null'){
                            attachmentInput.put(recupd.Id,attach_data);
                        }
                    }
                }
            }
            
            if(ctrRun > 0){
            	CreateAttachments(recList,attachmentInput);
                ctrRun = 0;
            }
        } catch (Exception e) {
            System.debug('error'+e);
            System.debug('line:'+e.getLineNumber());
        }

    }

    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
    
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new PGFinancial_Batch());
    }
    
    public static void CreateAttachments(List <Financial__c> recList, Map<id, string> attachmentOutput){
        system.debug('RecList: ' +recList);
        system.debug('MapAttachment: ' +attachmentOutput);
        
        system.debug('MapAttachment Size: ' +attachmentOutput.size());
        if(attachmentOutput.size() > 0){
            if(recList != null && attachmentOutput != null){
                Integer ctratt = 0;
                for (Financial__c recupd: recList) {
                    ctratt = ctratt + 1;
                    system.debug(recupd.id + ':' + attachmentOutput.get(recupd.Id));
                    if(attachmentOutput.get(recupd.Id) != 'null' && attachmentOutput.get(recupd.Id) != null){
                        system.debug(ctratt + '. ' + attachmentOutput.get(recupd.Id));
                        String attach_data = attachmentOutput.get(recupd.Id);
                        system.debug('attach_data:' + attach_data);
                        
                        if(attach_data != null && attach_data != '' && attach_data !='null'){
                            attach_data = attach_data.replace('"', '');
                            Document attach = new Document();
                            attach.ContentType = 'application/pdf';
                            attach.name = recupd.Type__c + '_' + recupd.Name + '.pdf';
                            attach.body = EncodingUtil.base64Decode(attach_data);
                            attach.folderId = '00l7F0000011fcq';
                            insert attach;
                            if (attach.id != null) {
                                System.debug('Document Id:' + attach.Id);
                                recupd.Document_Id__c = attach.Id;
                            }
                        }
                    }
                }
                update recList;
            }
        }
    }

    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}
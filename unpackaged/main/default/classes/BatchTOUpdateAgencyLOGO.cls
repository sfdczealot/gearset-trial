public class BatchTOUpdateAgencyLOGO implements DataBase.Batchable<Sobject> ,Database.AllowsCallouts, Database.Stateful{
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id,Account__c,URL__c from Media__c where IsActive__c=false';
        return DataBase.getQueryLocator(query);      
    }
    public void execute(Database.BatchableContext bc, List<Media__c> listMedia){
        Map<String,ContentVersion> listContentVersion = new Map<String,ContentVersion>();
        Map<String,String> mapContentVersionID = new Map<String,String>();
        List<ContentDocumentLink> cdlinkList= new List<ContentDocumentLink>();
        List<Media__c> mediaUpdate= new List<Media__c>();
        system.debug(listMedia);
        
        
        for(Media__c med : listMedia){
            String endpoint = med.URL__c;
            HTTP h = new HTTP();
            HTTPRequest req = new HTTPRequest();
            req.setEndPoint(endpoint.trim());
            req.setHeader('Cache-Control', 'no-cache');
            req.setTimeout(integer.valueof(label.PG_LABEL_API_TimeOut));
            req.setMethod('GET');
            HTTPResponse res = h.send(req);
            while (res.getStatusCode() == 302) {
                req.setEndpoint(res.getHeader('Location'));
                req.setTimeout(integer.valueof(label.PG_LABEL_API_TimeOut));
                res = new Http().send(req);
            }
            system.debug(res.getBody());
            //    if(res.getBodyAsBlob()!=null){
            List<String> name=med.URL__c.Split('/');
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; 
            conVer.PathOnClient = name[name.size()-1]; 
            conVer.Title = name[name.size()-1];
            
            blob b=res.getBodyAsBlob();
            if(b==null && res.getBody()!=null && res.getBody()!=''){
                b=blob.valueOf(res.getBody());
            }
            if(b!=null){
                conVer.VersionData = b;
                listContentVersion.put(med.id,conVer);
            }
           
            
        }
        system.debug('list size  '+listContentVersion.size());
        system.debug(listContentVersion);
        insert listContentVersion.Values();
        for(String s : listContentVersion.keySet()){
            mapContentVersionID.put(listContentVersion.get(s).id,s);
        }
        
        List<ContentVersion> conDoc = [SELECT id,ContentDocumentId FROM ContentVersion WHERE Id in: mapContentVersionID.keySet()];
        
        for(ContentVersion c: conDoc)  {
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = c.ContentDocumentId;
            cDe.LinkedEntityId = mapContentVersionID.get(c.id); 
            cDe.ShareType = 'V'; 
            cdlinkList.add(cDe);
            mediaUpdate.add(new Media__c(id=mapContentVersionID.get(c.id),IsActive__c=true));
        }
        insert cdlinkList;
        update mediaUpdate;
        
    }
    
    public void finish(Database.BatchableContext bc){
        System.debug('finish123');
    }
    
    
}
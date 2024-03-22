/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Controller for ApprovalResult visualforce page
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* * @author         Osvaldo Parra  <osvaldo.parrarascon@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            name@email.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public without sharing class ApprovalResultController {
    // PROPERTIES - START
    public String salesOrderId {get;set;}
    public String soName {get;set;}
    public List<CS_ApprovalService.ApprovalResultSnapshot> approvalResults {get;set;}
    public Map<String, String> lineIdToNumberMap {get;set;}

    public ApprovalResultController(){
        try {
            // fetch query string parameters
            salesOrderId = ApexPages.currentPage().getParameters().get('salesOrderId');

            if(salesOrderId == null){
                throw new ApprovalResultException('Sales Order Id from querystring parameter cannot be null!');
            }
            loadData(salesOrderId);
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(
                    ApexPages.severity.ERROR,
                    'An error ocured while loading page. ' + ex.getMessage()));
            System.debug('##### Error while reading approval results: ' + ex.getMessage() + ' [' + ex.getLineNumber() + ']');
            System.debug('##### stack trace: ' + ex.getStackTraceString() );
        }
    }

    public void loadData(String soId){

        //Get basket and product configs from sales order
        List<cscfga__Product_Basket__c> applicableBaskets =
        [
                SELECT  Id,
                        csmso__Sales_Order__r.Name,
                (Select Id,Line_ID__c from cscfga__Product_Configurations__r)
                FROM    cscfga__Product_Basket__c
                WHERE   csmso__Sales_Order__c = :soId
        ];

        Set<Id> configurationIdSet = new Set<Id>();
        this.lineIdToNumberMap = new Map<String,String>();
        //save the so name and configuration Ids
        if(!applicableBaskets.isEmpty()){
            if(applicableBaskets[0] != null){
                soName = applicableBaskets[0].csmso__Sales_Order__r.Name;

                if(applicableBaskets[0].cscfga__Product_Configurations__r != null){
                    for(cscfga__Product_Configuration__c line : applicableBaskets[0].cscfga__Product_Configurations__r){
                        configurationIdSet.add(line.Id);
                        //Build map of pc Ids to Line_ID__c
                        this.lineIdToNumberMap.put(line.Id, (String)line.Line_ID__c);
                    }
                }
            }
            //gather all file names
            Set<String> fileNames = getFileNames();

            //get attachment bodies
            List<Attachment> csApprovalResultsList = getAttachmentBodies(New Set<Id> {applicableBaskets[0].Id}, fileNames);

            //deserialize each attachment body and add to list
            List<CS_ApprovalService.ApprovalResultSnapshot> deserializedSnapshot = getDeserializedAttachments(csApprovalResultsList);
            //do final clean up on deserialized attachment
            finalizeApprovalResults(deserializedSnapshot);
            //add to results to display in vf page
            this.approvalResults = deserializedSnapshot;
        }
    }

    public List<Attachment> getAttachmentBodies(Set<Id> applicableBaskets, Set<String> fileNames){
        List<Attachment> csApprovalResultsList = new List<Attachment>();

        csApprovalResultsList.addall( CS_Attachment.getAttachmentList(applicableBaskets, fileNames) );

        return csApprovalResultsList;
    }

    public List<CS_ApprovalService.ApprovalResultSnapshot> getDeserializedAttachments(List<Attachment> csApprovalResultsList){
        List<CS_ApprovalService.ApprovalResultSnapshot> deserializedSnapshot = new List<CS_ApprovalService.ApprovalResultSnapshot>();

        for(Integer i = 0; i < csApprovalResultsList.size(); i++){
            deserializedSnapshot.addall( (List<CS_ApprovalService.ApprovalResultSnapshot>)JSON.deserialize(csApprovalResultsList[i].Body.ToString(), List<CS_ApprovalService.ApprovalResultSnapshot>.class) );
        }
        return deserializedSnapshot;
    }

    public void finalizeApprovalResults(List<CS_ApprovalService.ApprovalResultSnapshot> deserializedSnapshot){
        //loop through each approvalresult and remove ones without message
        for(CS_ApprovalService.ApprovalResultSnapshot result : deserializedSnapshot){
            for(Integer i = (result.ApprovalResultList.size()-1); i>= 0; i--){
                String msg = result.ApprovalResultList[i].message;
                if(String.isBlank(msg)){
                    result.ApprovalResultList.remove(i);
                }
            }
        }
    }

    public Set<String> getFileNames(){
        Set<String> fileNames = new Set<String>();

        Map<String, Approval_Type__mdt> approvalTypes = CS_ApprovalService.approvalTypes;

        //populate file names from MDT
        for(Approval_Type__mdt key : approvalTypes.Values()){
            fileNames.add(key.Order_Result_Filename__c);
            fileNames.add(key.Order_Line_Result_Filename__c);
        }

        return fileNames;
    }

    // EXCEPTIONS - START
    public class ApprovalResultException extends Exception {}
}
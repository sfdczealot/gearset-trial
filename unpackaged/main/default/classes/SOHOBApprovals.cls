@RestResource(urlMapping='/api/salesorderHOBApproval/')

global class SOHOBApprovals {
    /*
* comments,
*/
    @HttpPost
    global static void approveRejectSalesOrder(){
        RestRequest request = RestContext.request;
        Map<String, Object> params;
         String response;
         RestResponse res = RestContext.response;
        if(request != null && String.isNotBlank(request.requestBody.toString())){
            system.debug('---<<<req>>>--- '+request.requestBody.toString());
            params = (Map<String, Object>)JSON.deserializeUntyped(request.requestBody.toString());
            String soId =(String)params.get('SOId');
            String approvalStatus = (String)params.get('ApprovalStatus');
            /*String comments =(String)params.get('Comments');
csmso__Sales_Order__c so = new csmso__Sales_Order__c(id=soId,Comments__c =comments);
update so;*/
            system.debug('****SO updated');
            if(ApprovalStatus == 'Approved'){
                ButtonSOApprovalAccept button = new ButtonSOApprovalAccept();
               response=  button.performAction(soId);
            }
            if(ApprovalStatus == 'Rejected'){
                ButtonSOApprovalReject button = new ButtonSOApprovalReject();
                  response=  button.performAction(soId);
            }
             res.statusCode = 200;
            res.responseBody =Blob.valueOf(response);
            
        }
    }
}
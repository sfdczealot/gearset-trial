public with sharing class InsertionOrder2ClickApproveController {
    public InsertionOrder2ClickApproveController() {}

    public PageReference insertionOrder2ClickApprove() {
        Id ioId = ApexPages.currentPage().getParameters().get('Id');
        Id soId = ApexPages.currentPage().getParameters().get('soId');
        
        csmso__Sales_Order__c so = [SELECT Id, csmso__Booking_Contact__c, Click_Approve_Setting_for_templates__c FROM csmso__Sales_Order__c WHERE Id = :soId];
        csmso__Upload_Approval__c ua = [SELECT Id, Name FROM csmso__Upload_Approval__c WHERE Id = :ioId];
        if (so == null || ua == null){
            return null;
        }

        
        CSCAP__ClickApprove_Contact_Role__c role = null;

        try {
            role = [
                SELECT  CSCAP__Contact__c
                FROM    CSCAP__ClickApprove_Contact_Role__c
                WHERE   Upload_Approval__c = :ua.id
            ];
        } catch (Exception e) {
            // no records
        }

        if (role == null) {
            CSCAP__Click_Approve_Setting__c setting = [SELECT Id FROM CSCAP__Click_Approve_Setting__c WHERE Name = :so.Click_Approve_Setting_for_templates__c];
            role = new CSCAP__ClickApprove_Contact_Role__c (
                CSCAP__ClickApprove_Setting__c = setting.Id,
                Upload_Approval__c = ua.id,
                CSCAP__IsPrimary__c = true,
                CSCAP__Role__c = 'Booking Contact'
            );
        }

        role.CSCAP__Contact__c = so.csmso__Booking_Contact__c;

        upsert role;

        // ensure that attachments from the sales order are available on the uploadapproval record, so that they can be included in clickapprove.
        List<Attachment> ioAttachments = [select Id, Name, ParentId from Attachment where ParentId = :ua.id];

        if (ioAttachments.size() == 1){ // add sales order attachments to the upload approval record so they can also be included in the email.
            List<Attachment> newAttachments = new List<Attachment>();

            for (Attachment sA : [select Id, Name, ParentId, Body, contentType from Attachment where ParentId = :so.id]){
                Attachment a = new Attachment();
                a.name = sA.name;
                a.parentId = ua.id;
                a.Body = sA.Body;
                a.contentType = sA.contentType;

                newAttachments.add(a);
            }

            if (newAttachments.size() > 0){
                insert newAttachments;
            }
        }

        return new PageReference('/apex/CSCAP__SendFormalEmailForApproval_LE?Id=' + ua.id);
    }
}
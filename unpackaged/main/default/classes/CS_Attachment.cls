/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to hold common actions related to attachments.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Danijel Scuric   <danijel.scuric@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            name@email.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_Attachment {
    public static Map<String, List<String>> getAttachmentContentToDeserializeList(Set<Id> recordIdSet, List<String> fileNames) {
        Map<String, List<String>> attachmentContentToTypeMap = new Map<String, List<String>>();
        List<String> attachmentContentList = new List<String>();

        List<Attachment> listAttachment = CS_Attachment.getAttachmentList(recordIdSet, fileNames);

        if(!listAttachment.isEmpty()){
            for(Attachment currentAttachment : listAttachment) {
                Map<String, String> attachmentContentToNameMap = new Map<String, String>();
                if(currentAttachment.body != null){
                    for(String attachmentName : fileNames){
                        if(currentAttachment.Name == attachmentName){
                            if (attachmentContentToTypeMap.containsKey(currentAttachment.Name)) {
                                attachmentContentToTypeMap.get(currentAttachment.Name).add(currentAttachment.body.ToString());
                            } else {
                                attachmentContentToTypeMap.put(currentAttachment.Name, new List<String>{
                                        currentAttachment.body.ToString()
                                });
                            }
                        }
                    }
                }
            }
        }

        return attachmentContentToTypeMap;
    }

    public static List<Attachment> getAttachmentList(Set<Id> recordIdSet, List<String> fileNames) {

        List<Attachment> attachmentList = new List<Attachment>();

        if(recordIdSet!=null && !recordIdSet.isEmpty()) {

            attachmentList =
            [
                    SELECT		Id,
                            Name,
                            Body
                    FROM		Attachment
                    WHERE		ParentId = :recordIdSet
                    AND			Name IN :fileNames
                    ORDER BY	CreatedDate DESC
            ];
        }

        return attachmentList;
    }

    public static List<String> getAttachmentContentToDeserializeList(Set<Id> recordIdSet, String fileName) {

        List<String> attachmentContentList = new List<String>();

        List<Attachment> listAttachment = CS_Attachment.getAttachmentList(recordIdSet, fileName);

        if(!listAttachment.isEmpty()){

            for(Attachment currentAttachment : listAttachment) {

                if(currentAttachment.body != null) {
                    attachmentContentList.add(currentAttachment.body.ToString());
                }
            }
        }

        return attachmentContentList;
    }

    public static List<Attachment> getAttachmentList(Set<Id> recordIdSet, String fileName) {

        List<Attachment> attachmentList = new List<Attachment>();

        if(recordIdSet!=null && !recordIdSet.isEmpty()) {

            attachmentList =
            [
                    SELECT		Id,
                            Name,
                            Body
                    FROM		Attachment
                    WHERE		ParentId = :recordIdSet
                    AND			Name = :fileName
                    ORDER BY	CreatedDate DESC
            ];
        }

        return attachmentList;
    }

    public static List<Attachment> getAttachmentList(Set<Id> recordIdSet, Set<String> fileNames){
        List<Attachment> attachmentList = new List<Attachment>();

        if(recordIdSet!=null && !recordIdSet.isEmpty() && fileNames !=null && !fileNames.isEmpty()) {

            attachmentList =
            [
                    SELECT		Id,
                            Name,
                            Body
                    FROM		Attachment
                    WHERE		ParentId = :recordIdSet
                    AND			Name IN :fileNames
                    ORDER BY	CreatedDate DESC
            ];
        }

        return attachmentList;
    }

    // use with caution since the method is deleting all attachment file names from all the records
    public static void createAttachments(List<Attachment> attachmentList, Boolean deletePreviousAttachments) {

        if(attachmentList != null && !attachmentList.isEmpty()) {

            if(deletePreviousAttachments) {
                deletePreviousAttachmentsFromSameRecordsWithSameFileName(attachmentList);
            }

            INSERT attachmentList;
        }
    }

    // use with caution since the method is deleting all attachment file names from all the records
    public static void deletePreviousAttachmentsFromSameRecordsWithSameFileName(List<Attachment> attachmentList) {

        Set<Id> parentRecordId = new Set<Id>();
        Set<String> fileName = new Set<String>();

        if(attachmentList != null && !attachmentList.isEmpty()) {

            for(Attachment currentAttachment : attachmentList) {
                parentRecordId.add(currentAttachment.ParentId);
                fileName.add(currentAttachment.Name);
            }

            List<Attachment> attachmentToDeleteList =
            [
                    SELECT  Id
                    FROM    Attachment
                    WHERE   ParentId = :parentRecordId
                    AND     Name = :fileName
            ];

            if(attachmentToDeleteList != null && !attachmentToDeleteList.isEmpty()) {
                DELETE attachmentToDeleteList;
            }
        }
    }

    public static Attachment generateAttachment(String attachmentSerialized, Id parentId, String fileName) {

        Attachment attach = new Attachment();
        Blob attachmentBody = Blob.valueOf(attachmentSerialized);

        if(attachmentBody != null && parentId != null) {

            attach.IsPrivate = false;
            attach.ParentId = parentId;
            attach.Name = fileName;
            attach.Body = attachmentBody;
        }
        return attach;
    }

    // use with caution since the method is deleting all attachment file names from all the records
    public static void removeAttachments(List<String> attachmentNamesList, Id parentRecordId) {
        if(attachmentNamesList != null && parentRecordId != null) {
            List<Attachment> attachmentToDeleteList =
            [
                    SELECT  Id
                    FROM    Attachment
                    WHERE   ParentId = :parentRecordId
                    AND     Name IN :attachmentNamesList
            ];
            if(attachmentToDeleteList != null && !attachmentToDeleteList.isEmpty()) {
                DELETE attachmentToDeleteList;
            }
        }
    }
}
@isTest 
private class CS_AttachmentTest {

	@isTest 
	static void getAttachmentContentToDeserializeListTest() {
		Account acc = TestDataSetupTargetables.createAccount();
        insert acc;

        Set<Id> setAccounts = new Set<Id>{acc.Id};
        String attachName = 'testattach1234';

        Attachment  attach = new Attachment();
        attach.ParentId = acc.Id;  
        attach.Name = attachName;
        attach.Body = Blob.valueOf('Unit Test Attachment Body');
        insert attach;


        List<String> serializedAttachments;
        Test.startTest();
        	serializedAttachments = CS_Attachment.getAttachmentContentToDeserializeList(setAccounts, attachName);
        Test.stopTest(); 
        System.assert(serializedAttachments.Size() == 1);
        System.assertEquals('Unit Test Attachment Body', serializedAttachments[0]);
	}

	
	@isTest 
	static void getAttachmentListTest() {
		Account acc = TestDataSetupTargetables.createAccount();
        insert acc;

        Set<Id> setAccounts = new Set<Id>{acc.Id};
        String attachName = 'testattach1234';

        Attachment  attach = new Attachment();
        attach.ParentId = acc.Id;  
        attach.Name = attachName;
        attach.Body = Blob.valueOf('Unit Test Attachment Body');
        insert attach;


        List<Attachment> returnedAttachments;
        Test.startTest();
        	returnedAttachments = CS_Attachment.getAttachmentList(setAccounts, attachName);
        Test.stopTest(); 
        System.assert(returnedAttachments.Size() == 1);
        System.assertEquals('Unit Test Attachment Body', returnedAttachments[0].body.ToString());
	}

	@isTest 
	static void createAttachmentsTest() {
		Account acc = TestDataSetupTargetables.createAccount();
        insert acc;

        Set<Id> setAccounts = new Set<Id>{acc.Id};
        String attachName = 'testattach1234';

        List<Attachment> attachmentList = new List<Attachment>();

        Attachment  attach = new Attachment();
        attach.ParentId = acc.Id;  
        attach.Name = attachName;
        attach.Body = Blob.valueOf('Unit Test Attachment Body');
        attachmentList.add(attach);

        Test.startTest();
        	CS_Attachment.createAttachments(attachmentList, false);
        Test.stopTest(); 

        List<Attachment> attachmentListQueried = new List<Attachment>( 
									    		[
									    			SELECT		Id, 
									    						Name, 
									    						Body
									    			FROM		Attachment
									    			WHERE		ParentId = :acc.Id
									    			ORDER BY	CreatedDate DESC
									    		]);


        System.assert(attachmentListQueried.Size() == 1, 'One attachement should be attached to this records' );
	}

	@isTest 
	static void createDeleteAttachmentsTest() {
		Account acc = TestDataSetupTargetables.createAccount();
        insert acc;

        Set<Id> setAccounts = new Set<Id>{acc.Id};
        String attachName = 'testattach1234';
        String attachName2 = 'testattach123456';

        List<Attachment> attachmentList = new List<Attachment>();

        Attachment  attach = new Attachment();
        attach.ParentId = acc.Id;  
        attach.Name = attachName;
        attach.Body = Blob.valueOf('Unit Test Attachment Body');
        INSERT attach;

        Attachment  attach2 = new Attachment();
        attach2.ParentId = acc.Id;  
        attach2.Name = attachName2;
        attach2.Body = Blob.valueOf('Unit Test Attachment Body2');
        INSERT attach2;

        Attachment  attach3 = new Attachment();
        attach3.ParentId = acc.Id;  
        attach3.Name = attachName;
        attach3.Body = Blob.valueOf('Unit Test Attachment Body3');
        attachmentList.add(attach3);

        List<Attachment> attachmentListQueriedInitial = new List<Attachment>( 
									    		[
									    			SELECT		Id, 
									    						Name, 
									    						Body
									    			FROM		Attachment
									    			WHERE		ParentId = :acc.Id
									    			ORDER BY	CreatedDate DESC
									    		]);


        System.assert(attachmentListQueriedInitial.Size() == 2, 'Two attachements should be attached to this records' );

        Test.startTest();
        	CS_Attachment.deletePreviousAttachmentsFromSameRecordsWithSameFileName(attachmentList);
        Test.stopTest(); 

        List<Attachment> attachmentListQueried = new List<Attachment>( 
									    		[
									    			SELECT		Id, 
									    						Name, 
									    						Body
									    			FROM		Attachment
									    			WHERE		ParentId = :acc.Id
									    			ORDER BY	CreatedDate DESC
									    		]);


        System.assert(attachmentListQueried.Size() == 1, 'Only one attachement should be attached to this records' );
	}

	@isTest 
	
	static void generateAttachmentTest() {
		Account acc = TestDataSetupTargetables.createAccount();
        insert acc;

        String attachName = 'testattach1234';

        Test.startTest();
        	Attachment returnedRecord = CS_Attachment.generateAttachment('Unit Test Attachment Body', acc.Id, attachName);
        Test.stopTest(); 


        System.assert(returnedRecord.Name == attachName, 'Attachment has wrong name' );
        System.assert(returnedRecord.Body.ToString() == 'Unit Test Attachment Body', 'Attachment has wrong body value' );
	}
}
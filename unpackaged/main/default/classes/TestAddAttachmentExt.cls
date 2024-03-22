@isTest
public class TestAddAttachmentExt {
    
    static testMethod void testAttachmentExtInOpp() {
        
        //Attachment body
        Blob blobBody = Blob.valueOf('This is attachment file body');
        
        //Create opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.CloseDate = System.Today()+10;
        insert opp;    
        
        PageReference pr;
        
        test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        AddAttachmentExt e = new AddAttachmentExt(sc); //constructor
        
        //Assign values to name and body
        e.att.Name = 'Attachment';
        e.att.Body = blobBody;
        
        pr = e.AddAttachment(); //method call
        pr.getParameters().put('rId',opp.Id); //Assign rId which is set in AddAttachmentExt VisualForce page 
        e.doDelete(); //method call
        
        test.stopTest();
    }
}
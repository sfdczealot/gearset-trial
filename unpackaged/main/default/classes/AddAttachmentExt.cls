public with sharing class AddAttachmentExt 
{
    private ApexPages.StandardController stdCtrl;
    public Attachment att {get; set;}
    public String rId{get;set;}
    
    public AddAttachmentExt(ApexPages.StandardController inStd)
    {
        stdCtrl=inStd;
        att=new Attachment();
    }
    
    public PageReference AddAttachment()
    {
        att.ParentId=stdCtrl.getId();
        insert att;
        
        PageReference pr=ApexPages.currentPage();
        pr.setRedirect(true);
        
        return pr;
    }
    
    public pagereference doDelete(){
         delete [select id from attachment where id =: rId];
         PageReference pr=ApexPages.currentPage();
         pr.setRedirect(true);
        
         return pr;
    }

}
public class CS_OppNewSalesOrderExtension {

    private Opportunity opp ;

    public CS_OppNewSalesOrderExtension(ApexPages.StandardController controller) {
        opp = (Opportunity) controller.getRecord();
    }

    public PageReference NewSalesorder() {
        PageReference pr;

        if (opp.SO_Creation_Allowed__c ) {
            pr = new PageReference('/apex/csmso__OpportunitySalesOrderActions');
            pr.getParameters().put('id', opp.Id);
            pr.setRedirect(true);
        }

        return pr;
    }
}
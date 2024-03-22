/**
 * Created by petar on 28/8/20.
 */

public class CS_LoadSOInventoryPageController {
    private final csmso__Sales_Order__c so;

    public CS_LoadSOInventoryPageController(ApexPages.StandardController stdController) {
        this.so = (csmso__Sales_Order__c) stdController.getRecord();
    }

    public PageReference redirectToIBT() {
        PageReference IBTPage = new PageReference('/apex/csinvgridspt__InventoryGrid');
        

        return IBTPage;
    }
}
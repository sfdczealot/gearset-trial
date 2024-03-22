/**
 * @name CS_BatchReleaseInventory
 * @description Class that handles clearing inventory
 * @revision
 *
 */
public class CS_BatchReleaseInventory extends CS_BatchWorker implements Database.AllowsCallouts, Schedulable {
  // Language=Apex
  public static String QUERY_TEMPLATE =
      'SELECT Id, Product_Configuration__c, Product_Configuration__r.Reserve_Inventory__c, Product_Configuration__r.Reservation_Status__c, Product_Configuration__r.Sales_Order__c, Product_Configuration__r.Sales_Order__r.Inventory_Auto_Released__c ' +
          'FROM csdf__Fulfilment_Item__c ' +
          'WHERE (Product_Configuration__r.Sales_Order__r.Sold__c = FALSE ' +
          'AND Product_Configuration__r.Reserve_Expiration_Date__c < TODAY ' +
          'AND Product_Configuration__r.Reservation_Status__c != NULL ' +
          'AND Product_Configuration__r.Sales_Order__r.Inventory_Auto_Released__c = FALSE) {0} ' +
          'ORDER BY CreatedDate DESC';

  public Set<Id> salesOrderIds {get; set;}

  /**
   * Class constructor
   * @return CS_BatchReleaseInventory
   */
  public CS_BatchReleaseInventory() {
    this(null);
  }

  public CS_BatchReleaseInventory(Set<Id> salesOrderIds) {
    super('CS_BatchReleaseInventory', 50);
    this.salesOrderIds = salesOrderIds;
    this.queryString = getQueryString();
  }

  /**
   * Method that handles processing of Orders
   * @param  sObjects List<SObject>
   */
  public override void doWork(List<SObject> sObjects) {
    CS_DMLWorker dmlWorker = new CS_DMLWorker(false);

    List<Id> fulfilmentItemIds = new List<Id>();
    Set<Id> uniqueSOs = new Set<Id>();

    for(SObject obj : sObjects) {

      String reservationStatus = String.valueOf(CS_utl_SObject.getFieldValue(obj, 'Product_Configuration__r.Reservation_Status__c'));
      Id salesOrderID = String.valueOf(CS_utl_SObject.getFieldValue(obj, 'Product_Configuration__r.Sales_Order__c'));
      if (CS_utl_ProductConfiguration.isReserved(reservationStatus)){
        fulfilmentItemIds.add((Id) obj.get('Id'));
        dmlWorker.addForUpsert(new List<cscfga__Product_Configuration__c>{
            new cscfga__Product_Configuration__c(
                Id = (Id) obj.get('Product_Configuration__c'),
                Reserve_Inventory__c = Boolean.valueOf(CS_utl_SObject.getFieldValue(obj, 'Product_Configuration__r.Reserve_Inventory__c'))
            )
        });

        if (uniqueSOs.contains(salesOrderID)) {
          continue;
        }
        uniqueSOs.add(salesOrderID);
        dmlWorker.addForUpsert(new List<csmso__Sales_Order__c>{
            new csmso__Sales_Order__c(
                Id = String.valueOf(CS_utl_SObject.getFieldValue(obj, 'Product_Configuration__r.Sales_Order__c')),
                Inventory_Auto_Released__c = true
            )
        });
      }
    }

    if(!fulfilmentItemIds.isEmpty()) {
      if(!Test.isRunningTest()){
        csam.ObjectGraphCalloutHandler.createAndSendFromIds('Fulfilment Item Reserve Release', fulfilmentItemIds);
      }

      dmlWorker.doUpsert();
    }
  }

  /**
   * Method that creates the query string for batch
   * @return   String
   */
  private String getQueryString() {
    return String.format(QUERY_TEMPLATE, new List<String>{salesOrderIds != null ? 'AND Product_Configuration__r.Sales_Order__c IN (\'' + CS_utl_Array.join(new List<Id>(salesOrderIds), '\',\'') + '\')' : ''});
  }

  @TestVisible
  protected override Database.QueryLocator onStart() {
    this.queryString = getQueryString();
    return super.onStart();
  }
}
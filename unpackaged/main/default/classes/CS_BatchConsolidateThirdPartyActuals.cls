/**
 * Created by jameshladek on 2/11/20.
 *
 * This is a batch class that gathers Third Party Monthly Actuals data as related to a product configuration
 * then calculate the total number of Clicks or Impressions based on tne Insertion Unit Type on the
 * Product Configuration. Then take this total and put it on the related Billing Schedule Item and
 * Revenue Schedule Item
 *
 * @since February 11, 2020
 * @version 1.0
 * @author james.hladek@cloudsense.com
 */

public with sharing class CS_BatchConsolidateThirdPartyActuals extends CS_BatchWorker {

    /**
     * The constructor that will be called from the scheduler
     */
    public CS_BatchConsolidateThirdPartyActuals() {
        super('CS_BatchConsolidateThirdPartyActuals', 10);
    }

    public static void scheduleIt() {
        System.schedule('Consolidate 3rd Party Monthly Actuals', '0 0 20 3 * ?', new CS_BatchConsolidateThirdPartyActuals());
    }

    /**
     * Constructor that accepts two parameters and calls the parent class to start the batch process
     *
     * @param processName
     * @param batchSize
     */
    public override void init(String processName, Integer batchSize) {
        super.init(processName, batchSize);

        List<csdf__Custom_Report_Execution__c> reportExecution = [
                SELECT Id, csdf__Report_Status__c
                FROM csdf__Custom_Report_Execution__c
                WHERE CreatedDate = TODAY
                AND csdf__Custom_Report_Definition__r.Scheduled_Execution__c = TRUE
                AND csdf__Report_Status__c != 'Integration Error'
                AND csdf__Report_Status__c != 'Completed'
        ];
        this.delayExecution = !reportExecution.isEmpty();

    }

    /**
     * Method is used as the Start functionality on a Salesforce batch process.
     * The method gets the queryString to query for the Product Configurations,
     * Billing Schedule Items and Revenue Schedule Items. And passes back to the
     * parent method the performs query and passes the list on to the execute method.
     *
     * @return
     */
    public override Database.QueryLocator onStart() {
        this.queryString = getQueryString();
        return super.onStart();
    }

    /**
     * This method performs the work to be done by the batch process. The method queries the
     * Third Party Monthly Actuals records to calculate the number of Clicks or Impressions
     * That are related to the Product Configuration. After the data is tabulated the values
     * are populated on the Billing Schedule Item and the Revenue Schedule Item and then updates
     * these items.
     *
     * @param scope List of Product Configurations with Billing Schedule Items and Revenue Schedule Items.
     */
    public override void doWork(List<SObject> scope) {
        List<cscfga__Product_Configuration__c> configs = (List<cscfga__Product_Configuration__c>) scope;
        Set<String> lineIds = new Set<String>();
        List<SObject> billingScheduleItems = new List<SObject>();
        List<SObject> revenueScheduleItems = new List<SObject>();
        Map<String, List<AggregateResult>> resultById = new Map<String, List<AggregateResult>>();

        for (cscfga__Product_Configuration__c config : configs) {
            lineIds.add(config.Order_Line_ID__c);
        }
        for (AggregateResult result : getMonthlyAcutals(lineIds)) {
            String lineId = (String) result.get('Order_Line_Id__c');
            List<AggregateResult> results = resultById.get('lineId');
            if (results == null) {
                results = new List<AggregateResult>();
            }
            results.add(result);
            resultById.put(lineId, results);
        }
        for (cscfga__Product_Configuration__c pc : configs) {
            Decimal monthlyTotal = 0;
            if (resultById.containsKey(pc.Order_Line_ID__c)) {
                for (AggregateResult monthlyResult : resultById.get(pc.Order_Line_ID__c)) {
                    String localServer = (String) monthlyResult.get('Local_Server_Name__c');
                    if (pc.X3rd_Party_Ad_Server_Name__c == localServer) {
                        if (pc.Insertion_Unit_Type__c.equalsIgnoreCase('CPC')) {
                            monthlyTotal = (Decimal) monthlyResult.get('expr0');
                        } else {
                            monthlyTotal = (Decimal) monthlyResult.get('expr1');
                        }
                        for (CS_Billing_Schedule_Item__c bsi : pc.Billing_Schedule_Item__r) {
                            if(bsi.Billing_Calendar__c == CS_const_BillingScheduleItem.BillingCalendar_Standard) {
                                bsi.Third_Party_Monthly_Actuals__c = monthlyTotal;
                                billingScheduleItems.add(bsi);
                            }
                        }
                        for (CS_Revenue_Schedule_Item__c rsi : pc.Revenue_Schedule_Item__r) {
                            rsi.Third_Party_Monthly_Actuals__c = monthlyTotal;
                            revenueScheduleItems.add(rsi);
                        }

                    }
                }
            }
        }
        update billingScheduleItems;
        update revenueScheduleItems;
    }

/**
 * The string that is generated for the use in the Database.query method
 *
 * @return
 */
    private String getQueryString() {
        String query = 'SELECT Id, Flight_Begin__c, Flight_End__c, Insertion_Unit_Type__c, Order_Line_Id__c, X3rd_Party_Ad_Server_Name__c,' +
                ' (SELECT Id, Third_Party_Monthly_Actuals__c, Insertion_Unit_Type__c, X3rd_Party_Ad_Server__c, Product_Configuration__r.X3rd_Party_Ad_Server_Name__c, Billing_Calendar__c FROM Billing_Schedule_Item__r WHERE Billing_Date__c = LAST_MONTH),' +
                ' (SELECT Id, Third_Party_Monthly_Actuals__c, Insertion_Unit_Type__c, X3rd_Party_Ad_Server__c, Product_Configuration__r.X3rd_Party_Ad_Server_Name__c FROM Revenue_Schedule_Item__r WHERE Rev_Rec_Date__c = LAST_MONTH)' +
                ' FROM cscfga__Product_Configuration__c WHERE (Flight_Begin__c <= LAST_MONTH AND FLight_End__c >= LAST_MONTH) AND Billing_Source__c = \'3rd Party Actuals\'';
        return query;
    }

/**
 * Queries for the Third Party Monthly Actual records that are related to Product Configurations
 *
 * @param orderLineIds Set of Product Configuration ids.
 *
 * @return
 */
    private List<AggregateResult> getMonthlyAcutals(Set<String> orderLineIds) {
        return (List<AggregateResult>) [
                SELECT Order_Line_Id__c, Local_Server_Name__c, SUM(Clicks__c), SUM(Impressions__c)
                FROM Third_Party_Monthly_Actual__c
                WHERE Order_Line_Id__c IN :orderLineIds
                AND Report_Date__c = LAST_MONTH
                GROUP BY Order_Line_Id__c, Local_Server_Name__c
        ];
    }

}
/**
 * @name CS_ScheduledReportWorker
 * @description Class used to start report from DFP
 * @revision
 *
 */
public class CS_ScheduledReportWorker extends CS_ScheduledWorker implements Schedulable {
    public static final String ScheduledExecutionCritera_BillingDateOne = 'Billing Date + 1';

    /**
     * Class constructor
     * @param processName String
     * @return            CS_ScheduledReportWorker
     */
    public CS_ScheduledReportWorker() {
        super('CS_ScheduledReportWorker');
    }

    public CS_Custom_Settings__c customSettings {
        get {
            if (customSettings == null) {
                customSettings = CS_Custom_Settings__c.getInstance();
            }
            return customSettings;
        }
        set;
    }

    public List<Bill_Run__c> billRuns {
        get {
            if (billRuns == null) {
                billRuns = [SELECT Id, Billing_Date__c FROM Bill_Run__c WHERE Billing_Date__c = YESTERDAY];
            }
            return billRuns;
        }
        set;
    }

    /**
     * Method that implements work that needs to be done
     */
    @TestVisible
    public override void doWork() {
        List<csdf__Custom_Report_Definition__c> reportDefinitions = [
                SELECT Id, csdf__Default_Map_Parameters__c, Name, Frequency__c, Recurrence__c,
                        csdf__Ad_Server__r.csdf__Type__c, Scheduled_Execution_Criteria__c, (
                        SELECT Id, csdf__Report_Status__c, CreatedDate,
                                csdf__Map_Parameters__c
                        FROM csdf__Custom_Report_Executions__r
                        WHERE csdf__Report_Status__c = 'Completed'
                        ORDER BY CreatedDate DESC
                )
                FROM csdf__Custom_Report_Definition__c
                WHERE Scheduled_Execution__c = TRUE
        ];

        List<csdf__Custom_Report_Execution__c> executionReportsToInsert = new List<csdf__Custom_Report_Execution__c>();
        for (csdf__Custom_Report_Definition__c reportDefinition : reportDefinitions) {
            if (reportDefinition.Frequency__c == 'Daily' ||
                    (reportDefinition.Frequency__c == 'Weekly' && reportDefinition.Recurrence__c == Datetime.now().format('EEEEE')) ||
                    (reportDefinition.Frequency__c == 'Monthly' && Integer.valueOf(reportDefinition.Recurrence__c) == Date.today().day())) {
                if (shouldExecute(reportDefinition.Scheduled_Execution_Criteria__c)) {
                    csdf__Custom_Report_Execution__c reportExecution = new csdf__Custom_Report_Execution__c(
                            Name = reportDefinition.Name + ' ' + System.now(),
                            csdf__Custom_Report_Definition__c = reportDefinition.Id,
                            csdf__Report_Status__c = 'Scheduled',
                            csdf__Map_Parameters__c = getParameters(reportDefinition)
                    );
                    executionReportsToInsert.add(reportExecution);
                }
            }
        }

        if (!executionReportsToInsert.isEmpty()) {
            insert executionReportsToInsert;

            csam.ObjectGraphCalloutHandler.queueMultipleMessages('Custom Report Execution Run', new List<Id>(new Map<Id, csdf__Custom_Report_Execution__c>(executionReportsToInsert).keySet()));

        }
    }

    public String getParameters(csdf__Custom_Report_Definition__c reportDefinition) {
        if (ScheduledExecutionCritera_BillingDateOne.equalsIgnoreCase(reportDefinition.Scheduled_Execution_Criteria__c)) {
            return JSON.serialize(new MapParameters(
                    billRuns.get(0).Billing_Date__c,
                    billRuns.get(0).Billing_Date__c.addDays(1)
            ));
        } else if (reportDefinition.csdf__Ad_Server__r.csdf__Type__c == 'DFP' && !reportDefinition.csdf__Custom_Report_Executions__r.isEmpty()) {
            MapParameters params = (MapParameters) JSON.deserialize(reportDefinition.csdf__Custom_Report_Executions__r.get(0).csdf__Map_Parameters__c, MapParameters.class);
            return JSON.serialize(new MapParameters(
                    params.endDate.getDate() > Date.today().addDays(-1 * (customSettings.DFP_Actuals_Rolling_Days__c.intValue() + 1)) ? Date.today().addDays(-1 * (customSettings.DFP_Actuals_Rolling_Days__c.intValue() + 1)) : params.endDate.getDate(),
                    Date.today()
            ));
        }

        return reportDefinition.csdf__Default_Map_Parameters__c;
    }

    public Boolean shouldExecute(String criteria) {
        if (String.isBlank(criteria)) {
            return true;
        } else if (criteria.equalsIgnoreCase(ScheduledExecutionCritera_BillingDateOne)) {
            return !(billRuns.isEmpty());
        }

        return false;
    }

    public class MapParameters {
        public DateParameter startDate { get; set; }
        public DateParameter endDate { get; set; }

        public MapParameters() {
        }

        public MapParameters(Date startDate, Date endDate) {
            this.startDate = new DateParameter(startDate);
            this.endDate = new DateParameter(endDate);
        }
    }

    public class DateParameter {
        public Integer year { get; set; }
        public Integer month { get; set; }
        public Integer day { get; set; }

        public DateParameter() {
        }

        public DateParameter(Date dateValue) {
            this.year = dateValue.year();
            this.month = dateValue.month();
            this.day = dateValue.day();
        }

        public Date getDate() {
            return Date.newInstance(this.year, this.month, this.day);
        }
    }
}
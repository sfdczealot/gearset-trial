/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to calculate DFP / Third party actuals
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sasa Marjancic   <sasa.marjancic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            name@email.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text. 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public abstract class CS_ActualsBase {
    public static CS_Custom_Settings__c customSettings {
        get {
            if(customSettings == null) {
                customSettings = CS_Custom_Settings__c.getInstance();
            }
            return customSettings;
        }
        set;
    }
    
    public Date executeDate {get; set;}
    
    public Date asOfDate {get; set;}
    
    public Date scheduleStartDate {get; set;}
    
    public Date scheduleEndDate {get; set;}

    public Datetime flightBegin {get; set;}

    public Datetime flightEnd {get; set;}
    
    public String localTimeZone {get; set;}
    
    public String serverName {get; set;}
    
    public Set<Datetime> calculatedPeriods {
        get {
            if(calculatedPeriods == null) {
                calculatedPeriods = new Set<Datetime>();
            }
            return calculatedPeriods;
        }
        set;
    }

    public Set<String> uniquePeriods {
        get {
            if(uniquePeriods == null) {
                uniquePeriods = new Set<String>();
            }
            return uniquePeriods;            
        }
        set;
    }
    
    public Timezone tz {
        get {
            if(tz == null) {
                tz = TimeZone.getTimeZone(this.localTimeZone);
            }
            return tz;
        }
        set;
    }
    
    public Integer applicableLines;
    
    public Integer quantity;
    
    public Integer rollingQuantity;
    
    public Integer getOffset(Datetime targetDate) {
        return tz.getOffset(targetDate) / (1000 * 60 * 60);     
    }
    
    public Integer getHourOffset(Datetime targetDate) {
        Integer currentOffset = getOffset(targetDate.addHours(23));
        Integer previousOffset = getOffset(targetDate);
        
        if(currentOffset > previousOffset) {
            return (currentOffset - 1);
        }
        else if(currentOffset < previousOffset) {
            return (currentOffset + 1);
        }
        
        return (currentOffset);
    }
    
    public Datetime getCalculatedToDate() {
        List<Datetime> periods = new List<Datetime>(calculatedPeriods);
        periods.sort();
        
        Datetime calculatedTo = periods.get(periods.size() - 1);
        
        return Datetime.newInstanceGmt(calculatedTo.year(), calculatedTo.month(), calculatedTo.day() + 1, 0, 0, 0);
    }
    
    public CS_ActualsBase(Datetime flightBegin, Datetime flightEnd, Date scheduleStartDate, Date scheduleEndDate, Date asOfDate, String localTimeZone, String serverName, Date executeDate) {
        this.scheduleStartDate = scheduleStartDate;
        this.scheduleEndDate = scheduleEndDate;
        this.flightBegin = flightBegin;
        this.flightEnd = flightEnd;
        this.asOfDate = asOfDate;
        this.localTimeZone = localTimeZone;
        this.serverName = serverName;
        this.executeDate = executeDate;
        this.applicableLines = 0;
        this.quantity = 0;
        this.rollingQuantity = 0;
    }
    
    public void calculate(List<SObject> actuals, String insertionType) {
        String calculateField = insertionType.equalsIgnoreCase('CPC') ? 'Clicks__c' : 'Impressions__c';
        List<SObject> actualsForRollingDays = new List<SObject>();

        for(SObject actual : actuals) {
            if(isApplicable(actual)) {
                applicableLines += 1;
                quantity += Integer.valueOf(CS_utl_SObject.getDecimalValue(calculateField, actual));
                actualsForRollingDays.add(actual);
                calculatedPeriods.add(getLocalReportDate(actual));
                uniquePeriods.add(getUniqueId(actual));
            }
        }

        for(SObject actual : actualsForRollingDays) {
            Date rollingDate = getCalculatedToDate().date();
            if((getLocalReportDate(actual).date() >= rollingDate.addDays(getRollingDays() * -1))) {
                rollingQuantity += Integer.valueOf(CS_utl_SObject.getDecimalValue(calculateField, actual));
            }
        }
    }
    
    public abstract Boolean isApplicable(SObject actual);

    public abstract String getUniqueId(SObject actual);

    public abstract Integer getRollingDays();
    
    public Datetime getReportDate(SObject actual) {
        Map<String, Object> actualValues = actual.getPopulatedFieldsAsMap();
        return Datetime.newInstanceGmt((Date) actual.get('Report_Date__c'),
                                        Time.newInstance(actualValues.containsKey('Hour__c') ? ((Decimal) actual.get('Hour__c')).intValue() : 0, 0, 0, 0));
    }

    public abstract Datetime getLocalReportDate(SObject actual);
    
    public class CS_DFPActuals extends CS_ActualsBase {
        public CS_DFPActuals(Datetime flightBegin, Datetime flightEnd, Date scheduleStartDate, Date scheduleEndDate, Date asOfDate, String localTimeZone, String serverName, Date executeDate) {
            super(flightBegin, flightEnd, scheduleStartDate, scheduleEndDate, asOfDate, localTimeZone, serverName, executeDate);
        }
        
        public override Boolean isApplicable(SObject actual) {
            Datetime reportDate = getLocalReportDate(actual);
            
            return reportDate.date() >= scheduleStartDate && reportDate.date() <= scheduleEndDate &&
                   (asOfDate == null || reportDate.date().addDays(getRollingDays()) >= asOfDate) &&
                   (reportDate.date() < executeDate) &&
                   !uniquePeriods.contains(getUniqueId(actual));
        }

        public override String getUniqueId(SObject actual) {
            return String.valueOf(getLocalReportDate(actual));
        }

        public override Integer getRollingDays() {
            return (customSettings.DFP_Actuals_Rolling_Days__c.intValue() - 1);
        }

        public override Datetime getLocalReportDate(SObject actual) {
            Datetime gmtReportDate = getReportDate(actual);
            return gmtReportDate.addHours(getHourOffset(gmtReportDate));
        }
    }
    
    public class CS_ThirdPartyActuals extends CS_ActualsBase {
        public CS_ThirdPartyActuals(Datetime flightBegin, Datetime flightEnd, Date scheduleStartDate, Date scheduleEndDate, Date asOfDate, String localTimeZone, String serverName, Date executeDate) {
            super(flightBegin, flightEnd, scheduleStartDate, scheduleEndDate, asOfDate, localTimeZone, serverName, executeDate);
        }
        
        public override Boolean isApplicable(SObject actual) {
            Date reportDate = (Date) actual.get('Report_Date__c');
            String timezoneName = (String) actual.get('Time_Zone__c');
            
            Datetime reportDateGmt = getDateGMT(reportDate, Time.newInstance(0, 0, 0, 0), flightBegin, flightEnd, timezoneName);
            Datetime scheduleStartDateWithOffset = getDateGMT(scheduleStartDate, Time.newInstance(0, 0, 0, 0), flightBegin, flightEnd, this.localTimeZone);
            Datetime scheduleEndDateWithOffset = getDateGMT(scheduleEndDate, Time.newInstance(23, 59, 0, 0), flightBegin, flightEnd, this.localTimeZone);

            return //reportDateGmt >= scheduleStartDateWithOffset && reportDateGmt <= scheduleEndDateWithOffset &&
                    reportDate >= scheduleStartDate && reportDate <= scheduleEndDate &&
                   (asOfDate == null || (reportDate.addDays(getRollingDays()) >= asOfDate)) &&
                   (actual.get('Local_Server_Name__c') == serverName && String.isNotBlank(serverName)) &&
                   (reportDate < executeDate) &&
                   !uniquePeriods.contains(getUniqueId(actual));
        }

        public override String getUniqueId(SObject actual) {
            return String.valueOf(getLocalReportDate(actual)) + actual.get('Creative_Id__c');
        }

        public Datetime getDateGMT(Date inputDate, Time inputTime, Datetime flightBegin, Datetime flightEnd, String timezoneName) {
            Datetime inputDateDt = Datetime.newInstanceGmt(inputDate, inputTime);
            if(String.isNotBlank(timezoneName)) {
                inputDateDt = inputDateDt.addHours(-(TimeZone.getTimeZone(timezoneName).getOffset(inputDateDt) / (1000 * 60 * 60)));
            }

            if(inputDateDt.date() == flightBegin.date()) return flightBegin;
            else if(inputDateDt.date() == flightEnd.date()) return flightEnd;
            else return inputDateDt;
        }

        public override Integer getRollingDays() {
            return (customSettings.X3rd_Party_Actuals_Rolling_Days__c.intValue() - 1);
        }

        public override Datetime getLocalReportDate(SObject actual) {
            return getReportDate(actual);
        }
    }
}
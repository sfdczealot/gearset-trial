public class BatchToComputeTotalSpending_Scheduler implements Schedulable {
    static DateTime temp_StartDate;
    public static void scdeuleJob(Datetime testStartDate){
        temp_StartDate = testStartDate;
        String cronexpression = '0 0 0 ' + temp_StartDate.day() +' '+ temp_StartDate.month()+ ' ?';
        BatchToComputeTotalSpending_Scheduler.execute(null);
        
    }
    public static void execute(SchedulableContext SC) {
        Datetime targetTime;
        if (temp_StartDate!=null) {
             targetTime = temp_StartDate;
        } else{
             targetTime = System.today();  
        }
          Date CED = calculateCED(targetTime);
       
        Date targetTime_temp = date.newinstance(targetTime.year(), targetTime.month(), targetTime.day()).addmonths(-1);
        BatchToComputeTotalSpending obj = new BatchToComputeTotalSpending('Singapore',false);
        BatchToComputeTotalSpending Malaysia_batch = new BatchToComputeTotalSpending('Malaysia',false);
       
        // Checks for quartely month
        if(targetTime_temp.month() == CED.month()){ 
            Datetime nextStart =AddDays(targetTime); 
            String cronexpression = '0 0 0 ' + nextStart.day() +' '+ nextStart.month()+ ' ?';
            String cronexpression_Malaysia = '0 0 0 ' + nextStart.day() +' '+ nextStart.month()+ ' ?';
            system.schedule('BatchToComputeTotalSpending_Singapore Job Submitted At ' + String.valueOf(Datetime.now()), cronexpression, obj);
            system.schedule('BatchToComputeTotalSpending_Malaysia Job Submitted At ' + String.valueOf(Datetime.now()), cronexpression, Malaysia_batch);
           
        }
        
    }
                                                                      
    public static Datetime AddDays(Datetime dSartDate){ 
        String businessHoursName =  System.label.BusinessHour;
        BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE Name = : businessHoursName];   
        DateTime nextDay = BusinessHours.nextStartDate(bHours.id, dSartDate); 
        DateTime secondWorkingDay = BusinessHours.add(bHours.id, nextDay, 86400000);
    
        return secondWorkingDay;
    }    
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    public static Date calculateCED(DateTime dStartDate){
        date calculationEndDate;
               
        Integer month = dStartDate.month();
        
        if(month/3 == 0){
            calculationEndDate = date.newInstance(Date.today().year()-1, 12, date.daysInMonth(Date.today().year()-1, 12));
            
        }
        else if(month/3 <= 1){
            if(math.mod(month,3) ==0){
                calculationEndDate = date.newInstance(Date.today().year()-1, 12, date.daysInMonth(Date.today().year()-1, 12));
                
            }
            if(math.mod(month,3) ==1){
                calculationEndDate = date.newInstance(Date.today().year(), 3, date.daysInMonth(Date.today().year(), 3));
                
            }
            if(math.mod(month,3) ==2){
                calculationEndDate = date.newInstance(Date.today().year(), 3, date.daysInMonth(Date.today().year(), 3));
                
            }
        }
        else if(month/3 <= 2){
            if(math.mod(month,3) ==0){
                calculationEndDate = date.newInstance(Date.today().year(), 3, date.daysInMonth(Date.today().year(), 3));
                
            }
            if(math.mod(month,3) ==1){
                calculationEndDate = date.newInstance(Date.today().year(), 6, date.daysInMonth(Date.today().year(), 6));
                
            }
            if(math.mod(month,3) ==2){
                calculationEndDate = date.newInstance(Date.today().year(), 6, date.daysInMonth(Date.today().year(), 6));
                
            }
        }
        else  if(month/3 <= 3){
            if(math.mod(month,3) ==0){
                calculationEndDate = date.newInstance(Date.today().year(), 6, date.daysInMonth(Date.today().year(), 6));
            }
            if(math.mod(month,3) ==1){
                calculationEndDate = date.newInstance(Date.today().year(), 9, date.daysInMonth(Date.today().year(), 9));
                
            }
            if(math.mod(month,3) ==2){
                calculationEndDate = date.newInstance(Date.today().year(), 9, date.daysInMonth(Date.today().year(), 9));
            }
        }
        else {
            calculationEndDate = date.newInstance(Date.today().year(), 9, date.daysInMonth(Date.today().year(), 9));
        } 
              return calculationEndDate;
    }
    
}
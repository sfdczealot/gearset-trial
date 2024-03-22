public class createCampaignInfluenceClass implements Queueable{
    
    List<CampaignInfluence> CampaignInfluenceList;
    public createCampaignInfluenceClass(List<CampaignInfluence> CampaignInfluenceList){
        this.CampaignInfluenceList = new List<CampaignInfluence>();
        this.CampaignInfluenceList = CampaignInfluenceList;
        system.debug('CampaignInfluenceList!!! '+CampaignInfluenceList);
    }
    public void execute(QueueableContext qc){
        
        sleep(10000);
        if(!CampaignInfluenceList.isEmpty())
            Database.insert(CampaignInfluenceList,false);
    }
    
    public static void sleep(Long milliSeconds){
        if(Test.isRunningTest()){
        	milliSeconds = 0;
        }
        Long timeDiff = 0;
            DateTime firstTime = System.now();
            do{
                timeDiff = System.now().getTime() - firstTime.getTime();
            }while(timeDiff <= milliSeconds);
        
    }
}
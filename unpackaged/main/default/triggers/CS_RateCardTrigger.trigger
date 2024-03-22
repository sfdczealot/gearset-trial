/**
* @name CS_SalesOrderDelegate
* @description trigger class for object csmso__Rate_Card__c. 
* Prevents insertion of duplicate Rate cards for the same time period for the same Account/Market.
* @revision
* Ivan Ravnjak (CloudSense) 11-09-2018 Created class
*/
trigger CS_RateCardTrigger on csmso__Rate_Card__c (before insert,before update) {
    // Check the Custom settings to see if we are running triggers
    if (!CS_TriggerHandler.GetTriggersEnabled())
        return;

    // Check the Custom settings to see if we are running triggers
    if(CS_utl_user.isTriggerActiveForMe()) {

        List<csmso__Rate_Card__c> ListOfRateCards = new List<csmso__Rate_Card__c>([SELECT Type__c, Order_Type__c, csmso__Product_Node__c, Account__c, csmso__From_Date__c, csmso__To_Date__c from csmso__Rate_Card__c limit 10000 ]);

        if (trigger.isBefore && trigger.isInsert) {
            for(csmso__Rate_Card__c NewObj: Trigger.new) {
                List<csmso__Rate_Card__c> overlapingRcs = new List<csmso__Rate_Card__c>();

                for(csmso__Rate_Card__c currRc:ListOfRateCards) {
                    if( (
                         (NewObj.csmso__To_Date__c >= currRc.csmso__From_Date__c && NewObj.csmso__To_Date__c <= currRc.csmso__To_Date__c) ||
                           (NewObj.csmso__From_Date__c >= currRc.csmso__From_Date__c && NewObj.csmso__To_Date__c<= currRc.csmso__To_Date__c) ||
                           (NewObj.csmso__From_Date__c >= currRc.csmso__From_Date__c && NewObj.csmso__From_Date__c <= currRc.csmso__To_Date__c) ||
                           (NewObj.csmso__From_Date__c < currRc.csmso__To_Date__c&& NewObj.csmso__To_Date__c> currRc.csmso__To_Date__c )
                           )
                          )
                        {   
                            overlapingRcs.add(currRc);
                        }
                }

                for (csmso__Rate_Card__c currRc : overlapingRcs) {
                    //Ensure there are no Rate Cards with Type = Base with dates overlay with another Rate Card with Type = Base for the SAME Market (Product Node)
                    //if ( NewObj.Type__c == 'Base' && currRc.Type__c == 'Base' && NewObj.csmso__Product_Node__c == currRc.csmso__Product_Node__c 
                    //    && NewObj.Order_Type__c == currRc.Order_Type__c ) {
                    //    NewObj.addError('Overlapping dates with another "Base" Rate Card with the same Product Node and Order Type! Id:'+currRc.Id);
                    //} 
                    //Ensure there are no Rate Cards with Type = Customer Price List with dates overlay with another Rate Card with Type = Customer Price List 
                    //for the SAME Account. 
                    //else 
                    if ( NewObj.Type__c == 'Customer Price List' && currRc.Type__c == 'Customer Price List' && NewObj.Account__c == currRc.Account__c  
                        && NewObj.Order_Type__c == currRc.Order_Type__c ) {
                        NewObj.addError('Overlapping dates with another "Customer" Rate Card with the same Account and Order Type! Id:'+currRc.Id);
                    } 
                    //Ensure there are no Rate Cards with Type = Seasonal with dates overlay with another Rate Card with Type = Seasonal for the SAME Market (Product Node) 
                    else if ( NewObj.Type__c == 'Seasonal' && currRc.Type__c == 'Seasonal' && NewObj.csmso__Product_Node__c == currRc.csmso__Product_Node__c  
                        && NewObj.Order_Type__c == currRc.Order_Type__c ) {
                        NewObj.addError('Overlapping dates with another "Seasonal" Rate Card with the same Product Node and Order Type! Id:'+currRc.Id);
                    } 
                }
            }
        }

        if (trigger.isBefore && trigger.isUpdate) {
            for(Sobject NewObj: Trigger.new) {
                List<csmso__Rate_Card__c> overlapingRcs = new List<csmso__Rate_Card__c>();

                csmso__Rate_Card__c rcNew = (csmso__Rate_Card__c) NewObj;
                csmso__Rate_Card__c rcOld = (csmso__Rate_Card__c) Trigger.oldMap.get(rcNew.Id);
                
                for(csmso__Rate_Card__c currRc:ListOfRateCards) {
                    if( (
                         (rcNew.csmso__To_Date__c >= currRc.csmso__From_Date__c && rcNew.csmso__To_Date__c <= currRc.csmso__To_Date__c) ||
                           (rcNew.csmso__From_Date__c >= currRc.csmso__From_Date__c && rcNew.csmso__To_Date__c<= currRc.csmso__To_Date__c) ||
                           (rcNew.csmso__From_Date__c >= currRc.csmso__From_Date__c && rcNew.csmso__From_Date__c <= currRc.csmso__To_Date__c) ||
                           (rcNew.csmso__From_Date__c < currRc.csmso__To_Date__c&& rcNew.csmso__To_Date__c> currRc.csmso__To_Date__c )
                           )
                          )
                        {   
                            if ( rcNew.Id != currRc.Id ) {
                                system.debug('currRc dates ' + currRc);
                                system.debug('rcNew dates ' + rcNew);
                                overlapingRcs.add(currRc);
                            }
                        }
                }
                system.debug('overlapingRcs ' + overlapingRcs);
                for (csmso__Rate_Card__c currRc : overlapingRcs) {
                    //Ensure there are no Rate Cards with Type = Base with dates overlay with another Rate Card with Type = Base for the SAME Market (Product Node)
                    //if ( rcNew.Type__c == 'Base' && currRc.Type__c == 'Base' && rcNew.csmso__Product_Node__c == currRc.csmso__Product_Node__c 
                    //    && rcNew.Order_Type__c == currRc.Order_Type__c ) {
                    //    rcNew.addError('Overlapping dates with another "Base" Rate Card with the same Product Node and Order Type! Id:'+currRc.Id);
                    //} 
                    //Ensure there are no Rate Cards with Type = Customer Price List with dates overlay with another Rate Card with Type = Customer Price List 
                    //for the SAME Account. 
                    //else 
                    if ( rcNew.Type__c == 'Customer Price List' && currRc.Type__c == 'Customer Price List' && rcNew.Account__c == currRc.Account__c  
                        && rcNew.Order_Type__c == currRc.Order_Type__c ) {
                        rcNew.addError('Overlapping dates with another "Customer" Rate Card with the same Account and Order Type! Id:'+currRc.Id);
                    } 
                    //Ensure there are no Rate Cards with Type = Seasonal with dates overlay with another Rate Card with Type = Seasonal for the SAME Market (Product Node) 
                    else if ( rcNew.Type__c == 'Seasonal' && currRc.Type__c == 'Seasonal' && rcNew.csmso__Product_Node__c == currRc.csmso__Product_Node__c  
                        && rcNew.Order_Type__c == currRc.Order_Type__c ) {
                        rcNew.addError('Overlapping dates with another "Seasonal" Rate Card with the same Product Node and Order Type! Id:'+currRc.Id);
                    } 
                }
            }
        }
    }
}
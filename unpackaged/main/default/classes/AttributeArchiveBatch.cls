//Batch Class to archive attributes on configs in Sales orders once flagged
global class AttributeArchiveBatch implements Database.Batchable<cscfga__Product_Configuration__c>
{
    /*Start method */
    global Iterable<cscfga__Product_Configuration__c> start(Database.BatchableContext BC)
    {
        return (Iterable<cscfga__Product_Configuration__c>)AttributeArchiveHelper.getProductConfigurationsToArchive();
    }

    /*Execute method */
    global void execute(Database.BatchableContext bc, List<cscfga__Product_Configuration__c> scope)
    {
        AttributeArchiveHelper.archiveProductConfigs(scope);
    }

    /*Finish method */
    global void finish(Database.BatchableContext bc){
       
    }
}
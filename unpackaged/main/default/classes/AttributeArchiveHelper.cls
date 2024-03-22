//Archives Attributes on Sales Order Configs to JSON also reinstates them if required.
global class AttributeArchiveHelper implements Schedulable
{

    private static final string AttachmentName = 'Attribute_JSON.json';

    Id salesOrderId;

    public AttributeArchiveHelper(Id salesOrderId) {
        this.salesOrderId = salesOrderId;
    }

    public static void prepareWork(Id salesOrderId, List<cscfga__Product_Configuration__c> configs, String oType) {
        CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();
        Integer totalConfigs = configs.size();
        
        for(Integer i = 0; i < Math.ceil((Decimal)totalConfigs / CS_Custom_Settings__c.getInstance().Sync_Retraction_SOLI_Limit__c).intValue(); i++) {
            Integer currentConfigSize = configs.size();
            List<cscfga__Product_Configuration__c> currentConfigList = new List<cscfga__Product_Configuration__c>();

            for(Integer j = 0; j < CS_Custom_Settings__c.getInstance().Sync_Retraction_SOLI_Limit__c && j < currentConfigSize; j++) { 
                currentConfigList.add(configs.remove(0));
            }
            
            dispatcher.addWorker(new CS_AttributeArchiveHelperWorker(new Map<String, Object> {
                'type' => oType,
                'salesOrderId' => salesOrderId,
                'productConfigurationList' => currentConfigList
            }));
        }
        
        dispatcher.dispatch();
    }
    
    // Scheduleable element
    global void execute(SchedulableContext sc){
        AttributeArchiveBatch ab = new AttributeArchiveBatch();
        database.executeBatch(ab, 20);
    }
    
    webservice static boolean archiveProductConfigs(List<cscfga__Product_Configuration__c> configs)
    {

        CS_utl_User.isTriggerDeactivationEnabledForAllTriggers = true;
        CS_LogWorker log = CS_LogWorker.getInstance();

        Id currentSalesOrderId;

        Attachment[] jsonFiles = new Attachment[]{};
        cscfga__Attribute__c[] attsToDelete = new cscfga__Attribute__c[]{};
        cscfga__Attribute__c[] attsToUpdate = new cscfga__Attribute__c[]{};

        Map<Id, csmso__Sales_Order__c> idToSalesOrder = new Map<Id, csmso__Sales_Order__c>();
        
        Savepoint sPoint = Database.setSavepoint();
        try
        {
            for (cscfga__Product_Configuration__c config : configs)
            {
                if(config.Is_archived__c)
                    continue;

                currentSalesOrderId = config.cscfga__product_basket__r.csmso__Sales_Order__c;
                 
                string jsonData  = JSON.serializePretty(config);
                 
                Attachment a = new Attachment();
                a.ParentId = config.Id;
                a.Body = blob.valueOf(jsonData);
                a.contentType = 'text/javascript';
                a.Name = AttachmentName;
                jsonFiles.add(a);
                 
                for (cscfga__Attribute__c attrib :config.cscfga__Attributes__r )
                {
                    if (attrib.cscfga__Attribute_Definition__r.Do_Not_archive__c == true)
                        attsToUpdate.add(attrib);
                    else
                        attsToDelete.add(attrib);
                }

                // Flag the SO as being archived
                config.cscfga__product_basket__r.csmso__Sales_Order__r.Is_archived__c = true;
                config.cscfga__product_basket__r.csmso__Sales_Order__r.Can_archive__c = false;

                idToSalesOrder.put(config.cscfga__product_basket__r.csmso__Sales_Order__c, config.cscfga__product_basket__r.csmso__Sales_Order__r);
            }

            insert jsonFiles;
            delete attsToDelete;
            update attsToUpdate;

            sObject[] objs = new sobject[]{};

            objs.addAll(idToSalesOrder.values());
            for (Attachment a : jsonFiles)
            {
                cscfga__Product_Configuration__c config = new cscfga__Product_Configuration__c(Id = a.ParentId);
                config.JSON_Archive_Id__c = a.Id;
                objs.add(config);
            }

            update objs;
        }
        catch (exception e)
        {
            Database.Rollback(sPoint);
            
            csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c(
                Id = currentSalesOrderId,
                is_archived__c = false,
                Can_archive__c = true,
                Loading_Screen__c = 'Off'
            );

            log.addMessage(e, currentSalesOrderId);
            log.save('AttributeArchiveHelper', 'archiveProductConfigs', null, false);

            update salesOrder;
            
            return false;
        }

        CS_utl_User.isTriggerDeactivationEnabledForAllTriggers = false;
        
        return true;
    }

    // RESTORE ATTRIBUTES FROM JSON ARCHIVE (MEDIA ONLY)
    webservice static boolean restoreSalesOrderConfigs(id salesOrderId)
    {
        CS_utl_User.isTriggerDeactivationEnabledForAllTriggers = true;

        CS_LogWorker log = CS_LogWorker.getInstance();

        System.Savepoint sPoint = Database.setSavepoint();
        // Update the Sales Order before Querying the Attributes, otherwise the
        // changes will not be reflected within the transaction.
        csmso__Sales_Order__c so = new csmso__Sales_Order__c(id = salesOrderId, is_archived__c = false);

        try {
            // Get the Configs to be restored.
            cscfga__Product_Configuration__c[] configs = getSOConfigs(salesOrderId);

            update so;

            if (configs.size() == 0 )
            {
                return false;
            }

            prepareWork(salesOrderId, configs, 'restore');
        }
        catch(Exception e) {
            Database.Rollback(sPoint);
            so.is_archived__c = true;
            so.Loading_Screen__c = 'Off';

            log.addMessage(e, salesOrderId);
            log.save('AttributeArchiveHelper', 'Synchronous', null, false);

            update so;
            
            return false;
        }

        CS_utl_User.isTriggerDeactivationEnabledForAllTriggers = false;
        
        return true;
    }

    public boolean restoreSalesOrderConfigs(List<cscfga__Product_Configuration__c> configs)
    {
        CS_utl_User.isTriggerDeactivationEnabledForAllTriggers = true;

        CS_LogWorker log = CS_LogWorker.getInstance();
        map<id, Attachment> archives  = getArchiveAttachmentsByConfigId(salesOrderId);

        Savepoint sPoint = Database.setSavepoint();
        
        if (archives.size() == 0) 
        {
            return false; 
        }
        
        cscfga__Attribute__c[] attributesToInsert = new cscfga__Attribute__c[]{};
        cscfga__Attribute__c[] attributesToDelete = new cscfga__Attribute__c[]{}; 
        Attachment[] attsToDelete = new Attachment[]{};
        
        try
        {
            for (cscfga__Product_Configuration__c config : configs)
            {
                
                if (!config.is_archived__c)
                    continue;
                                 
                if (archives.containsKey(config.Id))
                {
                    Attachment a = archives.get(config.id);
                    string jsonText = a.body.toString();
                    cscfga__Product_Configuration__c oldConfig = (cscfga__Product_Configuration__c)JSON.Deserialize(jsonText,cscfga__Product_Configuration__c.Class);
                    attributesToInsert.addall(oldConfig.cscfga__attributes__r.Clone());                    
                    
                    // Clear down the 'un archived' attributes, and also the attachments
                    attributesToDelete.addAll(config.cscfga__attributes__r);
                    attsToDelete.add(a);
                }
                 
                config.JSON_Archive_Id__c = null;
                
            }
            for (cscfga__Attribute__c attr : attributesToInsert)
            {
                attr.Id = null;
            }

            delete attributesToDelete;
            insert attributesToInsert;
            update configs;
            delete attsToDelete;
        }
        catch (exception e)
        {
            Database.Rollback(sPoint);
            csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c(
                Id = salesOrderId,
                is_archived__c = true,
                Loading_Screen__c = 'Off'
            );

            log.addMessage(e, salesOrderId);
            log.save('AttributeArchiveHelper', 'Synchronous', null, false);

            update salesOrder;
            
            return false;
        }

        CS_utl_User.isTriggerDeactivationEnabledForAllTriggers = false;
        
        return true;
    }
    
    private static cscfga__Product_Configuration__c[] getSOConfigs(id salesOrderId)
    {
        return [Select Id, JSON_Archive_Id__c, 
                            Is_Archived__c, 
                            cscfga__product_basket__r.csmso__Sales_Order__r.can_archive__c,
                            cscfga__product_basket__r.csmso__Sales_Order__r.Is_archived__c, 
                            (select   
                            Name,
                            cscfga__Annualised_Price__c, 
                            cscfga__Attribute_Definition__c, 
                            cscfga__Attribute_Definition__r.Do_Not_archive__c,
                            cscfga__Billing_Price__c, 
                            cscfga__Cascade_value__c, 
                            cscfga__Discount_Amount__c, 
                            cscfga__Discount_Type__c, 
                            cscfga__Display_Value__c, 
                            cscfga__Hidden__c, 
                            cscfga__is_active__c, 
                            cscfga__Is_Line_Item__c, 
                            cscfga__Is_rate_line_item__c, 
                            cscfga__Is_Read_Only__c, 
                            cscfga__Is_Required__c, 
                            cscfga__Key__c, 
                            cscfga__Line_Item_Description__c, 
                            cscfga__Line_Item_Sequence__c, 
                            cscfga__List_Price__c, 
                            cscfga__Price__c, 
                            cscfga__Product_Configuration__c, 
                            cscfga__Recurring__c, 
                            cscfga__Value__c 
                            from cscfga__Attributes__r)
                    from cscfga__Product_Configuration__c 
                    where cscfga__product_basket__r.csmso__Sales_Order__c = :salesOrderId 
                    AND 
                    (cscfga__product_basket__r.csmso__Sales_Order__r.can_archive__c = true 
                       OR cscfga__product_basket__r.csmso__Sales_Order__r.is_archived__c = true)
                    AND cscfga__product_basket__r.csmso__Sales_Order__r.never_archive__c = false];
        
    }

    global static cscfga__Product_Configuration__c[] getProductConfigurationsToArchive()
    {
        return [Select Id, JSON_Archive_Id__c, 
                            Is_Archived__c,
                            cscfga__product_basket__r.csmso__Sales_Order__c,
                            cscfga__product_basket__r.csmso__Sales_Order__r.can_archive__c,
                            cscfga__product_basket__r.csmso__Sales_Order__r.Is_archived__c, 
                            (select   
                            Name,
                            cscfga__Annualised_Price__c, 
                            cscfga__Attribute_Definition__c, 
                            cscfga__Attribute_Definition__r.Do_Not_archive__c,
                            cscfga__Billing_Price__c, 
                            cscfga__Cascade_value__c, 
                            cscfga__Discount_Amount__c, 
                            cscfga__Discount_Type__c, 
                            cscfga__Display_Value__c, 
                            cscfga__Hidden__c, 
                            cscfga__is_active__c, 
                            cscfga__Is_Line_Item__c, 
                            cscfga__Is_rate_line_item__c, 
                            cscfga__Is_Read_Only__c, 
                            cscfga__Is_Required__c, 
                            cscfga__Key__c, 
                            cscfga__Line_Item_Description__c, 
                            cscfga__Line_Item_Sequence__c, 
                            cscfga__List_Price__c, 
                            cscfga__Price__c, 
                            cscfga__Product_Configuration__c, 
                            cscfga__Recurring__c, 
                            cscfga__Value__c 
                            from cscfga__Attributes__r)
                    from cscfga__Product_Configuration__c 
                    where (cscfga__product_basket__r.csmso__Sales_Order__r.can_archive__c = true 
                                OR cscfga__product_basket__r.csmso__Sales_Order__r.is_archived__c = true)
                    AND cscfga__product_basket__r.csmso__Sales_Order__r.never_archive__c = false];
        
    }

    private static map<id, Attachment> getArchiveAttachmentsByConfigId(id salesOrderId)
    {
            
        id[] attachmentIds = new id[]{};
        
         for (cscfga__Product_Configuration__c config : [Select Id, JSON_Archive_Id__c, Is_Archived__c
                            FROM cscfga__Product_Configuration__c
                            WHERE cscfga__product_basket__r.csmso__Sales_Order__c = :salesOrderId
                            And Is_Archived__c = true])
        {
                
            attachmentIds.add(config.JSON_Archive_Id__c);
        }
        
        Attachment[] atts = [select Id, ParentId, body, name from Attachment where id in :attachmentIds and Name = :AttachmentName];
        
        map<id, Attachment> attachmentbyConfigId = new map<id,attachment>();
        
        for (Attachment att : atts)
        {
            attachmentbyConfigId.put(att.ParentId, att);   
        }
        
        return attachmentbyConfigId;
        
    }
    
    global static csmso__Sales_Order__c[] getSalesOrdersToArchive()
    {
        return [select Id from csmso__Sales_Order__c where can_archive__c = true and never_archive__c = false and is_archived__c = false];
        
    }

    public class CS_AttributeArchiveHelperWorker extends CS_QueueableWorker {
        public CS_AttributeArchiveHelperWorker(Object params) {
            super('CS_AttributeArchiveHelperWorker', params);
        }
        
        public override void doWork() { 
            System.Savepoint sPoint = Database.setSavepoint();
            Map<String, Object> paramsType = (Map<String, Object>) this.params;
            Id salesOrderId = (Id) paramsType.get('salesOrderId');
            
            try {   
                if(String.valueOf(paramsType.get('type')) == 'restore') {
                    AttributeArchiveHelper attributeArchiveHelper = new AttributeArchiveHelper(salesOrderId);
                    attributeArchiveHelper.restoreSalesOrderConfigs((List<cscfga__Product_Configuration__c>) paramsType.get('productConfigurationList'));
                    if(this.nextWorker == null) {
                        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c(
                            Id = salesOrderId,
                            is_archived__c = false,
                            Loading_Screen__c = 'Off'
                        );
                        update salesOrder;
                    }
                }
            }
            catch(Exception e) {
                this.nextWorker = null;
                
                Database.rollback(sPoint);

                csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c(
                    Id = salesOrderId,
                    is_archived__c = true
                );
               
                log.addMessage(e, salesOrderId);
                log.save('AttributeArchiveHelper', CS_const_ApexJob.JobType_Queueable, getJobId(), false);

                update salesOrder;
            }
        }   
    }
    
}